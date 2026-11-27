// E-210, audit 2 High 5: the bootstrap pins full CanvasKit for every browser, so the one
// renderer the worker stores is the one Flutter asks for. Without the pin Flutter picks the
// chromium variant on Chrome and Edge, on checks (ImageDecoder, break iterators) that a
// service worker cannot all make.
//
// The bootstrap runs here as Flutter's build writes it, with the template tokens filled in
// and Flutter's loader replaced by one that records the configuration it is given.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const source = readFileSync(new URL('../../web/flutter_bootstrap.js', import.meta.url), 'utf8');

async function loaderConfig({base}) {
  const calls = [];
  const window = {
    pantasPwa: {registerWorker: async () => false},
    performance: {mark() {}},
  };
  if (base) window.pantasBuildBase = base;
  window.window = window;
  const code = source
    .replace('{{flutter_js}}', '')
    .replace('{{flutter_build_config}}', '')
    .replace('{{flutter_service_worker_version}}', '"1-abc"');
  vm.runInNewContext(`var _flutter = {loader: {load: function (options) { calls.push(options); }}};\n${code}`, {
    ...window, window, calls, performance: window.performance,
  });
  for (let i = 0; i < 20 && !calls.length; i++) await new Promise(done => setTimeout(done, 5));
  assert.equal(calls.length, 1, 'the bootstrap starts Flutter once');
  return calls[0].config ?? {};
}

test('a release build (a build folder) pins full CanvasKit', async () => {
  const config = await loaderConfig({base: 'b/1-abc/'});
  assert.equal(config.canvasKitVariant, 'full');
  assert.equal(config.canvasKitBaseUrl, 'b/1-abc/canvaskit');
});

test('a dev run (no build folder) pins full CanvasKit too', async () => {
  const config = await loaderConfig({base: undefined});
  assert.equal(config.canvasKitVariant, 'full');
});
