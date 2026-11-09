import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_guardian_step.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';
import '../../guardian/fake_guardian_gateway.dart';

class _ErrorSink extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

void main() {
  late AppDatabase db;
  late FakeGuardianGateway gateway;
  late _ErrorSink sink;
  setUp(() {
    db = inMemoryDatabase();
    gateway = FakeGuardianGateway();
    sink = _ErrorSink();
  });
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester, {
    VoidCallback? sent,
    Brightness brightness = Brightness.light,
    double scale = 1,
    Size size = const Size(390, 844),
  }) =>
      pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            settingsRepositoryProvider
                .overrideWithValue(DriftSettingsRepository(db)),
            guardianGatewayProvider.overrideWithValue(gateway),
            telemetryProvider.overrideWithValue(sink),
          ],
          child: OnboardingGuardianStep(onSent: sent ?? () {}),
        ),
        brightness: brightness,
        textScale: scale,
        viewportSize: size,
        disableAnimations: true,
      );

  // The label is drawn above each field at every width, so the placeholder
  // is an example: "Full name" and "name@example.com".
  Finder field(String label) => find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText ==
                (label.endsWith('name') ? 'Full name' : 'name@example.com'),
      );

  Future<void> fill(
    WidgetTester tester, {
    String email = 'maria@gmail.com',
  }) async {
    await tester.enterText(field("Parent or guardian's name"), 'Maria');
    await tester.enterText(field("Parent or guardian's email"), email);
    await tester.pump();
  }

  PantasButton sendButton(WidgetTester tester) => tester.widget<PantasButton>(
        find.widgetWithText(PantasButton, 'Send Link'),
      );

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'the screen says what the approved copy says $brightness $scale',
          (tester) async {
        await pump(tester, brightness: brightness, scale: scale);
        expect(
          find.text('A parent or guardian needs to agree first'),
          findsOneWidget,
        );
        expect(
          find.text(
            "You're under 18. We'll email them a link to review and confirm.",
          ),
          findsOneWidget,
        );
        expect(field("Parent or guardian's name"), findsOneWidget);
        expect(field("Parent or guardian's email"), findsOneWidget);
        expect(find.text('Send Link'), findsOneWidget);
        expect(find.text('Back'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('resting fields use the neutral outline, focus uses the accent',
      (tester) async {
    await pump(tester);
    final context = tester.element(find.byType(OnboardingGuardianStep));
    for (final label in [
      "Parent or guardian's name",
      "Parent or guardian's email",
    ]) {
      final decoration = tester.widget<TextField>(field(label)).decoration!;
      final resting = decoration.enabledBorder! as OutlineInputBorder;
      final focused = decoration.focusedBorder! as OutlineInputBorder;
      expect(
        resting.borderSide.color,
        context.colors.controlOutline,
        reason: label,
      );
      expect(focused.borderSide.color, context.colors.accent, reason: label);
    }
  });

  testWidgets('Send Link waits for a name and a plausible email',
      (tester) async {
    await pump(tester);
    expect(sendButton(tester).onPressed, isNull);
    await tester.enterText(field("Parent or guardian's name"), 'Maria');
    await tester.pump();
    expect(sendButton(tester).onPressed, isNull);
    await tester.enterText(field("Parent or guardian's email"), 'maria@');
    await tester.pump();
    expect(sendButton(tester).onPressed, isNull);
    await tester.enterText(
      field("Parent or guardian's email"),
      'maria@gmail.com',
    );
    await tester.pump();
    expect(sendButton(tester).onPressed, isNotNull);
  });

  testWidgets('sending asks the server once and moves on', (tester) async {
    var sent = 0;
    await pump(tester, sent: () => sent++);
    await fill(tester);
    await tester.tap(find.text('Send Link'));
    await tester.pumpAndSettle();
    expect(gateway.sent, hasLength(1));
    expect(gateway.sent.single.name, 'Maria');
    expect(gateway.sent.single.email, 'maria@gmail.com');
    expect(sent, 1);
    final contact = await AppPreferencesRepository(db).guardianContact();
    expect(contact?.email, 'maria@gmail.com');
  });

  testWidgets('a failed send keeps the typing and offers a retry',
      (tester) async {
    var sent = 0;
    gateway.failure = const GuardianGatewayException('unavailable');
    await pump(tester, sent: () => sent++);
    await fill(tester);
    await tester.tap(find.text('Send Link'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(sent, 0);
    expect(sink.errors, hasLength(1));
    expect(find.text('Maria'), findsOneWidget);
    gateway.failure = null;
    await tester.ensureVisible(find.text('Try Again'));
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(sent, 1);
  });

  testWidgets('too many sends says so, not "could not save" (5S-7)',
      (tester) async {
    gateway.failure = const GuardianRateLimitedException();
    await pump(tester);
    await fill(tester);
    await tester.tap(find.text('Send Link'));
    await tester.pumpAndSettle();
    expect(
      find.text('Too many tries. Wait a while, then try again.'),
      findsOneWidget,
    );
    expect(find.text('Could not save your progress.'), findsNothing);
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('Maria'), findsOneWidget);
  });

  testWidgets('the next send clears the too-many line', (tester) async {
    gateway.failure = const GuardianRateLimitedException();
    await pump(tester);
    await fill(tester);
    await tester.tap(find.text('Send Link'));
    await tester.pumpAndSettle();
    gateway.failure = const GuardianGatewayException('unavailable');
    await tester.ensureVisible(find.text('Try Again'));
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(
      find.text('Too many tries. Wait a while, then try again.'),
      findsNothing,
    );
  });

  testWidgets('wide: the first field takes the keys at once (5S-8)',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    await pump(tester, size: const Size(1440, 900));
    await tester.pumpAndSettle();
    final name = tester.widget<TextField>(
      find
          .byWidgetPredicate((w) => w is TextField && w.focusNode != null)
          .first,
    );
    expect(name.focusNode!.hasPrimaryFocus, isTrue);
    await tester.enterText(find.byType(TextField).first, 'Maria');
    expect(find.text('Maria'), findsOneWidget);
  });

  testWidgets('the contact kept on this device is filled in again',
      (tester) async {
    await AppPreferencesRepository(db).setGuardianContact(
      name: 'Maria',
      email: 'maria@gmail.com',
    );
    await pump(tester);
    await tester.pumpAndSettle();
    expect(find.text('Maria'), findsOneWidget);
    expect(find.text('maria@gmail.com'), findsOneWidget);
  });

  testWidgets('wide: a placeholder never repeats the label drawn above it',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    await pump(tester, size: const Size(1440, 900));
    expect(find.text("Parent or guardian's name"), findsOneWidget);
    final hints = [
      for (final field in tester.widgetList<TextField>(find.byType(TextField)))
        field.decoration?.hintText,
    ];
    expect(hints, ['Full name', 'name@example.com']);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets(
        'phone: each field has its label above it and an example inside $scale',
        (tester) async {
      await pump(tester, scale: scale);
      // Field README: the label is above on every width, and the placeholder
      // is never the only hint.
      for (final label in [
        "Parent or guardian's name",
        "Parent or guardian's email",
      ]) {
        expect(
          find.descendant(
            of: find.byType(PantasFieldLabel),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
      }
      expect(field("Parent or guardian's name"), findsOneWidget);
      expect(field("Parent or guardian's email"), findsOneWidget);
    });
  }
}
