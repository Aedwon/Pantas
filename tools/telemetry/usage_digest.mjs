#!/usr/bin/env node
// Builds a private usage digest from the screen records in Cloud Logging.
//
//   node tools/telemetry/usage_digest.mjs [--project pantas-prod] [--days 7]
//
// Reads `usage_visit` lines with the gcloud CLI, groups them by visit, and writes a Markdown file
// OUTSIDE the repository (default ~/Library/Application Support/Pantas/usage-digests/, or the
// folder in PANTAS_PRIVATE_DIR). It prints only the file path and the totals. Tester data never
// goes in the repository. See docs/OPERATIONS.md.
//
// When speed and error reports carry screen counts (usage telemetry step 2, off until signed off),
// it adds a second section for them: views per screen and how often each is a first and last screen.
import { execFileSync } from 'node:child_process';
import { mkdirSync, realpathSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { basename, dirname, isAbsolute, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';

const MAX_DAYS = 30; // Logs are kept 30 days.
const VISIT_ID = /^[0-9a-f]{16}$/;

// Screens a person passes through before the app proper: onboarding, the guardian steps and the
// gates. "First screen after setup" skips these.
const SETUP = (screen) =>
  screen.startsWith('onboarding') || screen.startsWith('guardian') ||
  ['auth_email_link', 'beta', 'update_required'].includes(screen);

const payloadOf = (entry) => {
  const payload = entry?.jsonPayload;
  return payload && typeof payload === 'object' ? payload : null;
};

function median(values) {
  if (!values.length) return null;
  const sorted = [...values].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 ? sorted[mid] : Math.round((sorted[mid - 1] + sorted[mid]) / 2);
}

const byCountThenName = (a, b) => b.count - a.count || a.screen.localeCompare(b.screen);

function tally(map, total) {
  return [...map].map(([screen, count]) => ({ screen, count, share: total ? count / total : 0 }))
    .sort(byCountThenName);
}

/**
 * Turns log entries into the numbers the digest prints. Pure: no files, no clock.
 *
 * Records of one visit are merged by visit id and ordered by their time. A screen's time on
 * screen is the gap to the next screen of the same visit, so the last screen of a visit has no
 * time and is left out of its median rather than counted as zero.
 */
export function aggregate(entries) {
  const visits = new Map(); // visit_id -> Map(`${t}|${s}` -> {s, t})
  let first = null;
  let last = null;
  for (const entry of entries) {
    const payload = payloadOf(entry);
    if (payload?.kind !== 'usage_visit') continue;
    if (typeof payload.visit_id !== 'string' || !VISIT_ID.test(payload.visit_id)) continue;
    if (!Array.isArray(payload.screens)) continue;
    for (const item of payload.screens) {
      if (typeof item?.s !== 'string' || !Number.isFinite(item.t)) continue;
      if (!visits.has(payload.visit_id)) visits.set(payload.visit_id, new Map());
      visits.get(payload.visit_id).set(`${item.t}|${item.s}`, { s: item.s, t: item.t });
    }
    if (typeof entry.timestamp === 'string') {
      if (first === null || entry.timestamp < first) first = entry.timestamp;
      if (last === null || entry.timestamp > last) last = entry.timestamp;
    }
  }

  const ends = new Map();
  const firsts = new Map();
  const afterSetup = new Map();
  const screens = new Map(); // screen -> { views, visitIds:Set, durations:[] }
  let views = 0;
  let visitCount = 0;
  for (const records of visits.values()) {
    const list = [...records.values()].sort((a, b) => a.t - b.t);
    if (!list.length) continue;
    visitCount += 1;
    views += list.length;
    const lastScreen = list[list.length - 1].s;
    ends.set(lastScreen, (ends.get(lastScreen) ?? 0) + 1);
    firsts.set(list[0].s, (firsts.get(list[0].s) ?? 0) + 1);
    const real = list.find((item) => !SETUP(item.s));
    if (real) afterSetup.set(real.s, (afterSetup.get(real.s) ?? 0) + 1);
    list.forEach((item, index) => {
      const row = screens.get(item.s) ?? { views: 0, seen: 0, durations: [], lastVisit: null };
      row.views += 1;
      if (row.lastVisit !== records) {
        row.seen += 1;
        row.lastVisit = records;
      }
      if (index < list.length - 1) row.durations.push(list[index + 1].t - item.t);
      screens.set(item.s, row);
    });
  }

  return {
    visits: visitCount,
    views,
    from: first,
    to: last,
    ends: tally(ends, visitCount),
    first: tally(firsts, visitCount),
    firstAfterSetup: tally(afterSetup, visitCount),
    screens: [...screens].map(([screen, row]) => ({
      screen,
      views: row.views,
      visits: row.seen,
      medianMs: median(row.durations),
      timed: row.durations.length,
    })).sort((a, b) => b.views - a.views || a.screen.localeCompare(b.screen)),
  };
}

/**
 * Screen counts from the speed and error reports (log kind `client_telemetry`, key `screens`).
 * Pure. These come from everyone who did not switch the reports off, so they are a separate
 * basis from the usage visits above and are never merged with them. A report carries a screen id,
 * whether it was a visit's first and last screen, and a count, and nothing that ties it to a
 * person or a visit.
 */
export function aggregateScreenCounts(entries) {
  const rows = new Map();
  let reports = 0;
  let views = 0;
  let firsts = 0;
  let lasts = 0;
  for (const entry of entries) {
    const payload = payloadOf(entry);
    if (payload?.kind !== 'client_telemetry' || !Array.isArray(payload.screens)) continue;
    let counted = false;
    for (const item of payload.screens) {
      if (typeof item?.s !== 'string' || !Number.isInteger(item.n) || item.n < 1) continue;
      counted = true;
      const row = rows.get(item.s) ?? { screen: item.s, views: 0, firsts: 0, lasts: 0 };
      row.views += item.n;
      views += item.n;
      if (item.first === true) { row.firsts += 1; firsts += 1; }
      if (item.last === true) { row.lasts += 1; lasts += 1; }
      rows.set(item.s, row);
    }
    if (counted) reports += 1;
  }
  return {
    reports, views, firsts, lasts,
    rows: [...rows.values()].sort((a, b) => b.views - a.views || a.screen.localeCompare(b.screen)),
  };
}

const percent = (share) => `${(share * 100).toFixed(1)}%`;
const seconds = (ms) => (ms === null ? 'n/a' : `${(ms / 1000).toFixed(1)} s`);

const table = (header, rows) => [
  `| ${header.join(' | ')} |`,
  `| ${header.map(() => '---').join(' | ')} |`,
  ...rows.map((row) => `| ${row.join(' | ')} |`),
].join('\n');

/** The Markdown text of the digest. */
export function renderDigest(summary, { project, days, generated, screenCounts }) {
  const head = [
    '# Pantas usage digest',
    '',
    `Project ${project}, last ${days} days, made ${generated.toISOString().slice(0, 10)}.`,
    'People who chose "Help improve Pantas by sharing usage data" only. No account or person is named.',
    '',
  ];
  const counts = renderScreenCounts(screenCounts);
  if (!summary.visits) {
    return [...head, 'No visits were recorded in this period.', '', ...counts].join('\n');
  }
  const span = summary.from ? ` Records from ${summary.from.slice(0, 10)} to ${summary.to.slice(0, 10)}.` : '';
  return [
    ...head,
    `${summary.visits} visits, ${summary.views} screen views.${span}`,
    '',
    '## Where visits end',
    '',
    'The last screen of each visit. A visit that ends on a screen may have stopped there or closed the page there.',
    '',
    table(['Screen', 'Visits ended', 'Share of visits'],
      summary.ends.map((r) => [r.screen, r.count, percent(r.share)])),
    '',
    '## What they open first',
    '',
    'The first screen of each visit, then the first screen after onboarding, the guardian steps and the gates.',
    '',
    table(['First screen', 'Visits', 'Share'],
      summary.first.map((r) => [r.screen, r.count, percent(r.share)])),
    '',
    table(['First screen after setup', 'Visits', 'Share'],
      summary.firstAfterSetup.map((r) => [r.screen, r.count, percent(r.share)])),
    '',
    '## How much each screen is used',
    '',
    'Median time is the gap to the next screen. The last screen of a visit has no gap, so it is not timed.',
    'A page left open in the background can make a gap long.',
    '',
    table(['Screen', 'Views', 'Visits that reached it', 'Median time on it', 'Timed views'],
      summary.screens.map((r) => [r.screen, r.views, r.visits, seconds(r.medianMs), r.timed])),
    '',
    ...counts,
  ].join('\n');
}

/** The optional screen counts section, as lines. Empty when there are no counts. */
function renderScreenCounts(counts) {
  if (!counts?.reports) return [];
  const share = (n, total) => percent(total ? n / total : 0);
  return [
    '## Screen counts, everyone',
    '',
    `${counts.reports} reports, ${counts.views} screen views. These come from the speed and error`,
    'reports, so they cover everyone who left those reports on, not only the people above.',
    'First is counted once per visit. Last is counted each time a page is hidden or closed, so a',
    'visit that was hidden and reopened can be counted more than once.',
    '',
    table(['Screen', 'Views', 'First screen', 'Share of firsts', 'Last screen', 'Share of lasts'],
      counts.rows.map((r) => [r.screen, r.views, r.firsts, share(r.firsts, counts.firsts),
        r.lasts, share(r.lasts, counts.lasts)])),
    '',
  ];
}

/** The Cloud Logging filter for usage records in the last `days` days. */
export function buildFilter(days, now = new Date()) {
  const since = new Date(now.getTime() - days * 24 * 60 * 60 * 1000).toISOString();
  return `jsonPayload.kind="usage_visit" AND timestamp>="${since}"`;
}

/** The Cloud Logging filter for speed and error reports that carry screen counts. */
export function buildScreenCountsFilter(days, now = new Date()) {
  const since = new Date(now.getTime() - days * 24 * 60 * 60 * 1000).toISOString();
  return `jsonPayload.kind="client_telemetry" AND jsonPayload.screens:* AND timestamp>="${since}"`;
}

/** The folder digests are written to. Never inside the repository. */
export function privateDir(env = process.env) {
  if (env.PANTAS_PRIVATE_DIR) return resolve(env.PANTAS_PRIVATE_DIR);
  return join(homedir(), 'Library', 'Application Support', 'Pantas', 'usage-digests');
}

/**
 * The real path of `path`. A folder that does not exist yet is resolved through its nearest
 * existing parent, so a symlink anywhere above it is followed.
 */
function realPathOf(path) {
  let current = resolve(path);
  const rest = [];
  for (;;) {
    try {
      return join(realpathSync(current), ...rest);
    } catch (error) {
      const parent = dirname(current);
      if (error?.code !== 'ENOENT' || parent === current) throw error;
      rest.unshift(basename(current));
      current = parent;
    }
  }
}

/** Throws when `dir` is the repository or inside it. */
export function assertOutsideRepo(dir, repoRoot) {
  const rel = relative(realPathOf(repoRoot), realPathOf(dir));
  if (rel === '' || (rel !== '..' && !rel.startsWith(`..${sep}`) && !isAbsolute(rel))) {
    throw new Error(`Refusing to write usage data inside the repository: ${dir}`);
  }
}

export const digestFileName = (date) => `usage-digest-${date.toISOString().slice(0, 10)}.md`;

function readEntries(project, filter) {
  const raw = execFileSync('gcloud', [
    'logging', 'read', filter, `--project=${project}`, '--format=json', '--limit=100000',
  ], { encoding: 'utf8', maxBuffer: 512 * 1024 * 1024 });
  return JSON.parse(raw || '[]');
}

function main() {
  const { values } = parseArgs({
    options: { project: { type: 'string', default: 'pantas-prod' }, days: { type: 'string', default: '7' } },
  });
  const days = Number(values.days);
  if (!Number.isInteger(days) || days < 1 || days > MAX_DAYS) {
    throw new Error(`--days must be a whole number from 1 to ${MAX_DAYS}`);
  }
  const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
  const dir = privateDir();
  assertOutsideRepo(dir, repoRoot);
  const generated = new Date();
  const summary = aggregate(readEntries(values.project, buildFilter(days)));
  const screenCounts = aggregateScreenCounts(readEntries(values.project, buildScreenCountsFilter(days)));
  mkdirSync(dir, { recursive: true });
  const file = join(dir, digestFileName(generated));
  writeFileSync(file, renderDigest(summary, { project: values.project, days, generated, screenCounts }), { mode: 0o600 });
  console.log(file);
  console.log(`${summary.visits} visits, ${summary.views} screen views`);
  if (screenCounts.reports) {
    console.log(`${screenCounts.reports} reports with screen counts, ${screenCounts.views} screen views`);
  }
}

if (process.argv[1] && realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}
