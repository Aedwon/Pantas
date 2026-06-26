import 'package:cse_cet_reviewer/app/telemetry_providers.dart';
import 'package:cse_cet_reviewer/core/storage/age_gate.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/telemetry/telemetry.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Onboarding emits onboardingStepReached for initial step',
      (tester) async {
    final sink = RecordingTelemetrySink();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryProvider.overrideWithValue(sink),
          passedAgeGateProvider.overrideWith((ref) async => false),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(sink.loggedEvents, [TelemetryEvent.onboardingStepReached]);
    expect(sink.loggedProperties, [
      {'step': 'welcome'},
    ]);
  });
}

class RecordingTelemetrySink implements Telemetry {
  final loggedEvents = <TelemetryEvent>[];
  final loggedProperties = <Map<String, Object>?>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    loggedEvents.add(event);
    loggedProperties.add(properties);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}
