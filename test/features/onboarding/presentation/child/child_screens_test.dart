import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/onboarding/presentation/child/child_nickname_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/child_notice_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/parent_setup_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/parent_sign_in_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/under_thirteen_screen.dart';

import '../../../../helpers/child_setup_harness.dart';

void main() {
  late FakeChildSetupGateway gateway;
  late FakeChildSessionStarter starter;
  late MockAuthRepository auth;

  setUp(() {
    gateway = FakeChildSetupGateway();
    starter = FakeChildSessionStarter();
    auth = fakeAuth();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    Widget screen, {
    Size size = const Size(390, 844),
    bool web = false,
  }) async {
    if (web) {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
    }
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        childSetupGatewayProvider.overrideWithValue(gateway),
        childSessionStarterProvider.overrideWithValue(starter),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLightTheme(web: web),
          home: MediaQuery(
            data: MediaQueryData(size: size, disableAnimations: true),
            child: screen,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return container;
  }

  PantasButton button(WidgetTester tester, String label) =>
      tester.widget<PantasButton>(find.widgetWithText(PantasButton, label));

  Finder tickRow(int index) => find.byType(CheckboxRow).at(index);

  group('under-13 screen (board 1A)', () {
    testWidgets('shows the board text, the guardian button and the notice',
        (tester) async {
      await pump(tester, const UnderThirteenScreen());
      expect(find.text(ChildSetupCopy.underThirteenTitle), findsOneWidget);
      expect(find.text(ChildSetupCopy.underThirteenBody), findsOneWidget);
      expect(find.text("I'm the Parent or Guardian"), findsOneWidget);
      expect(find.text('What a Parent or Guardian Agrees To'), findsOneWidget);
    });

    testWidgets('has no back', (tester) async {
      await pump(tester, const UnderThirteenScreen());
      expect(find.text('Back'), findsNothing);
      expect(
        find.byWidgetPredicate((w) => w is PopScope && !w.canPop),
        findsOneWidget,
      );
    });

    testWidgets('the main button is on top and the notice button below',
        (tester) async {
      await pump(tester, const UnderThirteenScreen());
      final main = tester.getTopLeft(find.text("I'm the Parent or Guardian"));
      final notice =
          tester.getTopLeft(find.text('What a Parent or Guardian Agrees To'));
      expect(main.dy, lessThan(notice.dy));
    });

    testWidgets('the buttons call their actions', (tester) async {
      var guardian = 0;
      var notice = 0;
      await pump(
        tester,
        UnderThirteenScreen(
          onGuardian: () => guardian++,
          onNotice: () => notice++,
        ),
      );
      await tester.tap(find.text("I'm the Parent or Guardian"));
      await tester.tap(find.text('What a Parent or Guardian Agrees To'));
      expect(guardian, 1);
      expect(notice, 1);
    });

    testWidgets('closed: keeps the screen, drops the guardian button',
        (tester) async {
      final container = await pump(tester, const UnderThirteenScreen());
      container.read(childSetupClosedProvider.notifier).state = true;
      await tester.pump();
      expect(find.text(ChildSetupCopy.closedTitle), findsOneWidget);
      expect(find.text(ChildSetupCopy.underThirteenTitle), findsNothing);
      expect(find.text("I'm the Parent or Guardian"), findsNothing);
      expect(find.text('Back'), findsNothing);
    });

    testWidgets('wide web draws the same screen', (tester) async {
      await pump(
        tester,
        const UnderThirteenScreen(),
        size: const Size(1440, 900),
        web: true,
      );
      expect(find.text(ChildSetupCopy.underThirteenTitle), findsOneWidget);
      expect(find.text("I'm the Parent or Guardian"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('parent sign-in (board 2)', () {
    testWidgets('shows the board text, a back and both buttons',
        (tester) async {
      await pump(tester, const ParentSignInScreen());
      expect(find.text(ChildSetupCopy.signInTitle), findsOneWidget);
      expect(find.text(ChildSetupCopy.signInLead), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Email'), findsOneWidget);
      final google = tester.getTopLeft(find.text('Continue with Google')).dy;
      final email = tester.getTopLeft(find.text('Continue with Email')).dy;
      expect(google, lessThan(email));
    });

    testWidgets('Email opens the email sign-in', (tester) async {
      var email = 0;
      await pump(tester, ParentSignInScreen(onEmail: () => email++));
      await tester.tap(find.text('Continue with Email'));
      expect(email, 1);
    });

    testWidgets('Google signs in through the app sign-in, then continues',
        (tester) async {
      when(auth.signInWithGoogle)
          .thenAnswer((_) async => const SignInResult.linkedExisting());
      var signedIn = 0;
      await pump(tester, ParentSignInScreen(onSignedIn: () => signedIn++));
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      verify(auth.signInWithGoogle).called(1);
      expect(signedIn, 1);
    });

    testWidgets('a cancelled Google sign-in stays and says nothing',
        (tester) async {
      var signedIn = 0;
      await pump(tester, ParentSignInScreen(onSignedIn: () => signedIn++));
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      expect(signedIn, 0);
      expect(find.byType(NoticeStrip), findsNothing);
    });

    testWidgets('a failed Google sign-in shows a notice that can be closed',
        (tester) async {
      when(auth.signInWithGoogle)
          .thenAnswer((_) async => const SignInResult.failed(reason: 'x'));
      await pump(tester, ParentSignInScreen(onSignedIn: () {}));
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      expect(find.text("We couldn't sign you in. Try again."), findsOneWidget);
      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pump();
      expect(find.byType(NoticeStrip), findsNothing);
    });
  });

  group('parent setup (board 2A)', () {
    testWidgets('starts with two empty ticks, each in its own card, button off',
        (tester) async {
      await pump(tester, const ParentSetupScreen());
      expect(find.text(ChildSetupCopy.setupTitle), findsOneWidget);
      expect(find.text(ChildSetupCopy.setupLead), findsOneWidget);
      expect(find.byType(CheckboxRow), findsNWidgets(2));
      expect(
        find.textContaining(
          'I am 18 or older and I am the parent or guardian',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'I consent to Pantas using my child',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Child Notice'), findsOneWidget);
      expect(button(tester, 'Set Up Account').onPressed, isNull);
      expect(find.byType(NoticeStrip), findsNothing);
    });

    testWidgets('one tick is not enough, both turn the button on',
        (tester) async {
      await pump(tester, const ParentSetupScreen());
      await tester.tap(tickRow(0));
      await tester.pump();
      expect(button(tester, 'Set Up Account').onPressed, isNull);
      await tester.tap(tickRow(1));
      await tester.pump();
      expect(button(tester, 'Set Up Account').onPressed, isNotNull);
      await tester.tap(tickRow(0));
      await tester.pump();
      expect(button(tester, 'Set Up Account').onPressed, isNull);
    });

    testWidgets('the links open the Terms and the Child Notice',
        (tester) async {
      var terms = 0;
      var notice = 0;
      await pump(
        tester,
        ParentSetupScreen(
          onOpenTerms: () => terms++,
          onOpenChildNotice: () => notice++,
        ),
      );
      await tester.tap(find.text('Terms'));
      await tester.tap(find.text('Child Notice'));
      expect(terms, 1);
      expect(notice, 1);
      // A link tap does not tick the box.
      expect(button(tester, 'Set Up Account').onPressed, isNull);
    });

    testWidgets('setup starts the child session, then goes on', (tester) async {
      var next = 0;
      final container = await pump(
        tester,
        ParentSetupScreen(onSetUp: () => next++),
      );
      await tester.tap(tickRow(0));
      await tester.tap(tickRow(1));
      await tester.pump();
      await tester.tap(find.text('Set Up Account'));
      await tester.pump();
      await tester.pump();
      expect(gateway.setups, 1);
      expect(starter.started, ['child-1']);
      expect(container.read(pendingChildIdProvider), 'child-1');
      expect(next, 1);
    });

    Future<void> setUpWith(
      WidgetTester tester,
      ChildSetupFailure failure,
    ) async {
      gateway.setupError = ChildSetupException(failure);
    }

    testWidgets('email already used: the 2AE notice, button off',
        (tester) async {
      await setUpWith(tester, ChildSetupFailure.emailHasAccount);
      await pump(tester, const ParentSetupScreen());
      await tester.tap(tickRow(0));
      await tester.tap(tickRow(1));
      await tester.pump();
      await tester.tap(find.text('Set Up Account'));
      await tester.pump();
      await tester.pump();
      expect(find.text(ChildSetupCopy.emailHasAccount), findsOneWidget);
      expect(find.text('Use Another Email'), findsOneWidget);
      // Both ticks stay on and the button stays off until the email changes.
      expect(button(tester, 'Set Up Account').onPressed, isNull);
      expect(starter.started, isEmpty);
    });

    testWidgets('Use Another Email signs out and returns to sign-in',
        (tester) async {
      await setUpWith(tester, ChildSetupFailure.emailHasAccount);
      var another = 0;
      await pump(
        tester,
        ParentSetupScreen(onUseAnotherEmail: () async => another++),
      );
      await tester.tap(tickRow(0));
      await tester.tap(tickRow(1));
      await tester.pump();
      await tester.tap(find.text('Set Up Account'));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Use Another Email'));
      await tester.pump();
      expect(another, 1);
    });

    testWidgets('closing the notice keeps the button off', (tester) async {
      await setUpWith(tester, ChildSetupFailure.emailHasAccount);
      await pump(tester, const ParentSetupScreen());
      await tester.tap(tickRow(0));
      await tester.tap(tickRow(1));
      await tester.pump();
      await tester.tap(find.text('Set Up Account'));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pump();
      expect(find.byType(NoticeStrip), findsNothing);
      expect(button(tester, 'Set Up Account').onPressed, isNull);
    });

    for (final (failure, message) in [
      (ChildSetupFailure.childLimit, ChildSetupCopy.childLimit),
      (ChildSetupFailure.staleConsentText, ChildSetupCopy.staleConsentText),
      (
        ChildSetupFailure.namedSignInRequired,
        ChildSetupCopy.namedSignInRequired,
      ),
      (ChildSetupFailure.rateLimited, ChildSetupCopy.rateLimited),
      (ChildSetupFailure.other, ChildSetupCopy.setupFailed),
    ]) {
      testWidgets('$failure shows its plain message and allows a retry',
          (tester) async {
        await setUpWith(tester, failure);
        await pump(tester, const ParentSetupScreen());
        await tester.tap(tickRow(0));
        await tester.tap(tickRow(1));
        await tester.pump();
        await tester.tap(find.text('Set Up Account'));
        await tester.pump();
        await tester.pump();
        expect(find.text(message), findsOneWidget);
        expect(find.text(ChildSetupCopy.emailHasAccount), findsNothing);
        expect(button(tester, 'Set Up Account').onPressed, isNotNull);
        expect(starter.started, isEmpty);
      });
    }

    testWidgets('named sign-in required offers Sign In', (tester) async {
      await setUpWith(tester, ChildSetupFailure.namedSignInRequired);
      await pump(tester, const ParentSetupScreen());
      await tester.tap(tickRow(0));
      await tester.tap(tickRow(1));
      await tester.pump();
      await tester.tap(find.text('Set Up Account'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets(
        'closed on the server: back to the under-13 screen, which '
        'drops its guardian button', (tester) async {
      await setUpWith(tester, ChildSetupFailure.childAccountsClosed);
      var back = 0;
      final container = await pump(
        tester,
        ParentSetupScreen(onBack: () => back++),
      );
      await tester.tap(tickRow(0));
      await tester.tap(tickRow(1));
      await tester.pump();
      await tester.tap(find.text('Set Up Account'));
      await tester.pump();
      await tester.pump();
      expect(container.read(childSetupClosedProvider), isTrue);
      expect(back, 1);
      expect(starter.started, isEmpty);
    });

    testWidgets('an unexpected error is the plain failure message',
        (tester) async {
      gateway.setupError = Exception('boom');
      await pump(tester, const ParentSetupScreen());
      await tester.tap(tickRow(0));
      await tester.tap(tickRow(1));
      await tester.pump();
      await tester.tap(find.text('Set Up Account'));
      await tester.pump();
      await tester.pump();
      expect(find.text(ChildSetupCopy.setupFailed), findsOneWidget);
    });
  });

  group('short child notice (board N2C)', () {
    testWidgets('shows the legal-draft text and no back', (tester) async {
      await pump(tester, const ChildNoticeScreen());
      expect(find.text(ChildSetupCopy.noticeTitle), findsOneWidget);
      expect(find.text(ChildSetupCopy.noticeKeep), findsOneWidget);
      expect(find.text(ChildSetupCopy.noticeConsent), findsOneWidget);
      expect(find.text(ChildSetupCopy.noticeMore), findsOneWidget);
      expect(find.text('Back'), findsNothing);
      final read = tester.getTopLeft(find.text('Read More for Kids')).dy;
      final ask = tester.getTopLeft(find.text('Ask My Parent or Guardian')).dy;
      expect(read, lessThan(ask));
    });

    testWidgets('the buttons call their actions', (tester) async {
      var ask = 0;
      var more = 0;
      await pump(
        tester,
        ChildNoticeScreen(onAskParent: () => ask++, onReadMore: () => more++),
      );
      await tester.tap(find.text('Ask My Parent or Guardian'));
      await tester.tap(find.text('Read More for Kids'));
      expect(ask, 1);
      expect(more, 1);
    });
  });

  group('nickname step (board S7N)', () {
    testWidgets('shows the label, the help line and a Continue that is off',
        (tester) async {
      await pump(
        tester,
        ChildNicknameScreen(onSubmit: (_) async {}, onDone: () {}),
      );
      expect(find.text(ChildSetupCopy.nicknameTitle), findsOneWidget);
      expect(find.text("Child's nickname"), findsOneWidget);
      expect(find.text(ChildSetupCopy.nicknameHelp), findsOneWidget);
      expect(find.text('Back'), findsNothing);
      expect(button(tester, 'Continue').onPressed, isNull);
    });

    testWidgets('a nickname turns Continue on and saves it', (tester) async {
      final saved = <String>[];
      var done = 0;
      await pump(
        tester,
        ChildNicknameScreen(
          onSubmit: (nickname) async => saved.add(nickname),
          onDone: () => done++,
        ),
      );
      await tester.enterText(find.byType(EditableText), '  Kiko ');
      await tester.pump();
      expect(button(tester, 'Continue').onPressed, isNotNull);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump();
      expect(saved, ['Kiko']);
      expect(done, 1);
    });

    testWidgets('a field of spaces keeps Continue off', (tester) async {
      await pump(
        tester,
        ChildNicknameScreen(onSubmit: (_) async {}, onDone: () {}),
      );
      await tester.enterText(find.byType(EditableText), '   ');
      await tester.pump();
      expect(button(tester, 'Continue').onPressed, isNull);
    });

    testWidgets('a failed save shows the error in the field and stays',
        (tester) async {
      var done = 0;
      await pump(
        tester,
        ChildNicknameScreen(
          onSubmit: (_) async => throw Exception('no'),
          onDone: () => done++,
        ),
      );
      await tester.enterText(find.byType(EditableText), 'Kiko');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump();
      expect(find.text(ChildSetupCopy.nicknameFailed), findsOneWidget);
      expect(find.text(ChildSetupCopy.nicknameHelp), findsNothing);
      expect(done, 0);
      expect(find.byType(PantasField), findsOneWidget);
    });
  });

  group('wide web draws every screen without error', () {
    final screens = <String, Widget Function()>{
      'sign-in': ParentSignInScreen.new,
      'setup': ParentSetupScreen.new,
      'notice': ChildNoticeScreen.new,
      'nickname': () =>
          ChildNicknameScreen(onSubmit: (_) async {}, onDone: () {}),
    };
    for (final entry in screens.entries) {
      testWidgets(entry.key, (tester) async {
        await pump(
          tester,
          entry.value(),
          size: const Size(1440, 900),
          web: true,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
