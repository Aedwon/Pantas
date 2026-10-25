import {existsSync, lstatSync, readdirSync, readFileSync} from 'node:fs';
import {join} from 'node:path';

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
    const figure = /^(\d{2,})-[a-z0-9-]+\.(svg|png)$/.exec(name);
    if (!figure) continue;
    const seq = Number(figure[1]); const type = figure[2];
    const file = join(dir, name);
    if (seq < 1 || lstatSync(file).isSymbolicLink() || !lstatSync(file).isFile()) throw new Error(`Invalid illustration: ${file}`);
    const key = `${seq}/${type}`;
    if (seen.has(key)) throw new Error(`Duplicate illustration sequence: ${file}`);
    seen.add(key);
    if (!entries.has(seq) || type === 'svg') entries.set(seq, {file, type, seq, alt: entries.get(seq)?.alt, credit: entries.get(seq)?.credit});
  }
  if (entries.size === 0) return body;
  const ordered = [...entries.values()].sort((a, b) => a.seq - b.seq);
  let index = 0;
  return body.replace(/<!--\s*ILLUSTRATION:\s*([\s\S]*?)\s*-->/g, (_, alt) => {
    const figure = ordered[index++];
    if (!figure) throw new Error(`Missing illustration slot ${index}: ${lessonPath}`);
    const mime = figure.type === 'svg' ? 'image/svg+xml' : 'image/png';
    const url = figure.url ?? `data:${mime};base64,${readFileSync(figure.file).toString('base64')}`;
    const key = `${match.slice(1).join('/')}#${figure.seq}`;
    return `<!-- IMAGE: ${JSON.stringify({asset: {url, credit: figure.credit ?? credits[key] ?? 'Pantas'}, alt: figure.alt || alt.trim()})} -->`;
  });
}
