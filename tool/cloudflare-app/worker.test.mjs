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

// M4 security headers (plan docs/superpowers/plans/2026-11-22-m4-security-pass.md): CSP reports.
const report = (body, init = {}) => new Request('https://app.pantas.study/__/csp-report', {
  method: 'POST', body, headers: {'content-type': 'application/csp-report', ...(init.headers ?? {})}, ...init});

function captureLog() {
  const lines = []; const original = console.log;
  console.log = (...a) => lines.push(a.join(' '));
  return {lines, restore: () => { console.log = original; }};
}

test('a CSP report is logged compactly, with no query strings, and never forwarded', async () => {
  const log = captureLog();
  try {
    const body = JSON.stringify({'csp-report': {'document-uri': 'https://app.pantas.study/quiz/x?token=secret',
      'violated-directive': 'script-src-elem', 'effective-directive': 'script-src-elem',
      'blocked-uri': 'https://evil.example/a.js?k=v', 'source-file': 'https://app.pantas.study/main.dart.js?v=1', 'line-number': 12}});
    const response = await handle(report(body), env([]), async () => { throw new Error('no forwarding'); });
    assert.equal(response.status, 204);
    assert.equal(log.lines.length, 1);
    const entry = JSON.parse(log.lines[0]);
    assert.deepEqual(entry, {kind: 'csp_report', directive: 'script-src-elem', blocked: 'https://evil.example/a.js',
      page: '/quiz/x', source: 'https://app.pantas.study/main.dart.js', line: 12});
    assert.ok(!log.lines[0].includes('secret') && !log.lines[0].includes('k=v'));
  } finally { log.restore(); }
});

test('the Reporting API format (a list of csp-violation reports) is accepted too', async () => {
  const log = captureLog();
  try {
    const body = JSON.stringify([{type: 'csp-violation', url: 'https://app.pantas.study/', body: {
      effectiveDirective: 'connect-src', blockedURL: 'wss://x.example/socket', documentURL: 'https://app.pantas.study/', lineNumber: 3}}]);
    const response = await handle(report(body, {headers: {'content-type': 'application/reports+json'}}), env([]), async () => { throw new Error('no'); });
    assert.equal(response.status, 204);
    assert.equal(JSON.parse(log.lines[0]).directive, 'connect-src');
    assert.equal(JSON.parse(log.lines[0]).blocked, 'wss://x.example/socket');
  } finally { log.restore(); }
});

test('a CSP report that is too large or not JSON is dropped without logging, and only POST is accepted', async () => {
  const log = captureLog();
  try {
    assert.equal((await handle(report('x'.repeat(9000)), env([]), async () => { throw new Error('no'); })).status, 413);
    assert.equal((await handle(report('not json'), env([]), async () => { throw new Error('no'); })).status, 400);
    const get = await handle(new Request('https://app.pantas.study/__/csp-report'), env([]), async () => { throw new Error('no'); });
    assert.equal(get.status, 405);
    assert.equal(log.lines.length, 0);
  } finally { log.restore(); }
});

test('both header files send the enforced headers and a report-only CSP that reports to the Worker', async () => {
  const {readFileSync} = await import('node:fs');
  for (const [envName, functionsHost] of [['prod', 'https://asia-southeast1-pantas-prod.cloudfunctions.net'], ['staging', 'https://asia-southeast1-pantas-staging.cloudfunctions.net']]) {
    const text = readFileSync(new URL(`./headers.${envName}`, import.meta.url), 'utf8');
    const all = text.split(/\n(?=\/)/).find(block => block.startsWith('/*\n'));
    assert.ok(all, `${envName}: a /* block`);
    for (const header of ['Strict-Transport-Security: max-age=31556926', 'X-Content-Type-Options: nosniff',
      'Referrer-Policy: strict-origin-when-cross-origin', "Content-Security-Policy: frame-ancestors 'self'"]) {
      assert.ok(all.includes(header), `${envName}: ${header}`);
    }
    assert.match(all, /Permissions-Policy: camera=\(\), microphone=\(\), geolocation=\(\)/);
    const csp = /Content-Security-Policy-Report-Only: (.*)/.exec(all)?.[1] ?? '';
    for (const part of ["default-src 'self'", "object-src 'none'", "base-uri 'self'", 'report-uri /__/csp-report',
      "'wasm-unsafe-eval'", "'sha256-wLXA+w+9L9bTF96SO3KPEs30qNhuiOJJxLtqMR1MJFc='", functionsHost]) {
      assert.ok(csp.includes(part), `${envName} CSP has ${part}`);
    }
    assert.ok(!csp.includes("'unsafe-eval'") && !/script-src[^;]*'unsafe-inline'/.test(csp), `${envName}: no unsafe script sources`);
  }
});
