import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import test from 'node:test';

const readJson = (path) => JSON.parse(readFileSync(new URL(path, import.meta.url), 'utf8'));

test('package builds its deploy entry and runs every test stage on the demo emulators', () => {
  const pkg = readJson('../package.json');
  const config = readJson('../../firebase.json');
  assert.equal(pkg.main, 'lib/index.js');
  assert.equal(pkg.engines.node, '22');
  assert.match(pkg.scripts.build, /^tsc\b/);
  assert.match(pkg.scripts.test, /npm run build && node --test test\/\*\.test\.mjs/);
  assert.match(pkg.scripts.test, /--only auth,firestore,storage --project demo-pantas-test/);
  assert.match(pkg.scripts.test, /test\/\*\.rules\.mjs test\/\*\.emulator\.mjs/);
  assert.equal(config.functions.runtime, 'nodejs22');
  assert.equal(config.functions.predeploy, 'npm --prefix functions run build');
});

test('build includes the complete W0 exam catalog', () => {
  const path = new URL('../lib/examCatalog.json', import.meta.url);
  assert.ok(existsSync(path), 'compiled package must include the exam catalog');
  assert.deepEqual(readJson('../lib/examCatalog.json'), readJson('../../content/exams/catalog.json'));
});

test('AC-7 build includes the complete W3 product table', () => {
  const path = new URL('../lib/products.json', import.meta.url);
  assert.ok(existsSync(path), 'compiled package must include the product table');
  assert.deepEqual(readJson('../lib/products.json'), readJson('../src/products.json'));
});
