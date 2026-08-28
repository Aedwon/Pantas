import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

test('index exports privacy and audit callables', () => {
  const source = readFileSync(new URL('../src/index.ts', import.meta.url), 'utf8');

  assert.match(source, /export \{ exportData \}/);
  assert.match(source, /export \{ deleteAccount \}/);
  assert.match(source, /export \{ resetCloudUserData \}/);
  assert.match(source, /export \{ revenuecatWebhook \}/);
  assert.match(source, /export \{ getProContent \}/);
  assert.match(source, /export \{ recordSignInEvent \}/);
  assert.match(source, /export \{ onUserCreated \}/);
});

test('sensitive callables enforce App Check and consume replay tokens', () => {
  const exportData = readFileSync(
    new URL('../src/exportData.ts', import.meta.url),
    'utf8',
  );
  const deleteAccount = readFileSync(
    new URL('../src/deleteAccount.ts', import.meta.url),
    'utf8',
  );

  for (const source of [exportData, deleteAccount]) {
    assert.match(source, /enforceAppCheck: true/);
    assert.match(source, /consumeAppCheckToken: true/);
    assert.match(source, /assertNamedUser\(request\.auth\)/);
  }

  const audit = readFileSync(new URL('../src/_audit.ts', import.meta.url), 'utf8');
  assert.match(audit, /sign_in_provider === 'anonymous'/);
});

test('named-user guard uses structured callable errors', () => {
  const source = readFileSync(new URL('../src/_audit.ts', import.meta.url), 'utf8');

  assert.match(source, /HttpsError/);
  assert.match(source, /new HttpsError\('unauthenticated'/);
  assert.match(source, /'permission-denied'/);
});

test('audit helper writes Cloud Logging and Firestore audit_logs', () => {
  const source = readFileSync(new URL('../src/_audit.ts', import.meta.url), 'utf8');

  assert.match(source, /logger\.info\('audit'/);
  assert.match(source, /collection\('audit_logs'\)/);
});

test('recordSignInEvent ensures a minimal user root before audit', () => {
  const source = readFileSync(
    new URL('../src/recordSignInEvent.ts', import.meta.url),
    'utf8',
  );
  const rootIndex = source.indexOf("collection('users').doc(uid)");
  const transactionIndex = source.indexOf('runTransaction');
  const createIndex = source.indexOf('transaction.create');
  const createdAtIndex = source.indexOf('createdAt: FieldValue.serverTimestamp()');
  const auditIndex = source.indexOf('await writeAuditLog');

  assert.notEqual(rootIndex, -1);
  assert.notEqual(transactionIndex, -1);
  assert.notEqual(createIndex, -1);
  assert.notEqual(createdAtIndex, -1);
  assert.notEqual(auditIndex, -1);
  assert.ok(rootIndex < auditIndex);
  assert.ok(transactionIndex < auditIndex);
  assert.ok(createIndex < auditIndex);
  assert.doesNotMatch(source, /proIsActive|isPro|study_progress/);
});

test('resetCloudUserData is App Check enforced and wipes sync collections', () => {
  const source = readFileSync(
    new URL('../src/resetCloudUserData.ts', import.meta.url),
    'utf8',
  );

  assert.match(source, /enforceAppCheck: true/);
  assert.doesNotMatch(source, /consumeAppCheckToken: true/);
  assert.match(source, /assertNamedUser\(request\.auth\)/);

  for (const collection of [
    'lesson_progress',
    'quiz_attempts',
    'fsrs_cards',
    'assessments',
    'study_plan',
    'mock_exam_attempts',
  ]) {
    assert.match(source, new RegExp(`collection\\('${collection}'\\)`));
  }
  assert.match(source, /cloudDataReset/);
});

test('deleteAccount uses asia-southeast1 app check replay protection', () => {
  const source = readFileSync(
    new URL('../src/deleteAccount.ts', import.meta.url),
    'utf8',
  );

  assert.match(source, /region: 'asia-southeast1'/);
  assert.match(source, /enforceAppCheck: true/);
  assert.match(source, /consumeAppCheckToken: true/);
});

test('deleteAccount checks recent auth before destructive work', () => {
  const source = readFileSync(
    new URL('../src/deleteAccount.ts', import.meta.url),
    'utf8',
  );

  const authTimeIndex = source.indexOf('auth_time');
  const recentLoginIndex = source.indexOf('requires-recent-login');
  const deleteIndex = source.indexOf('recursiveDelete');

  assert.notEqual(authTimeIndex, -1);
  assert.notEqual(recentLoginIndex, -1);
  assert.notEqual(deleteIndex, -1);
  assert.match(source, /new HttpsError\(/);
  assert.match(source, /'failed-precondition'/);
  assert.ok(authTimeIndex < deleteIndex);
  assert.ok(recentLoginIndex < deleteIndex);
});

test('deleteAccount audit write appears before recursive delete', () => {
  const source = readFileSync(
    new URL('../src/deleteAccount.ts', import.meta.url),
    'utf8',
  );

  const auditIndex = source.indexOf('await writeAuditLog');
  const deleteIndex = source.indexOf('recursiveDelete');
  const userDocIndex = source.indexOf("collection('users').doc(uid)");

  assert.notEqual(auditIndex, -1);
  assert.notEqual(deleteIndex, -1);
  assert.notEqual(userDocIndex, -1);
  assert.ok(auditIndex < deleteIndex);
  assert.ok(userDocIndex < deleteIndex);
});

test('deleteAccount deletes Firebase Auth identity after all data cleanup', () => {
  const source = readFileSync(
    new URL('../src/deleteAccount.ts', import.meta.url),
    'utf8',
  );

  const firestoreIndex = source.indexOf('recursiveDelete');
  const sharedIndex = source.indexOf('sharedCards.docs.map');
  const storageIndex = source.indexOf('deleteFiles');
  const authDeleteIndex = source.indexOf('getAuth().deleteUser(uid)');

  for (const index of [firestoreIndex, sharedIndex, storageIndex, authDeleteIndex]) {
    assert.notEqual(index, -1);
  }
  assert.ok(firestoreIndex < authDeleteIndex);
  assert.ok(sharedIndex < authDeleteIndex);
  assert.ok(storageIndex < authDeleteIndex);
});

test('exportData remains app check enforced if kept', () => {
  const source = readFileSync(
    new URL('../src/exportData.ts', import.meta.url),
    'utf8',
  );

  assert.match(source, /enforceAppCheck: true/);
  assert.match(source, /consumeAppCheckToken: true/);
  assert.match(source, /assertNamedUser\(request\.auth\)/);
});
