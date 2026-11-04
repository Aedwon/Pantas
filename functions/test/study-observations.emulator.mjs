import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {recordSession} from '../lib/ingestSession.js';
import {lessonItem, questionSetItems, writeContent} from '../lib/contentUpload.js';
import {clearExamContentCache} from '../lib/_examContent.js';
import {readStudyInsights} from '../lib/studyInsights.js';
import {randomUUID} from 'node:crypto';
const db=getFirestore(), now=Date.parse('2026-10-24T10:00:00+08:00'), examId='exam_dost_sei';
const auth=uid=>({uid,token:{firebase:{sign_in_provider:'anonymous'}}});
const deps={db,now:()=>now,allow:async()=>true};
const code=async p=>{try{await p;return 'ok';}catch(e){return e.code??String(e);}};
const batch=(uid,id='observed-session-1')=>({expectedUid:uid,sessionId:id,examId,origin:'drill',startedAt:now-2000,finishedAt:now,durationMs:2000,
 answers:[{questionId:'obs-q1',chosen:'a',correct:true,answeredAt:now,responseMs:1200,questionVersion:2}]});
test('observation metadata is attributable and account-bound',async()=>{
 const uid='w4b-obs'; await db.recursiveDelete(db.doc('users/'+uid));
 await writeContent(db,[questionSetItems({meta:{subject:'s',topic:'obs',exams:['dost-sei']},questions:[{id:'obs-q1',stem:'x',choices:[{text:'a',correct:true},{text:'b'}]}]},'obs/q.yaml').item,
 lessonItem({_id:'lesson-obs-one',title:'One',topic:'topic-obs',subject:'s'},'body')],[],{});clearExamContentCache();
 assert.equal(await code(recordSession(auth(uid),batch('other'),deps)),'failed-precondition');
 for(const extra of [{origin:'mock'},{origin:'unknown'},{examId:undefined},{expectedUid:undefined},{answers:[{...batch(uid).answers[0],questionId:'missing-q'}]}]){
  assert.equal(await code(recordSession(auth(uid),{...batch(uid),...extra},deps)),'invalid-argument');
 }
 assert.equal((await recordSession(auth(uid),batch(uid),deps)).stored,true);
 const row=(await db.doc('users/'+uid+'/server/answers/items/observed-session-1').get()).data();
 assert.equal(row.examId,examId);assert.equal(row.origin,'drill');assert.equal(row.answers[0].responseMs,1200);
 assert.equal((await recordSession(auth(uid),batch(uid),deps)).stored,false);
 const review=await db.doc('users/'+uid+'/server/reviews/items/obs-q1').get();
 assert.equal(review.exists,true,'ordinary answers seed shared review scheduling');
});
test('lesson observations preserve earliest actual timestamp and reject an account rebound',async()=>{
 const m=await import('../lib/studyObservations.js').catch(()=>({}));
 assert.equal(typeof m.writeLessonRead,'function','lesson observation endpoint exists');
 const uid='w4b-lesson';await db.recursiveDelete(db.doc('users/'+uid));
 assert.equal(await code(m.writeLessonRead(auth(uid),{expectedUid:'other',lessonId:'lesson-obs-one',readAt:now-5000},deps)),'failed-precondition');
 assert.equal(await code(m.writeLessonRead(auth(uid),{expectedUid:uid,lessonId:'missing',readAt:now},deps)),'invalid-argument');
 await m.writeLessonRead(auth(uid),{expectedUid:uid,lessonId:'lesson-obs-one',readAt:now-5000},deps);
 await m.writeLessonRead(auth(uid),{expectedUid:uid,lessonId:'lesson-obs-one',readAt:now-1000},deps);
 const row=await db.doc('users/'+uid+'/server/lessonReads/items/lesson-obs-one').get();assert.equal(row.get('readAt'),now-5000);
});

test('actual new-question and flagged origins ingest, immutable replay survives retired content',async()=>{
 const uid='w4b-replay';await db.recursiveDelete(db.doc('users/'+uid));
 for(const origin of ['new_questions','flagged']){
  const payload={...batch(uid,'observed-'+origin),origin};
  assert.equal((await recordSession(auth(uid),payload,deps)).stored,true);
 }
});
test('immutable successful replay survives retired content and conflicting reuse fails',async()=>{
 const uid='w4b-retired';await db.recursiveDelete(db.doc('users/'+uid));
 const payload=batch(uid,'observed-retired');
 assert.equal((await recordSession(auth(uid),payload,deps)).stored,true);
 await db.doc('content/questions/items/qs-obs__q').delete();clearExamContentCache();
 assert.equal((await recordSession(auth(uid),payload,deps)).stored,false);
 assert.equal(await code(recordSession(auth(uid),{...payload,durationMs:1},deps)),'failed-precondition');
});

test('a version 1 totals document is rebuilt once from the stored sessions, never counting a session twice',async()=>{
 const {loadTotals,completedOn}=await import('../lib/_answerTotals.js');
 const uid='w4b-totals-v1';await db.recursiveDelete(db.doc('users/'+uid));
 const items=db.collection('users/'+uid+'/server/answers/items');
 const midnight=Date.parse('2026-10-24T00:00:00+08:00');
 // Attributed: no per-answer time, crosses midnight. Legacy: real answer times, no exam or origin.
 await items.doc('attributed-0001').set({sessionId:'attributed-0001',examId,origin:'drill',startedAt:midnight-60000,finishedAt:midnight+60000,durationMs:120000,
  answers:[{questionId:'q-a',chosen:'a',correct:true},{questionId:'q-b',chosen:'a',correct:false}]});
 await items.doc('legacy-00001').set({sessionId:'legacy-00001',startedAt:midnight-5000,finishedAt:midnight+5000,durationMs:10000,
  answers:[{questionId:'q-a',chosen:'a',correct:true,answeredAt:midnight-1000}]});
 await db.doc('users/'+uid+'/server/answerTotals').set({version:1,sessions:2,answers:3,prunedDays:0,
  questionsJson:JSON.stringify([['q-a',2,2],['q-b',1,0]]),daysJson:JSON.stringify([['2026-10-23',[[0,2],[1,1]]]])});
 const totals=await loadTotals(db,uid);
 assert.equal(totals.sessions,2);assert.equal(totals.answers,3);
 assert.equal(totals.questions.get('q-a').answered,2);
 assert.equal(totals.questions.get('q-a').firstCompletedAt,midnight-1000,'legacy real answer time is the earliest');
 assert.equal(totals.questions.get('q-b').firstCompletedAt,midnight+60000,'attributed completion is the actual finish');
 assert.deepEqual([...completedOn(totals,'2026-10-24').ids].sort(),['q-a','q-b']);
 assert.deepEqual([...completedOn(totals,'2026-10-23').ids],['q-a']);
 assert.equal((await db.doc('users/'+uid+'/server/answerTotals').get()).get('version'),3);
 await items.doc('not-ingested-yet').set({answers:[{questionId:'q-later',chosen:'a',correct:true,answeredAt:now}]});
 const again=await loadTotals(db,uid);assert.equal(again.sessions,2,'the second read does not rebuild or recount');
 assert.equal(again.questions.has('q-later'),false);
 assert.deepEqual(again,totals);
});

test('ingestSession upgrades existing v1 totals and counts old and new sessions exactly once',async()=>{
 const {ingestSession}=await import('../lib/ingestSession.js');
 const {fromDoc,completedOn}=await import('../lib/_answerTotals.js');
 const uid='w4b-ingest-v1';await db.recursiveDelete(db.doc('users/'+uid));
 const earlier=now-86400000;
 await db.doc('users/'+uid+'/server/answers/items/legacy-before-v2').set({answers:[{questionId:'q-old',chosen:'a',correct:true,answeredAt:earlier}]});
 const ref=db.doc('users/'+uid+'/server/answerTotals');
 await ref.set({version:1,sessions:1,answers:1,questionsJson:'[["q-old",1,1]]',daysJson:'[]'});
 const payload={sessionId:'ingest-upgrade-v2',startedAt:now-1000,finishedAt:now,durationMs:1000,
  answers:[{questionId:'q-new',chosen:'a',correct:false,answeredAt:now}]};
 assert.equal((await ingestSession.run({auth:auth(uid),data:payload})).stored,true);
 const saved=(await ref.get()).data(),totals=fromDoc(saved);
 assert.equal(saved.version,3);assert.equal(totals.sessions,2);assert.equal(totals.answers,2);
 assert.equal(totals.questions.get('q-old').firstCompletedAt,earlier);
 assert.equal(totals.questions.get('q-new').firstCompletedAt,now);
 assert.deepEqual([...completedOn(totals,'2026-10-24').ids],['q-new']);
 assert.equal((await ingestSession.run({auth:auth(uid),data:payload})).stored,false);
 assert.deepEqual((await ref.get()).data(),saved);
});

// ---- a custom exam: any well-formed id is accepted, and the answers are checked against the whole corpus ----
// Math has m1 and m2, Language has l1 and l2, in two catalogs. zz9 is on neither: a phone's bundle can hold ids the catalog lacks.
const CUSTOM='exam_custom_'+randomUUID();
async function customCorpus(){
 const math={_id:'subj-math',name:'Math',exam:'exam_cx',ordering:1},lang={_id:'subj-lang',name:'Language',exam:'exam_cy',ordering:2};
 const tMath={_id:'topic-math',name:'Math topic',subject:'subj-math',ordering:1},tLang={_id:'topic-lang',name:'Language topic',subject:'subj-lang',ordering:1};
 const set=(id,topic,ids)=>({id,topic,lesson:null,exams:['exam_cx','exam_cy'],questions:ids.map(q=>({id:q}))});
 const put=(id,value)=>db.doc('content/catalog/items/'+id).set({version:'v1',payload:JSON.stringify(value)});
 await put('index',{subjects:[math,lang],topics:[tMath,tLang],catalogs:['exam_cx','exam_cy']});
 await put('exam_cx',{id:'exam_cx',sets:[set('set-math','topic-math',['m1','m2'])]});
 await put('exam_cy',{id:'exam_cy',sets:[set('set-lang','topic-lang',['l1','l2'])]});
 clearExamContentCache();
}
const customBatch=(uid,id,questions,over={})=>({expectedUid:uid,sessionId:id,examId:CUSTOM,origin:'drill',startedAt:now-2000,finishedAt:now,durationMs:2000,
 answers:questions.map(questionId=>({questionId,chosen:questionId+'_a',correct:true,answeredAt:now,responseMs:1200})),...over});
const totalsOf=async uid=>(await db.doc('users/'+uid+'/server/answerTotals').get()).data();
const sessionDoc=(uid,id)=>db.doc('users/'+uid+'/server/answers/items/'+id).get();
const customSettings=(uid,excludedTopicIds=[])=>db.doc('users/'+uid+'/server/settings').set({examId:CUSTOM,examDate:null,studyDays:[1,2,3,4,5,6,7],
 assessmentCompleted:true,updatedAt:now,excludedTopicIds,excludedLessonIds:[]});
// The roadmap rebuild after a stored session logs and swallows its own failure, so a test listens for it.
async function withoutRebuildErrors(run){
 const logged=[],original=console.error;console.error=(...args)=>logged.push(args);
 try{await run();}finally{console.error=original;}
 assert.deepEqual(logged,[],'the roadmap rebuild did not fail');
}
test('a custom corpus is ready',async()=>{await customCorpus();});

test('a custom session is stored with no track document, and seeds reviews and totals like a listed one',async()=>{
 const uid='cus-obs-store';await db.recursiveDelete(db.doc('users/'+uid));
 assert.deepEqual(await recordSession(auth(uid),customBatch(uid,'custom-session-1',['m1','l1']),deps),{sessionId:'custom-session-1',stored:true});
 const row=(await sessionDoc(uid,'custom-session-1')).data();
 assert.equal(row.examId,CUSTOM);assert.equal(row.origin,'drill');assert.equal(row.answerCount,2);assert.deepEqual(row.answers.map(a=>a.questionId),['m1','l1']);
 assert.equal((await db.doc('users/'+uid+'/server/customTracks/items/'+CUSTOM).get()).exists,false,'no track document is needed or made');
 assert.equal((await db.doc('users/'+uid+'/server/reviews/items/m1').get()).exists,true);
 assert.equal((await totalsOf(uid)).sessions,1);assert.equal((await totalsOf(uid)).answers,2);
});

test('a replay of a custom session does not count twice',async()=>{
 const uid='cus-obs-replay';await db.recursiveDelete(db.doc('users/'+uid));
 const payload=customBatch(uid,'custom-session-2',['m1','m2']);
 assert.equal((await recordSession(auth(uid),payload,deps)).stored,true);
 const before=await totalsOf(uid);
 assert.equal((await recordSession(auth(uid),payload,deps)).stored,false);
 assert.deepEqual(await totalsOf(uid),before);
 assert.equal(before.sessions,1);assert.equal(before.answers,2);
 assert.equal(await code(recordSession(auth(uid),{...payload,durationMs:1},deps)),'failed-precondition');
 assert.equal(await code(recordSession(auth(uid),customBatch(uid,'custom-session-2',['m1','l2']),deps)),'failed-precondition');
});

test('an answer whose question is not in the corpus is dropped, and the rest of the session is kept',async()=>{
 const uid='cus-obs-unknown';await db.recursiveDelete(db.doc('users/'+uid));
 assert.equal((await recordSession(auth(uid),customBatch(uid,'custom-session-3',['m1','zz9','l2']),deps)).stored,true);
 const row=(await sessionDoc(uid,'custom-session-3')).data();
 assert.deepEqual(row.answers.map(a=>a.questionId),['m1','l2']);assert.equal(row.answerCount,2);
 assert.equal((await totalsOf(uid)).answers,2);
 assert.equal((await db.doc('users/'+uid+'/server/reviews/items/zz9').get()).exists,false);
 assert.equal((await db.doc('users/'+uid+'/server/reviews/items/l2').get()).exists,true);
});

test('a custom session left with nothing after the filter stores nothing at all',async()=>{
 const uid='cus-obs-empty';await db.recursiveDelete(db.doc('users/'+uid));
 assert.deepEqual(await recordSession(auth(uid),customBatch(uid,'custom-session-4',['zz9','zz8']),deps),{sessionId:'custom-session-4',stored:false});
 assert.equal((await sessionDoc(uid,'custom-session-4')).exists,false);
 assert.equal((await db.doc('users/'+uid+'/server/answerTotals').get()).exists,false);
 assert.equal((await db.collection('users/'+uid+'/server/reviews/items').get()).size,0);
 assert.equal((await db.doc('users/'+uid+'/server/studyInsights').get()).exists,false);
});

test('a replay of a filtered custom session compares the filtered list, so no answer is lost and none is refused',async()=>{
 const uid='cus-obs-filtered-replay';await db.recursiveDelete(db.doc('users/'+uid));
 const payload=customBatch(uid,'custom-session-5',['m1','zz9','m2']);
 assert.equal((await recordSession(auth(uid),payload,deps)).stored,true);
 assert.equal((await recordSession(auth(uid),payload,deps)).stored,false,'the full payload again is the same session');
 assert.deepEqual((await sessionDoc(uid,'custom-session-5')).get('answers').map(a=>a.questionId),['m1','m2'],'the stored answers are untouched');
 assert.equal((await totalsOf(uid)).answers,2);
 assert.equal(await code(recordSession(auth(uid),customBatch(uid,'custom-session-5',['m1','zz9']),deps)),'failed-precondition','a real difference still fails');
});

test('a listed exam keeps its strictness, and a malformed custom id is not a known exam',async()=>{
 const uid='cus-obs-listed';await db.recursiveDelete(db.doc('users/'+uid));
 const listed={...batch(uid,'listed-strict-1'),answers:[{...batch(uid).answers[0]},{...batch(uid).answers[0],questionId:'missing-q'}]};
 await assert.rejects(recordSession(auth(uid),listed,deps),e=>e.code==='invalid-argument'&&e.message==='Question is outside this exam.');
 assert.equal((await sessionDoc(uid,'listed-strict-1')).exists,false);
 for(const examId of ['exam_custom','exam_custom_'+randomUUID().toUpperCase(),'exam_custom_'+randomUUID()+'x']){
  await assert.rejects(recordSession(auth(uid),customBatch(uid,'custom-session-6',['m1'],{examId}),deps),
   e=>e.code==='invalid-argument'&&e.message==='Send a known exam and session origin.');
 }
 await assert.rejects(recordSession(auth(uid),customBatch(uid,'custom-session-6',['m1'],{origin:'mock'}),deps),e=>e.code==='invalid-argument');
 await assert.rejects(recordSession(auth(uid),customBatch('someone-else','custom-session-6',['m1']),deps),e=>e.code==='failed-precondition');
});

test('scope is not applied at ingest: a session finished before narrowing counts, and a later one on a narrowed subject is kept',async()=>{
 const uid='cus-obs-scope';await db.recursiveDelete(db.doc('users/'+uid));
 await customSettings(uid);
 await withoutRebuildErrors(async()=>{
  assert.equal((await recordSession(auth(uid),customBatch(uid,'custom-session-7',['m1','l1']),deps)).stored,true);
 });
 assert.equal((await db.doc('users/'+uid+'/server/studyInsights').get()).exists,true,'the rebuild after a custom session reads the insights too');
 assert.equal((await db.doc(`users/${uid}/server/roadmapDays/items/${CUSTOM}:2026-10-24`).get()).exists,true,'and the plan');
 const view=()=>readStudyInsights(auth(uid),{expectedUid:uid,examId:CUSTOM},deps).then(r=>r.performance.overall);
 assert.deepEqual(await view(),{correct:2,answered:2});
 await customSettings(uid,['topic-lang']);
 assert.deepEqual(await view(),{correct:1,answered:1},'narrowing hides the Language answer');
 assert.equal((await recordSession(auth(uid),customBatch(uid,'custom-session-8',['l2']),deps)).stored,true,'Language is not ticked, and the session is still stored');
 assert.equal((await totalsOf(uid)).answers,3);
 assert.deepEqual(await view(),{correct:1,answered:1});
 await customSettings(uid,[]);
 assert.deepEqual(await view(),{correct:3,answered:3},'ticking it again restores every answer');
});

test('a lesson read with custom settings active is stored and the rebuild does not fail',async()=>{
 const m=await import('../lib/studyObservations.js');
 const uid='cus-obs-lesson';await db.recursiveDelete(db.doc('users/'+uid));
 await customSettings(uid);
 await withoutRebuildErrors(async()=>{
  assert.deepEqual(await m.writeLessonRead(auth(uid),{expectedUid:uid,lessonId:'lesson-obs-one',readAt:now-1000},deps),{stored:true});
 });
 assert.equal((await db.doc('users/'+uid+'/server/lessonReads/items/lesson-obs-one').get()).get('readAt'),now-1000);
 assert.equal((await db.doc('users/'+uid+'/server/studyInsights').get()).exists,true);
 assert.equal((await db.doc(`users/${uid}/server/roadmapDays/items/${CUSTOM}:2026-10-24`).get()).exists,true);
});

test('custom observations cleanup',async()=>{
 for(const id of ['index','exam_cx','exam_cy'])await db.doc('content/catalog/items/'+id).delete();
 clearExamContentCache();
});
