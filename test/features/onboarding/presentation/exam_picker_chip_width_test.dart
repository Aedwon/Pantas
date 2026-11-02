import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/onboarding_steps_harness.dart';

// ignore_for_file: cascade_invocations

/// Aedwon, Nov 2, 2026: the filter chips must not move when one is picked.
void main() {
  setUpAll(loadGeist);

  const labels = [
    'All',
    'College',
    'High school',
    'Scholarships',
    'Civil service',
    'Academies',
    'Licensure',
  ];

  testWidgets('wide: no chip moves or wraps when any chip is selected',
      (tester) async {
    await pumpFramedStep(tester, 'picker', wide: true);
    List<Rect> rects() => [
          for (final label in labels)
            tester.getRect(
              find.ancestor(
                of: find.text(label),
                matching: find.byType(TextButton),
              ),
            ),
        ];
    final first = rects();
    final rows = first.map((r) => r.top).toSet().length;
    for (final label in labels) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(rects(), first, reason: 'selecting $label moved a chip');
      expect(rects().map((r) => r.top).toSet().length, rows);
    }
  });

  testWidgets('each chip label is announced once', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpFramedStep(tester, 'picker', wide: true);
    for (final label in labels) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    semantics.dispose();
  });
}
