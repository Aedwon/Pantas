import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/settings_group.dart';
import 'package:pantas/core/ui/components/settings_switch.dart';
import 'package:pantas/core/ui/components/settings_value_row.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import 'package:pantas/features/settings/presentation/pages/change_exam_page.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  final upcat = buildExam(
    id: 'exam_upcat',
    code: 'UPCAT',
    shortName: 'UPCAT',
    name: 'UP College Admissions Test',
  );
  final dost = buildExam(
    id: 'exam_dost',
    code: 'DOST',
    shortName: 'DOST',
    name: 'DOST Scholarship Exam',
  );

  List<Override> createOverrides({
    Exam? activeExam,
    bool carryOverProgress = true,
  }) {
    final exam = activeExam ?? upcat;
    final db = inMemoryDatabase();
    addTearDown(db.close);
    return [
      appDatabaseProvider.overrideWithValue(db),
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(exam),
      ),
      examListProvider.overrideWith(
        (ref) async => [upcat, dost],
      ),
      userSettingsProvider.overrideWith(
        (ref) async => UserSettings(
          name: 'Student',
          dailyReminderTime: null,
          examDate: null,
          strictMockMode: false,
          helpImproveApp: true,
          carryOverProgress: carryOverProgress,
          sessionOrdering: SessionOrdering.interleavedTail,
          retainTableOrder: true,
          updatedAt: null,
        ),
      ),
    ];
  }

  testWidgets('the heading is the exam name and there are three rows',
      (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<SettingsGroup>(find.byType(SettingsGroup)).title,
      'UPCAT',
    );
    expect(find.byType(SettingsValueRow), findsNWidgets(3));
    expect(find.text('Change exam'), findsOneWidget);
    expect(find.text('Carry over progress'), findsOneWidget);
    expect(find.text("What's included"), findsOneWidget);
  });

  testWidgets('carry over is a switch, on by default', (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsSwitch), findsOneWidget);
    expect(
      tester.widget<SettingsSwitch>(find.byType(SettingsSwitch)).value,
      isTrue,
    );
  });

  testWidgets('the lede states the rule that surprises people', (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Answers from your other exams count toward this one. '
        'Nothing is ever deleted.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the word migrate never appears', (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.data?.toLowerCase().contains('migrat') ?? false, isFalse);
    }
  });

  testWidgets(
      'exam change presents carry-over once after returning to the Exam page',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        GoRoute(
          path: '/settings/exam',
          builder: (_, __) => const ExamPage(),
        ),
        GoRoute(
          path: '/settings/exam/change',
          builder: (_, __) => const ChangeExamPage(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        ...createOverrides(),
        carryableCountProvider.overrideWith((ref, examId) async {
          expect(examId, dost.id);
          return 3;
        }),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change exam'));
    await tester.pumpAndSettle();
    expect(find.byType(ChangeExamPage), findsOneWidget);

    await tester.tap(find.text('DOST'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangeExamPage), findsNothing);
    expect(find.text("You're not starting from zero"), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text("You're not starting from zero"), findsOneWidget);
  });

  testWidgets(
      'carry-over waits for the change-exam reverse transition to finish',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        GoRoute(
          path: '/settings/exam',
          builder: (_, __) => const ExamPage(),
        ),
        GoRoute(
          path: '/settings/exam/change',
          pageBuilder: (_, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            child: const ChangeExamPage(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        ...createOverrides(),
        carryableCountProvider.overrideWith((ref, examId) async {
          expect(examId, dost.id);
          return 3;
        }),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DOST'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ChangeExamPage), findsOneWidget);
    expect(find.text("You're not starting from zero"), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(ChangeExamPage), findsNothing);
    expect(find.text("You're not starting from zero"), findsOneWidget);
  });

  testWidgets(
      'exam focus stays stable until the change-exam transition is finished',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await AppPreferencesRepository(db).setSelectedExamId(upcat.id);

    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        GoRoute(
          path: '/settings/exam',
          builder: (_, __) => const ExamPage(),
        ),
        GoRoute(
          path: '/settings/exam/change',
          pageBuilder: (_, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            child: const ChangeExamPage(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        examListProvider.overrideWith((ref) async => [upcat, dost]),
        userSettingsProvider.overrideWith(
          (ref) async => const UserSettings(
            name: 'Student',
            dailyReminderTime: null,
            examDate: null,
            strictMockMode: false,
            helpImproveApp: true,
            carryOverProgress: true,
            sessionOrdering: SessionOrdering.interleavedTail,
            retainTableOrder: true,
            updatedAt: null,
          ),
        ),
        carryableCountProvider.overrideWith((ref, examId) async {
          expect(examId, dost.id);
          return 3;
        }),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<SettingsGroup>(find.byType(SettingsGroup)).title,
      'UPCAT',
    );

    await tester.tap(find.text('Change exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DOST'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ChangeExamPage), findsOneWidget);
    expect(
      tester.widget<SettingsGroup>(find.byType(SettingsGroup)).title,
      'UPCAT',
    );
    expect(find.text("You're not starting from zero"), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(ChangeExamPage), findsNothing);
    expect(
      tester.widget<SettingsGroup>(find.byType(SettingsGroup)).title,
      'DOST',
    );
    expect(find.text("You're not starting from zero"), findsOneWidget);
  });

  testWidgets(
      'change exam hands carry-over back instead of presenting from its route',
      (tester) async {
    Object? changeResult;
    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        GoRoute(
          path: '/settings/exam',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () async {
                changeResult =
                    await context.push<Object?>('/settings/exam/change');
              },
              child: const Text('Open change exam'),
            ),
          ),
        ),
        GoRoute(
          path: '/settings/exam/change',
          builder: (_, __) => const ChangeExamPage(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        ...createOverrides(),
        carryableCountProvider.overrideWith((ref, examId) async {
          expect(examId, dost.id);
          return 3;
        }),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open change exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DOST'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangeExamPage), findsNothing);
    expect(find.text("You're not starting from zero"), findsNothing);
    expect(changeResult, isNotNull);
  });

  testWidgets('showCarryOverPrompt skips prompt when carryable count is 0',
      (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    final result = await showCarryOverPrompt(
      context: tester.element(find.byType(ExamPage)),
      examShortName: 'DOST',
      carryableCount: 0,
    );
    expect(result, isNull);
  });
}
