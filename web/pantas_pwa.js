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

  // The page loads its own build's files from b/<id>/, so it needs no worker to run
  // the right code. This only registers the worker (in the background, for the
  // next visit and for offline) and, before Flutter starts, does one quick local
  // check: if an update is already installed and waiting, and this is the only
  // window, the worker takes over and the page reloads into the new build.
  // Resolves true when that reload is under way (the caller must not start
  // Flutter), false otherwise. Never rejects and never waits long.
  function registerWorker(version) {
    buildVersion = version;
    window.pantasUpdate.currentVersion = version;
    scheduleUpdateCheck();
    var swapping;
    if (!('serviceWorker' in navigator)) {
      swapping = Promise.resolve(false);
    } else {
      try {
        navigator.serviceWorker
          .register('pantas_sw.js?v=' + encodeURIComponent(version))
          .catch(function () {});
      } catch (_) {}
      swapping = withTimeout(registration().then(swap), STARTUP_SWAP_MS, false);
    }
    return swapping.then(function (result) {
      mark('page.worker');
      return result;
    });
  }

  var STARTUP_SWAP_MS = 2500;
  var ASK_MS = 3000;

  // The result of `promise`, or `fallback` when it is slower than `ms`. A
  // rejection counts as the fallback too.
  function withTimeout(promise, ms, fallback) {
    return new Promise(function (resolve) {
      var timer = setTimeout(function () {
        resolve(fallback);
      }, ms);
      promise.then(
        function (value) {
          clearTimeout(timer);
          resolve(value);
        },
        function () {
          clearTimeout(timer);
          resolve(fallback);
        }
      );
    });
  }

  // This browser's registration for the app, from local storage (no network).
  function registration() {
    if (!('serviceWorker' in navigator) || !navigator.serviceWorker.getRegistration) return Promise.resolve(null);
    return navigator.serviceWorker.getRegistration().then(
      function (found) {
        return found || null;
      },
      function () {
        return null;
      }
    );
  }

  // Sends one message to a worker and resolves with its reply, or null.
  function ask(worker, message) {
    return new Promise(function (resolve) {
      var done = false;
      function finish(value) {
        if (done) return;
        done = true;
        clearTimeout(timer);
        resolve(value);
      }
      var timer = setTimeout(function () {
        finish(null);
      }, ASK_MS);
      try {
        var channel = new MessageChannel();
        channel.port1.onmessage = function (event) {
          finish(event.data || null);
        };
        worker.postMessage(message, [channel.port2]);
      } catch (_) {
        finish(null);
      }
    });
  }

  // An installed worker waits only after it stored and verified its whole build,
  // so a waiting worker is an update that is ready. Resolves with its build id
  // when it is a different build from this page's, otherwise null.
  function readyBuild(found) {
    var waiting = found && found.waiting;
    if (!waiting) return Promise.resolve(null);
    return ask(waiting, {type: 'pantas-build-id'}).then(function (reply) {
      var id = reply && typeof reply.id === 'string' && reply.id ? reply.id : null;
      return id && id !== buildVersion ? id : null;
    });
  }

  // Asks the waiting worker to take over and reloads into the new build. The
  // worker agrees only when this is the only window of the app, because it
  // deletes the older build's files when it activates. Resolves true when a
  // reload is under way.
  function swap(found) {
    return readyBuild(found).then(function (id) {
      if (!id) return false;
      var reloading = false;
      function reload() {
        if (reloading) return;
        reloading = true;
        window.location.reload();
      }
      navigator.serviceWorker.addEventListener('controllerchange', reload);
      return ask(found.waiting, {type: 'pantas-take-over'}).then(function (reply) {
        if (!reply || reply.ok !== true) {
          navigator.serviceWorker.removeEventListener('controllerchange', reload);
          return false;
        }
        // The worker is activating. Reload when it controls this page, or anyway if
        // that takes too long.
        setTimeout(reload, 5000);
        return true;
      });
    });
  }

  // Detection only. The app chooses a safe point and flushes local writes before
  // calling apply. An update is available when a worker that verified its whole
  // build is waiting, never merely because the server names a newer build: a
  // build whose install failed must not make the page reload again and again.
  var checkingUpdate = null;
  var updateTimer = null;
  function checkUpdate() {
    if (checkingUpdate) return checkingUpdate;
    if (buildVersion === null) return Promise.resolve({available: false, version: null});
    var timeout;
    checkingUpdate = Promise.race([
      registration()
        .then(function (found) {
          if (!found) return null;
          // Ask the browser to look for a new worker now; it would otherwise check once a day.
          return Promise.resolve(found.update()).then(
            function () {
              return found;
            },
            function () {
              return found;
            }
          );
        })
        .then(readyBuild)
        .then(function (id) {
          return {available: id !== null, version: id};
        }),
      new Promise(function (_, reject) {
        timeout = setTimeout(function () {
          reject(new Error('Version check timed out'));
        }, 4000);
      }),
    ]).finally(function () {
      clearTimeout(timeout);
      checkingUpdate = null;
    });
    return checkingUpdate;
  }
  function scheduleUpdateCheck() {
    if (!window.document || updateTimer !== null) return;
    updateTimer = setTimeout(function () {
      updateTimer = null;
      scheduleUpdateCheck();
      if (document.visibilityState === 'visible') return checkUpdate().catch(function () {});
    }, 5 * 60 * 1000);
  }
  window.pantasUpdate = {
    currentVersion: null,
    check: checkUpdate,
    // Takes over into the waiting build when this is the only window. With another
    // window open it does nothing: that window may still be running this build.
    apply: function () {
      return registration().then(swap);
    },
  };
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
    // Forced update: asks the browser for the newest worker, takes over into it
    // when one is ready and this is the only window, and reloads. It never
    // unregisters the worker or deletes a cache, so a lost connection leaves the
    // installed build bootable. Always reloads.
    updateNow: function () {
      return registration()
        .then(function (found) {
          if (!found) return false;
          return Promise.resolve(found.update())
            .catch(function () {})
            .then(function () {
              return swap(found);
            });
        })
        .catch(function () {
          return false;
        })
        .then(function (reloading) {
          if (!reloading) window.location.reload();
        });
    },
  };
})();
