// Refuses a web build whose service worker is not stamped for exactly the files
// in it. An unstamped worker (the dev behavior) or a build changed after the stamp
// would leave phones with a worker that cannot verify its own app. Run by
// tool/cloudflare-app/deploy.sh before anything is uploaded.
// Usage: node tool/deploy/check_worker_stamp.mjs [build/web]
import {existsSync, readFileSync} from 'node:fs';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {fingerprints, workerBuild} from '../web/stamp_worker_version.mjs';

/** Returns a list of problems; empty means the worker matches the build. */
export function stampProblems(dir) {
  const path = join(dir, 'pantas_sw.js');
  if (!existsSync(path)) return ['pantas_sw.js is missing'];
  let build;
  try {
    build = workerBuild(readFileSync(path, 'utf8'));
  } catch (error) {
    return [error.message];
  }
  if (!build) return ['pantas_sw.js is unstamped: run node tool/web/stamp_worker_version.mjs after the build'];
  const problems = [];
  const expected = fingerprints(dir);
  for (const name of new Set([...Object.keys(expected), ...Object.keys(build.files)])) {
    if (!(name in build.files)) problems.push(`${name || 'page'} is in the build but not in the worker's list`);
    else if (!(name in expected)) problems.push(`${name} is in the worker's list but not in the build`);
    else if (build.files[name] !== expected[name]) problems.push(`${name} changed after the stamp`);
  }
  for (const required of ['main.dart.js', 'flutter_bootstrap.js', 'index.html', '']) {
    if (!(required in build.files)) problems.push(`${required || 'page'} is missing from the startup set`);
  }
  const bootstrap = readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8');
  if (!bootstrap.includes(`registerWorker("${build.id}"`)) {
    problems.push('flutter_bootstrap.js names another build than the worker');
  }
  const metadata = join(dir, 'version.json');
  if (existsSync(metadata) && JSON.parse(readFileSync(metadata, 'utf8')).pantasBuildVersion !== build.id) {
    problems.push('version.json names another build than the worker');
  }
  return problems;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const dir = process.argv[2] ?? 'build/web';
  const problems = stampProblems(dir);
  if (problems.length) {
    console.error(`Refusing ${dir}:\n- ${problems.join('\n- ')}`);
    process.exit(1);
  }
  console.log(`Worker stamp matches ${dir}`);
}
