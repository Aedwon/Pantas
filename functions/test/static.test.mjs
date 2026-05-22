import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

test('index exports privacy and audit callables', () => {
  const source = readFileSync(new URL('../src/index.ts', import.meta.url), 'utf8');

  assert.match(source, /export \{ exportData \}/);
  assert.match(source, /export \{ deleteAccount \}/);
  assert.match(source, /export \{ resetCloudUserData \}/);
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

test('audit helper writes Cloud Logging and Firestore audit_logs', () => {
  const source = readFileSync(new URL('../src/_audit.ts', import.meta.url), 'utf8');

  assert.match(source, /logger\.info\('audit'/);
  assert.match(source, /collection\('audit_logs'\)/);
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
