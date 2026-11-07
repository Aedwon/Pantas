import assert from 'node:assert/strict';
import test from 'node:test';

import * as warm from '../lib/keepWarm.js';

const names = ['getBetaAccess', 'getRoadmap', 'setExamSettings', 'getWebEntitlement',
  'getMockAvailability', 'getStudyInsights', 'getContent',
  // The study loop: saving a finished quiz or lesson read, the quiz-end diagnosis and
  // Home's "do more today" were cold at 2.5 to 3.4 s on Nov 7.
  'ingestSession', 'recordLessonRead', 'getSessionDiagnosis', 'advanceRoadmap'];
const urls = names.map(name => `https://asia-southeast1-test-project.cloudfunctions.net/${name}`);

test('scheduled warm-up is exported for every five minutes in Singapore', async () => {
  assert.equal(typeof warm.keepCallablesWarm, 'function');
  assert.equal(warm.keepCallablesWarm.__endpoint.scheduleTrigger.schedule, 'every 5 minutes');
  assert.deepEqual(warm.keepCallablesWarm.__endpoint.region, ['asia-southeast1']);
  const endpoints = await import('../lib/index.js');
  assert.equal(endpoints.keepCallablesWarm, warm.keepCallablesWarm);
});

test('all eleven project URLs receive parallel OPTIONS preflights with ten-second timeouts', async t => {
  const calls = [];
  const releases = [];
  const timeouts = [];
  const timeout = AbortSignal.timeout.bind(AbortSignal);
  t.mock.method(AbortSignal, 'timeout', ms => {timeouts.push(ms); return timeout(ms);});
  const pending = warm.warmCallables(true, 'test-project', (url, options) => {
    calls.push({url, options});
    return new Promise(resolve => releases.push(() => resolve({ok: true, status: 204})));
  });
  try {
    assert.deepEqual(calls.map(call => call.url), urls);
    assert.deepEqual(timeouts, names.map(() => 10000));
    for (const {options} of calls) {
      assert.equal(options.method, 'OPTIONS');
      assert.deepEqual(options.headers, {
        Origin: 'https://app.pantas.study',
        'Access-Control-Request-Method': 'POST',
      });
      assert.ok(options.signal instanceof AbortSignal);
    }
  } finally {
    releases.forEach(release => release());
    await pending;
  }
});

test('disabled warm-up makes no requests', async () => {
  await warm.warmCallables(false, undefined, () => assert.fail('warm-up is disabled'));
});

test('failed targets log one warning for the run and never throw', async t => {
  const warnings = [];
  const calls = [];
  t.mock.method(process.stderr, 'write', message => {warnings.push(JSON.parse(String(message))); return true;});
  await assert.doesNotReject(warm.warmCallables(true, 'test-project', async url => {
    calls.push(url);
    if (url.endsWith('/getRoadmap')) throw new Error('network unavailable');
    return {ok: !url.endsWith('/getContent'), status: url.endsWith('/getContent') ? 503 : 204};
  }));
  assert.deepEqual(calls, urls);
  assert.equal(warnings.length, 1);
  assert.equal(warnings[0].severity, 'WARNING');
  assert.deepEqual(warnings[0].failedTargets, [urls[1], urls[6]]);
});

test('missing project logs once without making requests or throwing', async t => {
  const warnings = [];
  t.mock.method(process.stderr, 'write', message => {warnings.push(JSON.parse(String(message))); return true;});
  await assert.doesNotReject(warm.warmCallables(true, undefined, () => assert.fail('project is missing')));
  assert.equal(warnings.length, 1);
  assert.equal(warnings[0].severity, 'WARNING');
});
