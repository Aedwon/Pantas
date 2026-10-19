#!/usr/bin/env node
// Uploads lessons and question sets to server-only Firestore documents (plan task C7).
//   content/{kind}/items/{id}   free fields plus a version
//   contentPro/{id}             wrong-choice notes (Pro only)
// Usage: node upload_content.mjs [--root content] [--dry-run] [--live] [--project ID] [--skip-invalid]
// Without FIRESTORE_EMULATOR_HOST the tool refuses to write unless --live is given.
// Build the functions first (npm --prefix functions run build): this reads functions/lib.
import {existsSync, readdirSync, readFileSync, statSync} from 'node:fs';
import {createRequire} from 'node:module';
import {dirname, join, relative, resolve} from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const functionsDir = resolve(here, '../../functions');
const require = createRequire(join(functionsDir, 'package.json'));
const {parse} = require('yaml');

const args = process.argv.slice(2);
const flag = name => args.includes(name);
const option = (name, fallback) => { const i = args.indexOf(name); return i >= 0 ? args[i + 1] : fallback; };
const root = resolve(option('--root', resolve(here, '../../content')));
const dryRun = flag('--dry-run');
const live = flag('--live');
const skipInvalid = flag('--skip-invalid');

function walk(dir, ext) {
  let out = [];
  for (const name of readdirSync(dir).sort()) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) out = out.concat(walk(path, ext));
    else if (name.endsWith(ext)) out.push(path);
  }
  return out;
}

if (!process.env.FIRESTORE_EMULATOR_HOST && !live && !dryRun) {
  console.error('No emulator is set (FIRESTORE_EMULATOR_HOST). Pass --live to write to a real project.');
  process.exit(2);
}

const {blueprintItem, lessonItem, questionSetItems, writeContent} = await import(pathToFileURL(join(functionsDir, 'lib/contentUpload.js')));
const items = [];
const pros = [];
const invalid = [];

for (const file of walk(join(root, 'lessons'), '.md')) {
  try {
    const text = readFileSync(file, 'utf8');
    const match = /^---\n([\s\S]*?)\n---\n?([\s\S]*)$/.exec(text);
    if (!match) throw new Error('no frontmatter');
    items.push(lessonItem(parse(match[1]), match[2]));
  } catch (error) { invalid.push(`${relative(root, file)}: ${error.message.split('\n')[0]}`); }
}
const questionsRoot = join(root, 'questions');
for (const file of walk(questionsRoot, '.yaml')) {
  try {
    const doc = parse(readFileSync(file, 'utf8'));
    if (!doc?.meta || !Array.isArray(doc.questions)) throw new Error('needs meta and questions');
    const {item, pro} = questionSetItems(doc, relative(questionsRoot, file));
    items.push(item);
    if (pro) pros.push(pro);
  } catch (error) { invalid.push(`${relative(root, file)}: ${error.message.split('\n')[0]}`); }
}

const mockRoot = join(root, 'mock');
for (const file of existsSync(mockRoot) ? walk(mockRoot, '.yaml') : []) {
  try { items.push(blueprintItem(parse(readFileSync(file, 'utf8')))); }
  catch (error) { invalid.push(`${relative(root, file)}: ${error.message.split('\n')[0]}`); }
}

const ids = new Set();
for (const item of items) {
  const key = `${item.kind}/${item.id}`;
  if (ids.has(key)) invalid.push(`duplicate id ${key}`);
  ids.add(key);
}
if (invalid.length > 0) {
  console.error(`Invalid sources (${invalid.length}):\n${invalid.join('\n')}`);
  if (!skipInvalid) { console.error('Nothing written. Fix the sources or pass --skip-invalid.'); process.exit(1); }
}

console.log(`lessons: ${items.filter(i => i.kind === 'lessons').length}`);
console.log(`question sets: ${items.filter(i => i.kind === 'questions').length}`);
console.log(`mock blueprints: ${items.filter(i => i.kind === 'mocks').length}`);
console.log(`pro documents: ${pros.length}`);

if (dryRun && !process.env.FIRESTORE_EMULATOR_HOST) {
  console.log('dry run: no database was read or written');
  process.exit(0);
}
const {initializeApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
initializeApp({projectId: option('--project', process.env.GCLOUD_PROJECT ?? 'demo-pantas-test')});
const result = await writeContent(getFirestore(), items, pros, {dryRun});
console.log(`${dryRun ? 'dry run: would write' : 'wrote'} ${JSON.stringify(result.counts)}, pro documents changed: ${result.proWritten}`);
