#!/usr/bin/env node
// Uploads lessons and question sets to server-only Firestore documents (plan task C7).
//   content/{kind}/items/{id}   free fields plus a version
//   contentPro/{id}             wrong-choice notes (Pro only)
//   content/catalog/items/{id}  the catalog (structure and ids, no text); format in web/README.md
// Usage: node upload_content.mjs [--root content] [--dry-run] [--live] [--project ID] [--skip-invalid]
//                                [--export FILE] [--out-dir DIR]
// The catalog needs the exam, subject, topic and blueprint rows the bundled build produces. Pass
// --export FILE (the output of tools/build_content_export) or the tool runs that build itself with `dart`.
// --out-dir DIR writes every document to files and touches no database.
// Without FIRESTORE_EMULATOR_HOST the tool refuses to write unless --live is given.
// Build the functions first (npm --prefix functions run build): this reads functions/lib.
import {existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, statSync, writeFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {tmpdir} from 'node:os';
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
const outDir = option('--out-dir', undefined);

function walk(dir, ext) {
  let out = [];
  for (const name of readdirSync(dir).sort()) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) out = out.concat(walk(path, ext));
    else if (name.endsWith(ext)) out.push(path);
  }
  return out;
}

if (!process.env.FIRESTORE_EMULATOR_HOST && !live && !dryRun && !outDir) {
  console.error('No emulator is set (FIRESTORE_EMULATOR_HOST). Pass --live to write to a real project.');
  process.exit(2);
}

const {blueprintItem, catalogItems, lessonItem, questionSetItems, writeContent} = await import(pathToFileURL(join(functionsDir, 'lib/contentUpload.js')));
const items = [];
const pros = [];
const invalid = [];
const lessonFronts = [];
const setSources = [];

for (const file of walk(join(root, 'lessons'), '.md')) {
  try {
    const text = readFileSync(file, 'utf8');
    const match = /^---\n([\s\S]*?)\n---\n?([\s\S]*)$/.exec(text);
    if (!match) throw new Error('no frontmatter');
    const front = parse(match[1]);
    items.push(lessonItem(front, match[2]));
    lessonFronts.push(front);
  } catch (error) { invalid.push(`${relative(root, file)}: ${error.message.split('\n')[0]}`); }
}
const questionsRoot = join(root, 'questions');
for (const file of walk(questionsRoot, '.yaml')) {
  try {
    const doc = parse(readFileSync(file, 'utf8'));
    if (!doc?.meta || !Array.isArray(doc.questions)) throw new Error('needs meta and questions');
    const {item, pro} = questionSetItems(doc, relative(questionsRoot, file));
    items.push(item);
    setSources.push({source: doc, relativePath: relative(questionsRoot, file)});
    if (pro) pros.push(pro);
  } catch (error) { invalid.push(`${relative(root, file)}: ${error.message.split('\n')[0]}`); }
}

const mockRoot = join(root, 'mock');
for (const file of existsSync(mockRoot) ? walk(mockRoot, '.yaml') : []) {
  try { items.push(blueprintItem(parse(readFileSync(file, 'utf8')))); }
  catch (error) { invalid.push(`${relative(root, file)}: ${error.message.split('\n')[0]}`); }
}

function loadStructure() {
  let file = option('--export', undefined);
  // A plain dry run only reads the sources; building the export needs dart and takes a while.
  if (!file && dryRun && !outDir) { console.log('catalog: skipped (pass --export FILE to include it in a dry run)'); return null; }
  if (!file) {
    file = join(mkdtempSync(join(tmpdir(), 'content-export-')), 'export.json');
    const built = spawnSync('dart', ['run', join(here, '../build_content_export/build_content_export.dart'), file, resolve(root, '..')], {encoding: 'utf8'});
    if (built.status !== 0) {
      console.error(`The catalog needs the content export. Pass --export FILE, or install dart. ${built.stderr || built.error || ''}`);
      process.exit(1);
    }
  }
  const exported = JSON.parse(readFileSync(file, 'utf8'));
  return {exam: exported.exam, subject: exported.subject, topic: exported.topic,
    mockBlueprint: exported.mockBlueprint, diagnosticSet: exported.diagnosticSet};
}
const structure = invalid.length > 0 && !skipInvalid ? null : loadStructure();
const catalog = structure ? catalogItems({structure, lessons: lessonFronts, sets: setSources}) : [];
items.push(...catalog);

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
console.log(`catalog documents: ${catalog.length}`);
console.log(`pro documents: ${pros.length}`);

if (outDir) {
  // Each file holds the `data` getContent serves for that id to a Free account.
  for (const item of items.filter(i => i.kind === 'catalog' || i.kind === 'questions' || i.kind === 'lessons')) {
    const dir = join(resolve(outDir), item.kind);
    mkdirSync(dir, {recursive: true});
    const {kind: _kind, version: _version, payload, count: _count, ...fields} = item.data;
    const served = payload === undefined ? fields : item.kind === 'catalog' ? JSON.parse(payload) : {id: item.id, ...JSON.parse(payload)};
    writeFileSync(join(dir, `${item.id}.json`), JSON.stringify(served));
  }
  console.log(`wrote documents to ${resolve(outDir)}`);
  process.exit(0);
}

if (dryRun && !process.env.FIRESTORE_EMULATOR_HOST) {
  console.log('dry run: no database was read or written');
  process.exit(0);
}
const {initializeApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
initializeApp({projectId: option('--project', process.env.GCLOUD_PROJECT ?? 'demo-pantas-test')});
const result = await writeContent(getFirestore(), items, pros, {dryRun});
console.log(`${dryRun ? 'dry run: would write' : 'wrote'} ${JSON.stringify(result.counts)}, pro documents changed: ${result.proWritten}`);
