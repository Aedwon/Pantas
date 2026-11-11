// Hash of every Dart source file the server entry imports (directly or not).
// build.sh writes it into the generated JS; a plain Node test recomputes it to
// fail when a source changed and the JS was not rebuilt. Needs no Dart SDK.
import {createHash} from 'node:crypto';
import {existsSync, readFileSync} from 'node:fs';
import {dirname, join, relative, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
export const repoRoot = resolve(here, '..');
const directive = /^\s*(?:import|export|part)\s+'([^']+)'/gm;

export function closureFiles(entry = join(here, 'pantas_core.dart')) {
  const seen = new Set();
  const visit = file => {
    if (seen.has(file)) return;
    seen.add(file);
    for (const [, target] of readFileSync(file, 'utf8').matchAll(directive)) {
      let next;
      if (target.startsWith('package:pantas/')) next = join(repoRoot, 'lib', target.slice('package:pantas/'.length));
      else if (!target.includes(':')) next = resolve(dirname(file), target);
      // Generated parts (.freezed.dart, .g.dart) are not sources; their input is hashed.
      if (next && !/\.(freezed|g)\.dart$/.test(next) && existsSync(next)) visit(next);
    }
  };
  visit(entry);
  return [...seen].sort();
}

export function closureHash(entry) {
  const hash = createHash('sha256');
  for (const file of closureFiles(entry)) {
    hash.update(`${relative(repoRoot, file)}\0`);
    hash.update(readFileSync(file));
    hash.update('\0');
  }
  return hash.digest('hex');
}

if (process.argv[1] === fileURLToPath(import.meta.url)) console.log(closureHash());

/** True when the generated JS carries a source hash that differs from the current Dart sources. */
export function isStale(generatedText, entry) {
  const match = /^\/\/ pantas-core-source-hash: ([0-9a-f]{64})$/m.exec(generatedText);
  return !match || match[1] !== closureHash(entry);
}
