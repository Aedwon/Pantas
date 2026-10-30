import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {getAuth, type Auth} from 'firebase-admin/auth';
import {HttpsError, onCall, type CallableRequest} from 'firebase-functions/v2/https';
import {assertFreshAppCheck} from './_appCheck.js';
import {assertNamedUser} from './_audit.js';
import {allowAtMost} from './_limits.js';
import {examCatalog} from './revenuecatPasses.js';
import {readEntitlementInputs, claimsFromInputs, entitlementWrite, nativeCoverageRows} from './entitlementInputs.js';
import {copyEntitlementClaims} from './revenuecatClaims.js';
import {reanchorQueued} from './paymongoGrants.js';
import type {Grant} from './grants.js';

export const BETA_CUTOFF = Date.parse('2026-11-16T00:00:00+08:00');
/** Missing or invalid server config disables beta; config can never extend the approved window. */
export function betaProUntil(at: number): number | null {
  const configured = Date.parse(process.env.BETA_PRO_UNTIL ?? '');
  return Number.isFinite(configured) && at < Math.min(configured, BETA_CUTOFF)
    ? Math.min(configured, BETA_CUTOFF) : null;
}
type Deps = {db: Firestore; auth: Pick<Auth, 'getUser' | 'setCustomUserClaims'>;
  now?: () => number; until?: (at: number) => number | null; allow?: (uid: string) => Promise<boolean>};
export async function changeBetaPro(request: Pick<CallableRequest, 'auth' | 'app' | 'data'>, deps: Deps) {
  if (!request.app) throw new HttpsError('unauthenticated', 'App Check is required.');
  assertFreshAppCheck(request);
  const uid = assertNamedUser(request.auth);
  const data = request.data as {enabled?: unknown; examId?: unknown; uid?: unknown} | null;
  if (data?.uid !== undefined && data.uid !== uid) throw new HttpsError('permission-denied', 'The account changed. Try again.');
  const examId = data?.examId;
  if (typeof data?.enabled !== 'boolean' || typeof examId !== 'string' ||
      !examCatalog.some(exam => exam.id === examId) || !['exam_cse_pro', 'exam_cse_sub'].includes(examId)) {
    throw new HttpsError('invalid-argument', 'Choose a supported exam and switch state.');
  }
  if (!await (deps.allow ?? (id => allowAtMost(id, 'betaPro', 30, 10 * 60_000)))(uid)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const result = await deps.db.runTransaction(async tx => {
    // Evaluate again on transaction retries, so a retry cannot grant after the cutoff.
    const now = (deps.now ?? Date.now)();
    const until = (deps.until ?? betaProUntil)(now);
    if (until === null || now >= until || until > BETA_CUTOFF) {
      throw new HttpsError('failed-precondition', 'The beta has ended.');
    }
    const inputs = await readEntitlementInputs(tx, deps.db, uid);
    const id = `beta_${examId}`, previous = inputs.grants.get(id);
    const enabled = data.enabled as boolean;
    if (!previous && !enabled) return {enabled, betaProUntil: until};
    const grant: Grant = {source:'beta', product:'beta_pro', tier:'civilService', examId,
      startsAt: previous?.startsAt ?? now, endsAt: until, createdAt: previous?.createdAt ?? now,
      state: enabled ? 'active' : 'revoked'};
    const changed = !previous || previous.state !== grant.state || previous.endsAt !== until;
    if (changed) {
      const grants = reanchorQueued(new Map(inputs.grants).set(id, grant), nativeCoverageRows(inputs, now), now);
      for (const [gid, row] of grants) if (row !== inputs.grants.get(gid)) tx.set(deps.db.doc(`users/${uid}/grants/${gid}`), row);
      tx.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, grants)), {merge:true});
    }
    return {enabled, betaProUntil: until};
  });
  await copyEntitlementClaims(deps.db, deps.auth, uid);
  return result;
}
export const setBetaPro = onCall({region:'asia-southeast1', enforceAppCheck:true, consumeAppCheckToken:true},
  request => {
    assertFreshAppCheck(request);
    return changeBetaPro(request, {db:getFirestore(), auth:getAuth()});
  });
