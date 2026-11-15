// Compares what the Cloudflare Worker serves with the local build folder it was published from, path
// by path. It fetches only the Worker. It never fetches from Firebase: every byte downloaded from
// Firebase Hosting is billed egress (Fable 5.2 rule 7 ruling 2, Nov 15, 2026).
// Usage: node tool/cloudflare-app/compare.mjs <worker origin> <build/web dir> <web api key> [headers file]
// The headers file defaults to headers.staging for a host with "staging" in it, else headers.prod.
// Exit 1 on any mismatch. Checks, for every file in the build: status 200, content type, the body
// hash against the local file, and the cache lifetime and other headers the headers file sets. App
// routes must return the local index.html. The sign-in paths are fetched through the Worker, which
// forwards them to Firebase (a few kilobytes), and must answer.
import {createHash} from 'node:crypto';
import {readFileSync, readdirSync, statSync} from 'node:fs';
import {dirname, join, relative} from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

const NOT_SERVED = new Set(['/.last_build_id', '/README.md', '/_headers', '/.assetsignore']);

// Cloudflare's labels for the file kinds a Flutter web build holds. Other extensions are not checked
// (Cloudflare sends no type for licenses, shaders and debug symbols; the app reads them as bytes).
const TYPES = {
  html: ['text/html'], js: ['text/javascript', 'application/javascript'], mjs: ['text/javascript', 'application/javascript'],
  css: ['text/css'], json: ['application/json'], wasm: ['application/wasm'], png: ['image/png'], jpg: ['image/jpeg'],
  jpeg: ['image/jpeg'], svg: ['image/svg+xml'], webp: ['image/webp'], ico: ['image/x-icon', 'image/vnd.microsoft.icon'],
  txt: ['text/plain'], otf: ['font/otf', 'application/vnd.ms-opentype'], ttf: ['font/ttf', 'application/x-font-ttf'],
  woff: ['font/woff'], woff2: ['font/woff2'], webmanifest: ['application/manifest+json', 'application/json'],
};

/** Parses Cloudflare's _headers format. expected(path) returns the headers the file sets on that path. */
export function parseHeaders(text) {
  const blocks = [];
  for (const line of text.split('\n')) {
    if (!line.trim() || line.trim().startsWith('#')) continue;
    if (/^\s/.test(line)) {
      const [name, ...value] = line.trim().split(':');
      blocks.at(-1)?.headers.push([name.trim().toLowerCase(), value.join(':').trim()]);
    } else {
      const regex = new RegExp(`^${line.trim().replace(/[.+?^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '.*')}$`);
      blocks.push({regex, headers: []});
    }
  }
  return {
    expected(path) {
      const out = {};
      for (const block of blocks) if (block.regex.test(path)) for (const [name, value] of block.headers) out[name] = value;
      return out;
    },
  };
}

const maxAge = (value) => {
  const match = /max-age=(\d+)/.exec(value ?? '');
  return match ? Number(match[1]) : 0;
};
const typeOf = (value) => (value ?? '').split(';')[0].trim();
const sha = (bytes) => createHash('sha256').update(bytes).digest('hex').slice(0, 16);

export async function compare({worker, buildDir, apiKey, headersFile, fetchFn = fetch, log = console.log}) {
  const rules = parseHeaders(readFileSync(headersFile, 'utf8'));
  const files = [];
  const walk = (dir) => {
    for (const name of readdirSync(dir)) {
      const full = join(dir, name);
      if (statSync(full).isDirectory()) walk(full);
      else files.push('/' + relative(buildDir, full).split('\\').join('/'));
    }
  };
  walk(buildDir);

  const indexHash = sha(readFileSync(join(buildDir, 'index.html')));
  const auth = `apiKey=${encodeURIComponent(apiKey)}&appName=%5BDEFAULT%5D&authType=signInViaPopup&providerId=google.com&v=11.0.0`;
  const checks = [
    ...files.filter((path) => !NOT_SERVED.has(path)).map((path) => ({path, hash: sha(readFileSync(join(buildDir, path)))})),
    {path: '/', hash: indexHash, route: true},
    {path: '/quiz/some-id', hash: indexHash, route: true},
    {path: '/settings', hash: indexHash, route: true},
    {path: `/__/auth/handler?${auth}`, auth: 'html'},
    {path: `/__/auth/iframe?apiKey=${encodeURIComponent(apiKey)}&appName=%5BDEFAULT%5D&v=11.0.0`, auth: 'html'},
    {path: '/__/auth/handler.js', auth: 'js'},
    {path: '/__/firebase/init.json', auth: 'json'},
    {path: '/__/auth/handler?apiKey=x', method: 'POST', body: 'state=test', auth: 'post'},
  ];

  const mismatches = [];
  for (const check of checks) {
    const route = check.path.split('?')[0];
    const response = await fetchFn(worker + check.path, {
      method: check.method ?? 'GET', body: check.body, redirect: 'manual',
      headers: check.body ? {'content-type': 'application/x-www-form-urlencoded'} : {},
    });
    const body = Buffer.from(await response.arrayBuffer());
    const diffs = [];
    if (check.auth) {
      if (check.auth === 'post') {
        if (response.status >= 500 || response.status === 404) diffs.push(`status ${response.status}`);
      } else if (response.status !== 200) diffs.push(`status ${response.status}, expected 200`);
      else if (check.auth === 'json' && JSON.parse(body.toString('utf8')).apiKey !== apiKey) diffs.push('init.json apiKey is not the given key');
    } else {
      if (response.status !== 200) diffs.push(`status ${response.status}, expected 200`);
      if (sha(body) !== check.hash) diffs.push('body differs from the local file');
      const ext = route.includes('.') ? route.split('.').pop().toLowerCase() : '';
      const type = typeOf(response.headers.get('content-type'));
      if (!check.route && TYPES[ext] && !TYPES[ext].includes(type)) diffs.push(`type ${type || 'none'}, expected ${TYPES[ext][0]}`);
      const expected = rules.expected(route);
      // An app route is served from index.html, so it follows the index.html rules.
      const expectedHeaders = check.route ? rules.expected('/index.html') : expected;
      const age = expectedHeaders['cache-control'] === undefined ? 0 : maxAge(expectedHeaders['cache-control']);
      if (!check.route || route === '/') {
        if (maxAge(response.headers.get('cache-control')) !== age) diffs.push(`max-age ${maxAge(response.headers.get('cache-control'))}, expected ${age}`);
      }
      for (const [name, value] of Object.entries(expectedHeaders)) {
        if (name === 'cache-control') continue;
        if (response.headers.get(name) !== value) diffs.push(`header ${name} is "${response.headers.get(name)}", expected "${value}"`);
      }
    }
    if (diffs.length) {
      mismatches.push(`${check.method ?? 'GET'} ${check.path.slice(0, 80)}: ${diffs.join('; ')}`);
    }
  }
  for (const m of mismatches) log(`MISMATCH ${m}`);
  log(`${checks.length - mismatches.length} of ${checks.length} match`);
  return {total: checks.length, mismatches};
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const [worker, buildDir, apiKey, headersArg] = process.argv.slice(2);
  if (!worker || !buildDir || !apiKey) {
    console.error('usage: compare.mjs <worker origin> <build/web dir> <web api key> [headers file]');
    process.exit(2);
  }
  const here = dirname(fileURLToPath(import.meta.url));
  const headersFile = headersArg ?? join(here, /staging/.test(new URL(worker).hostname) ? 'headers.staging' : 'headers.prod');
  const {mismatches} = await compare({worker, buildDir, apiKey, headersFile});
  process.exit(mismatches.length ? 1 : 0);
}
