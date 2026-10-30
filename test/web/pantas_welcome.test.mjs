// Run with: node --test test/web/pantas_welcome.test.mjs
import test from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { create, SEEN_KEY, GIVE_UP_MS } = require('../../web/pantas_welcome.js');

function setup({ seen = false, wide = false, storageThrows = false } = {}) {
  const classes = new Set();
  const listeners = {};
  const timers = [];
  const store = new Map(seen ? [[SEEN_KEY, '1']] : []);
  const button = {
    html: 'Get Started',
    attrs: {},
    setAttribute(name, value) {
      this.attrs[name] = value;
    },
    set innerHTML(value) {
      this.html = value;
    },
    get innerHTML() {
      return this.html;
    },
  };
  let screenRemoved = false;
  const links = [];
  const doc = {
    head: { appendChild: (link) => links.push(link) },
    createElement: () => ({}),
    documentElement: {
      classList: {
        add: (name) => classes.add(name),
        remove: (name) => classes.delete(name),
      },
    },
    getElementById: (id) =>
      id === 'pw-start'
        ? button
        : id === 'pantas-welcome' && !screenRemoved
          ? { remove: () => (screenRemoved = true) }
          : null,
    addEventListener: (type, fn) => (listeners[type] = fn),
  };
  const storage = {
    getItem: (key) => {
      if (storageThrows) throw new Error('blocked');
      return store.get(key) ?? null;
    },
    setItem: (key, value) => {
      if (storageThrows) throw new Error('blocked');
      store.set(key, value);
    },
  };
  const welcome = create({
    document: doc,
    storage,
    setTimeout: (fn, ms) => timers.push({ fn, ms }),
    afterPaint: (fn) => fn(),
    wide: () => wide,
  });
  const tap = () =>
    listeners.click({ target: { closest: (sel) => (sel === '#pw-start' ? {} : null) } });
  return {
    welcome, classes, store, button, timers, links, tap, listeners,
    removed: () => screenRemoved,
  };
}

test('first visit shows the screen and preloads the three fonts', () => {
  const t = setup();
  assert.equal(t.welcome.isShown(), true);
  assert.ok(t.classes.has('pw-on'));
  assert.equal(t.links.length, 3);
  assert.ok(t.links.every((l) => l.href.startsWith('assets/assets/fonts/Geist-')));
});

test('returning visit never shows the screen', () => {
  const t = setup({ seen: true });
  assert.equal(t.welcome.isShown(), false);
  assert.ok(!t.classes.has('pw-on'));
  assert.equal(t.links.length, 0);
  t.welcome.ready(true);
  assert.equal(t.removed(), false);
});

test('app ready with a hold keeps the screen until Get Started', () => {
  const t = setup();
  t.welcome.ready(true);
  assert.ok(t.classes.has('pw-on'));
  t.tap();
  assert.ok(!t.classes.has('pw-on'));
  assert.equal(t.removed(), true);
  assert.equal(t.store.get(SEEN_KEY), '1');
  assert.equal(t.button.attrs['aria-busy'], undefined);
});

test('Get Started before the app is ready shows Starting, then hands over', () => {
  const t = setup();
  t.tap();
  assert.ok(t.classes.has('pw-on'));
  assert.equal(t.button.attrs['aria-busy'], 'true');
  assert.match(t.button.html, /Starting…/);
  t.welcome.ready(true);
  assert.ok(!t.classes.has('pw-on'));
  assert.equal(t.removed(), true);
});

test('a learner who is already set up skips the screen without a tap', () => {
  const t = setup();
  t.welcome.ready(false);
  assert.ok(!t.classes.has('pw-on'));
  assert.equal(t.store.get(SEEN_KEY), '1');
});

test('the tap is remembered even if the app never gets ready', () => {
  const t = setup();
  t.tap();
  assert.equal(t.store.get(SEEN_KEY), '1');
  assert.equal(t.timers[0].ms, GIVE_UP_MS);
  t.timers[0].fn();
  assert.ok(!t.classes.has('pw-on'));
});

test('a second tap changes nothing', () => {
  const t = setup();
  t.tap();
  t.button.html = 'unchanged';
  t.tap();
  assert.equal(t.button.html, 'unchanged');
  assert.equal(t.timers.length, 1);
});

test('Enter starts only on wide screens', () => {
  const phone = setup({ wide: false });
  phone.listeners.keydown({ key: 'Enter' });
  assert.equal(phone.welcome.state.started, false);
  const desktop = setup({ wide: true });
  desktop.listeners.keydown({ key: 'Enter' });
  assert.equal(desktop.welcome.state.started, true);
});

test('blocked storage still shows the screen and never throws', () => {
  const t = setup({ storageThrows: true });
  assert.equal(t.welcome.isShown(), true);
  t.welcome.ready(true);
  t.tap();
  assert.equal(t.removed(), true);
});
