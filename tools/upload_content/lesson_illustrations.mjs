import {existsSync, lstatSync, readdirSync, readFileSync} from 'node:fs';
import {join, relative} from 'node:path';

// The path rule for a local lesson figure, relative to the illustrations folder.
// The Dart seed applies the same rule.
const FIGURE_EXTENSION = /\.(svg|png|jpe?g|gif|webp)$/i;
const FIGURE_PATH = /^([a-z0-9-]+)\/([a-z0-9-]+)\/([a-z0-9-]+)\/(\d{2,})-[a-z0-9-]+\.(svg|png)$/;
const FIGURE_NAME = /^(\d{2,})-[a-z0-9-]+\.(svg|png)$/;
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
  const entries = new Map();
  for (const [key, asset] of Object.entries(map)) {
    if (!key.startsWith(prefix) || !/^[1-9][0-9]*$/.test(key.slice(prefix.length))) continue;
    const seq = Number(key.slice(prefix.length));
    if (typeof asset.url === 'string' && asset.url) entries.set(seq, {
      seq, url: asset.url, alt: asset.alt,
      credit: credits[asset.creditKey],
    });
  }
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
    if (!entries.has(seq) || type === 'svg') entries.set(seq, {file, type, seq, alt: entries.get(seq)?.alt, credit: entries.get(seq)?.credit});
  }
  if (entries.size === 0) return body;
  const ordered = [...entries.values()].sort((a, b) => a.seq - b.seq);
  let index = 0;
  const resolved = body.replace(/<!--\s*ILLUSTRATION:\s*([\s\S]*?)\s*-->/g, (_, alt) => {
    const figure = ordered[index++];
    if (!figure) throw new Error(`Missing illustration slot ${index}: ${lessonPath}`);
    const mime = figure.type === 'svg' ? 'image/svg+xml' : 'image/png';
    const url = figure.url ?? `data:${mime};base64,${readFileSync(figure.file).toString('base64')}`;
    const key = `${match.slice(1).join('/')}#${figure.seq}`;
    return `<!-- IMAGE: ${JSON.stringify({asset: {url, credit: figure.credit ?? credits[key] ?? 'Pantas'}, alt: figure.alt || alt.trim()})} -->`;
  });
  // A figure file that no marker consumed would otherwise be dropped silently.
  const unused = ordered.slice(index).filter(figure => figure.file);
  if (unused.length > 0) {
    throw new Error(`Figure file has no ILLUSTRATION marker to use it in ${lessonPath}: ${unused.map(figure => figure.file).join(', ')}`);
  }
  return resolved;
}
