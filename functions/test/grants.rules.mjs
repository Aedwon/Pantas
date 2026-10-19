import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before, after} from 'node:test';
import {initializeTestEnvironment, assertSucceeds, assertFails} from '@firebase/rules-unit-testing';
import {doc, getDoc, setDoc, updateDoc, deleteDoc} from 'firebase/firestore';
assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
let env;
before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-pantas-test',
    firestore: {rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8')}});
  await env.withSecurityRulesDisabled(async context => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/grant-rules/grants/pay_1'), {source: 'paymongo', product: 'pantas_cs_monthly', state: 'active', endsAt: 1900000000000});
    await setDoc(doc(db, 'users/grant-rules/server/trial'), {usedAt: 1, grantId: 'trial'});
    await setDoc(doc(db, 'paymongoPayments/pay_1'), {uid: 'grant-rules'});
    await setDoc(doc(db, 'paymongoRevocations/pay_1'), {reason: 'refund.succeeded'});
  });
});
after(async () => env.cleanup());
const named = uid => env.authenticatedContext(uid, {firebase: {sign_in_provider: 'google.com'}}).firestore();
test('the owner reads their grants, named or anonymous, without a Pro claim', async () => {
  for (const provider of ['google.com', 'anonymous']) {
    const db = env.authenticatedContext('grant-rules', {firebase: {sign_in_provider: provider}}).firestore();
    assert.equal((await assertSucceeds(getDoc(doc(db, 'users/grant-rules/grants/pay_1')))).get('product'), 'pantas_cs_monthly');
  }
});
test('clients cannot create, change or delete grants, even an admin owner', async () => {
  const own = env.authenticatedContext('grant-rules', {firebase: {sign_in_provider: 'google.com'}, admin: true, pro: true, proUntil: 4102444800000}).firestore();
  await assertFails(setDoc(doc(own, 'users/grant-rules/grants/pay_2'), {source: 'trial', state: 'active', endsAt: 4102444800000}));
  await assertFails(setDoc(doc(own, 'users/grant-rules/grants/trial'), {source: 'trial'}));
  await assertFails(updateDoc(doc(own, 'users/grant-rules/grants/pay_1'), {endsAt: 4102444800000}));
  await assertFails(deleteDoc(doc(own, 'users/grant-rules/grants/pay_1')));
});
test('other accounts and signed-out clients cannot read grants', async () => {
  await assertFails(getDoc(doc(named('someone-else'), 'users/grant-rules/grants/pay_1')));
  await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'users/grant-rules/grants/pay_1')));
});
test('the trial record, payment index and webhook ledgers stay server-only', async () => {
  const own = named('grant-rules');
  await assertFails(getDoc(doc(own, 'users/grant-rules/server/trial')));
  await assertFails(setDoc(doc(own, 'users/grant-rules/server/trial'), {usedAt: 0}));
  await assertFails(deleteDoc(doc(own, 'users/grant-rules/server/trial')));
  await assertFails(getDoc(doc(own, 'paymongoPayments/pay_1')));
  await assertFails(setDoc(doc(own, 'paymongoPayments/pay_9'), {uid: 'grant-rules'}));
  await assertFails(getDoc(doc(own, 'paymongoRevocations/pay_1')));
  await assertFails(setDoc(doc(own, 'paymongoRevocations/pay_9'), {reason: 'x'}));
  await assertFails(deleteDoc(doc(own, 'paymongoRevocations/pay_1')));
  await assertFails(getDoc(doc(own, 'webhookEvents/evt_1/users/grant-rules')));
});
