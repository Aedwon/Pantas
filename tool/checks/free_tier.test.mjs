// Tests for free_tier.mjs. Came from: the Nov 15, 2026 rule 7 audit (docs/workflow/process-improvement.md).
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {existsSync, readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import test from 'node:test';
import {checkCeilingNeverRises, discoverAll, evaluate, listScannedFiles, loadWaivers, parseEnv, readWarmupEndInCode, scanFirebaseFetches} from './free_tier.mjs';

const root = fileURLToPath(new URL('../..', import.meta.url));
const waivers = loadWaivers(root);
const NOW = new Date('2026-11-15T12:00:00+08:00');

const endpoint = (name, schedule = null, minInstances = null) => ({name, schedule, minInstances});
const jobs = (n) => Array.from({length: n}, (_, i) => endpoint(`job${i}`, 'every 5 minutes'));
const secrets = (n) => Array.from({length: n}, (_, i) => `SECRET_${i}`);
const project = (over = {}) => ({endpoints: [endpoint('callable')], secrets: [], env: {}, ...over});
const run = (projects, over = {}) => evaluate({projects, waivers, now: NOW, files: [], ...over});
const withSecretsWaiver = {...waivers, secrets: {ceiling: 16, expires: '2026-11-24', reference: 'test waiver'}};
const clean = () => ({'pantas-prod': project(), 'pantas-staging': project()});

test('the Nov 14 state (18 scheduled functions) fails the check', () => {
  const fixture = JSON.parse(readFileSync(new URL('./fixtures/free_tier_nov14.json', import.meta.url), 'utf8'));
  const result = evaluate({projects: fixture.projects, waivers, now: new Date(fixture.now), files: []});
  assert.equal(Object.values(fixture.projects).map((p) => p.endpoints.filter((e) => e.schedule).length).join(), '9,9');
  assert.ok(result.errors.some((e) => /scheduled functions: 18 .*limit 3/.test(e)), result.errors.join('\n'));
  assert.ok(result.errors.some((e) => /secrets: 16 .*limit 6/.test(e)), 'eight secrets on each project fail with no waiver');
});

// Scheduler step 4 (docs/superpowers/decisions/2026-10-19-pwa-launch-log.md, "Scheduler follow-up") sets
// LEGACY_SCHEDULES=off in the prod env file and force-deploys. Until it lands, prod's committed env still
// schedules the nine old jobs (12 in all), and this check correctly fails on them.
const AFTER_STEP_4 = {'pantas-prod': {LEGACY_SCHEDULES: 'off'}};

test("today's config with scheduler step 4 applied passes with no secrets waiver (2 secrets in all)", () => {
  const projects = discoverAll(root, AFTER_STEP_4);
  const result = evaluate({projects, waivers, now: NOW, files: listScannedFiles(root)});
  assert.deepEqual(result.errors, []);
  assert.deepEqual(projects['pantas-prod'].secrets, ['PANTAS_SECRETS']);
  assert.deepEqual(projects['pantas-staging'].secrets, ['PANTAS_SECRETS']);
  assert.equal(waivers.secrets, undefined, 'the secrets waiver is gone');
});

test('the committed config passes, or fails only on scheduled functions while prod still has LEGACY_SCHEDULES=on', () => {
  const prodEnv = parseEnv(readFileSync(new URL('../../functions/.env.pantas-prod', import.meta.url), 'utf8'));
  const result = evaluate({projects: discoverAll(root), waivers, now: NOW, files: listScannedFiles(root)});
  const expected = prodEnv.LEGACY_SCHEDULES === 'off' ? 0 : 1;
  assert.equal(result.errors.length, expected, result.errors.join('\n'));
  if (expected) assert.match(result.errors[0], /scheduled functions: 12 /);
});

test('more than 3 scheduled functions across both projects fail; exactly 3 pass', () => {
  assert.deepEqual(run({'pantas-prod': project({endpoints: jobs(3)}), 'pantas-staging': project()}).errors, []);
  const result = run({'pantas-prod': project({endpoints: jobs(2)}), 'pantas-staging': project({endpoints: jobs(2)})});
  assert.match(result.errors.join('\n'), /scheduled functions: 4 .*limit 3/);
});

test('a minimum instance above 0 fails, including one set by a parameter', () => {
  assert.match(run({'pantas-prod': project({endpoints: [endpoint('warm', null, 1)]}), 'pantas-staging': project()}).errors.join('\n'), /warm.*minInstances 1/);
  assert.match(run({'pantas-prod': project({endpoints: [endpoint('p', null, '{{ params.MIN }}')]}), 'pantas-staging': project()}).errors.join('\n'), /minInstances/);
  assert.deepEqual(run({'pantas-prod': project({endpoints: [endpoint('z', null, 0)]}), 'pantas-staging': project()}).errors, []);
});

test('secrets over 6 fail without a waiver, and pass with a warning inside one', () => {
  const eight = {'pantas-prod': project({secrets: secrets(8)}), 'pantas-staging': project({secrets: secrets(8)})};
  const none = {...waivers, secrets: undefined};
  assert.match(run(eight, {waivers: none}).errors.join('\n'), /secrets: 16 .*limit 6/);
  const ok = run(eight, {waivers: withSecretsWaiver});
  assert.deepEqual(ok.errors, []);
  assert.match(ok.warnings.join('\n'), /secrets: 16 .*waived until 2026-11-24/);
  const three = {'pantas-prod': project({secrets: secrets(3)}), 'pantas-staging': project({secrets: secrets(3)})};
  assert.deepEqual(run(three, {waivers: none}), {errors: [], warnings: []});
});

test('a waiver fails when the count passes its ceiling or its date has passed', () => {
  const nine = {'pantas-prod': project({secrets: secrets(9)}), 'pantas-staging': project({secrets: secrets(8)})};
  assert.match(run(nine, {waivers: withSecretsWaiver}).errors.join('\n'), /secrets: 17 .*ceiling 16/);
  const eight = {'pantas-prod': project({secrets: secrets(8)}), 'pantas-staging': project({secrets: secrets(8)})};
  assert.match(run(eight, {waivers: withSecretsWaiver, now: new Date('2026-11-24T00:00:00+08:00')}).errors.join('\n'), /waiver expired/);
  assert.deepEqual(run(eight, {waivers: withSecretsWaiver, now: new Date('2026-11-23T23:59:00+08:00')}).errors, []);
});

test('warm-up is allowed on prod only, and only before its recorded end date', () => {
  const on = {WARMUP_ENABLED: 'true'};
  assert.deepEqual(run({'pantas-prod': project({env: on}), 'pantas-staging': project()}).errors, []);
  assert.match(run({'pantas-prod': project(), 'pantas-staging': project({env: on})}).errors.join('\n'), /WARMUP_ENABLED.*pantas-staging/);
  const late = run({'pantas-prod': project({env: on}), 'pantas-staging': project()}, {now: new Date('2026-11-24T00:00:00+08:00')});
  assert.match(late.errors.join('\n'), /WARMUP_ENABLED.*pantas-prod.*2026-11-24/);
  const off = run({'pantas-prod': project({env: {WARMUP_ENABLED: 'false'}}), 'pantas-staging': project()}, {now: new Date('2026-12-01T00:00:00+08:00')});
  assert.deepEqual(off.errors, []);
});

test('a warm-up that stops by the recorded end date in code passes past the date; an env-only warm-up still fails', () => {
  const on = {WARMUP_ENABLED: 'true'};
  const prod = {'pantas-prod': project({env: on}), 'pantas-staging': project()};
  const after = {now: new Date('2026-12-01T00:00:00+08:00')};
  assert.deepEqual(run(prod, {...after, warmupEndsInCode: '2026-11-23T16:00:00Z'}).errors, []);
  assert.deepEqual(run(prod, {...after, warmupEndsInCode: '2026-11-20T00:00:00Z'}).errors, []);
  assert.match(run(prod, {...after, warmupEndsInCode: null}).errors.join('\n'), /WARMUP_ENABLED.*pantas-prod.*2026-11-24/);
  assert.match(run(prod, {...after, warmupEndsInCode: '2026-12-31T00:00:00Z'}).errors.join('\n'), /WARMUP_ENABLED.*pantas-prod/);
  assert.match(run(prod, {...after, warmupEndsInCode: 'not a date'}).errors.join('\n'), /WARMUP_ENABLED.*pantas-prod/);
  // Staging stays refused whatever the code says.
  assert.match(run({'pantas-prod': project(), 'pantas-staging': project({env: on})}, {warmupEndsInCode: '2026-11-23T16:00:00Z'}).errors.join('\n'), /WARMUP_ENABLED.*pantas-staging/);
});

test('the repository code records the warm-up end date, and it is no later than the waiver file', () => {
  const end = readWarmupEndInCode(root);
  assert.equal(end, '2026-11-23T16:00:00Z');
  assert.ok(new Date(end) <= new Date(waivers.warmup.endsAt));
  assert.equal(readWarmupEndInCode('/nonexistent'), null);
});

const file = (path, text) => ({path, text});

test('a tool that fetches app files from a Firebase address is flagged', () => {
  const bad = [
    file('tool/x/mirror.mjs', 'const r = await fetch(`https://${site}.web.app${path}`);'),
    file('tool/x/get.sh', 'curl -s https://pantas-prod.web.app/main.dart.js -o out'),
    file('.github/workflows/w.yml', '      - run: wget https://pantas-staging-app.firebaseapp.com/index.html'),
    file('functions/scripts/s.mjs', "const u = 'https://pantas-prod.web.app/'; const r = await fetch(u);"),
  ];
  for (const f of bad) assert.equal(scanFirebaseFetches([f], waivers).length, 1, f.path);
});

test('sign-in paths, bare origins in config, the Hosting API and the waived emergency tool pass', () => {
  const good = [
    file('tool/x/a.mjs', "await fetch('https://pantas-prod.firebaseapp.com/__/auth/handler?x=1');"),
    file('tool/x/b.jsonc', '"vars": {"FIREBASE_ORIGIN": "https://pantas-staging-app.web.app"}'),
    file('tool/x/c.mjs', 'await fetch(`https://firebasehosting.googleapis.com/v1beta1/sites/${site}/releases`);'),
    file('tool/cloudflare-app/mirror.mjs', 'await fetch(`https://${site}.web.app${path}`);'),
  ];
  assert.deepEqual(scanFirebaseFetches(good, waivers), []);
});

test('the scanned files include tool, .github and functions, and skip this check and its fixtures', () => {
  const paths = listScannedFiles(root).map((f) => f.path);
  assert.ok(paths.some((p) => p.startsWith('tool/cloudflare-app/')));
  assert.ok(paths.some((p) => p.startsWith('.github/workflows/')));
  assert.ok(paths.some((p) => p.startsWith('functions/src/')));
  assert.ok(!paths.some((p) => p.startsWith('tool/checks/free_tier') || p.startsWith('tool/checks/fixtures/')));
});

test('the waiver ceiling cannot rise above the committed one', () => {
  const prev = {secrets: {ceiling: 16, expires: '2026-11-24'}};
  assert.deepEqual(checkCeilingNeverRises(prev, prev), []);
  assert.deepEqual(checkCeilingNeverRises({secrets: {ceiling: 12, expires: '2026-11-24'}}, prev), []);
  assert.deepEqual(checkCeilingNeverRises({}, prev), []);
  assert.match(checkCeilingNeverRises({secrets: {ceiling: 17, expires: '2026-11-24'}}, prev).join(), /ceiling 17.*16/);
  assert.match(checkCeilingNeverRises({secrets: {ceiling: 16, expires: '2026-12-31'}}, prev).join(), /expires/);
  assert.match(checkCeilingNeverRises(prev, {}).join(), /new waiver/);
});

test('the committed waiver ceiling does not exceed the one on origin/main', (t) => {
  let previous;
  try {
    previous = JSON.parse(execFileSync('git', ['show', 'origin/main:tool/checks/free_tier_waivers.json'], {cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore']}));
  } catch {
    t.skip('origin/main has no waiver file yet (first merge), or the ref is not fetched');
    return;
  }
  assert.deepEqual(checkCeilingNeverRises(waivers, previous), []);
});

test('the waiver file has no secrets waiver and records the warm-up end date', () => {
  assert.equal(waivers.secrets, undefined);
  assert.equal(waivers.warmup.endsAt, '2026-11-24T00:00:00+08:00');
  assert.ok(existsSync(new URL('./fixtures/free_tier_nov14.json', import.meta.url)));
});
