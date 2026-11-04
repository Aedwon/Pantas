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
    var state = { shown: false, done: false };

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
      doc.documentElement.classList.remove('ps-on', 'ps-out');
      var splash = doc.getElementById('pantas-splash');
      if (splash && splash.remove) splash.remove();
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
