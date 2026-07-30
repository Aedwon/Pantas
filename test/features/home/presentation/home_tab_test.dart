import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/stats_band.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_result.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';
import 'package:pantas/features/home/presentation/widgets/home_stats_band.dart';

Widget harness({
  ActiveExamFocus? focus,
  AssessmentResult? result,
  bool throwError = false,
  String? errorString,
}) {
  const examId = 'exam_1';
  final examFocus = focus ??
      const ActiveExamFocus.selected(
        Exam(
          id: examId,
          code: 'UPCAT',
          name: 'UP College Admissions Test',
          shortName: 'UPCAT',
          language: 'en',
          isActive: true,
          subjects: [],
        ),
      );

  final mastheadData = HomeMastheadData(
    name: 'Aedwon',
    examShortName: examFocus.exam?.shortName ?? '',
    examDate: null,
  );

  return ProviderScope(
    overrides: [
      activeExamFocusProvider.overrideWith((ref) async {
        if (throwError) throw Exception(errorString ?? 'PlatformException(42)');
        return examFocus;
      }),
      homeMastheadProvider.overrideWith((ref) async => mastheadData),
      assessmentResultProvider(examId).overrideWith((ref) async {
        if (throwError) throw Exception(errorString ?? 'PlatformException(42)');
        return result;
      }),
      lessonsReadProvider(examId)
          .overrideWith((ref) async => const LessonsRead(read: 10, total: 20)),
    ],
    child: MaterialApp(
      theme: buildLightTheme(),
      home: const HomeTab(),
    ),
  );
}

void main() {
  testWidgets('with a result: masthead, band, and three panel slots',
      (tester) async {
    final result = AssessmentResult(
      examId: 'exam_1',
      completedAt: DateTime(2026, 8, 2),
      topicMasteries: [],
    );
    await tester.pumpWidget(harness(result: result));
    await tester.pumpAndSettle();

    expect(find.byType(HomeMasthead), findsOneWidget);
    expect(find.byType(HomeStatsBand), findsOneWidget);
    expect(find.byType(HomeTab), findsOneWidget);
  });

  testWidgets('with no result: masthead and the assessment invitation, no band',
      (tester) async {
    // ignore: avoid_redundant_argument_values
    await tester.pumpWidget(harness(result: null));
    await tester.pumpAndSettle();

    expect(find.byType(HomeMasthead), findsOneWidget);
    expect(find.text('Build your study plan'), findsOneWidget);
    expect(
      find.text('Take the assessment to find what to study first.'),
      findsOneWidget,
    );
    expect(find.byType(StatsBand), findsNothing);
  });

  testWidgets('with no exam: the choose-exam fallback and no masthead',
      (tester) async {
    await tester.pumpWidget(
      harness(focus: const ActiveExamFocus.needsSelection()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose your exam'), findsOneWidget);
    expect(find.byType(HomeMasthead), findsNothing);
  });

  testWidgets('an error never shows the exception string', (tester) async {
    await tester.pumpWidget(
      harness(throwError: true, errorString: 'PlatformException(42)'),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('PlatformException'), findsNothing);
    expect(
      find.text('Could not load your home. Pull down to try again.'),
      findsOneWidget,
    );
  });
}
