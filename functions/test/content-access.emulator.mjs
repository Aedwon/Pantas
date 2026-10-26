import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {serveContent} from '../lib/content.js';
import {questionSetItems, writeContent} from '../lib/contentUpload.js';
const db = getFirestore(), NOW = Date.UTC(2026, 10, 20), DAY = 86400000;
const uid = 'content-access-regression';
const auth = {uid, token: {pro: true, proUntil: NOW + DAY}};
const deps = {db, now: () => NOW, allow: async () => true};
const sets = ['cse-pro', 'cse-sub', 'upcat', 'let', 'unknown'].map(exam => questionSetItems({
  meta: {exams: [exam]}, questions: [{id: 'q', explanation: 'free', choices: [{text: 'wrong', rationale: 'PAID'}]}],
}, `access/${exam}.yaml`));
const ask = (knownVersions = {}) => serveContent(auth, {kind: 'questions', ids: sets.map(s => s.item.id), knownVersions}, deps);
const paid = (out, i) => JSON.stringify(out.items[sets[i].item.id]).includes('PAID');
const grant = (product, extra = {}) => db.doc(`users/${uid}/grants/test`).set({source: 'paymongo', product, tier: 'civilService', startsAt: NOW - DAY, endsAt: NOW + DAY, state: 'active', ...extra});
test('content uses current exam coverage, revocation, exact expiry and starts, despite stale claims and cached paid versions', async () => {
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await writeContent(db, sets.map(s => s.item), sets.map(s => s.pro), {});
  await grant('pantas_pass_cse_pro');
  const first = await ask();
  assert.deepEqual(sets.map((_, i) => paid(first, i)), [true, false, false, false, false]);
  const versions = Object.fromEntries(Object.entries(first.items).map(([id, e]) => [id, e.version]));
  for (const extra of [{state: 'revoked'}, {endsAt: NOW}, {startsAt: NOW + 1}]) {
    await grant('pantas_pass_cse_pro', extra);
    const out = await ask(versions);
    assert.equal(out.tier, 'free');
    assert.equal(out.items[sets[0].item.id].status, 'ok');
    assert.equal(paid(out, 0), false);
    assert.match(out.items[sets[0].item.id].version, /\.f$/);
  }
  await grant('pantas_cs_monthly');
  const subscription = await ask();
  assert.deepEqual(sets.map((_, i) => paid(subscription, i)), [true, true, true, false, false]);
  await db.doc(`users/${uid}/grants/test`).delete();
  await db.doc(`users/${uid}/passes/native`).set({product: 'pantas_pass_cse_pro', examId: 'exam_cse_pro', endsAt: NOW + DAY, state: 'active'});
  const native = await ask();
  assert.deepEqual(sets.map((_, i) => paid(native, i)), [true, false, false, false, false]);
  await db.doc(`users/${uid}/passes/native`).update({state: 'revoked'});
  assert.equal((await ask()).tier, 'free');
  const source = {productId: 'pantas_cs_monthly', appId: 'test-app', entitlementIds: ['pro'], environment: 'production', active: true, endsAt: NOW + DAY};
  const record = db.doc(`users/${uid}/server/entitlement`);
  const facts = sources => ({sources, coverageContext: {appId: 'test-app', firebaseProjectId: 'demo-pantas-test', sandboxTester: false}});
  await record.set({facts: facts([source])});
  const rc = await ask();
  assert.deepEqual(sets.map((_, i) => paid(rc, i)), [true, true, true, false, false]);
  for (const change of [{active: false}, {endsAt: NOW}]) {
    await record.set({facts: facts([{...source, ...change}])});
    assert.equal((await ask()).tier, 'free');
  }
});
