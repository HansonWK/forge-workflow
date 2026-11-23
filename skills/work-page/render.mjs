#!/usr/bin/env node
// node render.mjs <work folder> [--out <file>]
// Reads <work folder>/work-page.json, checks it against plan.md, and writes <work folder>/work-page.html
// from template.html with the house style from ../presentation/house-style.css.
import { execFileSync } from 'node:child_process';
import { existsSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const BANNED_IN_TITLE = /['"`$!\\]/;
const TIERS = ['low', 'medium', 'high'];
const MODES = ['choose', 'confirm', 'discuss'];

const fail = (message) => {
  console.error(`work-page: ${message}`);
  process.exit(1);
};

const validate = (page) => {
  const groupIds = (page.proofGroups || []).map((g) => g.id);
  const problems = [
    !page.name && 'name is missing',
    !page.problem && 'problem is missing',
    !Array.isArray(page.acs) && 'acs must be an array',
    !Array.isArray(page.subtasks) && 'subtasks must be an array',
    ...(page.acs || []).filter((a) => !/^AC\d+$/.test(a.id || '')).map((a) => `ac ${a.id}: id must be AC<n>`),
    ...(page.subtasks || []).flatMap((s) => [
      !Number.isInteger(s.n) && `subtask ${s.title}: n must be an integer`,
      !TIERS.includes(s.tier) && `subtask ${s.n}: tier must be one of ${TIERS.join(', ')}`,
      !s.tierWhy && `subtask ${s.n}: tierWhy is missing`,
      BANNED_IN_TITLE.test(s.title || '') && `subtask ${s.n}: title contains a quote mark, backtick, $, ! or \\`,
      !s.proof && `subtask ${s.n}: proof is missing (use {"group": "P1"} or {"none": "<reason>"})`,
      s.proof?.group && !groupIds.includes(s.proof.group) && `subtask ${s.n}: proof group ${s.proof.group} is not in proofGroups`,
      ...(s.questions || []).filter((q) => !MODES.includes(q.mode)).map((q) => `subtask ${s.n} ${q.id}: mode must be ${MODES.join(', ')}`),
    ]),
    ...(page.proofGroups || []).flatMap((g) => [
      !/^P\d+$/.test(g.id || '') && `proof group ${g.id}: id must be P<n>`,
      !(g.subtasks || []).length && `proof group ${g.id}: subtasks is empty`,
      !g.proof && `proof group ${g.id}: proof is missing`,
    ]),
    ...(page.devTests || []).filter((t) => !t.id || !t.step).map((t) => `devTests ${t.id}: id and step are required`),
  ].filter(Boolean);
  if (problems.length) fail(`work-page.json is not valid:\n- ${problems.join('\n- ')}`);
};

const openQuestionCount = (planMd, n) => {
  const start = planMd.search(new RegExp(`^### ${n}\\. `, 'm'));
  if (start < 0) return null;
  const rest = planMd.slice(start + 4);
  const end = rest.search(/^#{2,3} /m);
  const section = end < 0 ? rest : rest.slice(0, end);
  const marker = section.indexOf('**Open questions:**');
  if (marker < 0) return 0;
  return (section.slice(marker).match(/^\d+\. \*\*/gm) || []).length;
};

// The test-plan skill, once the project has it, renders the Test-on-dev tab: renderCases(data) returns
// the tab's HTML and pageScript is the script that keeps it live.
const testPlanTab = async (here, workDir) => {
  const plugin = join(here, '..', 'test-plan', 'render.mjs');
  const root = join(workDir, 'test-plan');
  if (!existsSync(plugin) || !existsSync(root)) return null;
  const { renderCases, pageScript } = await import(pathToFileURL(plugin).href);
  const envs = readdirSync(root).filter((env) => existsSync(join(root, env, 'test-plan.json')));
  if (!envs.length) return null;
  const ordered = [...envs.filter((env) => env !== 'dev'), ...envs.filter((env) => env === 'dev')];
  const html = ordered
    .map((env) => {
      const data = JSON.parse(readFileSync(join(root, env, 'test-plan.json'), 'utf8'));
      return `<div class="test-env" data-env="${env.replace(/[^\w-]/g, '')}">${renderCases(data)}</div>`;
    })
    .join('\n');
  return { html, script: `<script>\n${pageScript}\n</script>` };
};

// A script with a syntax error silently stops every live update, so check each one before publishing.
const checkScripts = (html) => {
  const scripts = [...html.matchAll(/<script(?![^>]*type="application\/json")[^>]*>([\s\S]*?)<\/script>/g)].map((m) => m[1]);
  const dir = mkdtempSync(join(tmpdir(), 'work-page-'));
  try {
    scripts.forEach((code, i) => {
      const file = join(dir, `script-${i}.js`);
      writeFileSync(file, code);
      try {
        execFileSync(process.execPath, ['--check', file], { stdio: 'pipe' });
      } catch (e) {
        fail(`script ${i + 1} in the page does not parse, so the page would never update:\n${e.stderr}`);
      }
    });
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
};

const args = process.argv.slice(2);
const workDirArg = args.find((a) => !a.startsWith('--'));
if (!workDirArg) fail('usage: node render.mjs <work folder> [--out <file>]');
const outArg = args.includes('--out') ? args[args.indexOf('--out') + 1] : null;

const workDir = resolve(workDirArg);
const here = dirname(fileURLToPath(import.meta.url));
const dataPath = join(workDir, 'work-page.json');
if (!existsSync(dataPath)) fail(`no work-page.json in ${workDir}`);
const page = JSON.parse(readFileSync(dataPath, 'utf8'));
validate(page);

const planPath = join(workDir, 'plan.md');
if (existsSync(planPath)) {
  const planMd = readFileSync(planPath, 'utf8');
  const mismatches = page.subtasks
    .map((s) => ({ n: s.n, plan: openQuestionCount(planMd, s.n), page: (s.questions || []).length }))
    .filter((m) => m.plan !== null && m.plan !== m.page)
    .map((m) => `subtask ${m.n}: plan.md has ${m.plan} open questions, work-page.json has ${m.page}`);
  if (mismatches.length) fail(`open questions do not match plan.md:\n- ${mismatches.join('\n- ')}`);
}

const stylePath = join(here, '..', 'presentation', 'house-style.css');
if (!existsSync(stylePath)) fail(`no house style at ${stylePath}`);

const progressPath = join(workDir, 'progress.json');
if (existsSync(progressPath)) page.seedProgress = JSON.parse(readFileSync(progressPath, 'utf8'));

const devTab = await testPlanTab(here, workDir);
page.testPlanTab = !!devTab;

const title = `${page.ticket ? `${page.ticket} ` : ''}${page.shortName || page.name}`.replace(/[<>&]/g, '');
// JSON inside a <script> ends at the first "</", so escape every "<".
const json = JSON.stringify(page).replace(/</g, '\\u003c');

const html = readFileSync(join(here, 'template.html'), 'utf8')
  .replace('/* @house-style */', () => readFileSync(stylePath, 'utf8'))
  .replace('{{TITLE}}', () => title)
  .replace('{{PAGE_JSON}}', () => json)
  .replace('{{DEV_TAB_HTML}}', () => devTab?.html || '')
  .replace('{{DEV_TAB_SCRIPT}}', () => devTab?.script || '');

checkScripts(html);
const out = outArg ? resolve(outArg) : join(workDir, 'work-page.html');
writeFileSync(out, html);
console.log(out);
