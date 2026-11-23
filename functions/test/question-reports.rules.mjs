import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before, after} from 'node:test';
import {initializeTestEnvironment, assertFails} from '@firebase/rules-unit-testing';
import {collection, doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc} from 'firebase/firestore';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
let env;
before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-pantas-test',
    firestore: {rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8')}});
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'questionReports/cXItb3duZXI.report-id-0000001'),
      {accountId: 'qr-owner', questionId: 'q1', message: 'x'});
    await setDoc(doc(context.firestore(), 'users/qr-owner/server/questionReportDay'), {day: 'x', count: 1});
    await setDoc(doc(context.firestore(), 'users/qr-owner/questionReportCounts/qabc'), {count: 1});
  });
});
after(async () => env?.cleanup());
for (const client of ['owner-named', 'owner-anonymous', 'other', 'signed-out']) {
  test(`question reports and their counts deny all client access: ${client}`, async () => {
    const db = client === 'signed-out' ? env.unauthenticatedContext().firestore()
      : env.authenticatedContext(client.startsWith('owner') ? 'qr-owner' : 'qr-other', {
        firebase: {sign_in_provider: client === 'owner-anonymous' ? 'anonymous' : 'google.com'},
      }).firestore();
    for (const path of ['questionReports/cXItb3duZXI.report-id-0000001', 'users/qr-owner/server/questionReportDay', 'users/qr-owner/questionReportCounts/qabc']) {
      const ref = doc(db, path);
      await assertFails(getDoc(ref));
      await assertFails(setDoc(ref, {message: 'changed'}));
      await assertFails(updateDoc(ref, {message: 'changed'}));
      await assertFails(deleteDoc(ref));
    }
    await assertFails(setDoc(doc(db, `questionReports/${client}_report-id-0000002`),
      {accountId: 'qr-owner', questionId: 'q1', message: 'new'}));
    await assertFails(getDocs(collection(db, 'questionReports')));
    await assertFails(getDocs(collection(db, 'users/qr-owner/questionReportCounts')));
  });
}
