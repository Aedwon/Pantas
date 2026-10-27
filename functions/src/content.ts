import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {allowAtMost} from './_limits.js';
import {mockCoverage} from './mockAccess.js';
import {examCatalog} from './revenuecatPasses.js';

/**
 * Per-account daily budget, counted in requested ids (not calls), so batching does not dodge it.
 * The whole bank is about 320 documents. A student who opens 20 items a day and refreshes each
 * once uses about 40 ids, so 300 leaves roughly seven times that, while one account needs more
 * than a day to read everything. Limits do not stop someone who makes many anonymous accounts;
 * App Check and the anonymous-account controls cover that.
 */
export const DAILY_CONTENT_IDS = 300;
export const MAX_IDS_PER_CALL = 20;
/**
 * Catalog documents hold structure only (ids, titles, links), no protected text. Every app start
 * asks for the index and its exam catalogs, so they have their own budget instead of spending the
 * student's content budget.
 */
export const DAILY_CATALOG_IDS = 200;
export const ID_PATTERN = /^[A-Za-z0-9_.-]{1,160}$/;

type Entry = {status: 'ok'; version: string; data: Record<string, unknown>}
  | {status: 'unchanged'; version: string} | {status: 'missing'};
export type ContentResponse = {tier: 'free' | 'pro'; items: Record<string, Entry>};
export type ContentDeps = {db: Firestore; now?: () => number; dailyIds?: number; dailyCatalogIds?: number;
  allow?: (uid: string, cost: number) => Promise<boolean>};
type Auth = {uid: string; token: object} | undefined;

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
  const allow = deps.allow ?? (kind === 'catalog'
    ? (uid: string, cost: number) => allowAtMost(uid, 'getCatalog', deps.dailyCatalogIds ?? DAILY_CATALOG_IDS, 86_400_000, cost)
    : (uid: string, cost: number) => allowAtMost(uid, 'getContent', deps.dailyIds ?? DAILY_CONTENT_IDS, 86_400_000, cost));
  if (!await allow(auth.uid, unique.length)) {
    throw new HttpsError('resource-exhausted', 'Daily content limit reached. Try again tomorrow.');
  }
  const coverage = await deps.db.runTransaction(tx => mockCoverage(tx, deps.db, auth.uid, now));
  const pro = examCatalog.some(exam => coverage.coversExam(exam.id));
  const items: Record<string, Entry> = {};
  await Promise.all(unique.map(async (id) => {
    const snapshot = await deps.db.doc(`content/${kind}/items/${id}`).get();
    if (!snapshot.exists) { items[id] = {status: 'missing'}; return; }
    const set = kind === 'questions'
      ? JSON.parse(String(snapshot.get('payload'))) as {meta?: {exams?: unknown}; passages?: unknown[]; questions: {id: string; choices?: Record<string, unknown>[]}[]}
      : undefined;
    const exams = set?.meta?.exams;
    const paid = kind === 'questions' ? Array.isArray(exams) && exams.some(exam =>
      typeof exam === 'string' && coverage.coversExam(`exam_${exam.replaceAll('-', '_')}`)) : pro;
    const suffix = paid ? 'p' : 'f';
    // The returned version names the tier it was built for, so a Free copy never satisfies a Pro caller.
    const version = `${String(snapshot.get('version'))}.${suffix}`;
    if (known[id] === version) { items[id] = {status: 'unchanged', version}; return; }
    if (kind === 'catalog') {
      // Structure only, the same for every tier. Stored as a JSON string, like question sets.
      items[id] = {status: 'ok', version, data: JSON.parse(String(snapshot.get('payload'))) as Record<string, unknown>};
      return;
    }
    if (kind === 'lessons') {
      const {title, summary, subject, topic, estimatedMinutes, body} = snapshot.data() as Record<string, unknown>;
      items[id] = {status: 'ok', version, data: {id, title, summary, subject, topic, estimatedMinutes, body}};
      return;
    }
    if (!set) return;
    if (paid) {
      const proSnapshot = await deps.db.doc(`contentPro/${id}`).get();
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
    items[id] = {status: 'ok', version, data: {id, meta: set.meta, questions: set.questions, passages: set.passages ?? []}};
  }));
  return {tier: pro ? 'pro' : 'free', items};
}

export const getContent = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true},
  request => serveContent(request.auth, request.data, {db: getFirestore()}));
