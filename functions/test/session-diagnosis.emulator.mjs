import '../lib/index.js';
import * as callables from '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {emptyTotals,addSession,toDoc} from '../lib/_answerTotals.js';
import {clearExamContentCache} from '../lib/_examContent.js';
import {core} from '../lib/_core.js';

const db=getFirestore(),NOW=Date.parse('2026-10-29T10:00:00+08:00'),DAY=86400000,EXAM='exam_cse_pro';
const auth=uid=>({uid,token:{pro:true,proUntil:NOW+DAY}});
const body=uid=>({expectedUid:uid,examId:EXAM,sessionId:'b4-session'});
const deps=()=>({db,now:()=>NOW,allow:async()=>true});
const code=async p=>{try{await p;return 'ok';}catch(e){return e.code??String(e);}};
async function read(...args){
 const module=await import('../lib/sessionDiagnosis.js').catch(()=>({}));
 assert.equal(typeof module.readSessionDiagnosis,'function','B4 diagnosis reader is available');
 return module.readSessionDiagnosis(...args);
}
const note='Check the denominator before adding.';
const answers=[{questionId:'b4-target-q',chosen:'b4-target-q_c',correct:false},
 {questionId:'b4-within-q',chosen:'b4-within-q_b',correct:false},
 {questionId:'b4-correct-q',chosen:'b4-correct-q_a',correct:true},
 {questionId:'b4-blank-q',chosen:null,correct:false}];
async function seed(uid,{pro=false,count=1}={}){
 await db.recursiveDelete(db.doc('users/'+uid));
 clearExamContentCache();
 await db.doc('content/catalog/items/index').delete();
 const lessons=[{id:'b4-target',topic:'b4-topic',title:'Target',ordering:0,prerequisites:[{lesson:'b4-prereq',strength:'helpful'}]},
  {id:'b4-prereq',topic:'b4-topic',title:'Prerequisite',ordering:1},
  {id:'b4-within',topic:'b4-topic',title:'Within',ordering:2},
  {id:'b4-unrelated',topic:'b4-topic',title:'Unrelated',ordering:3}];
 const sets=[{id:'b4-target-set',topic:'b4-topic',lesson:'b4-target',exams:[EXAM],questions:[{id:'b4-target-q'},{id:'b4-correct-q'},{id:'b4-blank-q'}]},
 {id:'b4-prereq-set',topic:'b4-topic',lesson:'b4-prereq',exams:[EXAM],questions:Array.from({length:count},(_,i)=>({id:'b4-prereq-q-'+i}))},
 {id:'b4-within-set',topic:'b4-topic',lesson:'b4-within',exams:[EXAM],questions:[{id:'b4-within-q'}]},
 {id:'b4-unrelated-set',topic:'b4-topic',lesson:'b4-unrelated',exams:[EXAM],questions:Array.from({length:400},(_,i)=>({id:'b4-unrelated-q-'+i}))}];
 await db.doc('content/catalog/items/'+EXAM).set({version:'b4',payload:JSON.stringify({subjects:[{_id:'b4-subject',name:'Subject',exam:EXAM}],topics:[{_id:'b4-topic',name:'Topic',subject:'b4-subject'}],lessons,sets})});
 await db.doc('content/gaps/items/tags').set({payload:JSON.stringify({'b4-target-q':{'b4-target-q_c':'b4-prereq'}})});
 await db.doc('contentPro/b4-target-set').set({payload:JSON.stringify({'b4-target-q':['Wrong note A','Wrong note B',note]})});
 await db.doc('users/'+uid+'/server/settings').set({examId:EXAM,examDate:null,studyDays:[1,2,3,4,5,6,7],assessmentCompleted:true});
 await db.doc('users/'+uid+'/server/answers/items/b4-session').set({sessionId:'b4-session',examId:EXAM,origin:'drill',answers,startedAt:NOW-1000,finishedAt:NOW});
 const totals=emptyTotals();addSession(totals,answers,{startedAt:NOW-1000,finishedAt:NOW});
 await db.doc('users/'+uid+'/server/answerTotals').set(toDoc(totals));
 if(pro)await db.doc('users/'+uid+'/grants/trial').set({source:'trial',product:'web_trial',tier:'civilService',startsAt:NOW-DAY,endsAt:NOW+DAY,state:'active',createdAt:NOW-DAY});
 return {lessons,sets};
}
test('Pro receives full attribution, positions and the chosen authored-position note',async()=>{
 const uid='b4-pro';await seed(uid,{pro:true});
 assert.equal(typeof callables.getSessionDiagnosis,'function');
 assert.deepEqual(await read(auth(uid),body(uid),deps()),{status:'ok',tier:'pro',tracedCount:1,
  traced:[{prerequisite:'b4-prereq',forLesson:'b4-target',via:'gapTag',questions:[{questionId:'b4-target-q',position:1,mistake:note}]}],
  withinLesson:[{lesson:'b4-within',questions:[{questionId:'b4-within-q',position:2}]}]});
});
test('Free receives exactly the whitelist and no fixture identity or note',async()=>{
 const uid='b4-free',fixture=await seed(uid);
 const result=await read(auth(uid),body(uid),deps());
 assert.deepEqual(result,{status:'ok',tier:'free',tracedCount:1});
 const text=JSON.stringify(result);
 const secrets=[...fixture.lessons.map(l=>l.id),...fixture.sets.flatMap(s=>s.questions.map(q=>q.id)),...answers.flatMap(a=>a.chosen?[a.chosen]:[]),note,'Wrong note A','Wrong note B'];
 for(const secret of secrets)assert.equal(text.includes(secret),false,secret);
});
test('missing session returns pending without needing settings or catalog',async()=>{
 const uid='b4-pending';await db.recursiveDelete(db.doc('users/'+uid));
 assert.deepEqual(await read(auth(uid),body(uid),deps()),{status:'pending'});
});
test('wrong exam, foreign account, unauthenticated and throttled requests are refused',async()=>{
 const uid='b4-errors';await seed(uid);
 assert.equal(await code(read(undefined,body(uid),deps())),'unauthenticated');
 assert.equal(await code(read(auth(uid),{...body(uid),expectedUid:'someone-else'},deps())),'failed-precondition');
 assert.equal(await code(read(auth(uid),body(uid),{...deps(),allow:async(u,key)=>{assert.equal(u,uid);assert.equal(key,'getSessionDiagnosis');return false;}})),'resource-exhausted');
 await db.doc('users/'+uid+'/server/answers/items/b4-session').update({examId:'exam_upcat'});
 assert.equal(await code(read(auth(uid),body(uid),deps())),'failed-precondition');
});
test('diagnosis refuses more than 300 involved review documents before reading them',async()=>{
 const uid='b4-bound';await seed(uid,{count:297}); // 3 target + 1 within + 297 prerequisite = 301.
 assert.equal(await code(read(auth(uid),body(uid),deps())),'resource-exhausted');
});

// Wrap the real transaction to count physical reads without replacing their behavior.
function measuredDb(){
 const reads=[],lists=[];
 return {reads,lists,db:new Proxy(db,{get(target,key){
  if(key==='runTransaction')return(fn,...args)=>target.runTransaction(tx=>fn(new Proxy(tx,{get(t,k){
   if(k==='get')return async ref=>{const result=await t.get(ref);if('docs'in result){lists.push(ref.path??ref._queryOptions?.parentPath?.toString());reads.push(...result.docs.map(d=>d.ref.path));}else reads.push(ref.path);return result;};
   if(k==='getAll')return async(...refs)=>{reads.push(...refs.map(r=>r.path));return t.getAll(...refs);};
   const value=t[k];return typeof value==='function'?value.bind(t):value;
  }})),...args);
  const value=target[key];return typeof value==='function'?value.bind(target):value;
 }})};
}
test('diagnosis reads only involved review states, at most 300, and never lists sessions',async()=>{
 const uid='b4-cost';await seed(uid,{pro:true,count:296}); // Exactly 300 involved questions.
 const measured=measuredDb();
 const result=await read(auth(uid),body(uid),{...deps(),db:measured.db});assert.equal(result.tracedCount,1);
 const reviewReads=measured.reads.filter(p=>p.includes('/reviews/items/'));
 assert.equal(reviewReads.length,300);assert.equal(reviewReads.some(p=>p.includes('unrelated')),false);
 // Fixed fixture: session, totals, settings, catalog + optional index, entitlement, one grant, two Pro sets.
 assert.ok(measured.reads.length<=310,JSON.stringify(measured.reads));
 assert.equal(measured.lists.some(p=>p?.includes('/answers/items')),false);
 const freeUid='b4-free-cost';await seed(freeUid);const free=measuredDb();
 await read(auth(freeUid),body(freeUid),{...deps(),db:free.db});
 assert.equal(free.reads.some(p=>p.startsWith('contentPro/')),false);
});
test('solid prerequisites yield zero traced misses and scope exclusions cannot be diagnosed',async()=>{
 const uid='b4-solid';await seed(uid);
 const totals=emptyTotals();for(let i=0;i<5;i++)addSession(totals,[{questionId:'b4-prereq-q-0',chosen:'b4-prereq-q-0_a',correct:true}]);
 await db.doc('users/'+uid+'/server/answerTotals').set(toDoc(totals));
 assert.deepEqual(await read(auth(uid),body(uid),deps()),{status:'ok',tier:'free',tracedCount:0});
 await db.doc('users/'+uid+'/server/settings').update({excludedLessonIds:['b4-prereq']});
 assert.deepEqual(await read(auth(uid),body(uid),deps()),{status:'ok',tier:'free',tracedCount:0});
});

test('pending does not depend on readable gap content',async()=>{
 const uid='b4-pending-gap';await db.recursiveDelete(db.doc('users/'+uid));
 const ref=db.doc('content/gaps/items/tags'),previous=await ref.get();
 await ref.set({payload:'{invalid'});clearExamContentCache();
 try{assert.deepEqual(await read(auth(uid),body(uid),deps()),{status:'pending'});}
 finally{if(previous.exists)await ref.set(previous.data());else await ref.delete();clearExamContentCache();}
});
