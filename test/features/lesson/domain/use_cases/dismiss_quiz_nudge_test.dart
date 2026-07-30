import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/data/repos/quiz_nudge_repository.dart';
import 'package:pantas/features/lesson/domain/use_cases/dismiss_quiz_nudge.dart';

class _MockNudge extends Mock implements QuizNudgeRepository {}

void main() {
  late _MockNudge nudge;
  late DismissQuizNudge useCase;

  setUp(() {
    nudge = _MockNudge();
    useCase = DismissQuizNudge(nudge);
    when(() => nudge.markDismissed()).thenAnswer((_) async {});
  });

  test('calls markDismissed on the repository', () async {
    await useCase();
    verify(() => nudge.markDismissed()).called(1);
  });
}
