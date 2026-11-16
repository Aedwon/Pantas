#!/usr/bin/env node
// Free-tier check (written rule 7, docs/workflow/process-improvement.md). Only real users may cost
// money, so the fixed and housekeeping items in the repository's deploy config must stay inside the
// free tiers, counted across pantas-prod and pantas-staging together (one billing account).
//
//   node tool/checks/free_tier.mjs                     checks the repository (needs `npm ci && npm run build` in functions/)
//   node tool/checks/free_tier.mjs --snapshot <file>   checks a recorded state, e.g. fixtures/free_tier_nov14.json
//
// It runs firebase-functions discovery once per project with that project's functions/.env file, the
// way a deploy does, and fails when:
//   - scheduled functions exceed 3 (Cloud Scheduler: 3 free jobs per billing account, paused ones count);
//   - any endpoint has minInstances above 0;
//   - distinct secret names times the projects that deploy them exceed 6 (Secret Manager: 6 free
//     versions), unless a valid waiver covers it (none now: two secrets per project, PANTAS_PAYMENT_SECRETS and PANTAS_APP_SECRETS, 4 in all);
//   - WARMUP_ENABLED is true anywhere but prod, or on prod after the end date in the waiver file
//     unless the warm-up code itself stops by a recorded end date (WARMUP_ENDS_AT in functions/src/keepWarm.ts)
//     no later than that date;
//   - a file under tool/, .github/ or functions/ fetches app files from *.web.app or *.firebaseapp.com
//     (Firebase Hosting bills every byte of egress).
// Waivers: tool/checks/free_tier_waivers.json. A waiver warns and passes until its date or ceiling is
// passed. Its ceiling and date cannot rise (free_tier.test.mjs compares with origin/main).
// The live account is checked by free_tier_live.mjs, by hand or on a schedule: CI has no cloud login.
import {execFileSync} from 'node:child_process';
import {existsSync, readFileSync} from 'node:fs';
import {join} from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

export const PROJECTS = ['pantas-prod', 'pantas-staging'];
export const PROD = 'pantas-prod';
export const LIMITS = {scheduled: 3, secrets: 6};
const MANILA = '+08:00';
const ROOT = fileURLToPath(new URL('../..', import.meta.url));

export const loadWaivers = (root = ROOT) => JSON.parse(readFileSync(join(root, 'tool/checks/free_tier_waivers.json'), 'utf8'));

export function parseEnv(text) {
  const env = {};
  for (const line of text.split('\n')) {
    const match = /^([A-Z0-9_]+)=(.*)$/.exec(line);
    if (match) env[match[1]] = match[2];
  }
  return env;
}

/** Runs firebase-functions' own loader in a clean process, with the project's .env file, like a deploy. */
export function discoverProject(project, root = ROOT, envOverride = {}) {
  const functionsDir = join(root, 'functions');
  if (!existsSync(join(functionsDir, 'lib/index.js')) || !existsSync(join(functionsDir, 'node_modules/firebase-functions'))) {
    throw new Error('functions/ is not built: run `npm ci && npm run build` in functions/ first');
  }
  const env = {...parseEnv(readFileSync(join(functionsDir, `.env.${project}`), 'utf8')), ...envOverride};
  const script = `
    const loader = require(${JSON.stringify(join(functionsDir, 'node_modules/firebase-functions/lib/runtime/loader.js'))});
    loader.loadStack(${JSON.stringify(functionsDir)}).then((stack) => {
      process.stdout.write(JSON.stringify({endpoints: stack.endpoints, params: stack.params ?? []}));
    }).catch((error) => { console.error(error); process.exit(1); });`;
  const output = execFileSync(process.execPath, ['-e', script], {
    env: {PATH: process.env.PATH, HOME: process.env.HOME, GCLOUD_PROJECT: project, ...env},
    cwd: functionsDir, encoding: 'utf8',
  });
  const stack = JSON.parse(output);
  const endpoints = Object.entries(stack.endpoints).map(([name, e]) => ({
    name, schedule: e.scheduleTrigger?.schedule ?? null, minInstances: e.minInstances ?? null,
  }));
  const secrets = new Set(stack.params.filter((p) => p.type === 'secret').map((p) => p.name));
  for (const e of Object.values(stack.endpoints)) for (const s of e.secretEnvironmentVariables ?? []) secrets.add(s.key);
  return {endpoints, secrets: [...secrets].sort(), env};
}

export const discoverAll = (root = ROOT, overrides = {}) => Object.fromEntries(PROJECTS.map((p) => [p, discoverProject(p, root, overrides[p])]));

const TEXT_FILE = /\.(mjs|cjs|js|ts|sh|ya?ml|jsonc?|dart|py|md|txt|toml|html)$/;
const OWN_FILES = /^tool\/checks\/(free_tier[^/]*|fixtures\/.*)$/;

/** The tracked text files the egress scan reads: everything under tool/, .github/ and functions/. */
export function listScannedFiles(root = ROOT) {
  const names = execFileSync('git', ['ls-files', '-z', 'tool', '.github', 'functions'], {cwd: root, encoding: 'utf8', maxBuffer: 1 << 28})
    .split('\0').filter(Boolean);
  const files = [];
  for (const path of names) {
    if (OWN_FILES.test(path) || !TEXT_FILE.test(path) || path === 'functions/package-lock.json' || !existsSync(join(root, path))) continue;
    const text = readFileSync(join(root, path), 'utf8');
    if (!text.includes('\0')) files.push({path, text});
  }
  return files;
}

const FETCH_VERB = /\b(fetch\s*\(|curl\b|wget\b|https?\.get\s*\(|urlopen\s*\(|requests\.(get|post)|Invoke-WebRequest|axios|got\s*\()/;
const FIREBASE_URL = /https?:\/\/[^\s'"`)>,]*?\.(?:web\.app|firebaseapp\.com)(?![\w-])(\/[^\s'"`)>,]*|(?=[$/]))?/g;

/**
 * Pattern check, not a proof: a line that holds a *.web.app or *.firebaseapp.com URL is a hit when the
 * URL goes past the host (a path or a template) or the line itself fetches. Sign-in paths (/__/) and
 * a bare origin in config are allowed. A file in waivers.firebaseFetch (the emergency mirror) is skipped.
 * Known limit: a URL built from pieces in several lines is not seen.
 */
export function scanFirebaseFetches(files, waivers) {
  const allowed = new Set((waivers.firebaseFetch ?? []).map((w) => w.path));
  const hits = [];
  for (const {path, text} of files) {
    if (allowed.has(path)) continue;
    text.split('\n').forEach((line, index) => {
      for (const match of line.matchAll(FIREBASE_URL)) {
        const rest = line.slice(match.index + match[0].length - (match[1]?.length ?? 0));
        if (/^\/__\//.test(rest)) continue;
        const pastHost = (match[1] ?? '') !== '' || /^\$\{/.test(line.slice(match.index + match[0].length));
        if (pastHost || FETCH_VERB.test(line)) hits.push(`${path}:${index + 1}: ${line.trim().slice(0, 120)}`);
      }
    });
  }
  return hits;
}

/** The warm-up end date the code stops at (WARMUP_ENDS_AT in functions/src/keepWarm.ts), or null. */
export function readWarmupEndInCode(root = ROOT) {
  try {
    const text = readFileSync(join(root, 'functions/src/keepWarm.ts'), 'utf8');
    return /export const WARMUP_ENDS_AT = '([^']+)';/.exec(text)?.[1] ?? null;
  } catch {
    return null;
  }
}

const dayStart = (date) => new Date(`${date}T00:00:00${MANILA}`);

/** The waiver's ceiling and date may only fall. `previous` is the waiver file on origin/main. */
export function checkCeilingNeverRises(current, previous) {
  const errors = [];
  for (const [name, now] of Object.entries(current)) {
    if (typeof now !== 'object' || now === null || now.ceiling === undefined) continue;
    const before = previous[name];
    if (!before || before.ceiling === undefined) { errors.push(`waiver ${name}: a new waiver cannot be added after the first one (ceiling ${now.ceiling}); fix the item instead`); continue; }
    if (now.ceiling > before.ceiling) errors.push(`waiver ${name}: ceiling ${now.ceiling} is above the committed ${before.ceiling}`);
    if (dayStart(now.expires) > dayStart(before.expires)) errors.push(`waiver ${name}: expires ${now.expires} is later than the committed ${before.expires}`);
  }
  return errors;
}

const stopsInCodeBy = (codeEnd, end) => {
  const at = codeEnd ? new Date(codeEnd) : null;
  return at !== null && !Number.isNaN(at.getTime()) && at <= end;
};

/**
 * projects: {name: {endpoints: [{name, schedule, minInstances}], secrets: [names], env: {}}}
 * Returns {errors, warnings}: one line each.
 */
export function evaluate({projects, waivers, now, files, warmupEndsInCode = null}) {
  const errors = [];
  const warnings = [];

  const scheduled = Object.entries(projects).flatMap(([p, v]) => v.endpoints.filter((e) => e.schedule).map((e) => `${p}/${e.name}`));
  if (scheduled.length > LIMITS.scheduled) {
    errors.push(`scheduled functions: ${scheduled.length} across both projects (limit ${LIMITS.scheduled}): ${scheduled.join(', ')}`);
  }

  for (const [p, v] of Object.entries(projects)) {
    for (const e of v.endpoints) {
      if (e.minInstances !== null && e.minInstances !== 0 && !(typeof e.minInstances === 'number' && e.minInstances <= 0)) {
        errors.push(`${p}/${e.name}: minInstances ${JSON.stringify(e.minInstances)} (must be 0 or unset)`);
      }
    }
  }

  const secretCount = Object.values(projects).reduce((sum, v) => sum + v.secrets.length, 0);
  if (secretCount > LIMITS.secrets) {
    const w = waivers.secrets;
    const label = `secrets: ${secretCount} (distinct names times projects, limit ${LIMITS.secrets})`;
    if (!w) errors.push(label);
    else if (now >= dayStart(w.expires)) errors.push(`${label}: waiver expired on ${w.expires} (${w.reference})`);
    else if (secretCount > w.ceiling) errors.push(`${label}: above the waiver ceiling ${w.ceiling} (${w.reference})`);
    else warnings.push(`${label}: waived until ${w.expires}, ceiling ${w.ceiling} (${w.reference})`);
  }

  for (const [p, v] of Object.entries(projects)) {
    if (String(v.env?.WARMUP_ENABLED).toLowerCase() !== 'true') continue;
    const end = waivers.warmup?.endsAt ? new Date(waivers.warmup.endsAt) : null;
    if (p !== PROD) errors.push(`WARMUP_ENABLED is true on ${p}: warm-up may run on prod only`);
    else if (!end) errors.push(`WARMUP_ENABLED is true on ${p} and the waiver file has no warm-up end date`);
    else if (now >= end && stopsInCodeBy(warmupEndsInCode, end)) continue;
    else if (now >= end) errors.push(`WARMUP_ENABLED is still true on ${p} after its end date ${waivers.warmup.endsAt.slice(0, 10)} (${waivers.warmup.reference})`);
  }

  for (const hit of scanFirebaseFetches(files, waivers)) errors.push(`fetches app files from a Firebase address: ${hit}`);
  return {errors, warnings};
}

function main(argv) {
  const snapshot = argv.indexOf('--snapshot');
  const waivers = loadWaivers();
  let projects;
  let now = new Date();
  let files = [];
  let warmupEndsInCode = readWarmupEndInCode();
  if (snapshot >= 0) {
    const fixture = JSON.parse(readFileSync(argv[snapshot + 1], 'utf8'));
    projects = fixture.projects;
    if (fixture.now) now = new Date(fixture.now);
    warmupEndsInCode = fixture.warmupEndsInCode ?? null;
  } else {
    projects = discoverAll();
    files = listScannedFiles();
  }
  const {errors, warnings} = evaluate({projects, waivers, now, files, warmupEndsInCode});
  for (const [p, v] of Object.entries(projects)) {
    console.log(`INFO  ${p}: ${v.endpoints.filter((e) => e.schedule).length} scheduled, ${v.secrets.length} secrets, WARMUP_ENABLED=${v.env?.WARMUP_ENABLED ?? 'unset'}`);
  }
  for (const w of warnings) console.log(`WARN  ${w}`);
  for (const e of errors) console.log(`FAIL  ${e}`);
  console.log(errors.length ? `free-tier check failed (${errors.length})` : 'free-tier check passed');
  process.exit(errors.length ? 1 : 0);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
