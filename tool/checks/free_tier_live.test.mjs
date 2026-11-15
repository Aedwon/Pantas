// Tests for free_tier_live.mjs: the judging of already-collected data. The collection itself needs a
// cloud login, so it runs by hand (see the header of free_tier_live.mjs).
import assert from 'node:assert/strict';
import test from 'node:test';
import {judge, formatRow} from './free_tier_live.mjs';
import {loadWaivers} from './free_tier.mjs';

const waivers = loadWaivers();
const NOW = new Date('2026-11-15T12:00:00+08:00');
const MIB = 1024 * 1024;
const days = (n, reads = 1000, writes = 100) => Array.from({length: n}, (_, i) => ({day: `2026-11-${String(9 + i).padStart(2, '0')}`, reads, writes, deletes: 0}));

/** A clean project: nothing over any free limit. */
const project = (over = {}) => ({
  scheduler: {jobs: []},
  secretVersions: [],
  registry: [{name: 'gcf-artifacts', location: 'asia-southeast1', sizeBytes: 10 * MIB}],
  hostingEgress24h: 10 * MIB,
  firestore: {schedules: 0, backups: 0, daily: days(7)},
  buckets: [{name: 'b', location: 'asia-southeast1', bytes: 50 * MIB}],
  apis: ['firestore.googleapis.com', 'run.googleapis.com'],
  alerts: {policies: 0, conditions: 0},
  recaptchaCap: 100,
  services: [{name: 'billing-cutoff', minInstances: 0}, {name: 'exportdata', minInstances: 0}],
  ...over,
});
const data = (prod = {}, staging = {}, catalog = []) => ({projects: {'pantas-prod': project(prod), 'pantas-staging': project(staging)}, catalog});
const jobs = (n, state = 'ENABLED') => Array.from({length: n}, (_, i) => ({name: `j${i}`, state}));
const versions = (n, state = 'ENABLED') => Array.from({length: n}, (_, i) => ({secret: `s${i}`, state}));
const rows = (d) => judge(d, {waivers, now: NOW});
const find = (all, text) => all.find((r) => r.item.includes(text));
const status = (d, text) => find(rows(d), text)?.status;

test('a clean account has no OVER row', () => {
  const all = rows(data());
  assert.deepEqual(all.filter((r) => r.status === 'OVER'), []);
  assert.ok(all.length >= 12, `one row per item, got ${all.length}`);
});

test('scheduler: paused jobs count, in every project together; 3 is the limit', () => {
  assert.equal(status(data({scheduler: {jobs: jobs(3)}}), 'scheduler jobs'), 'OK');
  assert.equal(status(data({scheduler: {jobs: jobs(2)}}, {scheduler: {jobs: jobs(2, 'PAUSED')}}), 'scheduler jobs'), 'OVER');
  const nov14 = rows(data({scheduler: {jobs: jobs(9)}}, {scheduler: {jobs: jobs(9, 'PAUSED')}}));
  assert.match(find(nov14, 'scheduler jobs').detail, /18 .*free 3/);
});

test('scheduler: a failed record is reported', () => {
  const failed = [{name: 'x', state: 'UPDATE_FAILED'}];
  assert.equal(status(data({scheduler: {jobs: failed}}), 'failed scheduler'), 'WARN');
  const errored = [{name: 'y', state: 'ENABLED', status: {code: 13}, lastAttemptTime: '2026-11-15T10:00:00Z'}];
  assert.equal(status(data({scheduler: {jobs: errored}}), 'failed scheduler'), 'WARN');
  const neverRan = [{name: 'z', state: 'PAUSED', status: {code: -1}}];
  assert.equal(status(data({scheduler: {jobs: neverRan}}), 'failed scheduler'), 'OK');
});

test('secret versions: enabled and disabled both count; destroyed do not; the waiver covers up to its ceiling', () => {
  assert.equal(status(data({secretVersions: versions(3)}, {secretVersions: versions(3)}), 'secret versions'), 'OK');
  assert.equal(status(data({secretVersions: [...versions(3), ...versions(1, 'DISABLED')]}, {secretVersions: versions(3)}), 'secret versions'), 'WARN');
  assert.equal(status(data({secretVersions: versions(3, 'DESTROYED')}, {secretVersions: versions(6)}), 'secret versions'), 'OK');
  assert.equal(status(data({secretVersions: versions(9)}, {secretVersions: versions(9)}), 'secret versions'), 'OVER');
  assert.match(find(rows(data({secretVersions: versions(9)}, {secretVersions: versions(9)})), 'secret versions').detail, /18 .*free 6.*ceiling 16/);
});

test('secret versions: an expired waiver is OVER even at 16', () => {
  const d = data({secretVersions: versions(8)}, {secretVersions: versions(8)});
  assert.equal(find(judge(d, {waivers, now: new Date('2026-11-24T00:00:00+08:00')}), 'secret versions').status, 'OVER');
});

test('Artifact Registry: more than 0.5 GiB across the account is OVER', () => {
  const big = (mib) => ({registry: [{name: 'gcf-artifacts', location: 'asia-southeast1', sizeBytes: mib * MIB}]});
  assert.equal(status(data(big(200), big(200)), 'Artifact Registry'), 'OK');
  assert.equal(status(data(big(227), big(424)), 'Artifact Registry'), 'OVER');
});

test('Hosting egress: over 360 MB in 24 hours on a project is OVER', () => {
  assert.equal(status(data({hostingEgress24h: 479009522}), 'Hosting egress'), 'OVER');
  assert.equal(status(data({hostingEgress24h: 100 * MIB}), 'Hosting egress'), 'OK');
});

test('Firestore backups: any on staging is OVER; prod backups are WARN (kept by ruling)', () => {
  assert.equal(status(data({}, {firestore: {schedules: 1, backups: 0, daily: days(7)}}), 'Firestore backups'), 'OVER');
  assert.equal(status(data({firestore: {schedules: 1, backups: 7, daily: days(7)}}), 'Firestore backups'), 'WARN');
  assert.equal(status(data(), 'Firestore backups'), 'OK');
});

test('buckets: bytes outside the free regions are WARN, and OVER above 1 GiB', () => {
  assert.equal(status(data({buckets: []}, {buckets: []}), 'bucket'), 'OK');
  assert.equal(status(data(), 'bucket'), 'WARN');
  const big = {buckets: [{name: 'b', location: 'asia-southeast1', bytes: 2048 * MIB}]};
  assert.equal(status(data(big), 'bucket'), 'OVER');
  const free = {buckets: [{name: 'b', location: 'us-central1', bytes: 2048 * MIB}]};
  assert.equal(status(data(free, {buckets: []}), 'bucket'), 'OK');
});

test('enabled APIs that bill on use are WARN', () => {
  assert.equal(status(data({apis: ['bigquery.googleapis.com', 'dataform.googleapis.com']}), 'paid-on-use APIs'), 'WARN');
  assert.equal(status(data(), 'paid-on-use APIs'), 'OK');
});

test('alerting: no SKU and no priced SKU is OK; a priced alerting SKU with policies is OVER', () => {
  const withPolicies = {alerts: {policies: 9, conditions: 9}};
  assert.equal(status(data(withPolicies), 'alerting'), 'OK');
  const free = [{description: 'Alerting policy conditions', priced: false}];
  assert.equal(status(data(withPolicies, {}, free), 'alerting'), 'WARN');
  const priced = [{description: 'Alerting policy conditions', priced: true}];
  assert.equal(status(data(withPolicies, {}, priced), 'alerting'), 'OVER');
  assert.equal(status(data({}, {}, priced), 'alerting'), 'OK');
});

test('reCAPTCHA: the daily caps times 31 days stay at or under 10,000', () => {
  assert.equal(status(data({recaptchaCap: 280}, {recaptchaCap: 40}), 'reCAPTCHA'), 'OK');
  assert.equal(status(data({recaptchaCap: 300}, {recaptchaCap: 300}), 'reCAPTCHA'), 'OVER');
  assert.equal(status(data({recaptchaCap: -1}, {recaptchaCap: 40}), 'reCAPTCHA'), 'OVER');
  assert.match(find(rows(data({recaptchaCap: 280}, {recaptchaCap: 40})), 'reCAPTCHA').detail, /9920 .*free 10000/);
});

test('Firestore daily operations: over 50,000 reads or 20,000 writes a day is OVER on staging, WARN on prod', () => {
  const heavy = (reads, writes) => ({firestore: {schedules: 0, backups: 0, daily: [...days(6), {day: '2026-11-10', reads, writes, deletes: 0}]}});
  assert.equal(status(data({}, heavy(57791, 100)), 'Firestore daily operations'), 'OVER');
  assert.equal(status(data({}, heavy(100, 20001)), 'Firestore daily operations'), 'OVER');
  assert.equal(status(data({}, heavy(50000, 20000)), 'Firestore daily operations'), 'OK');
  assert.equal(status(data(heavy(57791, 100)), 'Firestore daily operations'), 'WARN');
  assert.match(find(rows(data({}, heavy(57791, 100))), 'Firestore daily operations').detail, /57791 reads on 2026-11-10.*free 50000/);
});

test('both billing-cutoff functions must exist, and no service keeps a minimum instance', () => {
  assert.equal(status(data(), 'billing-cutoff'), 'OK');
  const missing = {services: [{name: 'exportdata', minInstances: 0}]};
  assert.equal(status(data({}, missing), 'billing-cutoff'), 'OVER');
  assert.equal(status(data({services: [{name: 'billing-cutoff', minInstances: 1}]}), 'minimum instances'), 'OVER');
});

test('a row prints on one line with its status, item and detail', () => {
  const line = formatRow({status: 'OVER', item: 'scheduler jobs (account)', detail: '18, free 3'});
  assert.equal(line, 'OVER  scheduler jobs (account): 18, free 3');
  assert.equal(formatRow({status: 'OK', item: 'x', detail: 'y'}), 'OK    x: y');
  assert.equal(formatRow({status: 'WARN', item: 'x', detail: 'y'}), 'WARN  x: y');
});
