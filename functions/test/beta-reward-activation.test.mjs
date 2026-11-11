import test from 'node:test';
import assert from 'node:assert/strict';
import * as reward from '../lib/betaReward.js';
import {coverageAt} from '../lib/revenuecatCoverage.js';
import {fixture, request, uid} from './_beta-helpers.mjs';
const state = `users/${uid}/betaReward/state`;
const ready = () => {const d=fixture();d.rows.set(state,{days:reward.BETA_DAYS.slice(0,5),surveyAt:d.now()});return d;};
test('activation requires five days, survey and deadline, but retries return the saved aggregate',async()=>{
 assert.equal(typeof reward.activateReward,'function');
 for(const row of [{days:reward.BETA_DAYS},{days:reward.BETA_DAYS.slice(0,4),surveyAt:1}]) {
  const d=ready();d.rows.set(state,row);await assert.rejects(reward.activateReward(request(),d),{code:'failed-precondition'});
 }
 const d=ready();d.now=()=>reward.ACTIVATION_DEADLINE;
 await assert.rejects(reward.activateReward(request(),d),{code:'failed-precondition'});
 const ok=ready();const result=await reward.activateReward(request(),ok);
 assert.equal(result.exams,18);assert.equal(result.startsAt,ok.now());
 ok.now=()=>reward.ACTIVATION_DEADLINE;
 assert.deepEqual(await reward.activateReward(request(),ok),result);
});
test('rewards queue per exam and cover NCE separately, ignoring beta and unrelated tier or exam coverage',async()=>{
 assert.equal(typeof reward.activateReward,'function');
 const d=ready(), now=d.now(), paidEnd=now+86400000;
 const grant=(tier,examId,source='trial')=>({source,product:'web_trial',tier,examId,startsAt:now-1,endsAt:paidEnd,state:'active',createdAt:now});
 d.rows.set(`users/${uid}/grants/paid`,grant('civilService'));
 d.rows.set(`users/${uid}/grants/beta`,{...grant('nce','exam_pshs_nce','beta'),endsAt:paidEnd+86400000});
 const result=await reward.activateReward(request(),d);
 const grants=[...d.rows].filter(([p])=>p.includes('/grants/beta_reward_')).map(([,g])=>g);
 assert.equal(grants.length,18);
 assert.equal(grants.find(g=>g.examId==='exam_cse_pro').startsAt,paidEnd);
 assert.equal(grants.find(g=>g.examId==='exam_pshs_nce').startsAt,now);
 assert.equal(grants.find(g=>g.examId==='exam_let').startsAt,now);
 assert.equal(result.startsAt,now);assert.equal(result.endsAt,Date.parse('2027-11-16T12:00:00+08:00'));
 const live=coverageAt({at:paidEnd,grants:grants.map(g=>({...g,active:true}))});
 for(const g of grants) assert.equal(live.coversExam(g.examId,g.tier),true);
 assert.equal(live.coversExam('future_exam','student'),false);
 assert.equal(reward.calendarYearEnd(Date.parse('2028-02-29T12:00:00+08:00')),Date.parse('2029-02-28T12:00:00+08:00'));
});
test('NCE and exam passes queue only matching coverage and revoked or future grants do not queue',async()=>{
 const d=ready(), now=d.now(), end=now+123456;
 const row={source:'trial',product:'web_trial',tier:'nce',startsAt:now-1,endsAt:end,state:'active',createdAt:now};
 d.rows.set(`users/${uid}/grants/nce`,row);
 d.rows.set(`users/${uid}/grants/pass`,{...row,source:'paymongo',product:'pantas_pass_cse_pro',examId:'exam_cse_pro',tier:'civilService'});
 d.rows.set(`users/${uid}/grants/revoked`,{...row,tier:'licensure',state:'revoked',endsAt:end+999});
 d.rows.set(`users/${uid}/grants/future`,{...row,tier:'licensure',startsAt:now+1,endsAt:end+999});
 await reward.activateReward(request(),d);
 const get=id=>d.rows.get(`users/${uid}/grants/beta_reward_${id}`);
 assert.equal(get('exam_pshs_nce').startsAt,end);
 assert.equal(get('exam_cse_pro').startsAt,end);
 assert.equal(get('exam_cse_sub').startsAt,now);
 assert.equal(get('exam_upcat').startsAt,now);
});
