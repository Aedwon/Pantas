import assert from 'node:assert/strict';
import { readdirSync, readFileSync } from 'node:fs';
import test from 'node:test';
import express from 'express';
import * as endpoints from '../lib/index.js';

const srcDir = new URL('../src/', import.meta.url);
const sources = readdirSync(srcDir)
  .filter((name) => name.endsWith('.ts'))
  .map((name) => [name, readFileSync(new URL(name, srcDir), 'utf8')]);

// Text of the options object passed as the first argument of a call that starts at `at`.
function optionsAt(source, at) {
  let i = source.indexOf('(', at) + 1;
  while (/\s/.test(source[i])) i += 1;
  if (source[i] !== '{') {
    const name = /^[A-Za-z_]\w*/.exec(source.slice(i))[0];
    const def = new RegExp(`const ${name}\\s*=\\s*\\{`).exec(source);
    assert.ok(def, `options ${name} must be defined in the same file`);
    return balanced(source, def.index + def[0].length - 1);
  }
  const own = balanced(source, i);
  return own.includes('...options') ? own + optionsAt(source, source.indexOf('const options')) : own;
}
function balanced(source, open) {
  let depth = 0;
  for (let i = open; i < source.length; i += 1) {
    if (source[i] === '{') depth += 1;
    if (source[i] === '}' && (depth -= 1) === 0) return source.slice(open, i + 1);
  }
  throw new Error('unbalanced options');
}
const calls = (re) => sources.flatMap(([file, source]) =>
  [...source.matchAll(re)].map((m) => ({ file, name: /export const (\w+)\s*=\s*$/.exec(source.slice(0, m.index))?.[1], options: optionsAt(source, m.index), source })));

const callables = calls(/\bonCall\(/g).filter((c) => c.name);
const httpFunctions = calls(/\bonRequest\(/g).filter((c) => c.name);

// Payment, trial, deletion, export, admin and paid-mock actions: one use per token.
const REPLAY_PROTECTED = [
  'createPaymongoCheckout', 'startWebTrial', 'deleteAccount', 'exportData',
  'recomputePassEnds', 'startMock', 'updateMockReview',
];

test('the source scan finds exactly the callables the deploy entry exposes', () => {
  const deployed = Object.entries(endpoints)
    .filter(([, fn]) => fn?.__endpoint?.callableTrigger)
    .map(([name]) => name).sort();
  assert.deepEqual(callables.map((c) => c.name).sort(), deployed);
  assert.ok(deployed.length >= 27);
});

test('every callable enforces App Check', () => {
  for (const { name, options } of callables) {
    assert.match(options, /enforceAppCheck:\s*true/, `${name} must enforce App Check`);
  }
});

test('payment, trial, deletion, export and admin callables consume the token and reject replays', () => {
  for (const name of REPLAY_PROTECTED) {
    const c = callables.find((x) => x.name === name);
    assert.ok(c, `${name} must exist`);
    assert.match(c.options, /consumeAppCheckToken:\s*true/, `${name} must consume the token`);
    const body = c.source.slice(c.source.indexOf(`export const ${name}`));
    assert.match(body.slice(0, 900), /assertFreshAppCheck\(request\)/, `${name} must reject a used token`);
  }
});

test('webhooks and public pages do not use App Check and keep their own checks', () => {
  assert.deepEqual(httpFunctions.map((f) => f.name).sort(), ['paymongoWebhook', 'renderWrappedPage', 'revenuecatWebhook']);
  for (const { name, options } of httpFunctions) {
    assert.doesNotMatch(options, /AppCheck/, `${name} is called by a third party or a browser page`);
  }
  const paymongo = sources.find(([f]) => f === 'paymongoWebhook.ts')[1];
  assert.match(paymongo, /signature/i);
  const revenuecat = sources.find(([f]) => f === 'revenuecatWebhook.ts')[1];
  assert.match(revenuecat, /authorization|signature|secret/i);
});

test('each callable rejects a request that carries no App Check token', async () => {
  for (const { name } of callables) {
    const app = express();
    app.use(express.json());
    app.post('/', endpoints[name]);
    const server = app.listen(0);
    try {
      const res = await fetch(`http://127.0.0.1:${server.address().port}/`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ data: {} }),
      });
      assert.equal(res.status, 401, `${name} must refuse a request without App Check`);
      assert.equal((await res.json()).error.status, 'UNAUTHENTICATED');
    } finally {
      server.close();
    }
  }
});

test('a used App Check token is rejected and a fresh one passes', async () => {
  const { assertFreshAppCheck } = await import('../lib/_appCheck.js');
  assert.throws(() => assertFreshAppCheck({ app: { appId: 'a', token: {}, alreadyConsumed: true } }), /Unauthenticated/);
  assert.doesNotThrow(() => assertFreshAppCheck({ app: { appId: 'a', token: {}, alreadyConsumed: false } }));
  assert.doesNotThrow(() => assertFreshAppCheck({}));
});
