import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
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
      find.text('Your line starts after two weeks with answers.'),
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

  // P10/U60: "this week" only when the last point is the current week.
  StudentRecord withLine({required bool current}) => StudentRecord(
        weeksIn: 6,
        dayStreak: 2,
        streakStartedOn: null,
        questionsAnswered: 38,
        sessionMinutes: 2130,
        lessonsRead: 3,
        daysActive: 2,
        longestStreak: 2,
        bestMockPercent: null,
        accuracySeries: [
          (weekStart: DateTime(2026, 9, 6), accuracy: 52),
          (weekStart: DateTime(2026, 11), accuracy: 61),
        ],
        latestWeekIsCurrent: current,
        mocks: const [],
      );

  for (final wide in [false, true]) {
    final where = wide ? 'wide' : 'phone';
    Future<void> pumpRecord(WidgetTester tester, StudentRecord record) async {
      if (wide) {
        debugWebPlatformOverride = true;
        tester.view.physicalSize = const Size(1440, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(() => debugWebPlatformOverride = null);
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: wide ? buildLightTheme(web: true) : buildLightTheme(),
          home: RecordPage(
            record: record,
            mocks: const [],
            onBack: () {},
            onMock: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('$where: the last week says this week only when it is',
        (tester) async {
      await pumpRecord(tester, withLine(current: true));
      expect(find.text('this week'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.textContaining('week of'), findsNothing);
    });

    testWidgets('$where: an older last week shows its start date',
        (tester) async {
      await pumpRecord(tester, withLine(current: false));
      expect(find.text('61%'), findsOneWidget);
      expect(find.text('week of Nov 1'), findsOneWidget);
      expect(find.text('Nov 1'), findsOneWidget);
      expect(find.text('Sep 6'), findsOneWidget);
      expect(find.text('this week'), findsNothing);
      expect(find.text('This week'), findsNothing);
    });
  }
}
