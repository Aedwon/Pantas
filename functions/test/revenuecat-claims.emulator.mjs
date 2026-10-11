import '../lib/index.js';
import {getFirestore,Timestamp} from 'firebase-admin/firestore';
import assert from 'node:assert/strict';
import test from 'node:test';
import * as claims from '../lib/revenuecatClaims.js';
assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
const db = getFirestore();
const at = Date.now();
const facts = {appId:'app-pantas-test', environment:'production', productIds:['pantas_pro_monthly'], entitlementIds:['pro'], expiry:at + 86400000};
const result = {pro:true, proUntil:at + 172800000};
function helper(name) {
  assert.equal(typeof claims[name], 'function', `${name} must implement the approved contract`);
  return claims[name];
}
function auth(uid, callback) {
  let current = {otherClaim: 'kept'};
  return {
    getUser: async () => ({customClaims:current}),
    setCustomUserClaims: async (_, value) => { await callback?.(value); current = value; },
    current: () => current,
  };
}
test('AC-3 claims are copied only after the authoritative record commits', async () => {
  const uid = 'w3-commit-test';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  const a = auth(uid, async () => assert.equal((await db.doc(`users/${uid}/server/entitlement`).get()).get('version'), 1));
  await helper('commitRevenueCatAnswer')(db, uid, 'event-1', at, result, facts);
  await helper('copyEntitlementClaims')(db, a, uid);
  const record = (await db.doc(`users/${uid}/server/entitlement`).get()).data();
  assert.equal(record.claimsVersion, record.version);
  assert.equal(a.current().pro, true);
  assert.equal(a.current().otherClaim, 'kept');
});
test('AC-3 a failed copy leaves a mismatch; deduped retry still repairs it', async () => {
  const uid = 'w3-failure-test';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await helper('commitRevenueCatAnswer')(db, uid, 'event-1', at, result, facts);
  await assert.rejects(helper('copyEntitlementClaims')(db, auth(uid, () => {throw Error('simulated Auth outage');}), uid));
  assert.equal(await helper('commitRevenueCatAnswer')(db, uid, 'event-1', at, result, facts), false);
  const a = auth(uid);
  await helper('copyEntitlementClaims')(db, a, uid);
  assert.equal(a.current().proUntil, result.proUntil);
  assert.ok((await db.doc(`users/${uid}`).get()).get('claimsChangedAt'));
});
test('AC-3 concurrent copies end with the newest record; older answers and replay are ignored', async () => {
  const uid = 'w3-concurrent-test';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  let release, entered;
  const held = new Promise(r => release = r);
  const began = new Promise(r => entered = r);
  let calls = 0;
  const a = auth(uid, async () => { if (++calls === 1) { entered(); await held; } });
  await helper('commitRevenueCatAnswer')(db, uid, 'old', at, result, facts);
  const oldCopy = helper('copyEntitlementClaims')(db, a, uid);
  await began;
  await helper('commitRevenueCatAnswer')(db, uid, 'new', at + 1000, {pro:false,proUntil:0}, facts);
  await assert.rejects(helper('copyEntitlementClaims')(db, a, uid), /lease/i);
  release();
  await oldCopy;
  assert.equal(a.current().pro, false);
  assert.equal(await helper('commitRevenueCatAnswer')(db, uid, 'late', at - 1000, result, facts), false);
  assert.equal((await db.doc(`users/${uid}/server/entitlement`).get()).get('version'), 2);
});
test('AC-3 hourly repair finds and copies a mismatch', async () => {
  const uid = 'w3-repair-test';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await helper('commitRevenueCatAnswer')(db, uid, 'repair', at, result, facts);
  const a = auth(uid);
  await helper('repairClaims')(db, a);
  assert.equal((await db.doc(`users/${uid}/server/entitlement`).get()).get('claimsVersion'), 1);
  assert.equal(a.current().pro, true);
  assert.equal(a.current().proUntil, result.proUntil);
});
import {reconcileWebhook} from '../lib/revenuecatWebhook.js';
import {createHmac} from 'node:crypto';
function request(event, dependencies) {
  const body = {event:{app_id:'app-pantas-test', environment:'PRODUCTION',...event}};
  const raw = Buffer.from(JSON.stringify(body));
  const t = Math.floor(Date.now()/1000);
  const hash = createHmac('sha256','test-secret').update(`${t}.`).update(raw).digest('hex');
  return reconcileWebhook(body,raw,`t=${t},v1=${hash}`,dependencies);
}
test('AC-3 every event reconciles; outage returns 500 and duplicate retries repair a failed copy', async () => {
  const uid = 'w3-webhook-test';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  let failed = true, reads = 0;
  const a = auth(uid, () => {if(failed) throw Error('simulated outage');});
  const deps = {db,auth:a,appId:'app-pantas-test',firebaseProjectId:'pantas-prod',signingSecret:'test-secret',
    readCustomer:async()=>{reads++;return [{productId:'pantas_pro_monthly',appId:'app-pantas-test',entitlementIds:['pro'],environment:'production',endsAt:Date.now()+86400000,active:true}];}};
  const event = {id:'retry-event',type:'CANCELLATION',app_user_id:uid};
  assert.equal(await request(event,deps),500);
  failed = false;
  assert.equal(await request(event,deps),200);
  assert.equal(reads,1);
  assert.equal(a.current().pro,true);
  for (const type of ['RENEWAL','PRODUCT_CHANGE','UNCANCELLATION','BILLING_ISSUE','EXPIRATION','REFUND_REVERSED','UNKNOWN_FUTURE_EVENT']) {
    assert.equal(await request({...event,id:type,type},deps),200);
  }
  assert.equal(reads,8);
  assert.equal(await request({...event,id:'outage'}, {...deps,readCustomer:async()=>{throw Error('RC down');}}),500);
});
test('AC-11 TRANSFER reconciles both accounts so one account holds the purchase', async () => {
  const from = 'w3-transfer-a', to = 'w3-transfer-b';
  await db.recursiveDelete(db.doc(`users/${from}`));
  await db.recursiveDelete(db.doc(`users/${to}`));
  const current = new Map([[from,{pro:true}], [to,{pro:false}]]);
  const deps = {db,appId:'app-pantas-test',firebaseProjectId:'pantas-prod',signingSecret:'test-secret',
    auth:{getUser:async uid=>({customClaims:current.get(uid)}),setCustomUserClaims:async(uid,value)=>{current.set(uid,value);}},
    readCustomer:async uid=>uid === from ? [] : [{productId:'pantas_pro_monthly',appId:'app-pantas-test',entitlementIds:['pro'],environment:'production',endsAt:Date.now()+86400000,active:true}]};
  assert.equal(await request({id:'transfer',type:'TRANSFER',transferred_from:[from],transferred_to:[to]},deps),200);
  assert.equal(current.get(from).pro,false);
  assert.equal(current.get(to).pro,true);
});


test('AC-3 a terminated copier leaves durable pending work and an expired lease recovers the newest Auth values', async () => {
  const uid = 'w3-copy-terminated';
  const record = db.doc(`users/${uid}/server/entitlement`);
  await db.recursiveDelete(db.doc(`users/${uid}`));
  let now = at;
  let stored = {otherClaim:'kept'};
  let wrote;
  const written = new Promise(resolve=>wrote=resolve);
  let calls = 0;
  const a = {
    getUser:async()=>({customClaims:stored}),
    setCustomUserClaims:async(_,value)=>{
      stored = value;
      if (++calls === 1) {wrote(); await new Promise(()=>{});}
    },
  };
  await helper('commitRevenueCatAnswer')(db,uid,'crash-old',at,result,facts);
  // A never-returning Auth response models process termination immediately
  // after the external write, without allowing corrective/finally code to run.
  void helper('copyEntitlementClaims')(db,a,uid,()=>now);
  await written;
  await helper('commitRevenueCatAnswer')(db,uid,'crash-new',at+1000,{pro:false,proUntil:0},facts);
  assert.equal((await record.get()).get('claimsPending'),true);
  await assert.rejects(helper('copyEntitlementClaims')(db,a,uid,()=>now),/lease/i);
  now += 60001;
  await helper('copyEntitlementClaims')(db,a,uid,()=>now);
  const latest = (await record.get()).data();
  assert.equal(stored.pro,latest.pro);
  assert.equal(stored.proUntil,latest.proUntil);
  assert.equal(stored.pro,false);
  assert.equal(stored.otherClaim,'kept');
  assert.equal(latest.claimsPending,false);
  assert.equal(latest.claimsVersion,latest.version);
  assert.equal(latest.claimsLeaseHolder,undefined);
});


test('finding 3 daily consistency repairs actual Auth mismatches even when marked synchronized, within 48 hours only', async()=>{
  const recent = 'w3-daily-recent', old = 'w3-daily-old';
  const now = Date.now();
  for(const [uid,hours] of [[recent,1],[old,49]]) {
    await db.doc(`users/${uid}/server/entitlement`).set({
      ...result,version:1,claimsVersion:1,claimsPending:false,
      updatedAt:Timestamp.fromMillis(now-hours*3600000),
    });
  }
  const values = new Map([[recent,{pro:false,proUntil:0}],[old,{pro:false,proUntil:0}]]);
  const reads = [];
  const a = {getUser:async uid=>{reads.push(uid);if(!values.has(uid)) throw Error('unrelated fixture');return {customClaims:values.get(uid)};},
    setCustomUserClaims:async(uid,value)=>values.set(uid,value)};
  await helper('checkRecentClaims')(db,a,()=>now);
  assert.equal(values.get(recent).pro,true);
  assert.equal(values.get(recent).proUntil,result.proUntil);
  assert.equal((await db.doc(`users/${recent}/server/entitlement`).get()).get('claimsPending'),false);
  assert.equal(values.get(old).pro,false);
  assert.equal(reads.includes(old),false);
});
