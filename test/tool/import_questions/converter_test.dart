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
      throwsA(isA<FormatException>().having((e) => e.message, 'message',
          contains('q-biology-cell-structure-0003'))),
    );
  });
}
