#!/usr/bin/env node
// Scaffold a deck or page from its shell, or export one as a standalone HTML file.
//   node build.mjs new deck|page <out.html> "<title>"
//   node build.mjs export <source.html>   ->  <source>.export.html
// The house stylesheet is the one .css file beside this script; each shell marks where it goes with
// /* @<stylesheet name> */, for example /* @house-style */ for house-style.css.
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, dirname, extname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ASSETS = dirname(fileURLToPath(import.meta.url));
const USAGE = 'usage: node build.mjs new deck|page <out.html> "<title>"  |  node build.mjs export <source.html>';

const fail = (message) => {
  console.error(message);
  process.exit(1);
};
const escapeHtml = (text) => text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const stylesheet = () => {
  const sheets = readdirSync(ASSETS).filter((f) => f.endsWith('.css'));
  if (sheets.length !== 1) fail(`expected one .css file in ${ASSETS}, found ${sheets.length}`);
  return { css: readFileSync(join(ASSETS, sheets[0]), 'utf8'), marker: `/* @${basename(sheets[0], '.css')} */` };
};

const scaffold = (kind, out, title) => {
  if (!['deck', 'page'].includes(kind)) fail('kind must be deck or page');
  const target = resolve(out);
  if (existsSync(target)) fail(`${target} already exists; edit it instead`);
  const shell = readFileSync(join(ASSETS, `${kind}.html`), 'utf8');
  const { css, marker } = stylesheet();
  if (!shell.includes(marker)) fail(`${kind}.html is missing the ${marker} marker`);
  mkdirSync(dirname(target), { recursive: true });
  writeFileSync(target, shell.replace(marker, () => css).replaceAll('{{TITLE}}', () => escapeHtml(title)));
  return target;
};

const exportFile = (source) => {
  const src = resolve(source);
  const html = readFileSync(src, 'utf8');
  const split = html.indexOf('</style>');
  if (split < 0) fail('no </style> found; the head must end with the page stylesheet');
  const head = html.slice(0, split + '</style>'.length).trim();
  const body = html.slice(split + '</style>'.length).trim();
  const target = join(dirname(src), `${basename(src, extname(src))}.export.html`);
  writeFileSync(
    target,
    [
      '<!doctype html>',
      '<html lang="en-GB">',
      '<head>',
      '<meta charset="utf-8" />',
      '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />',
      head,
      '</head>',
      '<body>',
      body,
      '</body>',
      '</html>',
      '',
    ].join('\n'),
  );
  return target;
};

const [command, ...rest] = process.argv.slice(2);
if (command === 'new' && rest.length === 3) console.log(scaffold(...rest));
else if (command === 'export' && rest.length === 1) console.log(exportFile(rest[0]));
else fail(USAGE);
