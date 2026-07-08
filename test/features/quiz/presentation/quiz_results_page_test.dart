import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_results_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockAttempts extends Mock implements AttemptsRepository {}

void main() {
  testWidgets('renders practice review from a stored Attempt', (tester) async {
    final attempts = _MockAttempts();
    when(() => attempts.byId('a1')).thenAnswer(
      (_) async => Attempt(
        id: 'a1',
        examId: 'e',
        startedAt: DateTime.utc(2026, 5, 9, 12),
        completedAt: DateTime.utc(2026, 5, 9, 12, 5),
        items: const [
          AttemptItem(
            questionId: 'q1',
            questionVersion: 1,
            chosenChoiceId: 'c_a',
            correctChoiceId: 'c_a',
            responseMs: 1500,
          ),
          AttemptItem(
            questionId: 'q2',
            questionVersion: 1,
            chosenChoiceId: 'c_a',
            correctChoiceId: 'c_b',
            responseMs: 4200,
          ),
        ],
      ),
    );

    await tester.pumpAppWithProviders(
      const QuizResultsPage(attemptId: 'a1'),
      overrides: [
        attemptsRepositoryProvider.overrideWithValue(attempts),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('All questions'), findsOneWidget);
  });
}
