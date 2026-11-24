// Run with: node --test test/web/pantas_splash.test.mjs
import test from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';

const require = createRequire(import.meta.url);
const { create, FADE_MS, GIVE_UP_MS, NEVER_STARTED_MS, SPINNER_MS, NUMBER_CLOSE_MS } = require('../../web/pantas_splash.js');

function setup({ welcomeShown = false, reduced = false } = {}) {
  const classes = new Set();
  const timers = [];
  const links = [];
  const loads = [];
  const frameListeners = [];
  const marks = [];
  let printed = 0;
  let splashRemoved = false;
  const num = { textContent: '' };
  const lab = { textContent: '' };
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
    getElementById: (id) => {
      if (id === 'ps-num') return num;
      if (id === 'ps-lab-n') return lab;
      return id === 'pantas-splash' && !splashRemoved
        ? { remove: () => (splashRemoved = true) }
        : null;
    },
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
    num,
    lab,
    // Runs the 1.5 s timer, the way the clock would.
    waited: () => timers.find((x) => x.ms === SPINNER_MS).fn(),
    closeNumber: () => timers.find((x) => x.ms === NUMBER_CLOSE_MS).fn(),
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

// Nov 8 reports showed a second splash.removed near 60 s: the safety timers
// still fired after the logo had left and removed it again.
test('the safety timers do nothing once the logo has left', () => {
  const t = setup();
  t.splash.started();
  t.splash.ready();
  t.timers.find((x) => x.ms === FADE_MS).fn();
  t.timers.find((x) => x.ms === GIVE_UP_MS).fn();
  t.timers.find((x) => x.ms === NEVER_STARTED_MS).fn();
  assert.deepEqual(t.marks, ['splash.ready', 'splash.removed']);
  assert.equal(t.printed(), 1);
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

// Aedwon, staging check: the logo and wordmark sat too far down on his phone.
// Centering plus 16% bottom padding puts the group's center at 42% of the
// height. The Welcome screen is a separate block and keeps its own layout.
test('the splash group centers at 42% of the height, using dvh with a vh fallback', () => {
  const html = readFileSync(new URL('../../web/index.html', import.meta.url), 'utf8');
  const rule = html.slice(html.indexOf('#pantas-splash {'));
  const block = rule.slice(0, rule.indexOf('}'));
  assert.match(block, /justify-content:\s*center/);
  const vh = block.indexOf('padding-bottom: 16vh;');
  const dvh = block.indexOf('padding-bottom: 16dvh;');
  assert.ok(vh > 0 && dvh > vh, 'vh fallback comes before dvh');
});

// Aedwon, Nov 24: "i think in the endeavor to better center the logo in mobile
// view the web view was also moved up and now web is not centered." The 16%
// lift was written for the phone. The approved wide board (Web_B_Still) centers
// the group on the page, so from the wide breakpoint the lift is removed.
test('on wide web the splash group is centered, with no bottom lift', () => {
  const html = readFileSync(new URL('../../web/index.html', import.meta.url), 'utf8');
  const start = html.indexOf('@media (min-width: 1024px) {', html.indexOf('#pantas-splash .ps-wm {'));
  assert.ok(start > 0, 'wide splash media block present');
  const block = html.slice(start, html.indexOf('@keyframes ps-pop', start));
  assert.match(block, /#pantas-splash\s*\{\s*padding-bottom:\s*0;?\s*\}/);
});

// Loading row, board A (UX lead, Nov 25): spinner under the wordmark from 1.5 s,
// the percent beside it only while bytes arrive, the number closes at 100%.

test('before 1.5 s the splash shows no spinner row', () => {
  const t = setup();
  assert.equal(SPINNER_MS, 1500);
  assert.ok(t.timers.some((x) => x.ms === SPINNER_MS));
  assert.ok(!t.classes.has('ps-wait'));
  assert.ok(!t.classes.has('ps-pct'));
});

test('a number that arrives before 1.5 s waits for the spinner', () => {
  const t = setup();
  t.splash.progress(30, 100);
  assert.ok(!t.classes.has('ps-wait'));
  assert.ok(!t.classes.has('ps-pct'));
  t.waited();
  assert.ok(t.classes.has('ps-wait'));
  assert.ok(t.classes.has('ps-pct'));
  assert.equal(t.num.textContent, '30%');
});

test('at 1.5 s with nothing downloading, only the spinner shows', () => {
  const t = setup();
  t.waited();
  assert.ok(t.classes.has('ps-wait'));
  assert.ok(!t.classes.has('ps-pct'));
  assert.equal(t.num.textContent, '');
});

test('spinner and percent: the number follows the bytes and never goes back', () => {
  const t = setup();
  t.waited();
  t.splash.progress(42, 100);
  assert.ok(t.classes.has('ps-pct'));
  assert.equal(t.num.textContent, '42%');
  t.splash.progress(10, 100);
  assert.equal(t.num.textContent, '42%');
  t.splash.progress(5_700_000, 13_400_000);
  assert.equal(t.num.textContent, '42%');
  t.splash.progress(7, 8);
  assert.equal(t.num.textContent, '87%');
});

test('at 100% the number closes after 200 ms and the spinner keeps going', () => {
  const t = setup();
  t.waited();
  t.splash.progress(42, 100);
  t.splash.progress(100, 100, true);
  assert.equal(t.num.textContent, '100%');
  assert.ok(t.classes.has('ps-pct'));
  t.closeNumber();
  assert.ok(!t.classes.has('ps-pct'));
  assert.ok(t.classes.has('ps-wait'));
  assert.equal(NUMBER_CLOSE_MS, 200);
  t.splash.progress(50, 100);
  assert.ok(!t.classes.has('ps-pct'), 'a closed number never comes back');
});

test('files that were already stored never print a number', () => {
  const t = setup();
  t.waited();
  t.splash.progress(100, 100, true);
  assert.ok(!t.classes.has('ps-pct'));
  assert.equal(t.num.textContent, '');
  assert.ok(!t.timers.some((x) => x.ms === NUMBER_CLOSE_MS));
});

test('a count the page cannot trust prints no number', () => {
  const t = setup();
  t.waited();
  for (const bad of [[1, 0], [-1, 100], [NaN, 100], [1, Infinity], ['1', '2'], [null, null], [undefined, 100]]) {
    t.splash.progress(...bad);
  }
  assert.ok(!t.classes.has('ps-pct'));
  assert.equal(t.num.textContent, '');
});

test('more bytes than the total never prints above 100%', () => {
  const t = setup();
  t.waited();
  t.splash.progress(50, 100);
  t.splash.progress(120, 100);
  assert.equal(t.num.textContent, '99%');
  assert.ok(t.classes.has('ps-pct'));
});

test('every byte delivered is still not 100% until the worker says done', () => {
  const t = setup();
  t.waited();
  t.splash.progress(60, 100);
  t.splash.progress(100, 100);
  assert.equal(t.num.textContent, '99%');
  assert.ok(!t.timers.some((x) => x.ms === NUMBER_CLOSE_MS));
  t.splash.progress(100, 100, true);
  assert.equal(t.num.textContent, '100%');
  assert.ok(t.timers.some((x) => x.ms === NUMBER_CLOSE_MS));
});

test('a stop from the worker hides the number at once and it never returns', () => {
  const t = setup();
  t.waited();
  t.splash.progress(42, 100);
  assert.ok(t.classes.has('ps-pct'));
  t.splash.stop();
  assert.ok(!t.classes.has('ps-pct'), 'the old percent does not stay on screen');
  assert.ok(t.classes.has('ps-wait'), 'the spinner keeps going');
  t.splash.progress(60, 100);
  t.splash.progress(100, 100, true);
  assert.ok(!t.classes.has('ps-pct'));
});

test('a stop before the spinner appears means no number at all', () => {
  const t = setup();
  t.splash.progress(42, 100);
  t.splash.stop();
  t.waited();
  assert.ok(!t.classes.has('ps-pct'));
});

test('the page forwards the stop message too', () => {
  const src = readFileSync(new URL('../../web/pantas_splash.js', import.meta.url), 'utf8');
  assert.match(src, /data\.stop/);
});

test('Reduce Motion: "Loading 42%" on one line, then "Loading"', () => {
  const t = setup({ reduced: true });
  assert.ok(t.classes.has('ps-rm'));
  t.waited();
  assert.ok(t.classes.has('ps-wait'));
  assert.equal(t.lab.textContent, '');
  t.splash.progress(42, 100);
  assert.equal(t.lab.textContent, ' 42%');
  assert.ok(t.classes.has('ps-pct'));
  t.splash.progress(100, 100, true);
  t.closeNumber();
  assert.ok(!t.classes.has('ps-pct'));
});

test('without Reduce Motion the splash does not take the label look', () => {
  const t = setup();
  assert.ok(!t.classes.has('ps-rm'));
});

test('progress on a page without the splash does nothing', () => {
  const t = setup({ welcomeShown: true });
  t.splash.progress(42, 100);
  assert.ok(!t.classes.has('ps-pct'));
  assert.equal(t.num.textContent, '');
});

test('progress after the splash has gone does nothing', () => {
  const t = setup({ reduced: true });
  t.splash.ready();
  t.splash.progress(42, 100);
  assert.ok(!t.classes.has('ps-pct'));
});

test('the page forwards the worker progress message to the splash', () => {
  const src = readFileSync(new URL('../../web/pantas_splash.js', import.meta.url), 'utf8');
  assert.match(src, /pantas-load-progress/);
});

test('the splash markup and styles match board A', () => {
  const html = readFileSync(new URL('../../web/index.html', import.meta.url), 'utf8');
  const css = html.slice(html.indexOf('#pantas-splash {'));
  assert.match(html, /id="ps-num"/);
  assert.match(html, /id="ps-lab-n"/);
  assert.match(css, /\.ps-ind \{[^}]*margin-top: 40px/);
  assert.match(css, /\.ps-ring \{[^}]*width: 20px[^}]*height: 20px[^}]*border: 2px solid var\(--track\)[^}]*animation: ps-spin \.9s linear infinite/);
  assert.match(css, /\.ps-num \{[^}]*font-size: 13px[^}]*font-weight: 500[^}]*font-variant-numeric: tabular-nums/);
  assert.match(css, /\.ps-num \{[^}]*220ms cubic-bezier\(\.25, ?\.1, ?\.25, ?1\)/);
  assert.match(css, /html\.ps-pct #pantas-splash \.ps-num \{[^}]*margin-left: 8px[^}]*max-width: 3em/);
  assert.match(css, /\.ps-num \{ font-size: 14px/);
  assert.match(css, /--sec: #6E6E73[\s\S]*--sec: #A3A3A3/);
});
