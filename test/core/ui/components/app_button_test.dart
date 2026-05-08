import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpApp(
        AppButton(label: 'Start Review', onPressed: () {}),
      );
      expect(find.text('Start Review'), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        AppButton(label: 'Go', onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('disabled variant does not fire onPressed', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        AppButton(
          label: 'Go',
          onPressed: () => tapped = true,
          variant: AppButtonVariant.disabled,
        ),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isFalse);
    });

    testWidgets('loading variant shows CircularProgressIndicator',
        (tester) async {
      await tester.pumpApp(
        AppButton(
          label: 'Go',
          onPressed: () {},
          variant: AppButtonVariant.loading,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Go'), findsNothing);
    });

    testWidgets('renders leading icon when provided', (tester) async {
      await tester.pumpApp(
        AppButton(
          label: 'Start',
          onPressed: () {},
          leadingIcon: const Icon(Icons.play_arrow, key: Key('icon')),
        ),
      );
      expect(find.byKey(const Key('icon')), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('has minimum 48dp height', (tester) async {
      await tester.pumpApp(
        AppButton(label: 'X', onPressed: () {}),
      );
      final size = tester.getSize(find.byType(AppButton));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
