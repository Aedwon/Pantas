import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, writeFileSync, readFileSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {stamp} from './stamp_worker_version.mjs';

test('stamp publishes matching opaque identities and a complete shell inventory, idempotently', () => {
  const dir = mkdtempSync(join(tmpdir(), 'pantas-manifest-'));
  try {
    mkdirSync(join(dir, 'assets'));
    for (const [name, value] of Object.entries({
      'flutter_bootstrap.js': 'pwa.registerWorker("123");',
      'pantas_sw.js': "const STAMPED_VERSION = '';\nconst SHELL_FILES = [];\nconst SHELL_HASHES = {};",
      'version.json': JSON.stringify({version: '1.2.3', build_number: '7'}),
      'main.dart.js': 'main', 'main.dart.js_1.part.js': 'part',
      'drift_worker.js': 'database', 'sqlite3.wasm': 'wasm',
      'assets/FontManifest.json': '[]', 'assets/font.woff2': 'font',
    })) writeFileSync(join(dir, name), value);
    const version = stamp(dir);
    assert.equal(JSON.parse(readFileSync(join(dir, 'version.json'))).pantasBuildVersion, version);
    assert.equal(JSON.parse(readFileSync(join(dir, 'version.json'))).build_number, '7');
    const worker = readFileSync(join(dir, 'pantas_sw.js'), 'utf8');
    assert.ok(worker.includes(JSON.stringify(version)));
    for (const name of ['main.dart.js', 'main.dart.js_1.part.js', 'drift_worker.js', 'sqlite3.wasm', 'assets/FontManifest.json', 'assets/font.woff2']) {
      assert.ok(worker.includes(JSON.stringify(name)), name);
    }
    assert.equal(stamp(dir), version);
    writeFileSync(join(dir, 'main.dart.js'), 'changed');
    assert.notEqual(stamp(dir), version);
  } finally {rmSync(dir, {recursive: true, force: true});}
});
