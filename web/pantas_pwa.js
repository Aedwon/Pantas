// Runs before Flutter. It keeps the browser's install event, which can fire
// before any Dart code exists, and registers the caching service worker.
(function () {
  'use strict';

  var state = { event: null, installed: false, listeners: [] };

  // The worker that controlled this page when it loaded, if any. A worker that
  // takes over later does not change what kind of visit this was.
  var controllerAtLoad = null;
  var buildVersion = null;
  try {
    if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
      controllerAtLoad = navigator.serviceWorker.controller.scriptURL;
    }
  } catch (_) {}

  // Timeline marks for the speed report. They only record times.
  function mark(name) {
    try {
      window.performance.mark(name);
    } catch (_) {}
  }

  // 'first' when no worker controlled the page, 'after_deploy' when the one
  // that did came from a different build, otherwise 'return'.
  function visitKind() {
    if (!controllerAtLoad) return 'first';
    if (buildVersion === null) return 'return';
    var at = controllerAtLoad.indexOf('?v=');
    if (at === -1) return 'after_deploy';
    var end = controllerAtLoad.indexOf('&', at);
    var found = controllerAtLoad.slice(at + 3, end === -1 ? undefined : end);
    return found === encodeURIComponent(buildVersion) ? 'return' : 'after_deploy';
  }

  function emit() {
    state.listeners.slice().forEach(function (listener) {
      try {
        listener();
      } catch (_) {}
    });
  }

  window.addEventListener('beforeinstallprompt', function (event) {
    // Keep the event so the Home card can open the dialog later.
    event.preventDefault();
    state.event = event;
    emit();
  });

  window.addEventListener('appinstalled', function () {
    state.event = null;
    state.installed = true;
    emit();
  });

  // Folder URLs establish the build before any worker can take control.
  function registerWorker(version) {
    buildVersion = version;
    window.pantasUpdate.currentVersion = version;
    scheduleCheck();
    if (!('serviceWorker' in navigator)) {
      mark('page.worker');
      return Promise.resolve(false);
    }
    return navigator.serviceWorker.register('/pantas_sw.js?v=' + encodeURIComponent(version),
      {updateViaCache: 'none'}).then(function () {
        mark('page.worker'); return true;
      }, function () { mark('page.worker'); return false; });
  }

  var checking = null;
  var checkTimer = null;
  var CHECK_INTERVAL = 5 * 60 * 1000;
  function checkUpdate() {
    if (checking) return checking;
    checking = (async function () {
      var controller = new AbortController();
      var timer;
      try {
        return await Promise.race([
          (async function () {
            var response = await fetch('/version.json', {cache: 'no-store', signal: controller.signal});
            if (!response.ok) throw new Error('Version check failed');
            var data = await response.json();
            var version = data.pantasBuildVersion;
            if (typeof version !== 'string' || !version) throw new Error('Missing build version');
            return {available: version !== buildVersion, version: version};
          })(),
          new Promise(function (_, reject) {
            timer = setTimeout(function () {
              reject(new Error('Version check timed out'));
              controller.abort();
            }, 4000);
          })
        ]);
      } finally { clearTimeout(timer); }
    })().finally(function () { checking = null; });
    return checking;
  }
  function scheduleCheck() {
    if (!window.document || checkTimer !== null) return;
    checkTimer = setTimeout(function tick() {
      checkTimer = null;
      var job = document.visibilityState === 'visible' ? checkUpdate().catch(function () {}) : Promise.resolve();
      scheduleCheck();
      return job;
    }, CHECK_INTERVAL);
  }
  function applyUpdate() {
    window.location.reload();
    return Promise.resolve(true);
  }
  window.pantasUpdate = {currentVersion: null, check: checkUpdate, apply: applyUpdate};
  if (window.document) {
    document.addEventListener('visibilitychange', function () {
      if (document.visibilityState === 'visible') return checkUpdate().catch(function () {});
    });
  }

  window.pantasPwa = {
    hasPrompt: function () {
      return state.event !== null;
    },
    wasInstalled: function () {
      return state.installed;
    },
    subscribe: function (callback) {
      state.listeners.push(callback);
    },
    // Opens the browser's install dialog. Each event works once.
    prompt: function () {
      var event = state.event;
      if (!event) return Promise.resolve('unavailable');
      state.event = null;
      emit();
      event.prompt();
      return event.userChoice.then(
        function (choice) {
          return choice && choice.outcome ? choice.outcome : 'dismissed';
        },
        function () {
          return 'dismissed';
        }
      );
    },
    registerWorker: registerWorker,
    visitKind: visitKind,
    // The build id the page was started with, for the speed report.
    buildVersion: function () {
      return buildVersion;
    },
    // Compatibility for the existing app action. It uses the same safe shell
    // update and never unregisters workers or clears storage.
    updateNow: applyUpdate,
  };
})();
