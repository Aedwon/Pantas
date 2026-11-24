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
  // The spinner row under the wordmark appears from here (board A, Nov 25).
  var SPINNER_MS = 1500;
  // The number stays up this long at 100% before its width closes.
  var NUMBER_CLOSE_MS = 200;

  function create(env) {
    var doc = env.document;
    var state = { shown: false, done: false, gone: false, waited: false, pct: null, closed: false };
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

    function setText(id, text) {
      var el = doc.getElementById(id);
      if (el) el.textContent = text;
    }

    // Puts the number on screen: beside the spinner, or after "Loading" when
    // Reduce Motion is on. Both rows are in the page; the classes pick one.
    function paintNumber() {
      var text = state.pct + '%';
      setText('ps-num', text);
      setText('ps-lab-n', ' ' + text);
      doc.documentElement.classList.add('ps-pct');
    }

    function closeNumber() {
      if (state.gone) return;
      doc.documentElement.classList.remove('ps-pct');
    }

    // Called at 1.5 s: the spinner row appears, with the number if bytes are
    // already arriving.
    function showSpinner() {
      if (state.gone || state.waited) return;
      state.waited = true;
      doc.documentElement.classList.add('ps-wait');
      if (state.pct !== null && !state.closed) paintNumber();
    }

    // Called by the service worker's count: bytes of the app's files received
    // against the total the build wrote down. Only a count that makes sense
    // prints a number; files that were already stored arrive as 100% at once
    // and print nothing.
    function progress(loaded, total) {
      if (!state.shown || state.gone || state.closed) return;
      if (typeof loaded !== 'number' || typeof total !== 'number') return;
      if (!isFinite(loaded) || !isFinite(total) || loaded < 0 || total <= 0) return;
      var pct = Math.floor((Math.min(loaded, total) * 100) / total);
      if (state.pct !== null && pct <= state.pct) return;
      var first = state.pct === null;
      state.pct = pct;
      if (pct >= 100) {
        state.closed = true;
        if (first) return;
        if (state.waited) {
          paintNumber();
          env.setTimeout(closeNumber, NUMBER_CLOSE_MS);
        }
        return;
      }
      if (state.waited) paintNumber();
    }

    function removeNow() {
      // The safety timers can fire after the logo has already left.
      if (state.gone) return;
      doc.documentElement.classList.remove('ps-on', 'ps-out', 'ps-wait', 'ps-pct', 'ps-rm');
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
      if (env.reducedMotion()) doc.documentElement.classList.add('ps-rm');
      env.setTimeout(showSpinner, SPINNER_MS);
      loadFont();
      env.setTimeout(giveUp, NEVER_STARTED_MS);
    }

    return {
      afterGone: afterGone,
      isShown: function () {
        return state.shown;
      },
      progress: progress,
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
      SPINNER_MS: SPINNER_MS,
      NUMBER_CLOSE_MS: NUMBER_CLOSE_MS,
    };
    return;
  }

  var splash = (root.pantasSplash = create({
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
  }));

  // The service worker posts how many bytes of the app's files have arrived.
  try {
    root.navigator.serviceWorker.addEventListener('message', function (event) {
      var data = event && event.data;
      if (data && data.type === 'pantas-load-progress') splash.progress(data.loaded, data.total);
    });
  } catch (_) {}
})(typeof window !== 'undefined' ? window : globalThis);
