import 'package:cse_cet_reviewer/core/ui/components/inline_offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('InlineOfflineBanner', () {
    testWidgets('shows offline message', (tester) async {
      await tester.pumpApp(
        InlineOfflineBanner(onDismiss: () {}),
      );
      expect(find.textContaining('Offline'), findsOneWidget);
    });

    testWidgets('shows dismiss button', (tester) async {
      await tester.pumpApp(
        InlineOfflineBanner(onDismiss: () {}),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('fires onDismiss when close tapped', (tester) async {
      var dismissed = false;
      await tester.pumpApp(
        InlineOfflineBanner(onDismiss: () => dismissed = true),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });
  });
}
