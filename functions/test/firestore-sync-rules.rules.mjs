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
  await testEnv.clearFirestore();

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
    value: 1,
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
  const db = context('pro', {
    firebase: { sign_in_provider: 'google.com' },
    pro: true,
  });

  await assertSucceeds(
    setDoc(doc(db, 'users/pro/sync_generations/new-staging'), {
      status: 'staging',
      schemaVersion: 1,
      createdAt: serverTimestamp(),
      createdByDeviceId: 'device-1',
      preferences: { theme: 'system' },
    }),
  );
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

console.log('FIRESTORE_SYNC_RULES_TEST_COUNT=21');

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
