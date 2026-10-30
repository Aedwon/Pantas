// Runs before Flutter. It decides whether this visit opens with the plain HTML
// logo splash (index.html) and removes it when Flutter has drawn its first frame.
//
//   * Returning visit (pantas_welcome.js did not claim the visit): the splash
//     shows from the first paint until Flutter's first frame.
//   * First visit: the Welcome screen owns the visit. The splash never shows
//     and its markup is removed, so the two can never appear together.
//   * Reduced motion: the splash leaves at once, with no fade.
//
// Flutter's engine fires "flutter-first-frame" on the page when it has put its
// first frame on screen. Nothing here reads app data.
(function (root) {
  'use strict';

  var FADE_MS = 400;
  // If the first frame never comes, uncover whatever the page shows instead of
  // leaving the logo up forever.
  var GIVE_UP_MS = 20000;
  var FIRST_FRAME_EVENT = 'flutter-first-frame';

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

    // Called with the first-frame signal. Waits until the frame is painted.
    function firstFrame() {
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
      env.onFirstFrame(firstFrame);
      env.setTimeout(finish, GIVE_UP_MS);
    }

    return {
      isShown: function () {
        return state.shown;
      },
      firstFrame: firstFrame,
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
    onFirstFrame: function (fn) {
      // Capture on window so it is heard wherever the engine dispatches it.
      root.addEventListener(FIRST_FRAME_EVENT, fn, true);
    },
  });
})(typeof window !== 'undefined' ? window : globalThis);
