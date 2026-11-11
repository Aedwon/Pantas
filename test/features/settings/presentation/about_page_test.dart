import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/build_info.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/client_report.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/application/minor_sharing.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/presentation/pages/about_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _NullSender implements ClientReportSender {
  @override
  Future<void> send(Map<String, Object?> payload) async {}
}

void main() {
  testWidgets('About uses the configured build number', (tester) async {
    await tester.pumpAppWithProviders(const AboutPage());
    await tester.pumpAndSettle();
    expect(find.text('Version 0.1.0 ($kBuildNumber)'), findsOneWidget);
  });

  testWidgets('About preserves explicit build number overrides',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(buildNumber: 'custom'));
    await tester.pumpAndSettle();
    expect(find.text('Version 0.1.0 (custom)'), findsOneWidget);
  });

  testWidgets('about carries legal, analytics, the DPO and feedback',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(
      find.text('Help improve Pantas by sharing usage data'),
      findsOneWidget,
    );
    expect(find.text('Contact our data protection officer'), findsOneWidget);
    expect(find.text('Send feedback'), findsOneWidget);
  });

  testWidgets('analytics is a switch, off until the student says yes',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.byType(PantasSwitch), findsNWidgets(2));
    expect(
      tester.widget<PantasSwitch>(find.byType(PantasSwitch).first).value,
      isFalse,
    );
  });

  testWidgets(
      'the speed and error row sits under usage sharing and toggles '
      'the setting and the reporter', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final reporter = ClientReporter(
      sender: _NullSender(),
      context: () => const ClientReportContext(
        build: 'b',
        visit: 'first',
        browser: 'chrome',
        mobile: false,
        viewportWidth: 1000,
      ),
    );
    ClientReporter.active = reporter;
    addTearDown(reporter.dispose);
    await tester.pumpAppWithProviders(
      const AboutPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Send speed and error reports'), findsOneWidget);
    expect(find.text('Helps us find slow screens and errors.'), findsOneWidget);
    final usageY = tester
        .getTopLeft(find.text('Help improve Pantas by sharing usage data'))
        .dy;
    final speedY =
        tester.getTopLeft(find.text('Send speed and error reports')).dy;
    expect(speedY, greaterThan(usageY));
    final switches = find.byType(PantasSwitch);
    expect(switches, findsNWidgets(2));
    expect(tester.widget<PantasSwitch>(switches.last).value, isTrue);

    await tester.tap(find.text('Send speed and error reports'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AboutPage)),
    );
    final off =
        await container.read(settingsRepositoryProvider).readUserSettings();
    expect(off.speedReportsEnabled, isFalse);
    expect(reporter.enabled, isFalse);
    expect(tester.widget<PantasSwitch>(switches.last).value, isFalse);

    await tester.tap(find.text('Send speed and error reports'));
    await tester.pumpAndSettle();
    expect(reporter.enabled, isTrue);
  });

  testWidgets(
      'a minor whose guardian has not allowed sharing sees the switch '
      'disabled with its caption', (tester) async {
    await tester.pumpAppWithProviders(
      const AboutPage(),
      overrides: [
        minorSharingProvider.overrideWith((ref) => MinorSharing.locked),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Your parent or guardian can turn this on.'),
      findsOneWidget,
    );
    final sharing =
        tester.widget<PantasSwitch>(find.byType(PantasSwitch).first);
    expect(sharing.onChanged, isNull);
    expect(sharing.value, isFalse);
  });

  testWidgets('an allowed minor and an adult see no caption and a live switch',
      (tester) async {
    for (final state in [MinorSharing.allowed, MinorSharing.notMinor]) {
      await tester.pumpAppWithProviders(
        const AboutPage(),
        overrides: [minorSharingProvider.overrideWith((ref) => state)],
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Your parent or guardian can turn this on.'),
        findsNothing,
      );
      expect(
        tester.widget<PantasSwitch>(find.byType(PantasSwitch).first).onChanged,
        isNotNull,
      );
    }
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
