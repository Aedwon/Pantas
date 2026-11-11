// The compiled Dart core (roadmap engine and mock sampler) must give the same output as the Dart VM.
// Fixtures: server_dart/fixtures, written by `dart run server_dart/make_fixtures.dart` and
// `dart run server_dart/reference.dart` (the Dart VM side). Rebuild the JS with server_dart/build.sh.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import test from 'node:test';
import vm from 'node:vm';
import {isStale} from '../../server_dart/closure_hash.mjs';

const fixture = name => JSON.parse(readFileSync(new URL(`../../server_dart/fixtures/${name}`, import.meta.url), 'utf8'));
const jsPath = new URL('../src/generated/pantas_core.js', import.meta.url);
const text = readFileSync(jsPath, 'utf8');

test('the generated JS matches the current Dart sources', () => {
  assert.equal(isStale(text), false, 'Run server_dart/build.sh and commit functions/src/generated/pantas_core.js.');
});

test('a changed source hash is reported as stale', () => {
  assert.equal(isStale(text.replace(/source-hash: [0-9a-f]{64}/, `source-hash: ${'0'.repeat(64)}`)), true);
  assert.equal(isStale('// no header\n'), true);
});

test('it loads in a bare V8 context with no browser or Node globals', () => {
  const sandbox = vm.createContext({});
  vm.runInContext(text, sandbox);
  assert.equal(typeof sandbox.pantasBuildRoadmap, 'function');
  assert.equal(typeof sandbox.pantasSampleMock, 'function');
});

createRequire(import.meta.url)(jsPath.pathname);

for (const [fn, scenarios, expected] of [
  ['pantasBuildRoadmap', 'roadmap_scenarios.json', 'roadmap_expected.json'],
  ['pantasSampleMock', 'mock_scenarios.json', 'mock_expected.json'],
  ['pantasSessionDiagnosis', 'diagnosis_scenarios.json', 'diagnosis_expected.json'],
]) {
  const inputs = fixture(scenarios);
  const outputs = fixture(expected);
  for (const [name, input] of Object.entries(inputs)) {
    test(`${fn} ${name} matches the Dart VM byte for byte`, () => {
      assert.equal(globalThis[fn](JSON.stringify(input)), JSON.stringify(outputs[name]));
    });
  }
}

test('the same mock seed gives the same paper and another seed gives another', () => {
  const inputs = fixture('mock_scenarios.json');
  const a = globalThis.pantasSampleMock(JSON.stringify(inputs.two_sections));
  assert.equal(globalThis.pantasSampleMock(JSON.stringify(inputs.two_sections)), a);
  assert.notEqual(globalThis.pantasSampleMock(JSON.stringify(inputs.same_inputs_other_seed)), a);
});

const r1Inputs = () => ({
  ...fixture('roadmap_scenarios.json').planning_rich,
  topics: [{id: 't', authoredIndex: 0, name: 'Topic'}],
  lessons: ['target', 'middle', 'base', 'empty'].map((id, ordering) => ({
    id, topicId: 't', ordering, readAt: id === 'target' ? null : '2026-09-01T08:00:00',
  })),
  questions: ['target', 'middle', 'base'].map(id => ({id: `q-${id}`, topicId: 't', lessonId: id})),
  seenQuestionIds: ['q-base', 'q-middle'], dueReviews: [], scores: {},
  lessonLinks: {target: [{lesson: 'middle', strength: 'required'}], middle: [{lesson: 'base', strength: 'required'}]},
  history: ['base', 'middle'].map(id => ({id: `q-${id}`, answered: 5, recent: [false, false, true]})),
  recall: {'q-base': 0.4, 'q-middle': 0.5}, gapTags: {'q-target_b': 'middle'},
});
const call = (fn, input) => JSON.parse(globalThis[fn](JSON.stringify(input)));

test('R1 inputs detour to the deepest weak prerequisite with a reason', () => {
  const result = call('pantasBuildRoadmap', r1Inputs());
  assert.equal(result.today.lessonIds.includes('target'), false);
  assert.equal(result.today.reviewQuestionIds[0], 'q-base');
  assert.deepEqual(result.today.reasons['q-base'], {kind: 'prerequisite', forLesson: 'target'});
});

test('R1 optional inputs default empty and the retired prerequisites field is ignored', () => {
  const input = r1Inputs();
  for (const key of ['lessonLinks', 'history', 'recall', 'gapTags']) delete input[key];
  const plain = globalThis.pantasBuildRoadmap(JSON.stringify(input));
  input.prerequisites = {t: ['t']};
  assert.equal(globalThis.pantasBuildRoadmap(JSON.stringify(input)), plain);
  assert.equal(call('pantasBuildRoadmap', {...input, assessmentCompleted: false}).today.reasons, undefined);
});

test('session diagnosis exposes exact Free and Pro shapes and preserves answer positions', () => {
  const input = {
    inputs: r1Inputs(), session: {sessionId: 's', answers: [
      {questionId: 'q-target', chosen: 'q-target_b', correct: false},
      {questionId: 'q-base', chosen: null, correct: false},
      {questionId: 'q-base', chosen: 'q-base_b', correct: false},
      {questionId: 'q-middle', chosen: 'q-middle_a', correct: true},
    ]}, notes: {'q-target_b': 'Check the base.'}, includeDetail: false,
  };
  assert.deepEqual(call('pantasSessionDiagnosis', input), {tracedCount: 1});
  assert.deepEqual(call('pantasSessionDiagnosis', {...input, includeDetail: true}), {
    tracedCount: 1,
    traced: [{prerequisite: 'base', forLesson: 'target', via: 'gapTag', questions: [
      {questionId: 'q-target', position: 1, mistake: 'Check the base.'},
    ]}],
    withinLesson: [{lesson: 'base', questions: [{questionId: 'q-base', position: 3}]}],
  });
});

test('the TypeScript loader exposes session diagnosis', async () => {
  const {core} = await import('../lib/_core.js');
  assert.equal(typeof core().sessionDiagnosis, 'function');
});

test('R1 cycles are reported and lessons without questions remain valid', () => {
  const input = r1Inputs();
  input.lessonLinks.base = [{lesson: 'target', strength: 'required'}];
  assert.equal(call('pantasBuildRoadmap', input).cycleDetected, true);
  input.lessonLinks = {target: [{lesson: 'empty', strength: 'required'}]};
  const result = call('pantasBuildRoadmap', input);
  assert.equal(result.cycleDetected, false);
  assert.equal(result.today.lessonIds.includes('target'), true);
});

test('stored plan views carry sorted reasons', () => {
  const plan = {
    day: '2026-09-29', lessonIds: ['target'], reviewQuestionIds: ['q-base'], newQuestionIds: [],
    isMockDay: false, isRestDay: false, advancedIds: [],
    reasons: {target: {kind: 'nextUp'}, 'q-base': {kind: 'prerequisite', forLesson: 'target'}},
  };
  const result = call('pantasRoadmapState', {
    operation: 'snapshotView', snapshot: {plan: {day: plan.day, lessons: plan.lessonIds, reviews: plan.reviewQuestionIds, new: [], mockDay: false, advanced: [], reasons: plan.reasons}, digest: JSON.stringify({examId: 'e', examDate: '', scope: [], content: 'r', assessed: true, mocks: 0}), head: [], state: 'planning'},
    completion: {readLessonIds: [], seenQuestionIds: [], reviewedTodayIds: []},
  });
  assert.deepEqual(result.today.reasons, {'q-base': plan.reasons['q-base'], target: plan.reasons.target});
  assert.deepEqual(result.remaining.reasons, result.today.reasons);
});

test('diagnosis sorts groups and lists questions in answer order', () => {
  const inputs = r1Inputs();
  inputs.questions.push(...['q-z', 'q-a'].map(id => ({id, topicId: 't', lessonId: 'target'})));
  const result = call('pantasSessionDiagnosis', {
    inputs, includeDetail: true, session: {sessionId: 'sorted', answers: [
      {questionId: 'q-target', chosen: 'q-target_b', correct: false},
      {questionId: 'q-middle', chosen: 'q-middle_b', correct: false},
      {questionId: 'q-z', chosen: 'q-z_b', correct: false},
      {questionId: 'q-a', chosen: 'q-a_b', correct: false},
    ]},
  });
  assert.deepEqual(result.traced.map(row => [row.forLesson, row.via]), [
    ['middle', 'requiredWeak'], ['target', 'gapTag'], ['target', 'requiredWeak'],
  ]);
  assert.deepEqual(result.traced[2].questions, [
    {questionId: 'q-z', position: 3}, {questionId: 'q-a', position: 4},
  ]);
});
