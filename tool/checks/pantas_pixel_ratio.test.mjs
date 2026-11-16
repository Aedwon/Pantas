// Run with: node --test tool/checks/pantas_pixel_ratio.test.mjs
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';

const require = createRequire(import.meta.url);
const {chooseRatio, isStagingHost, parseOverride, install, DEFAULT_CAP, PARAM, STORE_KEY} =
  require('../../web/pantas_pixel_ratio.js');

const PROD = 'app.pantas.study';
const STAGING = 'staging.pantas.study';

test('the default cap is 2.5', () => {
  assert.equal(DEFAULT_CAP, 2.5);
});

test('a coarse pointer above the cap is capped', () => {
  assert.equal(chooseRatio({native: 3, coarse: true, host: PROD}), 2.5);
  assert.equal(chooseRatio({native: 4, coarse: true, host: PROD}), 2.5);
});

test('a coarse pointer at or below the cap is untouched', () => {
  assert.equal(chooseRatio({native: 2, coarse: true, host: PROD}), 2);
  assert.equal(chooseRatio({native: 2.5, coarse: true, host: PROD}), 2.5);
  assert.equal(chooseRatio({native: 1.5, coarse: true, host: PROD}), 1.5);
});

test('a fine pointer is never capped', () => {
  assert.equal(chooseRatio({native: 3, coarse: false, host: PROD}), 3);
  assert.equal(chooseRatio({native: 2, coarse: false, host: PROD}), 2);
});

test('a broken native value passes through', () => {
  assert.equal(chooseRatio({native: 0, coarse: true, host: PROD}), 0);
  assert.ok(Number.isNaN(chooseRatio({native: NaN, coarse: true, host: PROD})));
});

test('only staging hosts are staging', () => {
  assert.equal(isStagingHost('staging.pantas.study'), true);
  assert.equal(isStagingHost('pantas-staging.web.app'), true);
  assert.equal(isStagingHost('pantas-staging-app.web.app'), true);
  assert.equal(isStagingHost('app.pantas.study'), false);
  assert.equal(isStagingHost('pantas.study'), false);
  assert.equal(isStagingHost('localhost'), false);
  assert.equal(isStagingHost('staging.pantas.study.evil.com'), false);
  assert.equal(isStagingHost('evil-pantas-staging.web.app'), false);
  assert.equal(isStagingHost('pantas-staging.web.app.evil.com'), false);
  assert.equal(isStagingHost(''), false);
  assert.equal(isStagingHost(undefined), false);
});

test('parameter values', () => {
  assert.equal(parseOverride('2'), 2);
  assert.equal(parseOverride('2.5'), 2.5);
  assert.equal(parseOverride('3'), Infinity);
  assert.equal(parseOverride('4'), Infinity);
  for (const bad of ['', 'abc', '0', '-1', '0.5', 'NaN', 'Infinity', null, undefined]) {
    assert.equal(parseOverride(bad), null, String(bad));
  }
});

test('on staging the parameter picks the cap', () => {
  assert.equal(chooseRatio({native: 3, coarse: true, host: STAGING, param: '3'}), 3);
  assert.equal(chooseRatio({native: 3, coarse: true, host: STAGING, param: '2'}), 2);
  assert.equal(chooseRatio({native: 3, coarse: true, host: STAGING, param: '2.5'}), 2.5);
});

test('on staging the stored choice applies when there is no parameter', () => {
  assert.equal(chooseRatio({native: 3, coarse: true, host: STAGING, stored: '2'}), 2);
  assert.equal(chooseRatio({native: 3, coarse: true, host: STAGING, stored: '3'}), 3);
});

test('on staging the parameter beats the stored choice', () => {
  assert.equal(
    chooseRatio({native: 3, coarse: true, host: STAGING, param: '3', stored: '2'}), 3);
});

test('on staging a bad parameter falls back to the stored choice, then the default', () => {
  assert.equal(
    chooseRatio({native: 3, coarse: true, host: STAGING, param: 'x', stored: '2'}), 2);
  assert.equal(chooseRatio({native: 3, coarse: true, host: STAGING, param: 'x'}), 2.5);
});

test('prod ignores the parameter and the stored choice', () => {
  assert.equal(chooseRatio({native: 3, coarse: true, host: PROD, param: '3'}), 2.5);
  assert.equal(chooseRatio({native: 3, coarse: true, host: PROD, stored: '3'}), 2.5);
  assert.equal(chooseRatio({native: 3, coarse: true, host: 'localhost', param: '3'}), 2.5);
});

test('a parameter never lifts the ratio above the native one', () => {
  assert.equal(chooseRatio({native: 2, coarse: true, host: STAGING, param: '2.5'}), 2);
});

test('a fine pointer ignores the parameter', () => {
  assert.equal(chooseRatio({native: 3, coarse: false, host: STAGING, param: '2'}), 3);
});

function fakeWindow({native = 3, coarse = true, host = PROD, search = '', stored = {}, storageThrows = false} = {}) {
  const store = new Map(Object.entries(stored));
  const win = {
    nativeRatio: native,
    coarse,
    location: {hostname: host, search},
    matchMedia(query) {
      assert.equal(query, '(pointer: coarse)');
      return {get matches() { return win.coarse; }};
    },
    sessionStorage: {
      getItem(key) { if (storageThrows) throw new Error('blocked'); return store.get(key) ?? null; },
      setItem(key, value) { if (storageThrows) throw new Error('blocked'); store.set(key, value); },
    },
    store,
  };
  Object.defineProperty(win, 'devicePixelRatio', {
    get() { return this.nativeRatio; },
    configurable: true,
  });
  return win;
}

test('install caps the live value and follows later changes', () => {
  const win = fakeWindow({native: 3});
  install(win);
  assert.equal(win.devicePixelRatio, 2.5);
  win.nativeRatio = 4;
  assert.equal(win.devicePixelRatio, 2.5);
  win.nativeRatio = 2;
  assert.equal(win.devicePixelRatio, 2);
  win.nativeRatio = 3;
  assert.equal(win.devicePixelRatio, 2.5);
});

test('install follows the pointer type live', () => {
  const win = fakeWindow({native: 3, coarse: false});
  install(win);
  assert.equal(win.devicePixelRatio, 3);
  win.coarse = true;
  assert.equal(win.devicePixelRatio, 2.5);
});

test('install leaves a desktop untouched', () => {
  const win = fakeWindow({native: 3, coarse: false});
  install(win);
  assert.equal(win.devicePixelRatio, 3);
});

test('install on staging stores the parameter and uses it', () => {
  const win = fakeWindow({host: STAGING, search: `?${PARAM}=3`});
  install(win);
  assert.equal(win.devicePixelRatio, 3);
  assert.equal(win.store.get(STORE_KEY), '3');
});

test('install on staging reuses the stored choice after the address is rewritten', () => {
  const win = fakeWindow({host: STAGING, search: '', stored: {[STORE_KEY]: '2'}});
  install(win);
  assert.equal(win.devicePixelRatio, 2);
});

test('install on prod ignores and does not store the parameter', () => {
  const win = fakeWindow({host: PROD, search: `?${PARAM}=3`});
  install(win);
  assert.equal(win.devicePixelRatio, 2.5);
  assert.equal(win.store.size, 0);
});

test('install on staging survives blocked storage', () => {
  const win = fakeWindow({host: STAGING, search: `?${PARAM}=3`, storageThrows: true});
  install(win);
  assert.equal(win.devicePixelRatio, 3);
});

test('install does nothing without matchMedia', () => {
  const win = fakeWindow();
  win.matchMedia = undefined;
  install(win);
  assert.equal(win.devicePixelRatio, 3);
});

const read = path => readFileSync(new URL(`../../${path}`, import.meta.url), 'utf8');

test('the page loads the script before the Flutter bootstrap', () => {
  const html = read('web/index.html');
  const ratio = html.indexOf('src="pantas_pixel_ratio.js"');
  assert.ok(ratio > 0);
  assert.ok(ratio < html.indexOf('src="flutter_bootstrap.js"'));
  assert.ok(!/<script[^>]*pantas_pixel_ratio[^>]*(async|defer)/.test(html));
});

test('the service worker stores and refreshes the script', () => {
  const sw = read('web/pantas_sw.js');
  assert.equal(sw.split("'pantas_pixel_ratio.js'").length - 1, 2);
});
