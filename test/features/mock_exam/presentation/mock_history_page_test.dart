import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('history page shows newest ten attempts and see all state',
      (tester) async {
    await tester.pumpApp(
      MockHistoryPage(
        attempts: [
          for (var i = 0; i < 12; i++)
            _attempt(
              id: 'mock_$i',
              submittedAt: DateTime.utc(2026, 5, 20).subtract(
                Duration(days: i),
              ),
            ),
        ],
      ),
    );

    expect(find.text('Past mocks'), findsOneWidget);
    expect(find.text('mock_0'), findsOneWidget);
    expect(find.text('mock_9'), findsOneWidget);
    expect(find.text('mock_10'), findsNothing);
    expect(find.text('See all'), findsOneWidget);

    await tester.ensureVisible(find.text('See all'));
    await tester.tap(find.text('See all'));
    await tester.pump();
    expect(find.text('mock_10'), findsOneWidget);
  });
}

MockAttempt _attempt({required String id, required DateTime submittedAt}) {
  return MockAttempt(
    id: id,
    userId: 'user_1',
    examId: 'exam_cse',
    blueprintId: 'bp_cse',
    blueprintName: 'CSE Practice',
    durationMinutes: 90,
    status: MockAttemptStatus.completed,
    strictMode: false,
    sampledQuestionsJson: '[]',
    elapsedSeconds: 300,
    accumulatedPausedSeconds: 0,
    pausedAtLastFlush: false,
    answersJson: '{}',
    flagsJson: '[]',
    currentIndex: 0,
    scoreRaw: 7,
    scoreTotal: 10,
    totalTimeSeconds: 300,
    startedAt: submittedAt.subtract(const Duration(minutes: 5)),
    lastFlushedAt: submittedAt,
    submittedAt: submittedAt,
    updatedAt: submittedAt,
  );
}
