// Run with: node --test test/web/pantas_splash.test.mjs
import test from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';

const require = createRequire(import.meta.url);
const { create, FADE_MS, GIVE_UP_MS } = require('../../web/pantas_splash.js');

function setup({ welcomeShown = false, reduced = false } = {}) {
  const classes = new Set();
  const timers = [];
  const links = [];
  const frameListeners = [];
  let splashRemoved = false;
  const doc = {
    head: { appendChild: (link) => links.push(link) },
    createElement: () => ({}),
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
  });
  return {
    splash,
    classes,
    timers,
    links,
    frameListeners,
    removed: () => splashRemoved,
  };
}

test('a returning visitor sees the splash from the first paint', () => {
  const t = setup();
  assert.equal(t.splash.isShown(), true);
  assert.ok(t.classes.has('ps-on'));
  assert.equal(t.removed(), false);
  assert.equal(t.frameListeners.length, 1);
});

test('a first-time visitor never sees the splash and its markup is removed', () => {
  const t = setup({ welcomeShown: true });
  assert.equal(t.splash.isShown(), false);
  assert.ok(!t.classes.has('ps-on'));
  assert.equal(t.removed(), true);
  assert.equal(t.frameListeners.length, 0);
  assert.equal(t.links.length, 0);
});

test('Geist Bold is preloaded for a returning visitor only', () => {
  const t = setup();
  assert.equal(t.links.length, 1);
  assert.equal(t.links[0].rel, 'preload');
  assert.equal(t.links[0].as, 'font');
  assert.equal(t.links[0].href, 'assets/assets/fonts/Geist-Bold.ttf');
});

test('the first frame fades the splash out, then removes it', () => {
  const t = setup();
  t.frameListeners[0]();
  assert.ok(t.classes.has('ps-out'));
  assert.equal(t.removed(), false);
  const fade = t.timers.find((x) => x.ms === FADE_MS);
  assert.ok(fade);
  fade.fn();
  assert.equal(t.removed(), true);
  assert.ok(!t.classes.has('ps-on'));
  assert.ok(!t.classes.has('ps-out'));
});

test('reduced motion removes the splash at once, with no fade', () => {
  const t = setup({ reduced: true });
  t.frameListeners[0]();
  assert.equal(t.removed(), true);
  assert.ok(!t.classes.has('ps-on'));
  assert.ok(!t.classes.has('ps-out'));
  assert.ok(!t.timers.some((x) => x.ms === FADE_MS));
});

test('a repeated first-frame signal does nothing more', () => {
  const t = setup();
  t.frameListeners[0]();
  const count = t.timers.length;
  t.frameListeners[0]();
  assert.equal(t.timers.length, count);
});

test('the splash gives up if the first frame never comes', () => {
  const t = setup({ reduced: true });
  const giveUp = t.timers.find((x) => x.ms === GIVE_UP_MS);
  assert.ok(giveUp);
  giveUp.fn();
  assert.equal(t.removed(), true);
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
