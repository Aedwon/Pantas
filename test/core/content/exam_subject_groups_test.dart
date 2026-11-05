import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/exam_subject_groups.dart';
import 'package:pantas/core/metrics/overall_accuracy.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';

void main() {
  const subjects = [
    Subject(id: 'math', examId: 'exam_upcat', name: 'Mathematics', ordering: 0),
  ];
  const names = [
    'Algebra',
    'Data Interpretation',
    'Vocabulary',
    'Philippine Constitution',
    'Clerical Ability',
    'Geometry',
  ];
  final topics = [
    for (final (index, name) in names.indexed)
      Topic(id: 'topic_$index', subjectId: 'math', name: name, ordering: index),
  ];

  for (final (examId, expected) in [
    (
      'exam_cse_pro',
      [
        'General Information',
        'Verbal Ability',
        'Analytical Ability',
        'Numerical Ability',
      ]
    ),
    (
      'exam_cse_sub',
      [
        'General Information',
        'Verbal Ability',
        'Numerical Ability',
        'Clerical Ability',
      ]
    ),
  ]) {
    test('$examId never falls back to a corpus subject heading', () {
      final groups = examSubjectGroups(
        examId: examId,
        subjects: subjects,
        topics: topics,
      );
      expect(groups.map((g) => g.name), expected);
      expect(
        groups.expand((g) => g.topics).map((t) => t.name),
        isNot(contains('Geometry')),
      );
      final algebra = groups.expand((g) => g.topics).firstWhere(
            (t) => t.name == 'Algebra',
          );
      expect(identical(algebra, topics.first), isTrue);
      expect(algebra.subjectId, 'math');
    });
  }

  test('another exam keeps its subjects and topic order', () {
    final groups = examSubjectGroups(
      examId: 'exam_upcat',
      subjects: subjects,
      topics: topics,
    );
    expect(groups.single.id, 'math');
    expect(groups.single.name, 'Mathematics');
    expect(groups.single.topics, topics);
  });

  test('Data Interpretation keeps its weighted Analytical rating', () {
    final accuracy = OverallAccuracy.fromTopics(
      examId: 'exam_cse_pro',
      topics: const [
        (topicId: 'topic_cse_pro_data_interpretation', correct: 1, answered: 1),
        (topicId: 'topic_cse_pro_algebra', correct: 0, answered: 9),
        (topicId: 'topic_upcat_text_types', correct: 1, answered: 2),
        (
          topicId: 'topic_cse_pro_philippine_constitution',
          correct: 0,
          answered: 1,
        ),
      ],
    );
    expect(accuracy.value, .5);
  });
}
