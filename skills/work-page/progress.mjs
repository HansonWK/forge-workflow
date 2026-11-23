#!/usr/bin/env node
// node progress.mjs <work folder> [--changed]
// Builds the work page's live progress document from status.md, plan.md, work-page.json, the proof folder,
// the branch's commits and the tier ledger, and writes it to <work folder>/progress.json.
// --changed also writes progress.patch.json holding only the top-level keys that differ from the last copy
// sent (progress.sent.json), for ArtifactData update; it prints "no change" when there is nothing to send.
import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

// The proof folder, relative to the work folder. /install changes it if the project keeps proofs elsewhere.
const PROOF_DIR = 'proof';
const EXCERPT_LINES = 20;
const LINE_CHARS = 200;
const SIGNOFF_STAGES = ['Sign-off', 'PR', 'Testing on the PR environment', 'Merged', 'Testing on dev', 'Done'];

const args = process.argv.slice(2);
const workDirArg = args.find((a) => !a.startsWith('--'));
if (!workDirArg) {
  console.error('usage: node progress.mjs <work folder> [--changed]');
  process.exit(1);
}
const workDir = resolve(workDirArg);
const proofDir = join(workDir, PROOF_DIR);
const read = (p) => (existsSync(p) ? readFileSync(p, 'utf8') : '');
const readJson = (p) => (existsSync(p) ? JSON.parse(readFileSync(p, 'utf8')) : null);

const status = read(join(workDir, 'status.md'));
const plan = read(join(workDir, 'plan.md'));
const page = readJson(join(workDir, 'work-page.json')) || { subtasks: [] };

const field = (name) => (status.match(new RegExp(`^(?:- )?${name}:[ \\t]*(.*)$`, 'm')) || [])[1]?.trim() || '';
const section = (md, heading) => {
  const start = md.search(new RegExp(`^## ${heading}\\s*$`, 'mi'));
  if (start < 0) return [];
  const rest = md.slice(start).split('\n').slice(1);
  const end = rest.findIndex((l) => /^#{1,2} /.test(l));
  return (end < 0 ? rest : rest.slice(0, end)).filter((l) => l.startsWith('- '));
};

// A subtask is done once it is committed: its **SHA:** line in plan.md is filled, or a commit carries its title.
const shaInPlan = Object.fromEntries(
  page.subtasks.map((s) => {
    const start = plan.search(new RegExp(`^### ${s.n}\\. `, 'm'));
    const rest = start < 0 ? '' : plan.slice(start + 4);
    const end = rest.search(/^#{2,3} /m);
    const body = end < 0 ? rest : rest.slice(0, end);
    return [String(s.n), (body.match(/^\*\*SHA:\*\*\s*`?([0-9a-f]{7,40})`?/m) || [])[1]];
  }),
);
const batch = field('batch')
  .replace(/[[\]]/g, '')
  .split(/[\s,]+/)
  .filter(Boolean)
  .map(Number)
  .filter(Number.isInteger);
const batchStatus = field('batch_status') || 'doing';

// Evidence for subtask 3 is every proof file named 3-<anything>; for group P1, P1-<anything>.
const proofFiles = existsSync(proofDir) ? readdirSync(proofDir) : [];
const assets = readJson(join(proofDir, 'assets.json')) || {};
const excerpt = (file) =>
  read(join(proofDir, file))
    .trimEnd()
    .split('\n')
    .slice(-EXCERPT_LINES)
    .map((l) => (l.length > LINE_CHARS ? `${l.slice(0, LINE_CHARS)}…` : l))
    .join('\n');
const evidenceFor = (key) =>
  proofFiles
    .filter((f) => f.startsWith(`${key}-`) || f.startsWith(`${key}.`))
    .flatMap((f) => {
      if (/\.(log|txt|out)$/.test(f)) return [{ kind: 'log', label: f, text: excerpt(f) }];
      if (/\.(png|jpe?g|gif|webp)$/.test(f) && assets[f]) return [{ kind: 'image', label: f, url: assets[f] }];
      return [];
    });

const proofs = Object.fromEntries(
  section(status, 'Proofs')
    .map((l) => l.match(/^- (P?\d+): (pass|fail|blocked|skipped|skip)\b\s*[—-]?\s*(.*)$/i))
    .filter(Boolean)
    .map(([, key, result, summary]) => [key.toUpperCase(), { result: result.toLowerCase(), summary, evidence: evidenceFor(key.toUpperCase()) }]),
);

const git = (...a) => {
  try {
    return execFileSync('git', a, { cwd: workDir, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
  } catch {
    return '';
  }
};
const base = git('symbolic-ref', '-q', '--short', 'refs/remotes/origin/HEAD') || 'origin/main';
const commits = git('log', '--format=%h%x09%s', `${base}..HEAD`)
  .split('\n')
  .filter(Boolean)
  .map((l) => l.split('\t'));
const shaFor = (title) => (commits.find(([, subject]) => subject === title || subject.endsWith(`: ${title}`)) || [])[0];

// Ledger columns: date, ticket, subtask, slug, field, from, to, by, reason.
const slug = workDir.split(/[\\/]/).pop();
const ledgerPath = join(workDir, '..', '..', 'ledger', 'tier-overrides.tsv');
const escalations = Object.fromEntries(
  read(ledgerPath)
    .split('\n')
    .slice(1)
    .map((l) => l.split('\t'))
    .filter((c) => c[3] === slug && c[4] === 'tier' && c[7] === 'claude')
    .map((c) => [c[2], { from: c[5], to: c[6], reason: c[8] }]),
);

const subtasks = Object.fromEntries(
  page.subtasks.map((s) => {
    const n = String(s.n);
    const commit = shaInPlan[n]?.slice(0, 7) || shaFor(s.title);
    const statusOf = commit ? 'done' : batch.includes(s.n) ? batchStatus : 'todo';
    return [
      n,
      {
        status: statusOf,
        ...(proofs[n] && { proof: proofs[n] }),
        ...(escalations[n] && { escalated: escalations[n] }),
        ...(commit && { commit }),
      },
    ];
  }),
);
const groups = Object.fromEntries(Object.entries(proofs).filter(([k]) => k.startsWith('P')));

const acs = Object.fromEntries(
  section(plan, 'Acceptance criteria')
    .map((l) => l.match(/^- \[([ xX])\] \*{0,2}(AC\d+)/))
    .filter(Boolean)
    .map(([, mark, id]) => {
      const by = page.subtasks
        .filter((s) => (s.proves || []).includes(id))
        .map((s) => (proofs[String(s.n)] ? String(s.n) : s.proof?.group && proofs[s.proof.group] ? s.proof.group : null))
        .filter(Boolean);
      return [id, { status: mark === ' ' ? 'pending' : 'pass', proof: [...new Set(by)].join(', ') }];
    }),
);

const checkResult = (mark, note) => {
  if (mark !== ' ') return 'pass';
  if (/^fail/i.test(note)) return 'fail';
  if (/^skipped/i.test(note)) return 'skipped';
  return 'pending';
};
const checks = Object.fromEntries(
  section(status, 'Sign-off checks')
    .map((l) => l.match(/^- \[([ xX])\] ([\w-]+)\s*(?:[—-]\s*(.*))?$/))
    .filter(Boolean)
    .map(([, mark, name, note = '']) => [name, { result: checkResult(mark, note), note }]),
);

const perfRows = () => {
  const before = readJson(join(proofDir, 'perf-baseline.json'));
  const after = readJson(join(proofDir, 'perf-after.json'));
  if (!before && !after) return null;
  const key = (r) => `${r.page} · ${r.form || ''}`.trim();
  const index = (d) => Object.fromEntries((d?.results || []).map((r) => [key(r), r]));
  const [b, a] = [index(before), index(after)];
  const rows = [...new Set([...Object.keys(b), ...Object.keys(a)])].flatMap((k) =>
    ['score', 'lcp', 'cls', 'tbt'].map((metric) => ({ page: k, metric, before: b[k]?.[metric], after: a[k]?.[metric] })),
  );
  return { rows, note: after?.note || before?.note || '' };
};

const stage = field('stage') || 'Plan review';
const perf = perfRows();
const progress = {
  stage,
  batch,
  subtasks,
  groups,
  acs,
  ...(field('stop_summary') && { stopSummary: field('stop_summary') }),
  ...((SIGNOFF_STAGES.includes(stage) || Object.values(checks).some((c) => c.result === 'pass')) && {
    signoff: { checks, ...(perf && { perf }) },
  }),
  ...(field('pr_url') && field('pr_url') !== 'null' && { pr: field('pr_url') }),
  updated: new Date().toISOString(),
};

const out = join(workDir, 'progress.json');
writeFileSync(out, `${JSON.stringify(progress, null, 2)}\n`);

if (!args.includes('--changed')) {
  console.log(out);
  process.exit(0);
}
const sentPath = join(workDir, 'progress.sent.json');
const sent = readJson(sentPath) || {};
const patch = Object.fromEntries(
  Object.entries(progress).filter(([k, v]) => k !== 'updated' && JSON.stringify(v) !== JSON.stringify(sent[k])),
);
if (!Object.keys(patch).length) {
  console.log('no change');
  process.exit(0);
}
const patchPath = join(workDir, 'progress.patch.json');
writeFileSync(patchPath, `${JSON.stringify({ ...patch, updated: progress.updated }, null, 2)}\n`);
copyFileSync(out, sentPath);
console.log(patchPath);
