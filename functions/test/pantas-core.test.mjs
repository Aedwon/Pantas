// The compiled Dart core (roadmap engine and mock sampler) must give the same output as the Dart VM.
// Fixtures: server_dart/fixtures, written by `dart run server_dart/make_fixtures.dart` and
// `dart run server_dart/reference.dart` (the Dart VM side). Rebuild the JS with server_dart/build.sh.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import test from 'node:test';
import vm from 'node:vm';
import {isStale} from '../../server_dart/closure_hash.mjs';

const fixture = name => JSON.parse(readFileSync(new URL(`../../server_dart/fixtures/${name}`, import.meta.url), 'utf8'));
const jsPath = new URL('../src/generated/pantas_core.js', import.meta.url);
const text = readFileSync(jsPath, 'utf8');

test('the generated JS matches the current Dart sources', () => {
  assert.equal(isStale(text), false, 'Run server_dart/build.sh and commit functions/src/generated/pantas_core.js.');
});

test('a changed source hash is reported as stale', () => {
  assert.equal(isStale(text.replace(/source-hash: [0-9a-f]{64}/, `source-hash: ${'0'.repeat(64)}`)), true);
  assert.equal(isStale('// no header\n'), true);
});

test('it loads in a bare V8 context with no browser or Node globals', () => {
  const sandbox = vm.createContext({});
  vm.runInContext(text, sandbox);
  assert.equal(typeof sandbox.pantasBuildRoadmap, 'function');
  assert.equal(typeof sandbox.pantasSampleMock, 'function');
});

createRequire(import.meta.url)(jsPath.pathname);

for (const [fn, scenarios, expected] of [
  ['pantasBuildRoadmap', 'roadmap_scenarios.json', 'roadmap_expected.json'],
  ['pantasSampleMock', 'mock_scenarios.json', 'mock_expected.json'],
]) {
  const inputs = fixture(scenarios);
  const outputs = fixture(expected);
  for (const [name, input] of Object.entries(inputs)) {
    test(`${fn} ${name} matches the Dart VM byte for byte`, () => {
      assert.equal(globalThis[fn](JSON.stringify(input)), JSON.stringify(outputs[name]));
    });
  }
}

test('the same mock seed gives the same paper and another seed gives another', () => {
  const inputs = fixture('mock_scenarios.json');
  const a = globalThis.pantasSampleMock(JSON.stringify(inputs.two_sections));
  assert.equal(globalThis.pantasSampleMock(JSON.stringify(inputs.two_sections)), a);
  assert.notEqual(globalThis.pantasSampleMock(JSON.stringify(inputs.same_inputs_other_seed)), a);
});
