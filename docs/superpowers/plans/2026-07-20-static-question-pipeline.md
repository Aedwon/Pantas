# Static Question Content Pipeline Implementation Plan

> **Typography, amended 11 August 2026.** Any "serif" below is superseded: the
> app uses one family, Source Sans 3, everywhere. See
> `decisions/2026-08-10-typeface-log.md`.



> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a static question-bank pipeline — reviewable YAML source per subtopic, a Dart importer that converts it to Sanity `question` docs, and a local review tool — then prove it end-to-end on one pilot subtopic.

**Architecture:** Authors write one YAML file per subtopic under `content/questions/`. A Dart importer (`tools/import_questions/`) validates each file and converts questions to the exact Sanity `question` doc shape the app already parses (`lib/core/content/sanity/parsers/question_parser.dart`), emitting NDJSON for `sanity dataset import` or a self-contained seed JSON for local verification. A dependency-free Node review tool (`tools/question_studio/`) renders/validates/approves questions, mirroring `tools/lesson_author/`.

**Tech Stack:** Dart (importer + tests, `yaml` package), Node ≥18 (studio server, `node:test`), Flutter test harness (`flutter test`), Sanity Portable Text.

## Global Constraints

- Content language English only; every `question` doc sets `language: "en"`.
- IDs derive from stable outline slugs, never editable titles: `subject-<slug>`, `topic-<topicSlug>`, `lesson-<topicSlug>-<lessonSlug>`, `exam-<code>`. Question ids: `q-<topicSlug>-<subtopicSlug>-NNNN`. (Matches the 2026-07-16 lesson-author spec so both importers stay compatible.)
- Emitted `question` doc must satisfy the shipping parser: fields `_id`, `_updatedAt` (ISO 8601 string), `schemaVersion: 1`, `isActive` (bool), `topic` (`{_ref}`), `subtopic` (`{_ref}`, optional), `examIds` (`[{_ref}]`), `language`, `stem` (Portable Text list), `explanation` (Portable Text list), `version` (int), `choices` (`[{_key,label,text,isCorrect}]`).
- Exactly one choice per question has `correct: true`.
- Figure-pending questions (YAML has a non-empty `figure:`) are emitted with `isActive: false` and their slug appended to `docs/content/question-figures/worklist.tsv`.
- `difficulty` is authoring-only: it orders question ids and never appears in any emitted doc.
- No AI/Claude attribution in commit messages.
- Follow existing tool precedent: importer mirrors `tools/build_content_seed/seed_writer.dart`; studio mirrors `tools/lesson_author/server.mjs`.

---

## File Structure

**Created:**
- `tools/import_questions/converter.dart` — pure YAML-question → Sanity-doc conversion + per-question validation.
- `tools/import_questions/ids.dart` — slug→id helpers shared with the future lesson importer.
- `tools/import_questions/import_questions.dart` — CLI: scan `content/questions/`, emit NDJSON (default) or `--seed-json <out>`.
- `tools/question_studio/server.mjs` — Node review server (port 4323).
- `tools/question_studio/validators.mjs` — pure validator functions (shared by server + browser).
- `tools/question_studio/validators.test.mjs` — `node:test` unit tests for validators.
- `tools/question_studio/public/index.html` — single-page review UI.
- `tools/question_studio/package.json` — declares the `yaml` dependency.
- `tools/question_studio/prompt_template.md` — generation brief.
- `tools/question_studio/Start Question Studio.command` — double-click launcher.
- `docs/content/question-style-guide.md`, `docs/content/question-authoring-runbook.md`, `docs/content/question-blueprints/{science,reasoning,language-proficiency}.md`, `docs/content/question-figures/worklist.tsv`.
- `content/questions/science/biology/cell-structure.yaml` — pilot content.
- `test/fixtures/questions/*.yaml` — importer test fixtures.
- `test/tool/import_questions/converter_test.dart`, `test/tool/import_questions/cli_test.dart`, `test/tool/question_studio_validators_test.dart`.

**Modified:**
- `pubspec.yaml` — add `yaml` to `dev_dependencies`.

---

## Task 1: Importer converter + id helpers (pure functions)

**Files:**
- Create: `tools/import_questions/ids.dart`
- Create: `tools/import_questions/converter.dart`
- Modify: `pubspec.yaml` (add `yaml` under `dev_dependencies`)
- Test: `test/tool/import_questions/converter_test.dart`

**Interfaces:**
- Produces:
  - `String subjectId(String subjectSlug)` → `subject-<slug>`; `String topicId(String topicSlug)` → `topic-<slug>`; `String lessonId(String topicSlug, String lessonSlug)` → `lesson-<topicSlug>-<lessonSlug>`; `String examId(String code)` → `exam-<code>`.
  - `List<Map<String,Object?>> textToPortableText(String text)` — splits on blank lines into `block` items, each with one `span` child; each block and span carries a `_key`.
  - `class QuestionMeta { final String subjectSlug, topicSlug, subtopicSlug; final List<String> examCodes; }`
  - `Map<String,Object?> questionToDoc(Map yamlQuestion, QuestionMeta meta, {required DateTime updatedAt})` — returns a Sanity `question` doc. Throws `FormatException` with the offending question id on invalid input (missing/empty stem or explanation, not exactly one correct, fewer than 2 choices). Sets `isActive:false` when the question has a non-empty `figure`.

- [ ] **Step 1: Add the `yaml` dev dependency**

In `pubspec.yaml`, under `dev_dependencies:`, add:

```yaml
  yaml: ^3.1.2
```

Run: `flutter pub get`
Expected: resolves without error (`yaml` is already in `pubspec.lock` transitively).

- [ ] **Step 2: Write the failing converter test**

Create `test/tool/import_questions/converter_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/content/sanity/parsers/question_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
// Path import: the tool is not part of lib/, so import by relative file path.
import '../../../tools/import_questions/converter.dart';

const _meta = QuestionMeta(
  subjectSlug: 'science',
  topicSlug: 'biology',
  subtopicSlug: 'cell-structure',
  examCodes: ['upcat', 'dost-sei'],
);

Map<String, Object?> _yaml(String src) =>
    Map<String, Object?>.from(loadYaml(src) as YamlMap);

final _updatedAt = DateTime.utc(2026, 7, 20);

void main() {
  test('converts a valid question to a parseable Sanity doc', () {
    final doc = questionToDoc(
      _yaml('''
id: q-biology-cell-structure-0001
type: identify-organelle
difficulty: easy
stem: |
  Which organelle is the site of photosynthesis?
choices:
  - text: Chloroplast
    correct: true
  - text: Mitochondrion
  - text: Ribosome
  - text: Golgi apparatus
explanation: |
  Chloroplasts hold chlorophyll, which captures light to make food.
'''),
      _meta,
      updatedAt: _updatedAt,
    );

    // The doc must satisfy the shipping parser end-to-end.
    final parsed = parseQuestion(doc);
    expect(parsed.question.id.value, 'q-biology-cell-structure-0001');
    expect(parsed.question.topicId.value, 'topic-biology');
    expect(parsed.question.subtopicId.value, 'lesson-biology-cell-structure');
    expect(parsed.choices, hasLength(4));
    expect(parsed.choices.map((c) => c.label.value), ['A', 'B', 'C', 'D']);
    expect(parsed.choices.where((c) => c.isCorrect.value), hasLength(1));
    expect(parsed.examLinks.map((e) => e.examId.value),
        ['exam-upcat', 'exam-dost-sei']);
    expect(doc['isActive'], true);
    expect(doc['difficulty'], isNull, reason: 'difficulty must not leak');
  });

  test('figure-pending question is emitted inactive', () {
    final doc = questionToDoc(
      _yaml('''
id: q-biology-cell-structure-0002
type: identify-organelle
difficulty: medium
figure: cell-diagram-01
stem: |
  Label the organelle marked X.
choices:
  - text: Nucleus
    correct: true
  - text: Vacuole
explanation: |
  X sits at the cell centre and holds the DNA.
'''),
      _meta,
      updatedAt: _updatedAt,
    );
    expect(doc['isActive'], false);
    expect(() => parseQuestion(doc), returnsNormally);
  });

  test('throws when not exactly one choice is correct', () {
    expect(
      () => questionToDoc(
        _yaml('''
id: q-biology-cell-structure-0003
type: identify-organelle
difficulty: easy
stem: |
  Pick one.
choices:
  - text: A
    correct: true
  - text: B
    correct: true
explanation: |
  Only one can be right.
'''),
        _meta,
        updatedAt: _updatedAt,
      ),
      throwsA(isA<FormatException>().having(
          (e) => e.message, 'message', contains('q-biology-cell-structure-0003'))),
    );
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `flutter test test/tool/import_questions/converter_test.dart`
Expected: FAIL — `converter.dart` / `QuestionMeta` / `questionToDoc` do not exist.

- [ ] **Step 4: Implement `ids.dart`**

Create `tools/import_questions/ids.dart`:

```dart
String subjectId(String subjectSlug) => 'subject-$subjectSlug';
String topicId(String topicSlug) => 'topic-$topicSlug';
String lessonId(String topicSlug, String lessonSlug) =>
    'lesson-$topicSlug-$lessonSlug';
String examId(String code) => 'exam-$code';
```

- [ ] **Step 5: Implement `converter.dart`**

Create `tools/import_questions/converter.dart`:

```dart
import 'ids.dart';

class QuestionMeta {
  const QuestionMeta({
    required this.subjectSlug,
    required this.topicSlug,
    required this.subtopicSlug,
    required this.examCodes,
  });
  final String subjectSlug;
  final String topicSlug;
  final String subtopicSlug;
  final List<String> examCodes;
}

int _keyCounter = 0;
String _key(String prefix) => '$prefix${_keyCounter++}';

List<Map<String, Object?>> textToPortableText(String text) {
  final paragraphs = text
      .trim()
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim())
      .where((p) => p.isNotEmpty)
      .toList();
  if (paragraphs.isEmpty) {
    throw const FormatException('empty rich-text field');
  }
  return [
    for (final p in paragraphs)
      {
        '_type': 'block',
        '_key': _key('b'),
        'style': 'normal',
        'markDefs': const <Object?>[],
        'children': [
          {'_type': 'span', '_key': _key('s'), 'text': p, 'marks': const <Object?>[]},
        ],
      },
  ];
}

Map<String, Object?> questionToDoc(
  Map<Object?, Object?> q,
  QuestionMeta meta, {
  required DateTime updatedAt,
}) {
  final id = (q['id'] as String?)?.trim();
  if (id == null || id.isEmpty) {
    throw const FormatException('question is missing an id');
  }

  String requireText(String field) {
    final v = q[field];
    if (v is! String || v.trim().isEmpty) {
      throw FormatException('$id: missing or empty "$field"');
    }
    return v;
  }

  final stem = requireText('stem');
  final explanation = requireText('explanation');

  final rawChoices = q['choices'];
  if (rawChoices is! List || rawChoices.length < 2) {
    throw FormatException('$id: needs at least 2 choices');
  }
  final correctCount =
      rawChoices.where((c) => (c as Map)['correct'] == true).length;
  if (correctCount != 1) {
    throw FormatException(
        '$id: exactly one choice must be correct (found $correctCount)');
  }

  const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
  final choices = <Map<String, Object?>>[];
  for (var i = 0; i < rawChoices.length; i++) {
    final c = rawChoices[i] as Map;
    final text = c['text'];
    if (text is! String || text.trim().isEmpty) {
      throw FormatException('$id: choice ${i + 1} has empty text');
    }
    choices.add({
      '_key': 'choice-${labels[i].toLowerCase()}',
      'label': labels[i],
      'text': text.trim(),
      'isCorrect': c['correct'] == true,
    });
  }

  final figure = q['figure'];
  final isFigurePending = figure is String && figure.trim().isNotEmpty;

  return {
    '_id': id,
    '_type': 'question',
    '_updatedAt': updatedAt.toUtc().toIso8601String(),
    'schemaVersion': 1,
    'isActive': !isFigurePending,
    'topic': {'_ref': topicId(meta.topicSlug)},
    'subtopic': {'_ref': lessonId(meta.topicSlug, meta.subtopicSlug)},
    'examIds': [for (final code in meta.examCodes) {'_ref': examId(code)}],
    'language': 'en',
    'stem': textToPortableText(stem),
    'explanation': textToPortableText(explanation),
    'version': 1,
    'choices': choices,
  };
}
```

- [ ] **Step 6: Run the test to verify it passes**

Run: `flutter test test/tool/import_questions/converter_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock tools/import_questions/ids.dart tools/import_questions/converter.dart test/tool/import_questions/converter_test.dart
git commit -m "feat(import_questions): YAML question to Sanity doc converter"
```

---

## Task 2: Importer CLI (scan tree, emit NDJSON / seed-JSON)

**Files:**
- Create: `tools/import_questions/import_questions.dart`
- Create: `test/fixtures/questions/science/biology/cell-structure.yaml`
- Create: `test/fixtures/questions/science/biology/_bad.yaml`
- Test: `test/tool/import_questions/cli_test.dart`

**Interfaces:**
- Consumes: `questionToDoc`, `QuestionMeta`, id helpers from Task 1; the outline at `tools/lesson_author/outline.json`.
- Produces (CLI contract):
  - `dart run tools/import_questions/import_questions.dart --root <dir>` → writes one `question` JSON doc per line to stdout (NDJSON).
  - `... --root <dir> --seed-json <out.json>` → writes `{"exam":[...],"subject":[...],"topic":[...],"question":[...]}` (referenced exam/subject/topic docs derived from the outline + referenced codes) so `seed_writer.dart` can build an openable DB.
  - Exit code non-zero with a message naming the file + question id on any validation failure or duplicate id.

- [ ] **Step 1: Create importer test fixtures**

Create `test/fixtures/questions/science/biology/cell-structure.yaml`:

```yaml
meta:
  subject: science
  topic: biology
  subtopic: cell-structure
  exams: [upcat, dost-sei]
questions:
  - id: q-biology-cell-structure-0001
    type: identify-organelle
    difficulty: easy
    stem: |
      Which organelle is the site of photosynthesis?
    choices:
      - text: Chloroplast
        correct: true
      - text: Mitochondrion
      - text: Ribosome
      - text: Golgi apparatus
    explanation: |
      Chloroplasts hold chlorophyll, which captures light to make food.
  - id: q-biology-cell-structure-0002
    type: structure-function
    difficulty: medium
    figure: cell-diagram-01
    stem: |
      The organelle marked X controls what enters and leaves the cell. Name it.
    choices:
      - text: Cell membrane
        correct: true
      - text: Cell wall
      - text: Cytoplasm
      - text: Nucleolus
    explanation: |
      The cell membrane is the gatekeeper that lets some things in and keeps others out.
```

Create `test/fixtures/questions/science/biology/_bad.yaml` (two correct answers, must fail):

```yaml
meta:
  subject: science
  topic: biology
  subtopic: cell-structure
  exams: [upcat]
questions:
  - id: q-biology-cell-structure-9001
    type: identify-organelle
    difficulty: easy
    stem: |
      Pick one.
    choices:
      - text: A
        correct: true
      - text: B
        correct: true
    explanation: |
      Broken on purpose.
```

- [ ] **Step 2: Write the failing CLI test**

Create `test/tool/import_questions/cli_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:cse_cet_reviewer/core/content/sanity/parsers/question_parser.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProcessResult> _run(List<String> args) => Process.run(
      'dart',
      ['run', 'tools/import_questions/import_questions.dart', ...args],
    );

void main() {
  test('emits NDJSON docs the shipping parser accepts', () async {
    final tmp = await Directory.systemTemp.createTemp('iq_ndjson_');
    addTearDown(() => tmp.delete(recursive: true));
    // Point at a root that contains only the good fixture.
    final root = Directory('${tmp.path}/science/biology')
      ..createSync(recursive: true);
    File('${root.path}/cell-structure.yaml').writeAsStringSync(
      File('test/fixtures/questions/science/biology/cell-structure.yaml')
          .readAsStringSync(),
    );

    final result = await _run(['--root', tmp.path]);
    expect(result.exitCode, 0, reason: result.stderr as String?);

    final lines = (result.stdout as String)
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    expect(lines, hasLength(2));
    for (final line in lines) {
      final doc = Map<String, Object?>.from(jsonDecode(line) as Map);
      expect(doc['_type'], 'question');
      expect(() => parseQuestion(doc), returnsNormally);
    }
    // Figure-pending question is inactive.
    final byId = {
      for (final l in lines)
        (jsonDecode(l) as Map)['_id'] as String: jsonDecode(l) as Map,
    };
    expect(byId['q-biology-cell-structure-0002']!['isActive'], false);
  });

  test('fails loudly on an invalid question', () async {
    final tmp = await Directory.systemTemp.createTemp('iq_bad_');
    addTearDown(() => tmp.delete(recursive: true));
    final root = Directory('${tmp.path}/science/biology')
      ..createSync(recursive: true);
    File('${root.path}/bad.yaml').writeAsStringSync(
      File('test/fixtures/questions/science/biology/_bad.yaml')
          .readAsStringSync(),
    );

    final result = await _run(['--root', tmp.path]);
    expect(result.exitCode, isNot(0));
    expect(result.stderr as String, contains('q-biology-cell-structure-9001'));
  });

  test('seed-json builds an openable database via seed_writer', () async {
    final tmp = await Directory.systemTemp.createTemp('iq_seed_');
    addTearDown(() => tmp.delete(recursive: true));
    final root = Directory('${tmp.path}/science/biology')
      ..createSync(recursive: true);
    File('${root.path}/cell-structure.yaml').writeAsStringSync(
      File('test/fixtures/questions/science/biology/cell-structure.yaml')
          .readAsStringSync(),
    );
    final seed = '${tmp.path}/seed.json';

    final gen = await _run(['--root', tmp.path, '--seed-json', seed]);
    expect(gen.exitCode, 0, reason: gen.stderr as String?);

    final json = jsonDecode(File(seed).readAsStringSync()) as Map;
    expect((json['question'] as List), hasLength(2));
    expect((json['topic'] as List).first['_id'], 'topic-biology');
    expect((json['subject'] as List).first['_id'], 'subject-science');
    expect((json['exam'] as List).map((e) => e['_id']),
        containsAll(['exam-upcat', 'exam-dost-sei']));
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `flutter test test/tool/import_questions/cli_test.dart`
Expected: FAIL — `import_questions.dart` does not exist.

- [ ] **Step 4: Implement the CLI**

Create `tools/import_questions/import_questions.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'converter.dart';
import 'ids.dart';

Future<void> main(List<String> args) async {
  final root = _flag(args, '--root') ?? 'content/questions';
  final seedJson = _flag(args, '--seed-json');
  final updatedAt = DateTime.now().toUtc();

  final questionDocs = <Map<String, Object?>>[];
  final seenIds = <String>{};
  final examCodes = <String>{};
  final topicSlugs = <String, String>{}; // topicSlug -> subjectSlug

  final dir = Directory(root);
  if (!dir.existsSync()) {
    stderr.writeln('Question root not found: $root');
    exitCode = 66;
    return;
  }

  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.yaml'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    try {
      final doc = loadYaml(file.readAsStringSync());
      final meta = Map<Object?, Object?>.from(doc['meta'] as Map);
      final qm = QuestionMeta(
        subjectSlug: meta['subject'] as String,
        topicSlug: meta['topic'] as String,
        subtopicSlug: meta['subtopic'] as String,
        examCodes: [for (final e in (meta['exams'] as List)) e as String],
      );
      topicSlugs[qm.topicSlug] = qm.subjectSlug;
      examCodes.addAll(qm.examCodes);
      for (final raw in (doc['questions'] as List)) {
        final q = Map<Object?, Object?>.from(raw as Map);
        final built = questionToDoc(q, qm, updatedAt: updatedAt);
        final id = built['_id'] as String;
        if (!seenIds.add(id)) {
          throw FormatException('$id: duplicate question id');
        }
        questionDocs.add(built);
      }
    } on FormatException catch (e) {
      stderr.writeln('${file.path}: ${e.message}');
      exitCode = 65;
      return;
    }
  }

  if (seedJson != null) {
    final payload = {
      'exam': [
        for (final code in examCodes)
          {
            '_id': examId(code),
            '_type': 'exam',
            '_updatedAt': updatedAt.toIso8601String(),
            'schemaVersion': 1,
            'isActive': true,
            'code': code.toUpperCase(),
            'name': code.toUpperCase(),
            'shortName': code.toUpperCase(),
            'language': 'en',
            'ordering': 1,
          },
      ],
      'subject': [
        for (final slug in topicSlugs.values.toSet())
          {
            '_id': subjectId(slug),
            '_type': 'subject',
            '_updatedAt': updatedAt.toIso8601String(),
            'schemaVersion': 1,
            'isActive': true,
            'exam': {'_ref': examId(examCodes.first)},
            'name': slug,
            'ordering': 1,
          },
      ],
      'topic': [
        for (final entry in topicSlugs.entries)
          {
            '_id': topicId(entry.key),
            '_type': 'topic',
            '_updatedAt': updatedAt.toIso8601String(),
            'schemaVersion': 1,
            'isActive': true,
            'subject': {'_ref': subjectId(entry.value)},
            'name': entry.key,
            'ordering': 1,
          },
      ],
      'question': questionDocs,
    };
    File(seedJson).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
    return;
  }

  final out = StringBuffer();
  for (final doc in questionDocs) {
    out.writeln(jsonEncode(doc));
  }
  stdout.write(out.toString());
}

String? _flag(List<String> args, String name) {
  final i = args.indexOf(name);
  return (i == -1 || i + 1 >= args.length) ? null : args[i + 1];
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/tool/import_questions/cli_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 6: Run the full existing tool suite for regressions**

Run: `flutter test test/tool/`
Expected: PASS (new + existing `content_seed_*` tests).

- [ ] **Step 7: Commit**

```bash
git add tools/import_questions/import_questions.dart test/fixtures/questions test/tool/import_questions/cli_test.dart
git commit -m "feat(import_questions): CLI scans YAML tree, emits NDJSON and seed JSON"
```

---

## Task 3: Studio validators (pure, tested)

**Files:**
- Create: `tools/question_studio/validators.mjs`
- Create: `tools/question_studio/validators.test.mjs`
- Test (harness wrapper): `test/tool/question_studio_validators_test.dart`

**Interfaces:**
- Produces: `export function validateQuestion(q)` → `string[]` of error messages (empty = valid); `export function findDuplicateStems(questions)` → `Array<[idA, idB]>`. A question is `{id, stem, choices:[{text, correct}], explanation, figure?}`.

- [ ] **Step 1: Write the failing validator tests**

Create `tools/question_studio/validators.test.mjs`:

```js
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { validateQuestion, findDuplicateStems } from './validators.mjs';

test('valid question has no errors', () => {
  assert.deepEqual(
    validateQuestion({
      id: 'q-1',
      stem: 'Which is a metal?',
      choices: [
        { text: 'Iron', correct: true },
        { text: 'Oxygen', correct: false },
      ],
      explanation: 'Iron is a metal.',
    }),
    [],
  );
});

test('flags zero and multiple correct answers', () => {
  assert.match(
    validateQuestion({
      id: 'q-2', stem: 's', explanation: 'e',
      choices: [{ text: 'a', correct: false }, { text: 'b', correct: false }],
    }).join(' '),
    /exactly one correct/,
  );
});

test('flags empty fields and too few choices', () => {
  const errs = validateQuestion({ id: 'q-3', stem: '', explanation: '', choices: [{ text: 'a', correct: true }] });
  assert.ok(errs.some((e) => /stem/.test(e)));
  assert.ok(errs.some((e) => /explanation/.test(e)));
  assert.ok(errs.some((e) => /at least 2 choices/.test(e)));
});

test('detects duplicate stems', () => {
  assert.deepEqual(
    findDuplicateStems([
      { id: 'q-1', stem: 'Same  question?' },
      { id: 'q-2', stem: 'same question ?' },
    ]),
    [['q-1', 'q-2']],
  );
});
```

Create `test/tool/question_studio_validators_test.dart`:

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('question_studio validators pass node:test', () async {
    final result = await Process.run(
      'node',
      ['--test', 'tools/question_studio/validators.test.mjs'],
    );
    expect(result.exitCode, 0,
        reason: '${result.stdout}\n${result.stderr}');
  });
}
```

- [ ] **Step 2: Run to verify failure**

Run: `node --test tools/question_studio/validators.test.mjs`
Expected: FAIL — `validators.mjs` does not exist.

- [ ] **Step 3: Implement `validators.mjs`**

Create `tools/question_studio/validators.mjs`:

```js
export function validateQuestion(q) {
  const errors = [];
  if (!q.stem || !q.stem.trim()) errors.push('stem is empty');
  if (!q.explanation || !q.explanation.trim()) errors.push('explanation is empty');
  const choices = Array.isArray(q.choices) ? q.choices : [];
  if (choices.length < 2) errors.push('needs at least 2 choices');
  if (choices.some((c) => !c.text || !c.text.trim())) errors.push('a choice has empty text');
  const correct = choices.filter((c) => c.correct === true).length;
  if (correct !== 1) errors.push(`exactly one correct answer required (found ${correct})`);
  return errors;
}

const norm = (s) => (s || '').toLowerCase().replace(/\s+/g, ' ').replace(/\s*\?\s*/g, '?').trim();

export function findDuplicateStems(questions) {
  const pairs = [];
  for (let i = 0; i < questions.length; i++) {
    for (let j = i + 1; j < questions.length; j++) {
      if (norm(questions[i].stem) === norm(questions[j].stem)) {
        pairs.push([questions[i].id, questions[j].id]);
      }
    }
  }
  return pairs;
}
```

- [ ] **Step 4: Run both tests to verify they pass**

Run: `node --test tools/question_studio/validators.test.mjs`
Expected: PASS (4 subtests).
Run: `flutter test test/tool/question_studio_validators_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add tools/question_studio/validators.mjs tools/question_studio/validators.test.mjs test/tool/question_studio_validators_test.dart
git commit -m "feat(question_studio): question validators with tests"
```

---

## Task 4: Studio server + UI + launcher

**Files:**
- Create: `tools/question_studio/package.json`
- Create: `tools/question_studio/server.mjs`
- Create: `tools/question_studio/public/index.html`
- Create: `tools/question_studio/prompt_template.md`
- Create: `tools/question_studio/Start Question Studio.command`

**Interfaces:**
- Consumes: `validators.mjs` from Task 3; question YAML files under `content/questions/`; `tools/lesson_author/outline.json`.
- Produces (HTTP): `GET /api/tree`, `GET /api/subtopic?id=<subject>/<topic>/<subtopic>`, `POST /api/subtopic` (writes edited YAML back), static `/` and `/prompt_template.md`.

- [ ] **Step 1: Create `package.json`**

Create `tools/question_studio/package.json`:

```json
{
  "name": "question-studio",
  "private": true,
  "type": "module",
  "dependencies": {
    "yaml": "^2.4.5"
  }
}
```

- [ ] **Step 2: Implement `server.mjs`**

Create `tools/question_studio/server.mjs` (mirrors `tools/lesson_author/server.mjs`; parses/stringifies YAML with the `yaml` package, first-run `npm install`, EADDRINUSE reuse, `--no-open` flag):

```js
// Local question review server. Renders/edits question YAML under
// content/questions/. Mirrors tools/lesson_author/server.mjs.
import { createServer } from 'node:http';
import { readFile, writeFile, mkdir, readdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { spawn } from 'node:child_process';
import { dirname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const PORT = Number(process.env.QSTUDIO_PORT ?? 4323);
const toolDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(toolDir, '..', '..');
const contentRoot = join(repoRoot, 'content', 'questions');

if (!existsSync(join(toolDir, 'node_modules'))) {
  console.log('First run: installing dependencies (yaml)...');
  await new Promise((resolve, reject) => {
    const npm = spawn('npm', ['install', '--no-audit', '--no-fund'], { cwd: toolDir, stdio: 'inherit' });
    npm.on('close', (code) => (code === 0 ? resolve() : reject(new Error(`npm install failed (${code})`))));
  });
}
const YAML = (await import('yaml')).default;

const send = (res, status, payload) => {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(payload));
};

async function buildTree() {
  const tree = [];
  if (!existsSync(contentRoot)) return tree;
  for (const subject of (await readdir(contentRoot, { withFileTypes: true })).filter((d) => d.isDirectory())) {
    const topics = [];
    const subjectDir = join(contentRoot, subject.name);
    for (const topic of (await readdir(subjectDir, { withFileTypes: true })).filter((d) => d.isDirectory())) {
      const subtopics = [];
      const topicDir = join(subjectDir, topic.name);
      for (const file of (await readdir(topicDir, { withFileTypes: true })).filter((d) => d.isFile() && d.name.endsWith('.yaml'))) {
        const doc = YAML.parse(await readFile(join(topicDir, file.name), 'utf8')) ?? {};
        const questions = doc.questions ?? [];
        subtopics.push({
          id: `${subject.name}/${topic.name}/${file.name.replace(/\.yaml$/, '')}`,
          count: questions.length,
          approved: questions.filter((q) => q.approved === true).length,
          figurePending: questions.filter((q) => q.figure).length,
        });
      }
      topics.push({ name: topic.name, subtopics });
    }
    tree.push({ name: subject.name, topics });
  }
  return tree;
}

const yamlPathFor = (id) => {
  const path = normalize(join(contentRoot, `${id}.yaml`));
  if (!path.startsWith(contentRoot)) throw new Error('Invalid path');
  return path;
};

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (c) => { data += c; if (data.length > 5_000_000) reject(new Error('Payload too large')); });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  try {
    if (req.method === 'GET' && url.pathname === '/') {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      return res.end(await readFile(join(toolDir, 'public', 'index.html')));
    }
    if (req.method === 'GET' && url.pathname === '/prompt_template.md') {
      res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
      return res.end(await readFile(join(toolDir, 'prompt_template.md')));
    }
    if (req.method === 'GET' && url.pathname === '/api/tree') {
      return send(res, 200, await buildTree());
    }
    if (req.method === 'GET' && url.pathname === '/api/subtopic') {
      const id = url.searchParams.get('id') ?? '';
      try {
        const doc = YAML.parse(await readFile(yamlPathFor(id), 'utf8'));
        return send(res, 200, doc);
      } catch {
        return send(res, 404, { error: `Not found: ${id}` });
      }
    }
    if (req.method === 'POST' && url.pathname === '/api/subtopic') {
      const { id, doc } = JSON.parse(await readBody(req));
      const path = yamlPathFor(id);
      await mkdir(dirname(path), { recursive: true });
      await writeFile(path, YAML.stringify(doc, { lineWidth: 0 }));
      return send(res, 200, { saved: true });
    }
    res.writeHead(404); res.end('Not found');
  } catch (error) {
    send(res, 500, { error: String(error?.message ?? error) });
  }
});

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.log(`Question Studio already running — opening http://localhost:${PORT}`);
    if (process.platform === 'darwin') spawn('open', [`http://localhost:${PORT}`], { stdio: 'ignore', detached: true }).unref();
    process.exit(0);
  }
  throw error;
});

server.listen(PORT, () => {
  const url = `http://localhost:${PORT}`;
  console.log(`Question Studio running at ${url}`);
  console.log(`Reviewing questions in ${contentRoot}`);
  if (process.platform === 'darwin' && !process.argv.includes('--no-open')) {
    spawn('open', [url], { stdio: 'ignore', detached: true }).unref();
  }
});
```

- [ ] **Step 3: Implement `public/index.html`**

Create `tools/question_studio/public/index.html` — a single page that loads the tree, opens a subtopic, renders each question (correct choice highlighted, explanation, type/difficulty/exam/figure badges), runs `validateQuestion`/`findDuplicateStems` inline, allows editing stem/choice/explanation text and an `approved` checkbox, and POSTs the whole doc back:

```html
<!doctype html>
<meta charset="utf-8" />
<title>Question Studio</title>
<style>
  body { font: 15px/1.5 system-ui, sans-serif; margin: 0; display: flex; height: 100vh; }
  #tree { width: 320px; overflow: auto; border-right: 1px solid #ddd; padding: 12px; }
  #main { flex: 1; overflow: auto; padding: 20px 28px; }
  .st { cursor: pointer; padding: 2px 0; }
  .st.badge::after { content: attr(data-badge); color: #888; font-size: 12px; margin-left: 6px; }
  .q { border: 1px solid #e2e2e2; border-radius: 8px; padding: 14px; margin-bottom: 16px; }
  .q .stem { width: 100%; font-weight: 600; border: 0; resize: vertical; font: inherit; }
  .choice { display: flex; gap: 8px; align-items: center; margin: 3px 0; }
  .choice.correct { background: #e7f6ec; border-radius: 6px; padding: 2px 6px; }
  .choice input[type=text] { flex: 1; border: 1px solid #ddd; border-radius: 4px; padding: 3px 6px; }
  .expl { width: 100%; border: 1px solid #eee; border-radius: 6px; margin-top: 6px; font: inherit; }
  .badges span { font-size: 12px; background: #f0f0f0; border-radius: 4px; padding: 1px 6px; margin-right: 4px; }
  .errors { color: #b00020; font-size: 13px; }
  .figure { color: #a15c00; }
  button { font: inherit; }
</style>
<div id="tree">Loading…</div>
<div id="main"><p>Select a subtopic.</p></div>
<script type="module">
  import { validateQuestion, findDuplicateStems } from '/validators.mjs';
  let current = null; // { id, doc }

  async function loadTree() {
    const tree = await (await fetch('/api/tree')).json();
    const el = document.getElementById('tree');
    el.innerHTML = '';
    for (const s of tree) {
      const h = document.createElement('div'); h.innerHTML = `<b>${s.name}</b>`; el.appendChild(h);
      for (const t of s.topics) {
        const th = document.createElement('div'); th.style.marginLeft = '10px'; th.textContent = t.name; el.appendChild(th);
        for (const st of t.subtopics) {
          const d = document.createElement('div');
          d.className = 'st badge'; d.style.marginLeft = '22px'; d.textContent = st.id.split('/').pop();
          d.dataset.badge = `${st.approved}/${st.count}${st.figurePending ? ` ✎${st.figurePending}` : ''}`;
          d.onclick = () => openSubtopic(st.id);
          el.appendChild(d);
        }
      }
    }
  }

  async function openSubtopic(id) {
    const doc = await (await fetch('/api/subtopic?id=' + encodeURIComponent(id))).json();
    current = { id, doc };
    render();
  }

  function render() {
    const main = document.getElementById('main');
    main.innerHTML = '';
    const dups = findDuplicateStems(current.doc.questions);
    const save = document.createElement('button');
    save.textContent = 'Save'; save.onclick = persist;
    main.appendChild(save);
    if (dups.length) {
      const w = document.createElement('div'); w.className = 'errors';
      w.textContent = 'Duplicate stems: ' + dups.map((p) => p.join(' / ')).join(', ');
      main.appendChild(w);
    }
    current.doc.questions.forEach((q, i) => main.appendChild(questionCard(q, i)));
  }

  function questionCard(q, i) {
    const card = document.createElement('div'); card.className = 'q';
    const badges = document.createElement('div'); badges.className = 'badges';
    badges.innerHTML = `<span>${q.type ?? '?'}</span><span>${q.difficulty ?? '?'}</span>` +
      (current.doc.meta?.exams ?? []).map((e) => `<span>${e}</span>`).join('') +
      (q.figure ? `<span class="figure">figure: ${q.figure}</span>` : '');
    card.appendChild(badges);

    const stem = document.createElement('textarea'); stem.className = 'stem'; stem.rows = 2; stem.value = q.stem ?? '';
    stem.oninput = () => { q.stem = stem.value; revalidate(card, q); };
    card.appendChild(stem);

    (q.choices ?? []).forEach((c) => {
      const row = document.createElement('div'); row.className = 'choice' + (c.correct ? ' correct' : '');
      const radio = document.createElement('input'); radio.type = 'radio'; radio.name = `correct-${i}`; radio.checked = !!c.correct;
      radio.onchange = () => { q.choices.forEach((x) => (x.correct = false)); c.correct = true; render(); };
      const text = document.createElement('input'); text.type = 'text'; text.value = c.text ?? '';
      text.oninput = () => { c.text = text.value; };
      row.append(radio, text); card.appendChild(row);
    });

    const expl = document.createElement('textarea'); expl.className = 'expl'; expl.rows = 2; expl.value = q.explanation ?? '';
    expl.oninput = () => { q.explanation = expl.value; revalidate(card, q); };
    card.appendChild(expl);

    const foot = document.createElement('label');
    const ok = document.createElement('input'); ok.type = 'checkbox'; ok.checked = q.approved === true;
    ok.onchange = () => { q.approved = ok.checked; };
    foot.append(ok, document.createTextNode(' approved'));
    card.appendChild(foot);

    const errs = document.createElement('div'); errs.className = 'errors'; card.appendChild(errs);
    revalidate(card, q);
    return card;
  }

  function revalidate(card, q) {
    card.querySelector('.errors').textContent = validateQuestion(q).join(' · ');
  }

  async function persist() {
    await fetch('/api/subtopic', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: current.id, doc: current.doc }),
    });
    await loadTree();
  }

  loadTree();
</script>
```

Note: the page imports `/validators.mjs`; add a static route for it in `server.mjs` by extending the `GET /` block — serve `tools/question_studio/validators.mjs` at `/validators.mjs` with `Content-Type: text/javascript`. Add this branch before the 404 in `server.mjs`:

```js
    if (req.method === 'GET' && url.pathname === '/validators.mjs') {
      res.writeHead(200, { 'Content-Type': 'text/javascript' });
      return res.end(await readFile(join(toolDir, 'validators.mjs')));
    }
```

- [ ] **Step 4: Implement `prompt_template.md` and launcher**

Create `tools/question_studio/prompt_template.md`:

```markdown
# Question generation brief

Generate one YAML file per subtopic at
content/questions/<subject>/<topic>/<subtopic>.yaml following
docs/content/question-style-guide.md and the subject blueprint in
docs/content/question-blueprints/<subject>.md.

Rules:
- Stem: authentic UPCAT/DOST exam wording and difficulty.
- Explanation: simple Grade 4–6 English; say why the answer is right and
  why the main distractor is wrong.
- Cover every archetype in the blueprint × 2–3 variants, ramped easy→exam.
- Exactly one correct choice; 4 choices; plausible mistake-based distractors.
- id: q-<topicSlug>-<subtopicSlug>-NNNN, numbered easy→hard.
- Figure-dependent items: add `figure: <slug>` and list the slug for the
  question-figures worklist.
```

Create `tools/question_studio/Start Question Studio.command` (mirror the lesson tool's launcher; make executable with `chmod +x`):

```bash
#!/bin/bash
cd "$(dirname "$0")"
node server.mjs
```

- [ ] **Step 5: Manual smoke test**

Run: `node tools/question_studio/server.mjs --no-open` then in another shell `curl -s localhost:4323/api/tree`
Expected: JSON array (empty `[]` until Task 6 adds content, or the science/biology tree if run after). Stop the server (Ctrl+C).
Run: `node --check tools/question_studio/server.mjs`
Expected: no output, exit 0 (syntax valid).

- [ ] **Step 6: Commit**

```bash
chmod +x "tools/question_studio/Start Question Studio.command"
git add tools/question_studio/package.json tools/question_studio/server.mjs tools/question_studio/public tools/question_studio/prompt_template.md "tools/question_studio/Start Question Studio.command"
git commit -m "feat(question_studio): review server and single-page UI"
```

---

## Task 5: Authoring docs (style guide, runbook, blueprints, figures worklist)

**Files:**
- Create: `docs/content/question-style-guide.md`
- Create: `docs/content/question-authoring-runbook.md`
- Create: `docs/content/question-blueprints/science.md`
- Create: `docs/content/question-blueprints/reasoning.md`
- Create: `docs/content/question-blueprints/language-proficiency.md`
- Create: `docs/content/question-figures/worklist.tsv`

- [ ] **Step 1: Write `question-style-guide.md`**

Encode the format contract exactly as in the spec's "One file per subtopic — YAML format" section: file path pattern; `meta` keys (`subject`, `topic`, `subtopic`, `exams`); per-question keys (`id`, `type`, `difficulty`, `stem`, `choices[].text/.correct`, `explanation`, optional `figure`, `approved`); rules (exactly one correct, 4 choices default, block scalars for stem/explanation, difficulty ∈ {easy,medium,hard,exam}, id pattern `q-<topicSlug>-<subtopicSlug>-NNNN` ascending with difficulty). State the two-level voice rule: stem at exam difficulty, explanation in Grade 4–6 English. Include the exact YAML example from the spec.

- [ ] **Step 2: Write `question-authoring-runbook.md`**

Steps to author a subtopic: pick the outline lesson (subject/topic/lesson from `tools/lesson_author/outline.json`); read the subject blueprint; look up the topic's exams from `docs/content/audit/benchmarks/` and set `meta.exams`; generate archetypes × 2–3 variants ramped by difficulty; run `dart run tools/import_questions/import_questions.dart --root content/questions` to validate; review/approve in Question Studio. Include a **topic → exams table** built from `docs/content/audit/` (list each in-scope topic with its `exams` codes drawn from the benchmark files: `upcat`, `acet`, `dlsucet`, `ustet`, `dost-sei`, `cse`).

- [ ] **Step 3: Write the three blueprint files**

Each blueprint lists the subject's question-type archetypes (verbatim from the spec's "Per-subject question-type blueprints" section) and the difficulty ramp, with one concrete example stem+choices+explanation per archetype so generation has a model. `reasoning.md` marks spatial-abstract and mechanical archetypes as figure-pending.

- [ ] **Step 4: Seed the figures worklist**

Create `docs/content/question-figures/worklist.tsv` with a header row only:

```tsv
slug	subject	topic	subtopic	question_id	status
```

- [ ] **Step 5: Commit**

```bash
git add docs/content/question-style-guide.md docs/content/question-authoring-runbook.md docs/content/question-blueprints docs/content/question-figures
git commit -m "docs: question authoring style guide, runbook, and blueprints"
```

---

## Task 6: Pilot — Biology → Cell Structure, end-to-end

**Files:**
- Create: `content/questions/science/biology/cell-structure.yaml`
- Modify: `docs/content/question-figures/worklist.tsv` (append any figure slugs)

- [ ] **Step 1: Author the pilot subtopic**

Write `content/questions/science/biology/cell-structure.yaml` with `meta` (`subject: science`, `topic: biology`, `subtopic: cell-structure`, `exams:` from the runbook table) and ~12–20 questions covering the Science blueprint archetypes × 2–3 variants, ramped easy→exam, ids `q-biology-cell-structure-0001…`. Keep the pilot **figure-free** (no `figure:` keys) so it is fully shippable and verifiable in-app. Follow `docs/content/question-style-guide.md`.

- [ ] **Step 2: Validate via the importer**

Run: `dart run tools/import_questions/import_questions.dart --root content/questions`
Expected: exit 0; NDJSON with one line per question, each `"_type":"question"`.

- [ ] **Step 3: Review in Question Studio**

Run: `node "tools/question_studio/Start Question Studio.command"` (or `node tools/question_studio/server.mjs`). Open the Biology → cell-structure subtopic; confirm each question renders, the correct choice is highlighted, no validator errors, no duplicate-stem warnings. Fix in-tool, Save, and re-run Step 2 until clean. Mark all approved.

- [ ] **Step 4: Build a local content DB and run the app**

```bash
dart run tools/import_questions/import_questions.dart --root content/questions --seed-json build/questions_seed.json
dart run tools/build_content_seed/seed_writer.dart build/questions_seed.json assets/seed/content.db
flutter run --flavor dev -t lib/main_dev.dart
```

In the running app (emulator `pantas_pixel`), navigate to the Biology topic drill and confirm the pilot questions appear with their choices, correct-answer feedback, and explanations. (This exercises the real `QuestionRepo` → `QuestionCard` path with no Sanity dependency.)

Expected: pilot questions render and are answerable. Note any rendering gaps (e.g. long stems) but do not fix the renderer here — that is deferred spec "E".

- [ ] **Step 5: Restore the seed artifact**

`assets/seed/content.db` is a build artifact; revert any local change so it is not committed:

Run: `git checkout -- assets/seed/content.db 2>/dev/null || rm -f assets/seed/content.db`
Expected: working tree clean except the new YAML.

- [ ] **Step 6: Commit the pilot content**

```bash
git add content/questions/science/biology/cell-structure.yaml docs/content/question-figures/worklist.tsv
git commit -m "content: pilot question set for Biology cell structure"
```

- [ ] **Step 7: Full test sweep**

Run: `flutter test test/tool/`
Expected: PASS. Confirms the pipeline is green before mass generation.

---

## Self-Review

**Spec coverage:**
- YAML format → Task 1 (converter) + Task 5 (style guide). ✓
- Subtopic = lesson id, shared id convention → Task 1 `ids.dart`. ✓
- Exam tags from audit → Task 5 runbook table + `meta.exams`. ✓
- Difficulty authoring-only (never emitted) → Task 1 (`difficulty` absent from doc; test asserts it). ✓
- Figures: author now, `isActive:false`, worklist → Task 1 (inactive), Task 5 (worklist), Task 6 (append). ✓
- Per-subject blueprints → Task 5. ✓
- Coverage model (archetypes × 2–3) → Task 5 blueprints + Task 6 pilot. ✓
- `import_questions` (NDJSON + seed-json, loud failures) → Task 2. ✓
- Question Studio (tree/render/validate/approve/edit) → Tasks 3–4. ✓
- Pilot end-to-end incl. app verification → Task 6. ✓
- RC/renderer/templated-math deferral → out of scope; not tasked (correct). ✓

**Placeholder scan:** No TBD/TODO; all code blocks concrete; docs tasks specify exact content to encode rather than "write docs." ✓

**Type consistency:** `questionToDoc(Map, QuestionMeta, {updatedAt})`, `QuestionMeta` fields, and id helpers are used identically in Tasks 1–2. Studio `validateQuestion`/`findDuplicateStems` signatures match across Tasks 3–4. CLI flags `--root`/`--seed-json` consistent across Task 2 and Task 6. ✓
