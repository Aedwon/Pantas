import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, symlinkSync } from 'node:fs';
import { homedir, tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import test from 'node:test';
import {
  aggregate, aggregateScreenCounts, assertOutsideRepo, buildFilter, buildScreenCountsFilter,
  digestFileName, privateDir, renderDigest,
} from './usage_digest.mjs';

// Fake visits only. Nothing here is real tester data.
const line = (visit_id, screens, timestamp = '2026-11-10T01:00:00Z', build = 'b1') => ({
  timestamp,
  jsonPayload: { kind: 'usage_visit', v: 1, build, visit_id, screens: screens.map(([s, t]) => ({ s, t })) },
});

const VISITS = [
  // aaaa: home, study, lesson, then stops on lesson.
  line('aaaaaaaaaaaaaaaa', [['home', 0], ['study', 4000], ['lesson', 10000]]),
  // bbbb: arrives in two records, stops on settings. Home, quiz, then settings.
  line('bbbbbbbbbbbbbbbb', [['home', 0], ['quiz', 2000]]),
  line('bbbbbbbbbbbbbbbb', [['settings', 8000]]),
  // cccc: a new person finishing onboarding, first real screen is home, stops on study.
  line('cccccccccccccccc', [['onboarding', 0], ['onboarding_custom_name', 5000], ['home', 9000], ['study', 12000]]),
  // dddd: one screen only.
  line('dddddddddddddddd', [['study', 0]]),
];

test('visits are merged by visit id and ordered by time', () => {
  const out = aggregate(VISITS);
  assert.equal(out.visits, 4);
  assert.equal(out.views, 3 + 3 + 4 + 1);
});

test('where visits end: the last screen of each visit, counted with its share', () => {
  const out = aggregate(VISITS);
  const rows = Object.fromEntries(out.ends.map((r) => [r.screen, r]));
  assert.equal(rows.lesson.count, 1);
  assert.equal(rows.settings.count, 1);
  assert.equal(rows.study.count, 2);
  assert.equal(rows.study.share, 0.5);
  assert.deepEqual(out.ends.map((r) => r.screen), ['study', 'lesson', 'settings']);
});

test('what they open first: the first screen of a visit, and the first after setup screens', () => {
  const out = aggregate(VISITS);
  const first = Object.fromEntries(out.first.map((r) => [r.screen, r.count]));
  assert.deepEqual(first, { home: 2, onboarding: 1, study: 1 });
  const afterSetup = Object.fromEntries(out.firstAfterSetup.map((r) => [r.screen, r.count]));
  assert.deepEqual(afterSetup, { home: 3, study: 1 });
});

test('per screen: views, visits that reached it, and median time on it', () => {
  const out = aggregate(VISITS);
  const rows = Object.fromEntries(out.screens.map((r) => [r.screen, r]));
  assert.equal(rows.home.views, 3);
  assert.equal(rows.home.visits, 3);
  // home durations: aaaa 4000, bbbb 2000, cccc 3000. Median 3000.
  assert.equal(rows.home.medianMs, 3000);
  assert.equal(rows.home.timed, 3);
  // study: aaaa 6000 (4000 to 10000), cccc is last (unknown), dddd is last (unknown).
  assert.equal(rows.study.medianMs, 6000);
  assert.equal(rows.study.timed, 1);
  // lesson only appears as a last screen, so its time is unknown, not zero.
  assert.equal(rows.lesson.medianMs, null);
  assert.equal(rows.lesson.timed, 0);
});

test('a screen seen twice in one visit counts two views and one visit', () => {
  const out = aggregate([line('eeeeeeeeeeeeeeee', [['home', 0], ['study', 1000], ['home', 2000]])]);
  const home = out.screens.find((r) => r.screen === 'home');
  assert.equal(home.views, 2);
  assert.equal(home.visits, 1);
});

test('a record sent twice is counted once', () => {
  const once = line('ffffffffffffffff', [['home', 0], ['study', 1500]]);
  const out = aggregate([once, once]);
  assert.equal(out.views, 2);
});

test('lines that are not usage visits, or are malformed, are skipped', () => {
  const out = aggregate([
    { jsonPayload: { kind: 'client_telemetry', timings: [] } },
    { jsonPayload: { kind: 'usage_visit', visit_id: 'short', screens: [{ s: 'home', t: 0 }] } },
    { jsonPayload: { kind: 'usage_visit', visit_id: 'aaaaaaaaaaaaaaaa', screens: 'x' } },
    { jsonPayload: { kind: 'usage_visit', visit_id: 'aaaaaaaaaaaaaaaa', screens: [{ s: 3, t: 'x' }, null] } },
    null,
    {},
  ]);
  assert.equal(out.visits, 0);
  assert.equal(out.views, 0);
  assert.deepEqual(out.ends, []);
});

test('an empty input gives an empty digest without dividing by zero', () => {
  const out = aggregate([]);
  assert.equal(out.visits, 0);
  const text = renderDigest(out, { project: 'p', days: 7, generated: new Date('2026-11-14T00:00:00Z') });
  assert.match(text, /No visits/);
});

test('the digest names the three questions and holds counts, never ids', () => {
  const out = aggregate(VISITS);
  const text = renderDigest(out, { project: 'pantas-prod', days: 7, generated: new Date('2026-11-14T00:00:00Z') });
  assert.match(text, /Where visits end/);
  assert.match(text, /What they open first/);
  assert.match(text, /How much each screen is used/);
  assert.match(text, /4 visits/);
  assert.doesNotMatch(text, /aaaaaaaaaaaaaaaa|bbbbbbbbbbbbbbbb/);
});

test('the gcloud filter asks for usage visits in the date range', () => {
  const filter = buildFilter(7, new Date('2026-11-14T00:00:00Z'));
  assert.match(filter, /jsonPayload\.kind="usage_visit"/);
  assert.match(filter, /timestamp>="2026-11-07T00:00:00\.000Z"/);
});

test('the private folder defaults outside the repository and can be overridden', () => {
  assert.equal(privateDir({}), join(homedir(), 'Library', 'Application Support', 'Pantas', 'usage-digests'));
  assert.equal(privateDir({ PANTAS_PRIVATE_DIR: '/somewhere/else' }), resolve('/somewhere/else'));
});

test('a folder inside the repository is refused', () => {
  const repo = resolve('/work/Pantas');
  assert.throws(() => assertOutsideRepo('/work/Pantas/docs', repo), /repository/);
  assert.throws(() => assertOutsideRepo('/work/Pantas', repo), /repository/);
  assert.doesNotThrow(() => assertOutsideRepo('/work/Pantas-private', repo));
  assert.doesNotThrow(() => assertOutsideRepo('/Users/x/Library/Application Support/Pantas/usage-digests', repo));
});

test('a symlink that points into the repository is refused', () => {
  const base = mkdtempSync(join(tmpdir(), 'pantas-digest-'));
  const repo = join(base, 'repo');
  mkdirSync(join(repo, 'docs'), { recursive: true });
  const link = join(base, 'link');
  symlinkSync(join(repo, 'docs'), link);
  assert.throws(() => assertOutsideRepo(link, repo), /repository/);
  // A folder that does not exist yet, under a symlink into the repository.
  assert.throws(() => assertOutsideRepo(join(link, 'new', 'deeper'), repo), /repository/);
  // The repository reached through a symlink.
  const repoLink = join(base, 'repo-link');
  symlinkSync(repo, repoLink);
  assert.throws(() => assertOutsideRepo(join(repoLink, 'docs'), repo), /repository/);
  // A real folder elsewhere is fine, even if it does not exist yet.
  const elsewhere = join(base, 'private');
  mkdirSync(elsewhere);
  assert.doesNotThrow(() => assertOutsideRepo(join(elsewhere, 'digests'), repo));
});

test('the file name carries the date and no tester data', () => {
  assert.equal(digestFileName(new Date('2026-11-14T08:00:00Z')), 'usage-digest-2026-11-14.md');
});

// Screen counts from the speed and error reports (usage telemetry step 2). Fake data only.
const report = (screens, extra = {}) => ({
  timestamp: '2026-11-10T01:00:00Z',
  jsonPayload: {
    kind: 'client_telemetry', v: 1, build: 'b1', visit: 'return', browser: 'chrome', mobile: true,
    viewport: 'phone', timings: [], errors: [], screens, ...extra,
  },
});
const sc = (s, n, first = false, last = false) => ({ s, n, first, last });

const REPORTS = [
  report([sc('home', 2, true), sc('study', 1, false, true)]),
  report([sc('home', 3), sc('lesson', 1, false, true)]),
  report([sc('study', 4, true)]),
  report(undefined),
  { jsonPayload: { kind: 'client_telemetry', timings: [], errors: [] } },
];

test('screen counts: views per screen, and how often each is a first and a last screen', () => {
  const out = aggregateScreenCounts(REPORTS);
  assert.equal(out.reports, 3);
  assert.equal(out.views, 11);
  assert.equal(out.firsts, 2);
  assert.equal(out.lasts, 2);
  const rows = Object.fromEntries(out.rows.map((r) => [r.screen, r]));
  assert.deepEqual(rows.home, { screen: 'home', views: 5, firsts: 1, lasts: 0 });
  assert.deepEqual(rows.study, { screen: 'study', views: 5, firsts: 1, lasts: 1 });
  assert.deepEqual(rows.lesson, { screen: 'lesson', views: 1, firsts: 0, lasts: 1 });
  assert.deepEqual(out.rows.map((r) => r.screen), ['home', 'study', 'lesson']);
});

test('screen counts: other log kinds, usage visits and malformed entries are skipped', () => {
  const out = aggregateScreenCounts([
    VISITS[0],
    report('x'),
    report([null, 'home', { s: 3, n: 1 }, { s: 'home', n: 0 }, { s: 'home', n: 1.5 }, { s: 'home', n: 'a' }]),
    { jsonPayload: { kind: 'other', screens: [sc('home', 1)] } },
    null,
    {},
  ]);
  assert.equal(out.reports, 0);
  assert.equal(out.views, 0);
  assert.deepEqual(out.rows, []);
});

test('screen counts: an empty input has no reports and no rows', () => {
  const out = aggregateScreenCounts([]);
  assert.deepEqual(out, { reports: 0, views: 0, firsts: 0, lasts: 0, rows: [] });
});

test('screen counts: the gcloud filter asks for speed and error reports that carry screens', () => {
  const filter = buildScreenCountsFilter(7, new Date('2026-11-14T00:00:00Z'));
  assert.match(filter, /jsonPayload\.kind="client_telemetry"/);
  assert.match(filter, /jsonPayload\.screens:\*/);
  assert.match(filter, /timestamp>="2026-11-07T00:00:00\.000Z"/);
});

test('the digest has no screen counts section when there are none', () => {
  const text = renderDigest(aggregate(VISITS), { project: 'p', days: 7, generated: new Date('2026-11-14T00:00:00Z') });
  assert.doesNotMatch(text, /Screen counts/);
  const empty = renderDigest(aggregate([]), {
    project: 'p', days: 7, generated: new Date('2026-11-14T00:00:00Z'), screenCounts: aggregateScreenCounts([]),
  });
  assert.doesNotMatch(empty, /Screen counts/);
});

test('the digest prints the screen counts section, with shares, and names no visit', () => {
  const text = renderDigest(aggregate(VISITS), {
    project: 'p', days: 7, generated: new Date('2026-11-14T00:00:00Z'), screenCounts: aggregateScreenCounts(REPORTS),
  });
  assert.match(text, /## Screen counts, everyone/);
  assert.match(text, /\| home \| 5 \| 1 \| 50\.0% \| 0 \| 0\.0% \|/);
  assert.match(text, /\| lesson \| 1 \| 0 \| 0\.0% \| 1 \| 50\.0% \|/);
  assert.match(text, /3 reports, 11 screen views/);
});

test('the screen counts section shows even when there are no usage visits', () => {
  const text = renderDigest(aggregate([]), {
    project: 'p', days: 7, generated: new Date('2026-11-14T00:00:00Z'), screenCounts: aggregateScreenCounts(REPORTS),
  });
  assert.match(text, /No visits/);
  assert.match(text, /## Screen counts, everyone/);
});
