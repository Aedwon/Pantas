import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/progress/application/how_you_work_provider.dart';
import 'package:pantas/features/progress/presentation/pages/how_you_work_page.dart';
import 'package:pantas/features/progress/presentation/progress_page.dart';
import 'package:pantas/features/progress/presentation/widgets/gap_comparison.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() {
    db.close();
  });

  Widget harness({
    required bool isPro,
    String? name,
    String? archetype,
  }) {
    final defaultTendencies = [
      const Tendency(
        id: TendencyId.underPressure,
        heading: 'Under pressure',
        leftLabel: 'practising',
        rightLabel: 'under time',
        gap: '14',
        leftFigure: '68%',
        rightFigure: '54%',
        sentence: 'Accuracy drops 14% under exam pressure.',
        isLoss: true,
        unlockAction: 'Finish one full length mock',
      ),
      const Tendency(
        id: TendencyId.stamina,
        heading: 'Stamina',
        leftLabel: 'first half',
        rightLabel: 'second half',
        gap: '9',
        leftFigure: '58%',
        rightFigure: '67%',
        sentence: 'Accuracy rises 9% in the second half of a mock.',
        isLoss: false,
        unlockAction: 'Finish one full length mock',
      ),
      const Tendency(
        id: TendencyId.howYouStudy,
        heading: 'How you study',
        leftLabel: 'read first',
        rightLabel: 'answered first',
        gap: '8',
        leftFigure: '12',
        rightFigure: '4',
        sentence: 'You usually read the lesson first.',
        isLoss: false,
        unlockAction: 'Read lessons or attempt topics',
      ),
      const Tendency(
        id: TendencyId.howYouAnswer,
        heading: 'How you answer',
        leftLabel: 'when correct',
        rightLabel: 'when wrong',
        gap: '6s',
        leftFigure: '12s',
        rightFigure: '18s',
        sentence: 'You spend 6s longer on questions you get wrong.',
        isLoss: true,
        unlockAction: 'Answer more questions',
      ),
      const Tendency(
        id: TendencyId.howLongYouRemember,
        heading: 'How long you remember',
        leftLabel: 'memory holds',
        rightLabel: 'lapse rate',
        gap: '9d',
        leftFigure: '9d',
        rightFigure: '18%',
        sentence:
            'what you learn holds about nine days before you need it again',
        isLoss: false,
        unlockAction: 'Review more questions',
      ),
    ];

    final whenYouWork = [
      (
        title: 'Peak hour',
        subtext: 'Measured from your highest accuracy',
        meta: '9 pm',
      ),
      (
        title: 'Session length',
        subtext: 'Average sit duration',
        meta: '8 minutes',
      ),
      (
        title: 'Total sits',
        subtext: 'Completed study sessions',
        meta: '14 sessions',
      ),
    ];

    final work = HowYouWork(
      name: name,
      archetype: archetype ?? 'Night-Owl Sprinter',
      archetypeLine: 'Sharpest at 9 pm, in 8 minute sits.',
      tendencies: defaultTendencies,
      whenYouWork: whenYouWork,
    );

    final entitlement = isPro
        ? Entitlement(
            plan: EntitlementPlan.monthly,
            expiresAt: DateTime.now().add(const Duration(days: 30)),
          )
        : const Entitlement.free();

    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        howYouWorkProvider.overrideWith((ref) => Future.value(work)),
        entitlementProvider.overrideWith((ref) => Stream.value(entitlement)),
      ],
      child: MaterialApp(
        theme: buildLightTheme(),
        home: const HowYouWorkPage(),
      ),
    );
  }

  Widget tabHarness() {
    const work = HowYouWork(
      name: 'Aedwon',
      archetype: 'Night-Owl Sprinter',
      archetypeLine: 'Sharpest at 9 pm, in 8 minute sits.',
      tendencies: [
        Tendency(
          id: TendencyId.underPressure,
          heading: 'Under pressure',
          leftLabel: 'practising',
          rightLabel: 'under time',
          gap: '14',
          leftFigure: '68%',
          rightFigure: '54%',
          sentence: 'Accuracy drops 14% under exam pressure.',
          isLoss: true,
          unlockAction: 'Finish one full length mock',
        ),
        Tendency(
          id: TendencyId.stamina,
          heading: 'Stamina',
          leftLabel: 'first half',
          rightLabel: 'second half',
          gap: null,
          leftFigure: null,
          rightFigure: null,
          sentence: null,
          isLoss: false,
          unlockAction: 'Finish one full length mock',
        ),
        Tendency(
          id: TendencyId.howYouStudy,
          heading: 'How you study',
          leftLabel: 'read first',
          rightLabel: 'answered first',
          gap: '8',
          leftFigure: '12',
          rightFigure: '4',
          sentence: 'You usually read the lesson first.',
          isLoss: false,
          unlockAction: 'Read lessons or attempt topics',
        ),
        Tendency(
          id: TendencyId.howYouAnswer,
          heading: 'How you answer',
          leftLabel: 'when correct',
          rightLabel: 'when wrong',
          gap: null,
          leftFigure: null,
          rightFigure: null,
          sentence: null,
          isLoss: false,
          unlockAction: 'Answer more questions',
        ),
        Tendency(
          id: TendencyId.howLongYouRemember,
          heading: 'How long you remember',
          leftLabel: 'memory holds',
          rightLabel: 'lapse rate',
          gap: '9d',
          leftFigure: '9d',
          rightFigure: '18%',
          sentence:
              'what you learn holds about nine days before you need it again',
          isLoss: false,
          unlockAction: 'Review more questions',
        ),
      ],
      whenYouWork: [],
    );

    final router = GoRouter(
      initialLocation: '/progress',
      routes: [
        GoRoute(
          path: '/progress',
          builder: (_, __) => const ProgressPage(),
        ),
        GoRoute(
          path: '/progress/how-you-work',
          builder: (_, __) => const HowYouWorkPage(),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        howYouWorkProvider.overrideWith((ref) => Future.value(work)),
        entitlementProvider.overrideWith(
          (ref) => Stream.value(
            Entitlement(
              plan: EntitlementPlan.monthly,
              expiresAt: DateTime.now().add(const Duration(days: 30)),
            ),
          ),
        ),
        activeExamFocusProvider.overrideWith(
          (ref) => Future.value(
            const ActiveExamFocus.selected(
              Exam(
                id: 'exam_upcat',
                code: 'UPCAT',
                name: 'UP College Admissions Test',
                shortName: 'UPCAT',
                language: 'en',
                isActive: true,
                subjects: [],
              ),
            ),
          ),
        ),
        countForExamProvider('exam_upcat')
            .overrideWith((ref) => Future.value(10)),
      ],
      child: MaterialApp.router(
        theme: buildLightTheme(),
        routerConfig: router,
      ),
    );
  }

  testWidgets('the profile is centred and carries the name', (tester) async {
    await tester.pumpWidget(harness(name: 'Aedwon', isPro: true));
    await tester.pumpAndSettle();

    final name = tester.widget<Text>(find.text('Aedwon'));
    expect(name.style?.fontSize, 24);
    expect(name.textAlign, TextAlign.center);
  });

  testWidgets('with no name it shows the invitation', (tester) async {
    await tester.pumpWidget(harness(isPro: true));
    await tester.pumpAndSettle();
    expect(find.text('Add your name'), findsOneWidget);
  });

  testWidgets('five tendencies render on both tiers', (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(harness(isPro: isPro));
      await tester.pumpAndSettle();
      expect(find.byType(GapComparison), findsNWidgets(5));
    }
  });

  testWidgets('Free does not see When you work', (tester) async {
    await tester.pumpWidget(harness(isPro: false));
    await tester.pumpAndSettle();
    expect(find.text('When you work'), findsNothing);
  });

  testWidgets('the Free teaser sits after the fifth tendency', (tester) async {
    await tester.pumpWidget(harness(isPro: false));
    await tester.pumpAndSettle();

    final fifthY = tester.getTopLeft(find.text('How long you remember')).dy;
    final teaserY = tester.getTopLeft(find.text('Unlock with Pro')).dy;
    expect(fifthY, lessThan(teaserY));
    expect(find.text('Unlock with Pro'), findsOneWidget);
  });

  testWidgets('the spaced repetition explainer has left this page',
      (tester) async {
    // This page is about the student's own habits. A general explanation of
    // the scheduler is not about them, which is why it read as out of place.
    // It lives in the quiz debrief now, where the thing being explained has
    // just happened. Its wording is guarded there.
    await tester.pumpWidget(harness(isPro: true));
    await tester.pumpAndSettle();

    expect(find.textContaining('spaced repetition'), findsNothing);
  });

  testWidgets('the exam is never named beside a day count', (tester) async {
    await tester.pumpWidget(harness(isPro: true));
    await tester.pumpAndSettle();

    // The scheduler states how long a memory holds. It does not state what
    // a student will score, so the day count is never set against the exam.
    expect(find.textContaining('UPCAT'), findsNothing);
  });

  testWidgets('the archetype name carries no article', (tester) async {
    await tester.pumpWidget(
      harness(isPro: true, archetype: 'Night-Owl Sprinter'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Night-Owl Sprinter'), findsOneWidget);
    expect(find.textContaining('The Night-Owl'), findsNothing);
  });

  testWidgets('the tab row opens it with push, not go', (tester) async {
    await tester.pumpWidget(tabHarness());
    await tester.pumpAndSettle();
    await tester.tap(find.text('How you work'));
    await tester.pumpAndSettle();

    expect(find.byType(HowYouWorkPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });
}
