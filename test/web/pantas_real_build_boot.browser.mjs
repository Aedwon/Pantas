// Boots a REAL stamped Flutter build (made by the lead: flutter build web, then the stamp
// tool) in headless Chromium, with no connection beyond this one local server:
//
//   1. First visit. The worker installs and stores the build.
//   2. Empty the browser's HTTP cache, cut the server, and reload.
//   3. The app must start from the worker's storage alone: the Flutter engine is up, the
//      database is open ("boot.storage") and the app has started ("boot.runapp").
//
// Every off-origin request is blocked from the first request on, in both phases: no Firebase
// SDK from gstatic, no fonts from gstatic, no Google or Firebase endpoint of any project is
// ever reached (audit 2, new High "cold offline boot", Medium 9). The page's HTML marker or
// the Flutter engine element alone is not readiness: this reads the app's own boot marks.
//
//   PW_MODULE=/path/to/node_modules/playwright node test/web/pantas_real_build_boot.browser.mjs build/web
//
// Not a *.test.mjs file, so `node --test` does not pick it up. Exits 1 when the app does not
// become ready, and prints every off-origin address that was asked for and the boot marks.
import {createServer} from 'node:http';
import {createRequire} from 'node:module';
import {readFileSync, statSync} from 'node:fs';
import {extname, join, resolve} from 'node:path';
import {coldHttpCache} from './fixtures/browser_harness.mjs';

const dir = resolve(process.argv[2] ?? 'build/web');
const {chromium} = createRequire(import.meta.url)(process.env.PW_MODULE);
const types = {'.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.json': 'application/json',
  '.wasm': 'application/wasm', '.png': 'image/png', '.otf': 'font/otf', '.ttf': 'font/ttf', '.bin': 'application/octet-stream'};
const pause = ms => new Promise(done => setTimeout(done, ms));
const state = {down: false, served: []};
const server = createServer((request, response) => {
  if (state.down) return request.socket.destroy();
  const path = new URL(request.url, 'http://x').pathname;
  state.served.push(path);
  let file = path === '/' ? 'index.html' : path.slice(1);
  let full = join(dir, decodeURIComponent(file));
  try {
    if (!statSync(full).isFile()) throw new Error('not a file');
  } catch {
    if (extname(file)) { response.writeHead(404); return response.end(); }
    full = join(dir, 'index.html');
    file = 'index.html';
  }
  response.writeHead(200, {
    'Content-Type': types[extname(file)] ?? 'application/octet-stream',
    'Cache-Control': path.startsWith('/b/') ? 'public, max-age=31536000, immutable' : 'no-cache',
  });
  response.end(readFileSync(full));
});
await new Promise(done => server.listen(0, '127.0.0.1', done));
const origin = `http://127.0.0.1:${server.address().port}`;
const browser = await chromium.launch({args: ['--use-mock-keychain', '--password-store=basic']});
const context = await browser.newContext();
let phase = 'first visit';
const blocked = {'first visit': new Set(), 'cold offline': new Set()};
// Everything that is not this server, a data: URI or a blob: URL is refused, and noted.
await context.route('**/*', route => {
  const url = route.request().url();
  if (url.startsWith(origin) || url.startsWith('data:') || url.startsWith('blob:')) return route.continue();
  blocked[phase].add(url);
  return route.abort('blockedbyclient');
});
const page = await context.newPage();
page.on('console', message => {
  if (['error', 'warning'].includes(message.type())) console.log(`[${phase}] console ${message.type()}: ${message.text().slice(0, 200)}`);
});
page.on('pageerror', error => console.log(`[${phase}] pageerror: ${error.message.slice(0, 200)}`));

// The app's own readiness: the marks bootstrap.dart writes, and the engine's first element.
const readiness = () => page.evaluate(() => {
  const marks = new Set(performance.getEntriesByType('mark').map(entry => entry.name));
  return {
    engine: Boolean(document.querySelector('flt-glass-pane')),
    firebase: marks.has('boot.firebase'),
    storage: marks.has('boot.storage'),
    started: marks.has('boot.runapp'),
    marks: [...marks].filter(name => name.startsWith('boot.')).sort(),
    controller: Boolean(navigator.serviceWorker.controller),
  };
});
async function ready(label, seconds) {
  const end = Date.now() + seconds * 1000;
  let state_ = await readiness().catch(() => ({}));
  while (!(state_.engine && state_.storage && state_.started) && Date.now() < end) {
    await pause(500);
    state_ = await readiness().catch(() => state_);
  }
  console.log(`${label}: ${JSON.stringify(state_)}`);
  return Boolean(state_.engine && state_.storage && state_.started);
}

let failed = false;
try {
  await page.goto(origin + '/');
  // The first visit has no connection to Google either, so the app may not start; what must
  // happen is that the worker stores the whole build.
  const firstReady = await ready('first visit', 45);
  await page.evaluate(() => navigator.serviceWorker.ready.then(() => true));
  for (let i = 0; i < 240; i++) {
    const stored = await page.evaluate(async () => {
      const names = await caches.keys();
      return names.some(name => name.startsWith('pantas-build-')) && names.includes('pantas-meta');
    });
    if (stored) break;
    await pause(500);
  }
  console.log(`worker stored the build and is in charge (first visit ready: ${firstReady})`);

  phase = 'cold offline';
  await coldHttpCache(page);
  state.down = true;
  state.served.length = 0;
  await context.setOffline(true);
  await page.reload();
  const coldReady = await ready('cold offline', 90);
  console.log(`requests that reached the server while down: ${state.served.length}`);
  console.log(`off-origin requests blocked, first visit:\n  ${[...blocked['first visit']].join('\n  ') || 'none'}`);
  console.log(`off-origin requests blocked, cold offline:\n  ${[...blocked['cold offline']].join('\n  ') || 'none'}`);
  // The Firebase SDK is served from our own address (E-210): nothing may ask Google for it.
  const asked = [...blocked['first visit'], ...blocked['cold offline']].filter(url => /\/firebasejs\//.test(url));
  if (asked.length) {
    failed = true;
    console.log(`FAIL: the page still asked another address for the Firebase SDK:\n  ${asked.join('\n  ')}`);
  }
  if (!coldReady) {
    failed = true;
    console.log('FAIL: with a cold HTTP cache and every off-origin request blocked, the app did not become ready (engine, storage and start)');
  } else if (!failed) {
    console.log('PASS: the app and its storage are ready from the worker alone');
  }
} finally {
  await browser.close();
  server.close();
}
process.exit(failed ? 1 : 0);
