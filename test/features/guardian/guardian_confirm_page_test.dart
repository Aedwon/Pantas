import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/guardian/presentation/guardian_confirm_page.dart';

import 'fake_guardian_gateway.dart';

class _Sink extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

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
              "app. Your child can't buy Pro. Only you can, from your own "
              'payment method.',
            ),
            findsOneWidget,
          );
          expect(find.text('Terms'), findsOneWidget);
          expect(find.text('Privacy Policy'), findsOneWidget);
          expect(find.text('Notice for teens'), findsOneWidget);
          expect(
            find.text(
              "I'm their parent or guardian, and I agree to these terms.",
            ),
            findsOneWidget,
          );
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
    expect(confirmButton(tester).onPressed, isNull);
    await tester.tap(
      find.text("I'm their parent or guardian, and I agree to these terms."),
    );
    await tester.pump();
    expect(confirmButton(tester).onPressed, isNotNull);
    await tester.tap(
      find.text("I'm their parent or guardian, and I agree to these terms."),
    );
    await tester.pump();
    expect(confirmButton(tester).onPressed, isNull);
  });

  testWidgets('confirming sends the token, the choice and the agreement',
      (tester) async {
    await pump(tester, token: 'tok');
    await tester.tap(
      find.text("I'm their parent or guardian, and I agree to these terms."),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(PantasButton, 'Confirm'));
    await tester.pumpAndSettle();
    expect(gateway.answers.single, (token: 'tok', confirm: true, agreed: true));
    expect(find.text('Thank you'), findsOneWidget);
    expect(
      find.text('The account is confirmed. You can close this page.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(PantasButton, 'Confirm'), findsNothing);
  });

  testWidgets("I Don't Agree declines without the box", (tester) async {
    gateway.answerTo = GuardianAnswer.declined;
    await pump(tester, token: 'tok');
    await tester.ensureVisible(find.text("I Don't Agree"));
    await tester.tap(find.text("I Don't Agree"));
    await tester.pumpAndSettle();
    expect(
      gateway.answers.single,
      (token: 'tok', confirm: false, agreed: false),
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
    await tester.tap(find.text('Terms'));
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
