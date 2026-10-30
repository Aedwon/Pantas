import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/public_id_provider.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/steps_screen.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/settings/presentation/pages/about_page.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/presentation/pages/session_building_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget page, {
  required bool dark,
  DateTime? examDay,
  AuthUser? user,
  PublicIdState publicId = const PublicIdState.notReady(),
  double scale = 1,
}) async {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final repository = DriftSettingsRepository(db);
  await tester.pumpAppWithProviders(
    Theme(
      data: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
      child: MediaQuery(
        data: MediaQueryData(
          size: const Size(1440, 1000),
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: page,
      ),
    ),
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      currentUserProvider.overrideWith((ref) async => user),
      publicIdProvider.overrideWith((ref) => Stream.value(publicId)),
      userSettingsProvider.overrideWith((ref) async {
        final settings = await repository.readUserSettings();
        return UserSettings(
          name: settings.name,
          dailyReminderTime: settings.dailyReminderTime,
          studyDays: settings.studyDays,
          examDate: examDay == null ? null : ExamDate.onDay(examDay),
          strictMockMode: settings.strictMockMode,
          helpImproveApp: settings.helpImproveApp,
          carryOverProgress: settings.carryOverProgress,
          sessionOrdering: settings.sessionOrdering,
          retainTableOrder: settings.retainTableOrder,
          updatedAt: settings.updatedAt,
        );
      }),
    ],
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);
  for (final dark in [false, true]) {
    for (final signedIn in [false, true]) {
      testWidgets('Account identity signedIn=$signedIn dark=$dark',
          (tester) async {
        await _pump(
          tester,
          const AccountPage(),
          dark: dark,
          user: signedIn
              ? const AuthUser(
                  uid: 'student',
                  email: 'student@example.com',
                  displayName: 'Student',
                )
              : null,
        );
        expect(
          find.byKey(const ValueKey('settings-navigation')),
          findsOneWidget,
        );
        expect(find.text('Your name, sign-in and backup.'), findsOneWidget);
        expect(find.text('Pantas ID'), findsOneWidget);
        expect(
          find.text(signedIn ? 'Not ready yet' : 'Sign in to get one'),
          findsOneWidget,
        );
        expect(
          find.text(signedIn ? 'Google' : 'Continue with Google'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('Account ID copied state ends after two seconds dark=$dark',
        (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await _pump(
        tester,
        const AccountPage(),
        dark: dark,
        user: const AuthUser(
          uid: 'student',
          email: 'student@example.com',
          displayName: 'Student',
        ),
        publicId: const PublicIdState.ready('482139075'),
      );
      expect(find.text('Click to copy'), findsOneWidget);
      await tester.tap(find.text('Pantas ID'));
      await tester.pump();
      expect(copied, '482139075');
      expect(find.text('Copied'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Copied'), findsNothing);
      expect(find.text('482 139 075'), findsOneWidget);
    });
    testWidgets('date editor has exact, month and unknown states dark=$dark',
        (tester) async {
      await _pump(
        tester,
        const ExamPage(),
        dark: dark,
        examDay: DateTime(DateTime.now().year + 1, 11, 11),
      );
      await tester.tap(find.text('Exam date'));
      await tester.pumpAndSettle();
      expect(find.byType(ValueWheel), findsNWidgets(3));
      await tester.tap(find.text('Month only'));
      await tester.pumpAndSettle();
      expect(find.byType(ValueWheel), findsNWidgets(2));
      await tester.tap(find.text('I don’t know'));
      await tester.pumpAndSettle();
      expect(find.byType(ValueWheel), findsNothing);
      expect(
        find.text('Your plan keeps a steady pace until you add a date.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
    for (final scale in [1.0, 2.0]) {
      testWidgets('past exam keeps warning color dark=$dark scale=$scale',
          (tester) async {
        await _pump(
          tester,
          const ExamPage(),
          dark: dark,
          scale: scale,
          examDay: DateTime(2025),
        );
        final date = find.text('Jan 1, 2025');
        expect(date, findsOneWidget);
        expect(
          tester.widget<Text>(date).style?.color,
          dark ? const Color(0xFFE0706B) : const Color(0xFFD70015),
        );
        expect(find.textContaining('This date has passed.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('About uses version card and hides sharing dark=$dark',
        (tester) async {
      await _pump(
        tester,
        const AboutPage(
          version: '2.0.0',
          buildNumber: '99',
        ),
        dark: dark,
      );
      final card = find.ancestor(
        of: find.text('Version 2.0.0 (99)'),
        matching: find.byType(WebCard),
      );
      expect(card, findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.text('P')),
        findsOneWidget,
      );
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Terms of service'), findsOneWidget);
      expect(find.text('Help improve the app'), findsOneWidget);
      expect(find.text('Facebook group ↗'), findsOneWidget);
      expect(find.text('Shared links'), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Practice uses newest strict mode copy dark=$dark',
        (tester) async {
      await _pump(tester, const SessionBuildingPage(), dark: dark);
      expect(
        find.text('For mock exams: no pausing and no ending a section early. '
            'Leaving the mock instantly ends and submits your answers, '
            'finished or not finished.'),
        findsOneWidget,
      );
      expect(find.text('One topic only'), findsOneWidget);
      expect(find.text('Interleaved tail'), findsOneWidget);
      expect(find.text('Fully mixed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('delete shows real pending operation then Close dark=$dark',
        (tester) async {
      final done = Completer<void>();
      await _pump(
        tester,
        DeleteAccountPage(
          isAnonymous: false,
          entitlement: const SettingsEntitlementSnapshot.free(),
          dpoEmail: defaultLegalContact.dpoEmail,
          onDelete: () => done.future,
        ),
        dark: dark,
      );
      expect(find.text('Delete your account?'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Delete My Data'),
        ),
      );
      await tester.pump();
      expect(find.byType(StepsScreen), findsOneWidget);
      expect(find.text('Deleting your account'), findsOneWidget);
      expect(find.text('Close'), findsNothing);
      done.complete();
      await tester.pumpAndSettle();
      expect(
        find.text('Your account is deleted. Nothing of yours is left.'),
        findsOneWidget,
      );
      expect(find.text('Close'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide setting values use board typography dark=$dark',
        (tester) async {
      await _pump(
        tester,
        const SettingsRow(title: 'Exam', value: 'CSE Professional'),
        dark: dark,
      );
      expect(
        tester.widget<Text>(find.text('CSE Professional')).style?.fontSize,
        16,
      );
    });
  }
}
