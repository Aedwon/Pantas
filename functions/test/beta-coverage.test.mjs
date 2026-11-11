import {test} from 'node:test';
import assert from 'node:assert/strict';
import {coverageAt} from '../lib/revenuecatCoverage.js';
import {claimsForRevenueCatAnswer} from '../lib/revenuecatPolicy.js';
import {planGrant} from '../lib/paymongoGrants.js';
import {webProduct} from '../lib/paymongoPolicy.js';
const end = Date.parse('2026-11-16T00:00:00+08:00');
const at = end - 1000;
const beta = {source:'beta', product:'beta_pro', tier:'civilService', examId:'exam_cse_pro', startsAt:at, endsAt:end, active:true, state:'active'};
const options = {appId:'',firebaseProjectId:'demo-pantas-test',sandboxTester:false,at,grants:[beta]};
test('beta covers only its exam and stops at its exact end', () => {
  const coverage = coverageAt(options);
  assert.equal(coverage.coversExam(beta.examId,'civilService'),true);
  assert.equal(coverage.coversExam('exam_cse_sub','civilService'),false);
  assert.equal(coverageAt({...options,at:end}).hasKnownCoverage,false);
});
test('beta claims have no grace; trial and paid claims retain one day', () => {
  assert.deepEqual(claimsForRevenueCatAnswer([],options),{pro:true,proUntil:end});
  for (const grant of [{...beta,source:'trial',product:'web_trial'}, {...beta,source:'paymongo',product:'pantas_cs_monthly'}]) {
    assert.equal(claimsForRevenueCatAnswer([],{...options,grants:[grant]}).proUntil,end+86400000);
    assert.equal(claimsForRevenueCatAnswer([],{...options,grants:[beta,grant]}).proUntil,end+86400000);
  }
});
test('purchases queue behind beta only until its end', () => {
  assert.equal(planGrant(webProduct('pantas_cs_monthly'),[beta],at,[]).startsAt,end);
  assert.equal(planGrant(webProduct('pantas_cs_monthly'),[beta],end+1,[]).startsAt,end+1);
});
test('a prepaid grant connected after beta keeps its ordinary grace', () => {
  const queued={...beta,source:'paymongo',product:'pantas_cs_monthly',startsAt:end,endsAt:end+86400000};
  assert.equal(claimsForRevenueCatAnswer([],{...options,grants:[beta,queued]}).proUntil,end+2*86400000);
});
test('beta server config defaults off, ends exactly, and cannot exceed the approved cutoff', async () => {
  const {betaProUntil}=await import('../lib/betaPro.js');
  const saved=process.env.BETA_PRO_UNTIL;
  try {
    delete process.env.BETA_PRO_UNTIL; assert.equal(betaProUntil(at),null);
    process.env.BETA_PRO_UNTIL='invalid'; assert.equal(betaProUntil(at),null);
    process.env.BETA_PRO_UNTIL='2026-11-16T00:00:00+08:00';
    assert.equal(betaProUntil(at),end); assert.equal(betaProUntil(end),null);
    process.env.BETA_PRO_UNTIL='2027-01-01T00:00:00+08:00'; assert.equal(betaProUntil(at),end);
  } finally { if(saved===undefined) delete process.env.BETA_PRO_UNTIL; else process.env.BETA_PRO_UNTIL=saved; }
});
