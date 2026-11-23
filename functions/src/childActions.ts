import {getAuth} from 'firebase-admin/auth';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, type CallableOptions, type CallableRequest} from 'firebase-functions/v2/https';
import {assertAccountActive, onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {assertNamedUser} from './_audit.js';
import {appSecrets} from './_secrets.js';
import {canManageChild, childEntryPath, holderForChild} from './childLinks.js';
import {deleteUserData} from './deleteUserData.js';
import {consumeGuardianProof} from './guardianCodeGate.js';
import {ACCOUNT_DELETION_MAX_INSTANCES} from './_options.js';
import {timed} from './_timed.js';

export const SIBLING_NOTICE_VERSION = '2026-11-20';

const notLinked = () => new HttpsError('permission-denied', 'This account is not linked to that child.',
  {reason: 'not-linked'});

/** The holder can act directly. The child session can act for itself via the holder's code. */
async function childHolder(db: Firestore, caller: string, childId: unknown): Promise<string> {
  if (typeof childId !== 'string' || !/^[^/\s]{1,128}$/.test(childId) || childId === '.' || childId === '..') {
    throw new HttpsError('invalid-argument', 'Name the child.');
  }
  const holder = await holderForChild(db, childId);
  if (!holder || !canManageChild(caller, holder, childId)) throw notLinked();
  await Promise.all([assertAccountActive(db, childId), assertAccountActive(db, holder)]);
  return holder;
}

export async function closeChild(caller: string, childId: string, proofId: unknown, action: 'withdraw' | 'delete') {
  const db = getFirestore();
  const holder = await childHolder(db, caller, childId);
  await consumeGuardianProof(proofId, holder, childId, action, {db});
  // Withdrawal closes the account and erases study data. The deletion path retains required evidence.
  await deleteUserData(db, getAuth(), childId, action === 'withdraw' ? 'guardian_withdrawal' : 'user_request');
  return {deletedAt: new Date().toISOString()};
}

function closeRequest(request: CallableRequest, action: 'withdraw' | 'delete') {
  const uid = assertNamedUser(request.auth);
  const childId: unknown = request.data?.childId;
  if (typeof childId !== 'string') throw new HttpsError('invalid-argument', 'Name the child.');
  return closeChild(uid, childId, request.data?.guardianProofId, action);
}

const options = {
  region: 'asia-southeast1',
  enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck,
  maxInstances: ACCOUNT_DELETION_MAX_INSTANCES,
  secrets: [appSecrets],
} satisfies CallableOptions;

export const withdrawChild = onCall(options, timed('withdrawChild', request => {
  assertFreshAppCheck(request);
  return closeRequest(request, 'withdraw');
}));

export const deleteChild = onCall(options, timed('deleteChild', request => {
  assertFreshAppCheck(request);
  return closeRequest(request, 'delete');
}));

export const setSiblingOpen = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck}, timed('setSiblingOpen', async request => {
  assertFreshAppCheck(request);
  const uid = assertNamedUser(request.auth);
  const {childId, open, guardianProofId} = request.data ?? {};
  if (typeof childId !== 'string' || typeof open !== 'boolean') {
    throw new HttpsError('invalid-argument', 'Name the child and choose whether to allow sibling access.');
  }
  const db = getFirestore();
  const holder = await childHolder(db, uid, childId);
  if (open) await consumeGuardianProof(guardianProofId, holder, childId, 'siblingOptIn', {db});
  const entry = db.doc(childEntryPath(holder, childId));
  await db.runTransaction(async tx => {
    const [row, deletion] = await tx.getAll(entry, db.doc(`accountDeletions/${childId}`));
    if (row.get('active') !== true || deletion.exists) throw notLinked();
    tx.update(entry, {siblingOpenWithoutCode: open, siblingAccessChangedAt: Date.now(),
      siblingNoticeVersion: SIBLING_NOTICE_VERSION});
  });
  return {siblingOpenWithoutCode: open};
}));
