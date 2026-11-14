// Compares what Firebase Hosting and the Cloudflare Worker serve, path by path.
// Usage: node tool/cloudflare-app/compare.mjs <firebase origin> <worker origin> <build/web dir> <web api key>
// Exit 1 on any mismatch. Checks status, content type, browser cache lifetime and body hash for every
// file in the build, the app routes, and Firebase's sign-in paths with query strings and a POST.
import {createHash} from 'node:crypto';
import {readdirSync, statSync} from 'node:fs';
import {join, relative} from 'node:path';

const [firebase, worker, buildDir, apiKey] = process.argv.slice(2);
if (!firebase || !worker || !buildDir || !apiKey) {
  console.error('usage: compare.mjs <firebase origin> <worker origin> <build/web dir> <web api key>');
  process.exit(2);
}

const NOT_SERVED = new Set(['/.last_build_id', '/README.md', '/_headers', '/.assetsignore']);
const files = [];
const walk = dir => {
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (statSync(full).isDirectory()) walk(full);
    else files.push('/' + relative(buildDir, full).split('\\').join('/'));
  }
};
walk(buildDir);

const auth = `apiKey=${encodeURIComponent(apiKey)}&appName=%5BDEFAULT%5D&authType=signInViaPopup&providerId=google.com&v=11.0.0`;
const checks = [
  ...files.filter(path => !NOT_SERVED.has(path)).map(path => ({path})),
  {path: '/'},
  {path: '/quiz/some-id', route: true},
  {path: '/settings', route: true},
  {path: `/__/auth/handler?${auth}`, auth: true},
  {path: `/__/auth/iframe?apiKey=${encodeURIComponent(apiKey)}&appName=%5BDEFAULT%5D&v=11.0.0`, auth: true},
  {path: '/__/auth/handler.js', auth: true},
  {path: '/__/firebase/init.json', auth: true},
  {path: '/__/auth/handler?apiKey=x', method: 'POST', body: 'state=test', auth: true},
];

const maxAge = value => {
  const match = /max-age=(\d+)/.exec(value ?? '');
  return match ? Number(match[1]) : 0;
};
const type = value => (value ?? '').split(';')[0].trim();

async function get(origin, check) {
  const response = await fetch(origin + check.path, {
    method: check.method ?? 'GET', body: check.body, redirect: 'manual',
    headers: check.body ? {'content-type': 'application/x-www-form-urlencoded'} : {},
  });
  const body = Buffer.from(await response.arrayBuffer());
  return {
    status: response.status,
    type: type(response.headers.get('content-type')),
    age: maxAge(response.headers.get('cache-control')),
    location: response.headers.get('location'),
    hash: createHash('sha256').update(body).digest('hex').slice(0, 16),
  };
}

let bad = 0;
for (const check of checks) {
  const [a, b] = await Promise.all([get(firebase, check), get(worker, check)]);
  const diffs = [];
  if (a.status !== b.status) diffs.push(`status ${a.status} vs ${b.status}`);
  // Files with no standard extension (licenses, shaders, debug symbols): Firebase labels them
  // text/html, Cloudflare sends no type. The app reads them as bytes, so the label does not matter.
  const untyped = a.type === 'text/html' && b.type === '' && !/\.html?$/.test(check.path.split('?')[0]) && check.path !== '/';
  if (a.type !== b.type && !untyped) diffs.push(`type ${a.type} vs ${b.type}`);
  // App routes: Firebase caches the rewritten index.html for an hour; the Worker revalidates it every
  // time, like /index.html. An intended improvement, so only the body must match.
  if (!check.route && !check.auth && a.age !== b.age) diffs.push(`max-age ${a.age} vs ${b.age}`);
  if (a.location !== b.location) diffs.push(`location ${a.location} vs ${b.location}`);
  if (a.hash !== b.hash) diffs.push('body differs');
  if (diffs.length) { bad += 1; console.log(`MISMATCH ${check.method ?? 'GET'} ${check.path.slice(0, 80)}: ${diffs.join('; ')}`); }
}
console.log(`${checks.length - bad} of ${checks.length} match`);
process.exit(bad ? 1 : 0);
