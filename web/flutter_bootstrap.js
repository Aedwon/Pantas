{{flutter_js}}
{{flutter_build_config}}

(function () {
  var version = {{flutter_service_worker_version}};
  var base = '/b/' + version + '/';
  window.pantasBuildBase = base;
  // No wait for registration: old workers cannot intercept these folder paths.
  if (window.pantasPwa) window.pantasPwa.registerWorker(version);
  try { performance.mark('page.loader'); } catch (_) {}
  _flutter.loader.load({config: {
    entrypointBaseUrl: base,
    assetBase: base,
    canvasKitBaseUrl: base + 'canvaskit/'
  }});
})();
