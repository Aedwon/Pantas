import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/presentation/widgets/home_notice_strip.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../../helpers/in_memory_database.dart';

class _Calls {
  late DriftSettingsRepository settings;
  final opened = <HomeNoticeKind>[];
  final routes = <String>[];
}

void main() {
  Future<AppPreferencesRepository> show(
    WidgetTester tester,
    HomeNotice notice,
    _Calls calls,
  ) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final prefs = AppPreferencesRepository(db);
    calls.settings = DriftSettingsRepository(db);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          nowProvider.overrideWithValue(() => DateTime(2026, 11, 8)),
          appPreferencesRepositoryProvider.overrideWithValue(prefs),
          homeNoticeProvider.overrideWith((ref) async {
            final stored = await ref
                .read(appPreferencesRepositoryProvider)
                .deviceValue('home_notice_dismissed_${notice.kind.name}');
            return stored == notice.dismissalToken ? null : notice;
          }),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: HomeNoticeStrip(
                onDate: calls.opened.add,
                onRoute: calls.routes.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return prefs;
  }

  const trial = HomeNotice(
    kind: HomeNoticeKind.trial,
    title: 'Pro trial ends in 2 days',
    detail: "Your free trial ends on Oct 2. You won't be charged.",
    dismissalToken: '2026-10-02',
    primaryLabel: 'See Pro',
    secondaryLabel: 'Got It',
  );

  testWidgets('nothing draws when there is no notice', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider
              .overrideWithValue(AppPreferencesRepository(db)),
          homeNoticeProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: HomeNoticeStrip(onDate: (_) {}, onRoute: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NoticeStrip), findsNothing);
  });

  testWidgets('a row tap opens the detail and See Pro opens the Pro page',
      (tester) async {
    final calls = _Calls();
    await show(tester, trial, calls);
    expect(find.text('Pro trial ends in 2 days'), findsOneWidget);
    await tester.tap(find.text('Pro trial ends in 2 days'));
    await tester.pumpAndSettle();
    expect(
      find.text("Your free trial ends on Oct 2. You won't be charged."),
      findsOneWidget,
    );
    await tester.tap(find.text('See Pro'));
    await tester.pumpAndSettle();
    expect(calls.routes, ['/settings/pro']);
  });

  testWidgets('welcome notice uses the board accent sparkle', (tester) async {
    await show(
      tester,
      const HomeNotice(
        kind: HomeNoticeKind.welcome,
        title: "You're in. Welcome to Pro.",
        dismissalToken: 'yes',
      ),
      _Calls(),
    );
    final icon = find.byIcon(PantasIcons.pro);
    expect(
      tester.widget<Icon>(icon).color,
      tester.element(icon).colors.accent,
    );
  });

  testWidgets('trial notice uses the board timer', (tester) async {
    await show(tester, trial, _Calls());
    expect(
      tester.widget<NoticeStrip>(find.byType(NoticeStrip)).icon,
      PantasIcons.timer,
    );
  });

  testWidgets('service notice uses the board information circle',
      (tester) async {
    await show(
      tester,
      const HomeNotice(
        kind: HomeNoticeKind.service,
        title: 'Service',
        dismissalToken: 'Service',
      ),
      _Calls(),
    );
    expect(
      tester.widget<NoticeStrip>(find.byType(NoticeStrip)).icon,
      const IconData(0xe2ce, fontFamily: 'Phosphor'),
    );
  });

  testWidgets('Got It on an account notice is stored and stays gone',
      (tester) async {
    final calls = _Calls();
    final prefs = await show(tester, trial, calls);
    await tester.tap(find.text('Pro trial ends in 2 days'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Got It'));
    await tester.pumpAndSettle();
    expect(find.byType(NoticeStrip), findsNothing);
    expect(
      await prefs.deviceValue('home_notice_dismissed_trial'),
      '2026-10-02',
    );
  });

  testWidgets('the close button on an account notice is stored too',
      (tester) async {
    final calls = _Calls();
    final prefs = await show(tester, trial, calls);
    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.byType(NoticeStrip), findsNothing);
    expect(
      await prefs.deviceValue('home_notice_dismissed_trial'),
      '2026-10-02',
    );
  });

  testWidgets('a date notice dismissal persists in app preferences',
      (tester) async {
    final calls = _Calls();
    const noDate = HomeNotice(
      kind: HomeNoticeKind.noDate,
      title: 'Add your exam date',
      detail: 'Your plan paces each day to it. '
          'Until then, today is reviews only.',
      dismissalToken: 'yes',
      primaryLabel: 'Add Exam Date',
      secondaryLabel: 'Later',
    );
    final prefs = await show(tester, noDate, calls);
    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.byType(NoticeStrip), findsNothing);
    expect(await prefs.deviceValue('home_notice_dismissed_noDate'), 'yes');
  });

  testWidgets('Add Exam Date asks Home to open the date sheet', (tester) async {
    final calls = _Calls();
    const noDate = HomeNotice(
      kind: HomeNoticeKind.noDate,
      title: 'Add your exam date',
      detail: 'Your plan paces each day to it. '
          'Until then, today is reviews only.',
      dismissalToken: 'yes',
      primaryLabel: 'Add Exam Date',
      secondaryLabel: 'Later',
    );
    await show(tester, noDate, calls);
    await tester.tap(find.text('Add your exam date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Exam Date'));
    await tester.pumpAndSettle();
    expect(calls.opened, [HomeNoticeKind.noDate]);
  });

  testWidgets('month-only notice picks a day inline before enabling Save',
      (tester) async {
    final calls = _Calls();
    await show(
      tester,
      const HomeNotice(
        kind: HomeNoticeKind.monthOnly,
        title: 'Do you know the day of your UPCAT?',
        detail: "It's November. Your plan is paced to the end of the month "
            'until you pick the day.',
        dismissalToken: '2026-11-01',
        primaryLabel: 'Save',
        secondaryLabel: 'Not Yet',
      ),
      calls,
    );
    await tester.tap(find.text('Do you know the day of your UPCAT?'));
    await tester.pumpAndSettle();
    final save = find.widgetWithText(PantasButton, 'Save');
    expect(tester.widget<PantasButton>(save).onPressed, isNull);
    // The row runs on to the card's own edge, not to the notice padding.
    expect(
      tester
          .widget<SingleChildScrollView>(
            find.ancestor(
              of: find.byKey(const ValueKey('notice-day-11')),
              matching: find.byType(SingleChildScrollView),
            ),
          )
          .clipBehavior,
      Clip.none,
    );
    final day = find.byKey(const ValueKey('notice-day-11'));
    await tester.ensureVisible(day);
    await tester.tap(day);
    await tester.pumpAndSettle();
    expect(tester.widget<PantasButton>(save).onPressed, isNotNull);
    expect(calls.opened, isEmpty);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(
      (await calls.settings.readUserSettings()).examDate?.storageValue,
      '2026-11-11',
    );
  });

  testWidgets('the service message has no detail to open', (tester) async {
    final calls = _Calls();
    const service = HomeNotice(
      kind: HomeNoticeKind.service,
      title: 'Backup is paused for a few hours.',
      dismissalToken: 'Backup is paused for a few hours.',
    );
    await show(tester, service, calls);
    expect(find.text('Backup is paused for a few hours.'), findsOneWidget);
    expect(find.text('Got It'), findsNothing);
    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.byType(NoticeStrip), findsNothing);
  });

  group('beta notice', () {
    const survey = HomeNotice(
      kind: HomeNoticeKind.beta,
      title: '2 of 5 beta days. Ends Nov 22.',
      detail: 'A day counts when you finish your whole Today plan. '
          'Reach 5 by Nov 22 and send the exit survey to earn 1 year of Pro.',
      dismissalToken: 'days:2|2026-11-16',
      primaryLabel: 'Take the Survey',
      secondaryLabel: 'Later',
      route: betaNoticeSurveyRoute,
    );
    const days = HomeNotice(
      kind: HomeNoticeKind.beta,
      title: '2 of 5 beta days. Ends Nov 22.',
      detail: 'A day counts when you finish your whole Today plan. '
          'Reach 5 by Nov 22 to earn 1 year of Pro.',
      dismissalToken: 'sent:2|2026-11-16',
      primaryLabel: 'See Your Days',
      secondaryLabel: 'Later',
      route: betaNoticeFeedbackRoute,
    );
    const earned = HomeNotice(
      kind: HomeNoticeKind.beta,
      title: 'You earned 1 year of Pro',
      detail: 'Thank you for testing Pantas. '
          'Turn it on whenever you are ready.',
      dismissalToken: 'earned',
      primaryLabel: 'See Your Reward',
      secondaryLabel: 'Later',
      route: betaNoticeFeedbackRoute,
      proIcon: true,
    );

    for (final (notice, label, route) in [
      (survey, 'Take the Survey', '/settings/beta-feedback/survey'),
      (days, 'See Your Days', '/settings/beta-feedback'),
      (earned, 'See Your Reward', '/settings/beta-feedback'),
    ]) {
      testWidgets('$label pushes $route and keeps the notice', (tester) async {
        final calls = _Calls();
        await show(tester, notice, calls);
        await tester.tap(find.text(notice.title));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(calls.routes, [route]);
        // Opening a page is not a dismissal.
        expect(find.byType(NoticeStrip), findsOneWidget);
      });
    }

    testWidgets('Later stores the day token', (tester) async {
      final prefs = await show(tester, survey, _Calls());
      await tester.tap(find.text(survey.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();
      expect(find.byType(NoticeStrip), findsNothing);
      expect(
        await prefs.deviceValue('home_notice_dismissed_beta'),
        'days:2|2026-11-16',
      );
    });

    testWidgets('the close button stores the earned token for good',
        (tester) async {
      final prefs = await show(tester, earned, _Calls());
      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.byType(NoticeStrip), findsNothing);
      expect(await prefs.deviceValue('home_notice_dismissed_beta'), 'earned');
    });

    testWidgets('days use the calendar icon', (tester) async {
      await show(tester, survey, _Calls());
      expect(
        tester.widget<NoticeStrip>(find.byType(NoticeStrip)).icon,
        PantasIcons.calendarBlank,
      );
    });

    testWidgets('earned uses the accent Pro mark', (tester) async {
      await show(tester, earned, _Calls());
      final icon = find.byIcon(PantasIcons.pro);
      expect(
        tester.widget<Icon>(icon).color,
        tester.element(icon).colors.accent,
      );
    });

    testWidgets('wide web: the same notice, buttons route the same',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final routes = <String>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesRepositoryProvider
                .overrideWithValue(AppPreferencesRepository(db)),
            homeNoticeProvider.overrideWith((ref) async => survey),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: Scaffold(
              body: HomeNoticeStrip(onDate: (_) {}, onRoute: routes.add),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeWebNotice), findsOneWidget);
      await tester.tap(find.text(survey.title));
      await tester.pumpAndSettle();
      expect(find.text(survey.detail!), findsOneWidget);
      await tester.tap(find.text('Take the Survey'));
      await tester.pumpAndSettle();
      expect(routes, ['/settings/beta-feedback/survey']);
    });
  });
}
