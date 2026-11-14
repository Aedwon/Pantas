// Run with: node --test test/web/pantas_pwa.test.mjs
import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFileSync } from 'node:fs';

const source = readFileSync(new URL('../../web/pantas_pwa.js', import.meta.url), 'utf8');

// Runs pantas_pwa.js in a fake page. `controller` is the worker script URL that
// controlled the page at load, or null for a page no worker controlled.
function load({ controller = null, supported = true, registerFails = false, noPerformance = false } = {}) {
  const marks = [];
  const listeners = {};
  const registration = {
    active: null,
    installing: null,
    waiting: null,
    addEventListener() {},
  };
  const sw = {
    controller: controller ? { scriptURL: controller } : null,
    register(script) {
      if (registerFails) return Promise.reject(new Error('blocked'));
      const worker = {
        scriptURL: 'https://app.example/' + script,
        addEventListener() {},
      };
      registration.active = worker;
      sw.controller = { scriptURL: worker.scriptURL };
      return Promise.resolve(registration);
    },
    addEventListener() {},
  };
  const navigator = supported ? { serviceWorker: sw } : {};
  const window = {
    addEventListener: (name, fn) => (listeners[name] = fn),
    location: { reload() {} },
    performance: noPerformance
      ? undefined
      : { mark: (name) => marks.push(name) },
  };
  const context = vm.createContext({
    window,
    navigator,
    setTimeout: (fn) => {
      void fn;
      return 0;
    },
    Promise,
    encodeURIComponent,
  });
  vm.runInContext(source, context);
  return { pwa: window.pantasPwa, marks };
}

test('a page no worker controlled is a first visit', () => {
  const { pwa } = load({ controller: null });
  assert.equal(pwa.visitKind(), 'first');
});

test('a page the same build controlled is a return visit', async () => {
  const { pwa } = load({ controller: 'https://app.example/pantas_sw.js?v=abc123' });
  assert.equal(pwa.visitKind(), 'return', 'before the build is known');
  await pwa.registerWorker('abc123');
  assert.equal(pwa.visitKind(), 'return');
});

test('a page an older build controlled is the first load after a deploy', async () => {
  const { pwa } = load({ controller: 'https://app.example/pantas_sw.js?v=old999' });
  await pwa.registerWorker('abc123');
  assert.equal(pwa.visitKind(), 'after_deploy');
});

test('the visit kind is decided at load, not after the new worker takes over', async () => {
  const { pwa } = load({ controller: null });
  await pwa.registerWorker('abc123');
  assert.equal(pwa.visitKind(), 'first');
});

test('the page can say which build it started with', async () => {
  const { pwa } = load({ controller: null });
  assert.equal(pwa.buildVersion(), null, 'before the worker step');
  await pwa.registerWorker('1293236267-5bbf79dc07b4');
  assert.equal(pwa.buildVersion(), '1293236267-5bbf79dc07b4');
});

test('a browser without workers counts as a first visit', () => {
  const { pwa } = load({ supported: false });
  assert.equal(pwa.visitKind(), 'first');
});

test('page.worker is marked when the worker step resolves, on every path', async () => {
  for (const options of [
    { controller: null },
    { controller: null, supported: false },
    { controller: 'https://app.example/pantas_sw.js?v=old', registerFails: true },
  ]) {
    const { pwa, marks } = load(options);
    assert.deepEqual(marks, []);
    await pwa.registerWorker('abc123');
    assert.deepEqual(marks, ['page.worker']);
  }
});

test('a missing performance API never breaks the worker step', async () => {
  const { pwa, marks } = load({ controller: null, noPerformance: true });
  assert.equal(await pwa.registerWorker('abc123'), true);
  assert.deepEqual(marks, []);
});
