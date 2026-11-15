#!/usr/bin/env node
// Refuses a functions deploy from a tree that is behind origin/main (Nov 15, 2026: a 3-day-old
// branch still carried the original beta dates in functions/.env.pantas-prod). Runs as the first
// functions predeploy step in firebase.json and firebase.staging.json, so every `firebase deploy`
// that includes functions checks it. A tree that contains origin/main (main itself, or a branch
// with main merged in) passes. Usage: node tool/deploy/require_current_main.mjs
import {execFileSync} from 'node:child_process';

const git = (...args) => execFileSync('git', args, {encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe']}).trim();
const refuse = (message) => { console.error(`Refusing to deploy functions: ${message}`); process.exit(1); };

try {
  git('fetch', '--quiet', 'origin', 'main');
} catch {
  refuse('could not fetch origin/main to check that this tree is current.');
}
const head = git('rev-parse', '--short', 'HEAD');
const main = git('rev-parse', '--short', 'origin/main');
let current = true;
try { git('merge-base', '--is-ancestor', 'origin/main', 'HEAD'); } catch { current = false; }
if (!current) {
  const behind = git('rev-list', '--count', 'HEAD..origin/main');
  refuse(`this tree (${head}) is ${behind} commits behind origin/main (${main}). Deploy from main, or merge main in first.`);
}
console.log(`Deploy source check: ${head} contains origin/main (${main}).`);
