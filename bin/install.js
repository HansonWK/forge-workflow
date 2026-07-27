#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const command = process.argv[2];
if (command !== 'install') {
  console.log('Usage: npx forge-workflow install');
  process.exit(1);
}

const sourceDir = path.join(__dirname, '..');
const targetDir = path.join(process.cwd(), '.claude');

// Directories shipped into the user's .claude/.
// - commands/agents/docs are the active, templated workflow files
// - examples are reference implementations the /install command reads (and that
//   generalized commands cite at runtime); they are NOT registered as commands
const dirs = ['commands', 'agents', 'skills', 'docs', 'examples'];

const SKIP = new Set(['.DS_Store', '.git']);

let copied = 0;

// Recursively copy a directory, preserving subdirectories (examples/ and docs/
// both have nested folders). Existing files are overwritten so re-installs pick
// up shipped updates; /install then re-templates them in place.
function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    if (SKIP.has(entry.name)) continue;
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDir(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
      copied++;
    }
  }
}

if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

for (const dir of dirs) {
  const src = path.join(sourceDir, dir);
  if (!fs.existsSync(src)) continue;
  copyDir(src, path.join(targetDir, dir));
}

console.log(`\n✓ Copied ${copied} forge-workflow files to .claude/`);
console.log('\nNext step: Open Claude Code and run /install to configure the workflow for your project.\n');
