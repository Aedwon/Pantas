import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/auth/public_id_provider.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/presentation/pages/name_page.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/presentation/pages/whats_included_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _Telemetry extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

class _Auth extends Fake implements AuthRepository {
  _Auth(this.error);
  // These fakes preserve both typed exceptions and Error instances.
  final Object error;
  @override
  // ignore: only_throw_errors
  Future<SignInResult> signInWithGoogle() async => throw error;
  @override
  // ignore: only_throw_errors
  Future<void> signOut() async => throw error;
}

class _Actions extends Fake implements SettingsActions {
  _Actions(this.error);
  // These fakes preserve both typed exceptions and Error instances.
  final Object error;
  @override
  // ignore: only_throw_errors
  Future<void> setName(String? name) async => throw error;
  @override
  Future<void> setCarryOverProgress({required bool enabled}) async =>
      // ignore: only_throw_errors
      throw error;
}

class _Runtime extends FakeSyncEngine {
  _Runtime(this.error);
  // These fakes preserve both typed exceptions and Error instances.
  final Object error;
  @override
  // ignore: only_throw_errors
  Future<void> forceFlush() async => throw error;
}

void main() {
  testWidgets('checkout user lookup failure is reported', (tester) async {
    final telemetry = _Telemetry();
    final error = StateError('user lookup');
    final gateway = WebPaymentGateway(
      callable: (_, __) async => {'plans': <Object?>[]},
      readGrants: (_) async => [],
      refreshClaims: (_) async {},
      openUrl: (_) async => true,
    );
    await tester.pumpAppWithProviders(
      const ProPage(),
      overrides: [
        telemetryProvider.overrideWithValue(telemetry),
        paymentsOnWebProvider.overrideWithValue(true),
        revenueCatGatewayProvider.overrideWithValue(gateway),
        currentUserProvider.overrideWith((ref) async => throw error),
        proForActiveExamProvider.overrideWith((ref) async => false),
        activeProCatalogEntryProvider.overrideWith((ref) async => null),
        paywallOfferingProvider.overrideWith(
          (ref) async => const PaywallOfferingResult.noCurrentOffering(),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(telemetry.errors, contains(same(error)));
  });

  testWidgets('upgrade preparation failure is reported before checkout',
      (tester) async {
    final telemetry = _Telemetry();
    final error = StateError('prepare');
    final db = inMemoryDatabase();
    addTearDown(db.close);
    const exam = ExamCatalogEntry(
      id: 'exam_cse_pro',
      name: 'CSE Professional',
      shortName: 'CSE Professional',
      priceTier: 'Civil Service',
      group: 'Civil service',
      comingSoon: false,
      publishedSittings: [],
      hasContent: true,
    );
    await tester.pumpAppWithProviders(
      const ProPage(targetExam: exam),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        telemetryProvider.overrideWithValue(telemetry),
        paymentsOnWebProvider.overrideWithValue(true),
        currentUserProvider.overrideWith(
          (ref) async => const AuthUser(
            uid: 'owner',
            email: 'o@example.com',
            displayName: 'Owner',
          ),
        ),
        isAnonymousProvider.overrideWith((ref) async => false),
        carryableCountProvider(exam.id)
            .overrideWith((ref) async => throw error),
        unfilteredPaywallOfferingProvider.overrideWith(
          (ref) async => const PaywallOfferingResult(
            status: PaywallOfferingStatus.available,
            recognizedPackages: [
              PaywallPackage(
                sku: PaywallSku.monthly,
                productId: 'pantas_cs_monthly',
                priceString: '₱149',
                priceAmount: 149,
              ),
            ],
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
    final button = find.byWidgetPredicate(
      (w) => w is PantasButton && w.label.startsWith('Upgrade for'),
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(telemetry.errors, contains(same(error)));
    expect(find.text('Could not save. Please try again.'), findsOneWidget);
  });

  testWidgets('subscription launcher failure is reported', (tester) async {
    final telemetry = _Telemetry();
    final error = StateError('launcher');
    await tester.pumpAppWithProviders(
      ProPage(subscriptionLauncher: (_) async => throw error),
      overrides: [
        telemetryProvider.overrideWithValue(telemetry),
        paymentsOnWebProvider.overrideWithValue(false),
        entitlementProvider.overrideWith(
          (ref) => Stream.value(
            const Entitlement(
              plan: EntitlementPlan.monthly,
              productId: 'pantas_pro_monthly',
            ),
          ),
        ),
        proForActiveExamProvider.overrideWith((ref) async => true),
        activeProCatalogEntryProvider.overrideWith((ref) async => null),
        paywallOfferingProvider.overrideWith(
          (ref) async => const PaywallOfferingResult.noCurrentOffering(),
        ),
      ],
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Manage in Google Play'));
    await tester.tap(find.text('Manage in Google Play'));
    await tester.pumpAndSettle();
    expect(telemetry.errors, contains(same(error)));
  });

  testWidgets('exam save failure is reported', (tester) async {
    final telemetry = _Telemetry();
    final error = StateError('exam save');
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: [
        telemetryProvider.overrideWithValue(telemetry),
        settingsActionsProvider.overrideWithValue(_Actions(error)),
        userSettingsProvider
            .overrideWith((ref) async => UserSettings.defaults()),
        activeExamFocusProvider
            .overrideWith((ref) async => ActiveExamFocus.selected(buildExam())),
      ],
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Carry over progress'));
    await tester.tap(find.text('Carry over progress'));
    await tester.pumpAndSettle();
    expect(telemetry.errors, contains(same(error)));
    expect(find.text('Could not save. Please try again.'), findsOneWidget);
  });

  for (final signOut in [false, true]) {
    for (final network in [false, true]) {
      testWidgets(
          'auth signOut=$signOut network=$network reports and classifies',
          (tester) async {
        final telemetry = _Telemetry();
        final error = network
            ? const AuthGatewayException('network-request-failed')
            : StateError('unexpected');
        await tester.pumpAppWithProviders(
          const AccountPage(),
          overrides: [
            telemetryProvider.overrideWithValue(telemetry),
            authRepositoryProvider.overrideWithValue(_Auth(error)),
            currentUserProvider.overrideWith(
              (ref) => signOut
                  ? const AuthUser(
                      uid: 'a',
                      email: 'a@example.com',
                      displayName: 'A',
                    )
                  : null,
            ),
            paymentsOnWebProvider.overrideWithValue(true),
          ],
        );
        await tester.pumpAndSettle();
        final label = signOut ? 'Sign Out' : 'Continue with Google';
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        if (signOut) {
          await tester.tap(find.text('Sign Out').last);
          await tester.pumpAndSettle();
        }
        expect(telemetry.errors, [same(error)]);
        expect(
          find.text('Something went wrong.'),
          network ? findsNothing : findsOneWidget,
        );
        expect(
          find.text(
            'You need a connection to sign ${signOut ? 'out' : 'in'}.',
          ),
          network ? findsOneWidget : findsNothing,
        );
      });
    }
  }

  testWidgets('clipboard failure is reported', (tester) async {
    final telemetry = _Telemetry();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          throw PlatformException(code: 'failed');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpAppWithProviders(
      const AccountPage(),
      overrides: [
        telemetryProvider.overrideWithValue(telemetry),
        currentUserProvider.overrideWith(
          (ref) => const AuthUser(
            uid: 'a',
            email: 'a@example.com',
            displayName: 'A',
          ),
        ),
        publicIdProvider.overrideWith(
          (ref) => Stream.value(const PublicIdState.ready('123456789')),
        ),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pantas ID'));
    await tester.pumpAndSettle();
    expect(telemetry.errors.single, isA<PlatformException>());
    expect(find.text('Copied'), findsNothing);
  });

  testWidgets('name save failure is reported and keeps retry', (tester) async {
    final telemetry = _Telemetry();
    final error = StateError('name');
    await tester.pumpAppWithProviders(
      const NamePage(),
      overrides: [
        telemetryProvider.overrideWithValue(telemetry),
        settingsActionsProvider.overrideWithValue(_Actions(error)),
        userSettingsProvider
            .overrideWith((ref) async => UserSettings.defaults()),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(telemetry.errors, [same(error)]);
    expect(find.text('Could not save your progress.'), findsOneWidget);
  });

  testWidgets('carry-over failure is reported and keeps retry', (tester) async {
    final telemetry = _Telemetry();
    final error = StateError('carry-over');
    await tester.pumpAppWithProviders(
      CarryOverScreen(
        exam: 'CSE',
        onCounted: () {},
        onDecision: ({required count}) async => throw error,
      ),
      overrides: [telemetryProvider.overrideWithValue(telemetry)],
    );
    await tester.ensureVisible(find.text('Count Them'));
    await tester.tap(find.text('Count Them'));
    await tester.pumpAndSettle();
    expect(telemetry.errors, [same(error)]);
    expect(find.text('Could not save your progress.'), findsOneWidget);
  });

  testWidgets('backup failure is reported and keeps retry', (tester) async {
    final telemetry = _Telemetry();
    final error = StateError('backup');
    await tester.pumpAppWithProviders(
      const BackupPage(),
      overrides: [
        telemetryProvider.overrideWithValue(telemetry),
        isAnonymousProvider.overrideWith((ref) async => false),
        entitlementProvider.overrideWith(
          (ref) =>
              Stream.value(const Entitlement(plan: EntitlementPlan.monthly)),
        ),
        syncRuntimeProvider.overrideWith((ref) => _Runtime(error)),
        syncStatusProvider
            .overrideWith((ref) => Stream.value(const SyncUpToDate())),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back Up Now'));
    await tester.pumpAndSettle();
    expect(telemetry.errors, [same(error)]);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('scope save failure is reported and keeps retry', (tester) async {
    final telemetry = _Telemetry();
    final error = StateError('scope');
    final exam = buildExam();
    await tester.pumpAppWithProviders(
      const WhatsIncludedPage(),
      overrides: [
        telemetryProvider.overrideWithValue(telemetry),
        activeExamFocusProvider
            .overrideWith((ref) async => ActiveExamFocus.selected(exam)),
        whatsIncludedDataProvider(exam.id).overrideWith(
          (ref) async => (
            exam: exam,
            excluded: <String>{},
            excludedLessons: <String>{},
            subjects: const [
              ScopeSubject(
                title: 'Math',
                topics: [
                  ScopeTopic(id: 'a', title: 'A'),
                  ScopeTopic(id: 'b', title: 'B'),
                ],
              ),
            ]
          ),
        ),
        studySettingsCaptureProvider
            .overrideWithValue(({String? examId}) async => throw error),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    expect(telemetry.errors, [same(error)]);
    expect(find.text('Could not save your progress.'), findsOneWidget);
  });

  testWidgets('delete failure is reported and keeps retry', (tester) async {
    final telemetry = _Telemetry();
    final error = StateError('delete');
    await tester.pumpAppWithProviders(
      DeleteAccountPage(
        isAnonymous: false,
        entitlement: const SettingsEntitlementSnapshot.free(),
        dpoEmail: 'dpo@example.com',
        onDelete: () async => throw error,
      ),
      overrides: [telemetryProvider.overrideWithValue(telemetry)],
    );
    await tester.tap(find.text('Delete My Data'));
    await tester.pumpAndSettle();
    expect(telemetry.errors, [same(error)]);
    expect(find.text('Try again'), findsOneWidget);
  });

  for (final web in [true, false]) {
    testWidgets('trial deletion warning web=$web', (tester) async {
      await tester.pumpAppWithProviders(
        DeleteAccountPage(
          isAnonymous: false,
          entitlement: const SettingsEntitlementSnapshot(
            plan: SettingsEntitlementPlan.monthly,
            isTrial: true,
          ),
          dpoEmail: 'dpo@example.com',
          onDelete: () async {},
        ),
        overrides: [paymentsOnWebProvider.overrideWithValue(web)],
      );
      expect(
        find.textContaining('Google Play'),
        web ? findsNothing : findsOneWidget,
      );
      expect(
        find.textContaining('Your free trial will end if you delete now.'),
        findsOneWidget,
      );
    });
  }
}
