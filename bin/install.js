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

const dirs = ['commands', 'agents', 'docs'];

// Create .claude directory if needed
if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

let copied = 0;
for (const dir of dirs) {
  const src = path.join(sourceDir, dir);
  const dest = path.join(targetDir, dir);
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }
  const files = fs.readdirSync(src);
  for (const file of files) {
    fs.copyFileSync(path.join(src, file), path.join(dest, file));
    copied++;
  }
}

console.log(`\n✓ Copied ${copied} forge-workflow files to .claude/`);
console.log('\nNext step: Open Claude Code and run /install to configure the workflow for your project.\n');
