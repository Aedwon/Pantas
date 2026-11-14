// Run: node --test tool/cloudflare-app/
import assert from 'node:assert/strict';
import test from 'node:test';
import {handle} from './worker.mjs';

const env = (calls) => ({
  FIREBASE_ORIGIN: 'https://pantas-prod.firebaseapp.com',
  ASSETS: {fetch: async request => { calls.push(['assets', new URL(request.url).pathname]); return new Response('asset'); }},
});

test('a path outside /__/ is served from the static files', async () => {
  const calls = [];
  const response = await handle(new Request('https://app.pantas.study/quiz/abc'), env(calls), async () => { throw new Error('no forwarding'); });
  assert.equal(await response.text(), 'asset');
  assert.deepEqual(calls, [['assets', '/quiz/abc']]);
});

test('/__/ is forwarded to Firebase with path, query, method, body and headers intact', async () => {
  const seen = [];
  const forward = async (url, init) => { seen.push({url: String(url), init}); return new Response('handler', {status: 200, headers: {'x-from': 'firebase'}}); };
  const request = new Request('https://app.pantas.study/__/auth/handler?apiKey=k&authType=signInViaPopup&v=1', {
    method: 'POST', body: 'a=1', headers: {'content-type': 'application/x-www-form-urlencoded', cookie: 'c=1', 'x-custom': 'y'},
  });
  const response = await handle(request, env([]), forward);
  assert.equal(await response.text(), 'handler');
  assert.equal(response.headers.get('x-from'), 'firebase');
  assert.equal(seen.length, 1);
  assert.equal(seen[0].url, 'https://pantas-prod.firebaseapp.com/__/auth/handler?apiKey=k&authType=signInViaPopup&v=1');
  assert.equal(seen[0].init.method, 'POST');
  assert.equal(seen[0].init.redirect, 'manual');
  const headers = new Headers(seen[0].init.headers);
  assert.equal(headers.get('cookie'), 'c=1');
  assert.equal(headers.get('x-custom'), 'y');
  assert.equal(headers.get('host'), null);
  assert.equal(await new Response(seen[0].init.body).text(), 'a=1');
});

test('a redirect from Firebase is passed back unchanged, not followed', async () => {
  const forward = async () => new Response(null, {status: 302, headers: {location: 'https://accounts.google.com/o/oauth2/auth?x=1'}});
  const response = await handle(new Request('https://app.pantas.study/__/auth/handler?x=1'), env([]), forward);
  assert.equal(response.status, 302);
  assert.equal(response.headers.get('location'), 'https://accounts.google.com/o/oauth2/auth?x=1');
});

test('only the exact /__/ prefix is forwarded', async () => {
  const calls = [];
  await handle(new Request('https://app.pantas.study/__x/file'), env(calls), async () => { throw new Error('no'); });
  assert.deepEqual(calls, [['assets', '/__x/file']]);
});
