import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/progress/application/record_provider.dart';
import 'package:pantas/features/progress/presentation/pages/your_record_page.dart';
import 'package:pantas/features/progress/presentation/progress_page.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final fullRecord = StudentRecord(
    weeksIn: 3,
    dayStreak: 5,
    streakStartedOn: DateTime(2026, 5, 12),
    questionsAnswered: 150,
    sessionMinutes: 45,
    lessonsRead: 12,
    daysActive: 18,
    longestStreak: 7,
    bestMockPercent: 68,
    accuracySeries: [
      (weekStart: DateTime(2026, 5), accuracy: 55.0),
      (weekStart: DateTime(2026, 5, 8), accuracy: 68.0),
    ],
    mocks: [
      (
        takenOn: DateTime(2026, 5, 20),
        percent: 68,
        blueprintName: 'UPCAT Full Mock',
      ),
    ],
  );

  final recordWithNoMock = StudentRecord(
    weeksIn: 3,
    dayStreak: 5,
    streakStartedOn: DateTime(2026, 5, 12),
    questionsAnswered: 150,
    sessionMinutes: 45,
    lessonsRead: 12,
    daysActive: 18,
    longestStreak: 7,
    bestMockPercent: null,
    accuracySeries: const [],
    mocks: const [],
  );

  const recordWithNoStreakStart = StudentRecord(
    weeksIn: 3,
    dayStreak: 5,
    streakStartedOn: null,
    questionsAnswered: 150,
    sessionMinutes: 45,
    lessonsRead: 12,
    daysActive: 18,
    longestStreak: 7,
    bestMockPercent: null,
    accuracySeries: [],
    mocks: [],
  );

  Widget harness({required StudentRecord record, bool isPro = false}) {
    final entitlement = isPro
        ? Entitlement(
            plan: EntitlementPlan.monthly,
            expiresAt: DateTime.now().add(const Duration(days: 30)),
          )
        : const Entitlement.free();

    return ProviderScope(
      overrides: [
        recordProvider.overrideWith((ref) async => record),
        entitlementProvider.overrideWith(
          (ref) => Stream.value(entitlement),
        ),
      ],
      child: MaterialApp(
        theme: buildLightTheme(),
        home: const YourRecordPage(),
      ),
    );
  }

  Widget tabHarness({required StudentRecord record}) {
    final exam = buildExam(
      id: 'exam_upcat',
      code: 'UPCAT',
      name: 'College Admissions Test',
      shortName: 'UPCAT',
    );

    final router = GoRouter(
      initialLocation: '/progress',
      routes: [
        GoRoute(
          path: '/progress',
          builder: (_, __) => const ProgressPage(),
        ),
        GoRoute(
          path: '/progress/your-record',
          builder: (_, __) => const YourRecordPage(),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        activeExamFocusProvider.overrideWith(
          (ref) async => ActiveExamFocus.selected(exam),
        ),
        countForExamProvider(exam.id).overrideWith((ref) async => 10),
        recordProvider.overrideWith((ref) async => record),
        entitlementProvider.overrideWith(
          (ref) => Stream.value(const Entitlement.free()),
        ),
      ],
      child: MaterialApp.router(
        theme: buildLightTheme(),
        routerConfig: router,
      ),
    );
  }

  testWidgets('four panels in the spec order', (tester) async {
    await tester.pumpWidget(harness(record: fullRecord));
    await tester.pumpAndSettle();

    final ys = [
      'Since you started',
      'Your totals',
      'Accuracy across your prep',
      'Your mocks',
    ].map((t) => tester.getTopLeft(find.text(t)).dy).toList();
    expect(ys, orderedEquals(List<double>.from(ys)..sort()));
  });

  testWidgets('the label is time in sessions, never time studied',
      (tester) async {
    await tester.pumpWidget(harness(record: fullRecord));
    await tester.pumpAndSettle();

    expect(find.text('time in sessions'), findsOneWidget);
    expect(find.textContaining('time studied'), findsNothing);
  });

  testWidgets('with no mock, the panel and the row are absent, not empty',
      (tester) async {
    await tester.pumpWidget(harness(record: recordWithNoMock));
    await tester.pumpAndSettle();

    expect(find.text('Your mocks'), findsNothing);
    expect(find.text('best mock'), findsNothing);
    expect(find.text('0%'), findsNothing);
    expect(find.textContaining('none yet'), findsNothing);
  });

  testWidgets('the subtitle drops the mock clause when there is no mock',
      (tester) async {
    await tester.pumpWidget(tabHarness(record: recordWithNoMock));
    await tester.pumpAndSettle();

    expect(find.textContaining('Best mock'), findsNothing);
    expect(find.text('18 days active'), findsOneWidget);
  });

  testWidgets('milestones are absent even though the data exists',
      (tester) async {
    await tester.pumpWidget(harness(record: fullRecord));
    await tester.pumpAndSettle();
    expect(find.text('Milestones'), findsNothing);
  });

  testWidgets('wholly free: no teaser and no redaction on either tier',
      (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(harness(record: fullRecord, isPro: isPro));
      await tester.pumpAndSettle();

      expect(find.text('Unlock with Pro'), findsNothing);
      expect(find.byType(FaintBars), findsNothing);
    }
  });

  testWidgets('no streak start date renders no line, not a null',
      (tester) async {
    await tester.pumpWidget(harness(record: recordWithNoStreakStart));
    await tester.pumpAndSettle();

    expect(find.textContaining('null'), findsNothing);
    expect(find.textContaining('since'), findsNothing);
  });

  testWidgets('the tab row opens it with push', (tester) async {
    await tester.pumpWidget(tabHarness(record: fullRecord));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Your record'));
    await tester.pumpAndSettle();

    expect(find.byType(YourRecordPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });
}
