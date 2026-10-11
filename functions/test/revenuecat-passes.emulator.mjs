import '../lib/index.js';
import {getFirestore} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';
import {createHmac} from 'node:crypto';
import assert from 'node:assert/strict';
import test from 'node:test';
import {reconcileWebhook} from '../lib/revenuecatWebhook.js';
import {deleteAccount} from '../lib/deleteAccount.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_AUTH_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST);
const db = getFirestore();
const at = Date.parse('2026-10-10T00:00:00Z');
const catalog = [{id:'exam_cse_pro',publishedSittings:[{firstDay:'2027-03-14',lastDay:'2027-03-14',sourceUrl:'https://example.test/official'}]},
  {id:'exam_cse_sub',publishedSittings:[{firstDay:'2027-03-14',lastDay:'2027-03-15',sourceUrl:'https://example.test/official'}]}];
const purchase = (uid, transactionId) => ({transactionId,customerId:uid,
  productId:'pantas_pass_cse_pro',purchasedAt:at,appId:'app-pantas-test',
  environment:'production',store:'play_store',status:'owned'});
const ownPass = (uid,id) => db.doc(`users/${uid}/passes/${encodeURIComponent(id)}`);
const seenClaims = new Map();
const auth = {getUser:async uid=>({customClaims:seenClaims.get(uid)}),
  setCustomUserClaims:async (uid,value)=>seenClaims.set(uid,value)};
async function deliver(uid,id,rows,extra={}) {
  const event = {id,type:'NON_RENEWING_PURCHASE',app_user_id:uid,app_id:'app-pantas-test',environment:'PRODUCTION',...extra.event};
  const body = {event}; const raw = Buffer.from(JSON.stringify(body));
  const t = Math.floor((extra.at ?? at)/1000);
  const sig = createHmac('sha256','test-secret').update(t + '.').update(raw).digest('hex');
  return reconcileWebhook(body,raw,`t=${t},v1=${sig}`,{db,auth,appId:'app-pantas-test',
    firebaseProjectId:extra.project ?? 'demo-pantas-test',signingSecret:'test-secret',now:()=>extra.at ?? at,
    readCustomer:async()=>[],readPurchases:async user=>typeof rows === 'function' ? rows(user) : rows,
    catalog:extra.catalog ?? catalog});
}

test('AC-4 purchase creates its bound pass and duplicate delivery changes nothing', async () => {
  const uid = 'pass-purchase'; const p = purchase(uid,'GPA.purchase');
  assert.equal(await deliver(uid,'pass-purchase-event',[p]),200);
  const first = await ownPass(uid,p.transactionId).get();
  assert.equal(first.get('examId'),'exam_cse_pro');
  assert.equal(first.get('endsAt'),Date.parse('2027-03-14T15:59:59.999Z'));
  assert.equal(first.get('state'),'active');
  assert.equal(seenClaims.get(uid).pro,true);
  const version = (await db.doc(`users/${uid}/server/entitlement`).get()).get('version');
  assert.equal(await deliver(uid,'pass-purchase-event',[]),200);
  assert.deepEqual((await ownPass(uid,p.transactionId).get()).data(),first.data());
  assert.equal((await db.doc(`users/${uid}/server/entitlement`).get()).get('version'),version);
});

test('AC-4 metadata cannot redirect a pass and Subprofessional ends on its last exam day', async () => {
  const uid = 'pass-binding';
  const pro = {...purchase(uid,'GPA.binding-pro'),examId:'exam_let'};
  const sub = {...purchase(uid,'GPA.binding-sub'),productId:'pantas_pass_cse_sub'};
  assert.equal(await deliver(uid,'pass-binding-event',[pro,sub]),200);
  assert.equal((await ownPass(uid,pro.transactionId).get()).get('examId'),'exam_cse_pro');
  assert.equal((await ownPass(uid,sub.transactionId).get()).get('examId'),'exam_cse_sub');
  assert.equal((await ownPass(uid,sub.transactionId).get()).get('endsAt'),Date.parse('2027-03-15T15:59:59.999Z'));
});

test('AC-4 refund revokes the ledger and claims; purchase read failure returns 500', async () => {
  const uid = 'pass-refund'; const p = purchase(uid,'GPA.refund');
  await deliver(uid,'pass-refund-buy',[p]);
  await deliver(uid,'pass-refund-event',[{...p,status:'refunded'}],{at:at+1000});
  assert.equal((await ownPass(uid,p.transactionId).get()).get('state'),'revoked');
  assert.equal(seenClaims.get(uid).pro,false);
  assert.equal(await deliver(uid,'pass-refund-outage',()=>{throw Error('simulated purchase outage');},{at:at+2000}),500);
});

test('AC-4 no published future sitting grants nothing and writes an audit', async () => {
  const uid = 'pass-no-sitting'; const p = purchase(uid,'GPA.no-sitting');
  assert.equal(await deliver(uid,'pass-no-sitting-event',[p],{catalog:[]}),200);
  assert.equal((await ownPass(uid,p.transactionId).get()).exists,false);
  assert.equal(seenClaims.get(uid).pro,false);
  const logs = await db.collection('audit_logs').where('uid','==',uid).get();
  assert.ok(logs.docs.some(doc=>doc.get('event')==='passNoPublishedSitting'));
});

test('AC-4 transfer moves one ledger record and never shortens its saved end', async () => {
  const from = 'pass-transfer-old'; const to = 'pass-transfer-new';
  const p = purchase(from,'GPA.transfer');
  await deliver(from,'pass-transfer-buy',[p]);
  const oldEnd = (await ownPass(from,p.transactionId).get()).get('endsAt');
  const earlier = [{...catalog[0],publishedSittings:[{...catalog[0].publishedSittings[0],firstDay:'2027-03-01',lastDay:'2027-03-01'}]}];
  await deliver(to,'pass-transfer-event',uid=>uid===to ? [{...p,customerId:to}] : [],
    {at:at+1000,catalog:earlier,event:{type:'TRANSFER',transferred_from:[from],transferred_to:[to]}});
  assert.equal((await ownPass(from,p.transactionId).get()).exists,false);
  assert.equal((await ownPass(to,p.transactionId).get()).get('endsAt'),oldEnd);
  assert.equal(seenClaims.get(from).pro,false);
  assert.equal(seenClaims.get(to).pro,true);
});

test('AC-4 admin recompute moves a date later and keeps it when moved earlier', async () => {
  const passes = await import('../lib/revenuecatPasses.js');
  const uid = 'pass-recompute'; const p = purchase(uid,'GPA.recompute');
  await deliver(uid,'pass-recompute-buy',[p]);
  const later = [{...catalog[0],publishedSittings:[{...catalog[0].publishedSittings[0],firstDay:'2027-03-21',lastDay:'2027-03-21'}]}];
  await passes.recomputePassRecords(db,later,auth,{'exam_cse_pro:2027-03-14':'2027-03-21'});
  const end = (await ownPass(uid,p.transactionId).get()).get('endsAt');
  assert.equal(end,Date.parse('2027-03-21T15:59:59.999Z'));
  await passes.recomputePassRecords(db,catalog,auth);
  assert.equal((await ownPass(uid,p.transactionId).get()).get('endsAt'),end);
  await assert.rejects(passes.recomputePassEnds.run({data:{},auth:{uid:'ordinary',token:{}},app:{appId:'demo-app'}}), {code:'permission-denied'});
});

test('AC-4 recompute never rolls a pass into a different future sitting', async () => {
  const passes = await import('../lib/revenuecatPasses.js');
  const uid = 'pass-next-sitting'; const p = purchase(uid,'GPA.next-sitting');
  await deliver(uid,'pass-next-sitting-buy',[p]);
  const next = [{...catalog[0],publishedSittings:[{...catalog[0].publishedSittings[0],firstDay:'2027-08-08',lastDay:'2027-08-08'}]}];
  await passes.recomputePassRecords(db,next,auth);
  assert.equal((await ownPass(uid,p.transactionId).get()).get('endsAt'),Date.parse('2027-03-14T15:59:59.999Z'));
});

test('AC-4 deleting an account removes ownership; a later verified transfer keeps the original sitting', async () => {
  const uid = 'pass-deleted-owner'; const to = 'pass-restored-owner';
  await getAuth().createUser({uid});
  const p = purchase(uid,'GPA.deleted-transfer');
  await deliver(uid,'pass-deleted-buy',[p]);
  await deleteAccount.run({data:{},auth:{uid,token:{firebase:{sign_in_provider:'google.com'},auth_time:Math.floor(Date.now()/1000)}},app:{appId:'demo-app'}});
  assert.equal((await db.collection('passOwners').where('uid','==',uid).get()).empty,true);
  const next = [{...catalog[0],publishedSittings:[{...catalog[0].publishedSittings[0],firstDay:'2027-08-08',lastDay:'2027-08-08'}]}];
  await deliver(to,'pass-deleted-restore',[{...p,customerId:to}],{catalog:next,at:at+1000});
  assert.equal((await ownPass(to,p.transactionId).get()).get('endsAt'),Date.parse('2027-03-14T15:59:59.999Z'));
  assert.equal((await ownPass(to,p.transactionId).get()).get('sitting.firstDay'),'2027-03-14');
});


test('AC-2 sandbox passes count only on staging or an allowlisted production account, with a log', async () => {
  const log = console.info;
  const logs = [];
  console.info = (...args) => logs.push(args);
  try {
    for (const [uid,project,allowed,expected] of [
      ['pass-sandbox-prod','pantas-prod',false,false],
      ['pass-sandbox-stage','pantas-staging',false,true],
      ['pass-sandbox-tester','pantas-prod',true,true],
    ]) {
      if (allowed) await db.doc('config/testers').set({uids:[uid]});
      const p = {...purchase(uid,'GPA.'+uid),environment:'sandbox'};
      assert.equal(await deliver(uid,uid+'-event',[p],{project}),200);
      assert.equal(seenClaims.get(uid).pro,expected);
      assert.equal((await ownPass(uid,p.transactionId).get()).exists,expected);
    }
    assert.ok(logs.some(args=>args[0]==='RevenueCat sandbox tester reconciliation' && args[1].uid==='pass-sandbox-tester'));
  } finally {
    console.info = log;
    await db.doc('config/testers').delete();
  }
});
