import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const productionPaths = [
    'lib/features/paywall/presentation/paywall_page.dart',
    'lib/features/paywall/presentation/plans_page.dart',
    'lib/features/paywall/presentation/plan_row.dart',
    'lib/features/paywall/presentation/trial_timeline_page.dart',
    'lib/features/paywall/presentation/trial_notice_banner.dart',
    'lib/features/paywall/presentation/subscription_panel.dart',
    'lib/features/paywall/presentation/paywall_package_card.dart',
    'lib/features/settings/presentation/pages/pro_page.dart',
  ];

  test('payment presentation contains no stale commercial copy', () {
    for (final path in productionPaths) {
      final source = File(path).readAsStringSync();
      expect(source.contains('₱499'), isFalse, reason: path);
      expect(source.contains('₱42'), isFalse, reason: path);
    }
  });

  test('payment network failure cannot use the shared ErrorBanner', () {
    final source = File(
      'lib/features/paywall/presentation/paywall_page.dart',
    ).readAsStringSync();

    expect(source.contains('ErrorBanner'), isFalse);
  });
}
