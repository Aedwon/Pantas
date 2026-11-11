import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../helpers/in_memory_database.dart';

// ignore_for_file: cascade_invocations

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'cse',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester, {required bool wide}) async {
    final catalog = await tester
        .runAsync(() => ExamCatalogRepository(contentDb).watchAll().first);
    if (wide) {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(catalog!)),
          contentDatabaseProvider.overrideWithValue(contentDb),
          entitlementProvider.overrideWith(
            (_) => Stream.value(const Entitlement.free()),
          ),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  String pathOf(WidgetTester tester) => ProviderScope.containerOf(
        tester.element(find.byType(App)),
      )
          .read(routerProvider)
          .routerDelegate
          .currentConfiguration
          .last
          .matchedLocation;

  List<bool> checks(WidgetTester tester) => tester
      .widgetList<CheckboxRow>(find.byType(CheckboxRow))
      .map((row) => row.selected)
      .toList();

  for (final wide in [true, false]) {
    for (final minor in [false, true]) {
      final who = minor ? 'a minor' : 'an adult';
      final where = wide ? 'wide web' : 'phone';
      for (final (link, route, heading) in const [
        ('Terms of Service', '/legal/terms', 'Use of the app'),
        ('Privacy Policy', '/legal/privacy', 'What we collect'),
      ]) {
        testWidgets(
            '$where, $who: $link opens from Terms and Back keeps the boxes',
            (tester) async {
          final prefs = AppPreferencesRepository(db);
          await prefs.setPassedAgeGate(value: true);
          if (minor) await prefs.setAgeGroup('minor');
          await pumpApp(tester, wide: wide);
          expect(find.text('Terms and Privacy'), findsOneWidget);

          await tester.tapAt(
            tester.getTopLeft(find.byType(CheckboxRow).last) +
                const Offset(28, 20),
          );
          await tester.pumpAndSettle();
          // Under 18 the usage box is not offered, so only the terms box shows.
          expect(checks(tester), minor ? [true] : [false, true]);

          await tester.tap(find.text(link));
          await tester.pumpAndSettle();
          expect(pathOf(tester), route);
          expect(find.text(heading), findsOneWidget);
          // During onboarding the main navigation never shows.
          expect(find.byType(WebShellFrame), findsNothing);
          expect(find.byType(AppNavBar), findsNothing);
          expect(find.text('Study'), findsNothing);
          expect(find.text('Settings'), findsNothing);

          await tester.tap(find.text('Back'));
          await tester.pumpAndSettle();
          expect(pathOf(tester), '/onboarding');
          expect(find.text('Terms and Privacy'), findsOneWidget);
          // Under 18 the usage box is not offered, so only the terms box shows.
          expect(checks(tester), minor ? [true] : [false, true]);
        });
      }
    }
  }

  for (final complete in [false, true]) {
    testWidgets(
        'wide web shell: legal page with onboarding '
        '${complete ? 'finished shows' : 'unfinished hides'} the tabs',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guardianGateProvider.overrideWith(
              (ref) async => GuardianGate.notRequired,
            ),
            onboardingCompleteProvider.overrideWith((ref) async => complete),
            userSettingsProvider.overrideWith((_) => Completer<Never>().future),
            activeExamShortNameProvider.overrideWithValue('CSE'),
            proForActiveExamProvider.overrideWith((_) async => false),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: const WebRouteShell(
              path: '/legal/terms',
              child: Text('legal body'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('legal body'), findsOneWidget);
      expect(
        find.byType(WebShellFrame),
        complete ? findsOneWidget : findsNothing,
      );
      if (complete) {
        expect(
          tester.widget<WebShellFrame>(find.byType(WebShellFrame)).activeIndex,
          3,
        );
      }
    });
  }
}
