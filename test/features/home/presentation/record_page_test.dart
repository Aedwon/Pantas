import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/home/presentation/record_page.dart';

void main() {
  const record = StudentRecord(
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
  );
  testWidgets(
      'record uses singular week, measured time and early line placeholder',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: RecordPage(
          record: record,
          mocks: const [],
          onBack: () {},
          onMock: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('week in'), findsOneWidget);
    expect(find.text('35h 30m'), findsOneWidget);
    expect(
      find.text('Your line starts after two weeks of answers.'),
      findsOneWidget,
    );
    expect(find.text('best mock'), findsNothing);
    expect(find.text('Your mocks'), findsNothing);
  });
  testWidgets('mock rows and extension follow actual history', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: RecordPage(
          record: record,
          mocks: [
            RecordMockRow(
              id: 'm',
              name: 'CSE simulation',
              date: DateTime(2026, 10, 24),
              percent: 64,
            ),
          ],
          wrappedRow: const Text('Accepted extension'),
          onBack: () {},
          onMock: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('CSE simulation'), 200);
    expect(find.text('64%'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Accepted extension'), 200);
    expect(find.text('Accepted extension'), findsOneWidget);
  });
}
