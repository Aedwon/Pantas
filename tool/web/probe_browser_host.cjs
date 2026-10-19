let completed = false;
globalThis.pantasProbeFinished = () => {completed = true;};
process.on('beforeExit', () => {if (!completed) {console.error('FAIL: Dart main did not complete');process.exitCode = 1;}});
// Synthetic browser storage adapters for Node probes. No production data.
const fs = require('node:fs');
const { webcrypto } = require('node:crypto');
// The probe loads a test-only module from a path the caller names explicitly,
// never from a shared default such as /tmp, so no other user can plant it.
if (!process.env.PANTAS_FAKE_IDB) {
  throw new Error('Set PANTAS_FAKE_IDB to the fake-indexeddb module path in a private directory (mktemp -d).');
}
const idb = require(process.env.PANTAS_FAKE_IDB);
Object.assign(globalThis, idb);
globalThis.self = globalThis;
globalThis.window = globalThis;
globalThis.location = new URL('https://pantas.test/');
globalThis.document = {baseURI: 'https://pantas.test/', scripts: [], currentScript: null};
globalThis.crypto = webcrypto;
class Directory {
  constructor(name = '') { this.name = name; this.entries = new Map(); }
  async getDirectoryHandle(name) {
    if (!this.entries.has(name)) this.entries.set(name, new Directory(name));
    return this.entries.get(name);
  }
  async getFileHandle(name) {
    if (!this.entries.has(name)) this.entries.set(name, new File(name));
    return this.entries.get(name);
  }
}
class File {
  constructor(name) { this.name = name; this.bytes = Buffer.alloc(0); }
  async createSyncAccessHandle() {
    const file = this;
    return {
      read(target, {at = 0} = {}) { return file.bytes.copy(new Uint8Array(target.buffer || target, target.byteOffset || 0, target.byteLength), 0, at); },
      write(source, {at = 0} = {}) {
        const bytes = Buffer.from(source.buffer || source, source.byteOffset || 0, source.byteLength);
        if (file.bytes.length < at + bytes.length) { const next = Buffer.alloc(at + bytes.length); file.bytes.copy(next); file.bytes = next; }
        bytes.copy(file.bytes, at); return bytes.length;
      },
      getSize() { return file.bytes.length; },
      truncate(n) { const next = Buffer.alloc(n); file.bytes.copy(next); file.bytes = next; },
      flush() {}, close() {},
    };
  }
}
const root = new Directory();
const held = new Set();
Object.defineProperty(globalThis, 'navigator', {value: {
  storage: {getDirectory: async () => root},
  locks: { async request(name, options, callback) {
    if (held.has(name)) return callback(null);
    held.add(name);
    try {return await callback({name});} finally {held.delete(name);}
  }},
}, configurable: true});
const wasm = fs.readFileSync(process.env.PANTAS_PROBE_WASM || 'web/sqlite3.wasm');
globalThis.fetch = async () => new Response(wasm, {headers: {'content-type': 'application/wasm'}});
function request(r) {return new Promise((resolve, reject) => {r.onsuccess=()=>resolve(r.result);r.onerror=()=>reject(r.error);});}
globalThis.pantasVerifyAtRest = async () => {
  const vault = await request(indexedDB.open('pantas-study-key-v1'));
  const record = await request(vault.transaction('keys').objectStore('keys').get('database'));
  if (record.wrappingKey.extractable !== false) throw Error('extractable wrapping key');
  if (Object.keys(record).sort().join(',') !== 'iv,wrapped,wrappingKey') throw Error('unexpected key material');
  if (record.wrapped.byteLength !== 48) throw Error('invalid ciphertext');
  vault.close();
  const db = await request(indexedDB.open('pantas-study-v1'));
  const blocks = await request(db.transaction('blocks').objectStore('blocks').getAll());
  const bytes = Buffer.concat(await Promise.all(blocks.map(async b => Buffer.from(b instanceof ArrayBuffer ? b : await b.arrayBuffer()))));
  if (bytes.includes(Buffer.from('synthetic-study-data')) || bytes.includes(Buffer.from('SQLite format 3'))) throw Error('plaintext persisted');
  if (bytes.length === 0) throw Error('no data persisted');
  db.close();
};
let savedBlock, blockKey;
globalThis.pantasTamperData = async (restore) => {
  const db = await request(indexedDB.open('pantas-study-v1'));
  if (!restore) {
    const cursor = await request(db.transaction('blocks').objectStore('blocks').openCursor());
    blockKey = cursor.key;
    savedBlock = cursor.value;
    const bad = savedBlock.slice(0);
    new Uint8Array(bad)[0] ^= 1;
    await request(db.transaction('blocks','readwrite').objectStore('blocks').put(bad, blockKey));
  } else {
    await request(db.transaction('blocks','readwrite').objectStore('blocks').put(savedBlock, blockKey));
  }
  db.close();
};
let saved;
globalThis.pantasTamperKey = async (restore) => {
  const vault = await request(indexedDB.open('pantas-study-key-v1'));
  if (!restore) {
    saved = await request(vault.transaction('keys').objectStore('keys').get('database'));
    const bad = {...saved, wrapped: saved.wrapped.slice(0)};
    new Uint8Array(bad.wrapped)[0] ^= 1;
    await request(vault.transaction('keys','readwrite').objectStore('keys').put(bad,'database'));
  } else {
    await request(vault.transaction('keys','readwrite').objectStore('keys').put(saved,'database'));
  }
  vault.close();
};
globalThis.pantasWasmBytes = new Uint8Array(fs.readFileSync('web/sqlite3.wasm'));
require('../../build/' + (process.env.PANTAS_PROBE_SCRIPT || 'probe_encrypted_wasm.js'));
