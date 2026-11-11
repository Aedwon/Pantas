// Splits the backend test files across CI jobs. CI speed plan S7.
//
// Usage (from the repository root or functions/):
//   node tool/ci/split_functions_tests.mjs --job N [--jobs 2] --kind plain|emulator
//       prints the files of job N (1-based) of that kind, one per line
//   node tool/ci/split_functions_tests.mjs --check [--jobs 2]
//       checks that every file `npm test` would run runs exactly once
//
// `npm test` runs functions/test/*.test.mjs with no emulator, then
// *.rules.mjs and *.emulator.mjs together inside the Firebase emulators. The
// two kinds are split the same way here. Emulator files are balanced on file
// size, which tracks the number of tests. Job 1 also takes every plain file,
// so it starts the emulator share lighter.
//
// Only node built-ins are used.
import { readdirSync, statSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const testDir = join(root, 'functions', 'test');

function list(suffixes) {
  return readdirSync(testDir)
    .filter((name) => suffixes.some((s) => name.endsWith(s)))
    .sort()
    .map((name) => `test/${name}`);
}

// The same globs as functions/package.json.
export const plainFiles = () => list(['.test.mjs']);
export const emulatorFiles = () => list(['.rules.mjs', '.emulator.mjs']);

const sizeOf = (file) => statSync(join(root, 'functions', file)).size;

/** Emulator files per job, longest first onto the lighter job. */
export function splitEmulator(files, jobs) {
  const total = files.reduce((sum, f) => sum + sizeOf(f), 0);
  const loads = Array.from({ length: jobs }, (_, i) => (i === 0 ? total * 0.1 : 0));
  const parts = Array.from({ length: jobs }, () => []);
  const ordered = [...files].sort((a, b) => sizeOf(b) - sizeOf(a) || a.localeCompare(b));
  for (const file of ordered) {
    let lightest = 0;
    for (let i = 1; i < jobs; i++) if (loads[i] < loads[lightest]) lightest = i;
    parts[lightest].push(file);
    loads[lightest] += sizeOf(file);
  }
  return parts.map((p) => p.sort());
}

const args = process.argv.slice(2);
const flag = (name, fallback) => {
  const i = args.indexOf(name);
  return i < 0 ? fallback : args[i + 1];
};
const jobs = Number(flag('--jobs', '2'));

if (args.includes('--check')) {
  const expected = [...plainFiles(), ...emulatorFiles()].sort();
  const seen = new Map();
  const problems = [];
  const parts = splitEmulator(emulatorFiles(), jobs);
  for (let job = 1; job <= jobs; job++) {
    const mine = [...(job === 1 ? plainFiles() : []), ...parts[job - 1]];
    if (parts[job - 1].length === 0) problems.push(`job ${job} has no emulator files`);
    for (const file of mine) {
      if (seen.has(file)) problems.push(`${file} runs in job ${seen.get(file)} and job ${job}`);
      seen.set(file, job);
    }
  }
  for (const file of expected) if (!seen.has(file)) problems.push(`${file} runs nowhere`);
  for (const file of seen.keys()) if (!expected.includes(file)) problems.push(`${file} is not a test file`);
  console.log(`${expected.length} backend test files in ${jobs} jobs: ` +
    `${[...Array(jobs).keys()].map((i) => parts[i].length).join(', ')} emulator files per job, ` +
    `${plainFiles().length} plain files in job 1`);
  if (problems.length) {
    console.error(problems.sort().join('\n'));
    process.exit(1);
  }
  console.log('backend partition ok');
} else {
  const job = Number(flag('--job', '0'));
  const kind = flag('--kind', '');
  if (!(job >= 1 && job <= jobs) || !['plain', 'emulator'].includes(kind)) {
    console.error('give --job N (1-based) and --kind plain|emulator, or --check');
    process.exit(64);
  }
  const files = kind === 'plain'
    ? (job === 1 ? plainFiles() : [])
    : splitEmulator(emulatorFiles(), jobs)[job - 1];
  if (files.length) console.log(files.join('\n'));
}
