#!/usr/bin/env node
// Reads the speed and error reports from Cloud Logging and prints typical and slowest times.
//
//   node tools/telemetry/report.mjs --project pantas-prod --hours 24 [--build <id>] [--visit return]
//
// Needs the gcloud CLI signed in with permission to read logs. See README.md.
import { execFileSync } from 'node:child_process';
import { realpathSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';

const VISITS = ['first', 'return', 'after_deploy'];
const MAX_HOURS = 720; // Logs are kept 30 days.

/** Nearest-rank percentile of `values` (p from 0 to 100), or null when there are none. */
export function percentile(values, p) {
  if (!values.length) return null;
  const sorted = [...values].sort((a, b) => a - b);
  const rank = Math.max(1, Math.ceil((p / 100) * sorted.length));
  return sorted[Math.min(rank, sorted.length) - 1];
}

const payloadOf = (entry) => {
  const payload = entry?.jsonPayload;
  return payload && typeof payload === 'object' ? payload : null;
};

/** Keeps `fn_timing` lines and the client reports that match the wanted build and visit. */
export function filterEntries(entries, { build, visit } = {}) {
  return entries.filter((entry) => {
    const payload = payloadOf(entry);
    if (payload?.kind !== 'client_telemetry') return true;
    return (!build || payload.build === build) && (!visit || payload.visit === visit);
  });
}

const byNumber = (field) => (a, b) => a[field] - b[field];

/** Turns log entries into the numbers the readout prints. */
export function summarize(entries) {
  const timings = new Map();
  const calls = new Map();
  const errors = new Map();
  let reports = 0;
  let callCount = 0;

  for (const entry of entries) {
    const payload = payloadOf(entry);
    if (payload?.kind === 'client_telemetry') {
      reports += 1;
      for (const timing of Array.isArray(payload.timings) ? payload.timings : []) {
        if (typeof timing?.n !== 'string' || !Number.isFinite(timing.ms)) continue;
        if (!timings.has(timing.n)) timings.set(timing.n, []);
        timings.get(timing.n).push(timing.ms);
      }
      for (const error of Array.isArray(payload.errors) ? payload.errors : []) {
        if (typeof error?.type !== 'string') continue;
        const frame = Array.isArray(error.stack) && typeof error.stack[0] === 'string' ? error.stack[0] : '';
        const key = `${error.type}\n${frame}`;
        const row = errors.get(key) ?? { type: error.type, frame, count: 0, reports: 0, sample: String(error.msg ?? '') };
        row.count += Number.isInteger(error.count) ? error.count : 1;
        row.reports += 1;
        errors.set(key, row);
      }
    } else if (payload?.kind === 'fn_timing' && typeof payload.fn === 'string' && Number.isFinite(payload.ms)) {
      callCount += 1;
      const row = calls.get(payload.fn) ?? { ms: [], cold: 0, errors: 0 };
      row.ms.push(payload.ms);
      if (payload.cold === true) row.cold += 1;
      if (payload.outcome === 'error') row.errors += 1;
      calls.set(payload.fn, row);
    }
  }

  return {
    reports,
    calls: callCount,
    timings: [...timings].map(([name, ms]) => ({
      name, count: ms.length, p50: percentile(ms, 50), p90: percentile(ms, 90), max: Math.max(...ms),
    })).sort((a, b) => a.name.localeCompare(b.name)),
    functions: [...calls].map(([fn, row]) => ({
      fn, count: row.ms.length, p50: percentile(row.ms, 50), p90: percentile(row.ms, 90),
      coldShare: row.cold / row.ms.length, errors: row.errors,
    })).sort((a, b) => b.p90 - a.p90 || a.fn.localeCompare(b.fn)),
    errors: [...errors.values()].sort((a, b) => b.count - a.count || a.type.localeCompare(b.type) || a.frame.localeCompare(b.frame)),
  };
}

const row = (cells, widths) => cells.map((cell, i) => String(cell).padEnd(widths[i])).join('  ').trimEnd();

/** Plain-text readout of a `summarize` result. */
export function formatReport(summary) {
  if (!summary.reports && !summary.calls) return 'No reports found for that period.\n';
  const lines = [`${summary.reports} client reports, ${summary.calls} function calls`, ''];
  if (summary.timings.length) {
    lines.push('Client timings (ms)', row(['name', 'count', 'p50', 'p90', 'max'], [26, 6, 8, 8, 8]));
    for (const t of summary.timings) lines.push(row([t.name, t.count, t.p50, t.p90, t.max], [26, 6, 8, 8, 8]));
    lines.push('');
  }
  if (summary.functions.length) {
    lines.push('Functions (ms)', row(['function', 'count', 'p50', 'p90', 'cold', 'errors'], [26, 6, 8, 8, 6, 6]));
    for (const f of summary.functions) {
      lines.push(row([f.fn, f.count, f.p50, f.p90, `${Math.round(f.coldShare * 100)}%`, f.errors], [26, 6, 8, 8, 6, 6]));
    }
    lines.push('');
  }
  if (summary.errors.length) {
    lines.push('Errors', row(['type', 'count', 'reports', 'first stack line'], [26, 6, 8, 40]));
    for (const e of summary.errors) {
      lines.push(row([e.type, e.count, e.reports, e.frame || '(no stack)'], [26, 6, 8, 40]));
      if (e.sample) lines.push(`    ${e.sample}`);
    }
    lines.push('');
  }
  return lines.join('\n');
}

/** Reads and checks the command line. Throws a plain Error with a usage message. */
export function parseArguments(argv) {
  const { values } = parseArgs({
    args: argv,
    options: { project: { type: 'string' }, hours: { type: 'string' }, build: { type: 'string' }, visit: { type: 'string' } },
    strict: true,
  });
  if (!values.project || !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/.test(values.project)) {
    throw new Error('--project is required and must be a Google Cloud project id, for example pantas-prod');
  }
  const hours = values.hours === undefined ? 24 : Number(values.hours);
  if (!Number.isFinite(hours) || hours <= 0 || hours > MAX_HOURS) throw new Error(`--hours must be above 0 and at most ${MAX_HOURS}`);
  if (values.build !== undefined && !/^[A-Za-z0-9._-]{1,40}$/.test(values.build)) throw new Error('--build must be a build id');
  if (values.visit !== undefined && !VISITS.includes(values.visit)) throw new Error(`--visit must be one of ${VISITS.join(', ')}`);
  return { project: values.project, hours, build: values.build, visit: values.visit };
}

/** Arguments for `gcloud`, passed without a shell. */
export function buildGcloudArgs({ project, hours }) {
  return [
    'logging', 'read', 'jsonPayload.kind=("client_telemetry" OR "fn_timing")',
    `--project=${project}`, `--freshness=${hours}h`, '--format=json', '--limit=100000',
  ];
}

function main() {
  let options;
  try {
    options = parseArguments(process.argv.slice(2));
  } catch (error) {
    console.error(`${error.message}\nUsage: node tools/telemetry/report.mjs --project <id> [--hours 24] [--build <id>] [--visit first|return|after_deploy]`);
    process.exit(2);
  }
  const output = execFileSync('gcloud', buildGcloudArgs(options), { encoding: 'utf8', maxBuffer: 512 * 1024 * 1024 });
  process.stdout.write(formatReport(summarize(filterEntries(JSON.parse(output || '[]'), options))));
}

if (process.argv[1] && realpathSync(process.argv[1]) === realpathSync(fileURLToPath(import.meta.url))) main();
