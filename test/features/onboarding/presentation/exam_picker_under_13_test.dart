// Under-13 boards 3A (the child question) and 5 (the picker on a child),
// in onboarding and in Settings.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/application/exam_picker_availability.dart';
import 'package:pantas/features/onboarding/presentation/child/parent_setup_screen.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

import '../../../helpers/in_memory_database.dart';

const _pshsId = 'exam_pshs_nce';

ExamCatalogEntry _entry(
  String id,
  String shortName,
  String group, {
  bool comingSoon = false,
}) =>
    ExamCatalogEntry(
      id: id,
      name: shortName,
      shortName: shortName,
      priceTier: 'test',
      group: group,
      comingSoon: comingSoon,
      publishedSittings: const [],
      hasContent: true,
    );

List<ExamCatalogEntry> _catalog({required bool pshsComingSoon}) => [
      _entry('exam_upcat', 'UPCAT', 'College entrance'),
      _entry('exam_acet', 'ACET', 'College entrance'),
      _entry(_pshsId, 'PSHS-NCE', 'High school', comingSoon: pshsComingSoon),
      _entry('exam_cse_pro', 'CSE Professional', 'Civil service'),
    ];

const _question = 'Is this for a child under 13?';
const _questionBody =
    'A parent or guardian sets up PSHS-NCE accounts for children under 13.';
const _anotherEmail = 'Use another email';
const _anotherEmailBody = 'This account already has study records. To set up '
    'a child under 13, sign out, then sign in with another email.';

void main() {
  late AppDatabase db;
  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester, {
    required AgeGroup ageGroup,
    ExamPickerMode mode = ExamPickerMode.onboarding,
    bool wide = false,
    bool pshsComingSoon = false,
    bool flag = false,
    bool web = true,
    TargetPlatform platform = TargetPlatform.iOS,
    List<String>? picks,
  }) async {
    debugWebPlatformOverride = wide;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = wide ? const Size(1440, 900) : const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => ExamPickerScreen(
            mode: mode,
            onPicked: (id) async => picks?.add(id),
            onBack: () {},
            onCustom: () {},
          ),
        ),
        GoRoute(
          path: childSignInPath,
          builder: (_, __) => const Scaffold(body: Text('parent sign in')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerPolicyProvider.overrideWithValue(
            ExamPickerPolicy(
              ageGroup: ageGroup,
              isWeb: web,
              platform: platform,
              pshsForChildren: flag,
            ),
          ),
          examPickerCatalogProvider.overrideWith(
            (ref) => Stream.value(_catalog(pshsComingSoon: pshsComingSoon)),
          ),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(web: wide),
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder pshs() => find.byKey(const ValueKey('exam-$_pshsId'));

  Future<void> tapPshs(WidgetTester tester) async {
    await tester.ensureVisible(pshs());
    await tester.tap(pshs());
    await tester.pumpAndSettle();
  }

  bool continueEnabled(WidgetTester tester) {
    final wide = find.widgetWithText(OnboardingButton, 'Continue');
    return wide.evaluate().isNotEmpty
        ? tester.widget<OnboardingButton>(wide).onPressed != null
        : tester
                .widget<PantasButton>(
                  find.widgetWithText(PantasButton, 'Continue'),
                )
                .onPressed !=
            null;
  }

  group('board 5, the picker on a child', () {
    for (final wide in [false, true]) {
      for (final mode in ExamPickerMode.values) {
        testWidgets('other exams say "For ages 13 and up" (wide $wide, $mode)',
            (tester) async {
          await pump(
            tester,
            ageGroup: AgeGroup.child,
            mode: mode,
            wide: wide,
            pshsComingSoon: true,
            flag: true,
          );
          expect(find.text('For ages 13 and up'), findsNWidgets(3));
          expect(find.text('Coming soon'), findsNothing);
          expect(find.text('Philippine Science High School'), findsOneWidget);
        });

        testWidgets('PSHS-NCE is selectable (wide $wide, $mode)',
            (tester) async {
          final picks = <String>[];
          await pump(
            tester,
            ageGroup: AgeGroup.child,
            mode: mode,
            wide: wide,
            pshsComingSoon: true,
            flag: true,
            picks: picks,
          );
          await tapPshs(tester);
          expect(find.text(_question), findsNothing);
          if (mode == ExamPickerMode.settings) {
            expect(picks, [_pshsId]);
          } else {
            await tester.tap(find.text('Continue'));
            await tester.pumpAndSettle();
            expect(picks, [_pshsId]);
          }
        });

        testWidgets(
            'an exam for ages 13 and up cannot be picked '
            '(wide $wide, $mode)', (tester) async {
          final picks = <String>[];
          await pump(
            tester,
            ageGroup: AgeGroup.child,
            mode: mode,
            wide: wide,
            pshsComingSoon: true,
            flag: true,
            picks: picks,
          );
          final upcat = find.byKey(const ValueKey('exam-exam_upcat'));
          await tester.ensureVisible(upcat);
          await tester.tap(upcat, warnIfMissed: false);
          await tester.pumpAndSettle();
          expect(picks, isEmpty);
          expect(find.text(_question), findsNothing);
        });
      }
    }
  });

  group('board 3A, "Is this for a child under 13?"', () {
    for (final wide in [false, true]) {
      for (final mode in ExamPickerMode.values) {
        final where = '(wide $wide, $mode)';

        testWidgets('an adult tap on PSHS-NCE asks the question $where',
            (tester) async {
          await pump(tester, ageGroup: AgeGroup.adult, mode: mode, wide: wide);
          await tapPshs(tester);
          expect(find.text(_question), findsOneWidget);
          expect(find.text(_questionBody), findsOneWidget);
          expect(find.text('No'), findsOneWidget);
          expect(find.text('Yes'), findsOneWidget);
        });

        testWidgets('a teen account is asked too $where', (tester) async {
          await pump(tester, ageGroup: AgeGroup.minor, mode: mode, wide: wide);
          await tapPshs(tester);
          expect(find.text(_question), findsOneWidget);
        });

        testWidgets('another exam does not ask $where', (tester) async {
          await pump(tester, ageGroup: AgeGroup.adult, mode: mode, wide: wide);
          final upcat = find.byKey(const ValueKey('exam-exam_upcat'));
          await tester.ensureVisible(upcat);
          await tester.tap(upcat);
          await tester.pumpAndSettle();
          expect(find.text(_question), findsNothing);
        });

        testWidgets('Android does not show PSHS-NCE, so no question $where',
            (tester) async {
          await pump(
            tester,
            ageGroup: AgeGroup.adult,
            mode: mode,
            web: false,
            platform: TargetPlatform.android,
          );
          expect(pshs(), findsNothing);
          expect(find.text(_question), findsNothing);
        });

        testWidgets('No selects PSHS-NCE when it is selectable $where',
            (tester) async {
          final picks = <String>[];
          await pump(
            tester,
            ageGroup: AgeGroup.adult,
            mode: mode,
            wide: wide,
            picks: picks,
          );
          await tapPshs(tester);
          await tester.tap(find.text('No'));
          await tester.pumpAndSettle();
          expect(find.text(_question), findsNothing);
          if (mode == ExamPickerMode.onboarding) {
            expect(continueEnabled(tester), isTrue);
            await tester.tap(find.text('Continue'));
            await tester.pumpAndSettle();
          }
          expect(picks, [_pshsId]);
        });
      }
    }

    testWidgets('coming soon and no flag: the row stays as it is',
        (tester) async {
      await pump(tester, ageGroup: AgeGroup.adult, pshsComingSoon: true);
      expect(find.text('Coming soon'), findsOneWidget);
      await tester.ensureVisible(pshs());
      await tester.tap(pshs(), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text(_question), findsNothing);
    });

    for (final mode in ExamPickerMode.values) {
      testWidgets(
          'coming soon with the flag: asks, and No selects nothing '
          '($mode)', (tester) async {
        final picks = <String>[];
        await pump(
          tester,
          ageGroup: AgeGroup.adult,
          mode: mode,
          pshsComingSoon: true,
          flag: true,
          picks: picks,
        );
        await tapPshs(tester);
        expect(find.text(_question), findsOneWidget);
        await tester.tap(find.text('No'));
        await tester.pumpAndSettle();
        expect(find.text(_question), findsNothing);
        expect(picks, isEmpty);
        if (mode == ExamPickerMode.onboarding) {
          expect(continueEnabled(tester), isFalse);
        }
      });
    }

    testWidgets('Yes in onboarding starts the parent setup', (tester) async {
      final picks = <String>[];
      await pump(tester, ageGroup: AgeGroup.adult, picks: picks);
      final prefs = AppPreferencesRepository(db);
      expect(await prefs.needsGuardianSetup(), isFalse);
      await tapPshs(tester);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(find.text('parent sign in'), findsOneWidget);
      expect(await prefs.needsGuardianSetup(), isTrue);
      expect(await prefs.hasPassedAgeGate(), isFalse);
      expect(picks, isEmpty);
    });

    testWidgets('Yes in Settings says to use another email', (tester) async {
      final picks = <String>[];
      await pump(
        tester,
        ageGroup: AgeGroup.adult,
        mode: ExamPickerMode.settings,
        picks: picks,
      );
      await tapPshs(tester);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(find.text(_question), findsNothing);
      expect(find.text(_anotherEmail), findsOneWidget);
      expect(find.text(_anotherEmailBody), findsOneWidget);
      expect(find.text('Got It'), findsOneWidget);
      expect(find.text('No'), findsNothing);
      expect(find.text('parent sign in'), findsNothing);
      expect(await AppPreferencesRepository(db).needsGuardianSetup(), isFalse);

      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();
      expect(find.text(_anotherEmail), findsNothing);
      expect(picks, isEmpty);
    });

    for (final group in [AgeGroup.child, AgeGroup.unrecognized]) {
      testWidgets('never asked for ${group.name}', (tester) async {
        await pump(
          tester,
          ageGroup: group,
          wide: true,
          pshsComingSoon: true,
          flag: true,
        );
        await tapPshs(tester);
        expect(find.text(_question), findsNothing);
      });
    }
  });
}
