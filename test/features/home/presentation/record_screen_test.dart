import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/home/presentation/record_screen.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

void main() {
  testWidgets(
      'record route displays stored totals and waits for actual mock history',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordProvider.overrideWith(
            (_) async => const StudentRecord(
              weeksIn: 1,
              dayStreak: 2,
              streakStartedOn: null,
              questionsAnswered: 38,
              sessionMinutes: 2130,
              lessonsRead: 3,
              daysActive: 2,
              longestStreak: 2,
              bestMockPercent: null,
              accuracySeries: [],
              mocks: [],
            ),
          ),
          mockHistoryProvider.overrideWith((_) => Stream.value([])),
        ],
        child:
            MaterialApp(theme: buildLightTheme(), home: const RecordScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your record'), findsOneWidget);
    expect(find.text('35h 30m'), findsOneWidget);
    expect(find.text('Your mocks'), findsNothing);
  });
  // The web keeps a mock's time in UTC. The row must show the device's day,
  // as the results screen does, not the UTC day.
  for (final utc in [
    DateTime.utc(2026, 11, 26, 3),
    DateTime.utc(2026, 11, 25, 22),
  ]) {
    testWidgets('a mock taken at $utc shows the local day', (tester) async {
      tester.view
        ..physicalSize = const Size(800, 3000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final attempt = MockAttempt(
        id: 'mock_1',
        userId: 'u',
        examId: 'exam_cse_pro',
        blueprintId: 'bp',
        blueprintName: 'CSE Professional',
        durationMinutes: 180,
        status: MockAttemptStatus.completed,
        strictMode: false,
        sampledQuestionsJson: '[]',
        elapsedSeconds: 600,
        accumulatedPausedSeconds: 0,
        pausedAtLastFlush: false,
        answersJson: '{}',
        flagsJson: '[]',
        currentIndex: 0,
        startedAt: utc,
        lastFlushedAt: utc,
        updatedAt: utc,
        submittedAt: utc,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recordProvider.overrideWith(
              (_) async => const StudentRecord(
                weeksIn: 1,
                dayStreak: 0,
                streakStartedOn: null,
                questionsAnswered: 9,
                sessionMinutes: 10,
                lessonsRead: 0,
                daysActive: 1,
                longestStreak: 0,
                bestMockPercent: 80,
                accuracySeries: [],
                mocks: [],
              ),
            ),
            mockHistoryProvider.overrideWith(
              (_) => Stream.value([
                MockHistoryEntry(
                  attempt: attempt,
                  results: const MockResults(
                    scoreRaw: 8,
                    scoreTotal: 10,
                    percent: 80,
                    sections: [],
                    topWeak: [],
                    totalTimeSeconds: 600,
                    wasStrict: false,
                  ),
                ),
              ]),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const RecordScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(DateFormat('MMM d, y', 'en_US').format(utc.toLocal())),
        findsOneWidget,
      );
    });
  }
}
