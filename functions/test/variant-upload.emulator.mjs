import assert from 'node:assert/strict';
import test from 'node:test';
import {initializeApp, deleteApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import * as upload from '../lib/contentUpload.js';

// One lesson with one type, uploaded to the emulator the way the CLI builds it: the lesson, the lesson's file set
// (its source question carries the active state the type decides), the lesson's type-only set, the Free variant
// document and the Pro notes. Both active-state directions (L2) are checked, and the Free and Pro split.
test('uploads one lesson with one type: documents, active states, Free and Pro split', async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  const app = initializeApp({projectId: 'demo-pantas-test'}, 'one-type-lesson');
  const lessonId = 'lesson-biology-botany';
  const typeId = 'qt-biology-botany-example';
  const fileSetId = 'qs-science__biology__botany';
  const typeSetId = `qs-types__${lessonId}`;
  const free = {id: typeId, exams: ['cse-pro'], variants: [{variantIndex: 0, ruleKey: 'k0', stem: 'S0', explanation: 'E0',
    choices: [{text: 'right', correct: true}, {text: 'wrong a', correct: false}, {text: 'wrong b', correct: false}]}]};
  const notes = {rationales: {0: [null, 'NOTE-WRONG-A', 'NOTE-WRONG-B']}};
  const single = {meta: {subject: 'science', topic: 'biology', subtopic: 'botany', exams: ['cse-pro']},
    questions: [{id: 'q-botany-1', type: 'single_choice', stem: 'S', explanation: 'E',
      choices: [{text: 'A', correct: true}, {text: 'B', rationale: 'NOTE-SINGLE-B'}]}]};
  const build = enabled => {
    const type = {id: typeId, lesson: lessonId, topic: 'topic_upcat_biology', exams: ['cse-pro'], isActive: enabled,
      variantCount: 1, mergedQuestions: [{id: 'q-botany-1', variantIndex: 0}]};
    const activity = {'q-botany-1': !enabled};
    const [typeSet] = upload.typeSetSources([type]);
    const {item: variant, pro: variantPro} = upload.variantItems(free, notes);
    const {item: fileSet, pro: filePro} = upload.questionSetItems(upload.withProblemTypes(single, [], activity), 'science/biology/botany.yaml');
    const typeSetItem = upload.questionSetItems(typeSet.source, typeSet.relativePath).item;
    const lesson = upload.lessonItem({_id: lessonId, title: 'Botany', topic: 'topic-biology'}, '## Body');
    return {items: [lesson, fileSet, typeSetItem, variant], pros: [filePro, variantPro]};
  };
  try {
    const db = getFirestore(app);
    const read = async path => (await db.doc(path).get());
    const payload = async path => JSON.parse((await read(path)).get('payload'));
    const enabled = build(true);
    const dry = await upload.writeContent(db, enabled.items, enabled.pros, {dryRun: true});
    assert.deepEqual(dry.counts, {create: 4, update: 0, unchanged: 0});
    assert.equal((await read(`content/variants/items/${typeId}`)).exists, false, 'a dry run writes nothing');
    try {
      const first = await upload.writeContent(db, enabled.items, enabled.pros, {});
      assert.deepEqual(first.counts, {create: 4, update: 0, unchanged: 0});
      for (const path of [`content/lessons/items/${lessonId}`, `content/questions/items/${fileSetId}`,
        `content/questions/items/${typeSetId}`, `content/variants/items/${typeId}`, `contentPro/${typeId}`, `contentPro/${fileSetId}`]) {
        assert.equal((await read(path)).exists, true, path);
      }
      // Enabled: the type row is active, its source question is inactive and written explicitly.
      const typeSet = await payload(`content/questions/items/${typeSetId}`);
      assert.deepEqual(typeSet.questions, []);
      assert.equal(typeSet.problemTypes[0].isActive, true);
      assert.equal((await payload(`content/questions/items/${fileSetId}`)).questions[0].isActive, false);
      // The split: the Free variant document and both Free sets hold no note; the Pro document holds them.
      for (const path of [`content/variants/items/${typeId}`, `content/questions/items/${fileSetId}`, `content/questions/items/${typeSetId}`]) {
        const text = JSON.stringify((await read(path)).data());
        for (const secret of ['NOTE-WRONG-A', 'NOTE-WRONG-B', 'NOTE-SINGLE-B']) assert.equal(text.includes(secret), false, `${path} ${secret}`);
      }
      assert.deepEqual(await payload(`contentPro/${typeId}`), notes);
      assert.equal((await read(`contentPro/${typeId}`)).get('version'), (await read(`content/variants/items/${typeId}`)).get('version'));
      assert.equal(JSON.stringify(await payload(`content/variants/items/${typeId}`)), JSON.stringify(free));
      // Disabled: the reverse, written explicitly over the old value. The variant document is untouched.
      const disabled = build(false);
      const second = await upload.writeContent(db, disabled.items, disabled.pros, {});
      assert.deepEqual(second.counts, {create: 0, update: 2, unchanged: 2});
      assert.equal((await payload(`content/questions/items/${typeSetId}`)).problemTypes[0].isActive, false);
      assert.equal((await payload(`content/questions/items/${fileSetId}`)).questions[0].isActive, true);
      assert.equal((await read(`content/variants/items/${typeId}`)).exists, true);
      const again = await upload.writeContent(db, disabled.items, disabled.pros, {dryRun: true});
      assert.deepEqual(again.counts, {create: 0, update: 0, unchanged: 4});
    } finally {
      // Only what this test wrote, so other emulator tests keep their own data.
      await Promise.all([`content/lessons/items/${lessonId}`, `content/questions/items/${fileSetId}`,
        `content/questions/items/${typeSetId}`, `content/variants/items/${typeId}`, `contentPro/${typeId}`, `contentPro/${fileSetId}`,
        ...['lessons', 'questions', 'variants', 'mocks', 'catalog', 'gaps'].map(kind => `content/versions/items/${kind}`),
        'content/summaries/items/_bank'].map(path => db.doc(path).delete()));
      await db.recursiveDelete(db.collection('content/summaries/items'));
    }
  } finally {
    await deleteApp(app);
  }
});

test('plans variant and Pro documents without writing during a dry run', async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  const app = initializeApp({projectId: 'demo-pantas-test'}, 'variant-upload');
  try {
    const db = getFirestore(app);
    const id = 'qt-upload-dry-run';
    const {item, pro} = upload.variantItems(
      {id, exams: ['cse-pro'], variants: []},
      {rationales: {}},
    );
    const freeRef = db.doc(`content/variants/items/${id}`);
    const proRef = db.doc(`contentPro/${id}`);
    const dryRun = await upload.writeContent(db, [item], [pro], {dryRun: true});
    assert.deepEqual(dryRun.counts, {create: 1, update: 0, unchanged: 0});
    assert.equal(dryRun.proWritten, 1);
    assert.equal((await freeRef.get()).exists, false);
    assert.equal((await proRef.get()).exists, false);

    try {
      await upload.writeContent(db, [item], [pro], {});
      assert.equal((await freeRef.get()).get('version'), (await proRef.get()).get('version'));
      const retry = await upload.writeContent(db, [item], [pro], {dryRun: true});
      assert.equal(retry.counts.unchanged, 1);
    } finally {
      await Promise.all([freeRef.delete(), proRef.delete()]);
    }
  } finally {
    await deleteApp(app);
  }
});
