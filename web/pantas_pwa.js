// Runs before Flutter. It keeps the browser's install event, which can fire
// before any Dart code exists, and registers the caching service worker.
(function () {
  'use strict';

  var state = { event: null, installed: false, listeners: [] };

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
  };
})();
