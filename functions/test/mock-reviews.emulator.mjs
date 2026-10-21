import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {beginMock, changeMock, readMock, recordMock} from '../lib/mock.js';
import {serveMockResults} from '../lib/mockReader.js';
import {saveExamSettings, serveRoadmap} from '../lib/roadmap.js';
import {recordSession} from '../lib/ingestSession.js';
import {questionSetItems, blueprintItem, writeContent} from '../lib/contentUpload.js';
import {clearExamContentCache} from '../lib/_examContent.js';
assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore(), NOW = Date.parse('2026-11-20T10:00:00+08:00'), DAY=86400000, EXAM='exam_cse_pro';
const named=uid=>({uid, token:{firebase:{sign_in_provider:'google.com'}}});
const deps=(at=NOW)=>({db,now:()=>at,allow:async()=>true,seed:()=>5});
const items=uid=>db.collection(`users/${uid}/server/mocks/items`);
const reviews=uid=>db.collection(`users/${uid}/server/reviews/items`);
const ledger=(uid,id)=>db.doc(`users/${uid}/server/answers/items/mock:${id}`);
const totals=async uid=>(await db.doc(`users/${uid}/server/answerTotals`).get()).data();
const snapshot=async(uid,id)=>(await items(uid).doc(id).get()).data();
const settings={examId:EXAM,examDate:null,studyDays:[1,2,3,4,5,6,7],assessmentCompleted:true};
async function start(uid, strict=false){await db.recursiveDelete(db.doc(`users/${uid}`));return beginMock(named(uid),{examId:EXAM,strict},deps());}
function answers(paper, blank=false){return paper.sections.flatMap(s=>s.questions).map((q,i)=>({questionId:q.id,chosen:blank||i===2?null:i===0?'a':'b',correct:!blank&&i===0,answeredAt:NOW}));}
async function submit(uid,out, reason='student', at=NOW+1000){const body={mockId:out.mockId,answers:answers(out.paper),durationMs:1000,reason};await recordMock(named(uid),body,deps(at));return body;}

test('seed mock-review content',async()=>{
 const set=questionSetItems({meta:{subject:'s',topic:'review',exams:['cse-pro']},questions:Array.from({length:6},(_,i)=>({id:`mrq${i}`,stem:'x',choices:[{text:'a',correct:true},{text:'b'}]}))},'mock-review/q.yaml').item;
 const blueprint=blueprintItem({exam:EXAM,name:'Paper',durationMinutes:60,sectionalTiming:'none',sections:[{id:'s',name:'Paper',questionCount:3,suggestedMinutes:60,topicIds:['topic_cse_pro_review'],topicWeights:{topic_cse_pro_review:1}}]});
 await writeContent(db,[set,blueprint],[],{});clearExamContentCache();
});
test('submission atomically records chosen answers, totals and review states once',async()=>{
 const uid='mr-record', out=await start(uid);const body=await submit(uid,out);
 const record=await ledger(uid,out.mockId).get();assert.equal(record.exists,true);
 assert.equal(record.get('answers').length,2);assert.equal(record.get('origin'),'mock');
 let sum=await totals(uid);assert.equal(sum.sessions,1);assert.equal(sum.answers,2);
 const states=(await reviews(uid).get()).docs.map(d=>JSON.parse(d.get('stateJson')));
 assert.equal(states.length,2);assert.ok(states.every(s=>s.reps===1));assert.deepEqual(states.map(s=>s.stage).sort(),['learning','review']);
 await Promise.all([recordMock(named(uid),body,deps()),recordMock(named(uid),body,deps())]);
 await serveMockResults(named(uid),{mockId:out.mockId},deps());
 sum=await totals(uid);assert.equal(sum.sessions,1);assert.equal(sum.answers,2);
 assert.ok((await reviews(uid).get()).docs.every(d=>JSON.parse(d.get('stateJson')).reps===1));
});
test('strict exit and timeout use the same atomic answer feed',async()=>{
 for(const timeout of [false,true]){
  const uid=`mr-terminal-${timeout}`,out=await start(uid,true);
  if(timeout){await changeMock(named(uid),{mockId:out.mockId,action:'save',answers:answers(out.paper)},deps());await readMock(named(uid),{},deps(NOW+3600000));}
  else await submit(uid,out,'strict-exit');
  assert.equal((await ledger(uid,out.mockId).get()).exists,true);assert.equal((await totals(uid)).answers,2);assert.equal((await reviews(uid).get()).size,2);
 }
});
test('an all-blank paper records the terminal session without invented answered questions',async()=>{
 const uid='mr-blank',out=await start(uid);
 await recordMock(named(uid),{mockId:out.mockId,answers:answers(out.paper,true),durationMs:1000},deps(NOW+1000));
 assert.equal((await ledger(uid,out.mockId).get()).get('answers').length,0);assert.equal((await totals(uid)).sessions,1);assert.equal((await totals(uid)).answers,0);assert.equal((await reviews(uid).get()).size,0);
});
test('mock answers invalidate same-day roadmap cache and ordinary review advances the existing scheduler state',async()=>{
 const uid='mr-roadmap',out=await start(uid);await saveExamSettings(named(uid),settings,deps());
 await submit(uid,out);
 await serveRoadmap(named(uid),{},deps(NOW+2000));
 assert.equal((await db.doc(`users/${uid}/server/roadmap`).get()).get('answerSessions'),1);
 const wrong=out.paper.sections[0].questions[1].id;
 await serveRoadmap(named(uid),{},deps(NOW+2*DAY));
 let stored=(await db.doc(`users/${uid}/server/roadmap`).get()).data();
 assert.equal(stored.answerSessions,1);assert.ok(JSON.parse(stored.roadmapJson).today.reviewQuestionIds.includes(wrong));
 const at=NOW+2*DAY+1000;
 await recordSession(named(uid),{sessionId:'ordinary-review-1',startedAt:at-1000,finishedAt:at,durationMs:1000,answers:[{questionId:wrong,chosen:'a',correct:true,answeredAt:at}]},deps(at));
 const state=JSON.parse((await reviews(uid).doc(encodeURIComponent(wrong)).get()).get('stateJson'));
 assert.equal(state.reps,2);assert.equal(Date.parse(state.lastReview),at);assert.ok(Date.parse(state.due)>at);
 stored=(await db.doc(`users/${uid}/server/roadmap`).get()).data();assert.equal(stored.answerSessions,2);
});
test('a completed legacy result reconciles once and cannot overwrite a newer review',async()=>{
 const uid='mr-legacy',out=await start(uid);await submit(uid,out);
 const before=(await reviews(uid).get()).docs.map(d=>[d.id,d.data()]);
 const id='LegacyMock000001';
 await items(uid).doc(id).set({...await snapshot(uid,out.mockId),startedAt:NOW-DAY-1000,submittedAt:NOW-DAY});
 await serveMockResults(named(uid),{mockId:id},deps());
 await serveMockResults(named(uid),{mockId:id},deps());
 assert.equal((await totals(uid)).sessions,2);
 for(const [id,data]of before)assert.deepEqual((await reviews(uid).doc(id).get()).data(),data);
});

test('concurrent submission and strict recovery publish one terminal answer feed',async()=>{
 const uid='mr-concurrent',out=await start(uid);
 const body={mockId:out.mockId,answers:answers(out.paper),durationMs:1000};
 await Promise.all([recordMock(named(uid),body,deps(NOW+1000)),recordMock(named(uid),body,deps(NOW+1000))]);
 assert.equal((await totals(uid)).sessions,1);assert.ok((await reviews(uid).get()).docs.every(d=>JSON.parse(d.get('stateJson')).reps===1));
 const strictUid='mr-concurrent-strict',strict=await start(strictUid,true);
 await changeMock(named(strictUid),{mockId:strict.mockId,action:'save',answers:answers(strict.paper)},deps());
 const results=await Promise.all(Array.from({length:4},()=>readMock(named(strictUid),{},deps(NOW+3600000))));
 assert.ok(results.every(r=>r.open===false),'No response may revive the already-finished strict paper.');
 assert.equal((await totals(strictUid)).sessions,1);
 const startUid='mr-concurrent-start',expired=await start(startUid,true);
 const starts=await Promise.allSettled(Array.from({length:4},()=>beginMock(named(startUid),{examId:EXAM},deps(NOW+3600000))));
 assert.ok(starts.every(s=>s.status==='rejected'&&s.reason.code==='failed-precondition'),'Free starts cannot return the old expired paper.');
 assert.equal((await totals(startUid)).sessions,1);
});

test('review-state failure rolls back submission and answer totals before a successful retry',async()=>{
 const uid='mr-rollback',out=await start(uid),first=out.paper.sections[0].questions[0].id;
 await reviews(uid).doc(encodeURIComponent(first)).set({questionId:first,due:NOW,stateJson:'not json'});
 const body={mockId:out.mockId,answers:answers(out.paper),durationMs:1000};
 await assert.rejects(recordMock(named(uid),body,deps(NOW+1000)));
 assert.equal((await snapshot(uid,out.mockId)).status,'started');assert.equal((await ledger(uid,out.mockId).get()).exists,false);
 assert.equal((await db.doc(`users/${uid}/server/answerTotals`).get()).exists,false);
 await reviews(uid).doc(encodeURIComponent(first)).delete();
 await recordMock(named(uid),body,deps(NOW+1000));assert.equal((await totals(uid)).sessions,1);
});
