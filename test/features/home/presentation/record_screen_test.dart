import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/home/presentation/record_screen.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';

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
}
