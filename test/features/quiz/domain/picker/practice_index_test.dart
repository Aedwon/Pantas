import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';

PracticeLessonEntry lesson(
  String id, {
  bool isRead = false,
  int questionCount = 4,
}) =>
    PracticeLessonEntry(
      id: id,
      title: 'Lesson $id',
      isRead: isRead,
      questionCount: questionCount,
    );

void main() {
  test('a topic with questions can be selected', () {
    const topic = PracticeTopicEntry(
      id: 'topic_algebra',
      name: 'Algebra',
      questionCount: 12,
      lessons: [],
    );

    expect(topic.hasQuestions, isTrue);
  });

  test('a topic with no questions cannot be selected', () {
    const topic = PracticeTopicEntry(
      id: 'topic_algebra',
      name: 'Algebra',
      questionCount: 0,
      lessons: [],
    );

    expect(topic.hasQuestions, isFalse);
    expect(topic.canUnfold, isFalse);
  });

  test('a topic whose lessons hold no tagged questions cannot unfold', () {
    final topic = PracticeTopicEntry(
      id: 'topic_algebra',
      name: 'Algebra',
      questionCount: 12,
      lessons: [lesson('l_1', questionCount: 0)],
    );

    expect(topic.canUnfold, isFalse);
  });

  test('a topic with one tagged lesson can unfold', () {
    final topic = PracticeTopicEntry(
      id: 'topic_algebra',
      name: 'Algebra',
      questionCount: 12,
      lessons: [lesson('l_1'), lesson('l_2', questionCount: 0)],
    );

    expect(topic.canUnfold, isTrue);
  });
}
