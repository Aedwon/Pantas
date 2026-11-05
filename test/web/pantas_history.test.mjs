// Run with: node --test test/web/pantas_history.test.mjs
import test from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';

const require = createRequire(import.meta.url);
const { unwrap } = require('../../web/pantas_history.js');

function windowWith(state, { throws = false } = {}) {
  const calls = [];
  return {
    calls,
    location: { href: 'https://pantas.test/legal/privacy' },
    history: {
      get state() {
        if (throws) throw new Error('denied');
        return state;
      },
      replaceState: (...args) => calls.push(args),
    },
  };
}

test('a reloaded entry numbered by Flutter is unwrapped in place', () => {
  const inner = { location: '/settings', state: { codec: 'json' } };
  const win = windowWith({ serialCount: 5, state: inner });
  assert.equal(unwrap(win), true);
  assert.deepEqual(win.calls, [[inner, '', 'https://pantas.test/legal/privacy']]);
});

test('a first load, with no state, is left alone', () => {
  const win = windowWith(null);
  assert.equal(unwrap(win), false);
  assert.equal(win.calls.length, 0);
});

test('a state Flutter did not number is left alone', () => {
  const win = windowWith({ origin: true, state: null });
  assert.equal(unwrap(win), false);
  assert.equal(win.calls.length, 0);
});

test('a browser that refuses history access does not break the page', () => {
  assert.equal(unwrap(windowWith({ serialCount: 1, state: {} }, { throws: true })), false);
});

test('the page loads it first, and the worker keeps it current', () => {
  const html = readFileSync(new URL('../../web/index.html', import.meta.url), 'utf8');
  const sw = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
  assert.ok(html.indexOf('pantas_history.js') > 0);
  assert.ok(html.indexOf('pantas_history.js') < html.indexOf('pantas_pwa.js'));
  assert.equal(sw.split("'pantas_history.js'").length - 1, 2);
});
