import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_calendar.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  Future<void> pumpWide(
    WidgetTester tester,
    Widget screen, {
    bool still = false,
  }) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: still),
            child: child!,
          ),
          home: Scaffold(body: screen),
        ),
      ),
    );
  }

  group('wide welcome pop', () {
    const logo = ValueKey('welcome-logo-pop');
    const title = ValueKey('welcome-title-pop');
    double opacity(WidgetTester tester, Key key) => tester
        .widget<Opacity>(
          find.descendant(of: find.byKey(key), matching: find.byType(Opacity)),
        )
        .opacity;
    double scale(WidgetTester tester, Key key) => tester
        .widget<Transform>(
          find
              .descendant(of: find.byKey(key), matching: find.byType(Transform))
              .first,
        )
        .transform
        .storage[0];

    testWidgets('logo and title pop over 750 ms and settle', (tester) async {
      await pumpWide(tester, OnboardingWelcomeStep(onAdvance: () {}));
      await tester.pump();
      for (final key in [logo, title]) {
        expect(opacity(tester, key), 0, reason: '$key');
        expect(scale(tester, key), closeTo(.4, .001), reason: '$key');
      }
      await tester.pump(const Duration(milliseconds: 450));
      for (final key in [logo, title]) {
        expect(opacity(tester, key), inExclusiveRange(0, 1));
        expect(scale(tester, key), greaterThan(.4));
      }
      await tester.pumpAndSettle();
      for (final key in [logo, title]) {
        expect(opacity(tester, key), 1);
        expect(scale(tester, key), 1);
      }
    });

    testWidgets('reduced motion shows them at once with no timer left',
        (tester) async {
      await pumpWide(
        tester,
        OnboardingWelcomeStep(onAdvance: () {}),
        still: true,
      );
      await tester.pump();
      for (final key in [logo, title]) {
        expect(opacity(tester, key), 1);
        expect(scale(tester, key), 1);
      }
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('wide calendar month change', () {
    final month = ValueNotifier<int>(10);
    Widget calendar() => ValueListenableBuilder<int>(
          valueListenable: month,
          builder: (_, value, __) => Center(
            child: SizedBox(
              width: 780,
              child: OnboardingWebCalendar(
                value: MonthFirstDate(year: 2026, month: value),
                today: DateTime(2026, 10, 3),
                onChanged: (_) {},
              ),
            ),
          ),
        );
    Finder panel(int month) =>
        find.byKey(ValueKey('calendar-month-2026-$month'));
    double opacity(WidgetTester tester, Finder panel) => tester
        .widget<Opacity>(
          find.ancestor(of: panel, matching: find.byType(Opacity)).first,
        )
        .opacity;
    setUp(() => month.value = 10);

    testWidgets('the new month rises in over 320 ms', (tester) async {
      await pumpWide(tester, calendar());
      await tester.pumpAndSettle();
      expect(opacity(tester, panel(10)), 1);
      month.value = 11;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacity(tester, panel(11)), inExclusiveRange(0, 1));
      // The old month leaves at once.
      expect(panel(10), findsNothing);
      await tester.pumpAndSettle();
      expect(opacity(tester, panel(11)), 1);
    });

    testWidgets('reduced motion swaps the month at once', (tester) async {
      await pumpWide(tester, calendar(), still: true);
      await tester.pumpAndSettle();
      month.value = 11;
      await tester.pump();
      expect(opacity(tester, panel(11)), 1);
      expect(panel(10), findsNothing);
    });
  });

  group('wide age gate blocked fade', () {
    Future<void> block(WidgetTester tester, {required bool still}) async {
      await pumpWide(
        tester,
        OnboardingAgeGateStep(currentYear: 2026, onAgeGatePassed: () {}),
        still: still,
      );
      await tester.enterText(find.byType(TextField), '2020');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      // Saving runs on a real database, so wait for the block to show.
      for (var i = 0;
          i < 100 && find.text("Pantas isn't available yet").evaluate().isEmpty;
          i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)),
        );
        await tester.pump();
      }
    }

    double fade(WidgetTester tester) => tester
        .widget<Opacity>(
          find
              .ancestor(
                of: find.text("Pantas isn't available yet"),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;

    testWidgets('the block fades in over 300 ms', (tester) async {
      await block(tester, still: false);
      expect(fade(tester), lessThan(1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(fade(tester), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(fade(tester), 1);
    });

    testWidgets('reduced motion shows the block at once', (tester) async {
      await block(tester, still: true);
      expect(fade(tester), 1);
    });
  });
}
