import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('resume sheet shows blueprint elapsed and remaining',
      (tester) async {
    await tester.pumpApp(
      MockResumeSheet(
        attempt: _attempt(elapsedSeconds: 60),
        onResume: () {},
        onDiscard: () {},
      ),
    );

    expect(find.text('CSE Practice'), findsOneWidget);
    expect(find.text('Elapsed 01:00'), findsOneWidget);
    expect(find.text('Remaining 89:00'), findsOneWidget);
  });

  testWidgets('resume and discard actions call handlers', (tester) async {
    var resumed = false;
    var discarded = false;
    await tester.pumpApp(
      MockResumeSheet(
        attempt: _attempt(),
        onResume: () => resumed = true,
        onDiscard: () => discarded = true,
      ),
    );

    await tester.tap(find.text('Resume'));
    await tester.tap(find.text('Discard'));

    expect(resumed, isTrue);
    expect(discarded, isTrue);
  });
}

MockAttempt _attempt({int elapsedSeconds = 0}) {
  final now = DateTime.utc(2026, 5, 20);
  return MockAttempt(
    id: 'mock_1',
    userId: 'user_1',
    examId: 'exam_cse',
    blueprintId: 'bp_cse',
    blueprintName: 'CSE Practice',
    durationMinutes: 90,
    status: MockAttemptStatus.inProgress,
    strictMode: false,
    sampledQuestionsJson: '[]',
    elapsedSeconds: elapsedSeconds,
    accumulatedPausedSeconds: 0,
    pausedAtLastFlush: false,
    answersJson: '{}',
    flagsJson: '[]',
    currentIndex: 0,
    startedAt: now,
    lastFlushedAt: now,
    updatedAt: now,
  );
}
