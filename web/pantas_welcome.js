// Runs before Flutter. It decides whether this visit opens with the plain HTML
// Welcome screen (index.html) and hands over to the app when the app is ready.
//
//   * First visit (no stored mark): the screen shows while the app downloads.
//   * Returning visit: the screen never shows.
//   * Get Started before the app is ready: the button shows "Starting…" and the
//     screen leaves the moment the app reports that it is ready.
//   * Get Started after the app is ready: the screen leaves at once.
//
// The app (Dart) calls pantasWelcome.ready(holdForTap) once it has drawn its
// first onboarding step (true) or knows the learner is already set up (false).
// With true the screen waits for the tap. Nothing here reads app data.
(function (root) {
  'use strict';

  var SEEN_KEY = 'pantas.welcome.seen';
  // If the app never reports ready, uncover whatever it shows (usually its own
  // error screen) instead of leaving a button that says "Starting…" forever.
  var GIVE_UP_MS = 20000;
  var FONTS = ['Regular', 'SemiBold', 'Bold'];

  function create(env) {
    var doc = env.document;
    var storage = env.storage;
    var state = { shown: false, started: false, ready: false, done: false };

    function seen() {
      try {
        return storage.getItem(SEEN_KEY) === '1';
      } catch (_) {
        return false;
      }
    }

    function remember() {
      try {
        storage.setItem(SEEN_KEY, '1');
      } catch (_) {
        // Private browsing can refuse storage. The screen then shows again.
      }
    }

    function preloadFonts() {
      if (!doc.head || !doc.createElement) return;
      FONTS.forEach(function (name) {
        var link = doc.createElement('link');
        link.rel = 'preload';
        link.as = 'font';
        link.type = 'font/ttf';
        link.crossOrigin = 'anonymous';
        link.href = 'assets/assets/fonts/Geist-' + name + '.ttf';
        doc.head.appendChild(link);
      });
    }

    function finish() {
      if (state.done) return;
      state.done = true;
      remember();
      doc.documentElement.classList.remove('pw-on');
      var screen = doc.getElementById('pantas-welcome');
      if (screen && screen.remove) screen.remove();
    }

    function showStarting() {
      var button = doc.getElementById('pw-start');
      if (!button) return;
      button.setAttribute('aria-busy', 'true');
      button.innerHTML = '<span class="pw-spin" aria-hidden="true"></span>Starting…';
    }

    function start() {
      if (!state.shown || state.done || state.started) return;
      state.started = true;
      // Marked at the tap, so a visit closed before the app is ready still
      // counts: the next visit goes to the app, which resumes onboarding.
      remember();
      if (state.ready) {
        finish();
        return;
      }
      showStarting();
      env.setTimeout(finish, GIVE_UP_MS);
    }

    function ready(holdForTap) {
      if (!state.shown || state.done) return;
      state.ready = true;
      // Let the app's frame reach the screen before the cover leaves.
      if (!holdForTap || state.started) env.afterPaint(finish);
    }

    if (!seen()) {
      state.shown = true;
      doc.documentElement.classList.add('pw-on');
      preloadFonts();
      doc.addEventListener('click', function (event) {
        var target = event.target;
        if (target && target.closest && target.closest('#pw-start')) start();
      });
      // The Enter hint on the button only exists on wide screens.
      doc.addEventListener('keydown', function (event) {
        if (event.key === 'Enter' && env.wide()) start();
      });
    }

    return {
      isShown: function () {
        return state.shown;
      },
      ready: ready,
      start: start,
      state: state,
    };
  }

  if (typeof module === 'object' && module.exports) {
    module.exports = { create: create, SEEN_KEY: SEEN_KEY, GIVE_UP_MS: GIVE_UP_MS };
    return;
  }

  var storage = null;
  try {
    storage = root.localStorage;
  } catch (_) {}
  root.pantasWelcome = create({
    document: root.document,
    storage: storage,
    setTimeout: function (fn, ms) {
      return root.setTimeout(fn, ms);
    },
    afterPaint: function (fn) {
      root.requestAnimationFrame(function () {
        root.requestAnimationFrame(fn);
      });
    },
    wide: function () {
      return root.matchMedia('(min-width: 1024px)').matches;
    },
  });
})(typeof window !== 'undefined' ? window : globalThis);
