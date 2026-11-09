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

// ---- listed regression: the exact keys of availability and results for a listed exam ----
const keysOf = value => Object.keys(value).sort();
test('listed exam: availability and results keep their exact keys, with no examName', async () => {
  const uid = 'mr-keys';
  await seed(uid);
  await db.doc(`content/mocks/items/${EXAM}`).set({sectionsJson: '[]', durationMinutes: 60});
  const cooling = await r.serveMockAvailability(auth(uid), {examId: EXAM}, deps());
  assert.deepEqual(keysOf(cooling), ['accessRecheckAt', 'examId', 'lastMockId', 'nextEligibleAt', 'proCovered', 'serverNow', 'status']);
  await ref(uid, 'MockOpen0000001').set({...row, status: 'started', submittedAt: null, pausedMs: 0, pausedAt: null});
  assert.deepEqual(keysOf(await r.serveMockAvailability(auth(uid), {examId: EXAM}, deps())),
    ['accessRecheckAt', 'examId', 'lastMockId', 'nextEligibleAt', 'open', 'proCovered', 'serverNow', 'status']);
  await ref(uid, 'MockOpen0000001').delete();
  const results = await r.serveMockResults(auth(uid), {mockId: ID}, deps());
  assert.deepEqual(keysOf(results), ['accessRecheckAt', 'answers', 'canReview', 'durationMs', 'endedBy', 'examId', 'limitMs', 'mockId', 'paper',
    'proCovered', 'reviewUntil', 'score', 'sections', 'serverNow', 'startedAt', 'strict', 'submittedAt']);
});

// ---- custom exams ----
const CUSTOM = 'exam_custom_6f1c2d3e-4a5b-4c6d-8e7f-0a1b2c3d4e5f';
const OTHER_CUSTOM = 'exam_custom_0a1b2c3d-4e5f-4a6b-9c7d-8e9f0a1b2c3d';
const trackRef = (uid, id = CUSTOM) => db.doc(`users/${uid}/server/customTracks/items/${id}`);
const sectionsOf = (count, topicIds = ['topic_mr_algebra']) => [{id: 'section_all', name: 'Everything', questionCount: count, suggestedMinutes: 30, topicIds}];
async function track(uid, id = CUSTOM, {count = 12, name = 'PUP CET', blueprint = true} = {}) {
  await trackRef(uid, id).set({examId: id, name, excludedTopicIds: [], excludedLessonIds: [], createdAt: NOW, updatedAt: NOW,
    blueprint: blueprint ? {sectionsJson: JSON.stringify(sectionsOf(count)), totalQuestions: count, totalMinutes: 30, sectionsTimedSeparately: false, updatedAt: NOW} : null});
}
const customRow = (over = {}) => ({...row, examId: CUSTOM, examName: 'PUP CET', ...over});
const cseGrant = uid => grant(uid);

test('seed a custom corpus of 30 questions', async () => {
  const set = {id: 'set-mr-algebra', topic: 'topic_mr_algebra', lesson: null, exams: ['exam_mr_a'], language: 'en', questions: Array.from({length: 30}, (_, i) => ({id: `mra-${i}`}))};
  const catalog = {
    index: {subjects: [{_id: 'subj_mr_math', name: 'Mathematics', exam: 'exam_mr_a', ordering: 1}],
      topics: [{_id: 'topic_mr_algebra', name: 'Algebra', subject: 'subj_mr_math', ordering: 1}], catalogs: ['exam_mr_a']},
    exam_mr_a: {id: 'exam_mr_a', sets: [set]},
  };
  for (const [id, value] of Object.entries(catalog)) await db.doc(`content/catalog/items/${id}`).set({version: `mr-${id}`, payload: JSON.stringify(value)});
  (await import('../lib/_examContent.js')).clearExamContentCache();
});

test('custom availability reads the track: no track and no blueprint are no-blueprint, a plan is available', async () => {
  const uid = 'mr-c-states';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  let out = await r.serveMockAvailability(auth(uid), {examId: CUSTOM}, deps());
  assert.equal(out.status, 'no-blueprint');
  assert.equal(out.proCovered, false);
  await track(uid, CUSTOM, {blueprint: false});
  assert.equal((await r.serveMockAvailability(auth(uid), {examId: CUSTOM}, deps())).status, 'no-blueprint');
  await track(uid);
  out = await r.serveMockAvailability(auth(uid), {examId: CUSTOM}, deps());
  assert.equal(out.status, 'available');
  assert.equal(out.nextEligibleAt, null);
  assert.equal(out.lastMockId, null);
  assert.deepEqual(keysOf(out), ['accessRecheckAt', 'examId', 'lastMockId', 'nextEligibleAt', 'proCovered', 'serverNow', 'status']);
  // A listed blueprint does not make a custom id available, and a malformed custom id is not an exam.
  await db.doc(`content/mocks/items/${CUSTOM}`).set({sectionsJson: '[]', durationMinutes: 60});
  assert.equal((await r.serveMockAvailability(auth('mr-c-states-2'), {examId: CUSTOM}, deps())).status, 'no-blueprint');
  assert.equal(await code(r.serveMockAvailability(auth(uid), {examId: 'exam_custom_nope'}, deps())), 'invalid-argument');
  await db.doc(`content/mocks/items/${CUSTOM}`).delete();
});

test('custom availability: the window counts every exam, a paid CSE grant does not open it, tracks do not reset it', async () => {
  const uid = 'mr-c-cooldown';
  await seed(uid);                       // a listed CSE mock submitted at NOW
  await track(uid); await track(uid, OTHER_CUSTOM, {name: 'Second'});
  for (const id of [CUSTOM, OTHER_CUSTOM]) {
    const out = await r.serveMockAvailability(auth(uid), {examId: id}, deps());
    assert.equal(out.status, 'cooldown');
    assert.equal(out.nextEligibleAt, NOW + 30 * DAY);
    assert.equal(out.lastMockId, null);
  }
  await cseGrant(uid);
  assert.equal((await r.serveMockAvailability(auth(uid), {examId: EXAM}, deps())).status, 'available');
  const custom = await r.serveMockAvailability(auth(uid), {examId: CUSTOM}, deps());
  assert.equal(custom.status, 'cooldown');
  assert.equal(custom.proCovered, false);
  assert.equal((await r.serveMockAvailability(auth(uid), {examId: CUSTOM}, deps(NOW + 30 * DAY))).status, 'available');
  // A custom mock also blocks a CSE start and the other custom track, and lastMockId is per exam.
  const own = 'mr-c-own';
  await db.recursiveDelete(db.doc(`users/${own}`));
  await track(own); await track(own, OTHER_CUSTOM, {name: 'Second'});
  await ref(own, 'CustomMock00001').set(customRow({submittedAt: NOW - 3 * DAY}));
  assert.equal((await r.serveMockAvailability(auth(own), {examId: OTHER_CUSTOM}, deps())).status, 'cooldown');
  assert.equal((await r.serveMockAvailability(auth(own), {examId: OTHER_CUSTOM}, deps())).lastMockId, null);
  const same = await r.serveMockAvailability(auth(own), {examId: CUSTOM}, deps());
  assert.equal(same.status, 'cooldown');
  assert.equal(same.lastMockId, 'CustomMock00001');
  assert.equal(same.nextEligibleAt, NOW - 3 * DAY + 30 * DAY);
  assert.equal((await r.serveMockAvailability(auth(own), {examId: EXAM}, deps())).status, 'cooldown');
});

test('custom availability: an open mock of any exam is in-progress, and a strict time-out ends it first', async () => {
  const uid = 'mr-c-open';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await track(uid);
  await ref(uid, 'MockOpen0000002').set({...row, status: 'started', submittedAt: null, examId: EXAM, pausedMs: 0, pausedAt: null});
  const out = await r.serveMockAvailability(auth(uid), {examId: CUSTOM}, deps());
  assert.equal(out.status, 'in-progress');
  assert.equal(out.open.examId, EXAM);
  await ref(uid, 'MockOpen0000002').set({...customRow({status: 'started', submittedAt: null, strict: true, startedAt: NOW - 10000, limitMs: 1000, pausedMs: 0, pausedAt: null})});
  const ended = await r.serveMockAvailability(auth(uid), {examId: CUSTOM}, deps());
  assert.equal(ended.status, 'cooldown');
  assert.equal(ended.lastMockId, 'MockOpen0000002');
});

test('the setup preview of a custom plan is assembled on the server, starts no clock, and fails when short', async () => {
  const uid = 'mr-c-preview';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await track(uid, CUSTOM, {count: 12});
  const out = await r.serveMockAvailability(auth(uid), {examId: CUSTOM, includeSetup: true}, deps());
  assert.deepEqual(out.setup, {expectedQuestionCount: 12, questionCount: 12});
  assert.equal((await db.collection(`users/${uid}/server/mocks/items`).get()).size, 0);
  await track(uid, OTHER_CUSTOM, {count: 31});
  await assert.rejects(r.serveMockAvailability(auth(uid), {examId: OTHER_CUSTOM, includeSetup: true}, deps()),
    e => e.code === 'failed-precondition' && e.message === 'There are not enough questions for this mock yet.');
  // Without the flag the same plan is simply available, and in cooldown there is no preview.
  assert.equal((await r.serveMockAvailability(auth(uid), {examId: OTHER_CUSTOM}, deps())).status, 'available');
  await ref(uid, 'CustomMock00002').set(customRow({submittedAt: NOW}));
  assert.equal('setup' in await r.serveMockAvailability(auth(uid), {examId: CUSTOM, includeSetup: true}, deps()), false);
});

test('results and history read a custom paper with its name; a listed row and a bad name carry none', async () => {
  const uid = 'mr-c-results';
  await seed(uid);
  await ref(uid, 'CustomMock00003').set(customRow({submittedAt: NOW - DAY}));
  await ref(uid, 'CustomMock00004').set(customRow({submittedAt: NOW - 2 * DAY, examName: 42}));
  const {examName: _gone, ...unnamed} = customRow({submittedAt: NOW - 3 * DAY});
  await ref(uid, 'CustomMock00005').set(unnamed);
  const res = await r.serveMockResults(auth(uid), {mockId: 'CustomMock00003'}, deps());
  assert.equal(res.examName, 'PUP CET');
  assert.equal(res.examId, CUSTOM);
  assert.deepEqual(res.score, {correct: 1, answered: 2, wrong: 1, blank: 2, total: 4});
  assert.equal(res.canReview, true);
  assert.equal(res.proCovered, false);
  assert.equal('examName' in await r.serveMockResults(auth(uid), {mockId: 'CustomMock00004'}, deps()), false);
  assert.equal('examName' in await r.serveMockResults(auth(uid), {mockId: 'CustomMock00005'}, deps()), false);
  assert.equal('examName' in await r.serveMockResults(auth(uid), {mockId: ID}, deps()), false);
  const history = await r.serveMockHistory(auth(uid), {}, deps());
  assert.deepEqual(history.items.map(i => [i.mockId, i.examName]), [[ID, undefined], ['CustomMock00003', 'PUP CET'], ['CustomMock00004', undefined], ['CustomMock00005', undefined]]);
  assert.equal('examName' in history.items[0], false);
});

test('a Free custom result is reviewable for 30 days and then loses its paper; the name stays', async () => {
  const uid = 'mr-c-window';
  await seed(uid);
  await ref(uid, 'CustomMock00006').set(customRow({submittedAt: NOW}));
  assert.equal((await r.serveMockResults(auth(uid), {mockId: 'CustomMock00006'}, deps(NOW + 30 * DAY - 1))).canReview, true);
  const closed = await r.serveMockResults(auth(uid), {mockId: 'CustomMock00006'}, deps(NOW + 30 * DAY));
  assert.equal(closed.canReview, false);
  assert.equal(closed.examName, 'PUP CET');
  for (const k of ['paper', 'answers', 'notes']) assert.equal(k in closed, false);
});

test('another account cannot read a custom result by id', async () => {
  await seed('mr-c-a');
  await ref('mr-c-a', 'CustomMock00007').set(customRow({submittedAt: NOW}));
  assert.equal(await code(r.serveMockResults(auth('mr-c-b'), {mockId: 'CustomMock00007'}, deps())), 'not-found');
  assert.deepEqual((await r.serveMockHistory(auth('mr-c-b'), {}, deps())).items, []);
});
