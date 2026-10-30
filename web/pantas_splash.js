// Returning visits keep the logo until the first route has drawn settled data.
// The HTML welcome still owns first visits. Eight seconds is the hard limit.
(function (root) {
  'use strict';

  var FADE_MS = 400;
  // Uncover normal loading states if data takes too long.
  var GIVE_UP_MS = 8000;

  function create(env) {
    var doc = env.document;
    var state = { shown: false, done: false };

    function preloadFont() {
      if (!doc.head || !doc.createElement) return;
      var link = doc.createElement('link');
      link.rel = 'preload';
      link.as = 'font';
      link.type = 'font/ttf';
      link.crossOrigin = 'anonymous';
      link.href = 'assets/assets/fonts/Geist-Bold.ttf';
      doc.head.appendChild(link);
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
      preloadFont();
      env.setTimeout(function () {
        state.done = true;
        removeNow();
      }, GIVE_UP_MS);
    }

    return {
      isShown: function () {
        return state.shown;
      },
      ready: ready,
      state: state,
    };
  }

  if (typeof module === 'object' && module.exports) {
    module.exports = { create: create, FADE_MS: FADE_MS, GIVE_UP_MS: GIVE_UP_MS };
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
