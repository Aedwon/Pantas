// Returning visits keep the logo until the first route has drawn settled data.
// The HTML welcome still owns first visits. Once the app has started, eight
// seconds is the limit. Before that nothing is drawn underneath, so a slow phone
// keeps the logo instead of a blank page, for at most a minute.
(function (root) {
  'use strict';

  var FADE_MS = 400;
  // Uncover normal loading states if data takes too long.
  var GIVE_UP_MS = 8000;
  // A page whose app never starts still ends up uncovered.
  var NEVER_STARTED_MS = 60000;

  function create(env) {
    var doc = env.document;
    var state = { shown: false, done: false, gone: false };
    var waiting = [];

    // Timeline marks for the speed report. They only record times and can
    // never change what the splash does.
    function mark(name) {
      try {
        if (env.mark) env.mark(name);
      } catch (_) {}
    }

    // Runs each waiting callback once the splash is out of the page. A page
    // that never had the splash counts as already gone.
    function afterGone(fn) {
      if (!state.shown || state.gone) {
        fn();
        return;
      }
      waiting.push(fn);
    }

    // Starts Geist Bold downloading now, through the font loading API. A
    // <link rel="preload"> did the same, but WebKit warned that it was
    // "preloaded but not used"; a font the page asks for is always used.
    function loadFont() {
      var fonts = doc.fonts;
      if (!fonts || !fonts.load) return;
      try {
        var loading = fonts.load('700 42px Geist');
        if (loading && loading.catch) loading.catch(function () {});
      } catch (_) {}
    }

    function removeNow() {
      // The safety timers can fire after the logo has already left.
      if (state.gone) return;
      doc.documentElement.classList.remove('ps-on', 'ps-out');
      var splash = doc.getElementById('pantas-splash');
      if (splash && splash.remove) splash.remove();
      state.gone = true;
      mark('splash.removed');
      try {
        if (env.printTiming) env.printTiming();
      } catch (_) {}
      var callbacks = waiting;
      waiting = [];
      callbacks.forEach(function (fn) {
        try {
          fn();
        } catch (_) {}
      });
    }

    function finish() {
      if (!state.shown || state.done) return;
      state.done = true;
      if (env.reducedMotion()) {
        removeNow();
        return;
      }
      // Fade over the app that is already drawn underneath, then take it out.
      doc.documentElement.classList.add('ps-out');
      env.setTimeout(removeNow, FADE_MS);
    }

    function giveUp() {
      state.done = true;
      removeNow();
    }

    // Called by the app when its first route is about to mount, or when it has
    // an error screen to show.
    function started() {
      if (!state.shown || state.done || state.started) return;
      state.started = true;
      env.setTimeout(giveUp, GIVE_UP_MS);
    }

    // Called by the app once the first route has settled.
    function ready() {
      if (!state.shown || state.done) return;
      if (!state.readyMarked) {
        state.readyMarked = true;
        mark('splash.ready');
      }
      env.afterPaint(finish);
    }

    var welcomeShown = !!(env.welcome && env.welcome.isShown());
    if (welcomeShown) {
      // The Welcome screen has this visit. Drop the splash markup entirely.
      var stray = doc.getElementById('pantas-splash');
      if (stray && stray.remove) stray.remove();
    } else {
      state.shown = true;
      doc.documentElement.classList.add('ps-on');
      loadFont();
      env.setTimeout(giveUp, NEVER_STARTED_MS);
    }

    return {
      afterGone: afterGone,
      isShown: function () {
        return state.shown;
      },
      ready: ready,
      started: started,
      state: state,
    };
  }

  if (typeof module === 'object' && module.exports) {
    module.exports = {
      create: create,
      FADE_MS: FADE_MS,
      GIVE_UP_MS: GIVE_UP_MS,
      NEVER_STARTED_MS: NEVER_STARTED_MS,
    };
    return;
  }

  root.pantasSplash = create({
    document: root.document,
    welcome: root.pantasWelcome,
    mark: function (name) {
      root.performance.mark(name);
    },
    // With ?timing=1 in the address, prints every mark once the splash is gone.
    printTiming: function () {
      if (!/[?&]timing=1(?:&|$)/.test(root.location.search)) return;
      var rows = root.performance.getEntriesByType('mark').map(function (entry) {
        return { name: entry.name, ms: Math.round(entry.startTime) };
      });
      root.console.table(rows);
    },
    setTimeout: function (fn, ms) {
      return root.setTimeout(fn, ms);
    },
    afterPaint: function (fn) {
      root.requestAnimationFrame(function () {
        root.requestAnimationFrame(fn);
      });
    },
    reducedMotion: function () {
      try {
        return root.matchMedia('(prefers-reduced-motion: reduce)').matches;
      } catch (_) {
        return false;
      }
    },
  });
})(typeof window !== 'undefined' ? window : globalThis);
