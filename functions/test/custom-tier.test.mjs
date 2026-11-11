import assert from 'node:assert/strict';
import test from 'node:test';
import {readFileSync} from 'node:fs';
import {customSubjectTiers, customTier, coversStudyExam, tierDisplayName} from '../lib/_customTrack.js';

const GENERAL = customSubjectTiers.subjects.find(s => s.name === 'General Information');
const everyTopic = customSubjectTiers.subjects.flatMap(s => s.topicIds);
const subjectNamed = name => customSubjectTiers.subjects.find(s => s.name === name);
const without = (...subjects) => subjects.flatMap(name => subjectNamed(name).topicIds);
const studentSubjects = customSubjectTiers.subjects.filter(s => s.tier === 'Student').map(s => s.name);

test('the shipped table is the same file the repo check guards', () => {
  const source = JSON.parse(readFileSync(new URL('../../content/exams/custom_subject_tiers.json', import.meta.url), 'utf8'));
  assert.deepEqual(customSubjectTiers, source);
});

test('every subject is Student except General Information, which is Civil Service', () => {
  assert.deepEqual(studentSubjects.sort(), ['Language Proficiency (English & Filipino)', 'Mathematics',
    'Reading Comprehension (English & Filipino)', 'Reasoning', 'Science']);
  assert.equal(GENERAL.tier, 'Civil Service');
});

test('keeping General Information makes the exam Civil Service; with nothing excluded too', () => {
  assert.equal(customTier([]), 'civilService');
  assert.equal(customTier(without('Science')), 'civilService');
});

test('excluding every General Information topic makes the exam Student', () => {
  assert.equal(customTier(GENERAL.topicIds), 'student');
});

test('a subject stays kept while one of its topics is not excluded', () => {
  assert.equal(customTier(GENERAL.topicIds.slice(1)), 'civilService');
});

test('keeping only Student subjects is Student, whichever one', () => {
  for (const name of studentSubjects) {
    const excluded = everyTopic.filter(id => !subjectNamed(name).topicIds.includes(id));
    assert.equal(customTier(excluded), 'student', name);
  }
});

test('a topic only topicTiers places prices at its own highest tier and never lowers one', () => {
  const table = customSubjectTiers;
  const placed = new Set(everyTopic);
  const stray = 'topic_upcat_stray_for_test';
  table.topicTiers[stray] = 'Licensure';
  try {
    assert.equal(customTier(everyTopic.filter(id => !GENERAL.topicIds.includes(id))), 'licensure');
    assert.equal(customTier([...everyTopic, stray]), 'student');
    assert.equal(placed.has(stray), false);
  } finally { delete table.topicTiers[stray]; }
});

test('excluded ids the table does not know are ignored, and nothing kept falls to the lowest tier', () => {
  assert.equal(customTier(['topic_nope', ...GENERAL.topicIds]), 'student');
  assert.equal(customTier([...everyTopic]), 'student');
  assert.equal(tierDisplayName('civilService'), 'Civil Service');
});

const access = (tier, listed = []) => ({
  coversExam: id => listed.includes(id),
  coversCustom: t => ['student', 'civilService', 'licensure'].indexOf(tier) >= ['student', 'civilService', 'licensure'].indexOf(t),
});
const CUSTOM = 'exam_custom_0a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d';

test('a custom exam is covered by tier from the server exclusions, a listed exam by its own id', () => {
  const student = new Map([[CUSTOM, GENERAL.topicIds]]);
  const civil = new Map([[CUSTOM, []]]);
  assert.equal(coversStudyExam(access('student'), CUSTOM, student), true);
  assert.equal(coversStudyExam(access('student'), CUSTOM, civil), false);
  assert.equal(coversStudyExam(access('civilService'), CUSTOM, civil), true);
  assert.equal(coversStudyExam(access('licensure'), CUSTOM, civil), true);
  assert.equal(coversStudyExam(access(null), CUSTOM, student), false);
  assert.equal(coversStudyExam(access('student', ['exam_cse_pro']), 'exam_cse_pro', new Map()), true);
  assert.equal(coversStudyExam(access('civilService'), 'exam_upcat', new Map()), false);
});

test('a custom exam with no record prices at its highest tier', () => {
  assert.equal(coversStudyExam(access('student'), CUSTOM, new Map()), false);
});

test('a kept topic in the corpus that no subject and no topic tier names raises the tier to the top', () => {
  const corpus = [...everyTopic, 'topic_upcat_brand_new'];
  // Everything but General Information excluded would be Student; the new topic is kept, so Licensure.
  assert.equal(customTier(everyTopic.filter(id => !GENERAL.topicIds.includes(id)), corpus), 'licensure');
  assert.equal(customTier(GENERAL.topicIds, corpus), 'licensure');
});

test('an excluded unknown corpus topic does not raise the tier, and no corpus means the table alone', () => {
  const corpus = [...everyTopic, 'topic_upcat_brand_new'];
  assert.equal(customTier([...GENERAL.topicIds, 'topic_upcat_brand_new'], corpus), 'student');
  assert.equal(customTier(GENERAL.topicIds), 'student');
});

test('coversStudyExam passes the corpus through, so an unknown kept topic is not covered by Student or Civil Service', () => {
  const corpus = [...everyTopic, 'topic_upcat_brand_new'];
  const exclusions = new Map([[CUSTOM, GENERAL.topicIds]]);
  assert.equal(coversStudyExam(access('student'), CUSTOM, exclusions), true);
  assert.equal(coversStudyExam(access('student'), CUSTOM, exclusions, {corpusTopicIds: corpus}), false);
  assert.equal(coversStudyExam(access('civilService'), CUSTOM, exclusions, {corpusTopicIds: corpus}), false);
  assert.equal(coversStudyExam(access('licensure'), CUSTOM, exclusions, {corpusTopicIds: corpus}), true);
});

test('mock coverage uses the higher tier of the exclusions the paper was assembled from and those read in the transaction', () => {
  const lowered = new Map([[CUSTOM, GENERAL.topicIds]]);          // transaction sees General Information excluded: Student
  const assembled = [];                                            // the paper was drawn with nothing excluded: Civil Service
  assert.equal(coversStudyExam(access('student'), CUSTOM, lowered), true);
  assert.equal(coversStudyExam(access('student'), CUSTOM, lowered, {assembledExclusions: assembled}), false);
  assert.equal(coversStudyExam(access('civilService'), CUSTOM, lowered, {assembledExclusions: assembled}), true);
  // The other direction: the assembly saw it lowered, the transaction sees it raised.
  assert.equal(coversStudyExam(access('student'), CUSTOM, new Map([[CUSTOM, []]]), {assembledExclusions: GENERAL.topicIds}), false);
  // A listed exam ignores both.
  assert.equal(coversStudyExam(access('student', ['exam_cse_pro']), 'exam_cse_pro', new Map(), {assembledExclusions: []}), true);
});

test('a mock keeps the tier it was started at, so narrowing later cannot lower its review below it', () => {
  const student = new Map([[CUSTOM, GENERAL.topicIds]]);
  assert.equal(coversStudyExam(access('student'), CUSTOM, student), true);
  assert.equal(coversStudyExam(access('student'), CUSTOM, student, {pinnedTier: 'civilService'}), false);
  assert.equal(coversStudyExam(access('civilService'), CUSTOM, student, {pinnedTier: 'civilService'}), true);
  assert.equal(coversStudyExam(access('student'), CUSTOM, student, {pinnedTier: 'student'}), true);
  assert.equal(coversStudyExam(access('student'), CUSTOM, student, {pinnedTier: 'not-a-tier'}), false,
    'a malformed stored tier fails closed');
});
