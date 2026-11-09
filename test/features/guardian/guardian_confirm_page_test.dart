import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/guardian/domain/guardian_copy.dart';
import 'package:pantas/features/guardian/presentation/guardian_confirm_page.dart';

import 'fake_guardian_gateway.dart';

class _Sink extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

const _sharingLabel = 'Allow optional usage sharing';
const _sharingHelp =
    'Optional. Helps us improve Pantas. Your child can turn it '
    'off at any time.';

void main() {
  late FakeGuardianGateway gateway;
  late _Sink sink;
  final opened = <String>[];
  setUp(() {
    gateway = FakeGuardianGateway()
      ..link = GuardianLinkOpen(
        expiresAt: DateTime.utc(2026, 11, 8, 17),
      );
    sink = _Sink();
    opened.clear();
  });

  Future<void> pump(
    WidgetTester tester, {
    String? token = 'a1',
    Brightness brightness = Brightness.light,
    Size size = const Size(390, 844),
    bool web = false,
    double scale = 1,
  }) async {
    if (web) {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
    }
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          guardianGatewayProvider.overrideWithValue(gateway),
          telemetryProvider.overrideWithValue(sink),
        ],
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: MaterialApp(
            theme: brightness == Brightness.dark
                ? buildDarkTheme(web: web)
                : buildLightTheme(web: web),
            home: GuardianConfirmPage(token: token, onOpenDocument: opened.add),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  PantasButton confirmButton(WidgetTester tester) =>
      tester.widget<PantasButton>(find.widgetWithText(PantasButton, 'Confirm'));

  for (final brightness in Brightness.values) {
    for (final entry in {
      'phone': (const Size(390, 844), false),
      'wide web': (const Size(1440, 900), true),
    }.entries) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
            'the page says the approved copy: ${entry.key} '
            '$brightness $scale', (tester) async {
          await pump(
            tester,
            brightness: brightness,
            size: entry.value.$1,
            web: entry.value.$2,
            scale: scale,
          );
          expect(find.text("Confirm your child's account"), findsOneWidget);
          expect(
            find.text("You're confirming as their parent or guardian."),
            findsOneWidget,
          );
          expect(
            find.textContaining(
              "Pantas keeps your child's answers and study progress to run the "
              'app. Confirming here does not authorize a charge. If your '
              'child wants Pro, a parent or guardian makes the payment and '
              'ticks a box to accept the Terms.',
            ),
            findsOneWidget,
          );
          expect(find.text('Terms of Service'), findsOneWidget);
          expect(find.text('Privacy Policy'), findsOneWidget);
          expect(teenNoticeReady, isTrue);
          expect(find.text('Notice for teens'), findsOneWidget);
          expect(
            find.text(
              "I'm their parent or guardian, and I agree to these terms.",
            ),
            findsOneWidget,
          );
          expect(find.text(_sharingLabel), findsOneWidget);
          expect(find.text(_sharingHelp), findsOneWidget);
          expect(find.text('Confirm'), findsOneWidget);
          expect(find.text("I Don't Agree"), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('opening the page alone confirms nothing', (tester) async {
    await pump(tester);
    expect(gateway.answers, isEmpty);
  });

  testWidgets('Confirm waits for the agreement box', (tester) async {
    await pump(tester);
    final agreement =
        find.text("I'm their parent or guardian, and I agree to these terms.");
    expect(confirmButton(tester).onPressed, isNull);
    await tester.ensureVisible(agreement);
    expect(agreement.hitTestable(), findsOneWidget);
    await tester.tap(agreement);
    await tester.pump();
    expect(confirmButton(tester).onPressed, isNotNull);
    await tester.tap(agreement);
    await tester.pump();
    expect(confirmButton(tester).onPressed, isNull);
  });

  testWidgets('confirming sends the token, the choice and the agreement',
      (tester) async {
    await pump(tester, token: 'tok');
    final agreement =
        find.text("I'm their parent or guardian, and I agree to these terms.");
    await tester.ensureVisible(agreement);
    expect(agreement.hitTestable(), findsOneWidget);
    await tester.tap(agreement);
    await tester.pump();
    final confirm = find.widgetWithText(PantasButton, 'Confirm');
    await tester.ensureVisible(confirm);
    expect(confirm.hitTestable(), findsOneWidget);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(
      gateway.answers.single,
      (token: 'tok', confirm: true, agreed: true, allowSharing: false),
    );
    expect(find.text('Thank you'), findsOneWidget);
    expect(
      find.text(
        'The account is confirmed. To change sharing or withdraw later, use '
        'Manage Permission or the link in your email.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(PantasButton, 'Confirm'), findsNothing);
  });

  Future<void> confirmNow(WidgetTester tester) async {
    final agreement =
        find.text("I'm their parent or guardian, and I agree to these terms.");
    await tester.ensureVisible(agreement);
    await tester.tap(agreement);
    await tester.pump();
    final confirm = find.widgetWithText(PantasButton, 'Confirm');
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
  }

  for (final web in [false, true]) {
    testWidgets(
        'the Thank you page offers Manage Permission, which opens the manage '
        'page with the returned token, web $web', (tester) async {
      gateway.manageTokenTo = 'mt-123';
      await pump(
        tester,
        web: web,
        size: web ? const Size(1440, 900) : const Size(390, 844),
      );
      await confirmNow(tester);
      expect(find.text('Thank you'), findsOneWidget);
      final button = find.widgetWithText(PantasButton, 'Manage Permission');
      expect(button, findsOneWidget);
      expect(
        tester.widget<PantasButton>(button).variant,
        PantasButtonVariant.secondary,
      );
      await tester.tap(button);
      expect(opened, ['/guardian/manage?token=mt-123']);
    });
  }

  testWidgets('the Manage Permission button sits centered at natural width',
      (tester) async {
    await pump(tester);
    await confirmNow(tester);
    final box =
        tester.getRect(find.widgetWithText(PantasButton, 'Manage Permission'));
    expect(box.center.dx, closeTo(195, 1));
    expect(box.width, lessThan(390 - 40));
  });

  testWidgets('without a manage token there is no Manage Permission button',
      (tester) async {
    gateway.manageTokenTo = null;
    await pump(tester);
    await confirmNow(tester);
    expect(find.text('Thank you'), findsOneWidget);
    expect(find.text('Manage Permission'), findsNothing);
  });

  testWidgets('a declined answer offers no Manage Permission', (tester) async {
    gateway.answerTo = GuardianAnswer.declined;
    await pump(tester);
    await tester.ensureVisible(find.text("I Don't Agree"));
    await tester.tap(find.text("I Don't Agree"));
    await tester.pumpAndSettle();
    expect(find.text('Manage Permission'), findsNothing);
  });

  testWidgets(
      'the sharing box starts unticked and is independent of the '
      'agreement box', (tester) async {
    await pump(tester);
    final sharing = find.text(_sharingLabel);
    final agreement =
        find.text("I'm their parent or guardian, and I agree to these terms.");
    expect(
      tester
          .widget<CheckboxRow>(find.widgetWithText(CheckboxRow, _sharingLabel))
          .selected,
      isFalse,
    );
    await tester.ensureVisible(sharing);
    await tester.tap(sharing);
    await tester.pump();
    // Ticking sharing does not tick the agreement or enable Confirm.
    expect(confirmButton(tester).onPressed, isNull);
    expect(
      tester
          .widget<CheckboxRow>(find.widgetWithText(CheckboxRow, _sharingLabel))
          .selected,
      isTrue,
    );
    await tester.ensureVisible(agreement);
    await tester.tap(agreement);
    await tester.pump();
    expect(confirmButton(tester).onPressed, isNotNull);
    // Unticking the agreement leaves sharing ticked.
    await tester.tap(agreement);
    await tester.pump();
    expect(
      tester
          .widget<CheckboxRow>(find.widgetWithText(CheckboxRow, _sharingLabel))
          .selected,
      isTrue,
    );
  });

  testWidgets('confirming with the sharing box ticked sends allowSharing true',
      (tester) async {
    await pump(tester, token: 'tok');
    for (final label in [
      _sharingLabel,
      "I'm their parent or guardian, and I agree to these terms.",
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
    }
    final confirm = find.widgetWithText(PantasButton, 'Confirm');
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(
      gateway.answers.single,
      (token: 'tok', confirm: true, agreed: true, allowSharing: true),
    );
    expect(find.text('Thank you'), findsOneWidget);
  });

  testWidgets("I Don't Agree declines without the box", (tester) async {
    gateway.answerTo = GuardianAnswer.declined;
    await pump(tester, token: 'tok');
    await tester.ensureVisible(find.text("I Don't Agree"));
    await tester.tap(find.text("I Don't Agree"));
    await tester.pumpAndSettle();
    expect(
      gateway.answers.single,
      (token: 'tok', confirm: false, agreed: false, allowSharing: false),
    );
    expect(find.text('Response sent'), findsOneWidget);
    expect(
      find.text('The account was not confirmed. You can close this page.'),
      findsOneWidget,
    );
  });

  testWidgets('a link answered by someone else in the meantime says so',
      (tester) async {
    gateway.answerTo = GuardianAnswer.used;
    await pump(tester);
    await tester.ensureVisible(find.text("I Don't Agree"));
    await tester.tap(find.text("I Don't Agree"));
    await tester.pumpAndSettle();
    expect(find.text('This link no longer works'), findsOneWidget);
  });

  for (final reason in GuardianLinkClosedReason.values) {
    testWidgets('a closed link ($reason) shows no form', (tester) async {
      gateway.link = GuardianLinkClosed(reason);
      await pump(tester);
      expect(find.text('This link no longer works'), findsOneWidget);
      expect(
        find.text('It has expired or was already used.'),
        findsOneWidget,
      );
      expect(find.text('Confirm'), findsNothing);
      expect(find.text("I Don't Agree"), findsNothing);
    });
  }

  testWidgets('a missing token shows the closed link without calling out',
      (tester) async {
    await pump(tester, token: null);
    expect(find.text('This link no longer works'), findsOneWidget);
    expect(gateway.answers, isEmpty);
  });

  testWidgets('the document links open the legal pages', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Terms of Service'));
    await tester.tap(find.text('Privacy Policy'));
    await tester.tap(find.text('Notice for teens'));
    expect(opened, ['/legal/terms', '/legal/privacy', '/legal/teens']);
  });

  testWidgets('a failed answer keeps the form and offers a retry',
      (tester) async {
    await pump(tester, token: 'tok');
    gateway.failure = const GuardianGatewayException('unavailable');
    await tester.ensureVisible(find.text("I Don't Agree"));
    await tester.tap(find.text("I Don't Agree"));
    await tester.pumpAndSettle();
    expect(find.text("Confirm your child's account"), findsOneWidget);
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(sink.errors, hasLength(1));
  });

  testWidgets('a failed load shows a retry', (tester) async {
    gateway.failure = const GuardianGatewayException('unavailable');
    await pump(tester);
    expect(find.text('Try Again'), findsOneWidget);
    gateway.failure = null;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text("Confirm your child's account"), findsOneWidget);
  });
}
