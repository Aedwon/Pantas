import assert from 'node:assert/strict';
import {createHmac} from 'node:crypto';
import test from 'node:test';
import {addPrepaid, normalizePaymongoEvent, priceCentavos, verifyPaymongoSignature, webProduct,
  webProductIds} from '../lib/paymongoPolicy.js';
import {coverageAt} from '../lib/revenuecatCoverage.js';
import {planGrant} from '../lib/paymongoGrants.js';

const ph = iso => Date.parse(iso);
const raw = Buffer.from('{"data":{"id":"evt_1"}}');
const now = ph('2026-10-20T10:00:00+08:00');
const t = String(Math.floor(now / 1000));
const hex = (secret = 's', body = raw, at = t) =>
  createHmac('sha256', secret).update(`${at}.`).update(body).digest('hex');

test('signature: test events verify against te, live events against li', () => {
  assert.equal(verifyPaymongoSignature(raw, `t=${t},te=${hex()},li=`, 's', false, now), true);
  assert.equal(verifyPaymongoSignature(raw, `t=${t},te=,li=${hex()}`, 's', true, now), true);
});

test('signature: wrong secret, altered body, wrong mode part and missing parts all fail', () => {
  assert.equal(verifyPaymongoSignature(raw, `t=${t},te=${hex('other')},li=`, 's', false, now), false);
  assert.equal(verifyPaymongoSignature(Buffer.from('{"data":{"id":"evt_2"}}'), `t=${t},te=${hex()},li=`, 's', false, now), false);
  assert.equal(verifyPaymongoSignature(raw, `t=${t},te=${hex()},li=`, 's', true, now), false);
  assert.equal(verifyPaymongoSignature(raw, `t=${t},te=,li=${hex()}`, 's', false, now), false);
  for (const header of ['', `te=${hex()}`, `t=${t}`, `t=abc,te=${hex()}`, `t=${t},te=zz`, `t=${t},t=${t},te=${hex()}`]) {
    assert.equal(verifyPaymongoSignature(raw, header, 's', false, now), false, header);
  }
  assert.equal(verifyPaymongoSignature(raw, `t=${t},te=${hex()},li=`, '', false, now), false);
});

test('signature: a timestamp more than five minutes from now is refused in both directions', () => {
  const old = String(Math.floor(now / 1000) - 301);
  const future = String(Math.floor(now / 1000) + 301);
  assert.equal(verifyPaymongoSignature(raw, `t=${old},te=${hex('s', raw, old)},li=`, 's', false, now), false);
  assert.equal(verifyPaymongoSignature(raw, `t=${future},te=${hex('s', raw, future)},li=`, 's', false, now), false);
  const edge = String(Math.floor(now / 1000) - 299);
  assert.equal(verifyPaymongoSignature(raw, `t=${edge},te=${hex('s', raw, edge)},li=`, 's', false, now), true);
});

test('event envelope needs id, type, livemode and a resource', () => {
  const ok = {data: {id: 'evt_1', attributes: {type: 'refund.succeeded', livemode: false, data: {id: 'ref_1'}}}};
  assert.deepEqual(normalizePaymongoEvent(ok), {id: 'evt_1', type: 'refund.succeeded', livemode: false, data: {id: 'ref_1'}});
  for (const bad of [null, {}, {data: {}}, {data: {id: 'e', attributes: {type: 't', data: {}}}},
    {data: {id: 'e/x', attributes: {type: 't', livemode: true, data: {}}}},
    {data: {id: 'e', attributes: {type: 't', livemode: true}}}]) {
    assert.equal(normalizePaymongoEvent(bad), null);
  }
});

test('web products carry the docs/pricing.md Civil Service prices and nothing else is sold', () => {
  const prices = Object.fromEntries(webProductIds().map(id => [id, webProduct(id).webPricePhp]));
  assert.deepEqual(prices, {pantas_cs_weekly: 49, pantas_cs_monthly: 149, pantas_cs_yearly: 1199,
    pantas_pass_cse_pro: 499, pantas_pass_cse_sub: 499});
  assert.equal(priceCentavos(webProduct('pantas_cs_monthly')), 14900);
  for (const id of ['pantas_pro_monthly', 'promo_student', 'web_trial', '', undefined, 'constructor']) {
    assert.equal(webProduct(id), undefined);
  }
});

test('prepaid lengths: weekly is 7 days; monthly and yearly keep the Philippine calendar date', () => {
  assert.equal(addPrepaid(ph('2026-10-20T10:00:00+08:00'), {unit: 'days', count: 7}), ph('2026-10-27T10:00:00+08:00'));
  assert.equal(addPrepaid(ph('2027-01-31T10:00:00+08:00'), {unit: 'months', count: 1}), ph('2027-02-28T10:00:00+08:00'));
  assert.equal(addPrepaid(ph('2028-01-31T10:00:00+08:00'), {unit: 'months', count: 1}), ph('2028-02-29T10:00:00+08:00'));
  assert.equal(addPrepaid(ph('2026-12-15T23:30:00+08:00'), {unit: 'months', count: 1}), ph('2027-01-15T23:30:00+08:00'));
  assert.equal(addPrepaid(ph('2026-03-31T09:00:00+08:00'), {unit: 'months', count: 1}), ph('2026-04-30T09:00:00+08:00'));
  assert.equal(addPrepaid(ph('2028-02-29T12:00:00+08:00'), {unit: 'years', count: 1}), ph('2029-02-28T12:00:00+08:00'));
  assert.equal(addPrepaid(ph('2026-10-20T10:00:00+08:00'), {unit: 'years', count: 1}), ph('2027-10-20T10:00:00+08:00'));
});

test('prepaid month uses Philippine time, not UTC: 23:00 UTC on Jan 31 is already Feb 1 in Manila', () => {
  // 2027-01-31T23:00Z is 2027-02-01 07:00 in Manila, so one month later is March 1 07:00 Manila.
  assert.equal(addPrepaid(Date.parse('2027-01-31T23:00:00Z'), {unit: 'months', count: 1}), ph('2027-03-01T07:00:00+08:00'));
  assert.throws(() => addPrepaid(now, {unit: 'sitting'}));
  assert.throws(() => addPrepaid(now, {unit: 'days', count: 0}));
});

const catalog = [{id: 'exam_cse_pro', publishedSittings: [
  {firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'https://example.test/a'},
  {firstDay: '2027-08-08', lastDay: '2027-08-08', sourceUrl: 'https://example.test/b'}]}];
const grant = (over) => ({source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService',
  startsAt: now, endsAt: now + 86400000, state: 'active', createdAt: now, ...over});

test('planGrant: early renewal stacks from the current end; an expired or revoked grant does not', () => {
  const monthly = webProduct('pantas_cs_monthly');
  const end = ph('2026-11-05T12:00:00+08:00');
  assert.deepEqual(planGrant(monthly, [grant({endsAt: end})], now, catalog),
    {startsAt: end, endsAt: ph('2026-12-05T12:00:00+08:00')});
  assert.deepEqual(planGrant(monthly, [grant({endsAt: now - 1})], now, catalog),
    {startsAt: now, endsAt: ph('2026-11-20T10:00:00+08:00')});
  assert.equal(planGrant(monthly, [grant({endsAt: end, state: 'revoked'})], now, catalog).startsAt, now);
  assert.equal(planGrant(monthly, [], now, catalog).startsAt, now);
});

test('planGrant: a pass ends at the end of the next published sitting and never stacks', () => {
  const pass = webProduct('pantas_pass_cse_pro');
  const plan = planGrant(pass, [grant({endsAt: ph('2027-12-01T00:00:00+08:00')})], now, catalog);
  assert.deepEqual(plan, {startsAt: now, endsAt: ph('2027-03-14T23:59:59.999+08:00')});
  // Bought on the exam day itself: that day still counts. The next day moves to the next sitting.
  assert.equal(planGrant(pass, [], ph('2027-03-14T08:00:00+08:00'), catalog).endsAt, ph('2027-03-14T23:59:59.999+08:00'));
  assert.equal(planGrant(pass, [], ph('2027-03-15T08:00:00+08:00'), catalog).endsAt, ph('2027-08-08T23:59:59.999+08:00'));
  assert.equal(planGrant(pass, [], ph('2027-08-09T08:00:00+08:00'), catalog), null);
});

test('a pass grant does not push a later subscription start', () => {
  const monthly = webProduct('pantas_cs_monthly');
  const pass = grant({product: 'pantas_pass_cse_pro', endsAt: ph('2027-03-14T23:59:59.999+08:00')});
  assert.equal(planGrant(monthly, [pass], now, catalog).startsAt, now);
});

test('coverage includes live grants: subscription, pass, trial; revoked and expired add nothing', () => {
  const at = now;
  const live = coverageAt({at, grants: [{source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService', endsAt: at + 1000, active: true}]});
  assert.equal(live.tier, 'civilService');
  assert.equal(live.endsAt, at + 1000);
  assert.equal(live.coversExam('exam_cse_pro', 'civilService'), true);
  assert.equal(live.coversExam('exam_cse_pro', 'licensure'), false);
  const pass = coverageAt({at, grants: [{source: 'paymongo', product: 'pantas_pass_cse_sub', tier: 'civilService', endsAt: at + 5, active: true}]});
  assert.equal(pass.coversExam('exam_cse_sub', 'civilService'), true);
  assert.equal(pass.coversExam('exam_cse_pro', 'civilService'), false);
  const trial = coverageAt({at, grants: [{source: 'trial', product: 'web_trial', tier: 'civilService', endsAt: at + 9, active: true}]});
  assert.equal(trial.tier, 'civilService');
  assert.equal(trial.endsAt, at + 9);
  for (const g of [{active: false, endsAt: at + 1000}, {active: true, endsAt: at}]) {
    const none = coverageAt({at, grants: [{source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService', ...g}]});
    assert.equal(none.endsAt, null);
    assert.equal(none.hasKnownCoverage, false);
  }
  const unknown = coverageAt({at, grants: [{source: 'paymongo', product: 'pantas_made_up', tier: 'civilService', endsAt: at + 9, active: true}], onUnknown: () => {}});
  assert.equal(unknown.isUnknown, true);
  assert.equal(unknown.endsAt, null);
});
