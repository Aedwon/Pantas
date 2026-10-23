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
