import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/sign_in/sign_in_parts.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';
import 'package:pantas/features/child_setup/presentation/guardian_code_gate_page.dart';

import '../../helpers/child_setup_harness.dart';

const _request = GuardianGateRequest(
  action: GuardianAction.withdraw,
  childId: 'child-1',
  nickname: 'Kiko',
  actionPhrase: GuardianGateCopy.withdrawalPhrase,
);

void main() {
  late FakeChildSetupGateway gateway;
  late List<String> mailOpened;
  String? popped;
  var popCount = 0;

  setUp(() {
    gateway = FakeChildSetupGateway();
    mailOpened = [];
    popped = null;
    popCount = 0;
  });

  Future<void> pump(
    WidgetTester tester, {
    GuardianGateRequest request = _request,
    Size size = const Size(390, 844),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          childSetupGatewayProvider.overrideWithValue(gateway),
          dpoMailOpenerProvider.overrideWithValue((email) async {
            mailOpened.add(email);
          }),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    popped = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => GuardianCodeGatePage(request: request),
                      ),
                    );
                    popCount++;
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder codeField() => find.descendant(
        of: find.byType(CodeBoxes),
        matching: find.byType(EditableText),
      );

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(codeField(), text);
    await tester.pump();
  }

  /// Taps [link] inside the paragraph that starts with [start].
  Future<void> tapLink(WidgetTester tester, String start, String link) async {
    final paragraph = tester.renderObject<RenderParagraph>(
      find
          .byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText().startsWith(start),
          )
          .first,
    );
    final at = paragraph.text.toPlainText().indexOf(link);
    final box = paragraph
        .getBoxesForSelection(
          TextSelection(baseOffset: at, extentOffset: at + link.length),
        )
        .first
        .toRect();
    await tester.tapAt(paragraph.localToGlobal(box.center));
    await tester.pump();
  }

  bool confirmEnabled(WidgetTester tester) =>
      tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, 'Confirm'))
          .onPressed !=
      null;

  group('opening', () {
    testWidgets('requests the code for the action and child on open',
        (tester) async {
      await pump(tester);
      expect(gateway.codeRequests, [(GuardianAction.withdraw, 'child-1')]);
    });

    testWidgets('shows the board text with the nickname and masked email',
        (tester) async {
      await pump(tester);
      expect(find.text('Confirm withdrawal for Kiko'), findsOneWidget);
      expect(
        find.text(
          'We sent a 6-digit code to p***@example.test. Enter it to confirm '
          'withdrawal for Kiko.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('6-digit code'), findsOneWidget);
      // The resend button replaces the countdown once the cooldown is over.
      expect(
        find.text("Didn't get it? You can resend in 1:00."),
        findsOneWidget,
      );
      expect(
        find.text(
          "Can't reach that email? Write to dpo@pantas.study for another way "
          'to verify.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('the deletion action says deletion', (tester) async {
      await pump(
        tester,
        request: const GuardianGateRequest(
          action: GuardianAction.delete,
          childId: 'child-1',
          nickname: 'Kiko',
          actionPhrase: GuardianGateCopy.deletionPhrase,
        ),
      );
      expect(find.text('Confirm deletion for Kiko'), findsOneWidget);
      expect(gateway.codeRequests, [(GuardianAction.delete, 'child-1')]);
    });

    testWidgets('Confirm is off until six digits are in', (tester) async {
      await pump(tester);
      expect(confirmEnabled(tester), isFalse);
      await type(tester, '12345');
      expect(confirmEnabled(tester), isFalse);
    });

    testWidgets('Back leaves with no proof', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(popCount, 1);
      expect(popped, isNull);
    });
  });

  group('entering the code', () {
    testWidgets('six digits check themselves and the proof comes back',
        (tester) async {
      await pump(tester);
      await type(tester, '123456');
      await tester.pumpAndSettle();
      expect(
        gateway.codeChecks,
        [(GuardianAction.withdraw, 'child-1', '123456')],
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(popped, 'proof-1');
    });

    testWidgets('a pasted code keeps its digits only', (tester) async {
      await pump(tester);
      await type(tester, '12 34-56');
      await tester.pumpAndSettle();
      expect(gateway.codeChecks.single.$3, '123456');
    });

    testWidgets('Confirm also sends the check once the code is complete',
        (tester) async {
      gateway.verifyError =
          const GuardianGateException(GuardianGateFailure.other);
      await pump(tester);
      await type(tester, '123456');
      await tester.pump();
      expect(gateway.codeChecks, hasLength(1));
    });
  });

  group('a wrong code', () {
    testWidgets('shows the board message and clears the boxes after the beat',
        (tester) async {
      gateway.verifyError = const GuardianGateException(
        GuardianGateFailure.wrong,
        triesLeft: 4,
      );
      await pump(tester);
      await type(tester, '123456');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('That code is not right. Check it and try again.'),
        findsOneWidget,
      );
      expect(popped, isNull);
      // Confirm stays on with the wrong digits showing, as on board C8AW.
      expect(confirmEnabled(tester), isTrue);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 300));
      final field = tester.widget<EditableText>(codeField());
      expect(field.controller.text, isEmpty);
    });

    testWidgets('typing again starts over and the next code works',
        (tester) async {
      gateway.verifyError = const GuardianGateException(
        GuardianGateFailure.wrong,
        triesLeft: 4,
      );
      await pump(tester);
      await type(tester, '123456');
      await tester.pump();
      gateway.verifyError = null;
      // A key after a wrong code starts a fresh code and ends the beat.
      await type(tester, '1234567');
      expect(
        find.text('That code is not right. Check it and try again.'),
        findsNothing,
      );
      expect(tester.widget<EditableText>(codeField()).controller.text, '7');
      await type(tester, '765432');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(popped, 'proof-1');
    });

    testWidgets('too many wrong tries asks for a new code', (tester) async {
      gateway.verifyError =
          const GuardianGateException(GuardianGateFailure.tooManyTries);
      await pump(tester);
      await type(tester, '123456');
      await tester.pumpAndSettle();
      expect(
        find.text('Too many wrong tries. Send a new code.'),
        findsOneWidget,
      );
      expect(confirmEnabled(tester), isFalse);
    });

    testWidgets('an expired code asks for a new code', (tester) async {
      gateway.verifyError =
          const GuardianGateException(GuardianGateFailure.expired);
      await pump(tester);
      await type(tester, '123456');
      await tester.pumpAndSettle();
      expect(
        find.text('This code has expired. Send a new code.'),
        findsOneWidget,
      );
      expect(confirmEnabled(tester), isFalse);
    });

    testWidgets('a rate limit says to try later', (tester) async {
      gateway.verifyError =
          const GuardianGateException(GuardianGateFailure.rateLimited);
      await pump(tester);
      await type(tester, '123456');
      await tester.pumpAndSettle();
      expect(find.text('Too many tries. Try again later.'), findsOneWidget);
    });

    testWidgets('another failure says the check failed', (tester) async {
      gateway.verifyError =
          const GuardianGateException(GuardianGateFailure.other);
      await pump(tester);
      await type(tester, '123456');
      await tester.pumpAndSettle();
      expect(
        find.text("We couldn't check the code. Try again."),
        findsOneWidget,
      );
    });
  });

  group('a new code', () {
    testWidgets('inside the cooldown the sign-in countdown shows, no button',
        (tester) async {
      await pump(tester);
      expect(
        find.text("Didn't get it? You can resend in 1:00."),
        findsOneWidget,
      );
      expect(find.text('Send a New Code'), findsNothing);
      await tester.pump(const Duration(seconds: 5));
      expect(
        find.text("Didn't get it? You can resend in 0:55."),
        findsOneWidget,
      );
      expect(gateway.codeRequests, hasLength(1));
    });

    testWidgets('after the cooldown the button sends a new code and says so',
        (tester) async {
      await pump(tester);
      await type(tester, '123');
      await tester.pump(const Duration(seconds: 61));
      expect(find.textContaining("Didn't get it?"), findsNothing);
      await tester.tap(find.text('Send a New Code'));
      await tester.pumpAndSettle();
      expect(gateway.codeRequests, hasLength(2));
      expect(find.text('We sent a new code.'), findsOneWidget);
      // The digits typed for the old code are gone.
      final field = tester.widget<EditableText>(codeField());
      expect(field.controller.text, isEmpty);
      expect(confirmEnabled(tester), isFalse);
    });

    testWidgets(
        'a dead code shows the button, and asking early repeats the wait',
        (tester) async {
      gateway.verifyError =
          const GuardianGateException(GuardianGateFailure.expired);
      await pump(tester);
      await type(tester, '123456');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send a New Code'));
      await tester.pumpAndSettle();
      expect(gateway.codeRequests, hasLength(1));
      expect(find.text('You can request a code in 1:00.'), findsOneWidget);
    });

    testWidgets('a new code reopens a dead one', (tester) async {
      gateway.verifyError =
          const GuardianGateException(GuardianGateFailure.expired);
      await pump(tester);
      await type(tester, '123456');
      await tester.pumpAndSettle();
      gateway.verifyError = null;
      await tester.pump(const Duration(seconds: 61));
      await tester.tap(find.text('Send a New Code'));
      await tester.pumpAndSettle();
      expect(find.text('We sent a new code.'), findsOneWidget);
      await type(tester, '111111');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(popped, 'proof-1');
    });

    testWidgets('a mail that fails says so and can be tried again',
        (tester) async {
      gateway.requestError =
          const GuardianGateException(GuardianGateFailure.sendFailed);
      await pump(tester);
      expect(
        find.text("We couldn't send the code. Try again."),
        findsOneWidget,
      );
      gateway.requestError = null;
      await tester.tap(find.text('Send a New Code'));
      await tester.pumpAndSettle();
      expect(gateway.codeRequests, hasLength(2));
      expect(find.text('We sent a new code.'), findsOneWidget);
    });
  });

  group('the success beat', () {
    testWidgets('the page holds for the sign-in beat, then leaves',
        (tester) async {
      await pump(tester);
      await type(tester, '123456');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(popped, isNull);
      expect(popCount, 0);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(popped, 'proof-1');
      expect(popCount, 1);
    });
  });

  group('the daily limit', () {
    testWidgets('says to try tomorrow and names the data protection officer',
        (tester) async {
      gateway.requestError =
          const GuardianGateException(GuardianGateFailure.dailyLimit);
      await pump(tester);
      expect(
        find.text(
          "You have reached today's code limit. Try again tomorrow, or write "
          'to dpo@pantas.study for another way to verify.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(confirmEnabled(tester), isFalse);
      final send = tester.widget<PantasButton>(
        find.widgetWithText(PantasButton, 'Send a New Code'),
      );
      expect(send.onPressed, isNull);
    });

    testWidgets('the address in the message opens mail', (tester) async {
      gateway.requestError =
          const GuardianGateException(GuardianGateFailure.dailyLimit);
      await pump(tester);
      await tapLink(tester, "You have reached today's", 'dpo@pantas.study');
      expect(mailOpened, ['dpo@pantas.study']);
    });
  });

  group('the fine print', () {
    testWidgets('the address opens mail', (tester) async {
      await pump(tester);
      await tapLink(tester, "Can't reach that email?", 'dpo@pantas.study');
      expect(mailOpened, ['dpo@pantas.study']);
    });
  });
}
