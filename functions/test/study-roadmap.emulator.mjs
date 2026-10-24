import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {saveExamSettings,readStudyRoadmap,advanceStudyRoadmap,readStudyDay} from '../lib/roadmap.js';
import {recordSession} from '../lib/ingestSession.js';
import {readStudyInsights} from '../lib/studyInsights.js';
import {emptyTotals,toDoc} from '../lib/_answerTotals.js';
const db=getFirestore(),NOW=Date.parse('2026-10-24T10:00:00+08:00'),EXAM='exam_cse_pro',DAY=86400000;
const auth=uid=>({uid,token:{firebase:{sign_in_provider:'anonymous'},pro:true,proUntil:NOW+100*DAY}});
const deps=(at=NOW)=>({db,now:()=>at,allow:async()=>true});
const body=uid=>({expectedUid:uid,examId:EXAM});
const code=async p=>{try{await p;return 'ok';}catch(e){return e.code??String(e);}};
async function seed(uid){
 await db.recursiveDelete(db.doc('users/'+uid));
 const topics=[{_id:'topic-cse-alpha',name:'Authored Alpha',subject:'subject-cse',ordering:0},{_id:'topic-cse-beta',name:'Authored Beta',subject:'subject-cse',ordering:1}];
 const lessons=Array.from({length:12},(_,i)=>({id:'lesson-cse-'+i,title:'Lesson '+i,topic:topics[i<6?0:1]._id,ordering:i}));
 const sets=topics.map((t,n)=>({id:'set-cse-'+n,topic:t._id,lesson:lessons[n*6].id,exams:[EXAM],questions:Array.from({length:12},(_,i)=>({id:'cse-'+n+'-'+i}))}));
 await db.doc('content/catalog/items/'+EXAM).set({version:'catalog-v1',payload:JSON.stringify({id:EXAM,subjects:[{_id:'subject-cse',name:'Authored Subject',exam:EXAM,ordering:0}],topics,lessons,sets})});
 await db.doc('users/'+uid+'/server/settings').set({examId:EXAM,examDate:{precision:'day',day:'2026-11-15'},studyDays:[1,2,3,4,5,6,7],assessmentCompleted:true,updatedAt:NOW});
 await db.doc('users/'+uid+'/server/answerTotals').set(toDoc(emptyTotals()));
 for(const [i,t]of topics.entries())await db.doc('content/questions/items/raw-cse-'+i).set({payload:JSON.stringify({meta:{subject:'s',topic:i?'beta':'alpha',exams:['cse-pro']},questions:sets[i].questions.map(q=>({...q,choices:[{text:'a',correct:true},{text:'b'}]}))})});
 for(const l of lessons)await db.doc('content/lessons/items/'+l.id).set({title:l.title,topic:l.topic});
 return {topics,lessons,sets};
}
test('authoritative Today stays original while actual completion changes remaining, no fabricated mock',async()=>{
 const uid='w4b-roadmap';await seed(uid);await db.doc('content/mocks/items/'+EXAM).delete();
 const first=await readStudyRoadmap(auth(uid),body(uid),deps());
 assert.equal(first.proCovered,false,'generic Pro claim cannot grant exam access');
 assert.equal(first.today.isMockDay,false);
 assert.equal('comingUp'in first,false);assert.equal('history'in first,false);
 for(const secret of ['digest','scope','topicOrder','weeksAhead'])assert.equal(JSON.stringify(first).includes('"'+secret+'"'),false);
 const lessonId=first.today.lessonIds[0];
 await db.doc('users/'+uid+'/server/lessonReads/items/'+lessonId).set({lessonId,readAt:NOW+1000});
 const next=await readStudyRoadmap(auth(uid),body(uid),deps(NOW+1000));
 assert.deepEqual(next.today,first.today);
 assert.equal(next.remaining.lessonIds.includes(lessonId),false);
 assert.notEqual(next.revision,first.revision);
 assert.equal(await code(readStudyDay(auth(uid),{...body(uid),date:'2026-10-25'},deps())),'permission-denied');
 assert.equal((await readStudyDay(auth(uid),{...body(uid),date:'2026-10-01'},deps())).kind,'unknown');
});
test('current coverage allows future, immutable advance applies once and refuses conflicting identity',async()=>{
 const uid='w4b-advance';await seed(uid);
 await db.doc('users/'+uid+'/grants/trial').set({source:'trial',product:'web_trial',tier:'civilService',startsAt:NOW-DAY,endsAt:NOW+DAY,state:'active',createdAt:NOW-DAY});
 const first=await readStudyRoadmap(auth(uid),body(uid),deps());
 for(const lessonId of first.today.lessonIds)await db.doc('users/'+uid+'/server/lessonReads/items/'+lessonId).set({lessonId,readAt:NOW});
 // Use the real totals document to record the exact original question completion.
 const {addSession,fromDoc}=await import('../lib/_answerTotals.js');
 const ref=db.doc('users/'+uid+'/server/answerTotals'),totals=fromDoc((await ref.get()).data());
 addSession(totals,first.today.newQuestionIds.map(questionId=>({questionId,chosen:'a',correct:true,answeredAt:NOW})));await ref.set(toDoc(totals));
 const ready=await readStudyRoadmap(auth(uid),body(uid),deps());
 assert.equal(ready.originalDone,true);assert.equal(ready.canAdvance,true);
 const request={...body(uid),requestId:'advance-request-1',expectedDay:ready.today.day,expectedRevision:ready.revision};
 const result=await advanceStudyRoadmap(auth(uid),request,deps());
 assert.ok(result.today.advancedIds.length>0);
 assert.deepEqual((await advanceStudyRoadmap(auth(uid),request,deps())).today,result.today);
 assert.equal(await code(advanceStudyRoadmap(auth(uid),{...request,expectedUid:'other'},deps())),'failed-precondition');
 assert.equal(await code(advanceStudyRoadmap(auth(uid),{...request,expectedRevision:'different'},deps())),'failed-precondition');
 const future=await readStudyDay(auth(uid),{...body(uid),date:'2026-10-25'},deps());assert.equal(future.kind,'future');
 const expired=await readStudyRoadmap(auth(uid),body(uid),deps(NOW+2*DAY));assert.equal(expired.proCovered,false);assert.equal('comingUp'in expired,false);
});
test('settings exclusions remain authoritative and reject unknown or all-topic exclusions',async()=>{
 const uid='w4b-scope';const {topics}=await seed(uid);
 const settings={...body(uid),examDate:{precision:'day',day:'2026-11-15'},studyDays:[1,2,3,4,5,6,7],assessmentCompleted:true,excludedTopicIds:[topics[0]._id]};
 await saveExamSettings(auth(uid),settings,deps());
 const view=await readStudyRoadmap(auth(uid),body(uid),deps());
 assert.equal(view.todayTopicOrder.includes(topics[0]._id),false);
 assert.equal(view.today.lessonIds.some(id=>Number(id.split('-').at(-1))<6),false);
 assert.equal(await code(saveExamSettings(auth(uid),{...settings,excludedTopicIds:['missing']},deps())),'invalid-argument');
 assert.equal(await code(saveExamSettings(auth(uid),{...settings,excludedTopicIds:topics.map(t=>t._id)},deps())),'invalid-argument');
});
test('insight payload gates paid fields and uses actual trial evidence',async()=>{
 const uid='w4b-insights';await seed(uid);
 const free=await readStudyInsights(auth(uid),body(uid),deps());
 assert.equal(free.proCovered,false);assert.equal(free.trialEndsAt,null);
 for(const field of ['tendencies','whenYouWork'])assert.equal(field in free,false);
 assert.equal('topics'in free.performance,false);assert.equal('lessons'in free.performance,false);
 await db.doc('users/'+uid+'/grants/trial').set({source:'trial',product:'web_trial',tier:'civilService',startsAt:NOW-DAY,endsAt:NOW+DAY,state:'active',createdAt:NOW-DAY});
 const pro=await readStudyInsights(auth(uid),body(uid),deps());assert.equal(pro.proCovered,true);assert.equal(pro.trialEndsAt,NOW+DAY);
 for(const tendency of Object.values(pro.tendencies)){assert.equal(tendency.confidence,'early');assert.equal(tendency.value,null);}
 assert.equal(await code(readStudyInsights(auth(uid),{...body(uid),expectedUid:'other'},deps())),'failed-precondition');
});

test('past completion uses observed historical dates even without a final plan read',async()=>{
 const uid='w4b-past';await seed(uid);const first=await readStudyRoadmap(auth(uid),body(uid),deps());
 for(const lessonId of first.today.lessonIds)await db.doc('users/'+uid+'/server/lessonReads/items/'+lessonId).set({lessonId,readAt:NOW+1000});
 const {addSession,fromDoc}=await import('../lib/_answerTotals.js');
 const ref=db.doc('users/'+uid+'/server/answerTotals'),totals=fromDoc((await ref.get()).data());
 addSession(totals,first.today.newQuestionIds.map(questionId=>({questionId,chosen:'a',correct:true,answeredAt:NOW+1000})));await ref.set(toDoc(totals));
 const next=await readStudyRoadmap(auth(uid),body(uid),deps(NOW+DAY));

 const past=await readStudyDay(auth(uid),{...body(uid),date:'2026-10-24'},deps(NOW+DAY));
 assert.equal(past.remaining.lessonIds.length,0);assert.equal(past.remaining.newQuestionIds.length,0);
});

test('advance rejects stale revision after unviewed input change',async()=>{
 const uid='w4b-stale-advance';await seed(uid);
 const first=await readStudyRoadmap(auth(uid),body(uid),deps());
 for(const lessonId of first.today.lessonIds)await db.doc('users/'+uid+'/server/lessonReads/items/'+lessonId).set({lessonId,readAt:NOW});
 const {addSession,fromDoc}=await import('../lib/_answerTotals.js');const ref=db.doc('users/'+uid+'/server/answerTotals'),totals=fromDoc((await ref.get()).data());
 addSession(totals,first.today.newQuestionIds.map(questionId=>({questionId,chosen:'a',correct:true,answeredAt:NOW})));await ref.set(toDoc(totals));
 const ready=await readStudyRoadmap(auth(uid),body(uid),deps());
 await db.doc('users/'+uid+'/server/lessonReads/items/lesson-cse-11').set({lessonId:'lesson-cse-11',readAt:NOW});
 const request={...body(uid),requestId:'advance-stale-01',expectedDay:ready.today.day,expectedRevision:ready.revision};
 assert.equal(await code(advanceStudyRoadmap(auth(uid),request,deps())),'failed-precondition');
 assert.equal((await db.doc('users/'+uid+'/server/roadmapAdvances/items/'+request.requestId).get()).exists,false);
});

test('history includes current real shaping change immediately, with stable pages',async()=>{
 const uid='w4b-history';await seed(uid);
 await db.doc('users/'+uid+'/grants/trial').set({source:'trial',product:'web_trial',tier:'civilService',startsAt:NOW-DAY,endsAt:NOW+DAY,state:'active',createdAt:NOW-DAY});
 await readStudyRoadmap(auth(uid),body(uid),deps());
 await db.doc('users/'+uid+'/server/settings').update({examDate:{precision:'day',day:'2026-11-14'},updatedAt:NOW+1000});
 const first=await readStudyRoadmap(auth(uid),{...body(uid),historyLimit:1},deps(NOW+1000));
 assert.equal(first.history.changes[0]?.cause,'examDateChanged');
 const again=await readStudyRoadmap(auth(uid),{...body(uid),historyLimit:1},deps(NOW+2000));
 assert.deepEqual(again.history.changes,first.history.changes);
 assert.equal(first.history.changes.some(c=>['newDay','prerequisiteCycle'].includes(c.cause)),false);
});
test('mixed finished origins count accuracy once and legacy metadata stays absent',async()=>{
 const uid='w4b-mixed';await seed(uid);
 const ref=db.collection('users/'+uid+'/server/answers/items');
 for(const [origin,correct]of[['assessment',true],['inline',false],['drill',true],['mock',false]])await ref.doc(origin).set({sessionId:origin,examId:EXAM,origin,startedAt:NOW-1000,finishedAt:NOW,durationMs:1000,answers:[{questionId:'cse-0-0',chosen:'a',correct,answeredAt:NOW}]});
 await ref.doc('legacy').set({sessionId:'legacy',startedAt:NOW-1000,finishedAt:NOW,durationMs:1000,answers:[{questionId:'cse-0-0',chosen:'a',correct:true,answeredAt:NOW}]});
 const result=await readStudyInsights(auth(uid),body(uid),deps());
 assert.deepEqual(result.performance.overall,{correct:2,answered:4});
 assert.equal(result.performance.subjects[0].title,'Authored Subject');
});

test('finished-session ingest refreshes stored authoritative remaining and insight cache',async()=>{
 const uid='w4b-write-derived';await seed(uid);
 const first=await readStudyRoadmap(auth(uid),body(uid),deps());
 const questionId=first.today.newQuestionIds[0];
 await recordSession(auth(uid),{...body(uid),sessionId:'derived-session-01',origin:'drill',startedAt:NOW-2000,finishedAt:NOW,durationMs:2000,
  answers:[{questionId,chosen:'a',correct:true,answeredAt:NOW,responseMs:1200,questionVersion:1}]},deps());
 const saved=await db.doc('users/'+uid+'/server/roadmapDays/items/'+EXAM+':2026-10-24').get();
 assert.equal(JSON.parse(saved.get('stateJson')).remaining.newQuestionIds.includes(questionId),false);
 const insight=await db.doc('users/'+uid+'/server/studyInsights').get();assert.equal(insight.exists,true);
});

test('shared selected-exam catalog references resolve authored index topics and other-exam lessons',async()=>{
 const uid='w4b-catalog-closure';await seed(uid);
 const shared='topic_upcat_shared',lesson='lesson-shared';
 await db.doc('content/catalog/items/index').set({version:'index-shared-v1',payload:JSON.stringify({subjects:[{_id:'subject-shared',name:'Authored shared subject',exam:'exam_upcat'}],topics:[{_id:shared,name:'Authored shared topic',subject:'subject-shared'}],catalogs:[EXAM,'exam_upcat']})});
 await db.doc('content/catalog/items/exam_upcat').set({version:'shared-v1',payload:JSON.stringify({id:'exam_upcat',subjects:[],topics:[],lessons:[{id:lesson,title:'Authored shared lesson',topic:shared,ordering:2}],sets:[]})});
 await db.doc('content/catalog/items/'+EXAM).set({version:'closure-v1',payload:JSON.stringify({id:EXAM,subjects:[],topics:[],lessons:[],sets:[{id:'shared-set',topic:shared,lesson,exams:[EXAM],questions:[{id:'shared-q'}]}]})});
 const out=await readStudyRoadmap(auth(uid),body(uid),deps());assert.deepEqual(out.today.lessonIds,[lesson]);assert.deepEqual(out.todayTopicOrder,[shared]);
 await db.doc('content/catalog/items/exam_upcat').update({version:'shared-v2',payload:JSON.stringify({id:'exam_upcat',lessons:[],sets:[]})});
 assert.notEqual(await code(readStudyRoadmap(auth(uid),body(uid),deps())),'ok');
 await db.doc('content/catalog/items/index').delete();await db.doc('content/catalog/items/exam_upcat').delete();
});

test('a catalog document without a readable payload fails with a typed recoverable error, not a parse crash',async()=>{
 const uid='w4b-bad-catalog';await seed(uid);
 await db.doc('content/catalog/items/index').set({version:'v'});
 try{
  assert.equal(await code(readStudyRoadmap(auth(uid),body(uid),deps())),'unavailable');
  assert.equal(await code(readStudyInsights(auth(uid),body(uid),deps())),'unavailable');
  await db.doc('content/catalog/items/index').set({version:'v',payload:'{not json'});
  assert.equal(await code(readStudyRoadmap(auth(uid),body(uid),deps())),'unavailable');
  await db.doc('content/catalog/items/index').set({version:'v',payload:'[]'});
  assert.equal(await code(readStudyRoadmap(auth(uid),body(uid),deps())),'unavailable');
 }finally{await db.doc('content/catalog/items/index').delete();}
 assert.equal(await code(readStudyRoadmap(auth(uid),body(uid),deps())),'ok');
});

const trial=uid=>db.doc('users/'+uid+'/grants/trial').set({source:'trial',product:'web_trial',tier:'civilService',startsAt:NOW-60*DAY,endsAt:NOW+60*DAY,state:'active',createdAt:NOW-60*DAY});
const {readStudyWeek}=await import('../lib/roadmap.js');
test('a Free week read returns the past and today and locks future days with no payload; Pro gets them',async()=>{
 const thursday=Date.parse('2026-10-22T10:00:00+08:00');
 const uid='w4b-free-week';await seed(uid);
 await readStudyRoadmap(auth(uid),body(uid),deps(thursday-DAY));   // stores Wednesday's snapshot
 const free=await readStudyWeek(auth(uid),{...body(uid),start:'2026-10-18'},deps(thursday));
 assert.equal(free.proCovered,false);assert.equal(free.days.length,7);
 assert.deepEqual(free.days.map(d=>d.date),['2026-10-18','2026-10-19','2026-10-20','2026-10-21','2026-10-22','2026-10-23','2026-10-24']);
 assert.equal(free.days[3].kind,'past');assert.ok(free.days[3].plan,'Free keeps the actual past day');
 assert.equal(free.days[4].kind,'today');
 for(const d of free.days.slice(5)){assert.equal(d.kind,'locked');assert.equal('plan'in d,false);assert.equal('remaining'in d,false);}
 assert.equal(JSON.stringify(free).includes('lesson-cse'),true,'today and past lessons are real data');
 const future=JSON.stringify(free.days.slice(5));assert.equal(future.includes('lesson'),false);
 const uid2='w4b-pro-week';await seed(uid2);await trial(uid2);
 const covered=await readStudyWeek(auth(uid2),{...body(uid2),start:'2026-10-18'},deps(thursday));
 assert.equal(covered.proCovered,true);assert.equal(covered.days[5].kind,'future');assert.ok(covered.days[5].plan);
 assert.equal(await code(readStudyWeek(auth(uid),{...body(uid),start:'2026-10-19'},deps(thursday))),'invalid-argument');
 assert.equal(await code(readStudyWeek(auth(uid),{...body(uid),expectedUid:'other',start:'2026-10-18'},deps(thursday))),'failed-precondition');
});

test('a past day beyond the 14-day mask is read from the stored sessions, never treated as missed',async()=>{
 const old=NOW-30*DAY,oldDay='2026-09-24';
 for(const done of [true,false]){
  const uid='w4b-old-day-'+done;await seed(uid);
  const first=await readStudyRoadmap(auth(uid),body(uid),deps(old));
  assert.equal(first.today.day,oldDay);
  const ids=first.today.newQuestionIds;assert.ok(ids.length>0);
  if(done){
   await recordSession(auth(uid),{...body(uid),sessionId:'old-day-session',origin:'new_questions',startedAt:old-2000,finishedAt:old,durationMs:2000,
    answers:ids.map(questionId=>({questionId,chosen:'a',correct:true}))},deps(old));
  }
  // A recent session moves the mask's anchor 30 days on, so the old day is outside the mask.
  const other=['cse-0-11','cse-1-11'].find(id=>!ids.includes(id));
  await recordSession(auth(uid),{...body(uid),sessionId:'recent-session',origin:'drill',startedAt:NOW-2000,finishedAt:NOW,durationMs:2000,
   answers:[{questionId:other,chosen:'a',correct:true}]},deps());
  const past=await readStudyDay(auth(uid),{...body(uid),date:oldDay},deps());
  assert.equal(past.kind,'past');
  assert.equal(past.remaining.newQuestionIds.length,done?0:ids.length,done?'completion found in the stored session':'no completion exists, so nothing is invented');
 }
});

test('an attributed session without answer times that crosses midnight completes on its finish day',async()=>{
 const uid='w4b-midnight';await seed(uid);
 const finish=Date.parse('2026-10-24T00:05:00+08:00'),start=finish-600000;
 const first=await readStudyRoadmap(auth(uid),body(uid),deps(start));   // Friday 23:55 plan
 assert.equal(first.today.day,'2026-10-23');
 const ids=first.today.newQuestionIds;
 await recordSession(auth(uid),{...body(uid),sessionId:'midnight-session',origin:'new_questions',startedAt:start,finishedAt:finish,durationMs:600000,
  answers:ids.map(questionId=>({questionId,chosen:'a',correct:true}))},deps(finish));
 const friday=await readStudyDay(auth(uid),{...body(uid),date:'2026-10-23'},deps(finish));
 assert.equal(friday.remaining.newQuestionIds.length,ids.length,'completed after midnight, so not completed on Friday');
 const saturday=await readStudyRoadmap(auth(uid),body(uid),deps(finish));
 assert.equal(saturday.today.day,'2026-10-24');
 for(const id of ids)assert.equal(saturday.today.newQuestionIds.includes(id)||saturday.remaining.newQuestionIds.includes(id),false,'seen questions are not new again');
});

async function readyToAdvance(uid,pro=false){
 await seed(uid);if(pro)await trial(uid);
 const first=await readStudyRoadmap(auth(uid),body(uid),deps());
 for(const lessonId of first.today.lessonIds)await db.doc('users/'+uid+'/server/lessonReads/items/'+lessonId).set({lessonId,readAt:NOW});
 const {addSession}=await import('../lib/_answerTotals.js');const totals=emptyTotals();
 addSession(totals,[...first.today.newQuestionIds,...first.today.reviewQuestionIds].map(questionId=>({questionId,chosen:'a',correct:true,answeredAt:NOW})));
 await db.doc('users/'+uid+'/server/answerTotals').set(toDoc(totals));
 const ready=await readStudyRoadmap(auth(uid),body(uid),deps());
 assert.equal(ready.originalDone,true);assert.equal(ready.canAdvance,true);
 return {...body(uid),expectedDay:ready.today.day,expectedRevision:ready.revision};
}
test('concurrent advances with one expected revision have exactly one winner',async()=>{
 const uid='w4b-advance-race',request=await readyToAdvance(uid,true);
 const results=await Promise.allSettled(['advance-race-one','advance-race-two'].map(requestId=>advanceStudyRoadmap(auth(uid),{...request,requestId},deps())));
 assert.equal(results.filter(r=>r.status==='fulfilled').length,1);
 const loser=results.find(r=>r.status==='rejected');assert.equal(loser.reason.code,'failed-precondition');
 assert.equal(loser.reason.message,'Your plan changed. Open it again.');
 assert.equal((await db.collection('users/'+uid+'/server/roadmapAdvances/items').get()).size,1);
 const winner=results.find(r=>r.status==='fulfilled').value;
 assert.deepEqual((await readStudyRoadmap(auth(uid),body(uid),deps())).today,winner.today);
});
test('advance rejects yesterday expectedDay even with today revision',async()=>{
 const uid='w4b-advance-rollover';await readyToAdvance(uid,true);
 const today=await readStudyRoadmap(auth(uid),body(uid),deps(NOW+DAY));
 await assert.rejects(advanceStudyRoadmap(auth(uid),{...body(uid),requestId:'advance-rollover',expectedDay:'2026-10-24',expectedRevision:today.revision},deps(NOW+DAY)),
  {code:'failed-precondition',message:'Your plan changed. Open it again.'});
 assert.equal((await db.collection('users/'+uid+'/server/roadmapAdvances/items').get()).size,0);
});
test('Free can advance completed Today without paid future payloads',async()=>{
 const uid='w4b-free-advance',request=await readyToAdvance(uid);
 const payload={...request,requestId:'free-advance-one'};
 const out=await advanceStudyRoadmap(auth(uid),payload,deps());
 assert.equal(out.proCovered,false);assert.equal(out.tier,'free');assert.ok(out.today.advancedIds.length>0);
 for(const field of ['comingUp','history','digest','topicOrder','weeksAhead'])assert.equal(field in out,false);
 assert.deepEqual((await advanceStudyRoadmap(auth(uid),payload,deps())).today,out.today);
 assert.equal(await code(readStudyDay(auth(uid),{...body(uid),date:'2026-10-25'},deps())),'permission-denied');
});
