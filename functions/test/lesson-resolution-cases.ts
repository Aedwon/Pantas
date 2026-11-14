import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {loadExamContent, clearExamContentCache} from '../lib/_examContent.js';

const cases = JSON.parse(readFileSync(new URL('../../test/fixtures/content/lesson_resolution_cases.json', import.meta.url), 'utf8'));
for (const fixture of cases) {
  test(`shared lesson resolution: ${fixture.name}`, async () => {
    clearExamContentCache();
    const docs = fixture.lessons.map(lesson => ({id: lesson.id, get: key => ({topic: 'topic-test', ...lesson})[key]}));
    const set = {meta: {...fixture.question, exams: ['cse-pro']}, questions: [{id: 'q', lesson: fixture.question.lesson}]};
    const db = {collection: path => ({select() { return this; }, get: async () => ({docs: path.includes('/questions/')
      ? [{id: 'set', get: () => JSON.stringify(set)}] : docs})})};
    if (fixture.error) await assert.rejects(loadExamContent(db, 'exam_cse_pro', 0), new RegExp(fixture.error));
    else assert.equal((await loadExamContent(db, 'exam_cse_pro', 0)).questions[0].lessonId, fixture.expectedLesson);
  });
}

test('TypeScript quiz sizes equal the Dart exporter for shared fixture lessons', async () => {
  const {mkdtempSync, mkdirSync, writeFileSync, rmSync} = await import('node:fs');
  const {tmpdir} = await import('node:os');
  const {join} = await import('node:path');
  const {spawnSync} = await import('node:child_process');
  const {lessonItem} = await import('../lib/contentUpload.js');
  const repo = new URL('../../', import.meta.url).pathname;
  const root = mkdtempSync(join(tmpdir(), 'quiz-parity-'));
  try {
    mkdirSync(join(root, 'content/lessons/s/test'), {recursive: true});
    mkdirSync(join(root, 'content/illustrations'), {recursive: true});
    writeFileSync(join(root, 'content/illustrations/assets.json'), '{}');
    const rows = cases.flatMap((fixture, i) => fixture.lessons.map((lesson, j) => {
      const front = {_id: `lesson-test-${i}-${j}`, topic: 'topic-test', title: 'Test', summary: 'Test',
        estimatedMinutes: 1, subject: i % 2 ? 'subject-science' : 'subject-mathematics',
        keyPoints: Array.from({length: (i + j) % 5}, (_, k) => `Point ${k}`)};
      const body = '## Core Concept\n### Ignore\n## Examples\n### One\n### Two\n### Three\n## Traps\n### Ignore';
      writeFileSync(join(root, `content/lessons/s/test/${i}-${j}.md`), `---\n${JSON.stringify(front)}\n---\n${body}`);
      return {front, body};
    }));
    const helper = join(root, 'parity.dart');
    writeFileSync(helper, `import 'dart:convert';\nimport '${new URL('../../tools/build_content_export/build_content_export.dart', import.meta.url).href}' as exporter;\nvoid main(List<String> args) { print(jsonEncode(exporter.buildLessons({'test': 'topic_test'}, args.single))); }\n`);
    const dart = spawnSync('dart', [`--packages=${repo}.dart_tool/package_config.json`, helper, root], {cwd: repo, encoding: 'utf8'});
    assert.equal(dart.status, 0, dart.stderr);
    const exported = JSON.parse(dart.stdout.trim().split('\n').at(-1));
    for (const {front, body} of rows) {
      assert.equal(lessonItem(front, body).data.quizSize, exported.find(row => row._id === front._id).quizSize, front._id);
    }
  } finally { rmSync(root, {recursive: true, force: true}); }
});
