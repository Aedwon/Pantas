import 'package:pantas/core/ui/components/settings_switch.dart';
import 'package:pantas/features/settings/presentation/pages/about_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('about carries legal, analytics, the DPO and feedback',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Terms of service'), findsOneWidget);
    expect(find.text('Help improve the app'), findsOneWidget);
    expect(find.text('Contact our DPO'), findsOneWidget);
    expect(find.text('Send feedback'), findsOneWidget);
  });

  testWidgets('the analytics lede says crash reports are always sent',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Shares anonymous usage data. Crash reports are always sent.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('analytics is a switch, off until the student says yes',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsSwitch), findsOneWidget);
    expect(
      tester.widget<SettingsSwitch>(find.byType(SettingsSwitch)).value,
      isFalse,
    );
  });

  testWidgets(
      'without the build flag there is no debug row and no debug '
      'heading', (tester) async {
    await tester.pumpAppWithProviders(
      const AboutPage(),
      overrides: [],
    );
    await tester.pumpAndSettle();

    expect(find.text('Debug'), findsNothing);
  });

  testWidgets(
      'with the build flag the debug row is plainly visible, with no '
      'gesture needed', (tester) async {
    await tester.pumpAppWithProviders(
      const AboutPage(debugEnabled: true),
      overrides: [],
    );
    await tester.pumpAndSettle();

    expect(find.text('Debug'), findsOneWidget);
  });

  testWidgets('nothing on the page mentions a lifetime purchase',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.data?.toLowerCase().contains('lifetime') ?? false, isFalse);
    }
  });
}
