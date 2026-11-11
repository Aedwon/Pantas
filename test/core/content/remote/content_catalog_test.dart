import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/content_catalog.dart';
import 'package:pantas/core/content/sanity/parser_exceptions.dart';

Map<String, Object?> exam(String id) => {
      '_id': id,
      '_updatedAt': '2026-01-01T00:00:00.000Z',
      'schemaVersion': 1,
      'isActive': true,
      'code': 'UPCAT',
      'name': 'UP College Admission Test',
      'shortName': 'UPCAT',
      'language': 'en',
      'ordering': 2,
    };

Map<String, Object?> subject(String id, String examId) => {
      '_id': id,
      '_updatedAt': '2026-01-01T00:00:00.000Z',
      'schemaVersion': 1,
      'isActive': true,
      'exam': {'_ref': examId},
      'name': 'Science',
      'ordering': 1,
    };

Map<String, Object?> topic(String id, String subjectId) => {
      '_id': id,
      '_updatedAt': '2026-01-01T00:00:00.000Z',
      'schemaVersion': 1,
      'isActive': true,
      'subject': {'_ref': subjectId},
      'name': 'Biology',
      'ordering': 1,
    };

void main() {
  test('parses the index document', () {
    final index = parseCatalogIndex({
      'id': 'index',
      'exams': [exam('exam_upcat')],
      'subjects': [subject('subj_upcat_science', 'exam_upcat')],
      'topics': [topic('topic_upcat_biology', 'subj_upcat_science')],
      'catalogs': ['exam_upcat'],
    });
    expect(index.exams.single.id.value, 'exam_upcat');
    expect(index.subjects.single.examId.value, 'exam_upcat');
    expect(index.topics.single.subjectId.value, 'subj_upcat_science');
    expect(index.catalogs, ['exam_upcat']);
  });

  test('an index without catalogs lists none', () {
    final index = parseCatalogIndex({'id': 'index'});
    expect(index.exams, isEmpty);
    expect(index.catalogs, isEmpty);
  });

  test('parses an exam catalog with lessons, sets and parts', () {
    final catalog = parseExamCatalog({
      'id': 'exam_upcat',
      'lessons': [
        {
          'id': 'lesson-biology-cells',
          'topic': 'topic_upcat_biology',
          'subtopic': 'subtopic_cells',
          'title': 'Cells',
          'summary': 'Parts of a cell.',
          'estimatedMinutes': 12,
          'ordering': 3,
        },
      ],
      'sets': [
        {
          'id': 'qs-science__biology__cells',
          'topic': 'topic_upcat_biology',
          'subtopic': 'subtopic_cells',
          'lesson': 'lesson-biology-cells',
          'exams': ['exam_upcat'],
          'questions': [
            {'id': 'q1'},
            {'id': 'q2', 'passage': 'p1', 'figure': true},
          ],
        },
      ],
      'parts': ['exam_upcat.math'],
    });
    expect(catalog.id, 'exam_upcat');
    final lesson = catalog.lessons.single;
    expect(lesson.topicId, 'topic_upcat_biology');
    expect(lesson.ordering, 3);
    expect(lesson.isActive, isTrue);
    final set = catalog.sets.single;
    expect(set.id, 'qs-science__biology__cells');
    expect(set.language, 'en');
    expect(set.questions.map((q) => q.id), ['q1', 'q2']);
    expect(set.questions.last.passageId, 'p1');
    expect(set.questions.last.hasFigure, isTrue);
    expect(set.questions.first.hasFigure, isFalse);
    expect(catalog.parts, ['exam_upcat.math']);
  });

  test('accepts references in the object form the export uses', () {
    final catalog = parseExamCatalog({
      'id': 'exam_upcat',
      'sets': [
        {
          'id': 's',
          'topic': {'_ref': 'topic_upcat_biology'},
          'exams': ['exam_upcat'],
          'questions': <Object>[],
        },
      ],
    });
    expect(catalog.sets.single.topicId, 'topic_upcat_biology');
  });

  test('refuses a catalog with a malformed row instead of half loading it', () {
    expect(
      () => parseExamCatalog({
        'id': 'exam_upcat',
        'sets': [
          {'id': 's', 'topic': 't', 'exams': <String>[], 'questions': 'no'},
        ],
      }),
      throwsA(isA<ParseException>()),
    );
    expect(
      () => parseExamCatalog({
        'id': 'exam_upcat',
        'lessons': ['not an object'],
      }),
      throwsA(isA<ParseException>()),
    );
    expect(
      () => parseCatalogIndex({
        'catalogs': [1],
      }),
      throwsA(isA<ParseException>()),
    );
  });
}
