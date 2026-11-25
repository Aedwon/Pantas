// A fake browser page for web/pantas_pwa.js: a service worker container with one
// registration, optionally a waiting worker that answers the page's messages like
// the real one (web/pantas_sw.js), and timers a test fires by hand.
import vm from 'node:vm';
import {readFileSync} from 'node:fs';

const source = readFileSync(new URL('../../../web/pantas_pwa.js', import.meta.url), 'utf8');

class FakeChannel {
  constructor() {
    const port1 = {onmessage: null};
    this.port1 = port1;
    // The page keeps port1; the worker answers on port2.
    this.port2 = {postMessage: (data) => Promise.resolve().then(() => port1.onmessage && port1.onmessage({data}))};
  }
}

/**
 * options:
 *  controller    script URL of the worker that controlled the page at load, or null
 *  supported     false for a browser without service workers
 *  registerFails true when register() rejects
 *  waiting       {id, windowsOk} a verified waiting worker, or null
 *  waitingAtLoad true when it is already waiting as the page loads; otherwise a test
 *                attaches it with page.arrive(), like an install that finishes later
 *  silentWaiting true when the waiting worker never answers
 *  updateFails   true when registration.update() rejects
 *  noPerformance true for a page with no performance API
 */
export function loadPage({
  controller = null, supported = true, registerFails = false, waiting = null, silentWaiting = false,
  updateFails = false, noPerformance = false, hasRegistration = true, waitingAtLoad = false,
} = {}) {
  const marks = [];
  const timers = [];
  const listeners = {};
  const posted = [];
  let reloads = 0;
  let updates = 0;
  const registered = [];
  const events = {};

  const waitingWorker = waiting && {
    state: 'installed',
    postMessage(message, ports = []) {
      posted.push(message);
      if (silentWaiting) return;
      const [port] = ports;
      if (message.type === 'pantas-build-id') port.postMessage({id: waiting.id});
      if (message.type === 'pantas-take-over') {
        port.postMessage({ok: waiting.windowsOk !== false});
        // The real worker skips waiting and claims the page: a controllerchange follows.
        if (waiting.windowsOk !== false) Promise.resolve().then(() => (events.controllerchange || []).slice().forEach((fn) => fn()));
      }
    },
  };
  const registration = {
    active: controller ? {scriptURL: controller} : null,
    waiting: waitingAtLoad ? waitingWorker : null,
    update: async () => {
      updates++;
      if (updateFails) throw new Error('worker offline');
    },
  };
  const sw = {
    controller: controller ? {scriptURL: controller} : null,
    register(script) {
      registered.push(script);
      if (registerFails) return Promise.reject(new Error('blocked'));
      return Promise.resolve(registration);
    },
    getRegistration: async () => (hasRegistration ? registration : undefined),
    addEventListener: (name, fn) => (events[name] = [...(events[name] || []), fn]),
    removeEventListener: (name, fn) => (events[name] = (events[name] || []).filter((f) => f !== fn)),
  };
  const document = {visibilityState: 'visible', addEventListener: (name, fn) => (listeners[name] = fn)};
  const window = {
    document,
    addEventListener() {},
    location: {reload: () => reloads++},
    performance: noPerformance ? undefined : {mark: (name) => marks.push(name)},
  };
  const context = vm.createContext({
    window, document, navigator: supported ? {serviceWorker: sw} : {}, Promise, encodeURIComponent, MessageChannel: FakeChannel,
    Error,
    setTimeout: (fn, ms) => {
      timers.push({fn, ms, cleared: false});
      return timers.length;
    },
    clearTimeout: (id) => {
      if (timers[id - 1]) timers[id - 1].cleared = true;
    },
  });
  vm.runInContext(source, context);
  return {
    window, pwa: window.pantasPwa, update: window.pantasUpdate, document, marks, timers, listeners, posted, registered, sw, registration,
    arrive: () => (registration.waiting = waitingWorker),
    reloads: () => reloads, updates: () => updates,
    // Fires the first timer waiting at `ms` that has not been cleared.
    fire: (ms) => timers.find((t) => t.ms === ms && !t.cleared)?.fn(),
    fireAll: (ms) => timers.filter((t) => t.ms === ms && !t.cleared).forEach((t) => t.fn()),
    controllerChange: () => (events.controllerchange || []).slice().forEach((fn) => fn()),
    listening: () => (events.controllerchange || []).length,
  };
}
