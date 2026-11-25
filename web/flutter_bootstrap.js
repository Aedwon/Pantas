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
  _flutter.loader.load(
    base ? {config: {entrypointBaseUrl: base, assetBase: base, canvasKitBaseUrl: base + 'canvaskit'}} : {}
  );
})();
