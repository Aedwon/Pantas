import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('upgrade chip opens paywall when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProUpgradeChip(
            label: 'Pro shows the full breakdown - Try Pro free',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Pro shows the full breakdown - Try Pro free'));

    expect(tapped, isTrue);
  });
}
