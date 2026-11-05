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
  // A slow phone can take longer than 20 seconds to start, and uncovering then
  // shows a blank page.
  var GIVE_UP_MS = 60000;
  var FONTS = ['400', '600', '700'];

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

    // Starts the three Geist weights downloading now, through the font loading
    // API. A <link rel="preload"> did the same, but WebKit warned that it was
    // "preloaded but not used"; a font the page asks for is always used.
    function loadFonts() {
      var fonts = doc.fonts;
      if (!fonts || !fonts.load) return;
      FONTS.forEach(function (weight) {
        try {
          var loading = fonts.load(weight + ' 16px Geist');
          if (loading && loading.catch) loading.catch(function () {});
        } catch (_) {}
      });
    }

    // The app's own element that held keyboard focus under the cover (its first
    // step's text field). Removing the cover must not leave focus on the page,
    // or the keys typed next go nowhere (WebKit).
    var appFocus = null;

    function onFocusIn(event) {
      var target = event.target;
      if (!target || (target.closest && target.closest('#pantas-welcome'))) return;
      if (target === doc.body || target === doc.documentElement) return;
      appFocus = target;
    }

    function focusOnPage() {
      var active = doc.activeElement;
      return !active || active === doc.body || active === doc.documentElement;
    }

    function restoreFocus() {
      var target = appFocus;
      if (!target || !target.isConnected || !target.focus || !focusOnPage()) return;
      try {
        target.focus({ preventScroll: true });
      } catch (_) {}
    }

    function finish() {
      if (state.done) return;
      state.done = true;
      remember();
      doc.documentElement.classList.remove('pw-on');
      var screen = doc.getElementById('pantas-welcome');
      if (screen && screen.remove) screen.remove();
      restoreFocus();
      // The engine may move its text field in the next frame; look again then.
      env.afterPaint(restoreFocus);
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

    // A parent or guardian opening the emailed link is not a new student, and
    // the Terms and Privacy pages open for anyone, so a link to them never
    // waits behind a Welcome screen. The screen would hide the page they came
    // for.
    function pageLink() {
      try {
        return /^\/(guardian|legal)(\/|$)/.test(env.pathname ? env.pathname() : '');
      } catch (_) {
        return false;
      }
    }

    if (!seen() && !pageLink()) {
      state.shown = true;
      doc.documentElement.classList.add('pw-on');
      loadFonts();
      doc.addEventListener('focusin', onFocusIn, true);
      doc.addEventListener('click', function (event) {
        var target = event.target;
        if (target && target.closest && target.closest('#pw-start')) start();
      });
      // The Enter hint on the button only exists on wide screens. Flutter's view
      // holds keyboard focus under the cover (a hidden text input) and its own
      // key handling stops the event before it reaches the document, so a
      // document listener never hears Enter until a click moves focus. This
      // listens on the window in the capture phase. This script runs before
      // Flutter's, so it is first in line, and it keeps Enter from also
      // reaching the app's own first step.
      (env.keyTarget || doc).addEventListener(
        'keydown',
        function (event) {
          if (event.key !== 'Enter' || state.done || !env.wide()) return;
          if (event.preventDefault) event.preventDefault();
          if (event.stopImmediatePropagation) event.stopImmediatePropagation();
          else if (event.stopPropagation) event.stopPropagation();
          start();
        },
        true,
      );
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
    keyTarget: root,
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
    pathname: function () {
      return root.location.pathname;
    },
  });
})(typeof window !== 'undefined' ? window : globalThis);
