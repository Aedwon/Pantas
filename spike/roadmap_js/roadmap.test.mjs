// Run from the repo root after build.sh and expected.dart:
//   node --test spike/roadmap_js/
// Env: ROADMAP_JS=spike/roadmap_js/build/roadmap.O2.js (default)
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { performance } from 'node:perf_hooks';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const jsFile = path.resolve(
  process.env.ROADMAP_JS ?? path.join(here, 'build/roadmap.O2.js'),
);
const scenarios = JSON.parse(readFileSync(path.join(here, 'fixtures/scenarios.json'), 'utf8'));
const expectedText = readFileSync(path.join(here, 'fixtures/expected.json'), 'utf8');
const expected = JSON.parse(expectedText);

// Browser-only globals that must not be needed at load time.
const browserGlobals = ['window', 'document', 'self', 'navigator', 'location'];
const before = browserGlobals.map((g) => [g, typeof globalThis[g]]);

const t0 = performance.now();
createRequire(import.meta.url)(jsFile);
const coldLoadMs = performance.now() - t0;

test('loading created no browser globals', () => {
  // Node 21+ ships its own `navigator`, so compare before and after load
  // instead of asserting absence.
  for (const [g, type] of before) assert.equal(typeof globalThis[g], type, g);
});

test('loads and runs in a bare V8 context (no window, document, timers, console, process)', () => {
  const sandbox = vm.createContext({});
  vm.runInContext(readFileSync(jsFile, 'utf8'), sandbox);
  assert.equal(typeof sandbox.pantasBuildRoadmap, 'function');
  const out = sandbox.pantasBuildRoadmap(JSON.stringify(scenarios.planning_rich));
  assert.equal(out, JSON.stringify(expected.planning_rich));
  for (const g of ['window', 'document', 'self', 'process']) {
    assert.equal(typeof sandbox[g], 'undefined', g);
  }
});

test('exports pantasBuildRoadmap', () => {
  assert.equal(typeof globalThis.pantasBuildRoadmap, 'function');
});

for (const [name, input] of Object.entries(scenarios)) {
  test(`scenario ${name} matches the Dart VM output exactly`, () => {
    const out = globalThis.pantasBuildRoadmap(JSON.stringify(input));
    assert.equal(typeof out, 'string');
    assert.deepEqual(JSON.parse(out), expected[name]);
    // Same key order and number formatting, byte for byte.
    assert.equal(out, JSON.stringify(expected[name]));
  });
}

test('the whole expected file matches byte for byte', () => {
  const all = {};
  for (const [name, input] of Object.entries(scenarios)) {
    all[name] = JSON.parse(globalThis.pantasBuildRoadmap(JSON.stringify(input)));
  }
  assert.equal(JSON.stringify(all), expectedText);
});

test('timing: 100 calls per scenario (informational)', () => {
  const report = { coldLoadMs: +coldLoadMs.toFixed(1), medianMs: {} };
  for (const name of ['planning_rich', 'planning_large_120x900', 'review_only_anchored']) {
    const json = JSON.stringify(scenarios[name]); // parse cost included below
    const times = [];
    for (let i = 0; i < 100; i++) {
      const s = performance.now();
      globalThis.pantasBuildRoadmap(json);
      times.push(performance.now() - s);
    }
    times.sort((a, b) => a - b);
    report.medianMs[name] = {
      median: +times[49].toFixed(2),
      p95: +times[94].toFixed(2),
      inputKB: Math.round(json.length / 1024),
    };
  }
  console.log('TIMING ' + JSON.stringify(report));
});

test('deterministic across repeated calls', () => {
  const json = JSON.stringify(scenarios.planning_rich);
  const a = globalThis.pantasBuildRoadmap(json);
  for (let i = 0; i < 20; i++) assert.equal(globalThis.pantasBuildRoadmap(json), a);
});
