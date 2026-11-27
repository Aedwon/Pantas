{{flutter_js}}
{{flutter_build_config}}

// Pantas registers its own worker (pantas_sw.js), so Flutter's is left out.
// The version token below expands to a quoted string.
//
// A release build (tool/web/stamp_worker_version.mjs) moves every file the page
// loads into b/<id>/ and writes window.pantasBuildBase, the folder's URL, above
// this code. Flutter then loads the app, its assets and CanvasKit from that
// folder, so this page can only ever run the files of its own build. Without the
// line (a dev run) everything loads from the root, as before.
//
// The page does not wait for the worker. The one thing it does first is a quick
// local check: when an update is already installed and waiting, and this is the
// only window, the worker takes over and the page reloads into the new build
// before Flutter starts.
(async function () {
  var pwa = window.pantasPwa;
  var swapping = false;
  if (pwa && pwa.registerWorker) {
    try {
      swapping = await pwa.registerWorker({{flutter_service_worker_version}});
    } catch (_) {}
  }
  if (swapping) return;
  try {
    performance.mark('page.loader');
  } catch (_) {}
  var base = window.pantasBuildBase;
  // Full CanvasKit in every browser. Left alone, Flutter picks the smaller chromium variant on
  // Chrome and Edge, on checks the service worker cannot make, so the worker would have to store
  // both. With the pin it stores one, and an update downloads half the renderer. Safari and
  // Firefox already run this variant (E-210, audit 2 High 5).
  var config = {canvasKitVariant: 'full'};
  if (base) {
    config.entrypointBaseUrl = base;
    config.assetBase = base;
    config.canvasKitBaseUrl = base + 'canvaskit';
  }
  _flutter.loader.load({config: config});
})();
