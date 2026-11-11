import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/start_location.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';

const _title = 'Take a timed mock';
const _message = 'Create a free account to take a mock and keep your results.';
const _note = 'Free includes one mock every 30 days.';
const _button = 'Create Free Account';
const _failure = 'Could not load your mock.';
const _resume = '/quiz/mock/resume/mock_1?examId=upcat';

void main() {
  setUpAll(loadDsFonts);
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'upcat',
      code: 'UPCAT',
      name: 'UPCAT',
      shortName: 'UPCAT',
    );
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('upcat');
  });

  tearDown(() => db.close());

  const named = AuthUser(
    uid: 'firebase_account_2',
    email: 'student@example.com',
    displayName: 'Student',
  );
  const anonymous = AuthState.anonymous(uid: 'anon');
  const namedState = AuthState.signedIn(user: named);

  ServerMockApi available() => ServerMockApi(
        (_, __) async => {
          'examId': 'upcat',
          'serverNow': 2000,
          'nextEligibleAt': null,
          'status': 'available',
          'proCovered': false,
          'lastMockId': null,
        },
      );

  ServerMockApi failing() => ServerMockApi(
        (_, __) async => throw const ServerMockException(code: 'internal'),
      );

  /// Pumps the whole app in a window of [size], then opens [path]. [auth]
  /// feeds the sign-in state.
  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    required Size size,
    required Stream<AuthState> auth,
    bool web = true,
    ServerMockApi? api,
    String? openedAt,
    bool settle = true,
    bool todayFails = false,
  }) async {
    // A page opened at an address starts the router there, as a reload does.
    forgetStartLocation();
    if (openedAt != null) {
      rememberStartLocation(Uri.parse(openedAt), isWeb: true);
    }
    addTearDown(forgetStartLocation);
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    debugWebPlatformOverride = web;
    addTearDown(() => debugWebPlatformOverride = null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (todayFails)
            sessionPanelProvider('upcat').overrideWith(
              (_) async => throw StateError('Server blocked'),
            ),
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          entitlementProvider
              .overrideWith((_) => Stream.value(const Entitlement.free())),
          proForActiveExamProvider.overrideWith((_) async => false),
          mockUsesServerProvider.overrideWithValue(web),
          authStateProvider.overrideWith((_) => auth),
          serverMockActorProvider.overrideWithValue(() => 'a'),
          serverMockApiProvider.overrideWithValue(api ?? available()),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    // The skeleton shimmers for as long as it shows, so it never settles.
    Future<void> settled() => settle
        ? tester.pumpAndSettle()
        : tester.pump(const Duration(seconds: 1));
    await settled();
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    final container =
        ProviderScope.containerOf(tester.element(find.byType(App)));
    if (openedAt == null) {
      container.read(routerProvider).go('/quiz');
      await settled();
    }
    return container;
  }

  String location(ProviderContainer container) =>
      container.read(routerProvider).routeInformationProvider.value.uri.path;

  void expectSignUpCard() {
    expect(find.byType(MockSignUpCard), findsOneWidget);
    expect(find.text(_title), findsOneWidget);
    expect(find.text(_message), findsOneWidget);
    expect(find.text(_note), findsOneWidget);
    expect(find.text(_button), findsOneWidget);
    expect(find.text(_failure), findsNothing);
    expect(find.byType(MockCard), findsNothing);
  }

  group('MockSignUpCard layout', () {
    Future<void> pumpCard(
      WidgetTester tester, {
      required bool wide,
      required bool dark,
    }) async {
      final size = wide ? const Size(1440, 900) : const Size(390, 844);
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(size: size, disableAnimations: true),
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: wide ? 520 : 358,
                  child: MockSignUpCard(onCreateAccount: () {}),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final dark in [true, false]) {
      final theme = dark ? 'dark' : 'light';
      testWidgets('wide $theme follows the board', (tester) async {
        await pumpCard(tester, wide: true, dark: dark);
        expectSignUpCard();
        final title = tester.widget<Text>(find.text(_title)).style!;
        expect(title.fontSize, 22);
        expect(title.fontWeight, FontWeight.w700);
        expect(title.letterSpacing, -.264);
        expect(tester.widget<Text>(find.text(_message)).style!.fontSize, 16);
        expect(tester.widget<Text>(find.text(_note)).style!.fontSize, 15);
        final button = find.widgetWithText(WebButton, _button);
        expect(tester.getSize(button).height, 50);
        // The button is the system's primary Button at the large size.
        final system = tester.widget<WebButton>(button);
        expect(system.size, PantasButtonSize.lg);
        // No full-width button on a wide screen: natural width.
        expect(system.expand, isFalse);
        expect(tester.getSize(button).width, lessThan(300));
        // 24 px (`space-24`, the system step nearest the board's 22) between
        // the parts of the card.
        expect(
          tester.getTopLeft(find.text(_message)).dy -
              tester.getBottomLeft(find.text(_title)).dy,
          24,
        );
        expect(
          tester.getTopLeft(button).dy -
              tester.getBottomLeft(find.text(_note)).dy,
          24,
        );
      });

      testWidgets('phone $theme follows the board', (tester) async {
        await pumpCard(tester, wide: false, dark: dark);
        expectSignUpCard();
        final title = tester.widget<Text>(find.text(_title)).style!;
        expect(title.fontSize, 20);
        expect(title.fontWeight, FontWeight.w700);
        expect(tester.widget<Text>(find.text(_message)).style!.fontSize, 15);
        expect(tester.widget<Text>(find.text(_note)).style!.fontSize, 13);
        final button = find.widgetWithText(PantasButton, _button);
        expect(tester.getSize(button).height, 50);
        expect(tester.getSize(button).width, 358 - 32);
        // 12 px between the parts of the card.
        expect(
          tester.getTopLeft(find.text(_message)).dy -
              tester.getBottomLeft(find.text(_title)).dy,
          12,
        );
        expect(
          tester.getTopLeft(button).dy -
              tester.getBottomLeft(find.text(_note)).dy,
          12,
        );
      });
    }

    testWidgets('the button calls back', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: MockSignUpCard(onCreateAccount: () => taps++),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(_button));
      expect(taps, 1);
    });
  });

  group('Quiz tab', () {
    testWidgets('anonymous student on wide web sees the sign-up card',
        (tester) async {
      await pumpApp(
        tester,
        size: const Size(1440, 900),
        auth: Stream.value(anonymous),
      );
      expect(tester.element(find.byType(App)).wideWeb, isTrue);
      expectSignUpCard();
    });

    testWidgets('anonymous student on phone web sees the sign-up card',
        (tester) async {
      await pumpApp(
        tester,
        size: const Size(390, 844),
        auth: Stream.value(anonymous),
      );
      expect(tester.element(find.byType(App)).wideWeb, isFalse);
      expectSignUpCard();
    });

    testWidgets('a signed-out student sees the sign-up card too',
        (tester) async {
      await pumpApp(
        tester,
        size: const Size(1440, 900),
        auth: Stream.value(const AuthState.signedOut()),
      );
      expectSignUpCard();
    });

    testWidgets('the button opens the account page', (tester) async {
      await pumpApp(
        tester,
        size: const Size(1440, 900),
        auth: Stream.value(anonymous),
      );
      await tester.tap(find.text(_button));
      await tester.pumpAndSettle();
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byType(MockSignUpCard), findsNothing);
    });

    testWidgets('shows neither the card nor an error while auth is unknown',
        (tester) async {
      await pumpApp(
        tester,
        size: const Size(1440, 900),
        auth: const Stream<AuthState>.empty(),
        settle: false,
      );
      expect(find.byType(MockSignUpCard), findsNothing);
      expect(find.byType(MockCard), findsNothing);
      expect(find.text(_failure), findsNothing);
    });

    testWidgets('becomes the normal card without a reload once named',
        (tester) async {
      final auth = StreamController<AuthState>()..add(anonymous);
      addTearDown(auth.close);
      await pumpApp(tester, size: const Size(1440, 900), auth: auth.stream);
      expectSignUpCard();
      auth.add(namedState);
      await tester.pumpAndSettle();
      expect(find.byType(MockSignUpCard), findsNothing);
      expect(find.byType(MockCard), findsOneWidget);
      expect(find.text(_failure), findsNothing);
    });

    testWidgets('a named student sees the normal mock card', (tester) async {
      await pumpApp(
        tester,
        size: const Size(1440, 900),
        auth: Stream.value(namedState),
      );
      expect(find.byType(MockSignUpCard), findsNothing);
      expect(find.byType(MockCard), findsOneWidget);
      expect(find.text(_button), findsNothing);
    });

    testWidgets('a real failure for a named student keeps the error',
        (tester) async {
      await pumpApp(
        tester,
        size: const Size(1440, 900),
        auth: Stream.value(namedState),
        api: failing(),
        todayFails: true,
      );
      expect(find.text('MOCK EXAM'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(_failure)).dy,
        closeTo(
          tester
              .getTopLeft(find.text('Could not load your practice.').first)
              .dy,
          1,
        ),
      );
      expect(find.text(_failure), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(StateView, _failure),
          matching: find.text('Try Again'),
        ),
        findsOneWidget,
      );
      expect(find.byType(MockSignUpCard), findsNothing);
      expect(find.text(_button), findsNothing);
    });

    testWidgets('the native app is unchanged', (tester) async {
      await pumpApp(
        tester,
        size: const Size(390, 844),
        auth: Stream.value(anonymous),
        web: false,
      );
      expect(find.byType(MockSignUpCard), findsNothing);
      expect(find.byType(MockCard), findsOneWidget);
      expect(find.text(_failure), findsNothing);
    });
  });

  group('mock resume address', () {
    testWidgets('an anonymous student is returned to the Quiz tab card',
        (tester) async {
      final container = await pumpApp(
        tester,
        size: const Size(1440, 900),
        auth: Stream.value(anonymous),
        openedAt: _resume,
      );
      expect(location(container), '/quiz');
      expectSignUpCard();
    });

    testWidgets('shows no error while auth is unknown', (tester) async {
      await pumpApp(
        tester,
        size: const Size(1440, 900),
        auth: const Stream<AuthState>.empty(),
        settle: false,
        openedAt: _resume,
      );
      expect(find.text(_failure), findsNothing);
      expect(find.byType(MockSignUpCard), findsNothing);
    });
  });
}
