// Loaded only by the isolated Functions emulator. Block external HTTP clients.
const {networkInterfaces} = require('node:os');
const {syncBuiltinESMExports} = require('node:module');
function local(url) {
  const host = new URL(url).hostname;
  if (!['localhost', '[::1]', ...Object.values(networkInterfaces()).flat().map(row => row?.address)].includes(host)) {
    throw Error(`Local runner blocked external service: ${host}`);
  }
}
const originalFetch = global.fetch;
global.fetch = (url, options) => { local(typeof url === 'string' || url instanceof URL ? url : url.url); return originalFetch(url, options); };
for (const scheme of ['http', 'https']) {
  const mod = require(`node:${scheme}`);
  for (const method of ['request', 'get']) {
    const original = mod[method];
    mod[method] = function (url, ...args) {
      if (typeof url === 'string' || url instanceof URL) local(url);
      else local(`${scheme}://${url.hostname || url.host || 'localhost'}`);
      return original.call(this, url, ...args);
    };
  }
}
syncBuiltinESMExports();
