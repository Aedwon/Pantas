import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_telemetry.dart';

void main() {
  for (final consent in [true, false]) {
    testWidgets(
        'viewing the Pro page logs pro_view once only with consent, '
        'consent=$consent', (tester) async {
      final sink = RecordingTelemetry();
      await tester.pumpAppWithProviders(
        const ProPage(),
        overrides: [
          telemetrySinkProvider.overrideWithValue(sink),
          effectiveTelemetryConsentProvider.overrideWithValue(consent),
          proForActiveExamProvider.overrideWith((ref) async => false),
        ],
      );
      await tester.pumpAndSettle();

      expect(sink.events, consent ? [TelemetryEvent.proView] : isEmpty);
      if (consent) expect(sink.logged.single.$2, isNull);
    });
  }
}
