import {existsSync, lstatSync, readdirSync, readFileSync} from 'node:fs';
import {join, relative} from 'node:path';

// The path rule for a local lesson figure, relative to the illustrations folder.
// The Dart seed applies the same rule.
const FIGURE_EXTENSION = /\.(svg|png|jpe?g|gif|webp)$/i;
const FIGURE_PATH = /^([a-z0-9-]+)\/([a-z0-9-]+)\/([a-z0-9-]+)\/(\d{2,})-[a-z0-9-]+\.(svg|png)$/;
const FIGURE_NAME = /^(\d{2,})-[a-z0-9-]+\.(svg|png)$/;
// The most bytes a lesson may take once its figures are embedded: the lesson text with
// each marker replaced by its IMAGE marker. The Dart seed counts the same way and
// drops the figure that would pass it.
export const MAX_RESOLVED_LESSON_BYTES = 900_000;
// The credit of a new original SVG drawing.
const PANTAS_CREDIT = 'Pantas';
export function assertResolvedLessonSize(body, lessonPath = '') {
  if (Buffer.byteLength(body, 'utf8') > MAX_RESOLVED_LESSON_BYTES) {
    throw new Error(`resolved lesson exceeds safe Firestore document size (${MAX_RESOLVED_LESSON_BYTES} bytes)${lessonPath ? `: ${lessonPath}` : ''}`);
  }
}
export const FIGURE_PATH_RULE = '<subject>/<topic>/<lesson>/NN-slug.svg or .png '
  + '(lowercase letters, digits and hyphens; NN is two or more digits, 01 or more)';

// Every figure-like file under the illustrations folder, with the lesson it
// would belong to. Returns the problems found instead of throwing, so the
// upload can list them all.
export function checkIllustrationFiles(root, lessonKeys) {
  const problems = [];
  const visit = dir => {
    for (const name of readdirSync(dir).sort()) {
      const path = join(dir, name);
      const info = lstatSync(path);
      if (info.isDirectory()) { visit(path); continue; }
      if (!FIGURE_EXTENSION.test(name)) continue;
      const relativePath = relative(root, path).split('\\').join('/');
      const match = FIGURE_PATH.exec(relativePath);
      if (!match) problems.push(`${path}: file name does not match ${FIGURE_PATH_RULE}`);
      else if (Number(match[4]) < 1) problems.push(`${path}: sequence must be 1 or more, as in ${FIGURE_PATH_RULE}`);
      else if (info.isSymbolicLink()) problems.push(`${path}: symbolic links are not allowed`);
      else if (!lessonKeys.has(match.slice(1, 4).join('/'))) problems.push(`${path}: no lesson file ${match.slice(1, 4).join('/')}.md uses this figure`);
    }
  };
  if (existsSync(root)) visit(root);
  return problems;
}

// Keep illustration bytes in the same server content response and client cache as
// the lesson. No second host, URL lifetime, or unauthenticated asset fetch is needed.
export function resolveLessonIllustrations(body, lessonPath, root, credits = {}) {
  const match = /^([a-z0-9-]+)\/([a-z0-9-]+)\/([a-z0-9-]+)\.md$/.exec(lessonPath);
  if (!match) throw new Error(`Invalid lesson illustration path: ${lessonPath}`);
  let dir = root;
  for (const part of ['', ...match.slice(1)]) {
    dir = join(dir, part);
    if (existsSync(dir) && lstatSync(dir).isSymbolicLink()) throw new Error(`Unsafe illustration path: ${dir}`);
  }
  const prefix = `${match.slice(1).join('/')}#`;
  const mapFile = join(root, 'assets.json');
  if (existsSync(mapFile) && lstatSync(mapFile).isSymbolicLink()) throw new Error(`Unsafe asset map path: ${mapFile}`);
  const map = existsSync(mapFile) ? JSON.parse(readFileSync(mapFile, 'utf8')) : {};
  // The asset map's entries (existing remote figures) and the credit key each one names.
  const remote = new Map();
  for (const [key, asset] of Object.entries(map)) {
    if (!key.startsWith(prefix) || !/^[1-9][0-9]*$/.test(key.slice(prefix.length))) continue;
    const seq = Number(key.slice(prefix.length));
    if (typeof asset.url === 'string' && asset.url) remote.set(seq, {seq, url: asset.url, alt: asset.alt, creditKey: asset.creditKey});
  }
  const found = new Map();
  const seen = new Set();
  for (const name of existsSync(dir) ? readdirSync(dir).sort() : []) {
    if (!FIGURE_EXTENSION.test(name)) continue;
    const file = join(dir, name);
    const figure = FIGURE_NAME.exec(name);
    if (!figure) throw new Error(`Illustration file name does not match ${FIGURE_PATH_RULE}: ${file}`);
    const seq = Number(figure[1]); const type = figure[2];
    if (seq < 1) throw new Error(`Illustration sequence must be 1 or more, as in ${FIGURE_PATH_RULE}: ${file}`);
    if (lstatSync(file).isSymbolicLink() || !lstatSync(file).isFile()) throw new Error(`Invalid illustration: ${file}`);
    const key = `${seq}/${type}`;
    if (seen.has(key)) throw new Error(`Duplicate illustration sequence: ${file}`);
    seen.add(key);
    // An SVG replaces the old PNG for the same marker slot.
    if (!found.has(seq) || type === 'svg') found.set(seq, {file, type});
  }
  const slotKey = seq => `${match.slice(1).join('/')}#${seq}`;
  const entries = new Map(remote);
  for (const [seq, {file, type}] of found) {
    const existing = remote.get(seq);
    if (existing && type !== 'svg') continue;
    const creditKey = existing?.creditKey ?? slotKey(seq);
    let credit = credits[creditKey];
    // The only figure without a credit entry is a new original SVG, which
    // docs/content/lesson-svg-authoring.md defines as made by Pantas. Any other
    // figure with no credit is an error, never a default. The seed applies the same rule.
    if (credit === undefined) {
      if (existing || type !== 'svg') throw new Error(`No credit for figure file ${file}: add "${creditKey}" with a credit to content/illustrations/sources/*.yaml`);
      credit = PANTAS_CREDIT;
    }
    entries.set(seq, {file, type, seq, alt: existing?.alt, credit});
  }
  if (entries.size === 0) return body;
  const ordered = [...entries.values()].sort((a, b) => a.seq - b.seq);
  let index = 0;
  const resolved = body.replace(/<!--\s*ILLUSTRATION:\s*([\s\S]*?)\s*-->/g, (_, alt) => {
    const figure = ordered[index++];
    if (!figure) throw new Error(`Missing illustration slot ${index}: ${lessonPath}`);
    const credit = figure.file ? figure.credit : credits[figure.creditKey];
    if (credit === undefined) throw new Error(`No credit for figure ${slotKey(figure.seq)} in ${lessonPath}: add "${figure.creditKey}" with a credit to content/illustrations/sources/*.yaml`);
    const mime = figure.type === 'svg' ? 'image/svg+xml' : 'image/png';
    const url = figure.url ?? `data:${mime};base64,${readFileSync(figure.file).toString('base64')}`;
    return `<!-- IMAGE: ${JSON.stringify({asset: {url, credit}, alt: figure.alt || alt.trim()})} -->`;
  });
  // A figure file that no marker consumed would otherwise be dropped silently.
  const unused = ordered.slice(index).filter(figure => figure.file);
  if (unused.length > 0) {
    throw new Error(`Figure file has no ILLUSTRATION marker to use it in ${lessonPath}: ${unused.map(figure => figure.file).join(', ')}`);
  }
  assertResolvedLessonSize(resolved, lessonPath);
  return resolved;
}
