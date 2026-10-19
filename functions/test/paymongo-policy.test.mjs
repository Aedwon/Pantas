import assert from 'node:assert/strict';
import {createHmac} from 'node:crypto';
import test from 'node:test';
import {addPrepaid, normalizePaymongoEvent, priceCentavos, verifyPaymongoSignature, webProduct,
  webProductIds} from '../lib/paymongoPolicy.js';
import {coverageAt} from '../lib/revenuecatCoverage.js';
import {planGrant, replanAfterRevoke} from '../lib/paymongoGrants.js';

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
  const live = coverageAt({at, grants: [{source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService', startsAt: at - 1, endsAt: at + 1000, active: true}]});
  assert.equal(live.tier, 'civilService');
  assert.equal(live.endsAt, at + 1000);
  assert.equal(live.coversExam('exam_cse_pro', 'civilService'), true);
  assert.equal(live.coversExam('exam_cse_pro', 'licensure'), false);
  const pass = coverageAt({at, grants: [{source: 'paymongo', product: 'pantas_pass_cse_sub', tier: 'civilService', startsAt: at, endsAt: at + 5, active: true}]});
  assert.equal(pass.coversExam('exam_cse_sub', 'civilService'), true);
  assert.equal(pass.coversExam('exam_cse_pro', 'civilService'), false);
  const trial = coverageAt({at, grants: [{source: 'trial', product: 'web_trial', tier: 'civilService', startsAt: at, endsAt: at + 9, active: true}]});
  assert.equal(trial.tier, 'civilService');
  assert.equal(trial.endsAt, at + 9);
  for (const g of [{active: false, endsAt: at + 1000}, {active: true, endsAt: at}]) {
    const none = coverageAt({at, grants: [{source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService', startsAt: at - 5, ...g}]});
    assert.equal(none.endsAt, null);
    assert.equal(none.hasKnownCoverage, false);
  }
  const unknown = coverageAt({at, grants: [{source: 'paymongo', product: 'pantas_made_up', tier: 'civilService', startsAt: at, endsAt: at + 9, active: true}], onUnknown: () => {}});
  assert.equal(unknown.isUnknown, true);
  assert.equal(unknown.endsAt, null);
});

const DAY = 86400000;
const lg = (startsAt, endsAt, over = {}) => ({source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService', startsAt, endsAt, active: true, ...over});

test('coverage: a grant covers only [startsAt, endsAt); a future grant adds nothing until contiguous', () => {
  const at = now;
  const future = coverageAt({at, grants: [lg(at + DAY, at + 5 * DAY)]});
  assert.equal(future.endsAt, null);
  assert.equal(future.tier, null);
  assert.equal(future.coversExam('exam_cse_pro', 'civilService'), false);
  // Starting exactly at "now" is live; ending exactly at "now" is not.
  assert.equal(coverageAt({at, grants: [lg(at, at + DAY)]}).tier, 'civilService');
  assert.equal(coverageAt({at, grants: [lg(at - DAY, at)]}).tier, null);
});

test('coverage: a stacked grant extends the end of the live chain, a gap does not', () => {
  const at = now;
  const a = lg(at - DAY, at + 10 * DAY);
  assert.equal(coverageAt({at, grants: [a, lg(at + 10 * DAY, at + 40 * DAY)]}).endsAt, at + 40 * DAY);
  assert.equal(coverageAt({at, grants: [a, lg(at + 10 * DAY, at + 40 * DAY), lg(at + 40 * DAY, at + 70 * DAY)]}).endsAt, at + 70 * DAY);
  assert.equal(coverageAt({at, grants: [a, lg(at + 11 * DAY, at + 40 * DAY)]}).endsAt, at + 10 * DAY);
  assert.equal(coverageAt({at, grants: [a, lg(at + 10 * DAY, at + 40 * DAY, {active: false})]}).endsAt, at + 10 * DAY);
});

const row = (startsAt, endsAt, over = {}) => ({source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService',
  startsAt, endsAt, state: 'active', createdAt: 1, ...over});

test('replan: refunding the first of two stacked months pulls the second forward to now', () => {
  const a0 = ph('2026-10-20T10:00:00+08:00'), a1 = ph('2026-11-20T10:00:00+08:00'), b1 = ph('2026-12-20T10:00:00+08:00');
  const at = ph('2026-10-30T09:00:00+08:00');
  const grants = new Map([['A', row(a0, a1, {state: 'revoked'})], ['B', row(a1, b1)]]);
  const out = replanAfterRevoke(grants, 'A', at);
  assert.deepEqual([out.get('B').startsAt, out.get('B').endsAt], [at, ph('2026-11-30T09:00:00+08:00')]);
  assert.equal(out.get('A').state, 'revoked');
});

test('replan: refunding the second leaves the first untouched; a started later grant is not moved', () => {
  const a0 = ph('2026-10-20T10:00:00+08:00'), a1 = ph('2026-11-20T10:00:00+08:00'), b1 = ph('2026-12-20T10:00:00+08:00');
  const at = ph('2026-10-30T09:00:00+08:00');
  const second = replanAfterRevoke(new Map([['A', row(a0, a1)], ['B', row(a1, b1, {state: 'revoked'})]]), 'B', at);
  assert.deepEqual([second.get('A').startsAt, second.get('A').endsAt], [a0, a1]);
  // First already ended and the second is running: nothing moves.
  const later = ph('2026-11-25T09:00:00+08:00');
  const started = replanAfterRevoke(new Map([['A', row(a0, a1, {state: 'revoked'})], ['B', row(a1, b1)]]), 'A', later);
  assert.deepEqual([started.get('B').startsAt, started.get('B').endsAt], [a1, b1]);
});

test('replan: three stacked months close the gap in order, keeping calendar lengths', () => {
  const a0 = ph('2026-10-20T10:00:00+08:00'), a1 = ph('2026-11-20T10:00:00+08:00'),
    b1 = ph('2026-12-20T10:00:00+08:00'), c1 = ph('2027-01-20T10:00:00+08:00');
  const at = ph('2026-10-21T10:00:00+08:00');
  const out = replanAfterRevoke(new Map([['A', row(a0, a1, {state: 'revoked'})], ['B', row(a1, b1)], ['C', row(b1, c1)]]), 'A', at);
  assert.deepEqual([out.get('B').startsAt, out.get('B').endsAt], [at, ph('2026-11-21T10:00:00+08:00')]);
  assert.deepEqual([out.get('C').startsAt, out.get('C').endsAt], [ph('2026-11-21T10:00:00+08:00'), ph('2026-12-21T10:00:00+08:00')]);
});

test('replan: a live trial followed by a paid grant closes up the same way', () => {
  const t0 = ph('2026-10-20T10:00:00+08:00'), t1 = t0 + 7 * DAY, p1 = ph('2026-11-27T10:00:00+08:00');
  const at = t0 + 2 * DAY;
  const grants = new Map([['trial', row(t0, t1, {source: 'trial', product: 'web_trial', state: 'revoked'})],
    ['P', row(t1, p1)]]);
  const out = replanAfterRevoke(grants, 'trial', at);
  assert.equal(out.get('P').startsAt, at);
  // A paid grant revoked ahead of a stacked trial-free chain keeps higher-tier live grants as the floor.
  const floor = new Map([['H', row(t0, t0 + 20 * DAY, {tier: 'licensure'})], ['A', row(t0, t1, {state: 'revoked'})], ['B', row(t1, p1)]]);
  assert.equal(replanAfterRevoke(floor, 'A', at).get('B').startsAt, t0 + 20 * DAY);
});

test('replan: passes and other tiers are never moved', () => {
  const t0 = ph('2026-10-20T10:00:00+08:00');
  const at = t0 + DAY;
  const grants = new Map([['A', row(t0, t0 + 30 * DAY, {state: 'revoked'})],
    ['pass', row(t0 + 30 * DAY, t0 + 90 * DAY, {product: 'pantas_pass_cse_pro'})],
    ['stu', row(t0 + 30 * DAY, t0 + 60 * DAY, {tier: 'student', product: 'pantas_pro_monthly'})]]);
  const out = replanAfterRevoke(grants, 'A', at);
  assert.equal(out.get('pass').startsAt, t0 + 30 * DAY);
  assert.equal(out.get('stu').startsAt, t0 + 30 * DAY);
});

import {applyRefund, shortenedEnd} from '../lib/paymongoGrants.js';

test('shortenedEnd: proportional from startsAt, rounded down to the second, additive not compounding', () => {
  const s = ph('2026-10-20T10:00:00+08:00'), e = s + 31 * DAY;
  assert.equal(shortenedEnd(s, e, 0, 14900), e);
  assert.equal(shortenedEnd(s, e, 7450, 14900), s + 15.5 * DAY);
  assert.equal(shortenedEnd(s, e, 3725 + 3725, 14900), shortenedEnd(s, e, 7450, 14900));
  assert.equal(shortenedEnd(s, s + 1000, 1, 3) % 1000, s % 1000);
  assert.ok(shortenedEnd(s, e, 1, 14900) < e);
});

test('applyRefund: partial shortens, repeat id is a no-op, cumulative full revokes, ended grants only record', () => {
  const s = ph('2026-10-20T10:00:00+08:00');
  const g = {...row(s, s + 31 * DAY), paidAmount: 14900};
  const a = applyRefund(g, 'r1', 7450, s + 10 * DAY);
  assert.equal(a.endsAt, s + 15.5 * DAY);
  assert.deepEqual(a.refunds, {r1: 7450});
  assert.equal(applyRefund(a, 'r1', 7450, s + 10 * DAY), a);
  assert.equal(applyRefund(a, 'r2', 7450, s + 11 * DAY).state, 'revoked');
  const ended = applyRefund(g, 'r1', 7450, s + 40 * DAY);
  assert.equal(ended.endsAt, g.endsAt);
  assert.deepEqual(ended.refunds, {r1: 7450});
  // Without a stored paid amount the web price is used.
  assert.equal(applyRefund(row(s, s + 31 * DAY), 'r1', 14900, s + DAY).state, 'revoked');
});
