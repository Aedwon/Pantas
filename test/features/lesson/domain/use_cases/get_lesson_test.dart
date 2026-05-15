import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/get_lesson.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockContent extends Mock implements ContentRepository {}

void main() {
  late _MockContent content;
  late GetLesson useCase;

  const lesson = Lesson(
    id: 'l1',
    topicId: 't1',
    title: 'Test Lesson',
    summary: 'Summary',
    bodyJson: [],
    estimatedMinutes: 3,
  );

  setUp(() {
    content = _MockContent();
    useCase = GetLesson(content);
  });

  test('returns Lesson when found', () async {
    when(() => content.lessonById('l1')).thenAnswer((_) async => lesson);
    final result = await useCase('l1');
    expect(result.id, equals('l1'));
    expect(result.title, equals('Test Lesson'));
  });

  test('throws StateError when lesson is not found', () async {
    when(() => content.lessonById('missing')).thenAnswer((_) async => null);
    expect(() => useCase('missing'), throwsStateError);
  });
}
