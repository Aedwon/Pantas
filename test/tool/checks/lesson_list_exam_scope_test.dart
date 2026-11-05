import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/lesson_list_exam_scope.dart';

void main() {
  test('a lesson list with no exam fails', () {
    final found = findUnscopedLessonLists(
      'lib/a.dart',
      'content.lessonsByTopics(topicIds);',
    );
    expect(found.single.acceptedBecause, isNull);
  });

  test('a lesson list scoped to the exam passes', () {
    expect(
      findUnscopedLessonLists(
        'lib/a.dart',
        'content.lessonsByTopics(ids(a), examId: exam.id);',
      ),
      isEmpty,
    );
  });
}
