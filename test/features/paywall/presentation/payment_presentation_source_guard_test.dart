import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Pro presentation uses gateway prices and the retired '
      'purchase flow is absent', () {
    final source =
        File('lib/features/settings/presentation/pages/pro_page.dart')
            .readAsStringSync();
    expect(source.contains('₱'), isFalse);
    for (final name in [
      'paywall_page',
      'what_pro_adds_page',
      'plans_page',
      'trial_timeline_page',
      'pro_specimen_panel',
      'paywall_package_card',
      'plan_row',
      'subscription_panel',
    ]) {
      expect(
        File('lib/features/paywall/presentation/$name.dart').existsSync(),
        isFalse,
        reason: name,
      );
    }
  });
  test('all live Pro destinations push Settings Pro', () {
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      expect(
        RegExp(r'''(?:push|go)(?:<[^>]*>)?\(['"]/paywall''')
            .hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });
}
