import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import * as r from '../lib/mockReader.js';
assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db=getFirestore(), NOW=Date.UTC(2026,10,20), DAY=86400000, ID='MockResult000001', EXAM='exam_cse_pro';
const auth=uid=>({uid,token:{firebase:{sign_in_provider:'google.com'}}});
const deps=(at=NOW)=>({db,now:()=>at,allow:async()=>true});
const code=async p=>{try{await p;return 'ok';}catch(e){return e.code;}};
const ref=(uid,id=ID)=>db.doc(`users/${uid}/server/mocks/items/${id}`);
const paper={expectedQuestionCount:4,sections:[{sectionId:'one',name:'First',questions:[{id:'a',setId:'set'},{id:'b',setId:'set'}]},{sectionId:'two',name:'Second',questions:[{id:'c',setId:'set'},{id:'d',setId:'set'}]}]};
const row={examId:EXAM,status:'submitted',startedAt:NOW-1000,submittedAt:NOW,endedBy:'student',strict:false,limitMs:3600000,durationMs:1000,paper,answers:[{questionId:'a',chosen:'a',correct:true,answeredAt:NOW},{questionId:'b',chosen:'b',correct:false,answeredAt:NOW},{questionId:'c',chosen:null,correct:false,answeredAt:NOW}],reviewNotes:{a:{missReason:'misread',reasonNote:'private note'}}};
async function seed(uid,value=row){await db.recursiveDelete(db.doc(`users/${uid}`));await ref(uid).set(value);}
async function grant(uid,product='pantas_cs_monthly',endsAt=NOW+DAY){await db.doc(`users/${uid}/grants/grant`).set({source:'paymongo',product,tier:'civilService',startsAt:NOW-DAY,endsAt,state:'active',createdAt:NOW-DAY});}
test('named auth and original account required',async()=>{
 await seed('mr-owner');
 assert.equal(await code(r.serveMockResults(undefined,{mockId:ID},deps())),'unauthenticated');
 assert.equal(await code(r.serveMockResults({uid:'mr-owner',token:{firebase:{sign_in_provider:'anonymous'}}},{mockId:ID},deps())),'permission-denied');
 assert.equal(await code(r.serveMockResults(auth('mr-other'),{mockId:ID},deps())),'not-found');
 assert.equal(await code(r.serveMockResults(auth('mr-owner'),{mockId:'../bad'},deps())),'invalid-argument');
});
test('Free real ordered counts, open selections, no notes; exact expiry removes review payload',async()=>{
 await seed('mr-free');
 const out=await r.serveMockResults(auth('mr-free'),{mockId:ID},deps());
 assert.deepEqual(out.score,{correct:1,answered:2,wrong:1,blank:2,total:4});
 assert.deepEqual(out.sections.map(s=>[s.sectionId,s.correct,s.wrong,s.blank,s.total]),[['one',1,1,0,2],['two',0,0,2,2]]);
 assert.equal(out.canReview,true);assert.equal(out.reviewUntil,NOW+30*DAY);assert.equal(out.proCovered,false);
 assert.deepEqual(out.paper,paper);assert.deepEqual(out.answers,row.answers);assert.equal('notes' in out,false);
 assert.equal((await r.serveMockResults(auth('mr-free'),{mockId:ID},deps(NOW+30*DAY-1))).canReview,true);
 const caller={...auth('mr-free'),token:{...auth('mr-free').token,pro:true,proUntil:NOW+100*DAY}};
 const closed=await r.serveMockResults(caller,{mockId:ID},deps(NOW+30*DAY));
 assert.equal(closed.canReview,false);for(const k of ['paper','answers','notes'])assert.equal(k in closed,false);
 assert.equal(closed.score.total,4);
});
test('covered Pro notes; expiry and other-exam pass cannot grant them',async()=>{
 await seed('mr-tier');await grant('mr-tier');
 let out=await r.serveMockResults(auth('mr-tier'),{mockId:ID},deps());assert.equal(out.proCovered,true);assert.deepEqual(out.notes,row.reviewNotes);
 assert.equal('notes' in await r.serveMockResults(auth('mr-tier'),{mockId:ID},deps(NOW+DAY)),false);
 await grant('mr-tier','pantas_pass_cse_sub');assert.equal((await r.serveMockResults(auth('mr-tier'),{mockId:ID},deps())).proCovered,false);
 await grant('mr-tier','pantas_pass_cse_pro');assert.equal((await r.serveMockResults(auth('mr-tier'),{mockId:ID},deps())).proCovered,true);
});
test('availability global cooldown, exact boundary, cross-exam open and strict expiry',async()=>{
 await seed('mr-available');await db.doc(`content/mocks/items/${EXAM}`).set({sectionsJson:'[]',durationMinutes:60});await db.doc('content/mocks/items/exam_cse_sub').set({sectionsJson:'[]',durationMinutes:60});
 let out=await r.serveMockAvailability(auth('mr-available'),{examId:'exam_cse_sub'},deps());assert.equal(out.status,'cooldown');assert.equal(out.nextEligibleAt,NOW+30*DAY);assert.equal(out.lastMockId,null);
 assert.equal((await r.serveMockAvailability(auth('mr-available'),{examId:EXAM},deps(NOW+30*DAY))).status,'available');
 await ref('mr-available','MockOpen0000001').set({...row,status:'started',submittedAt:null,examId:'exam_cse_sub',pausedMs:0,pausedAt:null});
 out=await r.serveMockAvailability(auth('mr-available'),{examId:EXAM},deps());assert.equal(out.status,'in-progress');assert.equal(out.open.examId,'exam_cse_sub');
 await seed('mr-timeout',{...row,status:'started',submittedAt:null,strict:true,startedAt:NOW-10000,limitMs:1000});
 out=await r.serveMockAvailability(auth('mr-timeout'),{examId:EXAM},deps());assert.equal(out.status,'cooldown');assert.equal(out.nextEligibleAt,NOW-9000+30*DAY);assert.equal((await ref('mr-timeout').get()).get('endedBy'),'time-out');
});
test('bounded history pagination preserves ties without review data',async()=>{
 await seed('mr-history');await ref('mr-history','MockResult000002').set(row);await ref('mr-history','MockResult000003').set({...row,submittedAt:NOW-1});
 const a=await r.serveMockHistory(auth('mr-history'),{limit:1},deps());const b=await r.serveMockHistory(auth('mr-history'),{limit:1,before:a.next},deps());const c=await r.serveMockHistory(auth('mr-history'),{limit:1,before:b.next},deps());
 assert.equal(new Set([...a.items,...b.items,...c.items].map(x=>x.mockId)).size,3);assert.equal(c.next,null);
 for(const e of [...a.items,...b.items,...c.items])for(const k of ['paper','answers','notes'])assert.equal(k in e,false);
 assert.equal(await code(r.serveMockHistory(auth('mr-history'),{limit:101},deps())),'invalid-argument');
});
test('notes require covered Pro and paper membership, validate fields and replace cleared reasons',async()=>{
 await seed('mr-notes');const body={mockId:ID,questionId:'a',missReason:'slipped',reasonNote:'check signs'};
 assert.equal(await code(r.writeMockReview(auth('mr-notes'),body,deps())),'permission-denied');await grant('mr-notes');
 assert.equal(await code(r.writeMockReview(auth('mr-notes'),{...body,questionId:'foreign'},deps())),'invalid-argument');
 assert.equal(await code(r.writeMockReview(auth('mr-notes'),{...body,reasonNote:'x'.repeat(4001)},deps())),'invalid-argument');
 await r.writeMockReview(auth('mr-notes'),body,deps());assert.deepEqual((await r.serveMockResults(auth('mr-notes'),{mockId:ID},deps())).notes.a,{missReason:'slipped',blankReason:null,reasonNote:'check signs'});
 await r.writeMockReview(auth('mr-notes'),{mockId:ID,questionId:'a'},deps());assert.deepEqual((await r.serveMockResults(auth('mr-notes'),{mockId:ID},deps())).notes.a,{missReason:null,blankReason:null,reasonNote:null});
});
test('invalid stored answer identities fail closed; rate limited',async()=>{
 await seed('mr-invalid',{...row,answers:[...row.answers,row.answers[0]]});assert.equal(await code(r.serveMockResults(auth('mr-invalid'),{mockId:ID},deps())),'failed-precondition');
 assert.equal(await code(r.serveMockResults(auth('mr-invalid'),{mockId:ID},{...deps(),allow:async()=>false})),'resource-exhausted');
});
test('empty availability/history, absent blueprint, paid unlimited and revoked grant',async()=>{
 const uid='mr-empty';await db.recursiveDelete(db.doc(`users/${uid}`));
 assert.deepEqual(await r.serveMockHistory(auth(uid),{},deps()),{items:[],next:null});
 assert.equal((await r.serveMockAvailability(auth(uid),{examId:EXAM},deps())).status,'available');
 assert.equal((await r.serveMockAvailability(auth(uid),{examId:'exam_upcat'},deps())).status,'no-blueprint');
 await seed(uid);await grant(uid);
 let out=await r.serveMockAvailability(auth(uid),{examId:EXAM},deps());assert.equal(out.status,'available');assert.equal(out.nextEligibleAt,null);
 await db.doc(`users/${uid}/grants/grant`).update({state:'revoked'});
 out=await r.serveMockAvailability(auth(uid),{examId:EXAM},deps());assert.equal(out.status,'cooldown');
 for(const [fn,data] of [[r.serveMockAvailability,{examId:EXAM}],[r.serveMockHistory,{}],[r.writeMockReview,{mockId:ID,questionId:'a'}]])assert.equal(await code(fn(auth(uid),data,{...deps(),allow:async()=>false})),'resource-exhausted');
});
test('malformed stored paper fails as recoverable results error',async()=>{
 await seed('mr-broken',{...row,paper:{sections:[{sectionId:'one',name:'First'}]}});
 assert.equal(await code(r.serveMockResults(auth('mr-broken'),{mockId:ID},deps())),'failed-precondition');
});
test('start uses the same current exam coverage as availability, without token-refresh dependence',async()=>{
 const {beginMock}=await import('../lib/mock.js');const {writeContent,questionSetItems,blueprintItem}=await import('../lib/contentUpload.js');
 const {clearExamContentCache}=await import('../lib/_examContent.js');
 await writeContent(db,[questionSetItems({meta:{subject:'s',topic:'ta',exams:['cse-pro']},questions:[{id:'ra',stem:'x',choices:[{text:'a',correct:true},{text:'b'}]}]},'mr/ta/u.yaml').item,blueprintItem({exam:EXAM,name:'Paper',durationMinutes:60,sectionalTiming:'none',sections:[{id:'s1',name:'First',questionCount:1,suggestedMinutes:60,topicIds:['topic_cse_pro_ta'],topicWeights:{topic_cse_pro_ta:1}}]})],[],{});clearExamContentCache();
 await seed('mr-start');await grant('mr-start','pantas_pass_cse_sub');
 const caller={...auth('mr-start'),token:{...auth('mr-start').token,pro:true,proUntil:NOW+DAY}};
 assert.equal(await code(beginMock(caller,{examId:EXAM},deps())),'failed-precondition');
 await grant('mr-start');assert.equal(await code(beginMock(auth('mr-start'),{examId:EXAM},deps())),'ok');
});

test('missing blueprint takes precedence over recent-submission cooldown',async()=>{
 await seed('mr-no-blueprint');
 const out=await r.serveMockAvailability(auth('mr-no-blueprint'),{examId:'exam_upcat'},deps());
 assert.equal(out.status,'no-blueprint');
});

test('setup preview count is assembled on the server without starting a clock', async () => {
  const uid = 'mr-preview';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  const out = await r.serveMockAvailability(auth(uid), {examId: EXAM, includeSetup: true}, deps());
  assert.equal(out.setup.questionCount, 1);
  assert.equal(out.setup.expectedQuestionCount, 1);
  assert.equal((await db.collection(`users/${uid}/server/mocks/items`).get()).size, 0);
});

test('result time metadata uses server time and schedules a Pro ledger transition', async () => {
  await seed('mr-clock'); await grant('mr-clock', 'pantas_cs_monthly', NOW + 1000);
  const out = await r.serveMockResults(auth('mr-clock'), {mockId: ID}, deps());
  assert.equal(out.serverNow, NOW);
  assert.equal(out.accessRecheckAt, NOW + 1000);
});
