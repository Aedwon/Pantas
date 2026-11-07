// Run with: node --test test/web/pantas_splash.test.mjs
import test from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';

const require = createRequire(import.meta.url);
const { create, FADE_MS, GIVE_UP_MS, NEVER_STARTED_MS } = require('../../web/pantas_splash.js');

function setup({ welcomeShown = false, reduced = false } = {}) {
  const classes = new Set();
  const timers = [];
  const links = [];
  const loads = [];
  const frameListeners = [];
  const marks = [];
  let printed = 0;
  let splashRemoved = false;
  const doc = {
    head: { appendChild: (link) => links.push(link) },
    createElement: () => ({}),
    fonts: { load: (spec) => { loads.push(spec); return Promise.resolve([]); } },
    documentElement: {
      classList: {
        add: (...names) => names.forEach((n) => classes.add(n)),
        remove: (...names) => names.forEach((n) => classes.delete(n)),
      },
    },
    getElementById: (id) =>
      id === 'pantas-splash' && !splashRemoved
        ? { remove: () => (splashRemoved = true) }
        : null,
  };
  const splash = create({
    document: doc,
    welcome: { isShown: () => welcomeShown },
    setTimeout: (fn, ms) => timers.push({ fn, ms }),
    afterPaint: (fn) => fn(),
    reducedMotion: () => reduced,
    onFirstFrame: (fn) => frameListeners.push(fn),
    mark: (name) => marks.push(name),
    printTiming: () => printed++,
  });
  return {
    splash,
    classes,
    timers,
    links,
    loads,
    frameListeners,
    marks,
    printed: () => printed,
    removed: () => splashRemoved,
  };
}

test('a returning visitor sees the splash from the first paint', () => {
  const t = setup();
  assert.equal(t.splash.isShown(), true);
  assert.ok(t.classes.has('ps-on'));
  assert.equal(t.removed(), false);
  assert.equal(typeof t.splash.ready, 'function');
});

test('a first-time visitor never sees the splash and its markup is removed', () => {
  const t = setup({ welcomeShown: true });
  assert.equal(t.splash.isShown(), false);
  assert.ok(!t.classes.has('ps-on'));
  assert.equal(t.removed(), true);
  assert.equal(t.frameListeners.length, 0);
  assert.equal(t.links.length, 0);
  assert.equal(t.loads.length, 0);
});

test('Geist Bold is requested through the font API, with no preload link', () => {
  const t = setup();
  assert.equal(t.links.length, 0);
  assert.deepEqual(t.loads, ['700 42px Geist']);
});

test('ready data fades the splash out, then removes it', () => {
  const t = setup();
  t.splash.ready();
  assert.ok(t.classes.has('ps-out'));
  assert.equal(t.removed(), false);
  const fade = t.timers.find((x) => x.ms === FADE_MS);
  assert.ok(fade);
  fade.fn();
  assert.equal(t.removed(), true);
  assert.ok(!t.classes.has('ps-on'));
  assert.ok(!t.classes.has('ps-out'));
});

test('a screen under the splash can wait until the splash is gone (4P-2)', () => {
  const t = setup();
  let ran = 0;
  t.splash.afterGone(() => ran++);
  t.splash.ready();
  assert.equal(ran, 0, 'the splash is still fading');
  t.timers.find((x) => x.ms === FADE_MS).fn();
  assert.equal(ran, 1);
  t.splash.afterGone(() => ran++);
  assert.equal(ran, 2, 'asking after it left runs at once');
});

test('without a splash there is nothing to wait for', () => {
  const t = setup({ welcomeShown: true });
  let ran = 0;
  t.splash.afterGone(() => ran++);
  assert.equal(ran, 1);
});

test('a splash that gives up also releases the waiting screen', () => {
  const t = setup({ reduced: true });
  let ran = 0;
  t.splash.afterGone(() => ran++);
  t.timers.find((x) => x.ms === NEVER_STARTED_MS).fn();
  assert.equal(ran, 1);
});

test('reduced motion removes the splash at once, with no fade', () => {
  const t = setup({ reduced: true });
  t.splash.ready();
  assert.equal(t.removed(), true);
  assert.ok(!t.classes.has('ps-on'));
  assert.ok(!t.classes.has('ps-out'));
  assert.ok(!t.timers.some((x) => x.ms === FADE_MS));
});

test('a repeated ready signal does nothing more', () => {
  const t = setup();
  t.splash.ready();
  const count = t.timers.length;
  t.splash.ready();
  assert.equal(t.timers.length, count);
});

test('the splash gives up if the app never starts', () => {
  const t = setup({ reduced: true });
  const giveUp = t.timers.find((x) => x.ms === NEVER_STARTED_MS);
  assert.ok(giveUp);
  giveUp.fn();
  assert.equal(t.removed(), true);
});

test('a slow phone keeps the logo until the app has started', () => {
  const t = setup();
  assert.equal(t.timers.some((x) => x.ms === GIVE_UP_MS), false);
  t.splash.started();
  assert.equal(t.removed(), false);
  assert.ok(t.timers.some((x) => x.ms === GIVE_UP_MS));
});

test('a repeated start signal sets one limit', () => {
  const t = setup();
  t.splash.started();
  t.splash.started();
  assert.equal(t.timers.filter((x) => x.ms === GIVE_UP_MS).length, 1);
});

test('the page loads the splash script after the welcome script', () => {
  const html = readFileSync(new URL('../../web/index.html', import.meta.url), 'utf8');
  const welcome = html.indexOf('src="pantas_welcome.js"');
  const splash = html.indexOf('src="pantas_splash.js"');
  assert.ok(welcome > 0 && splash > welcome);
  assert.match(html, /id="pantas-splash"[^>]*aria-label="Pantas is loading"/);
});

test('the service worker stores the splash script', () => {
  const sw = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
  const precache = sw.slice(sw.indexOf('const PRECACHE'), sw.indexOf('];', sw.indexOf('const PRECACHE')));
  assert.ok(precache.includes("'pantas_splash.js'"));
});

test('the first frame leaves the splash while data is pending', () => {
  const t = setup();
  t.frameListeners.forEach((fn) => fn());
  assert.equal(t.removed(), false);
  assert.ok(!t.classes.has('ps-out'));
});
test('Home releases the logo at its first frame, before its data, with the same fade and limits', () => {
  const t = setup();
  t.splash.started();
  // Home calls ready once it has drawn the loading shapes. No data is needed.
  t.splash.ready();
  assert.ok(t.classes.has('ps-out'), 'the logo starts to fade over the shapes');
  assert.equal(t.removed(), false);
  const fade = t.timers.find((x) => x.ms === FADE_MS);
  assert.ok(fade, 'the fade is the same 400 ms');
  // The data arriving later calls nothing more on the splash.
  const timers = t.timers.length;
  t.splash.ready();
  assert.equal(t.timers.length, timers);
  fade.fn();
  assert.equal(t.removed(), true);
  assert.equal(GIVE_UP_MS, 8000);
  assert.equal(NEVER_STARTED_MS, 60000);
});

test('the limit after start is eight seconds and removes the splash without another fade', () => {
  const t = setup();
  assert.equal(GIVE_UP_MS, 8000);
  t.splash.started();
  t.timers.find((x) => x.ms === 8000).fn();
  assert.equal(t.removed(), true);
});

test('the hard limit also ends a fade that started just before the limit', () => {
  const t = setup();
  t.splash.started();
  t.splash.ready();
  assert.equal(t.removed(), false);
  t.timers.find((x) => x.ms === GIVE_UP_MS).fn();
  assert.equal(t.removed(), true);
});

test('the timeline gets splash.ready once, then splash.removed when the logo leaves', () => {
  const t = setup();
  assert.deepEqual(t.marks, []);
  t.splash.ready();
  t.splash.ready();
  assert.deepEqual(t.marks, ['splash.ready']);
  t.timers.find((x) => x.ms === FADE_MS).fn();
  assert.deepEqual(t.marks, ['splash.ready', 'splash.removed']);
  assert.equal(t.printed(), 1, 'the ?timing=1 table prints at removal');
});

test('a splash that gives up still marks its removal', () => {
  const t = setup({ reduced: true });
  t.timers.find((x) => x.ms === NEVER_STARTED_MS).fn();
  assert.deepEqual(t.marks, ['splash.removed']);
});

test('a first-time visit marks nothing from the splash', () => {
  const t = setup({ welcomeShown: true });
  t.splash.ready();
  assert.deepEqual(t.marks, []);
});

test('a failing mark or table never stops the splash', () => {
  const t = setup({ reduced: true });
  const splash = create({
    document: { documentElement: { classList: { add() {}, remove() {} } },
      getElementById: () => null },
    welcome: { isShown: () => false },
    setTimeout: () => {},
    afterPaint: (fn) => fn(),
    reducedMotion: () => true,
    mark: () => { throw new Error('no performance API'); },
    printTiming: () => { throw new Error('no console'); },
  });
  splash.ready();
  assert.equal(splash.state.gone, true);
  assert.ok(t);
});

test('the page marks page.helpers after the helper scripts and before the app starts', () => {
  const html = readFileSync(new URL('../../web/index.html', import.meta.url), 'utf8');
  const mark = html.indexOf("performance.mark('page.helpers')");
  assert.ok(mark > 0, 'page.helpers mark present');
  assert.ok(mark > html.indexOf('src="pantas_splash.js"'));
  assert.ok(mark < html.indexOf('</head>'));
  const bootstrap = readFileSync(new URL('../../web/flutter_bootstrap.js', import.meta.url), 'utf8');
  const loader = bootstrap.indexOf("performance.mark('page.loader')");
  assert.ok(loader > 0, 'page.loader mark present');
  assert.ok(loader < bootstrap.indexOf('_flutter.loader.load'));
});
