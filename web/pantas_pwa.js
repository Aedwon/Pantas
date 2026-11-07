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

  // Registers pantas_sw.js for this build and resolves once that exact build
  // controls the page, so no file is read through an older cache. Never
  // rejects and never waits long: without a worker the app loads from the
  // network as before.
  function registerWorker(version) {
    buildVersion = version;
    return registerForBuild(version).then(function (result) {
      mark('page.worker');
      return result;
    });
  }

  function registerForBuild(version) {
    if (!('serviceWorker' in navigator)) return Promise.resolve(false);
    var script = 'pantas_sw.js?v=' + encodeURIComponent(version);
    // First visit: no worker controls the page, so nothing stale can be
    // served. Register in the background and start the app at once.
    if (!navigator.serviceWorker.controller) {
      navigator.serviceWorker.register(script).catch(function () {});
      return Promise.resolve(false);
    }
    var timeout = new Promise(function (resolve) {
      setTimeout(function () {
        resolve(false);
      }, 4000);
    });
    var ready = navigator.serviceWorker
      .register(script)
      .then(function (registration) {
        return new Promise(function (resolve) {
          function active() {
            var worker = registration.active;
            return worker && worker.scriptURL.indexOf('?v=' + encodeURIComponent(version)) !== -1
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
          navigator.serviceWorker.addEventListener('controllerchange', check);
          var pending = registration.installing || registration.waiting;
          if (pending) pending.addEventListener('statechange', check);
          registration.addEventListener('updatefound', function () {
            if (registration.installing) {
              registration.installing.addEventListener('statechange', check);
            }
          });
        });
      })
      .catch(function () {
        return false;
      });
    return Promise.race([ready, timeout]);
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
    // Forced update: removes this browser's worker and cached app files, then
    // reloads so the next load comes from the network. Always reloads.
    updateNow: function () {
      var work = [];
      try {
        if ('serviceWorker' in navigator) {
          work.push(
            navigator.serviceWorker.getRegistrations().then(function (list) {
              return Promise.all(
                list.map(function (registration) {
                  return registration.unregister();
                })
              );
            })
          );
        }
        if (window.caches) {
          work.push(
            caches.keys().then(function (names) {
              return Promise.all(
                names
                  .filter(function (name) {
                    return name.indexOf('pantas-shell-') === 0;
                  })
                  .map(function (name) {
                    return caches.delete(name);
                  })
              );
            })
          );
        }
      } catch (_) {}
      return Promise.all(
        work.map(function (job) {
          return job.catch(function () {});
        })
      ).then(function () {
        window.location.reload();
      });
    },
  };
})();
