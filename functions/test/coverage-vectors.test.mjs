import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import * as policy from '../lib/revenuecatPolicy.js';

const vectors = JSON.parse(readFileSync(new URL('../../test/fixtures/coverage_vectors.json', import.meta.url)));
const period = item => ({...item, endsAt: Date.parse(item.endsAt)});
for (const vector of vectors) {
  test(vector.name, () => {
    assert.equal(typeof policy.coverageAt, 'function', 'shared server coverage rule exists');
    const unknown = [];
    const result = policy.coverageAt({
      at: Date.parse(vector.now),
      subscriptions: vector.subscriptions.map(period),
      promotions: vector.promotions.map(period),
      passes: vector.passes.map(item => ({...period(item), active: item.state === 'active'})),
      nonSubscriptionPurchases: vector.nonSubscriptionPurchases.map(period),
      onUnknown: id => unknown.push(id),
    });
    assert.equal(result.coversExam(vector.examId, vector.examTier), vector.expected.covered);
    assert.equal(result.isUnknown, vector.expected.unknown);
    assert.equal(result.tier, vector.expected.tier);
    if (vector.subscriptions.some(s => s.id === 'pantas_future' && Date.parse(s.endsAt) > Date.parse(vector.now))) {
      assert.deepEqual(unknown, ['pantas_future']);
    }
  });
}

test('AC-7 claims accept only active ledger pass inputs, never purchase history', () => {
  const at = Date.parse('2026-10-07T00:00:00Z');
  const endsAt = at + 86400000;
  const options = {at, appId: 'test-app', firebaseProjectId: 'pantas-prod', sandboxTester: false};
  // Test double for server-owned ledger input. Task 5 supplies its transaction reader.
  const passes = [{examId: 'exam_cse_pro', endsAt, active: true}];
  assert.deepEqual(policy.claimsForRevenueCatAnswer([], {...options, passes}), {pro: true, proUntil: endsAt + 86400000});
  assert.deepEqual(policy.claimsForRevenueCatAnswer([], {...options, passes: [{...passes[0], active: false}]}), {pro: false, proUntil: 0});
});
