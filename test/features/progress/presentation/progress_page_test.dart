import 'dart:async';

import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/progress_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

Widget harness({bool hasAttempts = true, String? examId = 'cse'}) {
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
      if (examId != null)
        countForExamProvider(examId).overrideWith((ref) async {
          return hasAttempts ? 5 : 0;
        }),
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
  testWidgets('opens on the diagnosis, with Go deeper last', (tester) async {
    await tester.pumpApp(harness(hasAttempts: true));
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
    await tester.pumpApp(harness(hasAttempts: true));
    await tester.pumpAndSettle();
    expect(find.text('Milestones'), findsNothing);
    expect(find.textContaining('Charts land here'), findsNothing);
  });

  testWidgets('no banned word appears anywhere', (tester) async {
    await tester.pumpApp(harness(hasAttempts: true));
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
}
