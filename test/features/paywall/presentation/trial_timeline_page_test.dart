import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/presentation/trial_timeline_page.dart';

void main() {
  testWidgets('prints the charge date, never a relative phrase',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: TrialTimelinePage(
          today: DateTime(2026, 8, 3),
          yearlyPrice: '₱799',
          onStart: () {},
        ),
      ),
    );
    expect(find.textContaining('10 August 2026'), findsOneWidget);
    expect(find.textContaining('in 7 days'), findsNothing);
  });

  testWidgets('names the dynamic price twice, in the lede and on day 7',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: TrialTimelinePage(
          today: DateTime(2026, 8, 3),
          yearlyPrice: '₱799',
          onStart: () {},
        ),
      ),
    );
    expect(find.textContaining('₱799'), findsNWidgets(2));
    expect(find.textContaining('₱999'), findsNothing);
  });

  testWidgets('has three marks and no icons in them', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: TrialTimelinePage(
          today: DateTime(2026, 8, 3),
          yearlyPrice: '₱799',
          onStart: () {},
        ),
      ),
    );
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Day 5'), findsOneWidget);
    expect(find.text('Day 7'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });
}
