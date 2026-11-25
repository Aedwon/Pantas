// Shared pieces of the real-browser service worker tests (headless Chromium, a
// local static server, fixture builds from sw_fixture_build.mjs; no Flutter build
// and no hosted calls). Used by pantas_sw_rollout.browser.mjs and
// pantas_sw_blockers.browser.mjs.
//
//   PW_MODULE=/path/to/node_modules/playwright node test/web/pantas_sw_rollout.browser.mjs
//
// Chromium is launched with --use-mock-keychain and --password-store=basic, and
// closed when the run ends.
import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {createRequire} from 'node:module';
import {mkdtempSync, readFileSync, rmSync, statSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {dirname, extname, join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {constantOf, writeBuild} from './sw_fixture_build.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
export const pause = ms => new Promise(done => setTimeout(done, ms));

const types = {
  '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm',
  '.png': 'image/png', '.otf': 'font/otf', '.ttf': 'font/ttf', '.bin': 'application/octet-stream',
};
// Like the Cloudflare headers: build folders never change, root files revalidate,
// and today's root files in folders and the root images and wasm cache for an hour.
const cacheFor = path => {
  if (path.startsWith('/b/')) return 'public, max-age=31536000, immutable';
  const hour = path.startsWith('/assets/') || path.startsWith('/icons/') || path === '/sqlite3.wasm' || path === '/favicon.png';
  return hour ? 'max-age=3600' : 'no-cache';
};

/**
 * Starts the server and the browser. `specs` is {name: [id, options]}: each is a
 * fixture build (options.prod keeps today's production worker, helper and bootstrap).
 * The returned `state` is what a test changes while it runs:
 *   state.build        the build the server serves
 *   state.down         true cuts every connection
 *   state.delays       [{when(path, headers), ms}] hold matching responses back
 *   state.afterServe   [{when(path, headers), run()}] runs just after a response is sent
 */
export async function start(specs) {
  const {chromium} = createRequire(import.meta.url)(process.env.PW_MODULE ?? join(root, 'build/pw/node_modules/playwright'));
  const scratch = mkdtempSync(join(tmpdir(), 'sw-browser-'));
  const dirs = {};
  const served = {};
  for (const [name, [id, options]] of Object.entries(specs)) {
    dirs[name] = join(scratch, name);
    served[name] = writeBuild(dirs[name], id, options);
  }
  const state = {build: Object.keys(specs)[0], down: false, delays: [], afterServe: [], requests: []};
  const server = createServer(async (request, response) => {
    if (state.down) return request.socket.destroy();
    const path = new URL(request.url, 'http://x').pathname;
    state.requests.push({path, dest: request.headers['sec-fetch-dest'], build: state.build});
    let file = path === '/' ? 'index.html' : path.slice(1);
    let full = join(dirs[state.build], file);
    try {
      if (!statSync(full).isFile()) throw new Error();
    } catch {
      if (extname(file)) { response.writeHead(404); return response.end(); }
      full = join(dirs[state.build], 'index.html'); // single-page rewrite
      file = 'index.html';
    }
    for (const delay of state.delays) if (delay.when(path, request.headers)) await pause(delay.ms);
    if (state.down) return request.socket.destroy();
    response.writeHead(200, {
      'Content-Type': types[extname(file)] ?? 'application/octet-stream',
      'Cache-Control': cacheFor(path),
    });
    response.end(readFileSync(full), () => {
      for (const hook of state.afterServe) if (hook.when(path, request.headers)) hook.run();
    });
  });
  await new Promise(done => server.listen(0, '127.0.0.1', done));
  const base = `http://127.0.0.1:${server.address().port}/`;
  const browser = await chromium.launch({args: ['--use-mock-keychain', '--password-store=basic']});
  const results = [];
  let failed = 0;

  // One scenario runs in a fresh browser context, so no storage carries over.
  async function scenario(name, run) {
    const context = await browser.newContext();
    state.down = false;
    state.delays = [];
    state.afterServe = [];
    try {
      await run(context);
      results.push(`ok   ${name}`);
    } catch (error) {
      failed++;
      results.push(`FAIL ${name}: ${error.message}`);
    } finally {
      state.down = false;
      await context.close();
    }
  }

  async function finish() {
    await browser.close();
    server.close();
    rmSync(scratch, {recursive: true, force: true});
    console.log(results.join('\n'));
    console.log(failed ? `${failed} scenario(s) failed` : 'all scenarios passed');
    process.exit(failed ? 1 : 0);
  }

  return {base, state, scenario, finish, constant: name => constantOf(served[name]), served};
}

/** The builds the boot files of this page load came from, and whether the app started. */
export async function bootOf(page, {timeout = 15000} = {}) {
  // A page may reload itself once before it boots (a takeover), so ask again until the
  // time is up instead of waiting inside one document.
  const end = Date.now() + timeout;
  let log = [];
  for (;;) {
    log = await page.evaluate(() => window.__boot || []).catch(() => []);
    if (log.some(entry => entry.endsWith(':part'))) break;
    if (Date.now() > end) break;
    await pause(100);
  }
  const booted = log.some(entry => entry.endsWith(':part'));
  return {booted, log, builds: [...new Set(log.map(entry => entry.split(':')[0]))]};
}

/** Asserts a load is all one build, or did not boot; returns the load. */
export function oneBuild(load, label, expected) {
  assert.ok(load.builds.length <= 1, `${label}: boot files from ${load.builds.join(' and ')}: ${load.log.join(' ')}`);
  if (load.booted) assert.equal(load.log.length, 5, `${label}: expected 5 boot files, got ${load.log.join(' ')}`);
  if (expected === null) assert.equal(load.booted, false, `${label}: expected no boot, got ${load.log.join(' ')}`);
  else if (expected !== undefined) assert.deepEqual(load.builds, [expected], `${label}: ${load.log.join(' ')}`);
  return load;
}

export const controlled = page => page.waitForFunction(() => navigator.serviceWorker.controller !== null, null, {timeout: 20000});
export const settle = page => page.evaluate(() => navigator.serviceWorker.ready.then(() => true));

/** Goes to the page, tolerating a network that is down (no boot, no error). */
export async function open(page, url, label, {reload = false, timeout} = {}) {
  try {
    await (reload ? page.reload({timeout: timeout ?? 15000}) : page.goto(url, {timeout: timeout ?? 15000}));
  } catch {
    return {booted: false, log: [], builds: []};
  }
  return bootOf(page, {timeout: timeout ? Math.min(timeout, 8000) : 8000});
}

/** The service worker state as the page sees it: waiting, active and the caches. */
export const workerState = page => page.evaluate(async () => {
  const registration = await navigator.serviceWorker.getRegistration();
  return {
    waiting: Boolean(registration && registration.waiting),
    installing: Boolean(registration && registration.installing),
    active: Boolean(registration && registration.active),
    caches: (await caches.keys()).sort(),
  };
});

export async function waitFor(check, label, {timeout = 30000, every = 200} = {}) {
  const end = Date.now() + timeout;
  for (;;) {
    const value = await check();
    if (value) return value;
    if (Date.now() > end) throw new Error(`timed out waiting for ${label}`);
    await pause(every);
  }
}
