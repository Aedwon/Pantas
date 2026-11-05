// Run with: node --test test/web/pantas_welcome.test.mjs
import test from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { create, SEEN_KEY, GIVE_UP_MS } = require('../../web/pantas_welcome.js');

function setup({ seen = false, wide = false, storageThrows = false, path = '/', onWindow = false } = {}) {
  const classes = new Set();
  const listeners = {};
  const captures = {};
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
  const fontLoads = [];
  const body = {};
  const doc = {
    body,
    activeElement: body,
    fonts: { load: (spec) => { fontLoads.push(spec); return Promise.resolve([]); } },
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
    addEventListener: (type, fn, capture) => {
      listeners[type] = fn;
      captures[type] = capture === true;
    },
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
  const windowListeners = {};
  const windowCaptures = {};
  const keyTarget = {
    addEventListener: (type, fn, capture) => {
      windowListeners[type] = fn;
      windowCaptures[type] = capture === true;
    },
  };
  const welcome = create({
    document: doc,
    ...(onWindow ? { keyTarget } : {}),
    storage,
    setTimeout: (fn, ms) => timers.push({ fn, ms }),
    afterPaint: (fn) => fn(),
    wide: () => wide,
    pathname: () => path,
  });
  const tap = () =>
    listeners.click({ target: { closest: (sel) => (sel === '#pw-start' ? {} : null) } });
  return {
    welcome, classes, store, button, timers, fontLoads, tap, listeners, captures, doc, body,
    windowListeners, windowCaptures,
    removed: () => screenRemoved,
  };
}

test('first visit shows the screen and loads the three fonts without a preload link', () => {
  const t = setup();
  assert.equal(t.welcome.isShown(), true);
  assert.ok(t.classes.has('pw-on'));
  assert.deepEqual(t.fontLoads, ['400 16px Geist', '600 16px Geist', '700 16px Geist']);
  assert.equal(t.doc.head, undefined, 'no link element is added to the head');
});

test('returning visit never shows the screen', () => {
  const t = setup({ seen: true });
  assert.equal(t.welcome.isShown(), false);
  assert.ok(!t.classes.has('pw-on'));
  assert.equal(t.fontLoads.length, 0);
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

test('Enter is heard ahead of Flutter and kept from the app underneath', () => {
  const t = setup({ wide: true });
  assert.equal(t.captures.keydown, true);
  const event = {
    key: 'Enter',
    prevented: false,
    stopped: false,
    preventDefault() {
      this.prevented = true;
    },
    stopPropagation() {
      this.stopped = true;
    },
  };
  t.listeners.keydown(event);
  assert.equal(t.welcome.state.started, true);
  assert.equal(event.prevented && event.stopped, true);
  t.welcome.ready(false);
  const later = { key: 'Enter', stopped: false, stopPropagation() { this.stopped = true; } };
  t.listeners.keydown(later);
  assert.equal(later.stopped, false, 'once the screen has gone the app gets Enter');
});

test('blocked storage still shows the screen and never throws', () => {
  const t = setup({ storageThrows: true });
  assert.equal(t.welcome.isShown(), true);
  t.welcome.ready(true);
  t.tap();
  assert.equal(t.removed(), true);
});

test('a guardian link never shows the Welcome screen, on a first visit', () => {
  for (const path of ['/guardian', '/guardian/', '/guardian/waiting']) {
    const t = setup({ path });
    assert.equal(t.welcome.isShown(), false, path);
    assert.ok(!t.classes.has('pw-on'), path);
    assert.equal(t.fontLoads.length, 0, path);
    assert.equal(t.store.get(SEEN_KEY), undefined, 'the guardian visit is not remembered as a student visit');
  }
  assert.equal(setup({ path: '/guardianship' }).welcome.isShown(), true);
  assert.equal(setup({ path: '/' }).welcome.isShown(), true);
});

test('Enter is heard on the window, ahead of Flutter, and kept from it entirely', () => {
  // Flutter's own key handling stops Enter before it reaches the document
  // while its hidden text input has focus, so a document listener never hears
  // the first Enter. The window is reached first.
  const t = setup({ wide: true, onWindow: true });
  assert.equal(t.windowCaptures.keydown, true);
  assert.equal(t.listeners.keydown, undefined, 'nothing waits on the document');
  const event = {
    key: 'Enter',
    prevented: false,
    immediate: false,
    preventDefault() {
      this.prevented = true;
    },
    stopImmediatePropagation() {
      this.immediate = true;
    },
  };
  t.windowListeners.keydown(event);
  assert.equal(t.welcome.state.started, true);
  assert.equal(event.prevented && event.immediate, true);
});

test('a legal link never shows the Welcome screen, on a first visit', () => {
  for (const path of ['/legal/terms', '/legal/privacy', '/legal/']) {
    const t = setup({ path });
    assert.equal(t.welcome.isShown(), false, path);
    assert.ok(!t.classes.has('pw-on'), path);
    assert.equal(t.fontLoads.length, 0, path);
    assert.equal(t.store.get(SEEN_KEY), undefined, 'a legal visit is not remembered as a student visit');
  }
  assert.equal(setup({ path: '/legalese' }).welcome.isShown(), true);
});

test('when the cover leaves, focus goes back to the app field it was on', () => {
  const t = setup({ wide: true });
  let focused = 0;
  const field = { isConnected: true, focus: () => { focused += 1; t.doc.activeElement = field; } };
  t.listeners.focusin({ target: field });
  t.welcome.ready(true);
  // WebKit drops focus to the page when the cover is removed.
  t.doc.activeElement = t.body;
  t.listeners.keydown({ key: 'Enter' });
  assert.equal(t.removed(), true);
  assert.ok(focused >= 1, 'the field was focused again');
  assert.equal(t.doc.activeElement, field);
});

test('focus is left alone when the app already holds it, or the field is gone', () => {
  const kept = setup();
  let calls = 0;
  const field = { isConnected: true, focus: () => { calls += 1; } };
  kept.listeners.focusin({ target: field });
  kept.doc.activeElement = field;
  kept.welcome.ready(true);
  kept.tap();
  assert.equal(calls, 0);
  const gone = setup();
  const old = { isConnected: false, focus: () => { calls += 1; } };
  gone.listeners.focusin({ target: old });
  gone.welcome.ready(true);
  gone.tap();
  assert.equal(calls, 0);
  const cover = setup();
  cover.listeners.focusin({ target: { closest: (sel) => (sel === '#pantas-welcome' ? {} : null), isConnected: true, focus: () => { calls += 1; } } });
  cover.welcome.ready(true);
  cover.tap();
  assert.equal(calls, 0, 'the cover itself is never remembered');
});

// Board "e B": the Welcome screen, the splash and the app's first frame share
// the app background, so the handover shows no jump of color.
import { readFileSync } from 'node:fs';

test('Welcome, splash and the first app frame share one background in both themes', () => {
  const html = readFileSync(new URL('../../web/index.html', import.meta.url), 'utf8');
  const colors = readFileSync(new URL('../../lib/core/ui/theme/pantas_colors.dart', import.meta.url), 'utf8');
  const token = (name) => {
    const at = colors.indexOf(`static const ${name} = PantasColors(`);
    const m = /background: Color\(0xFF([0-9A-F]{6})\)/.exec(colors.slice(at));
    return `#${m[1]}`;
  };
  const light = token('light');
  const dark = token('dark');
  assert.equal(light, '#F5F5F7');
  assert.equal(dark, '#151515');
  const lightCss = html.replace(/@media \(prefers-color-scheme: dark\) \{(?:[^{}]|\{[^{}]*\})*\}/g, '');
  const darkBlocks = [...html.matchAll(/@media \(prefers-color-scheme: dark\) \{((?:[^{}]|\{[^{}]*\})*)\}/g)].map((m) => m[1]).join('\n');
  const bg = (css, selector) => {
    const m = new RegExp(`${selector}\\s*\\{[^}]*?--bg:\\s*(#[0-9A-Fa-f]{6})`).exec(css);
    return m && m[1].toUpperCase();
  };
  assert.equal(bg(lightCss, '#pantas-welcome'), light);
  assert.equal(bg(lightCss, '#pantas-splash'), light);
  assert.equal(bg(darkBlocks, '#pantas-welcome'), dark);
  assert.equal(bg(darkBlocks, '#pantas-splash'), dark);
  assert.match(lightCss, new RegExp(`html\\.pw-on \\{ background: ${light}; \\}`));
  assert.match(darkBlocks, new RegExp(`html\\.pw-on \\{ background: ${dark}; \\}`));
  assert.match(lightCss, new RegExp(`html \\{ background: ${light}; \\}`));
  assert.match(darkBlocks, new RegExp(`html \\{ background: ${dark}; \\}`));
});

test('on a short window the Welcome stack starts near the top, clear of the button (3M-15)', () => {
  const html = readFileSync(new URL('../../web/index.html', import.meta.url), 'utf8');
  const rule = /@media \(max-width: 1023px\) and \(max-height: 560px\) \{([^}]*\{[^}]*\}[^}]*)\}/.exec(html);
  assert.ok(rule, 'a short-window rule exists');
  assert.match(rule[1], /\.pw-body \{ padding-top: 28px;/);
  // The phone rule it overrides pins the button 34 px above the bottom and
  // starts the stack at 180 px. 28 + 72 + 20 + 38 + 10 + 50 = 218 clears a
  // 450 px window's button top (450 - 34 - 52 = 364).
  assert.ok(28 + 72 + 20 + 38 + 10 + 50 < 450 - 34 - 52);
});

// 6U-1: WebKit on a phone lays a page without a viewport tag out 980 px wide
// and scaled down, so the Welcome logo showed small near the top, then jumped
// when Flutter added its own tag. The page declares the same tag up front.
test('index.html declares the viewport Flutter writes, before any stylesheet', () => {
  const html = readFileSync(new URL('../../web/index.html', import.meta.url), 'utf8');
  const tag = /<meta name="viewport" content="([^"]*)">/.exec(html);
  assert.ok(tag, 'a viewport tag exists');
  assert.equal(
    tag[1],
    'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no',
  );
  assert.ok(html.indexOf(tag[0]) < html.indexOf('<style>'));
  assert.ok(html.indexOf(tag[0]) < html.indexOf('pantas_welcome.js'));
});

test('onLeave runs once when the screen leaves, and at once if it already has', () => {
  const t = setup();
  let calls = 0;
  t.welcome.onLeave(() => calls++);
  t.welcome.ready(true);
  assert.equal(calls, 0, 'the screen is still up while it waits for the tap');
  t.tap();
  assert.equal(t.removed(), true);
  assert.equal(calls, 1);

  let late = 0;
  t.welcome.onLeave(() => late++);
  assert.equal(late, 1, 'a hook added after the screen left runs at once');
  assert.equal(calls, 1);
});
