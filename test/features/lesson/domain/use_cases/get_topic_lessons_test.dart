import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/features/lesson/domain/use_cases/get_topic_lessons.dart';

class _MockContent extends Mock implements ContentRepository {}

void main() {
  late _MockContent content;
  late GetTopicLessons useCase;

  Lesson makeLesson(String id) => Lesson(
        id: id,
        topicId: 't1',
        title: 'Lesson $id',
        summary: '',
        bodyJson: const [],
        estimatedMinutes: 5,
      );

  setUp(() {
    content = _MockContent();
    useCase = GetTopicLessons(content);
  });

  test('returns list of lessons for topic', () async {
    final lessons = [makeLesson('l1'), makeLesson('l2')];
    when(() => content.lessonsByTopic('t1')).thenAnswer((_) async => lessons);

    final result = await useCase('t1');
    expect(result, hasLength(2));
    expect(result.first.id, equals('l1'));
  });

  test('returns empty list when topic has no lessons', () async {
    when(() => content.lessonsByTopic('empty')).thenAnswer((_) async => []);

    final result = await useCase('empty');
    expect(result, isEmpty);
  });
}
