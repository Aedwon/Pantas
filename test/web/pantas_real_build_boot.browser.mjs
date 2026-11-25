// Boots a REAL stamped Flutter build (build/web, made by the lead) in headless
// Chromium: online, then offline once the worker is active. Lists every off-origin
// request during boot and the b/<id>/ requests for drift_worker.js and sqlite3.wasm.
//   PW_MODULE=... node test/web/pantas_real_build_boot.browser.mjs [build/web]
// Not a *.test.mjs file, so `node --test` does not pick it up.
import {createServer} from 'node:http';
import {createRequire} from 'node:module';
import {readFileSync, statSync} from 'node:fs';
import {extname, join, resolve} from 'node:path';

const dir = resolve(process.argv[2] ?? 'build/web');
const {chromium} = createRequire(import.meta.url)(process.env.PW_MODULE);
const types = {'.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.json': 'application/json',
  '.wasm': 'application/wasm', '.png': 'image/png', '.otf': 'font/otf', '.ttf': 'font/ttf', '.bin': 'application/octet-stream'};
const state = {down: false, served: []};
const server = createServer((req, res) => {
  if (state.down) return req.socket.destroy();
  const path = new URL(req.url, 'http://x').pathname;
  state.served.push(path);
  let file = path === '/' ? 'index.html' : path.slice(1);
  let full = join(dir, decodeURIComponent(file));
  try { if (!statSync(full).isFile()) throw 0; } catch {
    if (extname(file)) { res.writeHead(404); return res.end(); }
    full = join(dir, 'index.html'); file = 'index.html';
  }
  res.writeHead(200, {'Content-Type': types[extname(file)] ?? 'application/octet-stream',
    'Cache-Control': path.startsWith('/b/') ? 'public, max-age=31536000, immutable' : 'no-cache'});
  res.end(readFileSync(full));
});
await new Promise(r => server.listen(0, '127.0.0.1', r));
const origin = `http://127.0.0.1:${server.address().port}`;
const browser = await chromium.launch({args: ['--use-mock-keychain', '--password-store=basic']});
const context = await browser.newContext();
const page = await context.newPage();
let phase = 'online';
const off = {online: new Set(), offline: new Set()};
const failedLocal = [];
page.on('request', r => { if (!r.url().startsWith(origin) && !r.url().startsWith('data:') && !r.url().startsWith('blob:')) off[phase].add(r.url()); });
context.on('request', r => { if (!r.url().startsWith(origin) && !r.url().startsWith('data:') && !r.url().startsWith('blob:')) off[phase].add(r.url()); });
page.on('requestfailed', r => { if (r.url().startsWith(origin)) failedLocal.push(`${phase} ${r.url()}`); });
page.on('console', m => { if (['error', 'warning'].includes(m.type())) console.log(`[${phase}] console ${m.type()}: ${m.text().slice(0, 200)}`); });
page.on('pageerror', e => console.log(`[${phase}] pageerror: ${e.message.slice(0, 200)}`));
const pause = ms => new Promise(r => setTimeout(r, ms));
const first = () => page.waitForFunction(() => !!document.querySelector('flt-glass-pane'), null, {timeout: 60000}).catch(async e => { console.log('no first frame; requests:', state.served.slice(-15).join(' '), 'failed:', failedLocal.join(' ')); throw e; });
const report = async label => {
  const info = await page.evaluate(() => ({
    glass: !!document.querySelector('flt-glass-pane'),
    controller: !!navigator.serviceWorker.controller,
    base: window.pantasBuildBase,
  }));
  console.log(label, JSON.stringify(info));
};

await page.goto(origin + '/');
await first();
await pause(3000);
console.log('asset requests:', [...new Set(state.served.filter(p => p.includes('assets/')))].join('\n  '));
await report('online first load');
await page.evaluate(() => navigator.serviceWorker.ready.then(() => true));
for (let i = 0; i < 60 && !(await page.evaluate(() => navigator.serviceWorker.controller !== null)); i++) await pause(500);
for (let i = 0; i < 120; i++) { // wait for the whole set to be stored
  if ((await page.evaluate(async () => { const k = await caches.keys(); return k.some(n => n.startsWith('pantas-build-')); }))) break;
  await pause(500);
}
await pause(2000);
await page.reload(); await first(); await report('online second load (worker controls)');
const folder = (state.served.find(p => /^\/b\/[^/]+\/main\.dart\.js$/.test(p)) ?? '').replace('main.dart.js', '');
console.log('build folder', folder);
const db = state.served.filter(p => p.endsWith('/drift_worker.js') || p.endsWith('/sqlite3.wasm') || p === '/drift_worker.js' || p === '/sqlite3.wasm');
console.log('db files requested (server log):', [...new Set(db)].join(', ') || 'none yet');

phase = 'offline';
state.down = true; state.served.length = 0;
await context.setOffline(true);
await page.reload(); await first(); await pause(5000);
await report('offline load');
const db2 = state.served;
console.log('offline: server saw', db2.length, 'requests');
// Which database files did the page ask for from the worker cache? Use the resource timing list.
const timing = await page.evaluate(() => performance.getEntriesByType('resource').map(e => e.name));
console.log('resource timing db files:', timing.filter(n => /drift_worker\.js|sqlite3\.wasm/.test(n)).join(', ') || 'none in page timing');
console.log('off-origin during online boot:', [...off.online].join('\n  ') || 'none');
console.log('off-origin during offline boot:', [...off.offline].join('\n  ') || 'none');
console.log('local request failures:', failedLocal.join('\n  ') || 'none');
await browser.close(); server.close();
