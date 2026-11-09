import assert from 'node:assert/strict';
import test from 'node:test';
import {CUSTOM_EXAM_ID, MAX_CUSTOM_TRACKS, checkCustomBlock, checkCustomBlueprint, customTrackRef, inCustomCorpus,
  isCustomExamId, isStudyExamId} from '../lib/_customTrack.js';

const UUID = '0a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d';
const NOW = Date.UTC(2026, 10, 4);
const DAY = 86_400_000;

// ---- identity -----------------------------------------------------------------------------------
test('a custom id is exam_custom_ plus a lowercase version 4 uuid', () => {
  assert.equal(isCustomExamId(`exam_custom_${UUID}`), true);
  for (const variant of ['a', 'b', '8', '9']) assert.equal(isCustomExamId(`exam_custom_0a1b2c3d-4e5f-4a6b-${variant}c7d-9e0f1a2b3c4d`), true);
  assert.ok(CUSTOM_EXAM_ID.test(`exam_custom_${UUID}`));
});

test('bare, uppercase, other-version and padded ids are not custom ids', () => {
  for (const id of ['exam_custom', 'exam_custom_', `exam_custom_${UUID.toUpperCase()}`, `exam_custom_${UUID.replace('-4a6b', '-1a6b')}`,
    `exam_custom_${UUID.replace('-8c7d', '-0c7d')}`, `exam_custom_${UUID}x`, ` exam_custom_${UUID}`, `exam_custom_${UUID}\n`,
    `exam_custom_${UUID.slice(1)}`, `exam_custom_${UUID}/x`, `custom_${UUID}`, `exam_upcat`]) {
    assert.equal(isCustomExamId(id), false, JSON.stringify(id));
  }
  for (const value of [undefined, null, 7, {}, [`exam_custom_${UUID}`]]) assert.equal(isCustomExamId(value), false);
});

test('a study exam id is a listed exam or a custom id', () => {
  assert.equal(isStudyExamId('exam_cse_pro'), true);
  assert.equal(isStudyExamId(`exam_custom_${UUID}`), true);
  for (const id of ['exam_custom', 'exam_nope', '', undefined, null, 4]) assert.equal(isStudyExamId(id), false);
});

test('the track document lives under the signed-in account, beside the mocks', () => {
  const paths = [];
  const db = {doc: path => { paths.push(path); return {path}; }};
  assert.equal(customTrackRef(db, 'u1', `exam_custom_${UUID}`).path, `users/u1/server/customTracks/items/exam_custom_${UUID}`);
  assert.equal(MAX_CUSTOM_TRACKS, 50);
});

test('the whole corpus is in every custom exam for now', () => {
  assert.equal(inCustomCorpus({id: 'qs-any', exams: []}), true);
  assert.equal(inCustomCorpus({id: 'qs-any', exams: ['exam_upcat']}), true);
});

// ---- blueprint ----------------------------------------------------------------------------------
const section = (n, extra = {}) => ({id: `section_${n}`, name: `Part ${n}`, questionCount: 10, suggestedMinutes: 20, topicIds: ['topic_upcat_algebra'], ...extra});
const blueprint = (sections = [section(1), section(2)], extra = {}) => ({
  sectionsJson: JSON.stringify(sections),
  totalQuestions: sections.reduce((n, s) => n + s.questionCount, 0),
  totalMinutes: sections.reduce((n, s) => n + s.suggestedMinutes, 0),
  sectionsTimedSeparately: false, updatedAt: NOW - 1000, ...extra,
});
const refuses = (value, now = NOW) => assert.throws(() => checkCustomBlueprint(value, now), error => {
  assert.equal(error.code, 'invalid-argument');
  assert.equal(error.message, 'Bad mock setup.');
  return true;
});

test('a good blueprint is returned with the same numbers and a cleaned section list', () => {
  const sent = blueprint();
  const clean = checkCustomBlueprint(sent, NOW);
  assert.deepEqual({...clean, sectionsJson: undefined}, {...sent, sectionsJson: undefined});
  assert.deepEqual(JSON.parse(clean.sectionsJson), JSON.parse(sent.sectionsJson));
});

test('topicWeights are removed from every section and nothing else is', () => {
  const sections = [section(1, {topicWeights: {topic_upcat_algebra: 1}, shuffle: true}), section('all', {topicWeights: {}})];
  const clean = checkCustomBlueprint(blueprint(sections), NOW);
  assert.deepEqual(JSON.parse(clean.sectionsJson), [section(1), section('all')]);
  assert.equal(clean.sectionsJson.includes('topicWeights'), false);
});

test('the input is not changed', () => {
  const sent = blueprint([section(1, {topicWeights: {a: 1}}), section(2)]);
  const before = JSON.stringify(sent);
  checkCustomBlueprint(sent, NOW);
  assert.equal(JSON.stringify(sent), before);
});

test('the blueprint must be an object with a string section list', () => {
  for (const value of [undefined, null, 'x', 5, [], blueprint([]), {...blueprint(), sectionsJson: 7}, {...blueprint(), sectionsJson: '{'},
    {...blueprint(), sectionsJson: '{}'}, {...blueprint(), sectionsJson: 'null'}, {...blueprint(), sectionsJson: '[1]'},
    {...blueprint(), sectionsJson: '[null]'}, {...blueprint(), sectionsJson: '[[]]'}]) refuses(value);
});

test('sectionsJson is at most 64,000 bytes and 1 to 20 sections', () => {
  const sections = Array.from({length: 20}, (_, i) => section(i + 1, {questionCount: 5, suggestedMinutes: 5}));
  assert.doesNotThrow(() => checkCustomBlueprint(blueprint(sections), NOW));
  refuses(blueprint([...sections, section(21, {questionCount: 5, suggestedMinutes: 5})]));
  const wide = section(1, {name: 'x'.repeat(80), padding: 'y'.repeat(64_000)});
  refuses(blueprint([wide]));
  const edge = JSON.stringify([section(1)]);
  const pad = 64_000 - Buffer.byteLength(edge) - ',"p":""'.length;
  const exact = JSON.stringify([section(1, {p: 'z'.repeat(pad)})]);
  assert.equal(Buffer.byteLength(exact), 64_000);
  assert.doesNotThrow(() => checkCustomBlueprint({...blueprint([section(1)]), sectionsJson: exact}, NOW));
  refuses({...blueprint([section(1)]), sectionsJson: exact.replace('"p":"', '"p":"z')});
});

test('a section id is unique and is section_all or section_ plus up to three digits', () => {
  for (const id of ['section_all', 'section_1', 'section_999', 'section_007']) {
    assert.doesNotThrow(() => checkCustomBlueprint(blueprint([section(1, {id})]), NOW), id);
  }
  for (const id of ['section_', 'section_1000', 'section_ALL', 'section_a', 'Section_1', 'section_1 ', '', 'section-1', 7, null]) {
    refuses(blueprint([section(1, {id})]));
  }
  refuses(blueprint([section(1), section(2, {id: 'section_1'})]));
});

test('a section name is a non-empty string up to 80 characters', () => {
  assert.doesNotThrow(() => checkCustomBlueprint(blueprint([section(1, {name: 'x'.repeat(80)})]), NOW));
  for (const name of ['', 'x'.repeat(81), 5, null, undefined]) refuses(blueprint([section(1, {name})]));
});

test('questionCount is an integer from 1 to 300 and the total equals the sum', () => {
  assert.doesNotThrow(() => checkCustomBlueprint(blueprint([section(1, {questionCount: 300})]), NOW));
  for (const questionCount of [0, 301, -1, 1.5, '5', null, NaN]) refuses({...blueprint([section(1)]), sectionsJson: JSON.stringify([section(1, {questionCount})])});
  refuses({...blueprint(), totalQuestions: 21});
  refuses({...blueprint(), totalQuestions: 19});
  refuses({...blueprint(), totalQuestions: '20'});
  const over = [section(1, {questionCount: 200}), section(2, {questionCount: 101})];
  refuses(blueprint(over));
  refuses({...blueprint([section(1)]), totalQuestions: 0, sectionsJson: JSON.stringify([section(1, {questionCount: 0})])});
});

test('suggestedMinutes is an integer from 1 to 720 and totalMinutes is an integer from 1 to 720', () => {
  assert.doesNotThrow(() => checkCustomBlueprint(blueprint([section(1, {suggestedMinutes: 720})]), NOW));
  for (const suggestedMinutes of [0, 721, -5, 2.5, '20', null]) refuses({...blueprint(), sectionsJson: JSON.stringify([section(1, {suggestedMinutes}), section(2)])});
  for (const totalMinutes of [0, 721, 1.5, '40', null, undefined, -1]) refuses({...blueprint(), totalMinutes});
  assert.doesNotThrow(() => checkCustomBlueprint({...blueprint(), totalMinutes: 720}, NOW), 'untimed totalMinutes need not equal the sum');
});

test('topicIds is 1 to 64 identifiers', () => {
  const ids = n => Array.from({length: n}, (_, i) => `topic_upcat_${i}`);
  assert.doesNotThrow(() => checkCustomBlueprint(blueprint([section(1, {topicIds: ids(64)})]), NOW));
  for (const topicIds of [[], ids(65), 'topic_a', null, undefined, [7], ['bad id'], ['a/b'], [''], ['x'.repeat(161)], [null]]) {
    refuses(blueprint([section(1, {topicIds})]));
  }
  assert.doesNotThrow(() => checkCustomBlueprint(blueprint([section(1, {topicIds: ['x'.repeat(160)]})]), NOW));
});

test('separate timing needs at least two sections and totalMinutes equal to the sum', () => {
  const two = [section(1, {suggestedMinutes: 30}), section(2, {suggestedMinutes: 45})];
  const timed = (sections, totalMinutes, flag = true) => ({...blueprint(sections), totalMinutes, sectionsTimedSeparately: flag});
  assert.doesNotThrow(() => checkCustomBlueprint(timed(two, 75), NOW));
  refuses(timed(two, 74));
  refuses(timed(two, 76));
  refuses(timed([section(1, {suggestedMinutes: 30})], 30));
  assert.doesNotThrow(() => checkCustomBlueprint(timed([section(1, {suggestedMinutes: 30})], 30, false), NOW));
  assert.doesNotThrow(() => checkCustomBlueprint(timed(two, 10, false), NOW), 'not separate: only the 1 to 720 range applies');
  for (const flag of ['true', 1, null, undefined]) refuses({...timed(two, 75), sectionsTimedSeparately: flag});
});

test('updatedAt is a safe integer and at most a day ahead of the server', () => {
  assert.doesNotThrow(() => checkCustomBlueprint({...blueprint(), updatedAt: NOW + DAY}, NOW));
  assert.doesNotThrow(() => checkCustomBlueprint({...blueprint(), updatedAt: 0}, NOW));
  for (const updatedAt of [NOW + DAY + 1, 1.5, NaN, Infinity, '5', null, undefined, Number.MAX_SAFE_INTEGER + 1]) refuses({...blueprint(), updatedAt});
});

// ---- the block that rides on setExamSettings -----------------------------------------------------
const refusesBlock = value => assert.throws(() => checkCustomBlock(value, NOW), error => {
  assert.equal(error.code, 'invalid-argument');
  return true;
});

test('an absent block is allowed and means nothing was sent', () => {
  assert.deepEqual(checkCustomBlock(undefined, NOW), {});
  assert.deepEqual(checkCustomBlock(null, NOW), {});
  assert.deepEqual(checkCustomBlock({}, NOW), {});
});

test('a name is trimmed and cut to 80 characters, never refused for length', () => {
  assert.deepEqual(checkCustomBlock({name: '  My exam  '}, NOW), {name: 'My exam'});
  assert.equal(checkCustomBlock({name: 'x'.repeat(500)}, NOW).name.length, 80);
  assert.equal(checkCustomBlock({name: ' ' + 'y'.repeat(100)}, NOW).name, 'y'.repeat(80));
  assert.deepEqual(checkCustomBlock({name: '   '}, NOW), {}, 'a blank name is not a name');
  assert.deepEqual(checkCustomBlock({name: null}, NOW), {});
});

test('a block that is not an object, or has a name that is not text, is refused', () => {
  for (const value of ['x', 5, true, [], [{}]]) refusesBlock(value);
  for (const name of [5, {}, [], true]) refusesBlock({name});
});

test('the block carries a validated blueprint, cleaned', () => {
  const sent = blueprint([section(1, {topicWeights: {topic_upcat_algebra: 1}}), section(2)]);
  const block = checkCustomBlock({name: 'A', blueprint: sent}, NOW);
  assert.equal(block.name, 'A');
  assert.equal(block.blueprint.sectionsJson.includes('topicWeights'), false);
  assert.equal(block.blueprint.totalQuestions, 20);
  assert.deepEqual(checkCustomBlock({blueprint: null}, NOW), {}, 'a null blueprint is absent');
  assert.throws(() => checkCustomBlock({blueprint: {...sent, totalQuestions: 1}}, NOW), error => error.message === 'Bad mock setup.');
});

test('unknown keys on the block are dropped, so nothing else reaches the track document', () => {
  assert.deepEqual(checkCustomBlock({name: 'A', examId: 'exam_cse_pro', createdAt: 1, excludedTopicIds: ['x']}, NOW), {name: 'A'});
});
