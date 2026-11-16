// Runs before Flutter. On a touch phone it lowers the pixel ratio Flutter draws
// at, to 2.5, so each frame has fewer pixels for the phone's GPU to fill. This is
// the whole change: no layout, motion or widget differs. Text and images are a
// little softer on a 3x phone. A 2x phone, a tablet at 2x and every desktop keep
// the real ratio.
//
// How the Flutter web engine reads the ratio (SDK 3.44.6, web_ui):
//   * One place reads it: EngineFlutterDisplay.browserDevicePixelRatio
//     (display.dart) returns window.devicePixelRatio times
//     visualViewport.scale. Every other use goes through that display object:
//     the view's devicePixelRatio, the CanvasKit surface size (canvaskit/
//     surface.dart), pointer positions, the semantics scale and the app's
//     MediaQuery. So lowering window.devicePixelRatio lowers all of them
//     together, and taps still land on the right place.
//   * It reads the value live, on every use, not once at startup.
//   * It finds changes with matchMedia('(resolution: <ratio>dppx)')
//     (view_embedder/display_dpr_stream.dart), built from the value our getter
//     returns. The browser answers that query with the real resolution, so with
//     the capped value (2.5) the event fires only if the real ratio becomes
//     exactly 2.5. While capped, the engine therefore hears no change event.
//     This costs nothing that matters: a zoom change also resizes the window,
//     and a resize makes the engine read the getter again, and the CanvasKit
//     surface compares the ratio on every frame (canvaskit/surface.dart). Moving
//     a touch device between screens of different ratios without a resize is the
//     one case left, and it is not a phone case.
// So the override has to be the window.devicePixelRatio getter only, and it has
// to cap the live native value on each read instead of storing one number.
//
// Staging only: ?pixelRatio=3 turns the cap off, ?pixelRatio=2.5 and
// ?pixelRatio=2 set it. The choice is kept in sessionStorage because the app
// rewrites the address while it starts. Anywhere else the parameter is ignored.
(function (root) {
  'use strict';

  var DEFAULT_CAP = 2.5;
  var PARAM = 'pixelRatio';
  var STORE_KEY = 'pantas.pixelRatio';
  var MAX_CAP = 3; // At or above this the cap is off.

  // Staging is only these hosts. Anything else, including a local run, is prod.
  function isStagingHost(host) {
    return (
      host === 'staging.pantas.study' ||
      /^pantas-staging[a-z0-9-]*\.web\.app$/.test(String(host || ''))
    );
  }

  // The cap a parameter asks for, Infinity for no cap, or null when it is not
  // a usable number.
  function parseOverride(raw) {
    if (typeof raw !== 'string' || raw.trim() === '') return null;
    var value = Number(raw);
    if (!isFinite(value) || value < 1) return null;
    return value >= MAX_CAP ? Infinity : value;
  }

  // The ratio to report. param and stored are the raw strings, or null.
  function chooseRatio(input) {
    var native = input.native;
    if (!input.coarse || !(native > 0)) return native;
    var cap = DEFAULT_CAP;
    if (isStagingHost(input.host)) {
      var chosen = parseOverride(input.param);
      if (chosen === null) chosen = parseOverride(input.stored);
      if (chosen !== null) cap = chosen;
    }
    return Math.min(native, cap);
  }

  function nativeGetter(win) {
    var target = win;
    while (target) {
      var descriptor = Object.getOwnPropertyDescriptor(target, 'devicePixelRatio');
      if (descriptor && descriptor.get) return descriptor.get;
      target = Object.getPrototypeOf(target);
    }
    return null;
  }

  function readParam(win) {
    try {
      var query = String(win.location.search || '');
      var match = new RegExp('[?&]' + PARAM + '=([^&#]*)').exec(query);
      return match ? decodeURIComponent(match[1]) : null;
    } catch (_) {
      return null;
    }
  }

  function install(win) {
    try {
      if (typeof win.matchMedia !== 'function') return;
      var getNative = nativeGetter(win);
      if (!getNative) return;
      var host = win.location.hostname;
      var staging = isStagingHost(host);
      var param = staging ? readParam(win) : null;
      var stored = null;
      if (staging) {
        try {
          if (parseOverride(param) !== null) win.sessionStorage.setItem(STORE_KEY, param);
          stored = win.sessionStorage.getItem(STORE_KEY);
        } catch (_) {
          // Blocked storage: the parameter still works for this load.
        }
      }
      // A live list: .matches is read on each call.
      var coarse = win.matchMedia('(pointer: coarse)');
      Object.defineProperty(win, 'devicePixelRatio', {
        configurable: true,
        enumerable: true,
        get: function () {
          return chooseRatio({
            native: getNative.call(win),
            coarse: coarse.matches,
            host: host,
            param: param,
            stored: stored,
          });
        },
      });
    } catch (_) {
      // On any failure the browser's own value stays in place.
    }
  }

  var api = {
    chooseRatio: chooseRatio,
    isStagingHost: isStagingHost,
    parseOverride: parseOverride,
    install: install,
    DEFAULT_CAP: DEFAULT_CAP,
    PARAM: PARAM,
    STORE_KEY: STORE_KEY,
  };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  if (typeof window !== 'undefined' && root === window) install(window);
})(typeof window !== 'undefined' ? window : globalThis);
