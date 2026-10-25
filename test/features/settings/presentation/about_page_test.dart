import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/build_info.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/settings/presentation/pages/about_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('About uses the configured build number', (tester) async {
    await tester.pumpAppWithProviders(const AboutPage());
    await tester.pumpAndSettle();
    expect(find.text('Version 0.1.0 (build $kBuildNumber)'), findsOneWidget);
  });

  testWidgets('About preserves explicit build number overrides',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(buildNumber: 'custom'));
    await tester.pumpAndSettle();
    expect(find.text('Version 0.1.0 (build custom)'), findsOneWidget);
  });

  testWidgets('about carries legal, analytics, the DPO and feedback',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Terms of service'), findsOneWidget);
    expect(find.text('Help improve the app'), findsOneWidget);
    expect(find.text('Contact our data protection officer'), findsOneWidget);
    expect(find.text('Send feedback'), findsOneWidget);
  });

  testWidgets('the analytics lede describes usage data and crash reports',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Help improve the app shares anonymous usage data. Crash '
        'reports are always sent. Contacting the officer opens your '
        'mail app.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('analytics is a switch, off until the student says yes',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.byType(PantasSwitch), findsOneWidget);
    expect(
      tester.widget<PantasSwitch>(find.byType(PantasSwitch)).value,
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

  testWidgets('the feedback row names where it goes and opens the group',
      (tester) async {
    final opened = <Uri>[];
    final modes = <LaunchMode>[];

    await tester.pumpAppWithProviders(
      AboutPage(
        opener: (url, {mode = LaunchMode.platformDefault}) async {
          opened.add(url);
          modes.add(mode);
          return true;
        },
      ),
      overrides: [],
    );
    await tester.pumpAndSettle();

    expect(find.text('Facebook group'), findsOneWidget);

    await tester.ensureVisible(find.text('Send feedback'));
    await tester.tap(find.text('Send feedback'));
    await tester.pumpAndSettle();

    expect(opened.single, Uri.parse(defaultLegalContact.communityGroupUrl));
    expect(modes.single, LaunchMode.externalApplication);
  });

  testWidgets('the DPO row opens mail to the DPO address', (tester) async {
    final opened = <Uri>[];

    await tester.pumpAppWithProviders(
      AboutPage(
        opener: (url, {mode = LaunchMode.platformDefault}) async {
          opened.add(url);
          return true;
        },
      ),
      overrides: [],
    );
    await tester.pumpAndSettle();

    expect(find.byType(SelectableText), findsOneWidget);

    await tester.tap(find.text('Contact our data protection officer'));
    await tester.pumpAndSettle();

    expect(opened.single.scheme, 'mailto');
    expect(opened.single.path, defaultLegalContact.dpoEmail);
  });

  testWidgets('the page names the app Pantas and not the old product',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.text('Pantas'), findsOneWidget);
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.data?.contains('CSE Reviewer') ?? false, isFalse);
    }
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
