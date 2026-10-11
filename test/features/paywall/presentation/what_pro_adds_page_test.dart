import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/presentation/what_pro_adds_page.dart';

void main() {
  Future<void> pump(WidgetTester tester, {VoidCallback? onSeePlans}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: WhatProAddsPage(onSeePlans: onSeePlans ?? () {}),
      ),
    );
  }

  testWidgets('the second line discloses the sample, above every figure',
      (tester) async {
    await pump(tester);
    expect(
      find.text(
        'This is an example. Pro measures every figure from your own answers.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('measured from your own answers'),
      findsNothing,
      reason: 'the old measurement claim must be gone',
    );
  });

  testWidgets('lists the four things Pro adds', (tester) async {
    await pump(tester);
    expect(find.text('Pro also adds'), findsOneWidget);
    expect(find.textContaining('to your wrong answers'), findsOneWidget);
    expect(find.textContaining('you keep missing'), findsOneWidget);
    expect(find.textContaining('down to the lesson'), findsOneWidget);
    expect(find.textContaining('mock exams'), findsOneWidget);
  });

  testWidgets('the CTA opens the plans screen', (tester) async {
    var tapped = 0;
    await pump(tester, onSeePlans: () => tapped++);
    await tester.ensureVisible(find.text('See plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('See plans'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('shows the fine print verbatim', (tester) async {
    await pump(tester);
    expect(find.text('From ₱29 a week. Cancel any time.'), findsOneWidget);
  });
}
