// Run after `flutter build web`. Flutter's service worker version does not
// change when only Dart code changes, so pantas_sw.js kept serving the old
// main.dart.js from its cache after such a deploy. This appends a hash of every
// built file to the version in flutter_bootstrap.js, so each build gets its own
// worker and cache.
//
// Usage: node tool/web/stamp_worker_version.mjs [build/web]
import {createHash} from 'node:crypto';
import {existsSync, readdirSync, readFileSync, statSync, writeFileSync} from 'node:fs';
import {join, relative} from 'node:path';

const BOOTSTRAP = 'flutter_bootstrap.js';
const TOKEN = /registerWorker\("([^"]*)"/;

function files(dir, root = dir) {
  return readdirSync(dir).filter(name => !name.startsWith('.')).sort().flatMap(name => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? files(path, root) : [relative(root, path)];
  });
}

export function buildHash(dir) {
  const hash = createHash('sha256');
  for (const name of files(dir)) {
    if (name === BOOTSTRAP) continue;
    const bytes = name === 'version.json'
      ? JSON.stringify((({pantasBuildVersion, ...rest}) => rest)(JSON.parse(readFileSync(join(dir, name), 'utf8'))))
      : name === 'pantas_sw.js'
        ? readFileSync(join(dir, name), 'utf8')
          .replace(/const STAMPED_VERSION = .*?;/, "const STAMPED_VERSION = '';")
          .replace(/const SHELL_FILES = .*?;/, 'const SHELL_FILES = [];')
          .replace(/const SHELL_HASHES = .*?;/, 'const SHELL_HASHES = {};')
        : readFileSync(join(dir, name));
    hash.update(name).update('\0').update(bytes).update('\0');
  }
  return hash.digest('hex').slice(0, 12);
}

export function stamp(dir) {
  const path = join(dir, BOOTSTRAP);
  const source = readFileSync(path, 'utf8');
  const match = source.match(TOKEN);
  if (!match) throw new Error(`No registerWorker("...") version in ${path}.`);
  const versionPath = join(dir, 'version.json');
  // Flutter normally creates this file. Also support minimal local fixtures.
  let metadata;
  try { metadata = JSON.parse(readFileSync(versionPath, 'utf8')); } catch (error) {
    if (error.code !== 'ENOENT') throw error;
    metadata = {};
    writeFileSync(versionPath, JSON.stringify(metadata));
  }
  const base = match[1].split('-')[0];
  const version = `${base}-${buildHash(dir)}`;
  writeFileSync(path, source.replace(TOKEN, `registerWorker("${version}"`));
  writeFileSync(versionPath, JSON.stringify({...metadata, pantasBuildVersion: version}));
  const workerPath = join(dir, 'pantas_sw.js');
  if (existsSync(workerPath)) {
    // Snapshot every shipped file so a deployment during installation cannot
    // mix builds. Hashes also validate entries left by an interrupted install.
    const shell = files(dir).filter(name =>
      name !== 'pantas_sw.js' && name !== 'flutter_service_worker.js' && !name.endsWith('.map')
    );
    const hashes = Object.fromEntries(shell.map(name => [
      name, createHash('sha256').update(readFileSync(join(dir, name))).digest('hex'),
    ]));
    const worker = readFileSync(workerPath, 'utf8')
      .replace(/const STAMPED_VERSION = .*?;/, `const STAMPED_VERSION = ${JSON.stringify(version)};`)
      .replace(/const SHELL_FILES = .*?;/, `const SHELL_FILES = ${JSON.stringify(shell)};`)
      .replace(/const SHELL_HASHES = .*?;/, `const SHELL_HASHES = ${JSON.stringify(hashes)};`);
    writeFileSync(workerPath, worker);
  }
  return version;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  console.log(`Service worker version: ${stamp(process.argv[2] ?? 'build/web')}`);
}
