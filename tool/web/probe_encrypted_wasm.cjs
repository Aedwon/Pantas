let completed = false;
globalThis.pantasProbeFinished = () => {completed = true;};
process.on('beforeExit', () => {if (!completed) {console.error('FAIL: Dart main did not complete');process.exitCode = 1;}});
const fs = require('node:fs');
globalThis.self = globalThis;
globalThis.pantasWasmBytes = new Uint8Array(fs.readFileSync('web/sqlite3.wasm'));
require('../../build/probe_encrypted_wasm.js');
