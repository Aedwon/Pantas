import assert from 'node:assert/strict';
import {readdirSync, readFileSync, statSync} from 'node:fs';
import {createRequire} from 'node:module';
import test from 'node:test';
import {blueprintItem} from '../lib/contentUpload.js';
import {topicIdFor} from '../lib/_examContent.js';
import {core} from '../lib/_core.js';

const require = createRequire(import.meta.url);
const {parse} = require('yaml');
const contentDir = new URL('../../content/', import.meta.url);

function walk(url, ext) {
  const out = [];
  for (const name of readdirSync(url).sort()) {
    const child = new URL(name + (statSync(new URL(name, url)).isDirectory() ? '/' : ''), url);
    if (name.endsWith(ext)) out.push(child);
    else if (statSync(child).isDirectory()) out.push(...walk(child, ext));
  }
  return out;
}

/** The pools the server builds in `loadExamContent`, read from the question YAML instead of Firestore. */
function poolsFor(examId) {
  const slug = examId.replace(/^exam_/, '').replace(/_/g, '-');
  const pools = {};
  for (const file of walk(new URL('questions/', contentDir), '.yaml')) {
    let doc;
    try { doc = parse(readFileSync(file, 'utf8')); } catch { continue; } // the upload leaves invalid sets out too
    const topic = doc?.meta?.topic;
    if (typeof topic !== 'string' || !doc.meta.exams?.includes(slug)) continue;
    for (const q of doc.questions ?? []) (pools[topicIdFor(examId, topic)] ??= []).push(q.id);
  }
  return pools;
}

const blueprint = name => parse(readFileSync(new URL(`mock/${name}.yaml`, contentDir), 'utf8'));

// Every section fills its count from the current bank. Numerical Ability weights arithmetic 0.6
// and algebra 0.4, because the bank holds only 20 CSE algebra questions.
const knownShortfall = {};

const expected = {
  exam_cse_pro: {file: 'cse-pro', minutes: 190, total: 155, counts: {
    sec_cse_pro_general_information: 20, sec_cse_pro_verbal_ability: 55,
    sec_cse_pro_analytical_ability: 35, sec_cse_pro_numerical_ability: 45}},
  exam_cse_sub: {file: 'cse-sub', minutes: 160, total: 145, counts: {
    sec_cse_sub_verbal_ability: 36, sec_cse_sub_numerical_ability: 36,
    sec_cse_sub_clerical_ability: 36, sec_cse_sub_general_information: 37}},
};

for (const [examId, want] of Object.entries(expected)) {
  test(`${examId} blueprint is valid, reported and sums to the examinee's counts`, () => {
    const doc = blueprint(want.file);
    assert.equal(doc.exam, examId);
    assert.equal(doc.source, 'reported');
    assert.ok(String(doc.sourceNote).length > 100);
    assert.equal(doc.durationMinutes, want.minutes);
    assert.equal(doc.sectionalTiming, 'roamable');
    assert.deepEqual(Object.fromEntries(doc.sections.map(s => [s.id, s.questionCount])), want.counts);
    assert.equal(doc.sections.reduce((n, s) => n + s.questionCount, 0), want.total);
    for (const section of doc.sections) {
      for (const topicId of section.topicIds) assert.ok(topicId.startsWith(`topic_${examId.replace(/^exam_/, '')}_`), topicId);
      const weights = Object.values(section.topicWeights);
      assert.equal(weights.length, section.topicIds.length);
      assert.ok(Math.abs(weights.reduce((a, b) => a + b, 0) - 1) < 1e-9);
      if (section.id === 'sec_cse_pro_numerical_ability') {
        assert.deepEqual(section.topicWeights, {topic_cse_pro_arithmetic_number_sense: 0.6, topic_cse_pro_algebra: 0.4});
      } else {
        assert.ok(Math.max(...weights) - Math.min(...weights) < 1e-9, 'even weights');
      }
    }
    const item = blueprintItem(doc);
    assert.equal(item.kind, 'mocks');
    assert.equal(item.id, examId);
  });

  test(`${examId} sampler builds a paper from the real tagged pools`, () => {
    const doc = blueprint(want.file);
    const pools = poolsFor(examId);
    const sectionsJson = blueprintItem(doc).data.sectionsJson;
    for (const seed of [1, 2, 3, 42, 2027]) {
      const paper = JSON.parse(core().sampleMock(JSON.stringify({
        sectionsJson, poolsByTopic: pools, passageSetsByTopic: {}, recentlySampledQuestionIds: [], seed})));
      assert.deepEqual(paper.sections.map(s => s.sectionId), doc.sections.map(s => s.id));
      const seen = new Set();
      for (const section of paper.sections) {
        const def = doc.sections.find(s => s.id === section.sectionId);
        const allowed = new Set(def.topicIds.flatMap(t => pools[t] ?? []));
        assert.equal(section.questionIds.length, knownShortfall[section.sectionId] ?? def.questionCount, section.sectionId);
        for (const id of section.questionIds) {
          assert.ok(allowed.has(id), `${id} is outside ${section.sectionId}`);
          assert.ok(!seen.has(id), `${id} repeats`);
          seen.add(id);
        }
      }
    }
  });
}
