// Runs before Flutter. It keeps the browser's install event, which can fire
// before any Dart code exists, and registers the caching service worker.
(function () {
  'use strict';

  var state = { event: null, installed: false, listeners: [] };

  // The worker that controlled this page when it loaded, if any. A worker that
  // takes over later does not change what kind of visit this was.
  var controllerAtLoad = null;
  var buildVersion = null;
  var registrationPromise = null;
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

  // Registers pantas_sw.js for this build and resolves once that exact build
  // controls the page, so no file is read through an older cache. Never
  // rejects and never waits long: without a worker the app loads from the
  // network as before.
  function registerWorker(version) {
    buildVersion = version;
    window.pantasUpdate.currentVersion = version;
    scheduleCheck();
    return registerForBuild(version).then(function (result) {
      mark('page.worker');
      return result;
    });
  }

  function registerForBuild(version) {
    if (!('serviceWorker' in navigator)) return Promise.resolve(false);
    var script = 'pantas_sw.js?v=' + encodeURIComponent(version);
    var opening = true;
    // First visit: no worker controls the page, so nothing stale can be
    // served. Register in the background and start the app at once.
    if (!navigator.serviceWorker.controller) {
      registrationPromise = navigator.serviceWorker.register(script);
      registrationPromise.catch(function () {});
      return Promise.resolve(false);
    }
    var timeout = new Promise(function (resolve) {
      setTimeout(function () {
        resolve(false);
      }, 4000);
    });
    registrationPromise = navigator.serviceWorker.register(script);
    var ready = registrationPromise
      .then(function (registration) {
        return new Promise(function (resolve) {
          function active() {
            var worker = registration.active;
            return workerVersion(worker) === version
              ? worker
              : null;
          }
          function check() {
            if (active() && navigator.serviceWorker.controller) {
              if (navigator.serviceWorker.controller.scriptURL === active().scriptURL) {
                resolve(true);
                return true;
              }
            }
            return false;
          }
          if (check()) return;
          // Page startup is a safe point. Only activate this page's build.
          function activateAtOpen() {
            var waiting = registration.waiting;
            if (opening && workerVersion(waiting) === version) {
              waiting.postMessage({ type: 'SKIP_WAITING' });
            }
          }
          activateAtOpen();
          navigator.serviceWorker.addEventListener('controllerchange', check);
          var pending = registration.installing || registration.waiting;
          if (pending) pending.addEventListener('statechange', function () { activateAtOpen(); check(); });
          registration.addEventListener('updatefound', function () {
            if (registration.installing) {
              registration.installing.addEventListener('statechange', function () { activateAtOpen(); check(); });
            }
          });
        });
      })
      .catch(function () {
        return false;
      });
    return Promise.race([ready, timeout]).then(function (result) {
      opening = false;
      return result;
    });
  }

  var lastCheck = null;
  var lastCheckedAt = -Infinity;
  var checking = null;
  var checkTimer = null;
  var applying = null;
  var CHECK_INTERVAL = 5 * 60 * 1000;

  function workerVersion(worker) {
    return worker ? new URL(worker.scriptURL).searchParams.get('v') : null;
  }

  // Versions are opaque content identities, not increasing version numbers:
  // a rollback is also a new build relative to the running page.
  function checkUpdate(force) {
    if (checking) return checking;
    if (!force && lastCheck && Date.now() - lastCheckedAt < CHECK_INTERVAL) {
      return Promise.resolve(lastCheck);
    }
    checking = (async function () {
      if (!buildVersion || !('serviceWorker' in navigator)) {
        return { available: false, version: buildVersion };
      }
      try {
        var response = await fetch('version.json', { cache: 'no-store' });
        if (!response.ok) throw new Error('Version check failed');
        var data = await response.json();
        var version = data.pantasBuildVersion;
        if (typeof version !== 'string' || !version) throw new Error('Missing build version');
        if (version !== buildVersion) {
          // Register the new URL, rather than update the old ?v= URL into the
          // old build's cache. Install in the background and leave it waiting.
          registrationPromise = navigator.serviceWorker.register(
            'pantas_sw.js?v=' + encodeURIComponent(version), { updateViaCache: 'none' }
          );
          var registration = await registrationPromise;
          await registration.update();
        }
        return { available: version !== buildVersion, version: version };
      } catch (_) {
        // Offline does not erase an update already discovered online.
        return lastCheck || { available: false, version: buildVersion };
      }
    })().then(function (result) {
      lastCheck = result;
      lastCheckedAt = Date.now();
      checking = null;
      return result;
    });
    return checking;
  }

  function scheduleCheck() {
    if (!window.document || checkTimer !== null) return;
    checkTimer = setTimeout(function tick() {
      checkTimer = null;
      if (document.visibilityState === 'visible') checkUpdate().catch(function () {});
      scheduleCheck();
    }, CHECK_INTERVAL);
  }

  // Only the app decides whether pending writes are flushed and a quiz or
  // lesson is finished. Nothing here automatically activates or reloads.
  function applyUpdate() {
    if (applying) return applying;
    applying = (async function () {
      var result = await checkUpdate();
      if (!result.available) return false;
      var registration = await registrationPromise;
      if (!registration.waiting && workerVersion(registration.active) !== result.version) {
        await new Promise(function (resolve, reject) {
          var timer = setTimeout(function () { reject(new Error('Update not ready')); }, 15000);
          function ready() {
            if (registration.waiting || workerVersion(registration.active) === result.version) {
              clearTimeout(timer); resolve();
            }
          }
          function installing() {
            if (registration.installing) registration.installing.addEventListener('statechange', ready);
            ready();
          }
          registration.addEventListener('updatefound', installing);
          installing();
        });
      }
      if (workerVersion(navigator.serviceWorker.controller) === result.version) {
        window.location.reload(); return true;
      }
      await new Promise(function (resolve, reject) {
        var timer = setTimeout(function () {
          reloading = true;
          navigator.serviceWorker.removeEventListener('controllerchange', changed);
          reject(new Error('Update activation timed out'));
        }, 15000);
        var reloading = false;
        function changed() {
          if (reloading || workerVersion(navigator.serviceWorker.controller) !== result.version) return;
          reloading = true;
          clearTimeout(timer);
          navigator.serviceWorker.removeEventListener('controllerchange', changed);
          window.location.reload(); resolve();
        }
        navigator.serviceWorker.addEventListener('controllerchange', changed);
        var waiting = registration.waiting;
        if (workerVersion(waiting) === result.version) waiting.postMessage({ type: 'SKIP_WAITING' });
        changed();
      });
      return true;
    })().finally(function () { applying = null; });
    return applying;
  }

  window.pantasUpdate = { currentVersion: null, check: checkUpdate, apply: applyUpdate };
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.addEventListener('message', function (event) {
      if (event.data && event.data.type === 'PANTAS_VERSION' && event.ports && event.ports[0]) {
        event.ports[0].postMessage({ version: buildVersion });
      }
    });
  }
  if (window.document) {
    document.addEventListener('visibilitychange', function () {
      if (document.visibilityState === 'visible') return checkUpdate(true);
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
