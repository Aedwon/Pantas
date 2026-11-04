import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/guardian/presentation/guardian_waiting_page.dart';

import '../../helpers/in_memory_database.dart';
import 'fake_guardian_gateway.dart';

class _Sink extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

void main() {
  late AppDatabase db;
  late FakeGuardianGateway gateway;
  late _Sink sink;
  var changed = 0;
  var cleared = 0;
  setUp(() {
    db = inMemoryDatabase();
    gateway = FakeGuardianGateway()
      ..current = GuardianStatus(
        status: GuardianConsentStatus.pending,
        maskedEmail: 'm***@g***.com',
        expiresAt: DateTime.utc(2026, 11, 8, 17),
      );
    sink = _Sink();
    changed = 0;
    cleared = 0;
  });
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester, {
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
          appDatabaseProvider.overrideWithValue(db),
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
            home: GuardianWaitingPage(
              onChangeEmail: () => changed++,
              onCleared: () => cleared++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const body = 'We emailed m***@g***.com. The link expires on Nov 9, 2026. '
      'Pantas opens here once they confirm.';

  for (final brightness in Brightness.values) {
    for (final entry in {
      'phone': (const Size(390, 844), false),
      'wide web': (const Size(1440, 900), true),
    }.entries) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
            'waiting shows the approved copy: ${entry.key} $brightness $scale',
            (tester) async {
          await pump(
            tester,
            brightness: brightness,
            size: entry.value.$1,
            web: entry.value.$2,
            scale: scale,
          );
          expect(
            find.text('Waiting for your parent or guardian'),
            findsOneWidget,
          );
          expect(find.text(body), findsOneWidget);
          expect(find.text('Check Again'), findsOneWidget);
          expect(find.text('Resend Email'), findsOneWidget);
          expect(find.text('Change Email'), findsOneWidget);
          expect(find.text('Back'), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('Check Again is the tint button and the others are text buttons',
      (tester) async {
    await pump(tester);
    PantasButtonVariant variantOf(String label) => tester
        .widget<PantasButton>(find.widgetWithText(PantasButton, label))
        .variant;
    expect(variantOf('Check Again'), PantasButtonVariant.secondary);
    expect(variantOf('Resend Email'), PantasButtonVariant.tertiary);
    expect(variantOf('Change Email'), PantasButtonVariant.tertiary);
  });

  testWidgets('on wide web the actions sit centered under the text',
      (tester) async {
    await pump(tester, size: const Size(1440, 900), web: true);
    final middle =
        tester.getCenter(find.text('Waiting for your parent or guardian')).dx;
    for (final label in ['Check Again', 'Resend Email', 'Change Email']) {
      expect(
        tester.getCenter(find.text(label)).dx,
        closeTo(middle, 1),
        reason: label,
      );
    }
  });

  testWidgets('the logo sits where the onboarding steps put it, x 30',
      (tester) async {
    await pump(tester, size: const Size(1440, 900), web: true);
    expect(tester.getRect(find.byType(PantasLogo)).left, 30);
  });

  for (final entry in {
    'phone': (const Size(390, 844), false),
    'wide web': (const Size(1440, 900), true),
  }.entries) {
    testWidgets(
        'the title never leaves one word alone on its last line: '
        '${entry.key}', (tester) async {
      await pump(tester, size: entry.value.$1, web: entry.value.$2);
      const title = 'Waiting for your parent or guardian';
      // Lay the title out again at the width it was given.
      final painter = TextPainter(
        text: TextSpan(
          text: title,
          style: tester.widget<Text>(find.text(title)).style,
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: tester.getSize(find.text(title)).width);
      final last = painter.getLineBoundary(
        const TextPosition(offset: title.length - 1),
      );
      expect(painter.computeLineMetrics().length, greaterThan(1));
      expect(
        title.substring(last.start, last.end).trim().contains(' '),
        isTrue,
        reason: 'last line "${title.substring(last.start, last.end)}"',
      );
    });
  }

  testWidgets('a feedback line moves nothing else on the page', (tester) async {
    await pump(tester, size: const Size(1440, 900), web: true);
    Offset at(String text) => tester.getTopLeft(find.text(text));
    final before = {
      for (final text in [
        'Waiting for your parent or guardian',
        'Check Again',
        'Resend Email',
        'Change Email',
      ])
        text: at(text),
    };
    await tester.tap(find.text('Check Again'));
    await tester.pumpAndSettle();
    expect(find.text('Not confirmed yet.'), findsOneWidget);
    for (final entry in before.entries) {
      expect(at(entry.key), entry.value, reason: entry.key);
    }
  });

  testWidgets('declined and expired keep the same screen', (tester) async {
    gateway.current = const GuardianStatus(
      status: GuardianConsentStatus.declined,
      maskedEmail: 'm***@g***.com',
    );
    await pump(tester);
    expect(find.text('Waiting for your parent or guardian'), findsOneWidget);
    expect(find.text('Change Email'), findsOneWidget);
  });

  testWidgets('Check Again moves on once a guardian confirmed', (tester) async {
    await pump(tester);
    expect(cleared, 0);
    gateway.current = const GuardianStatus(
      status: GuardianConsentStatus.confirmed,
    );
    await tester.tap(find.text('Check Again'));
    await tester.pumpAndSettle();
    expect(cleared, 1);
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isTrue);
  });

  testWidgets('Check Again while still pending stays and reads the server',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Check Again'));
    await tester.pumpAndSettle();
    expect(cleared, 0);
    expect(find.text(body), findsOneWidget);
    expect(find.text('Not confirmed yet.'), findsOneWidget);
    // The line sits under the buttons.
    expect(
      tester.getTopLeft(find.text('Not confirmed yet.')).dy,
      greaterThan(tester.getBottomLeft(find.text('Change Email')).dy),
    );
  });

  testWidgets('no feedback line shows before anything is pressed',
      (tester) async {
    await pump(tester);
    expect(find.text('Not confirmed yet.'), findsNothing);
    expect(find.text('Email sent.'), findsNothing);
  });

  testWidgets('a feedback line clears when the next action starts',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Check Again'));
    await tester.pumpAndSettle();
    expect(find.text('Not confirmed yet.'), findsOneWidget);
    gateway.failure = const GuardianGatewayException('unavailable');
    await tester.tap(find.text('Check Again'));
    await tester.pumpAndSettle();
    expect(find.text('Not confirmed yet.'), findsNothing);
  });

  testWidgets('Resend Email sends to the contact kept on this device',
      (tester) async {
    await AppPreferencesRepository(db).setGuardianContact(
      name: 'Maria',
      email: 'maria@gmail.com',
    );
    await pump(tester);
    await tester.tap(find.text('Resend Email'));
    await tester.pumpAndSettle();
    expect(gateway.sent.single.email, 'maria@gmail.com');
    expect(changed, 0);
    expect(find.text('Email sent.'), findsOneWidget);
    expect(find.text('Not confirmed yet.'), findsNothing);
  });

  testWidgets('Resend Email with no saved contact opens Change Email',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Resend Email'));
    await tester.pumpAndSettle();
    expect(gateway.sent, isEmpty);
    expect(changed, 1);
  });

  testWidgets('Change Email opens the contact form', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Change Email'));
    await tester.pumpAndSettle();
    expect(changed, 1);
  });

  testWidgets('a failed load shows a retry and reports the error',
      (tester) async {
    gateway.failure = const GuardianGatewayException('unavailable');
    await pump(tester);
    expect(find.text('Try Again'), findsOneWidget);
    expect(sink.errors, hasLength(1));
    gateway.failure = null;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Waiting for your parent or guardian'), findsOneWidget);
  });

  testWidgets('a failed resend keeps the screen and reports it',
      (tester) async {
    await AppPreferencesRepository(db).setGuardianContact(
      name: 'Maria',
      email: 'maria@gmail.com',
    );
    await pump(tester);
    gateway.failure = const GuardianRateLimitedException();
    await tester.tap(find.text('Resend Email'));
    await tester.pumpAndSettle();
    expect(find.text('Waiting for your parent or guardian'), findsOneWidget);
    expect(find.text('Could not send the email. Try again.'), findsOneWidget);
    expect(find.text('Email sent.'), findsNothing);
    expect(sink.errors, hasLength(1));
  });

  testWidgets('a failed Check Again keeps the generic retry', (tester) async {
    await pump(tester);
    gateway.failure = const GuardianGatewayException('unavailable');
    await tester.tap(find.text('Check Again'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.text('Not confirmed yet.'), findsNothing);
  });
}
