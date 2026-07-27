#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const command = process.argv[2];
if (command !== 'install') {
  console.log('Usage: npx forge-workflow install');
  process.exit(1);
}

const sourceDir = path.join(__dirname, '..');
const pkg = require(path.join(sourceDir, 'package.json'));
const targetDir = path.join(process.cwd(), '.claude');
const forgeDir = path.join(targetDir, '.forge');

// Source vs output:
//   .claude/.forge/**            the pristine template set (SOURCE) — gitignored, inert
//   .claude/commands|agents|...  your tailored, committed workflow (OUTPUT), written by /install
//
// This installer only STAGES the templates and drops the single live bootstrap
// command (/install). Running /install in Claude Code reads .claude/.forge/ and
// generates your tailored workflow into .claude/. Keeping source and output
// separate makes re-runs and upgrades non-destructive.
const dirs = ['commands', 'agents', 'skills', 'docs', 'examples'];
const SKIP = new Set(['.DS_Store', '.git']);

let copied = 0;

function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    if (SKIP.has(entry.name)) continue;
    const s = path.join(src, entry.name);
    const d = path.join(dest, entry.name);
    if (entry.isDirectory()) copyDir(s, d);
    else {
      fs.copyFileSync(s, d);
      copied++;
    }
  }
}

// 1. Stage the full template set under .claude/.forge/
fs.mkdirSync(forgeDir, { recursive: true });
for (const dir of dirs) {
  const src = path.join(sourceDir, dir);
  if (fs.existsSync(src)) copyDir(src, path.join(forgeDir, dir));
}

// 2. Stamp the staged version — /install reads this to detect upgrades.
fs.writeFileSync(path.join(forgeDir, 'VERSION'), `${pkg.version}\n`);

// 3. Copy the single live bootstrap command so /install is runnable.
const commandsDir = path.join(targetDir, 'commands');
fs.mkdirSync(commandsDir, { recursive: true });
fs.copyFileSync(path.join(sourceDir, 'commands', 'install.md'), path.join(commandsDir, 'install.md'));

console.log(`\n✓ Staged ${copied} forge-workflow template files in .claude/.forge/ (v${pkg.version})`);
console.log('✓ Installed the /install command.');
console.log('\nNext: open Claude Code and run /install to generate your tailored workflow.');
console.log("Tip: add '.claude/.forge/' to your .gitignore — it's a regenerable template cache.\n");
