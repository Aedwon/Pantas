import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/app/beta_gate.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart';
import 'package:pantas/app/sign_in/sign_in_parts.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';

class _Gateway extends Mock implements AuthGateway {}

class FakeCodes implements EmailCodeAuth {
  final requests = <String>[];
  final verifies = <List<String>>[];
  int resendAfter = 42;
  int cancels = 0;

  /// False answers like a cooldown the caller did not start.
  bool issuesChallenge = true;
  Exception? requestError;
  Future<SignInResult> Function(String challengeId, String code)? onVerify;

  @override
  Future<EmailCodeRequest> requestCode(String email) async {
    requests.add(email);
    final error = requestError;
    if (error != null) throw error;
    return EmailCodeRequest(
      resendAfterSeconds: resendAfter,
      challengeId: issuesChallenge ? 'challenge-${requests.length}' : null,
    );
  }

  @override
  Future<SignInResult> verifyCode(String challengeId, String code) {
    verifies.add([challengeId, code]);
    return onVerify!(challengeId, code);
  }

  @override
  void cancelVerification() => cancels++;
}

class _Repository extends AuthRepository {
  _Repository({this.google, this.onSignOut}) : super(gateway: _Gateway());

  final SignInResult? google;
  final void Function()? onSignOut;
  int googleCalls = 0;
  int signOutCalls = 0;

  @override
  Future<SignInResult> signInWithGoogle() async {
    googleCalls++;
    return google ?? const SignInResult.cancelled();
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    onSignOut?.call();
  }
}

const _phone = Size(390, 844);
const _laptop = Size(1440, 900);

void main() {
  late FakeCodes codes;
  late _Repository repository;
  var accessChecks = 0;

  setUp(() {
    codes = FakeCodes();
    repository = _Repository();
    accessChecks = 0;
  });

  Future<ProviderContainer> pumpPage(
    WidgetTester tester, {
    Size size = _phone,
    bool reduced = true,
    bool dark = false,
    bool beta = true,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => EmailSignInPage(beta: beta),
        ),
        GoRoute(path: '/beta', builder: (_, __) => const Text('gate screen')),
        GoRoute(path: '/home', builder: (_, __) => const Text('home screen')),
      ],
    );
    addTearDown(router.dispose);
    final container = ProviderContainer(
      overrides: [
        emailCodeAuthProvider.overrideWithValue(codes),
        authRepositoryProvider.overrideWithValue(repository),
        betaAccessProvider.overrideWith((ref) async {
          accessChecks++;
          return false;
        }),
      ],
    );
    addTearDown(container.dispose);
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
    await tester.pump();
    return container;
  }

  Finder digit(String d) =>
      find.byWidgetPredicate((w) => w is Text && w.data == d);

  Future<void> goToCode(
    WidgetTester tester, {
    String email = 'juan@gmail.com',
  }) async {
    await tester.enterText(find.byType(TextField), email);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> typeCode(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(TextField), code);
    await tester.pump();
  }

  group('email step', () {
    testWidgets('shows the board copy', (tester) async {
      await pumpPage(tester);
      expect(find.text('Welcome to Pantas'), findsNothing);
      expect(find.textContaining('Welcome to Pantas'), findsOneWidget);
      expect(find.text('BETA', findRichText: true), findsOneWidget);
      expect(
        find.text('Sign in with the email you applied with.'),
        findsOneWidget,
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Use Google Instead'), findsOneWidget);
      expect(find.textContaining('Need help?'), findsOneWidget);
      expect(find.text('Enter'), findsNothing, reason: 'no key hint on phone');
    });

    testWidgets('an invalid email shows the message and stays enabled',
        (tester) async {
      await pumpPage(tester);
      await tester.enterText(find.byType(TextField), 'juan@gmail');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text('Enter a full email address, like juan@gmail.com.'),
        findsOneWidget,
      );
      expect(codes.requests, isEmpty);
      // The button never disables: pressing again asks again.
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(codes.requests, isEmpty);
      // Typing clears the message.
      await tester.enterText(find.byType(TextField), 'juan@gmail.co');
      await tester.pump();
      expect(
        find.text('Enter a full email address, like juan@gmail.com.'),
        findsNothing,
      );
    });

    testWidgets('the invalid field shakes with motion on', (tester) async {
      await pumpPage(tester, reduced: false);
      await tester.enterText(find.byType(TextField), 'nope');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      final shake = find.byType(SignInShake);
      double offset() => tester
          .widget<Transform>(
            find.descendant(of: shake, matching: find.byType(Transform)).first,
          )
          .transform
          .getTranslation()
          .x;
      await tester.pump(const Duration(milliseconds: 80));
      expect(offset(), isNot(0));
      await tester.pump(const Duration(milliseconds: 500));
      expect(offset(), 0);
    });

    testWidgets('a valid email asks for a code and opens the code step',
        (tester) async {
      await pumpPage(tester);
      await goToCode(tester, email: ' juan@gmail.com ');
      expect(codes.requests, ['juan@gmail.com']);
      expect(find.text('Enter the code'), findsOneWidget);
      expect(
        find.textContaining('We sent a 6-digit code to juan@gmail.com.'),
        findsOneWidget,
      );
      expect(find.text('Code'), findsOneWidget);
      expect(
        find.text("Didn't get it? You can resend in 0:42."),
        findsOneWidget,
      );
      expect(find.text('Use a Different Email'), findsOneWidget);
      expect(find.text('Email'), findsNothing);
    });

    testWidgets('send errors show their message', (tester) async {
      await pumpPage(tester);
      codes.requestError = const EmailCodeException(
        EmailCodeFailure.tooManyRequests,
      );
      await tester.enterText(find.byType(TextField), 'juan@gmail.com');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text('Too many codes requested. Try again later.'),
        findsOneWidget,
      );
      expect(find.text('Enter the code'), findsNothing);

      codes.requestError = const EmailCodeException(
        EmailCodeFailure.unavailable,
      );
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text("We couldn't send the code. Try again."),
        findsOneWidget,
      );
    });

    testWidgets('a cooldown without a challenge waits on the email step',
        (tester) async {
      await pumpPage(tester);
      codes
        ..issuesChallenge = false
        ..resendAfter = 3;
      await tester.enterText(find.byType(TextField), 'juan@gmail.com');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Enter the code'), findsNothing);
      expect(find.text('You can request a code in 0:03.'), findsOneWidget);
      expect(codes.requests, hasLength(1));

      // While the wait runs, Continue does not ask again for the same email.
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(codes.requests, hasLength(1));

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('You can request a code in 0:02.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('You can request'), findsNothing);

      // After it ends, Continue asks again, and a challenge opens the step.
      codes.issuesChallenge = true;
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(codes.requests, hasLength(2));
      expect(find.text('Enter the code'), findsOneWidget);
    });

    testWidgets('a different email is not held by the wait', (tester) async {
      await pumpPage(tester);
      codes
        ..issuesChallenge = false
        ..resendAfter = 40;
      await tester.enterText(find.byType(TextField), 'juan@gmail.com');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.textContaining('You can request a code in'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'maria@gmail.com');
      await tester.pump();
      expect(find.textContaining('You can request'), findsNothing);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(codes.requests, ['juan@gmail.com', 'maria@gmail.com']);
    });

    testWidgets('Enter submits the email', (tester) async {
      await pumpPage(tester);
      await tester.enterText(find.byType(TextField), 'juan@gmail.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(codes.requests, ['juan@gmail.com']);
    });

    testWidgets('Google sign-in continues to the gate', (tester) async {
      repository = _Repository(google: const SignInResult.linkedExisting());
      await pumpPage(tester);
      await tester.tap(find.text('Use Google Instead'));
      await tester.pump();
      await tester.pump();
      expect(repository.googleCalls, 1);
      expect(find.text('gate screen'), findsOneWidget);
    });

    testWidgets('a cancelled Google sign-in stays put', (tester) async {
      await pumpPage(tester);
      await tester.tap(find.text('Use Google Instead'));
      await tester.pump();
      await tester.pump();
      expect(find.text('gate screen'), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('outside the beta there is no BETA mark and Home follows',
        (tester) async {
      repository = _Repository(google: const SignInResult.linkedExisting());
      await pumpPage(tester, beta: false);
      expect(find.text('BETA', findRichText: true), findsNothing);
      expect(find.text('Sign in with your email.'), findsOneWidget);
      await tester.tap(find.text('Use Google Instead'));
      await tester.pump();
      await tester.pump();
      expect(find.text('home screen'), findsOneWidget);
    });
  });

  group('code step', () {
    testWidgets('typing fills the boxes and the sixth digit submits',
        (tester) async {
      final pending = Completer<SignInResult>();
      codes.onVerify = (_, __) => pending.future;
      await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '4821');
      expect(digit('4'), findsOneWidget);
      expect(digit('1'), findsOneWidget);
      expect(codes.verifies, isEmpty);
      await typeCode(tester, '482139');
      expect(codes.verifies, [
        ['challenge-1', '482139'],
      ]);
      expect(find.byType(SignInSpinner), findsOneWidget);
      pending.complete(const SignInResult.failed(reason: 'x'));
      await tester.pump();
    });

    testWidgets('only digits count and a long paste keeps six', (tester) async {
      codes.onVerify = (_, __) => Completer<SignInResult>().future;
      await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '4a8-2');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '482',
      );
      await typeCode(tester, '48 21 39 77');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '482139',
      );
    });

    testWidgets('a wrong code shows the message, then clears the digits',
        (tester) async {
      codes.onVerify = (_, __) async =>
          throw const EmailCodeException(EmailCodeFailure.wrong, triesLeft: 4);
      await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '482139');
      await tester.pump();
      const message = "That code isn't right. Check the email and try again.";
      expect(find.text(message), findsOneWidget);
      expect(digit('4'), findsOneWidget, reason: 'red digits hold first');
      expect(codes.verifies, hasLength(1));

      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 300));
      expect(digit('4'), findsNothing, reason: 'then they clear');
      expect(find.text(message), findsOneWidget, reason: 'message stays');

      await typeCode(tester, '7');
      expect(find.text(message), findsNothing, reason: 'typing clears it');
      expect(digit('7'), findsOneWidget);
    });

    testWidgets('typing during the wrong-code beat starts over',
        (tester) async {
      codes.onVerify = (_, __) async =>
          throw const EmailCodeException(EmailCodeFailure.wrong);
      await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '482139');
      await tester.pump();
      await typeCode(tester, '4821397');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '7',
      );
      // The timers of the old beat are gone: nothing clears the new digit.
      await tester.pump(const Duration(seconds: 3));
      expect(digit('7'), findsOneWidget);
    });

    testWidgets('an expired code offers a new one', (tester) async {
      codes.onVerify = (_, __) async =>
          throw const EmailCodeException(EmailCodeFailure.expired);
      await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '482139');
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text('This code expired. Get a new one to keep going.'),
        findsOneWidget,
      );
      expect(find.text('Send a New Code'), findsOneWidget);
      expect(find.text('Use a Different Email'), findsOneWidget);
      expect(find.textContaining('Need help?'), findsOneWidget);
      expect(find.textContaining("Didn't get it?"), findsNothing);

      codes.resendAfter = 60;
      await tester.tap(find.text('Send a New Code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(codes.requests, ['juan@gmail.com', 'juan@gmail.com']);
      expect(find.text('Send a New Code'), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
      expect(
        find.text("Didn't get it? You can resend in 1:00."),
        findsOneWidget,
      );
      // The new challenge replaces the old one.
      codes.onVerify = (_, __) => Completer<SignInResult>().future;
      await typeCode(tester, '111111');
      expect(codes.verifies.last, ['challenge-2', '111111']);
    });

    testWidgets('too many tries has its own message', (tester) async {
      codes.onVerify = (_, __) async =>
          throw const EmailCodeException(EmailCodeFailure.tooManyTries);
      await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '482139');
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text('Too many tries. Get a new code to keep going.'),
        findsOneWidget,
      );
      expect(find.text('Send a New Code'), findsOneWidget);
    });

    testWidgets('server limits and a disabled account keep the code',
        (tester) async {
      codes.onVerify = (_, __) async =>
          throw const EmailCodeException(EmailCodeFailure.rateLimited);
      await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '482139');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Too many tries. Try again later.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      codes.onVerify = (_, __) async =>
          throw const EmailCodeException(EmailCodeFailure.disabled);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text("This account can't sign in. Write to support@pantas.study."),
        findsOneWidget,
      );
    });

    testWidgets('an incomplete code does not submit', (tester) async {
      await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '482');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(codes.verifies, isEmpty);
    });

    testWidgets('success draws the check, holds, then goes to the gate',
        (tester) async {
      final pending = Completer<SignInResult>();
      codes.onVerify = (_, __) => pending.future;
      final container = await pumpPage(tester);
      container.listen(betaAccessProvider, (_, __) {});
      await goToCode(tester);
      await typeCode(tester, '482139');
      expect(container.read(signInHoldProvider), isTrue);
      expect(find.byType(SignInSpinner), findsOneWidget);

      pending.complete(const SignInResult.switchedToExisting());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Signed In'), findsOneWidget);
      expect(find.byType(SignInSpinner), findsNothing);
      expect(container.read(signInHoldProvider), isTrue);
      expect(find.text('gate screen'), findsNothing);

      await tester.pump(signInHold);
      await tester.pump();
      expect(container.read(signInHoldProvider), isFalse);
      expect(find.text('gate screen'), findsOneWidget);
      expect(accessChecks, greaterThan(1), reason: 'the check reruns');
    });

    testWidgets('success with motion plays the staggered rings',
        (tester) async {
      codes.onVerify = (_, __) async => const SignInResult.linkedExisting();
      await pumpPage(tester, reduced: false);
      await tester.enterText(find.byType(TextField), 'juan@gmail.com');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await typeCode(tester, '482139');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Signed In'), findsOneWidget);
      await tester.pump(signInHold);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('gate screen'), findsOneWidget);
    });

    testWidgets('Use a Different Email keeps the typed email', (tester) async {
      await pumpPage(tester);
      await goToCode(tester);
      await tester.tap(find.text('Use a Different Email'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Enter the code'), findsNothing);
      expect(find.text('Email'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'juan@gmail.com',
      );
    });

    testWidgets('the countdown becomes Resend Code, which sends again',
        (tester) async {
      await pumpPage(tester);
      codes.resendAfter = 3;
      await goToCode(tester);
      expect(
        find.text("Didn't get it? You can resend in 0:03."),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text("Didn't get it? You can resend in 0:02."),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('You can resend'), findsNothing);
      expect(
        find.textContaining('Resend Code', findRichText: true),
        findsOneWidget,
      );

      codes.resendAfter = 60;
      await tester.tapOnText(find.textRange.ofSubstring('Resend Code'));
      await tester.pump();
      await tester.pump();
      expect(codes.requests, hasLength(2));
      expect(
        find.text("Didn't get it? You can resend in 1:00."),
        findsOneWidget,
      );
    });

    testWidgets('Use a Different Email mid-check cancels it', (tester) async {
      final pending = Completer<SignInResult>();
      codes.onVerify = (_, __) => pending.future;
      final container = await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '482139');
      expect(container.read(signInHoldProvider), isTrue);

      await tester.tap(find.text('Use a Different Email'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(codes.cancels, 1);
      expect(container.read(signInHoldProvider), isFalse);
      expect(find.text('Email'), findsOneWidget);

      // The late answer changes nothing on screen.
      pending.complete(const SignInResult.switchedToExisting());
      await tester.pump();
      await tester.pump(signInHold);
      expect(find.text('Signed In'), findsNothing);
      expect(find.text('gate screen'), findsNothing);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('closing the screen mid-check cancels it', (tester) async {
      codes.onVerify = (_, __) => Completer<SignInResult>().future;
      await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '482139');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(codes.cancels, 1);
    });

    testWidgets('leaving mid-check releases the gate hold', (tester) async {
      codes.onVerify = (_, __) => Completer<SignInResult>().future;
      final container = await pumpPage(tester);
      await goToCode(tester);
      await typeCode(tester, '482139');
      expect(container.read(signInHoldProvider), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(container.read(signInHoldProvider), isFalse);
    });
  });

  group('layouts', () {
    testWidgets('laptop shows the Enter key hint on both steps',
        (tester) async {
      await pumpPage(tester, size: _laptop);
      expect(find.text('Enter'), findsOneWidget);
      expect(find.textContaining('Need help?'), findsOneWidget);
      await goToCode(tester);
      expect(find.text('Enter the code'), findsOneWidget);
      expect(find.text('Enter'), findsOneWidget);
      expect(find.textContaining('Need help?'), findsOneWidget);
    });

    testWidgets('the logo does not move between steps', (tester) async {
      for (final size in [_phone, _laptop]) {
        await pumpPage(tester, size: size);
        final before = tester.getTopLeft(find.byType(PantasLogo));
        await goToCode(tester);
        final after = tester.getTopLeft(find.byType(PantasLogo));
        expect(after, before, reason: '$size');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('dark theme builds every step without overflow',
        (tester) async {
      for (final size in [_phone, _laptop]) {
        codes.onVerify = (_, __) async =>
            throw const EmailCodeException(EmailCodeFailure.wrong);
        await pumpPage(tester, size: size, dark: true);
        await goToCode(tester);
        await typeCode(tester, '482139');
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$size');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('a short phone scrolls instead of overflowing', (tester) async {
      await pumpPage(tester, size: const Size(360, 520));
      await goToCode(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('not on the list', () {
    Future<StreamController<AuthState>> pumpGate(WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _phone;
      addTearDown(tester.view.reset);
      final states = StreamController<AuthState>();
      addTearDown(states.close);
      repository = _Repository(
        onSignOut: () => states.add(const AuthState.anonymous(uid: 'anon')),
      );
      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, __) => const BetaGatePage())],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            emailCodeAuthProvider.overrideWithValue(codes),
            authRepositoryProvider.overrideWithValue(repository),
            betaAccessProvider.overrideWith((ref) async => false),
            authStateProvider.overrideWith((ref) => states.stream),
          ],
          child: MaterialApp.router(
            theme: appLightTheme(),
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
          ),
        ),
      );
      states.add(
        const AuthState.signedIn(
          user: AuthUser(
            uid: 'named',
            email: 'maria.santos@gmail.com',
            displayName: '',
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      return states;
    }

    testWidgets('explains the email and signs out to try another',
        (tester) async {
      await pumpGate(tester);
      expect(find.text("This email isn't on the beta list"), findsOneWidget);
      expect(
        find.textContaining(
          "You're signed in as maria.santos@gmail.com. If you applied with a "
          'different email, sign in with that one.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('Selected testers got an email on Nov 7.'),
        findsOneWidget,
      );
      expect(find.textContaining('Need help?'), findsOneWidget);

      await tester.tap(find.text('Use a Different Email'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(repository.signOutCalls, 1);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text("This email isn't on the beta list"), findsNothing);
    });

    testWidgets('the sign-in screen holds while the gate is checking',
        (tester) async {
      final container = await _pumpHeld(tester, codes, repository);
      expect(container.read(signInHoldProvider), isTrue);
      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('code digits', () {
    final formatter = CodeDigitsFormatter();
    TextEditingValue format(String old, String next) =>
        formatter.formatEditUpdate(
          TextEditingValue(text: old),
          TextEditingValue(text: next),
        );

    test('keeps digits, at most six', () {
      expect(format('', '12a3').text, '123');
      expect(format('123456', '1234567').text, '123456');
    });

    test('a pasted code replaces what is typed', () {
      expect(format('48', '48123456').text, '123456');
    });
  });
}

/// A gate with the hold on and the access check still running.
Future<ProviderContainer> _pumpHeld(
  WidgetTester tester,
  FakeCodes codes,
  _Repository repository,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _phone;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, __) => const BetaGatePage())],
  );
  addTearDown(router.dispose);
  final pending = Completer<bool>();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        emailCodeAuthProvider.overrideWithValue(codes),
        authRepositoryProvider.overrideWithValue(repository),
        betaAccessProvider.overrideWith((ref) => pending.future),
        signInHoldProvider.overrideWith((ref) => true),
        authStateProvider.overrideWith(
          (ref) => Stream.value(const AuthState.anonymous(uid: 'anon')),
        ),
      ],
      child: MaterialApp.router(
        theme: appLightTheme(),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byType(BetaGatePage)));
}
