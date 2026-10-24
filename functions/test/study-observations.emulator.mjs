import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {recordSession} from '../lib/ingestSession.js';
import {lessonItem, questionSetItems, writeContent} from '../lib/contentUpload.js';
import {clearExamContentCache} from '../lib/_examContent.js';
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
 assert.equal((await db.doc('users/'+uid+'/server/answerTotals').get()).get('version'),2);
 const again=await loadTotals(db,uid);assert.equal(again.sessions,2,'the second read does not rebuild or recount');
});
