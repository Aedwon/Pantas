import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {webcrypto, createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
const scope = 'https://app.example/';
const source = readFileSync('web/pantas_sw.js', 'utf8');
function worker(network = async () => {throw Error('offline');}, {buildFiles = [], buildHashes = {}, legacyFiles = {}, timeout = 3000} = {}) {
  const handlers = {}, stores = new Map();
  const caches = {keys: async () => [...stores.keys()], delete: async n => stores.delete(n),
    open: async n => {if (!stores.has(n)) stores.set(n, new Map()); const m = stores.get(n); return {
      match: async r => m.get(typeof r === 'string' ? r : r.url)?.clone(),
      put: async (r, v) => m.set(typeof r === 'string' ? r : r.url, v.clone()),
    };}};
  let skips = 0;
  const self = {location: new URL(scope + 'pantas_sw.js'), registration: {scope},
    clients: {claim: async () => {}, matchAll: async () => []}, skipWaiting: async () => skips++,
    addEventListener: (n, f) => handlers[n] = f};
  vm.runInNewContext(source.replace("const STAMPED_VERSION = '';", "const STAMPED_VERSION = 'new';")
    .replace('const BUILD_FILES = [];', 'const BUILD_FILES = '+JSON.stringify(buildFiles)+';')
    .replace('const LEGACY_FILES = {};', 'const LEGACY_FILES = '+JSON.stringify(legacyFiles)+';')
    .replace('const BUILD_HASHES = {};', 'const BUILD_HASHES = '+JSON.stringify(buildHashes)+';')
    .replace('const NETWORK_TIMEOUT_MS = 3000;', 'const NETWORK_TIMEOUT_MS = '+timeout+';')
    .replace('const RETAINED_VERSIONS = [];', "const RETAINED_VERSIONS = ['new','old','older'];"),
    {self, caches, URL, Request, Response, crypto:webcrypto, fetch: network, setTimeout, clearTimeout});
  return {stores, caches, skips: () => skips, async dispatch(n, extra = {}, waitForJobs = true) {
    let response; const jobs = []; handlers[n]?.({...extra, waitUntil: p => jobs.push(p), respondWith: p => response = p});
    const result = await response; if(waitForJobs) await Promise.all(jobs); return result;
  }};
}
function basic(bytes, headers = {}, status = 200) {const r = new Response(bytes, {headers,status}); Object.defineProperty(r, 'type', {value:'basic'}); return r;}
test('cleanup keeps current and last two regardless of open clients', async () => {
  const w = worker(); for (const v of ['new','old','older','expired']) await w.caches.open('pantas-build-' + v);
  await w.dispatch('activate');
  assert.deepEqual([...w.stores.keys()].filter(n => n.startsWith('pantas-build-')).sort(), ['pantas-build-new','pantas-build-old','pantas-build-older']);
});
test('old cached deferred bytes never require page identity or a network round trip', async () => {
  const w = worker(async () => {throw Error('must use cache');});
  await (await w.caches.open('pantas-build-old')).put(scope+'b/old/x.part.js', basic('old'));
  assert.equal(await (await w.dispatch('fetch', {request:new Request(scope+'b/old/x.part.js')})).text(), 'old');
});
test('old cache miss fetches exact retained path, never current deployment path', async () => {
  const paths = []; const w = worker(async r => {paths.push(r.url); return basic(r.url.includes('/b/old/') ? 'old' : 'new');});
  assert.equal(await (await w.dispatch('fetch', {request:new Request(scope+'b/old/x.part.js')})).text(), 'old');
  assert.deepEqual(paths, [scope+'b/old/x.part.js']);
});
test('offline navigation and loader use cached root files', async () => {
  const w = worker(); const cache = await w.caches.open('pantas-root');
  await cache.put(scope+'index.html', basic('pinned old index', {'Content-Type':'text/html'}));
  await cache.put(scope+'flutter_bootstrap.js', basic('loader'));
  assert.equal(await (await w.dispatch('fetch', {request:new Request(scope+'index.html')})).text(), 'pinned old index');
  assert.equal(await (await w.dispatch('fetch', {request:new Request(scope+'flutter_bootstrap.js')})).text(), 'loader');
});
test('other origins, flat files, auth, ranges and no-store requests bypass worker', async () => {
  const w = worker();
  for (const request of [new Request('https://other.example/b/new/a'), new Request(scope+'main.dart.js'),
    new Request(scope+'b/new/a', {headers:{Authorization:'test'}}), new Request(scope+'b/new/a', {headers:{Range:'bytes=0-1'}}),
    new Request(scope+'version.json', {cache:'no-store'})]) assert.equal(await w.dispatch('fetch', {request}), undefined);
});
test('HTML rewrites and no-store responses never populate immutable cache', async () => {
  for (const headers of [{'Content-Type':'text/html'}, {'Cache-Control':'no-store'}]) {
    const w = worker(async () => basic('wrong', headers));
    await w.dispatch('fetch', {request:new Request(scope+'b/old/missing.js')});
    assert.equal(w.stores.get('pantas-build-old')?.size ?? 0, 0);
  }
});
function page({offline = false} = {}) {
  const calls = [], timers = [], events = {}; let reloads = 0;
  const document = {visibilityState:'visible', addEventListener:(n,f) => events[n]=f};
  const window = {document, addEventListener(){}, location:{reload:()=>reloads++}, performance:{mark(){}}};
  vm.runInNewContext(readFileSync('web/pantas_pwa.js','utf8'), {window, document, navigator:{}, URL, Promise, AbortController,
    setTimeout:(f,ms)=>{timers.push({f,ms});return timers.length;}, clearTimeout(){},
    fetch:async (url,options)=>{calls.push({url,options}); if(offline) throw Error('offline'); return {ok:true,json:async()=>({pantasBuildVersion:'new'})};}});
  return {window,calls,timers,events,reloads:()=>reloads};
}
test('check fetches no-store on each safe-point call without requiring service workers', async () => {
  const p=page(); await p.window.pantasPwa.registerWorker('old');
  for(let i=0;i<2;i++) {const s=await p.window.pantasUpdate.check();assert.equal(s.available,true);assert.equal(s.version,'new');}
  assert.equal(p.calls.length,2); assert.equal(p.calls[0].options.cache,'no-store'); assert.equal(p.reloads(),0);
});
test('failed checks can retry; apply reloads immediately without installation', async () => {
  const p=page({offline:true});await p.window.pantasPwa.registerWorker('old');
  await assert.rejects(p.window.pantasUpdate.check(), /offline/);
  await assert.rejects(p.window.pantasUpdate.check(), /offline/);
  await p.window.pantasUpdate.apply(); assert.equal(p.reloads(),1); assert.equal(p.calls.length,2);
});
test('visibility and five-minute checks never reload', async () => {
  const p=page();await p.window.pantasPwa.registerWorker('old');
  await p.events.visibilitychange(); await p.timers.find(t=>t.ms===300000).f();
  assert.equal(p.calls.length,2);assert.equal(p.reloads(),0);
});
test('Flutter bootstrap config pins all build URLs to its stamped version', async () => {
  const text=readFileSync('web/flutter_bootstrap.js','utf8').replace('{{flutter_js}}','').replace('{{flutter_build_config}}','')
    .replaceAll('{{flutter_service_worker_version}}','"current"');
  let options;
  vm.runInNewContext(text,{window:{pantasPwa:{registerWorker:async()=>{} }}, performance:{mark(){}}, _flutter:{loader:{load:o=>options=o}}});
  await new Promise(r=>setImmediate(r));
  assert.equal(options.config.entrypointBaseUrl,'/b/current/');assert.equal(options.config.assetBase,'/b/current/');
  assert.equal(options.config.canvasKitBaseUrl,'/b/current/canvaskit/');
});
test('reserved auth and wrapped paths bypass navigation caching', async () => {
  const w=worker();
  for(const path of ['__/auth/handler','__/auth/iframe','wrapped/share']) {
    const request=new Request(scope+path);Object.defineProperty(request,'mode',{value:'navigate'});
    assert.equal(await w.dispatch('fetch',{request}),undefined);
  }
});
const sha = bytes => createHash('sha256').update(bytes).digest('hex');
test('install refuses missing, HTML, private, no-store and wrong build bytes', async () => {
  for(const response of [new Response('missing',{status:404}), basic('html',{'Content-Type':'text/html'}),
    basic('main',{'Cache-Control':'private'}),basic('main',{'Cache-Control':'no-store'}),basic('wrong')]) {
    const w=worker(async r=>r.url.includes('/b/')?basic(await response.clone().text(),Object.fromEntries(response.headers),response.status):basic('<html data-pantas-build="new">',{'Content-Type':'text/html'}),
      {buildFiles:['main.dart.js'],buildHashes:{'main.dart.js':sha('main')}});
    await assert.rejects(w.dispatch('install'));assert.equal(w.skips(),0);
  }
});
test('installation caches complete matching build before activating', async () => {
  const w=worker(async r=>basic(r.url.includes('/b/')?'main':r.url.endsWith('index.html')?'<html data-pantas-build="new">':'root'),
    {buildFiles:['main.dart.js'],buildHashes:{'main.dart.js':sha('main')}});
  await w.dispatch('install');assert.equal(w.skips(),1);
  assert.ok(w.stores.get('pantas-root').has(scope+'index.html'));
});
test('deployment changing during install cannot replace cached complete index', async () => {
  const w=worker(async r=>basic(r.url.includes('/b/')?'main':r.url.endsWith('index.html')?'<html data-pantas-build="later">':'root'),
    {buildFiles:['main.dart.js'],buildHashes:{'main.dart.js':sha('main')}});
  const root=await w.caches.open('pantas-root');await root.put(scope+'index.html',basic('old complete index'));
  await assert.rejects(w.dispatch('install'));assert.equal(w.skips(),0);
  assert.equal(await w.stores.get('pantas-root').get(scope+'index.html').text(),'old complete index');
});
test('online index is served but offline fallback stays pinned to a complete cached build', async () => {
  const w=worker(async()=>basic('<html data-pantas-build="later">',{'Content-Type':'text/html'}));
  await (await w.caches.open('pantas-root')).put(scope+'index.html',basic('old complete index'));
  assert.match(await (await w.dispatch('fetch',{request:new Request(scope+'index.html')})).text(),/later/);
  assert.equal(await w.stores.get('pantas-root').get(scope+'index.html').text(),'old complete index');
});
test('a failed install with wrong successful bytes recovers on next install', async () => {
  let wrong=true;
  const w=worker(async r=>basic(r.url.includes('/b/')?(wrong?'wrong':'main'):r.url.endsWith('index.html')?'<html data-pantas-build="new">':'root'),
    {buildFiles:['main.dart.js'],buildHashes:{'main.dart.js':sha('main')}});
  await assert.rejects(w.dispatch('install'),/hash mismatch/);wrong=false;
  await w.dispatch('install');assert.equal(w.skips(),1);
});
test('verified legacy flat files remain available offline after takeover',async()=>{
 let offline=false;
 const w=worker(async r=>{if(offline)throw Error('offline');return basic(r.url.endsWith('x.part.js')?'legacy':r.url.endsWith('index.html')?'<html data-pantas-build="new">':'root');},
   {legacyFiles:{'main.dart.js_7.x.part.js':sha('legacy')}});
 await w.dispatch('install');await w.dispatch('activate');offline=true;
 assert.equal(await(await w.dispatch('fetch',{request:new Request(scope+'main.dart.js_7.x.part.js')})).text(),'legacy');
});
test('slow root network returns cached fallback after short timeout',async()=>{
 let resolve;
 const w=worker(()=>new Promise(r=>resolve=r),{timeout:5});
 await(await w.caches.open('pantas-root')).put(scope+'flutter_bootstrap.js',basic('cached loader'));
 const response=await w.dispatch('fetch',{request:new Request(scope+'flutter_bootstrap.js')},false);
 assert.equal(await response.text(),'cached loader');resolve(basic('fresh loader'));
});
test('a slow version check times out, then next safe point can retry',async()=>{
 const events={},timers=[];let hanging=true,calls=0;
 const document={visibilityState:'visible',addEventListener:(n,f)=>events[n]=f};
 const window={document,addEventListener(){},location:{reload(){}},performance:{mark(){}}};
 vm.runInNewContext(readFileSync('web/pantas_pwa.js','utf8'),{window,document,navigator:{},AbortController,Promise,
   setTimeout:(f,ms)=>{timers.push({f,ms});return timers.length;},clearTimeout(){},
   fetch:async()=>{calls++;return hanging?new Promise(()=>{}):{ok:true,json:async()=>({pantasBuildVersion:'new'})};}});
 await window.pantasPwa.registerWorker('old');
 const pending=window.pantasUpdate.check();
 assert.ok(timers.some(t=>t.ms===4000),'check must have a deadline');
 const rejected=assert.rejects(pending,/timed out/);timers.find(t=>t.ms===4000).f();await rejected;
 hanging=false;assert.equal((await window.pantasUpdate.check()).available,true);assert.equal(calls,2);
});
