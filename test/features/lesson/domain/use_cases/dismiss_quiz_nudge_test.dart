import 'package:cse_cet_reviewer/core/storage/data/repos/quiz_nudge_repository.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/dismiss_quiz_nudge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
