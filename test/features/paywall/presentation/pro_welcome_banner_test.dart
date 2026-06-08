import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'welcome banner renders once for free to pro transition',
    (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: ProWelcomeBanner(
              onDismiss: () => dismissed = true,
              onPlanTap: () {},
            ),
          ),
        ),
      );

      expect(find.text("You're in."), findsOneWidget);
      await tester.tap(find.text("Take me to today's plan"));
      await tester.pump();

      expect(dismissed, isFalse);
    },
  );
}
