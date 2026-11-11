import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/settings.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      for (final state in ['named', 'no name', 'signed out', 'Pro', 'trial']) {
        testWidgets('root $state, dark $dark, text $scale', (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final name = state == 'no name' ? null : 'Aerol';
          final settings = UserSettings(
            name: name,
            dailyReminderTime: const SettingsTime(hour: 19, minute: 0),
            studyDays: StudyDays.all,
            examDate: null,
            strictMockMode: false,
            helpImproveApp: false,
            carryOverProgress: true,
            sessionOrdering: SessionOrdering.interleavedTail,
            retainTableOrder: true,
            updatedAt: null,
          );
          final entitlement = state == 'Pro'
              ? const Entitlement(plan: EntitlementPlan.yearly)
              : state == 'trial'
                  ? Entitlement(
                      plan: EntitlementPlan.monthly,
                      isTrial: true,
                      expiresAt: DateTime.now().add(const Duration(days: 3)),
                    )
                  : const Entitlement.free();
          await tester.pumpAppWithProviders(
            Theme(
              data: dark ? buildDarkTheme() : buildLightTheme(),
              child: MediaQuery(
                data: MediaQueryData(
                  size: const Size(390, 844),
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: const SettingsHomePage(),
              ),
            ),
            overrides: [
              userSettingsProvider.overrideWith((ref) async => settings),
              currentUserProvider.overrideWith(
                (ref) async => state == 'signed out'
                    ? null
                    : const AuthUser(
                        uid: 'a',
                        email: 'aerol@example.com',
                        displayName: 'Aerol',
                      ),
              ),
              isAnonymousProvider
                  .overrideWith((ref) async => state == 'signed out'),
              entitlementProvider
                  .overrideWith((ref) => Stream.value(entitlement)),
              activeExamShortNameProvider
                  .overrideWith((ref) => 'CSE Professional'),
              settingsSessionLengthProvider.overrideWith((ref) async => 10),
              themePreferenceProvider
                  .overrideWith((ref) async => ThemePreference.system),
            ],
          );
          await tester.pumpAndSettle();
          expect(find.text(name ?? 'Add your name'), findsOneWidget);
          expect(
            find.text(
              state == 'signed out' ? 'Not signed in' : 'aerol@example.com',
            ),
            findsOneWidget,
          );
          expect(
            find.text(
              state == 'Pro'
                  ? 'Yearly'
                  : state == 'trial'
                      ? 'Trial, 3 days left'
                      : 'Free',
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
