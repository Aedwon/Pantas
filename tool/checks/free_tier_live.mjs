#!/usr/bin/env node
// Live free-tier check (written rule 7, docs/workflow/process-improvement.md). READ-ONLY: it only
// issues GET requests. Run it by hand or from a scheduled agent, weekly and after every deploy. CI
// does not run it, because CI has no cloud credentials. The repository's deploy config is checked in
// CI by free_tier.mjs.
//
//   node tool/checks/free_tier_live.mjs
//
// Needs `gcloud auth login` as a user who can read the projects. It reads the billing account of
// pantas-prod at run time (no account id is stored in the repository), lists every project on that
// account, and prints one line per item: OK, WARN or OVER, with the count and the free limit. Exit 1
// if any item is OVER. Items:
//   Cloud Scheduler jobs in every location (paused and failed ones too), secret versions by state,
//   Artifact Registry size, last 24 h of Hosting egress, Firestore backups, bucket sizes, enabled
//   APIs that bill on use, alert policies and whether the Cloud Billing catalog lists an alerting SKU,
//   reCAPTCHA CreateAssessment daily caps, Firestore daily reads and writes for 7 days, minimum
//   instances, and that each project has its billing-cutoff function.
import {execFileSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {loadWaivers} from './free_tier.mjs';

const MIB = 1024 * 1024;
const GIB = 1024 * MIB;
export const FREE = {
  schedulerJobs: 3,
  secretVersions: 6,
  registryBytes: 0.5 * GIB,
  hostingEgressPerDay: 360e6,
  freeRegionBytes: 5 * GIB,
  // No free tier outside the three US regions. Fable 5.2 ruling 6 accepts function sources (about
  // 0.06 GiB a project, about $0.002 a month); a gigabyte or more is a leak.
  otherRegionBytesOver: 1 * GIB,
  recaptchaPerMonth: 10000,
  firestoreReadsPerDay: 50000,
  firestoreWritesPerDay: 20000,
  firestoreDeletesPerDay: 20000,
};
// Staging has no real users: its budget is 80% of the free quota, shared by every lane (security lead
// ruling, Nov 16, 2026; docs/deploy-prod.md "Staging read budget").
const STAGING_BUDGET = {readsPerDay: 40000, writesPerDay: 16000};
const FREE_REGIONS = new Set(['us-east1', 'us-west1', 'us-central1']);
const PAID_ON_USE_API = /^(bigquery[a-z]*|dataform|dataplex|analyticshub|cloudaicompanion|deploymentmanager|containerregistry|source|sql-component)\.googleapis\.com$/;
const ALERTING_SERVICE = '58CD-E7C3-72CA';
const ORDER = {OK: 0, WARN: 1, OVER: 2};

export const formatRow = ({status, item, detail}) => `${status.padEnd(5)} ${item}: ${detail}`;

const short = (id) => id.replace(/^pantas-/, '');
const isStaging = (id) => /staging/.test(id);
const mib = (bytes) => `${(bytes / MIB).toFixed(1)} MiB`;
const worst = (statuses) => statuses.reduce((a, b) => (ORDER[b] > ORDER[a] ? b : a), 'OK');
const perProject = (data, pick) => Object.entries(data.projects).map(([id, p]) => `${short(id)} ${pick(p)}`).join(', ');
const sum = (data, pick) => Object.values(data.projects).reduce((total, p) => total + pick(p), 0);
// Scheduler reports status code -1 for a job that has not run yet. A failed record is a job whose
// update failed, or whose last attempt ended in an error.
const failedRecord = (j) => j.state === 'UPDATE_FAILED' || (j.lastAttemptTime && (j.status?.code ?? 0) > 0);
const dayStart = (date) => new Date(`${date}T00:00:00+08:00`);

/** data: {projects: {id: {...collected...}}, catalog: [{description, priced}]} -> rows [{status, item, detail}] */
export function judge(data, {waivers, now}) {
  const rows = [];
  const add = (status, item, detail) => rows.push({status, item, detail});
  const projects = Object.entries(data.projects);

  const jobs = sum(data, (p) => p.scheduler.jobs.length);
  add(jobs > FREE.schedulerJobs ? 'OVER' : 'OK', 'scheduler jobs (all locations, paused ones too)',
    `${jobs} (${perProject(data, (p) => p.scheduler.jobs.length)}), free ${FREE.schedulerJobs}`);
  const failed = sum(data, (p) => p.scheduler.jobs.filter(failedRecord).length);
  add(failed ? 'WARN' : 'OK', 'failed scheduler records', `${failed}`);

  const billable = (p) => p.secretVersions.filter((v) => v.state === 'ENABLED' || v.state === 'DISABLED');
  const versions = sum(data, (p) => billable(p).length);
  const disabled = sum(data, (p) => p.secretVersions.filter((v) => v.state === 'DISABLED').length);
  let secretStatus = versions > FREE.secretVersions ? 'OVER' : 'OK';
  let secretNote = '';
  const w = waivers.secrets;
  if (secretStatus === 'OVER' && w) {
    if (now >= dayStart(w.expires)) secretNote = `, waiver expired on ${w.expires}`;
    else if (versions > w.ceiling) secretNote = `, above the waiver ceiling ${w.ceiling}`;
    else { secretStatus = 'WARN'; secretNote = `, waived until ${w.expires}, ceiling ${w.ceiling}`; }
  }
  add(secretStatus, 'secret versions (enabled and disabled both bill)',
    `${versions} (enabled ${versions - disabled}, disabled ${disabled}; ${perProject(data, (p) => billable(p).length)}), free ${FREE.secretVersions}${secretNote}`);

  const registry = sum(data, (p) => p.registry.reduce((t, r) => t + r.sizeBytes, 0));
  add(registry > FREE.registryBytes ? 'OVER' : 'OK', 'Artifact Registry size',
    `${mib(registry)} (${perProject(data, (p) => mib(p.registry.reduce((t, r) => t + r.sizeBytes, 0)))}), free ${mib(FREE.registryBytes)}`);

  add(worst(projects.map(([, p]) => (p.hostingEgress24h > FREE.hostingEgressPerDay ? 'OVER' : 'OK'))), 'Hosting egress, last 24 hours',
    `${perProject(data, (p) => mib(p.hostingEgress24h))}, free ${mib(FREE.hostingEgressPerDay)} a day per project`);

  add(worst(projects.map(([id, p]) => (p.firestore.schedules + p.firestore.backups === 0 ? 'OK' : isStaging(id) ? 'OVER' : 'WARN'))),
    'Firestore backups and schedules',
    `${perProject(data, (p) => `${p.firestore.schedules} schedules, ${p.firestore.backups} backups`)}; staging must have none, prod daily for 7 days is kept (ruling 5)`);

  const bytesIn = (p, free) => p.buckets.filter((b) => FREE_REGIONS.has(b.location) === free).reduce((t, b) => t + b.bytes, 0);
  const freeBytes = sum(data, (p) => bytesIn(p, true));
  const otherBytes = sum(data, (p) => bytesIn(p, false));
  const bucketStatus = freeBytes > FREE.freeRegionBytes || otherBytes > FREE.otherRegionBytesOver ? 'OVER' : otherBytes > 0 ? 'WARN' : 'OK';
  add(bucketStatus, 'bucket sizes',
    `${perProject(data, (p) => `${p.buckets.length} buckets ${mib(p.buckets.reduce((t, b) => t + b.bytes, 0))}`)}; free-region ${mib(freeBytes)} of ${mib(FREE.freeRegionBytes)}, other regions ${mib(otherBytes)} (no free tier; over ${mib(FREE.otherRegionBytesOver)} is OVER)`);

  const paid = projects.flatMap(([id, p]) => p.apis.filter((a) => PAID_ON_USE_API.test(a)).map((a) => `${short(id)}:${a.replace('.googleapis.com', '')}`));
  add(paid.length ? 'WARN' : 'OK', 'enabled paid-on-use APIs (bill only on use)',
    `${perProject(data, (p) => `${p.apis.length} enabled`)}; ${paid.length ? paid.join(' ') : 'none of the watched ones'}`);

  const policies = sum(data, (p) => p.alerts.policies);
  const conditions = sum(data, (p) => p.alerts.conditions);
  const skus = data.catalog;
  const pricedSku = skus.some((s) => s.priced);
  const alertStatus = !skus.length ? 'OK' : pricedSku ? (conditions ? 'OVER' : 'OK') : (policies ? 'WARN' : 'OK');
  add(alertStatus, 'alerting: policies, conditions and the catalog SKU',
    `${policies} policies, ${conditions} conditions; Cloud Monitoring catalog (${ALERTING_SERVICE}): ${!skus.length ? 'no alerting SKU' : pricedSku ? 'alerting SKU is priced' : 'alerting SKU listed, not priced'}`);

  const caps = projects.filter(([, p]) => p.recaptchaCap !== null);
  const unlimited = caps.some(([, p]) => p.recaptchaCap < 0);
  const month = caps.reduce((t, [, p]) => t + Math.max(p.recaptchaCap, 0) * 31, 0);
  add(unlimited || month > FREE.recaptchaPerMonth ? 'OVER' : 'OK', 'reCAPTCHA CreateAssessment caps',
    `${unlimited ? 'a project has no cap' : month} in a 31-day month (${caps.map(([id, p]) => `${short(id)} ${p.recaptchaCap < 0 ? 'none' : p.recaptchaCap} a day`).join(', ')}), free ${FREE.recaptchaPerMonth}`);

  const opsStatus = [];
  const opsText = [];
  for (const [id, p] of projects) {
    const top = (key) => p.firestore.daily.reduce((a, d) => (d[key] > a.value ? {value: d[key], day: d.day} : a), {value: 0, day: '-'});
    const [r, wr, d] = [top('reads'), top('writes'), top('deletes')];
    const over = r.value > FREE.firestoreReadsPerDay || wr.value > FREE.firestoreWritesPerDay || d.value > FREE.firestoreDeletesPerDay;
    const overBudget = isStaging(id) && (r.value > STAGING_BUDGET.readsPerDay || wr.value > STAGING_BUDGET.writesPerDay);
    opsStatus.push(over ? (isStaging(id) ? 'OVER' : 'WARN') : overBudget ? 'WARN' : 'OK');
    const budget = isStaging(id) ? `, staging budget ${STAGING_BUDGET.readsPerDay} reads and ${STAGING_BUDGET.writesPerDay} writes` : '';
    opsText.push(`${short(id)}: max ${r.value} reads on ${r.day} (free ${FREE.firestoreReadsPerDay}), ${wr.value} writes on ${wr.day} (free ${FREE.firestoreWritesPerDay}${budget})`);
  }
  add(worst(opsStatus), 'Firestore daily operations, last 7 days', opsText.join('; '));

  add(worst(projects.map(([, p]) => (p.services.some((s) => s.name === 'billing-cutoff') ? 'OK' : 'OVER'))), 'billing-cutoff functions exist',
    perProject(data, (p) => (p.services.some((s) => s.name === 'billing-cutoff') ? 'present' : 'MISSING')));

  const warm = projects.flatMap(([id, p]) => p.services.filter((s) => s.minInstances > 0).map((s) => `${short(id)}:${s.name}=${s.minInstances}`));
  add(warm.length ? 'OVER' : 'OK', 'Cloud Run minimum instances', warm.length ? warm.join(' ') : `0 on ${sum(data, (p) => p.services.length)} services`);
  return rows;
}

// ---- collection (read-only GETs) ----

const token = () => execFileSync('gcloud', ['auth', 'print-access-token'], {encoding: 'utf8'}).trim();

function makeApi(accessToken) {
  /** GET a Google API. Returns null when the service is disabled or the resource is missing. */
  return async function api(url, project) {
    const response = await fetch(url, {headers: {Authorization: `Bearer ${accessToken}`, 'x-goog-user-project': project}});
    const body = await response.json().catch(() => ({}));
    if (response.status === 403 || response.status === 404) {
      if (JSON.stringify(body).match(/SERVICE_DISABLED|has not been used|not enabled|NOT_FOUND|not found/i)) return null;
    }
    if (!response.ok) throw new Error(`${url}: ${response.status} ${JSON.stringify(body).slice(0, 300)}`);
    return body;
  };
}

async function pages(api, url, project, key) {
  const out = [];
  let token = '';
  do {
    const sep = url.includes('?') ? '&' : '?';
    const body = await api(`${url}${token ? `${sep}pageToken=${encodeURIComponent(token)}` : ''}`, project);
    if (!body) return out;
    out.push(...(body[key] ?? []));
    token = body.nextPageToken ?? '';
  } while (token);
  return out;
}

async function inBatches(items, size, fn) {
  const results = [];
  for (let i = 0; i < items.length; i += size) results.push(...(await Promise.all(items.slice(i, i + size).map(fn))));
  return results;
}

const series = (api, project, metric, query) =>
  api(`https://monitoring.googleapis.com/v3/projects/${project}/timeSeries?filter=${encodeURIComponent(`metric.type="${metric}"`)}&${query}`, project)
    .then((body) => body?.timeSeries ?? []);
const num = (value) => Number(value?.int64Value ?? value?.doubleValue ?? 0);

async function collectProject(api, project) {
  const end = new Date();
  const iso = (d) => d.toISOString().replace(/\.\d+Z$/, 'Z');
  const ago = (ms) => iso(new Date(end - ms));
  const window = (ms) => `interval.startTime=${ago(ms)}&interval.endTime=${iso(end)}`;
  const daily = 'aggregation.alignmentPeriod=86400s&aggregation.perSeriesAligner=ALIGN_SUM&aggregation.crossSeriesReducer=REDUCE_SUM';

  const schedLocations = (await pages(api, `https://cloudscheduler.googleapis.com/v1/projects/${project}/locations`, project, 'locations')).map((l) => l.locationId);
  const jobs = (await inBatches(schedLocations, 8, (loc) => pages(api, `https://cloudscheduler.googleapis.com/v1/projects/${project}/locations/${loc}/jobs`, project, 'jobs'))).flat()
    .map((j) => ({name: j.name, state: j.state, status: j.status, lastAttemptTime: j.lastAttemptTime}));

  const secrets = await pages(api, `https://secretmanager.googleapis.com/v1/projects/${project}/secrets`, project, 'secrets');
  const secretVersions = (await inBatches(secrets, 8, async (s) =>
    (await pages(api, `https://secretmanager.googleapis.com/v1/${s.name}/versions`, project, 'versions')).map((v) => ({secret: s.name, state: v.state})))).flat();

  const arLocations = (await pages(api, `https://artifactregistry.googleapis.com/v1/projects/${project}/locations`, project, 'locations')).map((l) => l.locationId);
  const registry = (await inBatches(arLocations, 8, (loc) => pages(api, `https://artifactregistry.googleapis.com/v1/projects/${project}/locations/${loc}/repositories`, project, 'repositories'))).flat()
    .map((r) => ({name: r.name, location: r.name.split('/')[3], sizeBytes: Number(r.sizeBytes ?? 0)}));

  const egress = await series(api, project, 'firebasehosting.googleapis.com/network/sent_bytes_count', `${window(24 * 3600e3)}&${daily}`);
  const hostingEgress24h = egress.flatMap((s) => s.points).reduce((t, p) => t + num(p.value), 0);

  const databases = await pages(api, `https://firestore.googleapis.com/v1/projects/${project}/databases`, project, 'databases');
  let schedules = 0;
  for (const db of databases) schedules += (await pages(api, `https://firestore.googleapis.com/v1/${db.name}/backupSchedules`, project, 'backupSchedules')).length;
  const backups = (await pages(api, `https://firestore.googleapis.com/v1/projects/${project}/locations/-/backups`, project, 'backups')).length;

  const ops = {};
  for (const [key, metric] of [['reads', 'read_count'], ['writes', 'write_count'], ['deletes', 'delete_count']]) {
    // Rolling 24-hour windows ending now. Google's free quota resets at Pacific midnight, so a window
    // can straddle two quota days: a figure near the limit needs a second look.
    for (const s of await series(api, project, `firestore.googleapis.com/document/${metric}`, `${window(7 * 24 * 3600e3)}&${daily}`)) {
      for (const p of s.points) { const day = p.interval.endTime.slice(0, 10); (ops[day] ??= {day, reads: 0, writes: 0, deletes: 0})[key] += num(p.value); }
    }
  }

  const bucketSeries = await series(api, project, 'storage.googleapis.com/storage/total_bytes',
    `${window(2 * 24 * 3600e3)}&aggregation.alignmentPeriod=86400s&aggregation.perSeriesAligner=ALIGN_MEAN&aggregation.crossSeriesReducer=REDUCE_SUM&aggregation.groupByFields=resource.label.bucket_name&aggregation.groupByFields=resource.label.location`);
  const buckets = bucketSeries.map((s) => ({name: s.resource.labels.bucket_name, location: s.resource.labels.location.toLowerCase(), bytes: num(s.points[0]?.value)}));

  const apis = (await pages(api, `https://serviceusage.googleapis.com/v1/projects/${project}/services?filter=state:ENABLED&pageSize=200`, project, 'services')).map((s) => s.config.name);

  const policyList = await pages(api, `https://monitoring.googleapis.com/v3/projects/${project}/alertPolicies?pageSize=100`, project, 'alertPolicies');
  const alerts = {policies: policyList.length, conditions: policyList.reduce((t, p) => t + (p.conditions?.length ?? 0), 0)};

  let recaptchaCap = null;
  const quota = await api(`https://serviceusage.googleapis.com/v1beta1/projects/${project}/services/recaptchaenterprise.googleapis.com/consumerQuotaMetrics`, project);
  const metric = quota?.metrics?.find((m) => m.metric === 'recaptchaenterprise.googleapis.com/CreateAssessmentRequests');
  const bucket = metric?.consumerQuotaLimits?.find((l) => l.unit === '1/d/{project}')?.quotaBuckets?.[0];
  if (bucket) recaptchaCap = Number(bucket.effectiveLimit);

  const services = (await pages(api, `https://run.googleapis.com/v2/projects/${project}/locations/-/services?pageSize=100`, project, 'services'))
    .map((s) => ({name: s.name.split('/').pop(), minInstances: Math.max(s.scaling?.minInstanceCount ?? 0, s.template?.scaling?.minInstanceCount ?? 0)}));

  return {scheduler: {jobs}, secretVersions, registry, hostingEgress24h, firestore: {schedules, backups, daily: Object.values(ops).sort((a, b) => a.day.localeCompare(b.day))},
    buckets, apis, alerts, recaptchaCap, services};
}

async function collectCatalog(api, project) {
  const skus = await pages(api, `https://cloudbilling.googleapis.com/v1/services/${ALERTING_SERVICE}/skus?pageSize=500`, project, 'skus');
  return skus.filter((s) => /alert/i.test(s.description)).map((s) => ({
    description: s.description,
    priced: (s.pricingInfo ?? []).some((info) => (info.pricingExpression?.tieredRates ?? []).some((r) => Number(r.unitPrice?.units ?? 0) > 0 || (r.unitPrice?.nanos ?? 0) > 0)),
  }));
}

export async function collect(seedProject = 'pantas-prod') {
  const api = makeApi(token());
  const info = await api(`https://cloudbilling.googleapis.com/v1/projects/${seedProject}/billingInfo`, seedProject);
  if (!info?.billingAccountName) throw new Error(`${seedProject} has no billing account (or it cannot be read)`);
  const list = await pages(api, `https://cloudbilling.googleapis.com/v1/${info.billingAccountName}/projects`, seedProject, 'projectBillingInfo');
  const ids = list.filter((p) => p.billingEnabled).map((p) => p.projectId).sort();
  const projects = {};
  for (const id of ids) projects[id] = await collectProject(api, id);
  return {projects, catalog: await collectCatalog(api, seedProject)};
}

async function main() {
  const data = await collect();
  console.log(`projects on the billing account: ${Object.keys(data.projects).join(', ')}`);
  const rows = judge(data, {waivers: loadWaivers(), now: new Date()});
  for (const row of rows) console.log(formatRow(row));
  const over = rows.filter((r) => r.status === 'OVER').length;
  const warn = rows.filter((r) => r.status === 'WARN').length;
  console.log(`${rows.length} items: ${rows.length - over - warn} OK, ${warn} WARN, ${over} OVER`);
  process.exit(over ? 1 : 0);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href && !process.env.NODE_TEST_CONTEXT) {
  main().catch((error) => { console.error(`free-tier live check could not run: ${error.message}`); process.exit(2); });
}
