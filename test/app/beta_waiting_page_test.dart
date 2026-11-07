import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/app/beta_gate.dart';
import 'package:pantas/app/beta_waiting_page.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

class _AuthGateway extends Mock implements AuthGateway {}

class _Repository extends AuthRepository {
  _Repository({this.onSignOut}) : super(gateway: _AuthGateway());

  final void Function()? onSignOut;
  int signOutCalls = 0;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    onSignOut?.call();
  }
}

/// Answers each check from a list, then repeats the last answer.
class _Access extends BetaAccessGateway {
  _Access(this.answers);
  final List<BetaAccess> answers;
  int checks = 0;

  @override
  Future<BetaAccess> check() async {
    checks++;
    return answers[(checks - 1).clamp(0, answers.length - 1)];
  }
}

class _Clock {
  _Clock(this.now);
  DateTime now;
  DateTime call() => now;
}

/// Nov 9, 2026, 12:00 a.m. in the Philippines.
final _start = DateTime.utc(2026, 11, 8, 16);
const _phone = Size(390, 844);
const _laptop = Size(1440, 900);
const _email = AuthState.signedIn(
  user: AuthUser(uid: 'named', email: 'juan@gmail.com', displayName: ''),
);

void main() {
  group('countdown math', () {
    BetaCountdown at(DateTime now) => BetaCountdown.until(_start, now);

    test('the board example reads 1 day, 9 hours, 41 minutes', () {
      final c = at(DateTime.utc(2026, 11, 7, 6, 19));
      expect(
        [c.daysText, c.hoursText, c.minutesText],
        ['1', '09', '41'],
      );
      expect(c.spoken, '1 day, 9 hours and 41 minutes to go');
    });

    test('it counts straight across Philippine midnight', () {
      // 11:59 p.m. on Nov 7, midnight Nov 8 and 12:01 a.m. Nov 8 in Manila.
      final before = at(DateTime.utc(2026, 11, 7, 15, 59));
      final at0 = at(DateTime.utc(2026, 11, 7, 16));
      final after = at(DateTime.utc(2026, 11, 7, 16, 1));
      expect([before.days, before.hours, before.minutes], [1, 0, 1]);
      expect([at0.days, at0.hours, at0.minutes], [1, 0, 0]);
      expect([after.days, after.hours, after.minutes], [0, 23, 59]);
    });

    test('the last minutes before the start, past Nov 8 Manila midnight', () {
      // 11:58:30 p.m. Nov 8 in Manila: 90 seconds left rounds up to 2.
      final c = at(DateTime.utc(2026, 11, 8, 15, 58, 30));
      expect([c.days, c.hours, c.minutes], [0, 0, 2]);
      final last = at(DateTime.utc(2026, 11, 8, 15, 59, 30));
      expect([last.days, last.hours, last.minutes], [0, 0, 1]);
      final lastSecond = at(DateTime.utc(2026, 11, 8, 15, 59, 59));
      expect(
        [lastSecond.days, lastSecond.hours, lastSecond.minutes],
        [0, 0, 1],
      );
    });

    test('it never reads zero before the start and never goes negative', () {
      final inside = at(_start.subtract(const Duration(milliseconds: 1)));
      expect(inside.minutes, 1);
      final done = at(_start);
      expect([done.days, done.hours, done.minutes], [0, 0, 0]);
      final past = at(_start.add(const Duration(days: 3)));
      expect([past.days, past.hours, past.minutes], [0, 0, 0]);
    });

    test('a local-time clock gives the same answer as a UTC one', () {
      final utc = DateTime.utc(2026, 11, 7, 6, 19);
      expect(at(utc.toLocal()), at(utc));
      expect(BetaCountdown.until(_start.toLocal(), utc), at(utc));
    });

    test('long waits keep counting days', () {
      final c = at(DateTime.utc(2026, 10, 20, 15, 45));
      expect([c.days, c.hours, c.minutes], [19, 0, 15]);
    });

    test('it speaks singular and plural units', () {
      expect(
        const BetaCountdown(days: 0, hours: 1, minutes: 0).spoken,
        '0 days, 1 hour and 0 minutes to go',
      );
      expect(
        const BetaCountdown(days: 2, hours: 0, minutes: 1).spoken,
        '2 days, 0 hours and 1 minute to go',
      );
    });

    test('the next change comes when the minute count drops', () {
      Duration next(DateTime now) => BetaCountdown.untilChange(_start, now);
      expect(
        next(DateTime.utc(2026, 11, 8, 15, 59)),
        const Duration(minutes: 1),
      );
      expect(
        next(DateTime.utc(2026, 11, 8, 15, 59, 30)),
        const Duration(seconds: 30),
      );
      expect(
        next(DateTime.utc(2026, 11, 8, 15, 58, 59)),
        const Duration(seconds: 1),
      );
      expect(next(_start), Duration.zero);
      expect(next(_start.add(const Duration(hours: 1))), Duration.zero);
    });
  });

  test('the tassel swings out, back and settles at the board keyframes', () {
    final angles = [0.0, 0.18, 0.38, 0.56, 0.74, 1.0]
        .map(PantasEffects.tasselSwing)
        .toList();
    expect(angles, [0, 11, -8, 5, -2.5, 0]);
  });

  group('screen', () {
    late _Clock clock;
    late _Access access;
    late _Repository repository;
    late StreamController<AuthState> states;

    setUp(() {
      clock = _Clock(DateTime.utc(2026, 11, 7, 6, 19));
      access = _Access([BetaAccess(selected: true, waitUntil: _start)]);
      states = StreamController<AuthState>();
      repository = _Repository(
        onSignOut: () => states.add(const AuthState.anonymous(uid: 'anon')),
      );
    });
    tearDown(() => states.close());

    Future<GoRouter> pumpGate(
      WidgetTester tester, {
      Size size = _phone,
      bool dark = false,
      bool reduced = false,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final container = ProviderContainer(
        overrides: [
          betaGateActiveProvider.overrideWithValue(true),
          betaClockProvider.overrideWithValue(clock.call),
          betaAccessGatewayProvider.overrideWithValue(access),
          authRepositoryProvider.overrideWithValue(repository),
          authStateProvider.overrideWith((ref) => states.stream),
        ],
      );
      addTearDown(container.dispose);
      final refresh = ValueNotifier<int>(0);
      addTearDown(refresh.dispose);
      container.listen(betaGateStatusProvider, (_, __) => refresh.value++);
      final router = GoRouter(
        initialLocation: '/beta',
        refreshListenable: refresh,
        redirect: (context, state) => betaGateRedirect(
          path: state.matchedLocation,
          active: true,
          access: container.read(betaGateStatusProvider),
          now: clock.now,
        ),
        routes: [
          GoRoute(path: '/beta', builder: (_, __) => const BetaGatePage()),
          GoRoute(path: '/home', builder: (_, __) => const Text('home screen')),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: dark ? appDarkTheme() : appLightTheme(),
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
              child: child!,
            ),
          ),
        ),
      );
      states.add(_email);
      await tester.pump();
      await tester.pump();
      return router;
    }

    Future<void> endPage(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
    }

    Color? colorOf(WidgetTester tester, String text) =>
        tester.widget<Text>(find.text(text)).style?.color;

    testWidgets('shows the board copy, tiles and actions', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpGate(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('The beta starts Nov 9'), findsOneWidget);
      expect(
        find.textContaining("You're signed in as juan@gmail.com."),
        findsOneWidget,
      );
      final email = tester.widget<RichText>(
        find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              w.text.toPlainText().contains("You're signed in"),
        ),
      );
      final spans = <InlineSpan>[];
      email.text.visitChildren((span) {
        spans.add(span);
        return true;
      });
      expect(
        spans.whereType<TextSpan>().any(
              (s) =>
                  s.text == 'juan@gmail.com' &&
                  s.style?.fontWeight == FontWeight.w600,
            ),
        isTrue,
        reason: 'the email is bold',
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('09'), findsOneWidget);
      expect(find.text('41'), findsOneWidget);
      expect(find.text('day'), findsOneWidget);
      expect(find.text('hours'), findsOneWidget);
      expect(find.text('min'), findsOneWidget);
      expect(find.text('Use a Different Email'), findsOneWidget);
      expect(find.textContaining('Need help?'), findsOneWidget);
      expect(
        find.textContaining('support@pantas.study', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('1 day, 9 hours and 41 minutes to go'),
        findsOneWidget,
      );
      // The first value is not teal. Only a rolled value is.
      expect(colorOf(tester, '41'), PantasColors.light.label);
      semantics.dispose();
      await endPage(tester);
    });

    testWidgets('the phone logo is 104 with a 34 point title', (tester) async {
      await pumpGate(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(tester.widget<PantasLogo>(find.byType(PantasLogo)).size, 104);
      expect(
        tester.widget<Text>(find.text('The beta starts Nov 9')).style?.fontSize,
        34,
      );
      await endPage(tester);
    });

    testWidgets('the laptop logo is 120 with a 48 point title', (tester) async {
      await pumpGate(tester, size: _laptop);
      await tester.pump(const Duration(seconds: 3));
      expect(tester.widget<PantasLogo>(find.byType(PantasLogo)).size, 120);
      expect(
        tester.widget<Text>(find.text('The beta starts Nov 9')).style?.fontSize,
        48,
      );
      expect(find.text('Use a Different Email'), findsOneWidget);
      await endPage(tester);
    });

    testWidgets('dark mode uses the dark tokens', (tester) async {
      await pumpGate(tester, dark: true);
      await tester.pump(const Duration(seconds: 3));
      final tiles = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == PantasColors.dark.surface,
      );
      expect(tiles, findsNWidgets(3));
      expect(colorOf(tester, '41'), PantasColors.dark.label);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        PantasColors.dark.background,
      );
      await endPage(tester);
    });

    for (final (name, size) in [('phone', _phone), ('laptop', _laptop)]) {
      testWidgets('the tester guide link sits under the countdown ($name)',
          (tester) async {
        await pumpGate(tester, size: size);
        await tester.pump(const Duration(seconds: 3));
        final link = find.text('Read the tester guide');
        expect(link, findsOneWidget);
        final style = tester.widget<Text>(link).style;
        expect(style?.fontSize, 17);
        expect(style?.fontWeight, FontWeight.w600);
        expect(style?.color, PantasColors.light.accent);
        expect(
          tester.getTopLeft(link).dy,
          greaterThan(tester.getBottomLeft(find.text('min')).dy),
          reason: 'below the tiles',
        );
        expect(
          tester.getBottomLeft(link).dy,
          lessThan(tester.getTopLeft(find.text('Use a Different Email')).dy),
          reason: 'above the buttons',
        );
        await endPage(tester);
      });
    }

    testWidgets('the tester guide link opens the guide', (tester) async {
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (call) async {
          calls.add(call);
          return true;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      await pumpGate(tester);
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.text('Read the tester guide'));
      await tester.pump();
      final launch = calls.singleWhere((c) => c.method == 'launch');
      expect(
        (launch.arguments as Map<Object?, Object?>)['url'],
        'https://www.pantas.study/beta/guide',
      );
      await endPage(tester);
    });

    testWidgets('the minutes roll each minute, the new value in teal',
        (tester) async {
      await pumpGate(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('41'), findsOneWidget);

      clock.now = clock.now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(minutes: 1));
      // Mid roll: the old value is leaving while the new one arrives.
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text('41'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('41'), findsNothing);
      expect(find.text('40'), findsOneWidget);
      expect(colorOf(tester, '40'), PantasColors.light.accent);
      await endPage(tester);
    });

    testWidgets('hours and days roll the same way when they change',
        (tester) async {
      // 24 hours and 1 minute to go: 1 day, 00 hours, 01 min.
      clock.now = _start.subtract(const Duration(hours: 24, minutes: 1));
      await pumpGate(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('00'), findsNWidgets(1));
      expect(find.text('01'), findsOneWidget);

      clock.now = clock.now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(minutes: 1));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('00'), findsNWidgets(2));

      // One minute later it is 23:59 with no day left.
      clock.now = clock.now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(minutes: 1));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('1'), findsOneWidget, reason: 'the day is leaving');
      expect(find.text('0'), findsOneWidget, reason: 'and 0 is arriving');
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('1'), findsNothing);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);
      expect(find.text('59'), findsOneWidget);
      expect(find.text('days'), findsOneWidget);
      expect(find.text('hours'), findsOneWidget);
      expect(colorOf(tester, '0'), PantasColors.light.accent);
      expect(colorOf(tester, '23'), PantasColors.light.accent);
      expect(colorOf(tester, '59'), PantasColors.light.accent);
      await endPage(tester);
    });

    testWidgets('the countdown is announced politely, once a minute',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpGate(tester);
      await tester.pump(const Duration(seconds: 3));
      final node = tester.getSemantics(
        find.bySemanticsLabel('1 day, 9 hours and 41 minutes to go'),
      );
      expect(node.flagsCollection.isLiveRegion, isTrue);
      // The tiles add no second announcement of their own.
      expect(find.bySemanticsLabel('41'), findsNothing);

      clock.now = clock.now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(minutes: 1));
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.bySemanticsLabel('1 day, 9 hours and 40 minutes to go'),
        findsOneWidget,
      );
      // Seconds passing inside a minute change nothing.
      for (var i = 0; i < 5; i++) {
        clock.now = clock.now.add(const Duration(seconds: 10));
        await tester.pump(const Duration(seconds: 10));
      }
      expect(
        find.bySemanticsLabel('1 day, 9 hours and 40 minutes to go'),
        findsOneWidget,
      );
      semantics.dispose();
      await endPage(tester);
    });

    testWidgets('reduced motion swaps the value at once', (tester) async {
      await pumpGate(tester, reduced: true);
      await tester.pump();
      expect(find.text('41'), findsOneWidget);
      clock.now = clock.now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(minutes: 1));
      expect(find.text('41'), findsNothing, reason: 'no roll, no old value');
      expect(find.text('40'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
      await endPage(tester);
    });

    testWidgets('reduced motion shows everything at the first frame',
        (tester) async {
      await pumpGate(tester, reduced: true);
      expect(find.text('The beta starts Nov 9'), findsOneWidget);
      expect(find.text('Use a Different Email'), findsOneWidget);
      for (final tile in ['1', '09', '41']) {
        expect(find.text(tile), findsOneWidget);
      }
      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((o) => o.opacity)
          .toList();
      expect(opacities, everyElement(1.0), reason: 'nothing is mid-entrance');
      await endPage(tester);
    });

    testWidgets('Use a Different Email signs out and returns to the email step',
        (tester) async {
      await pumpGate(tester);
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.text('Use a Different Email'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(repository.signOutCalls, 1);
      expect(find.text('The beta starts Nov 9'), findsNothing);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await endPage(tester);
    });

    testWidgets('at zero it asks again and opens the app without a reload',
        (tester) async {
      access = _Access([
        BetaAccess(selected: true, waitUntil: _start),
        BetaAccess.open,
      ]);
      clock.now = _start.subtract(const Duration(seconds: 90));
      final router = await pumpGate(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('02'), findsOneWidget);
      expect(access.checks, 1);

      clock.now = clock.now.add(const Duration(seconds: 30));
      await tester.pump(const Duration(seconds: 30));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('01'), findsOneWidget);
      expect(access.checks, 1, reason: 'no early recheck');

      clock.now = _start;
      await tester.pump(const Duration(minutes: 1));
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(access.checks, 2);
      expect(find.text('home screen'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/home');
      await endPage(tester);
    });

    testWidgets('a server clock that lags still opens the app at zero',
        (tester) async {
      // The server answers "wait" again, but the start has passed here.
      access = _Access([BetaAccess(selected: true, waitUntil: _start)]);
      clock.now = _start.subtract(const Duration(minutes: 1));
      await pumpGate(tester);
      await tester.pump(const Duration(seconds: 3));
      clock.now = _start.add(const Duration(milliseconds: 5));
      await tester.pump(const Duration(minutes: 1));
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(access.checks, 2);
      expect(find.text('home screen'), findsOneWidget);
      await endPage(tester);
    });

    testWidgets('a selected tester with no wait goes straight to the app',
        (tester) async {
      access = _Access([BetaAccess.open]);
      await pumpGate(tester);
      await tester.pumpAndSettle();
      expect(find.text('home screen'), findsOneWidget);
      expect(find.text('The beta starts Nov 9'), findsNothing);
      await endPage(tester);
    });

    testWidgets('an unselected account sees the not-on-the-list screen',
        (tester) async {
      access = _Access([BetaAccess.denied]);
      await pumpGate(tester);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text("This email isn't on the beta list"), findsOneWidget);
      expect(find.text('The beta starts Nov 9'), findsNothing);
      expect(
        find.textContaining('Selected testers get an email from Pantas.'),
        findsOneWidget,
      );
      expect(find.textContaining('Nov 7'), findsNothing);
      await endPage(tester);
    });
  });
}
