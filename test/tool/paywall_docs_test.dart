import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paywall live validation doc lists external blockers', () {
    final docs = File(
      'docs/superpowers/plans/2026-05-21-paywall-live-validation.md',
    ).readAsStringSync();

    for (final item in [
      'RevenueCat dashboard project',
      'Google Play IAP products',
      'RevenueCat product mappings',
      'Android RevenueCat API key',
      'Firebase Functions deployment credentials',
      'RevenueCat webhook shared secret',
      'Play Internal Testing',
      'Firebase live custom-claim validation',
      'Sanity Pro-content live validation',
      'Android manual QA',
      'production verification',
    ]) {
      expect(docs, contains(item));
    }
  });
}
