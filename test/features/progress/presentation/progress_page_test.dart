import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/features/home/application/how_you_work_provider.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/progress/application/pace_provider.dart';
import 'package:pantas/features/progress/presentation/progress_page.dart';

import '../../../helpers/pump_app.dart';

Widget harness({
  bool hasAttempts = true,
  String? examId = 'cse',
  HowYouWork? howYouWork,
  StudentRecord? record,
}) {
  final exam = buildExam(
    id: 'cse',
    code: 'CSE',
    name: 'Civil Service Exam',
    shortName: 'CSE',
  );

  return ProviderScope(
    overrides: [
      activeExamFocusProvider.overrideWith((ref) async {
        if (examId == null) {
          return const ActiveExamFocus.needsSelection();
        }
        return ActiveExamFocus.selected(exam);
      }),
      if (record != null) recordProvider.overrideWith((ref) async => record),
      if (howYouWork != null)
        howYouWorkProvider.overrideWith((ref) async => howYouWork),
      if (examId != null) ...[
        countForExamProvider(examId).overrideWith((ref) async {
          return hasAttempts ? 5 : 0;
        }),
        paceProvider.overrideWith((ref) async {
          return const PaceReading(
            lessonsRead: 10,
            lessonsTotal: 50,
            daysLeft: 30,
            lessonsPerWeek: 5,
            daysPastExam: null,
            rateToFinishInTime: null,
          );
        }),
      ],
    ],
    child: const ProgressPage(),
  );
}

Widget harnessThatThrows(String errorMsg) {
  final exam = buildExam(
    id: 'cse',
    code: 'CSE',
    name: 'Civil Service Exam',
    shortName: 'CSE',
  );

  return ProviderScope(
    overrides: [
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(exam),
      ),
      countForExamProvider('cse').overrideWith(
        (ref) => Future<int>.error(errorMsg),
      ),
    ],
    child: const ProgressPage(),
  );
}

Widget harnessLoading() {
  final completer = Completer<ActiveExamFocus>();
  return ProviderScope(
    overrides: [
      activeExamFocusProvider.overrideWith((ref) => completer.future),
    ],
    child: const ProgressPage(),
  );
}

void main() {
  for (final (days, best, expected) in <(int, int?, String)>[
    (0, null, '0 days active'),
    (1, null, '1 day active'),
    (9, null, '9 days active'),
    (1, 86, '1 day active. Best mock 86%'),
    (9, 86, '9 days active. Best mock 86%'),
  ]) {
    testWidgets('record subtitle states $expected', (tester) async {
      await tester.pumpApp(
        harness(
          record: StudentRecord(
            weeksIn: 10,
            dayStreak: 3,
            streakStartedOn: null,
            questionsAnswered: 100,
            sessionMinutes: 90,
            lessonsRead: 5,
            daysActive: days,
            longestStreak: 4,
            bestMockPercent: best,
            accuracySeries: const [],
            mocks: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your record'), findsOneWidget);
      expect(find.text(expected), findsOneWidget);
    });
  }

  testWidgets('opens on the diagnosis, with Go deeper last', (tester) async {
    await tester.pumpApp(harness());
    await tester.pumpAndSettle();

    final paceY = tester.getTopLeft(find.text('Your pace')).dy;
    final deeperY = tester.getTopLeft(find.text('Go deeper')).dy;
    expect(paceY, lessThan(deeperY));
  });

  testWidgets('day one shows an invitation and never a zero', (tester) async {
    await tester.pumpApp(harness(hasAttempts: false));
    await tester.pumpAndSettle();

    expect(find.text('Nothing to report yet'), findsOneWidget);
    expect(find.text('Take the assessment'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('an error never shows the exception string', (tester) async {
    await tester.pumpApp(harnessThatThrows('PlatformException(42)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('PlatformException'), findsNothing);
    expect(
      find.text('Could not load your progress. Pull down to try again.'),
      findsOneWidget,
    );
  });

  testWidgets('loading is faint bars, never shimmer or gray blocks',
      (tester) async {
    await tester.pumpApp(harnessLoading());
    await tester.pump();

    expect(find.byType(FaintBars), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('no exam shows the existing fallback', (tester) async {
    await tester.pumpApp(harness(examId: null));
    await tester.pumpAndSettle();
    expect(find.text('Choose your exam'), findsOneWidget);
  });

  testWidgets('milestones are gone', (tester) async {
    await tester.pumpApp(harness());
    await tester.pumpAndSettle();
    expect(find.text('Milestones'), findsNothing);
    expect(find.textContaining('Charts land here'), findsNothing);
  });

  testWidgets('no banned word appears anywhere', (tester) async {
    await tester.pumpApp(harness());
    await tester.pumpAndSettle();

    for (final word in [
      'FSRS',
      'stability',
      'retention',
      'retrievability',
      'algorithm',
      'marks',
      '—',
    ]) {
      expect(find.textContaining(word), findsNothing);
    }
  });

  testWidgets('Go deeper never prints a verdict the app has not measured',
      (tester) async {
    // The subtitle printed the spec's illustrative example, "Night-Owl
    // Sprinter. Sharpest at 9 pm, in 8 minute sits.", whenever there was no
    // archetype and no measured hours, while the page behind it correctly
    // said there was not enough data. Aedwon found the contradiction. The
    // invented figure is the graver half: no figure this project inferred on
    // its own may be printed.
    await tester.pumpApp(
      harness(
        // Nothing measured: no archetype, no hours.
        howYouWork: const HowYouWork(
          name: null,
          archetype: null,
          archetypeLine: null,
          tendencies: [],
          whenYouWork: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Guard the guard: if the section is not on screen this proves nothing.
    expect(find.text('How you work'), findsOneWidget);
    expect(find.textContaining('Night-Owl Sprinter'), findsNothing);
    expect(find.textContaining('9 pm'), findsNothing);
    expect(find.textContaining('8 minute sits'), findsNothing);
  });

  testWidgets('nor does it invent one when the read fails', (tester) async {
    await tester.pumpApp(harnessThatThrows('nope'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Night-Owl Sprinter'), findsNothing);
    expect(find.text('Day 1.'), findsNothing);
  });
}
