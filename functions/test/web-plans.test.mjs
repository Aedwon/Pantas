import assert from 'node:assert/strict';
import test from 'node:test';
import {listPlans} from '../lib/webPlans.js';
import * as endpoints from '../lib/index.js';

const NOW = Date.parse('2026-10-20T10:00:00+08:00');
const named = uid => ({uid, token: {firebase: {sign_in_provider: 'google.com'}}});
const anon = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const sitting = {firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'https://x.test/official'};
const catalog = [{id: 'exam_cse_pro', publishedSittings: [sitting]}, {id: 'exam_cse_sub', publishedSittings: [sitting]}];
const deps = (extra = {}) => ({renewal: async () => false, eligibility: async () => false, allow: async () => true, catalog, now: () => NOW, ...extra});
const code = async promise => {try {await promise; return 'ok';} catch (e) {assert.equal(typeof e.code, 'string', String(e)); return e.code;}};
const byProduct = out => Object.fromEntries(out.plans.map(p => [p.product, p]));

test('every web product is listed with the price checkout charges, formatted on the server', async () => {
  const out = await listPlans(named('u1'), deps());
  assert.deepEqual(out.plans.map(p => p.product), ['pantas_cs_weekly', 'pantas_cs_monthly', 'pantas_cs_yearly',
    'pantas_pass_cse_pro', 'pantas_pass_cse_sub']);
  const plans = byProduct(out);
  assert.deepEqual(plans.pantas_cs_weekly, {product: 'pantas_cs_weekly', priceCentavos: 4900, priceString: '₱49.00',
    prepaid: {unit: 'days', count: 7}, examId: null});
  assert.deepEqual(plans.pantas_cs_monthly, {product: 'pantas_cs_monthly', priceCentavos: 14900, priceString: '₱149.00',
    prepaid: {unit: 'months', count: 1}, examId: null});
  assert.deepEqual(plans.pantas_cs_yearly, {product: 'pantas_cs_yearly', priceCentavos: 119900, priceString: '₱1,199.00',
    prepaid: {unit: 'years', count: 1}, examId: null});
  assert.deepEqual(plans.pantas_pass_cse_pro, {product: 'pantas_pass_cse_pro', priceCentavos: 49900, priceString: '₱499.00',
    prepaid: {unit: 'sitting'}, examId: 'exam_cse_pro'});
  assert.equal(plans.pantas_pass_cse_sub.examId, 'exam_cse_sub');
});

test('store-only and promotional products are never listed', async () => {
  const ids = (await listPlans(named('u1'), deps())).plans.map(p => p.product);
  for (const id of ids) assert.match(id, /^pantas_(cs_|pass_cse_)/);
});

test('a pass is omitted when no sitting is published, as checkout refuses it', async () => {
  const none = {catalog: [{id: 'exam_cse_pro', publishedSittings: []}, {id: 'exam_cse_sub', publishedSittings: [{...sitting, sourceUrl: ''}]}]};
  const ids = (await listPlans(named('u1'), deps(none))).plans.map(p => p.product);
  assert.deepEqual(ids, ['pantas_cs_weekly', 'pantas_cs_monthly', 'pantas_cs_yearly']);
  const past = {now: () => Date.parse('2027-03-15T00:00:00+08:00')};
  assert.deepEqual((await listPlans(named('u1'), deps(past))).plans.map(p => p.product),
    ['pantas_cs_weekly', 'pantas_cs_monthly', 'pantas_cs_yearly']);
  const one = {catalog: [{id: 'exam_cse_sub', publishedSittings: [sitting]}]};
  assert.deepEqual((await listPlans(named('u1'), deps(one))).plans.map(p => p.product).slice(3), ['pantas_pass_cse_sub']);
});

test('any signed-in account may list, including anonymous; signed-out is refused', async () => {
  assert.equal(await code(listPlans(anon('a1'), deps())), 'ok');
  assert.equal(await code(listPlans(named('u1'), deps())), 'ok');
  assert.equal(await code(listPlans(undefined, deps())), 'unauthenticated');
});

test('a caller over the limit is refused before anything is listed', async () => {
  assert.equal(await code(listPlans(named('u1'), deps({allow: async () => false}))), 'resource-exhausted');
});

test('the limit is checked for the calling account', async () => {
  const seen = [];
  await listPlans(named('u7'), deps({allow: async uid => {seen.push(uid); return true;}}));
  assert.deepEqual(seen, ['u7']);
});

test('index exports listWebPlans', () => {
  assert.equal(typeof endpoints.listWebPlans, 'function');
});
