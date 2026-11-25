// The old Firebase addresses (pantas-prod.web.app, pantas-prod.firebaseapp.com, and staging's
// pantas-staging-app.web.app) serve only a tiny page that sends visitors to the real address.
// Firebase Hosting bills every byte it sends and has no cap (security audit S-01; checklist S6).
// The app itself is served by the Cloudflare Worker; the /__/ sign-in paths are reserved by
// Firebase and keep working with any site content.
import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync, readdirSync, statSync} from 'node:fs';

const root = new URL('../../', import.meta.url);
const read = path => readFileSync(new URL(path, root), 'utf8');
const appTarget = file => JSON.parse(read(file)).hosting.find(site => site.target === 'app');

test('the app Hosting target deploys only the tiny page, in prod and staging', () => {
  for (const file of ['firebase.json', 'firebase.staging.json']) {
    assert.equal(appTarget(file).public, 'hosting/retired', file);
  }
});

test('the tiny page stays tiny and points at the real address', () => {
  const dir = new URL('hosting/retired/', root);
  const files = readdirSync(dir).sort();
  assert.deepEqual(files, ['index.html', 'pantas_sw.js']);
  const total = files.reduce((sum, f) => sum + statSync(new URL(f, dir)).size, 0);
  assert.ok(total < 2048, `tiny page is ${total} bytes`);
  const page = read('hosting/retired/index.html');
  assert.match(page, /https:\/\/app\.pantas\.study/);
  assert.match(page, /startsWith\('pantas-staging'\) \? 'https:\/\/staging\.pantas\.study'/, 'staging goes to staging');
  assert.doesNotMatch(page, /<script[^>]+src=|<link[^>]+stylesheet|<img/, 'loads nothing else');
});

test('an old service worker on the old address removes itself', () => {
  const worker = read('hosting/retired/pantas_sw.js');
  assert.match(worker, /registration\.unregister\(\)/);
  assert.match(worker, /caches\.delete/);
});

test('the staging web deploy publishes to the Worker, not Firebase Hosting', () => {
  const script = read('tool/deploy/staging_web.sh');
  assert.doesNotMatch(script, /firebase deploy[^\n]*hosting/);
  assert.match(script, /tool\/cloudflare-app\/deploy\.sh staging build\/web/);
});
