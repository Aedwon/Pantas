// The Firebase JavaScript SDK files the app loads, served from our own address.
//
// FlutterFire's web plugins (firebase_core_web) load these ES modules with import() from
// https://www.gstatic.com/firebasejs/<version>/. A phone that starts the app with no
// connection, or with Google's address blocked, never gets them, so the app never opens its
// storage (cold offline start, E-210). The page holds an import map that sends each of those
// addresses to the same file under web/firebase_sdk/<version>/. FlutterFire keeps its own
// loading code and its own version; only the address changes. The files are Google's
// unmodified bytes (Apache License 2.0; firebase-app.js keeps its license header), checked
// below by SHA-256. A browser without import maps loads them from gstatic, as before.
//
// The version is the one FlutterFire pins for the locked firebase_core_web (a test compares
// them), and the folder name carries it, so a new version is a new address.
//
// Usage: node tool/web/firebase_sdk.mjs   (downloads missing files into web/firebase_sdk/<version>/
// and refuses any bytes that do not match the list)
import {createHash} from 'node:crypto';
import {existsSync, mkdirSync, readFileSync, writeFileSync} from 'node:fs';
import {dirname, join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

export const SDK_VERSION = '12.17.0';
// The locked firebase_core_web (pubspec.lock) whose pinned SDK version this is.
export const LOCKED_FIREBASE_CORE_WEB = '3.10.0';
export const SDK_ORIGIN = `https://www.gstatic.com/firebasejs/${SDK_VERSION}/`;
// Where the page's address for each file ends up, relative to the page (the root of the app).
export const SDK_FOLDER = `firebase_sdk/${SDK_VERSION}/`;
// Every service FlutterFire's web plugins in pubspec.yaml load. firebase-app.js is the core;
// the others import it, and firestore loads as its pipelines bundle (firebase_core_web 3.10.0).
export const SDK_FILES = {
  'firebase-app.js': '5d2e0f381b796483addf65c39762bb033e6c6bdfe42b17adef6259df36b43094',
  'firebase-auth.js': 'f6ab1b8f99046a7533742d49dfd94984b385217b7a4e1a23ed2304bf612f0974',
  'firebase-firestore-pipelines.js': '3409cd059ac6313c67c0dbbe0f99bf16e6d2ed6a5ddefb6ca9cebe50d82a19cd',
  'firebase-app-check.js': '6cb2eb7750ca5f3cf6d0d26433c9963c058cfd642d22b18e90765d18493e84d1',
  'firebase-analytics.js': '814c30381d7576cb9644c5525846f2aaedd46ba017017b56cb1bbe9106d6f7a7',
  'firebase-messaging.js': 'bdf2bdd3c028ae87fd59ca1f409fb8d69b5f60977f11d2f58777e1dc9deb584e',
  'firebase-remote-config.js': '0ace9ee3f678ed1d14faf8d8005e349142435f3d3aedfb468e0c1a9b94a3a4b6',
  'firebase-storage.js': '23bbb78edb6ca044aab551e46dbcd0296fd3331a5dac3323187d4adbf5015708',
  'firebase-functions.js': '8a1a824713340f3742012ea93a66fb6ff05c0e6498835375b26406a28b7eed6d',
};
export const SDK_PATHS = Object.keys(SDK_FILES).map(name => SDK_FOLDER + name);

/** The import map the page carries: each address FlutterFire imports, to our copy. */
export const importMap = () => ({
  imports: Object.fromEntries(Object.keys(SDK_FILES).map(name => [SDK_ORIGIN + name, `./${SDK_FOLDER}${name}`])),
});

export const sha256 = bytes => createHash('sha256').update(bytes).digest('hex');

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const root = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', 'web', SDK_FOLDER);
  mkdirSync(root, {recursive: true});
  for (const [name, hash] of Object.entries(SDK_FILES)) {
    const path = join(root, name);
    if (existsSync(path) && sha256(readFileSync(path)) === hash) {
      console.log(`ok       ${name}`);
      continue;
    }
    const response = await fetch(SDK_ORIGIN + name);
    if (!response.ok) throw new Error(`${SDK_ORIGIN + name}: ${response.status}`);
    const bytes = Buffer.from(await response.arrayBuffer());
    if (sha256(bytes) !== hash) throw new Error(`${name} from ${SDK_ORIGIN} does not match the pinned SHA-256`);
    writeFileSync(path, bytes);
    console.log(`fetched  ${name} (${bytes.length} bytes)`);
  }
}
