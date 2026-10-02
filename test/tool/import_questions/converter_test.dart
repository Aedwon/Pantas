import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/sanity/parsers/question_parser.dart';
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
  final missingNotes = <String, Map<String, Object?>>{
    'missing': {},
    'null': {'rationale': null},
    'empty': {'rationale': ''},
    'whitespace-only': {'rationale': ' \t\n '},
  };
  for (final entry in missingNotes.entries) {
    test('rejects ${entry.key} wrong-choice rationale', () {
      expect(
        () => questionToDoc(
          {
            'id': 'q-required-note',
            'stem': 'Which organelle makes food using light?',
            'explanation': 'Chloroplasts use light to make food.',
            'choices': [
              {'text': 'Chloroplast', 'correct': true},
              {
                'text': 'Mitochondrion',
                'rationale': 'This uses food instead of making it.',
              },
              {'text': 'Ribosome', 'correct': false, ...entry.value},
            ],
          },
          _meta,
          updatedAt: _updatedAt,
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('q-required-note'),
              contains('choice 3'),
              contains('rationale'),
            ),
          ),
        ),
      );
    });
  }

  for (final correct in [false, true]) {
    test('rejects non-string rationale when correct is $correct', () {
      expect(
        () => questionToDoc(
          {
            'id': 'q-non-string-note',
            'stem': 'Pick the correct choice.',
            'explanation': 'Only one choice is correct.',
            'choices': [
              {'text': 'First', 'correct': correct, 'rationale': 42},
              {
                'text': 'Second',
                'correct': !correct,
                'rationale': 'This is the wrong choice.',
              },
            ],
          },
          _meta,
          updatedAt: _updatedAt,
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            'q-non-string-note: choice 1 rationale must be a string',
          ),
        ),
      );
    });
  }

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
    rationale: '  This uses food instead of making it.  '
  - text: Ribosome
    rationale: This makes proteins instead of food.
  - text: Golgi apparatus
    rationale: This packs materials instead of making food.
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
    expect(parsed.choices.first.rationale.value, isNull);
    expect(
      parsed.choices.skip(1).map((c) => c.rationale.value),
      [
        'This uses food instead of making it.',
        'This makes proteins instead of food.',
        'This packs materials instead of making food.',
      ],
    );
    expect(
      parsed.examLinks.map((e) => e.examId.value),
      ['exam-upcat', 'exam-dost-sei'],
    );
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
    rationale: This stores materials instead of holding DNA.
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
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('q-biology-cell-structure-0003'),
        ),
      ),
    );
  });

  // The em dash is banned across the project. It reached 1,402 occurrences in
  // 81 question files before anything checked for it, because the only tool
  // that counted them reported a warning and failed nothing.
  test('an em dash in a stem is rejected', () {
    expect(
      () => questionToDoc(
        _yaml('''
id: q_emdash_stem
stem: A cell wall is rigid — unlike a membrane.
explanation: Cellulose gives it structure.
choices:
  - text: Rigid
    correct: true
  - text: Flexible
'''),
        _meta,
        updatedAt: _updatedAt,
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('q_emdash_stem'), contains('em dash')),
        ),
      ),
    );
  });

  test('an em dash in an explanation is rejected', () {
    expect(
      () => questionToDoc(
        _yaml('''
id: q_emdash_expl
stem: What makes a cell wall rigid?
explanation: Cellulose — a long chain sugar — gives it structure.
choices:
  - text: Cellulose
    correct: true
  - text: Water
'''),
        _meta,
        updatedAt: _updatedAt,
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('an em dash in a choice is rejected', () {
    expect(
      () => questionToDoc(
        _yaml('''
id: q_emdash_choice
stem: What makes a cell wall rigid?
explanation: Cellulose gives it structure.
choices:
  - text: Cellulose — a sugar
    correct: true
  - text: Water
'''),
        _meta,
        updatedAt: _updatedAt,
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('an en dash and a hyphen are both left alone', () {
    expect(
      () => questionToDoc(
        _yaml('''
id: q_dashes_ok
stem: Is a cell wall 10–20 nanometres thick?
explanation: A well-known range, 10–20 nanometres.
choices:
  - text: 10-20 nanometres
    correct: true
  - text: 200 nanometres
    rationale: This is outside the stated range.
'''),
        _meta,
        updatedAt: _updatedAt,
      ),
      returnsNormally,
    );
  });
}
