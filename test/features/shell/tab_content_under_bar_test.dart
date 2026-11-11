import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

import '../../helpers/in_memory_database.dart';

late ProviderContainer container;

void main() {
  setUpAll(() async {
    final font = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      font.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await font.load();
  });

  setUp(() async {
    final db = inMemoryDatabase();
    final contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'cse',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    // Enough topics that the Study map is longer than the phone screen.
    for (var i = 0; i < 14; i++) {
      await seedContentSubject(
        contentDb,
        subjectId: 's$i',
        examId: 'cse',
        name: 'Subject $i',
        ordering: i,
      );
      await seedContentTopic(
        contentDb,
        topicId: 't$i',
        subjectId: 's$i',
        name: 'Topic $i',
      );
      await seedContentLesson(
        contentDb,
        lessonId: 'l$i',
        topicId: 't$i',
        title: 'Lesson $i',
        bodyJson: '[]',
      );
      await seedContentQuestion(
        contentDb,
        questionId: 'l${i}_q',
        topicId: 't$i',
        examId: 'cse',
        lessonId: 'l$i',
      );
    }
    final preferences = AppPreferencesRepository(db);
    await preferences.setPassedAgeGate(value: true);
    await preferences.setSelectedExamId('cse');
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        entitlementProvider
            .overrideWith((_) => Stream.value(const Entitlement.free())),
        telemetryProvider.overrideWithValue(const DisabledTelemetry()),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  });

  final tabs = <(String, String, Type)>[
    ('Home', '/home', HomeTab),
    ('Study', '/study', StudyTabHome),
    ('Quiz', '/quiz', QuizTabScreen),
    ('Settings', '/settings', SettingsHomePage),
  ];
  // Short on purpose: Home before the assessment is only a few cards, and the
  // scroll checks need every tab to be longer than the screen.
  const screen = Size(390, 420);

  for (final (label, path, type) in tabs) {
    testWidgets('$label tab scrolls under the floating bar on a phone',
        (tester) async {
      tester.view
        ..physicalSize = screen
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = container.read(routerProvider);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: buildLightTheme(),
            routerConfig: router,
          ),
        ),
      );
      await _settle(tester);
      router.go(path);
      await _settle(tester);
      final page = find.byType(type);
      expect(page, findsOneWidget);
      final viewport = _tallestVerticalScrollable(tester, page);
      final bar = tester.getRect(find.byType(AppNavBar));
      expect(bar.bottom, lessThan(screen.height));

      // The scrolling area reaches the bottom of the screen, so the bar floats
      // over it. A viewport that ends at the bar leaves a solid band.
      expect(
        tester.getRect(viewport).bottom,
        screen.height,
        reason: 'the page must not stop at the top of the bar',
      );

      // The last row can still scroll clear of the bar.
      final position = tester.state<ScrollableState>(viewport).position;
      expect(
        position.maxScrollExtent,
        greaterThan(0),
        reason: 'the page must be longer than the screen for this check',
      );
      // A lazy list refines its extent as rows build, so go to the end until
      // it stops moving.
      for (var i = 0; i < 6; i++) {
        position.jumpTo(position.maxScrollExtent);
        await tester.pump();
      }
      final lowest = tester
          .widgetList<Text>(
            find.descendant(of: viewport, matching: find.byType(Text)),
          )
          .map((text) => tester.getRect(find.byWidget(text)))
          .where((rect) => rect.top < screen.height)
          .map((rect) => rect.bottom)
          .reduce((a, b) => a > b ? a : b);
      expect(lowest, lessThanOrEqualTo(bar.top));
    });
  }
}

/// The page's main scroll area: the tallest vertical scrollable inside it.
Finder _tallestVerticalScrollable(WidgetTester tester, Finder page) {
  Finder? best;
  var bestHeight = -1.0;
  for (final element in find
      .descendant(of: page, matching: find.byType(Scrollable))
      .evaluate()) {
    final finder = find.byWidget(element.widget);
    final state = tester.state<ScrollableState>(finder);
    if (state.axisDirection != AxisDirection.down) continue;
    final height = tester.getRect(finder).height;
    if (height > bestHeight) {
      best = finder;
      bestHeight = height;
    }
  }
  expect(best, isNotNull, reason: 'the page has a vertical scroll area');
  return best!;
}

/// Lets loads and entry animations finish. Study keeps a loop running, so
/// `pumpAndSettle` would never return there.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
