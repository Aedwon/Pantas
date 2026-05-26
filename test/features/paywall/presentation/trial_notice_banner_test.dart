import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('trial notice banner appears from day five with charge date copy',
      (tester) async {
    final notice = TrialNotice(
      daysRemaining: 2,
      chargeDate: DateTime.utc(2026, 5, 28),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TrialNoticeBanner(notice: notice)),
      ),
    );

    expect(find.text('Pro trial ends in 2 days'), findsOneWidget);
    expect(find.textContaining('May 28'), findsOneWidget);
  });
}
