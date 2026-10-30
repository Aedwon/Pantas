import {enforceAppCheck} from './_appCheck.js';
import {createHash} from 'node:crypto';
import {getFirestore, type Firestore, type Transaction} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {allowAtMost} from './_limits.js';
import {core} from './_core.js';
import type {Answer} from './_answers.js';
import {loadStudyContent} from './_examContent.js';
import {phDay, phStamp} from './_phDate.js';
import {mockCoverage} from './mockAccess.js';
import {assertStudyOwner} from './studyObservations.js';
import {readEntitlementInputs} from './entitlementInputs.js';
import {ledgerGrants} from './grants.js';
import {coverageAt, type PriceTier} from './revenuecatCoverage.js';
import {examCatalog, livePasses} from './revenuecatPasses.js';
import {coverageForRevenueCatAnswer, type RevenueCatAccessSource} from './revenuecatPolicy.js';

type Auth={uid:string;token?:object}|undefined;
type Deps={db:Firestore;now?:()=>number;allow?:(uid:string,key:string)=>Promise<boolean>};
type ObservedItem=Answer&{topicId?:string;lessonId?:string|null;subjectName?:string};
type Attempt={examId:string;origin:string;startedAt:string;finishedAt:string;items:ObservedItem[]};
type StoredSession={examId:string;origin:string;startedAt:number;finishedAt:number;answers:Answer[]};
type StoredMock={examId:string;endedBy:string;startedAt:number;submittedAt:number;durationMs:number;limitMs:number;
 answers:Answer[];paper:{sections:{questions:{id:string}[]}[]};score:{correct:number;total:number}};
type Count={correct:number;answered:number};
type PerformanceRow=Count&{id:string;title:string;parentId:string};
type Performance={overall:Count;subjects:(Count&{id:string;title:string;topicCount:number})[];
 lessonLevelAvailable:boolean;topics:PerformanceRow[];lessons:PerformanceRow[];
 topicDetails:(Count&{id:string;title:string;subject:string;lessons:{id:string;title:string;read:boolean}[]})[]};
type Finding={unmetRequirements:string[];confidence:'early'|'forming'|'clear';value:Record<string,number>|null};
type Insights={profile:{id:string}|null;tendencies:Record<'pressure'|'stamina'|'study'|'speed'|'memory',Finding>;
 whenYouWork:{peakHour:number;averageMinutes:number;sessionCount:number}|null};
const bad=(message:string)=>new HttpsError('invalid-argument',message);
const tiers:Record<string,PriceTier>={'Student':'student','Civil Service':'civilService','Licensure':'licensure','PSHS-NCE':'nce'};
async function actualTrial(tx:Transaction,db:Firestore,uid:string,examId:string,now:number):Promise<number|null>{
 const inputs=await readEntitlementInputs(tx,db,uid);
 const tier=tiers[String((examCatalog.find(e=>e.id===examId) as {priceTier?:string}|undefined)?.priceTier)];
 if(!tier)return null;
 const grants=[...inputs.grants.values()];
 const trials=grants.filter(g=>g.source==='trial'&&g.state==='active'&&g.startsAt<=now&&g.endsAt>now&&
  coverageAt({at:now,grants:ledgerGrants([g])}).coversExam(examId,tier));
 if(!trials.length)return null;
 const end=Math.max(...trials.map(g=>g.endsAt));
 const paid=grants.filter(g=>g.source!=='trial'&&g.state==='active'&&g.startsAt<=end&&g.endsAt>now);
 const facts=inputs.record.get('facts') as {sources?:RevenueCatAccessSource[];coverageContext?:{appId:string;firebaseProjectId:string;sandboxTester:boolean}}|undefined;
 const context=facts?.coverageContext??{appId:'',firebaseProjectId:process.env.GCLOUD_PROJECT??'',sandboxTester:false};
 const coveredAt=(at:number)=>coverageForRevenueCatAnswer(facts?.sources??[],{...context,at,
  passes:livePasses(inputs.passes),grants:ledgerGrants(paid)}).coversExam(examId,tier);
 return coveredAt(now)||coveredAt(end)?null:end;
}
export async function readStudyInsights(auth:Auth,data:unknown,deps:Deps){
 if(!auth)throw new HttpsError('unauthenticated','Sign in is required.');
 if(!data||typeof data!=='object'||Array.isArray(data))throw bad('Send an object.');
 const body=data as Record<string,unknown>;assertStudyOwner(auth.uid,body);
 const examId=body.examId;
 if(typeof examId!=='string'||!examCatalog.some(e=>e.id===examId))throw bad('Unknown exam.');
 const now=(deps.now??Date.now)();
 if(!await(deps.allow??((uid,key)=>allowAtMost(uid,key,600,3600000)))(auth.uid,'getStudyInsights'))throw new HttpsError('resource-exhausted','Too many attempts. Try again later.');
 return deps.db.runTransaction(async tx=>{
  const cacheRef=deps.db.doc('users/'+auth.uid+'/server/studyInsights');
  const [content,totalDoc,observationRevision,cache,access,settings,trialEndsAt]=await Promise.all([
   loadStudyContent(deps.db,examId,tx),
   tx.get(deps.db.doc('users/'+auth.uid+'/server/answerTotals')),
   tx.get(deps.db.doc('users/'+auth.uid+'/server/studyRevision')),tx.get(cacheRef),
   mockCoverage(tx,deps.db,auth.uid,now),tx.get(deps.db.doc('users/'+auth.uid+'/server/settings')),
   actualTrial(tx,deps.db,auth.uid,examId,now),
  ]);
  if(settings.exists&&settings.get('examId')!==examId)throw new HttpsError('failed-precondition','Your exam changed. Open this screen again.');
  const pro=access.coversExam(examId),topicOf=new Map(content.topics.map(t=>[t.id,t]));
  const sourceRevision=JSON.stringify([examId,content.revision,totalDoc.get('sessions')??0,observationRevision.get('value')??0,phDay(now),'topic-details-v3-unmet-requirements']);
  const response=(derived:Insights,performance:Performance,revision:string)=>{
   const {topics,lessons,topicDetails,...visible}=performance;
   return{examId:examId,serverNow:now,accessRecheckAt:access.recheckAt,proCovered:pro,revision,trialEndsAt,
    profile:derived.profile,performance:{...visible,...(pro?{topics,lessons,topicDetails}:{})},
    ...(pro?{tendencies:derived.tendencies,whenYouWork:derived.whenYouWork}:{})};
  };
  if(cache.exists&&cache.get('sourceRevision')===sourceRevision&&Number(cache.get('validUntil'))>now){
   return response(JSON.parse(String(cache.get('derivedJson'))) as Insights,JSON.parse(String(cache.get('performanceJson'))) as Performance,String(cache.get('revision')));
  }
  const[answers,mocks,reads,reviews]=await Promise.all([
   tx.get(deps.db.collection('users/'+auth.uid+'/server/answers/items')),
   tx.get(deps.db.collection('users/'+auth.uid+'/server/mocks/items').where('submittedAt','>',0)),
   tx.get(deps.db.collection('users/'+auth.uid+'/server/lessonReads/items')),
   tx.get(deps.db.collection('users/'+auth.uid+'/server/reviews/items')),
  ]);
  const subjectOf=new Map(content.subjects.map(s=>[s.id,s])),questionOf=new Map(content.questions.map(q=>[q.id,q]));
  const item=(a:Answer):ObservedItem=>{const q=questionOf.get(String(a.questionId)),topic=q?topicOf.get(q.topicId):undefined;
   return {...a,...(q?{topicId:q.topicId,lessonId:q.lessonId}:{}),...(topic?{subjectName:subjectOf.get(topic.subjectId)?.name}:{})};};
  const attempts:Attempt[]=answers.docs.filter(d=>d.get('examId')===examId&&typeof d.get('origin')==='string').map(d=>{
   const r=d.data() as StoredSession;return {...r,startedAt:phStamp(Number(r.startedAt)),finishedAt:phStamp(Number(r.finishedAt)),items:r.answers.map(item)};
  });
  const quizOrigins=new Set(['today_topic','today_interleaved','new_questions','drill','flagged','retake','inline']);
  const sessions=attempts.filter(r=>quizOrigins.has(String(r.origin))).map(r=>({...r,total:r.items.length,correct:r.items.filter((a:ObservedItem)=>a.correct).length}));
  const mockRows=mocks.docs.filter(d=>d.get('examId')===examId).map(d=>{
   const r=d.data() as StoredMock,byId=new Map(r.answers.map(a=>[a.questionId,a]));
   const ids=r.paper.sections.flatMap(s=>s.questions.map(q=>q.id));
   return {examId:examId,status:r.endedBy==='student'?'completed':'forfeited',startedAt:phStamp(Number(r.startedAt)),
    submittedAt:phStamp(Number(r.submittedAt)),durationMs:r.durationMs,limitMs:r.limitMs,
    scoreRaw:r.score.correct,scoreTotal:r.score.total,
    items:ids.map(id=>item(byId.get(id)??{questionId:id,chosen:null,correct:false}))};
  });
  const lessonRows=reads.docs.flatMap(d=>{const l=content.lessons.find(l=>l.id===d.get('lessonId'));return l?[{examId:examId,topicId:l.topicId,readAt:phStamp(Number(d.get('readAt')))}]:[];});
  const reviewRows=reviews.docs.map(d=>JSON.parse(String(d.get('stateJson'))));
  const input={examId:examId,now:phStamp(now),sessions,attempts,mocks:mockRows,lessons:lessonRows,reviews:reviewRows,topics:content.topics};
  const revision=createHash('sha256').update(JSON.stringify(input)).digest('hex');
  const derived=JSON.parse(core().studyInsights(JSON.stringify(input))) as Insights;
  const counts=new Map<string,{correct:number;answered:number}>();
  for(const r of attempts)for(const a of r.items){
   const q=questionOf.get(a.questionId);if(!q)continue;
   const c=counts.get(q.id)??{correct:0,answered:0};c.answered++;if(a.correct)c.correct++;counts.set(q.id,c);
  }
  const sum=(ids:string[])=>ids.reduce((total,id)=>{const c=counts.get(id);return{correct:total.correct+(c?.correct??0),answered:total.answered+(c?.answered??0)};},{correct:0,answered:0});
  const topics=content.topics.map(t=>({id:t.id,title:t.name,parentId:t.subjectId,...sum(content.questions.filter(q=>q.topicId===t.id).map(q=>q.id))})).filter(t=>t.answered>0);
  const lessons=content.lessons.map(l=>({id:l.id,title:l.title,parentId:l.topicId,...sum(content.questions.filter(q=>q.lessonId===l.id).map(q=>q.id))})).filter(l=>l.answered>0);
  const subjects=content.subjects.map(s=>({id:s.id,title:s.name,...sum(content.questions.filter(q=>topicOf.get(q.topicId)?.subjectId===s.id).map(q=>q.id)),topicCount:topics.filter(t=>t.parentId===s.id).length})).filter(s=>s.answered>0);
  const readIds=new Set(reads.docs.filter(d=>Number.isFinite(Number(d.get('readAt')))&&Number(d.get('readAt'))<=now).map(d=>String(d.get('lessonId'))));
  const topicDetails=content.topics.map(t=>({id:t.id,title:t.name,subject:subjectOf.get(t.subjectId)!.name,
   ...sum(content.questions.filter(q=>q.topicId===t.id).map(q=>q.id)),
   lessons:content.lessons.filter(l=>l.topicId===t.id).map(l=>({id:l.id,title:l.title,read:readIds.has(l.id)}))}));
  const performance={topicDetails,overall:sum(content.questions.map(q=>q.id)),subjects,lessonLevelAvailable:content.questions.some(q=>q.lessonId!==null),topics,lessons};
  // Cache authority never includes tier: every response rechecks current coverage.
  const nextDay=Date.parse(phDay(now)+'T00:00:00+08:00')+86400000;
  const futureTimes=[...answers.docs.flatMap(d=>[Number(d.get('startedAt')),Number(d.get('finishedAt'))]),
    ...mocks.docs.map(d=>Number(d.get('submittedAt'))),...reads.docs.map(d=>Number(d.get('readAt')))].filter(at=>at>now);
  tx.set(cacheRef,{examId:examId,sourceRevision,revision,computedAt:now,
   validUntil:Math.min(nextDay,...futureTimes),derivedJson:JSON.stringify(derived),performanceJson:JSON.stringify(performance)});
  return response(derived,performance,revision);
 });
}
export const getStudyInsights=onCall({region:'asia-southeast1',enforceAppCheck: enforceAppCheck},r=>readStudyInsights(r.auth,r.data,{db:getFirestore()}));
