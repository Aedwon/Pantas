// Prints a Firebase config for one rollback: the repository's own `app` hosting entry (its
// rewrites, headers and ignore list, from firebase.json for prod or firebase.staging.json for
// staging) with `public` set to the build folder. Both repository configs list their sites as an
// array, and the Firebase CLI refuses `--public` with an array ("Cannot specify --public option
// with multi-site configuration"), so the rollback gives it a config of its own instead.
// Usage: node tool/deploy/firebase_rollback_config.mjs staging|prod <build dir>
// Run by tool/deploy/firebase_rollback.sh, which writes the output to a temporary config file.
import {readFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

const repo = fileURLToPath(new URL('../../', import.meta.url));
const CONFIGS = {prod: 'firebase.json', staging: 'firebase.staging.json'};

export function rollbackConfig(env, build, root = repo) {
  if (!CONFIGS[env]) throw new Error('staging or prod');
  const hosting = JSON.parse(readFileSync(resolve(root, CONFIGS[env]), 'utf8')).hosting;
  const entry = (Array.isArray(hosting) ? hosting : [hosting]).find(site => site.target === 'app');
  if (!entry) throw new Error(`${CONFIGS[env]} has no hosting entry with target "app"`);
  return {hosting: {...entry, public: resolve(build)}};
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [env, build] = process.argv.slice(2);
  try {
    if (!build) throw new Error('Usage: node tool/deploy/firebase_rollback_config.mjs staging|prod <build dir>');
    console.log(JSON.stringify(rollbackConfig(env, build), null, 2));
  } catch (error) {
    console.error(error.message);
    process.exit(2);
  }
}
