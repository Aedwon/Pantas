import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('AppCard', () {
    testWidgets('plain variant renders child', (tester) async {
      await tester.pumpApp(
        const AppCard(child: Text('Hello')),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('accent variant has a top border', (tester) async {
      await tester.pumpApp(
        const AppCard(variant: AppCardVariant.accent, child: Text('Due')),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.border, isNotNull);
    });

    testWidgets('gradient variant renders a gradient decoration',
        (tester) async {
      await tester.pumpApp(
        AppCard(
          variant: AppCardVariant.gradient,
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
          ),
          child: const Text('Streak'),
        ),
      );
      expect(find.text('Streak'), findsOneWidget);
    });
  });
}
