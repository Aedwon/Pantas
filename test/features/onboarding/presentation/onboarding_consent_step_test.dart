import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  setUp(() {
    db = inMemoryDatabase();
  });
  tearDown(() => db.close());
  Widget scoped(Widget child, {DriftSettingsRepository? repository}) =>
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          if (repository != null)
            settingsRepositoryProvider.overrideWithValue(repository),
        ],
        child: child,
      );
  Future<void> pump(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    double scale = 1,
    VoidCallback? completed,
    DriftSettingsRepository? repository,
  }) =>
      pumpAccessibilitySurface(
        tester,
        scoped(
          OnboardingConsentStep(onCompleted: completed ?? () {}),
          repository: repository,
        ),
        brightness: brightness,
        textScale: scale,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('terms are last and required $brightness $scale',
          (tester) async {
        await pump(tester, brightness: brightness, scale: scale);
        expect(find.text('Terms and Privacy'), findsOneWidget);
        final rows =
            tester.widgetList<CheckboxRow>(find.byType(CheckboxRow)).toList();
        expect(
          rows.first.title,
          'Help improve Pantas by sharing usage data',
        );
        expect(rows.first.selected, isFalse);
        expect(rows.last.selected, isFalse);
        expect(
          tester
              .widget<PantasButton>(
                find.widgetWithText(PantasButton, 'Continue'),
              )
              .onPressed,
          isNull,
        );
        await tester
            .ensureVisible(find.byKey(const ValueKey('selection-mark')).first);
        await tester.tap(find.byKey(const ValueKey('selection-mark')).first);
        await tester.pump();
        expect(
          tester
              .widgetList<CheckboxRow>(find.byType(CheckboxRow))
              .first
              .selected,
          isTrue,
        );
        expect(
          tester
              .widget<PantasButton>(
                find.widgetWithText(PantasButton, 'Continue'),
              )
              .onPressed,
          isNull,
        );
        await tester.ensureVisible(find.byType(CheckboxRow).last);
        await tester.tap(find.byKey(const ValueKey('selection-mark')).last);
        await tester.pump();
        expect(
          tester
              .widget<PantasButton>(
                find.widgetWithText(PantasButton, 'Continue'),
              )
              .onPressed,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('continuing records acceptance and the separate usage choice',
      (tester) async {
    var completed = 0;
    await pump(tester, completed: () => completed++);
    await tester.tap(find.byKey(const ValueKey('selection-mark')).first);
    await tester.tap(find.byKey(const ValueKey('selection-mark')).last);
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    final settings = await DriftSettingsRepository(db).readUserSettings();
    expect(settings.acceptedTermsAt, isNotNull);
    expect(settings.helpImproveApp, isTrue);
    expect(completed, 1);
    final version = await (db.select(db.accountPrefs)
          ..where((row) => row.key.equals(SettingsPrefKeys.policyVersion)))
        .getSingle();
    expect(version.value, '1');
  });
  testWidgets('Back to Terms shows what was accepted ticked (5S-9)',
      (tester) async {
    await pump(tester, completed: () {});
    await tester.tap(find.byKey(const ValueKey('selection-mark')).last);
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // The step is built again, as it is after Back from the exam step.
    await tester.pumpWidget(const SizedBox.shrink());
    await pump(tester, completed: () {});
    await tester.pumpAndSettle();

    final rows =
        tester.widgetList<CheckboxRow>(find.byType(CheckboxRow)).toList();
    expect(rows.first.selected, isFalse, reason: 'usage was left unticked');
    expect(rows.last.selected, isTrue, reason: 'the terms were accepted');
    expect(
      tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, 'Continue'))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('Back to Terms keeps a ticked usage choice too', (tester) async {
    await pump(tester, completed: () {});
    await tester.tap(find.byKey(const ValueKey('selection-mark')).first);
    await tester.tap(find.byKey(const ValueKey('selection-mark')).last);
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await pump(tester, completed: () {});
    await tester.pumpAndSettle();

    expect(
      tester
          .widgetList<CheckboxRow>(find.byType(CheckboxRow))
          .every((row) => row.selected),
      isTrue,
    );
  });

  testWidgets('a student who never accepted sees both boxes empty',
      (tester) async {
    await pump(tester, completed: () {});
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<CheckboxRow>(find.byType(CheckboxRow))
          .any((row) => row.selected),
      isFalse,
    );
  });

  testWidgets(
      'consent save failure retains both choices and does not mark acceptance',
      (tester) async {
    var completed = 0;
    final repository =
        DriftSettingsRepository(db, analytics: _FailingConsentGateway());
    await pump(tester, repository: repository, completed: () => completed++);
    await tester.tap(find.byKey(const ValueKey('selection-mark')).first);
    await tester.tap(find.byKey(const ValueKey('selection-mark')).last);
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.textContaining('private details'), findsNothing);
    expect(completed, 0);
    expect((await repository.readUserSettings()).acceptedTermsAt, isNull);
    expect(
      tester
          .widgetList<CheckboxRow>(find.byType(CheckboxRow))
          .every((row) => row.selected),
      isTrue,
    );
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect((await repository.readUserSettings()).acceptedTermsAt, isNotNull);
    expect((await repository.readUserSettings()).helpImproveApp, isTrue);
    expect(completed, 1);
  });

  testWidgets('inline Terms and Privacy links match the sentence text',
      (tester) async {
    await pump(tester, completed: () {});
    TextStyle? styleOf(String text) =>
        tester.renderObject<RenderParagraph>(find.text(text).first).text.style;
    final sentence = styleOf('I agree to the ');
    for (final link in ['Terms of Service', 'Privacy Policy']) {
      expect(styleOf(link)?.fontSize, sentence?.fontSize, reason: link);
      expect(styleOf(link)?.height, sentence?.height, reason: link);
      // An inline link takes no 44px box, so the wrapped sentence keeps
      // its own line spacing (WCAG 2.5.8 exempts inline links).
      expect(
        find.ancestor(of: find.text(link), matching: find.byType(TouchTarget)),
        findsNothing,
        reason: link,
      );
    }
  });

  testWidgets('legal pages preserve both boxes when returning', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => OnboardingConsentStep(onCompleted: () {}),
        ),
        GoRoute(
          path: '/legal/terms',
          builder: (_, __) => const Scaffold(body: Text('Legal terms')),
        ),
        GoRoute(
          path: '/legal/privacy',
          builder: (_, __) => const Scaffold(body: Text('Legal privacy')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      scoped(
        MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('selection-mark')).first);
    await tester.tap(find.byKey(const ValueKey('selection-mark')).last);
    await tester.pump();
    Focus.of(
      tester.element(find.text('Terms of Service')),
      createDependency: false,
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Legal terms'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<CheckboxRow>(find.byType(CheckboxRow))
          .every((row) => row.selected),
      isTrue,
    );
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('Legal privacy'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<CheckboxRow>(find.byType(CheckboxRow))
          .every((row) => row.selected),
      isTrue,
    );
  });
}

class _FailingConsentGateway extends NoopAnalyticsConsentGateway {
  bool fail = true;
  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    if (fail) {
      fail = false;
      throw StateError('private details');
    }
  }
}
