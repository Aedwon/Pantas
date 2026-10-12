import {readFileSync} from 'node:fs';
import {join} from 'node:path';
import {createHash} from 'node:crypto';
import {FieldPath, FieldValue, getFirestore, type Firestore, type Transaction} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {requireAdmin} from './_admin.js';
import {claimsForRevenueCatAnswer, type RevenueCatAccessSource} from './revenuecatPolicy.js';
import {copyEntitlementClaims} from './revenuecatClaims.js';
import type {RevenueCatPurchase} from './revenuecatSubscriber.js';
import type {LedgerPass} from './revenuecatCoverage.js';

export interface Sitting {firstDay: string; lastDay: string; sourceUrl: string}
export interface CatalogExam {id: string; publishedSittings: Sitting[]}
export const examCatalog = JSON.parse(readFileSync(join(__dirname, 'examCatalog.json'), 'utf8')) as CatalogExam[];
const products = JSON.parse(readFileSync(join(__dirname, 'products.json'), 'utf8')) as
  {id: string; kind: string; examId: string | null}[];
type Pass = {transactionId: string; product: string; examId: string; purchasedAt: number;
  sitting: Sitting; endsAt: number; state: 'active' | 'revoked'};
const binding = (product: string) => products.find(p => p.id === product && p.kind === 'pass')?.examId;
const pathId = (id: string) => encodeURIComponent(id);
const receiptKey = (id: string) => createHash('sha256').update(id).digest('hex');

function sittingFor(catalog: CatalogExam[], examId: string, purchasedAt: number): Sitting | undefined {
  // Published Philippines exam days are calendar dates, not device times.
  const purchaseDay = new Date(purchasedAt + 8 * 60 * 60 * 1000).toISOString().slice(0, 10);
  return catalog.find(e => e.id === examId)?.publishedSittings
    .filter(s => s.firstDay >= purchaseDay && s.sourceUrl.length > 0)
    .sort((a,b) => a.firstDay.localeCompare(b.firstDay))[0];
}
const endOfSitting = (sitting: Sitting) => Date.parse(sitting.lastDay + 'T23:59:59.999+08:00');
const livePasses = (rows: Iterable<Pass>): LedgerPass[] =>
  [...rows].filter(row => binding(row.product) === row.examId && row.state === 'active')
    .map(row => ({examId:row.examId, endsAt:row.endsAt, active:true}));

/** All reads precede apply(). The caller commits dedupe, passes and the decision together. */
export async function preparePassReconciliation(transaction: Transaction, db: Firestore,
  uid: string, purchases: RevenueCatPurchase[], catalog: CatalogExam[], answerAt: number) {
  const own = db.collection(`users/${uid}/passes`);
  const current = await transaction.get(own);
  const rows = new Map(current.docs.map(doc => [doc.id, {...doc.data(),state:'revoked'} as Pass]));
  const owners = new Map<string, {uid: string; answerAt: number; product:string;
    examId:string; sitting:Sitting; endsAt:number}>();
  const moved: string[] = [];
  const audits: string[] = [];
  for (const purchase of purchases) {
    if (purchase.productId && !products.some(product => product.id === purchase.productId)) {
      console.info('Unknown payment item', {id:purchase.productId});
    }
    const examId = purchase.productId ? binding(purchase.productId) : undefined;
    if (!examId || !purchase.productId || purchase.customerId !== uid) continue;
    if (!Number.isFinite(purchase.purchasedAt) || purchase.purchasedAt > answerAt) {
      throw new Error('Invalid pass purchase time');
    }
    const id = pathId(purchase.transactionId);
    const key = receiptKey(purchase.transactionId);
    const owner = await transaction.get(db.doc(`passOwners/${key}`));
    if (Number(owner.get('answerAt') ?? 0) > answerAt) continue;
    const previousUid: unknown = owner.get('uid');
    if (owner.exists && (owner.get('product') !== purchase.productId ||
        owner.get('examId') !== examId)) throw new Error('Receipt binding mismatch');
    let prior = current.docs.find(doc => doc.id === id)?.data() as Pass | undefined;
    if (typeof previousUid === 'string' && previousUid !== uid) {
      const previous = await transaction.get(db.doc(`users/${previousUid}/passes/${id}`));
      if (previous.exists) prior = previous.data() as Pass;
    }
    if (prior && (prior.examId !== examId || prior.product !== purchase.productId ||
        prior.purchasedAt !== purchase.purchasedAt)) throw new Error('Pass binding mismatch');
    const sitting = prior?.sitting ?? owner.get('sitting') as Sitting | undefined ??
      sittingFor(catalog, examId, purchase.purchasedAt);
    if (!sitting) {audits.push(purchase.transactionId); continue;}
    const endsAt = prior?.endsAt ?? owner.get('endsAt') as number | undefined ?? endOfSitting(sitting);
    if (!Number.isFinite(endsAt)) throw new Error('Invalid published pass end');
    rows.set(id, {transactionId:purchase.transactionId, product:purchase.productId,
      examId, purchasedAt:purchase.purchasedAt, sitting, endsAt,
      state:purchase.status === 'owned' ? 'active' : 'revoked'});
    owners.set(key, {uid,answerAt,product:purchase.productId,examId,sitting,endsAt});
    if (typeof previousUid === 'string' && previousUid !== uid) {
      moved.push(`users/${previousUid}/passes/${id}`);
    }
  }
  return {
    passes: livePasses(rows.values()),
    apply: () => {
      for (const [id,row] of rows) transaction.set(own.doc(id), row);
      for (const [id,owner] of owners) transaction.set(db.doc(`passOwners/${id}`), owner);
      for (const path of moved) transaction.delete(db.doc(path));
      for (const transactionId of audits) transaction.create(db.collection('audit_logs').doc(), {
        uid,event:'passNoPublishedSitting',timestamp:FieldValue.serverTimestamp(),metadata:{transactionId},
      });
    },
  };
}

export async function recomputePassRecords(db: Firestore, catalog: CatalogExam[],
  auth: Parameters<typeof copyEntitlementClaims>[1],
  moves: Record<string, string> = {}): Promise<number> {
  let last;
  let changed = 0;
  while (true) {
    let query = db.collectionGroup('passes').orderBy(FieldPath.documentId()).limit(500);
    if (last) query = query.startAfter(last);
    const page = await query.get();
    for (const doc of page.docs) {
      const user = doc.ref.parent.parent;
      if (user?.parent.id !== 'users') continue;
      const updated = await db.runTransaction(async transaction => {
        const [fresh, record] = await transaction.getAll(doc.ref, db.doc(`users/${user.id}/server/entitlement`));
        if (!fresh.exists || fresh.get('state') !== 'active') return false;
        const pass = fresh.data() as Pass;
        if (binding(pass.product) !== pass.examId) return false;
        // firstDay identifies the saved sitting. Changing that identifier needs
        // an explicit admin move, never an inference from the next future date.
        const target = moves[`${pass.examId}:${pass.sitting.firstDay}`] ?? pass.sitting.firstDay;
        const sitting = catalog.find(exam => exam.id === pass.examId)?.publishedSittings
          .find(candidate => candidate.firstDay === target && candidate.sourceUrl.length > 0);
        const endsAt = sitting ? endOfSitting(sitting) : pass.endsAt;
        if (!Number.isFinite(endsAt) || endsAt <= pass.endsAt) return false;
        const all = await transaction.get(user.collection('passes'));
        const rows = all.docs.map(row => row.id === fresh.id
          ? {...pass, endsAt, sitting:sitting!} : row.data() as Pass);
        const facts = record.get('facts') as {sources?: RevenueCatAccessSource[];
          coverageContext?: {appId:string; firebaseProjectId:string; sandboxTester:boolean}} | undefined;
        if (!record.exists || !facts?.coverageContext) throw new Error('Missing entitlement reconciliation context');
        const claims = claimsForRevenueCatAnswer(facts.sources ?? [], {
          ...facts.coverageContext, at:Date.now(), passes:livePasses(rows)});
        transaction.update(doc.ref, {endsAt,sitting});
        transaction.set(db.doc(`passOwners/${receiptKey(pass.transactionId)}`),
          {endsAt,sitting}, {merge:true});
        transaction.update(record.ref, {...claims,claimsPending:true,updatedAt:FieldValue.serverTimestamp(),version:Number(record.get('version'))+1});
        transaction.create(db.collection('audit_logs').doc(), {
          uid:user.id,event:'passEndMoved',timestamp:FieldValue.serverTimestamp(),
          metadata:{transactionId:pass.transactionId,from:pass.endsAt,to:endsAt},
        });
        return true;
      });
      if (updated) {
        changed++;
        await copyEntitlementClaims(db,auth,user.id);
      }
    }
    if (page.size < 500) return changed;
    last = page.docs.at(-1);
  }
}

export async function clearPassOwnership(db: Firestore, uid: string): Promise<void> {
  const rows = await db.collection('passOwners').where('uid','==',uid).get();
  // Keep only a hashed receipt reference and its public exam-date bounds.
  // Erase the account link while preventing a restored receipt from rolling
  // into another sitting after its user ledger was deleted.
  for (let offset = 0; offset < rows.size; offset += 500) {
    const batch = db.batch();
    for (const row of rows.docs.slice(offset,offset+500)) {
      batch.update(row.ref, {uid:FieldValue.delete(),answerAt:FieldValue.delete()});
    }
    await batch.commit();
  }
}

export const recomputePassEnds = onCall({region:'asia-southeast1',enforceAppCheck:true,consumeAppCheckToken:true},
  async request => {
    await requireAdmin(request);
    const input: unknown = request.data?.moves ?? {};
    if (!input || typeof input !== 'object' || Array.isArray(input)) {
      throw new HttpsError('invalid-argument','Sitting moves must be a date mapping.');
    }
    const moves: Record<string,string> = {};
    for (const [key,value] of Object.entries(input)) {
      if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value) ||
          !/^exam_[a-z_]+:\d{4}-\d{2}-\d{2}$/.test(key)) {
        throw new HttpsError('invalid-argument','Invalid sitting move.');
      }
      moves[key] = value;
    }
    return {updated:await recomputePassRecords(getFirestore(),examCatalog,getAuth(),moves)};
  });
