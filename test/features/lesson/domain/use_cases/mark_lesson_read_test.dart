import 'package:pantas/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:pantas/features/lesson/domain/use_cases/mark_lesson_read.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProgress extends Mock implements LessonProgressRepository {}

void main() {
  late _MockProgress progress;
  late MarkLessonRead useCase;

  setUp(() {
    progress = _MockProgress();
    useCase = MarkLessonRead(progress);
    when(() => progress.markRead(any())).thenAnswer((_) async {});
  });

  test('calls markRead with the correct lesson ID', () async {
    await useCase('l1');
    verify(() => progress.markRead('l1')).called(1);
  });
}
