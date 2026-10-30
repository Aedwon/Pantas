{{flutter_js}}
{{flutter_build_config}}

// Pantas registers its own worker (pantas_sw.js), so Flutter's is left out.
// The version token below expands to a quoted string. The page waits for this build's worker to take control, then starts Flutter.
(async function () {
  var pwa = window.pantasPwa;
  if (pwa && pwa.registerWorker) {
    try {
      await pwa.registerWorker({{flutter_service_worker_version}});
    } catch (_) {}
  }
  _flutter.loader.load({});
})();
