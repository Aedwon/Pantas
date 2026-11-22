import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/analytics_never_blocks.dart';

void main() {
  test('an awaited analytics event fails, in every shape it was written', () {
    for (final bad in [
      // The Nov 22 2026 prod shape, from SubmitAnswer.
      'await _telemetry?.log(\n  TelemetryEvent.questionAnswered,\n);',
      'await telemetry.log(TelemetryEvent.mockStarted);',
      'await ref.read(telemetryProvider).log(\n  TelemetryEvent.tabOpened);',
      'await _ref.read(telemetryProvider).log(event, properties: p);',
    ]) {
      expect(
        findBlockingAnalytics('lib/features/a.dart', bad),
        hasLength(1),
        reason: bad,
      );
    }
  });

  test('the throwing property check in app code fails', () {
    expect(
      findBlockingAnalytics(
        'lib/features/a.dart',
        'assertPropertiesAllowed(properties);',
      ),
      hasLength(1),
    );
  });

  test('unawaited events, other awaits and the seam itself pass', () {
    expect(
      findBlockingAnalytics('lib/features/a.dart', '''
unawaited(_telemetry.log(TelemetryEvent.purchaseCompleted));
ref.read(telemetryProvider).log(TelemetryEvent.tabOpened);
await _reviewRepo.upsert(next);
await telemetry.recordError(error, stack);
await logger.log('saved');
// await _telemetry?.log(TelemetryEvent.questionAnswered) is what must not come back.
'''),
      isEmpty,
    );
    expect(
      findBlockingAnalytics(
        'lib/core/telemetry/gated_telemetry.dart',
        'await _inner.log(event, properties: allowed);',
      ),
      isEmpty,
    );
  });
}
