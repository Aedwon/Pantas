import test from 'node:test';
import assert from 'node:assert/strict';
const reward = await import('../lib/betaReward.js').catch(e => {
  if (e.code === 'ERR_MODULE_NOT_FOUND') return {};
  throw e;
});
test('Philippine beta, survey and deadline boundaries use exclusive midnight ends', () => {
  assert.equal(typeof reward.manilaDate, 'function');
  for (let day = 9; day <= 16; day++) {
    const at = Date.parse(`2026-11-${String(day).padStart(2, '0')}T00:00:00+08:00`);
    assert.equal(reward.manilaDate(at), `2026-11-${String(day).padStart(2, '0')}`);
    assert.equal(reward.isBetaDay(at), day <= 15);
    assert.equal(reward.isBetaDay(at - 1), day > 9);
  }
  for (const [at, open] of [
    [reward.SURVEY_OPENS_AT - 1, false], [reward.SURVEY_OPENS_AT, true],
    [reward.SURVEY_CLOSES_AT - 1, true], [reward.SURVEY_CLOSES_AT, false],
  ]) assert.equal(reward.isSurveyOpen(at), open);
  assert.equal(reward.ACTIVATION_DEADLINE, Date.parse('2028-01-01T00:00:00+08:00'));
  assert.deepEqual(reward.BETA_DAYS, Array.from({length: 7}, (_, i) => `2026-11-${9+i < 10 ? '0' : ''}${9+i}`));
});
import {fixture, request, uid, feedbackId} from './_beta-helpers.mjs';
const path = `betaFeedback/${uid}/${feedbackId}/0`;
test('feedback stores trimmed text, checked image metadata and stable retry result', async () => {
  assert.equal(typeof reward.sendFeedback, 'function');
  const deps=fixture();
  const req=request({feedbackId,text:' hello ',attachments:[{path,contentType:'image/png'}],userAgent:'test',appVersion:'1',examId:'exam_cse_pro'});
  const result=await reward.sendFeedback(req,deps);
  const saved=deps.rows.get(`users/${uid}/betaFeedback/${feedbackId}`);
  assert.equal(saved.text,'hello'); assert.deepEqual(saved.attachments,[{path,contentType:'image/png',size:10}]);
  deps.metadata=async()=>assert.fail('retries must not check Storage');
  assert.deepEqual(await reward.sendFeedback(req,deps),result);
  assert.deepEqual(result,{feedbackId,createdAt:deps.now()});
});
test('feedback validates text, IDs, metadata fields and attachment ownership before any write',async()=>{
  assert.equal(typeof reward.sendFeedback,'function');
  const valid={feedbackId,text:'hello',attachments:[]};
  for(const change of [{feedbackId:'../bad'},{feedbackId:'x'.repeat(33)},{text:''},{text:' '.repeat(2)},
    {text:'x'.repeat(4001)},{attachments:null},{attachments:[1]}, {userAgent:'x'.repeat(301)},
    {appVersion:'x'.repeat(41)},{examId:4}, {attachments:Array(4).fill({path,contentType:'image/png'})},
    ...['betaFeedback/other/'+feedbackId+'/0',path+'/x',path.replace('/0','/3')].map(path=>({attachments:[{path,contentType:'image/png'}]})),
    {attachments:[{path,contentType:'text/html'}]},
    {attachments:[{path,contentType:'image/png'},{path,contentType:'image/png'}]}]) {
    const deps=fixture(); await assert.rejects(reward.sendFeedback(request({...valid,...change}),deps),{code:'invalid-argument'});
    assert.equal(deps.rows.size,1);
  }
});
test('feedback refuses missing files, MIME mismatch, oversize and invalid sizes; accepts image-only and 5MB',async()=>{
  assert.equal(typeof reward.sendFeedback,'function');
  const req=request({feedbackId,text:'',attachments:[{path,contentType:'image/png'}]});
  for(const metadata of [{contentType:'text/html',size:1},{contentType:'image/jpeg',size:1},
    {contentType:'image/png',size:5*1024*1024+1},{contentType:'image/png',size:'NaN'},
    {contentType:'image/png',size:-1}]) await assert.rejects(reward.sendFeedback(req,{...fixture(),metadata:async()=>metadata}),{code:'invalid-argument'});
  await assert.rejects(reward.sendFeedback(req,{...fixture(),metadata:async()=>{throw Object.assign(new Error('missing'),{code:404});}}),{code:'invalid-argument'});
  await reward.sendFeedback(req,{...fixture(),metadata:async()=>({contentType:'image/png',size:5*1024*1024})});
});
test('feedback guards reject absent or replayed App Check, anonymous, unselected, unverified, rate limit',async()=>{
  assert.equal(typeof reward.sendFeedback,'function');
  const req=request({feedbackId,text:'hello',attachments:[]});
  for(const [change,code] of [[{app:undefined},'unauthenticated'],[{app:{alreadyConsumed:true}},'unauthenticated'],
    [{auth:undefined},'unauthenticated'],[{auth:{...req.auth,token:{firebase:{sign_in_provider:'anonymous'}}}},'permission-denied']]) {
    await assert.rejects(reward.sendFeedback({...req,...change},fixture()),{code});
  }
  await assert.rejects(reward.sendFeedback(req,{...fixture(),allow:async()=>false}),{code:'resource-exhausted'});
  for(const token of [{...req.auth.token,email_verified:false},req.auth.token]) {
    const deps=fixture();deps.rows.clear();
    await assert.rejects(reward.sendFeedback({...req,auth:{...req.auth,token}},deps),{code:'permission-denied'});
  }
});
test('day reporting counts each server Philippine date once and returns days outside the window',async()=>{
  assert.equal(typeof reward.recordDay,'function');
  const deps=fixture(); const req=request({kind:'plan'});
  for(const day of [9,10,11,12,13]) {
    deps.now=()=>Date.parse(`2026-11-${String(day).padStart(2,'0')}T23:59:59.999+08:00`);
    assert.equal((await reward.recordDay(req,deps)).recorded,true);
    assert.equal((await reward.recordDay(request({kind:'restDay'}),deps)).recorded,false);
  }
  const status=await reward.rewardStatus(request(),deps);
  assert.equal(status.days.length,5); assert.equal(status.eligible,false);
  assert.deepEqual(status.betaDays,reward.BETA_DAYS);
  assert.equal(status.surveyOpensAt,reward.SURVEY_OPENS_AT);
  assert.equal(status.surveyClosesAt,reward.SURVEY_CLOSES_AT);
  assert.equal(status.activationDeadline,reward.ACTIVATION_DEADLINE);
  assert.equal(status.activatedAt,null); assert.equal(status.rewardStartsAt,null); assert.equal(status.rewardEndsAt,null);
  for(const at of [Date.parse('2026-11-09T00:00:00+08:00')-1,Date.parse('2026-11-16T00:00:00+08:00')]) {
    deps.now=()=>at; const result=await reward.recordDay(req,deps);
    assert.equal(result.recorded,false);assert.equal(result.reason,'outside');assert.equal(result.days.length,5);
  }
  await assert.rejects(reward.recordDay(request({kind:'other'}),deps),{code:'invalid-argument'});
});
test('status uses distinct valid beta dates for eligibility and requires a survey',async()=>{
  assert.equal(typeof reward.rewardStatus,'function');
  const deps=fixture();const state=`users/${uid}/betaReward/state`;
  deps.rows.set(state,{days:['2026-11-08',...Array(5).fill('2026-11-09')]});
  assert.equal((await reward.rewardStatus(request(),deps)).eligible,false);
  deps.rows.set(state,{days:reward.BETA_DAYS.slice(0,5),surveyAt:deps.now()});
  assert.equal((await reward.rewardStatus(request(),deps)).eligible,true);
  deps.now=()=>reward.ACTIVATION_DEADLINE;
  assert.equal((await reward.rewardStatus(request(),deps)).eligible,false);
});
const answers={usage:'every_day',ease:5,usefulness:4,continue:'yes',recommend:10,improve:' Make it faster ',other:'Thanks'};
test('survey validates every field and accepts only one submission in its window',async()=>{
  assert.equal(typeof reward.submitSurvey,'function');
  for(const change of [{usage:'daily'},{ease:0},{ease:6},{ease:1.5},{ease:'3'},{usefulness:0},{usefulness:6},
    {usefulness:NaN},{continue:'ok'},{recommend:-1},{recommend:11},{recommend:0.5},{improve:''},
    {improve:' '},{improve:'x'.repeat(2001)},{other:3},{other:'x'.repeat(2001)}]) {
    await assert.rejects(reward.submitSurvey(request({answers:{...answers,...change}}),fixture()),{code:'invalid-argument'});
  }
  for(const at of [reward.SURVEY_OPENS_AT-1,reward.SURVEY_CLOSES_AT]) await assert.rejects(
    reward.submitSurvey(request({answers}),fixture(at)),{code:'failed-precondition'});
  for(const at of [reward.SURVEY_OPENS_AT,reward.SURVEY_CLOSES_AT-1]) {
    const deps=fixture(at); assert.deepEqual(await reward.submitSurvey(request({answers}),deps),{submittedAt:at});
    assert.equal(deps.rows.get(`users/${uid}/betaReward/state`).surveyAt,at);
    assert.equal(deps.rows.get(`users/${uid}/betaReward/survey`).answers.improve,'Make it faster');
    await assert.rejects(reward.submitSurvey(request({answers}),deps),{code:'already-exists'});
  }
  for(const usage of ['every_day','most_days','few_days','once']) for(const keep of ['yes','maybe','no']) {
    await reward.submitSurvey(request({answers:{...answers,usage,continue:keep,ease:1,usefulness:1,recommend:0,other:undefined}}),fixture());
  }
});
