import { recordSignInEvent } from '../lib/index.js';
import { getFirestore } from 'firebase-admin/firestore';
import { requireAdmin } from '../lib/_admin.js';
import { onCall } from 'firebase-functions/v2/https';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test, { after, before, beforeEach } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

const projectId = 'demo-pantas-test';
const rules = readFileSync(
  new URL('../../firestore.rules', import.meta.url),
  'utf8',
);

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: { rules },
  });
});

beforeEach(async () => {
  // Other emulator suites use the same demo project. Reset only this suite's fixtures.
  const adminDb = getFirestore();
  await Promise.all(['pro', 'free', 'new-sign-in', 'new-time', 'new-publicId',
    'new-tier', 'audit-limit-student', 'limits-test', 'other-account'].map(
    (uid) => adminDb.recursiveDelete(adminDb.doc(`users/${uid}`)),
  ));
  const ownAudits = await adminDb.collection('audit_logs').where('uid', 'in',
    ['demo-admin-guard', 'audit-limit-student', 'new-sign-in']).get();
  const auditReset = adminDb.batch();
  for (const log of ownAudits.docs) auditReset.delete(log.ref);
  await auditReset.commit();

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await setDoc(doc(db, 'users/pro'), {
      createdAt: new Date('2026-08-01T00:00:00Z'),
    });

    await setDoc(doc(db, 'users/pro/sync_state/current'), {
      activeGenerationId: 'active',
      schemaVersion: 1,
      updatedAt: new Date('2026-08-28T00:00:00Z'),
    });

    await setDoc(doc(db, 'users/pro/sync_generations/active'), {
      status: 'active',
      schemaVersion: 1,
      createdAt: new Date('2026-08-01T00:00:00Z'),
      createdByDeviceId: 'seed-device',
      preferences: {},
    });

    await setDoc(doc(db, 'users/pro/sync_generations/staging'), {
      status: 'staging',
      schemaVersion: 1,
      createdAt: new Date('2026-08-27T00:00:00Z'),
      createdByDeviceId: 'seed-device',
      preferences: {},
    });

    await setDoc(doc(db, 'users/pro/sync_generations/retired'), {
      status: 'retired',
      schemaVersion: 1,
      createdAt: new Date('2026-07-01T00:00:00Z'),
      createdByDeviceId: 'seed-device',
      preferences: {},
      retiredAt: new Date('2026-08-01T00:00:00Z'),
    });
  });
});

after(async () => {
  await testEnv.cleanup();
});

function context(uid, claims) {
  return testEnv.authenticatedContext(uid, claims).firestore();
}

function rowData(overrides = {}) {
  return {
    updatedAt: serverTimestamp(),
    originDeviceId: 'device-1',
    mutationId: 'mutation-1',
    schemaVersion: 1,
    deleted: false,
    ...overrides,
  };
}

test('anonymous Sync read and write fail', async () => {
  const db = context('anon', {
    firebase: { sign_in_provider: 'anonymous' },
    pro: true,
  });

  await assertFails(getDoc(doc(db, 'users/pro/sync_state/current')));
  await assertFails(
    setDoc(
      doc(
        db,
        'users/pro/sync_generations/active/lesson_progress/lesson-anon',
      ),
      rowData(),
    ),
  );
});

test('named Free Sync read and write fail', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: false,
  });

  await assertFails(getDoc(doc(db, 'users/pro/sync_state/current')));
  await assertFails(
    setDoc(
      doc(
        db,
        'users/pro/sync_generations/active/lesson_progress/lesson-free',
      ),
      rowData(),
    ),
  );
});

test('other named Pro cannot access owner Sync data', async () => {
  const db = context('other', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertFails(getDoc(doc(db, 'users/pro/sync_state/current')));
  await assertFails(
    getDoc(doc(db, 'users/pro/sync_generations/active')),
  );
});

test('owner named Pro reads control and generation data', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertSucceeds(getDoc(doc(db, 'users/pro/sync_state/current')));
  await assertSucceeds(
    getDoc(doc(db, 'users/pro/sync_generations/active')),
  );
});

test('client cannot write sync_state current', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertFails(
    setDoc(doc(db, 'users/pro/sync_state/current'), {
      activeGenerationId: 'staging',
      schemaVersion: 1,
      updatedAt: serverTimestamp(),
    }),
  );
});

test('named Pro owner may create a constrained staging generation', async () => {
  await assertSucceeds(stagingBatch(proDb(), ['new-staging']).commit());
});

test('client cannot create an active generation directly', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertFails(
    setDoc(doc(db, 'users/pro/sync_generations/new-active'), {
      status: 'active',
      schemaVersion: 1,
      createdAt: serverTimestamp(),
      createdByDeviceId: 'device-1',
      preferences: {},
    }),
  );
});

test('staging generation row write with exact Sync metadata succeeds', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertSucceeds(
    setDoc(
      doc(
        db,
        'users/pro/sync_generations/staging/lesson_progress/lesson-1',
      ),
      rowData(),
    ),
  );
});

test('active generation row write with exact Sync metadata succeeds', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertSucceeds(
    setDoc(
      doc(
        db,
        'users/pro/sync_generations/active/quiz_attempts/attempt-1',
      ),
      rowData(),
    ),
  );
});

test('retired generation row write fails', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertFails(
    setDoc(
      doc(
        db,
        'users/pro/sync_generations/retired/lesson_progress/lesson-1',
      ),
      rowData(),
    ),
  );
});

test('malformed Sync row metadata write fails', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertFails(
    setDoc(
      doc(
        db,
        'users/pro/sync_generations/active/lesson_progress/lesson-bad',
      ),
      rowData({ originDeviceId: '' }),
    ),
  );
});

test('client cannot mutate generation lifecycle status', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertFails(
    updateDoc(doc(db, 'users/pro/sync_generations/staging'), {
      status: 'active',
    }),
  );
});

test('preferences-only update on active generation succeeds', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertSucceeds(
    updateDoc(doc(db, 'users/pro/sync_generations/active'), {
      preferences: { theme: 'dark' },
    }),
  );
});

test('named Free account-root owner behavior remains allowed', async () => {
  const db = context('free', {
    firebase: { sign_in_provider: 'google.com' },
    pro: false,
  });

  await assertSucceeds(
    setDoc(doc(db, 'users/free'), {
      createdAt: serverTimestamp(),
    }),
  );

  await assertSucceeds(getDoc(doc(db, 'users/free')));
});

test('staging generation create rejects extra lifecycle fields', async () => {
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertFails(
    setDoc(doc(db, 'users/pro/sync_generations/overbroad-staging'), {
      status: 'staging',
      schemaVersion: 1,
      createdAt: serverTimestamp(),
      createdByDeviceId: 'device-1',
      preferences: {},
      activatedAt: serverTimestamp(),
    }),
  );
});

console.log('FIRESTORE_SYNC_RULES_TEST_COUNT=41');

// Keep this write in the rules suite so its clearFirestore hook cannot race it.
test('admin callable permits checked admin and writes an audit entry', async () => {
  assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  const callable = onCall({ enforceAppCheck: true }, (request) => requireAdmin(request));
  const uid = 'demo-admin-guard';
  assert.equal(await callable.run({
    data: {},
    auth: { uid, token: { admin: true } },
    app: { appId: 'demo-app', token: {} },
  }), uid);
  const records = await getFirestore().collection('audit_logs').where('uid', '==', uid).get();
  assert.equal(records.size, 1);
  assert.equal(records.docs[0].get('event'), 'adminAuthorized');
  assert.equal(records.docs[0].get('metadata').appId, 'demo-app');
});

for (const [field, value] of [['publicId', '123456789'], ['tier', 'civil_service']]) {
  test(`user-root create rejects client-supplied ${field}`, async () => {
    const uid = `new-${field}`;
    const db = context(uid, { firebase: { sign_in_provider: 'google.com' } });
    await assertFails(setDoc(doc(db, `users/${uid}`), {
      createdAt: serverTimestamp(),
      [field]: value,
    }));
  });
}

test('user-root create requires the server creation timestamp', async () => {
  const db = context('new-time', { firebase: { sign_in_provider: 'google.com' } });
  await assertFails(setDoc(doc(db, 'users/new-time'), {}));
  await assertFails(setDoc(doc(db, 'users/new-time'), {
    createdAt: new Date('2026-08-01T00:00:00Z'),
  }));
});

test('user-root create denies anonymous and other-account callers', async () => {
  const anon = context('new-anon', { firebase: { sign_in_provider: 'anonymous' } });
  const named = context('new-owner', { firebase: { sign_in_provider: 'google.com' } });
  await assertFails(setDoc(doc(anon, 'users/new-anon'), {
    createdAt: serverTimestamp(),
  }));
  await assertFails(setDoc(doc(named, 'users/somebody-else'), {
    createdAt: serverTimestamp(),
  }));
});

test('recordSignInEvent creates the real minimal user-root payload', async () => {
  const uid = 'new-sign-in';
  const result = await recordSignInEvent.run({
    data: {},
    auth: { uid, token: { firebase: { sign_in_provider: 'google.com' } } },
    app: { appId: 'demo-app', token: {} },
  });
  assert.deepEqual(result, { logged: true });
  const db = context(uid, { firebase: { sign_in_provider: 'google.com' } });
  const snapshot = await assertSucceeds(getDoc(doc(db, `users/${uid}`)));
  assert.deepEqual(Object.keys(snapshot.data()), ['createdAt']);
  assert.ok(snapshot.data().createdAt.toMillis() > 0);
});

function stagingData() {
  return { status: 'staging', schemaVersion: 1, createdAt: serverTimestamp(),
    createdByDeviceId: 'device-1', preferences: {} };
}
function stagingBatch(db, ids, limitId = ids[0]) {
  const batch = writeBatch(db);
  batch.set(doc(db, 'users/pro/limits/syncGeneration'), {
    lastStagedAt: serverTimestamp(), generationId: limitId,
  });
  for (const id of ids) batch.set(doc(db, `users/pro/sync_generations/${id}`), stagingData());
  return batch;
}
const proDb = () => context('pro', { firebase: { sign_in_provider: 'google.com' }, pro: true });

test('stage requires its limits write in the same batch', async () => {
  await assertFails(setDoc(doc(proDb(), 'users/pro/sync_generations/without-limit'), stagingData()));
});
test('first atomic stage succeeds and a second inside five minutes fails', async () => {
  const db = proDb();
  await assertSucceeds(stagingBatch(db, ['first']).commit());
  await assertFails(stagingBatch(db, ['second']).commit());
});
test('stage succeeds when the previous stage was at least five minutes ago', async () => {
  await testEnv.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), 'users/pro/limits/syncGeneration'), {
    lastStagedAt: new Date(Date.now() - 5 * 60 * 1000), generationId: 'old',
  }));
  await assertSucceeds(stagingBatch(proDb(), ['after-window']).commit());
});
test('one limits write cannot authorize two new generations in a batch', async () => {
  await assertFails(stagingBatch(proDb(), ['one', 'two']).commit());
});
test('stage rejects a mismatched generation id on its limits write', async () => {
  await assertFails(stagingBatch(proDb(), ['new'], 'different').commit());
});
test('clients cannot write audit counters or advance a stage limit alone', async () => {
  const db = proDb();
  await assertFails(setDoc(doc(db, 'users/pro/limits/signInAudit'), { count: 0 }));
  await assertFails(setDoc(doc(db, 'users/pro/limits/syncGeneration'), {
    lastStagedAt: serverTimestamp(), generationId: 'without-generation',
  }));
});

test('sign-in audit is limited while user-root creation always runs', async () => {
  const db = getFirestore();
  const uid = 'audit-limit-student';
  const request = { data: {}, auth: { uid, token: { firebase: { sign_in_provider: 'google.com' } } }, app: { appId: 'demo-app' } };
  await recordSignInEvent.run(request);
  await db.doc(`users/${uid}`).delete();
  await recordSignInEvent.run(request);
  assert.equal((await db.doc(`users/${uid}`).get()).exists, true);
  const logs = await db.collection('audit_logs').where('uid', '==', uid).get();
  assert.equal(logs.size, 1);
  const { Timestamp } = await import('firebase-admin/firestore');
  await db.doc(`users/${uid}/limits/signInAudit`).set({ count: 1, windowStartedAt: Timestamp.fromMillis(Date.now() - 59 * 60 * 1000) });
  await recordSignInEvent.run(request);
  assert.equal((await db.collection('audit_logs').where('uid', '==', uid).get()).size, 1);
  await db.doc(`users/${uid}/limits/signInAudit`).set({ count: 1, windowStartedAt: Timestamp.fromMillis(Date.now() - 60 * 60 * 1000) });
  await recordSignInEvent.run(request);
  assert.equal((await db.collection('audit_logs').where('uid', '==', uid).get()).size, 2);
});

test('transactional limits enforce the maximum, isolate accounts, and reopen at the window', async () => {
  const { existsSync } = await import('node:fs');
  assert.ok(existsSync(new URL('../lib/_limits.js', import.meta.url)), 'compiled limits helper must exist');
  const { allowAtMost } = await import('../lib/_limits.js');
  const db = getFirestore();
  const uid = 'limits-test';
  const grants = await Promise.all(Array.from({ length: 5 }, () => allowAtMost(uid, 'test', 2, 3600000)));
  assert.equal(grants.filter(Boolean).length, 2);
  assert.equal(await allowAtMost('other-account', 'test', 2, 3600000), true);
  const { Timestamp } = await import('firebase-admin/firestore');
  await db.doc(`users/${uid}/limits/test`).set({ count: 2, windowStartedAt: Timestamp.fromMillis(Date.now() - 3600000) });
  assert.equal(await allowAtMost(uid, 'test', 2, 3600000), true);
});

const realPayloads = {
  quiz_attempts: { id: 'a1', examId: 'exam_cse', startedAt: '2026-10-07T00:00:00Z', completedAt: null, origin: 'today_topic', itemsJson: '[]' },
  assessments: { examId: 'exam_cse', completedAt: '2026-10-07T00:00:00Z', topicScoresJson: '{}' },
  fsrs_cards: { questionId: 'q1', questionVersion: 1, stage: 'review', stability: 2, difficulty: 4, due: '2026-10-08T00:00:00Z', lastReview: '2026-10-07T00:00:00Z', reps: 1, lapses: 0, elapsedDays: 1, scheduledDays: 2 },
  lesson_progress: { lessonId: 'l1', readAt: '2026-10-07T00:00:00Z' },
  lesson_bookmarks: { lessonId: 'l1', markedAt: '2026-10-07T00:00:00Z', sortIndex: null },
  question_flags: { questionId: 'q1', flaggedAt: '2026-10-07T00:00:00Z', sortIndex: 1 },
  mock_exam_attempts: { id: 'm1', userId: 'pro', examId: 'exam_cse', blueprintId: 'b1', blueprintName: 'Practice', durationMinutes: 60, status: 'completed', strictMode: false, sampledQuestionsJson: '[]', elapsedSeconds: 60, accumulatedPausedSeconds: 0, pausedAtLastFlush: false, answersJson: '{}', flagsJson: '[]', currentIndex: 0, scoreRaw: 1, scoreTotal: 1, sectionResultsJson: '[]', totalTimeSeconds: 60, startedAt: '2026-10-07T00:00:00Z', lastFlushedAt: '2026-10-07T00:00:00Z', submittedAt: null, attemptUpdatedAt: '2026-10-07T00:00:00Z' },
  review_logs: { id: 'r1', questionId: 'q1', rating: 3, state: 2, due: '2026-10-08T00:00:00Z', stability: 2, difficulty: 4, elapsedDays: 1, lastElapsedDays: 1, scheduledDays: 2, review: '2026-10-07T00:00:00Z', durationMs: 1000, isCorrect: true, heuristicVersion: 1 },
  track_scope: { kind: 'scope', examId: 'exam_custom', topicId: 't1' },
  custom_blueprints: { examId: 'exam_custom', totalQuestions: 10, totalMinutes: 10, sectionsJson: '[]', sectionsTimedSeparately: false, blueprintUpdatedAt: '2026-10-07T00:00:00Z' },
};
for (const [name, payload] of Object.entries(realPayloads)) {
  test(`${name} accepts real payloads and tombstones but denies extra fields`, async () => {
    const db = proDb();
    const ref = doc(db, `users/pro/sync_generations/active/${name}/schema-row`);
    const metadata = { updatedAt: serverTimestamp(), originDeviceId: 'device-1', mutationId: 'mutation-1', schemaVersion: 1, deleted: false };
    await assertSucceeds(setDoc(ref, { ...payload, ...metadata }));
    await assertFails(setDoc(ref, { ...payload, ...metadata, arbitraryField: 'injected' }));
    await assertSucceeds(setDoc(ref, { ...metadata, deleted: true }));
  });
}
test('track_scope metadata payload is allowed', async () => {
  await assertSucceeds(setDoc(doc(proDb(), 'users/pro/sync_generations/active/track_scope/meta'), {
    kind: 'custom_track', examId: 'exam_custom', name: 'My exam', updatedAt: serverTimestamp(),
    originDeviceId: 'device-1', mutationId: 'meta-mutation', schemaVersion: 1, deleted: false,
  }));
});

test('generation cleanup queries are bounded to 500 results per page', async () => {
  const { Query, Timestamp } = await import('firebase-admin/firestore');
  const db = getFirestore();
  const old = Timestamp.fromMillis(Date.now() - 8 * 86400000);
  for (let start = 0; start < 501; start += 500) {
    const batch = db.batch();
    for (let i = start; i < Math.min(start + 500, 501); i++) {
      batch.set(db.doc(`users/pro/sync_generations/page-${String(i).padStart(3, '0')}`), { status: 'staging', createdAt: old });
    }
    await batch.commit();
  }
  await db.doc('users/pro/sync_state/current').set({ activeGenerationId: 'page-000' });
  const { mock } = await import('node:test');
  const { cleanupSyncData } = await import('../lib/cleanupSyncData.js');
  const originalGet = Query.prototype.get;
  const limits = [];
  const replacement = function (...args) {
    if (this._queryOptions.collectionId === 'sync_generations' && this._queryOptions.allDescendants) {
      limits.push(this._queryOptions.limit);
      assert.equal(this._queryOptions.limit, 500);
    }
    return Reflect.apply(originalGet, this, args);
  };
  mock.method(Query.prototype, 'get', replacement);
  try {
    await cleanupSyncData.run({ scheduleTime: new Date().toISOString() });
    assert.ok(limits.length >= 3);
    const remaining = await db.collection('users/pro/sync_generations').get();
    assert.deepEqual(remaining.docs.map((d) => d.id).sort(), ['active', 'page-000']);
  } finally {
    mock.restoreAll();
  }
});
