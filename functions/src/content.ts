import {enforceAppCheck} from './_appCheck.js';
import {setCoveredByTags} from './_setCoverage.js';
import {getFirestore, type DocumentSnapshot, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {sharedCeiling, type Ceiling} from './_contentCeiling.js';
import {allowAtMost, takeAtMost} from './_limits.js';
import {mockCoverage} from './mockAccess.js';
import {examCatalog} from './revenuecatPasses.js';
import {timed} from './_timed.js';

/**
 * Limits on getContent. Aedwon approved this design on 2 November 2026; the numbers may be tuned.
 * They slow bulk copying of paid content. They are not meant to stop an honest student.
 *
 * Four limits apply, all returning the same "Daily content limit reached" error:
 *
 * 1. Delivered budget, per account per rolling day: DAILY_CONTENT_IDS (300) lessons and question
 *    sets, DAILY_CATALOG_IDS (200) catalog documents. Only an `ok` response, which sends content,
 *    costs 1. `unchanged` and `missing` cost nothing here. The bank is about 320 documents, so
 *    one account needs more than a day to read it all. Items past the budget return `limited`
 *    instead of content, and the call fails if none fit. The budget is taken in one transaction
 *    after the delivered set is known (`takeAtMost`), so concurrent calls cannot pass it.
 * 2. Request cap, per account per rolling day: DAILY_CONTENT_REQUESTS and DAILY_CATALOG_REQUESTS
 *    (1000 each) ids asked about, delivered or not. It stops version checks being used as a
 *    probe or a load. It is checked before any document is read.
 * 3. A daily ceiling over all accounts on delivered lesson and question ids (`_contentCeiling`).
 *    The catalog is exempt, so the app still opens. Content a caller has paid access to is also
 *    exempt, so throwaway accounts cannot lock paying students out; their deliveries still count
 *    in the total, and limits 1 and 2 still bind them. The worst-case bill therefore also depends
 *    on the number of paid accounts, each bounded by limits 1 and 2.
 * 4. App Check and sign-in (anonymous accounts included) in front of all of it.
 *
 * None of these stops someone who makes many accounts; App Check, the anonymous-account controls
 * and the ceiling cover that.
 */
export const DAILY_CONTENT_IDS = 300;
export const DAILY_CATALOG_IDS = 200;
export const DAILY_CONTENT_REQUESTS = 1000;
export const DAILY_CATALOG_REQUESTS = 1000;
export const MAX_IDS_PER_CALL = 20;
export const ID_PATTERN = /^[A-Za-z0-9_.-]{1,160}$/;

const DAY_MS = 86_400_000;
const LIMIT_MESSAGE = 'Daily content limit reached. Try again tomorrow.';

type Entry = {status: 'ok'; version: string; data: Record<string, unknown>}
  | {status: 'unchanged'; version: string} | {status: 'missing'} | {status: 'limited'};
export type ContentResponse = {tier: 'free' | 'pro'; items: Record<string, Entry>};
export type ContentDeps = {
  db: Firestore;
  now?: () => number;
  dailyIds?: number;
  dailyCatalogIds?: number;
  dailyRequests?: number;
  dailyCatalogRequests?: number;
  /**
   * Test shorthand. Replaces the request cap and the delivered budget: false refuses, true
   * allows everything. The ceiling is skipped unless `ceiling` is also given.
   */
  allow?: (uid: string, cost: number) => Promise<boolean>;
  /** The cross-account ceiling. `null` turns it off. */
  ceiling?: Ceiling | null;
};
type Auth = {uid: string; token: object} | undefined;
type Candidate = {id: string; version: string; paid: boolean; snapshot: DocumentSnapshot};

const exhausted = (kind: 'content' | 'catalog', scope: 'requests' | 'delivered' | 'ceiling') =>
  new HttpsError('resource-exhausted', LIMIT_MESSAGE, {kind, scope});

export async function serveContent(auth: Auth, data: unknown, deps: ContentDeps): Promise<ContentResponse> {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  const request = data as {kind?: unknown; ids?: unknown; knownVersions?: unknown} | null;
  const kind = request?.kind;
  if (kind !== 'lessons' && kind !== 'questions' && kind !== 'catalog') throw new HttpsError('invalid-argument', 'Unknown content kind.');
  const ids = request?.ids;
  if (!Array.isArray(ids) || ids.length < 1 || ids.length > MAX_IDS_PER_CALL
      || !ids.every((id): id is string => typeof id === 'string' && ID_PATTERN.test(id))) {
    throw new HttpsError('invalid-argument', `Send 1 to ${MAX_IDS_PER_CALL} valid ids.`);
  }
  const unique = [...new Set(ids)];
  const known = request?.knownVersions && typeof request.knownVersions === 'object'
    ? request.knownVersions as Record<string, unknown> : {};
  const now = (deps.now ?? Date.now)();
  const scope = kind === 'catalog' ? 'catalog' : 'content';
  const uid = auth.uid;

  // 1. The request cap, before anything is read.
  const withinRequests = deps.allow
    ? await deps.allow(uid, unique.length)
    : await allowAtMost(uid, kind === 'catalog' ? 'getCatalogRequests' : 'getContentRequests',
      kind === 'catalog' ? deps.dailyCatalogRequests ?? DAILY_CATALOG_REQUESTS : deps.dailyRequests ?? DAILY_CONTENT_REQUESTS,
      DAY_MS, unique.length);
  if (!withinRequests) throw exhausted(scope, 'requests');

  // 2. The ceiling over all accounts. Lessons and questions only: the catalog must stay open.
  const ceiling = kind === 'catalog' ? null
    : deps.ceiling === undefined ? (deps.allow ? null : sharedCeiling(deps.db)) : deps.ceiling;
  const coverage = await deps.db.runTransaction(tx => mockCoverage(tx, deps.db, uid, now));
  const pro = examCatalog.some(exam => coverage.coversExam(exam.id));
  // Accounts with paid access are exempt from the ceiling, so throwaway accounts cannot lock
  // paying students out. Their own limits still apply and their deliveries still count in the
  // total. The error is the same for everyone and does not say why.
  const ceilingOpen = ceiling ? await ceiling.isOpen() : true;
  if (!ceilingOpen && !pro) throw exhausted(scope, 'ceiling');
  const items: Record<string, Entry> = {};
  const candidates: Candidate[] = [];
  await Promise.all(unique.map(async (id) => {
    const snapshot = await deps.db.doc(`content/${kind}/items/${id}`).get();
    if (!snapshot.exists) { items[id] = {status: 'missing'}; return; }
    let paid = pro;
    if (kind === 'questions') {
      const set = JSON.parse(String(snapshot.get('payload'))) as {meta?: {exams?: unknown}};
      const exams = set.meta?.exams;
      paid = setCoveredByTags(exams, id => coverage.coversExam(id));
    }
    // The returned version names the tier it was built for, so a Free copy never satisfies a Pro caller.
    const version = `${String(snapshot.get('version'))}.${paid ? 'p' : 'f'}`;
    if (known[id] === version) { items[id] = {status: 'unchanged', version}; return; }
    candidates.push({id, version, paid, snapshot});
  }));

  // 3. The delivered budget. Candidates are in the order of the request, so the first ones win.
  candidates.sort((a, b) => unique.indexOf(a.id) - unique.indexOf(b.id));
  if (!ceilingOpen) {
    // Paid somewhere, but not for these sets: they stay behind the ceiling.
    const unpaid = candidates.filter(candidate => !candidate.paid);
    if (unpaid.length > 0 && unpaid.length === candidates.length) throw exhausted(scope, 'ceiling');
    for (const candidate of unpaid) {
      items[candidate.id] = {status: 'limited'};
      candidates.splice(candidates.indexOf(candidate), 1);
    }
  }
  let granted = candidates.length;
  if (granted > 0 && !deps.allow) {
    granted = await takeAtMost(uid, kind === 'catalog' ? 'getCatalog' : 'getContent',
      kind === 'catalog' ? deps.dailyCatalogIds ?? DAILY_CATALOG_IDS : deps.dailyIds ?? DAILY_CONTENT_IDS,
      DAY_MS, candidates.length);
    if (granted === 0) throw exhausted(scope, 'delivered');
  }
  await Promise.all(candidates.map(async (candidate, index) => {
    if (index >= granted) { items[candidate.id] = {status: 'limited'}; return; }
    items[candidate.id] = await build(deps.db, kind, candidate);
  }));
  if (ceiling) await ceiling.record(granted);
  return {tier: pro ? 'pro' : 'free', items};
}

async function build(db: Firestore, kind: 'lessons' | 'questions' | 'catalog', candidate: Candidate): Promise<Entry> {
  const {id, version, paid, snapshot} = candidate;
  if (kind === 'catalog') {
    // Structure only, the same for every tier. Stored as a JSON string, like question sets.
    return {status: 'ok', version, data: JSON.parse(String(snapshot.get('payload'))) as Record<string, unknown>};
  }
  if (kind === 'lessons') {
    const {title, summary, subject, topic, estimatedMinutes, body} = snapshot.data() as Record<string, unknown>;
    return {status: 'ok', version, data: {id, title, summary, subject, topic, estimatedMinutes, body}};
  }
  const set = JSON.parse(String(snapshot.get('payload'))) as {meta?: unknown; passages?: unknown[]; questions: {id: string; choices?: Record<string, unknown>[]}[]};
  if (paid) {
    const proSnapshot = await db.doc(`contentPro/${id}`).get();
    if (proSnapshot.exists) {
      const notes = JSON.parse(String(proSnapshot.get('payload'))) as Record<string, (string | null)[]>;
      for (const question of set.questions) {
        const forQuestion = notes[question.id];
        if (!forQuestion || !question.choices) continue;
        question.choices.forEach((choice, index) => {
          const note = forQuestion[index];
          if (typeof note === 'string') choice.rationale = note;
        });
      }
    }
  }
  return {status: 'ok', version, data: {id, meta: set.meta, questions: set.questions, passages: set.passages ?? []}};
}

export const getContent = onCall(
  {region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('getContent', request => serveContent(request.auth, request.data, {db: getFirestore()})));
