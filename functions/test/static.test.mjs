import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import test from 'node:test';

test('index exports privacy and audit callables', () => {
  const source = readFileSync(new URL('../src/index.ts', import.meta.url), 'utf8');

  assert.match(source, /export \{ exportData \}/);
  assert.match(source, /export \{ deleteAccount \}/);
  const obsoleteResetName = ['reset', 'CloudUserData'].join('');
  assert.doesNotMatch(source, new RegExp(obsoleteResetName));
  assert.match(source, /export \{ activateSyncGeneration \}/);
  assert.match(source, /export \{ cleanupSyncData \}/);
  assert.match(source, /export \{ revenuecatWebhook \}/);
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
    assert.match(source, /enforceAppCheck: enforceAppCheck/);
    assert.match(source, /consumeAppCheckToken: enforceAppCheck/);
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

test('activateSyncGeneration owns generation activation transaction', () => {
  const activationUrl = new URL(
    '../src/activateSyncGeneration.ts',
    import.meta.url,
  );

  assert.equal(
    existsSync(activationUrl),
    true,
    'activateSyncGeneration.ts must exist',
  );

  const source = readFileSync(activationUrl, 'utf8');
  const indexSource = readFileSync(
    new URL('../src/index.ts', import.meta.url),
    'utf8',
  );

  assert.match(source, /onCall/);
  assert.match(source, /region: 'asia-southeast1'/);
  assert.match(source, /enforceAppCheck:\s*enforceAppCheck/);
  assert.match(source, /runTransaction/);
  assert.match(source, /assertNamedPro/);
  assert.match(source, /generation-conflict/);
  assert.match(source, /invalid-generation/);
  assert.match(source, /sync_state/);
  assert.match(source, /sync_generations/);
  assert.match(source, /status:\s*'active'/);
  assert.match(source, /status:\s*'retired'/);
  assert.match(source, /activeGenerationId/);
  assert.match(source, /syncGenerationActivated/);
  assert.match(source, /'permission-denied'/);
  assert.match(source, /'invalid-argument'/);
  assert.match(source, /'failed-precondition'/);

  const obsoleteResetName = ['reset', 'CloudUserData'].join('');
  assert.doesNotMatch(indexSource, new RegExp(obsoleteResetName));
  assert.match(indexSource, /activateSyncGeneration/);
});

test('obsolete cloud reset source is removed', () => {
  const obsoleteResetName = ['reset', 'CloudUserData'].join('');
  assert.equal(
    existsSync(new URL(`../src/${obsoleteResetName}.ts`, import.meta.url)),
    false,
  );
});

test('cleanupSyncData applies retention with a fresh active-pointer recheck', () => {
  const cleanupUrl = new URL('../src/cleanupSyncData.ts', import.meta.url);

  assert.equal(
    existsSync(cleanupUrl),
    true,
    'cleanupSyncData.ts must exist',
  );

  const source = readFileSync(cleanupUrl, 'utf8');
  const indexSource = readFileSync(
    new URL('../src/index.ts', import.meta.url),
    'utf8',
  );

  assert.match(source, /onSchedule/);
  assert.match(source, /region:\s*'asia-southeast1'/);
  assert.match(source, /TOMBSTONE_RETENTION_DAYS/);
  assert.match(source, /STAGING_RETENTION_DAYS/);
  assert.match(source, /RETIRED_RETENTION_DAYS/);
  assert.match(source, /generationCleanupEligible/);
  assert.match(source, /collectionGroup/);
  assert.match(source, /deleted/);
  assert.match(source, /updatedAt/);
  assert.match(source, /limit\(500\)/);
  assert.match(source, /sync_state/);
  assert.match(source, /activeGenerationId/);
  assert.match(source, /recursiveDelete/);

  for (const collection of [
    'quiz_attempts',
    'assessments',
    'fsrs_cards',
    'lesson_progress',
    'lesson_bookmarks',
    'question_flags',
    'mock_exam_attempts',
    'review_logs',
    'track_scope',
    'custom_blueprints',
  ]) {
    assert.match(source, new RegExp(`'${collection}'`));
  }

  const freshPointerIndex = source.indexOf(
    'const freshCurrentSnapshot = await transaction.get(currentRef)',
  );
  const freshActiveIndex = source.indexOf(
    'const freshActiveGenerationId',
  );
  const activeCompareIndex = source.indexOf(
    'freshActiveGenerationId === candidateGenerationId',
  );
  const freshGenerationIndex = source.indexOf(
    'const freshGenerationSnapshot = await transaction.get(candidateRef)',
  );
  const eligibilityIndex = source.lastIndexOf(
    'generationCleanupEligible',
  );
  const recursiveDeleteIndex = source.indexOf(
    'recursiveDelete(candidateRef)',
  );

  for (const index of [
    freshPointerIndex,
    freshActiveIndex,
    activeCompareIndex,
    freshGenerationIndex,
    eligibilityIndex,
    recursiveDeleteIndex,
  ]) {
    assert.notEqual(index, -1);
  }

  assert.ok(freshPointerIndex < freshActiveIndex);
  assert.ok(freshActiveIndex < activeCompareIndex);
  assert.ok(activeCompareIndex < freshGenerationIndex);
  assert.ok(freshGenerationIndex < eligibilityIndex);
  assert.ok(eligibilityIndex < recursiveDeleteIndex);

  assert.match(indexSource, /export \{ cleanupSyncData \}/);
});

test('deleteAccount uses asia-southeast1 app check replay protection', () => {
  const source = readFileSync(
    new URL('../src/deleteAccount.ts', import.meta.url),
    'utf8',
  );

  assert.match(source, /region: 'asia-southeast1'/);
  assert.match(source, /enforceAppCheck: enforceAppCheck/);
  assert.match(source, /consumeAppCheckToken: enforceAppCheck/);
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

  assert.match(source, /enforceAppCheck: enforceAppCheck/);
  assert.match(source, /consumeAppCheckToken: enforceAppCheck/);
  assert.match(source, /assertNamedUser\(request\.auth\)/);
});
