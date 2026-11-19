import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/account_device_state.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/app/sync_runtime_bootstrap.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/email_code_auth.dart';
import 'package:pantas/core/auth/email_link_auth.dart';
import 'package:pantas/core/auth/firebase_auth_functions_gateway.dart';
import 'package:pantas/core/auth/firebase_auth_gateway.dart';
import 'package:pantas/core/auth/firebase_google_sign_in_gateway.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/database_opener.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/runtime/sync_account_transition_gateway.dart';
import 'package:pantas/core/telemetry/client_report.dart';

typedef AuthGatewayBuilder = AuthGateway Function();
typedef GoogleGatewayBuilder = GoogleSignInGateway Function();
typedef FunctionsGatewayBuilder = AuthFunctionsGateway Function();
typedef LocalStateWiperBuilder = LocalStateWiper Function(Ref ref);
typedef AccountTransitionGatewayBuilder = AccountTransitionGateway Function(
  Ref ref,
);

List<Override> authRepositoryOverrides(
  FirebaseBootstrapResult firebaseResult, {
  AuthGatewayBuilder? authGatewayBuilder,
  GoogleGatewayBuilder? googleGatewayBuilder,
  FunctionsGatewayBuilder? functionsGatewayBuilder,
  LocalStateWiperBuilder? localStateWiperBuilder,
  AccountTransitionGatewayBuilder? accountTransitionGatewayBuilder,
}) {
  return [
    authRepositoryProvider.overrideWith((ref) {
      if (firebaseResult != FirebaseBootstrapResult.configured) {
        return buildUnavailableAuthRepository();
      }

      final gateway = (authGatewayBuilder ?? FirebaseAuthGateway.new)();
      const childAccounts = FirebaseChildAccountsGateway();
      final firebase = gateway is FirebaseAuthGateway ? gateway : null;
      final children = <String, AppDatabase>{};
      if (firebase != null) {
        ref.onDispose(() {
          for (final child in children.values) {
            unawaited(child.close());
          }
        });
      }

      LocalStateWiper wiper() =>
          localStateWiperBuilder?.call(ref) ??
          SyncLocalStateWiper(
            ref.read(appDatabaseProvider),
            notifications: ref.read(notificationServiceProvider),
            clearCustomExams: () =>
                deleteCustomContentExams(ref.read(contentDatabaseProvider)),
          );

      // Read the shared database once so auth survives a store switch.
      final device = firebase == null
          ? null
          : AccountDeviceState(
              shared: ref.read(appDatabaseProvider),
              openChild: (uid) async {
                final existing = children[uid];
                if (existing != null) return existing;
                final digest = await Sha256().hash(utf8.encode(uid));
                final suffix =
                    base64Url.encode(digest.bytes).replaceAll('=', '');
                return children[uid] = await openEncryptedDatabase(
                  databaseName: 'pantas-child-$suffix',
                );
              },
              activate: (database) async {
                if (identical(database, ref.read(appDatabaseProvider))) {
                  ref.invalidate(appPreferencesRepositoryProvider);
                  return;
                }
                final isChild = children.containsValue(database);
                if (isChild) {
                  ClientReporter.active?.enabled = false;
                  await ref
                      .read(telemetryConsentControllerProvider.notifier)
                      .applyStartupConsent(enabled: false);
                }
                final previous = ref.read(syncRuntimeProvider);
                final next = previous.runtimeKind == SyncRuntimeKind.configured
                    ? await buildConfiguredSyncRuntime(
                        ref.container,
                        database: database,
                      )
                    : null;
                if (previous is ConfiguredSyncRuntimeSurface) {
                  await previous.close();
                } else {
                  await previous.quiesce(flush: false);
                }
                final content = ref.read(contentDatabaseProvider);
                await deleteCustomContentExams(content);
                await CustomTrackRepository(database, content).reprojectAll();
                ref.read(activeChildDatabaseProvider.notifier).state =
                    isChild ? database : null;
                if (next != null) {
                  ref.read(syncRuntimeProvider.notifier).state = next;
                }
              },
            );

      return AuthRepository(
        gateway: gateway,
        emailLinkGateway: kIsWeb && gateway is EmailLinkAuthGateway
            ? gateway as EmailLinkAuthGateway
            : null,
        emailCodeGateway: FirebaseEmailCodeGateway(),
        googleExchangeGateway: FirebaseGoogleAccountExchangeGateway(),
        customTokenGateway: gateway is CustomTokenAuthGateway
            ? gateway as CustomTokenAuthGateway
            : null,
        googlePopupGateway: kIsWeb && gateway is GooglePopupAuthGateway
            ? gateway as GooglePopupAuthGateway
            : null,
        googleGateway:
            (googleGatewayBuilder ?? FirebaseGoogleSignInGateway.new)(),
        functionsGateway:
            (functionsGatewayBuilder ?? FirebaseAuthFunctionsGateway.new)(),
        accountTransitionGateway: accountTransitionGatewayBuilder?.call(ref) ??
            SyncAccountTransitionGateway(() => ref.read(syncRuntimeProvider)),
        activeStateWiper: wiper,
        childAccounts: firebase == null ? null : childAccounts,
        restoreDeviceState: device?.restore,
        completeGuardianSetup: device?.completeGuardianSetup,
        readAgeGroup: firebase == null
            ? null
            : (session) async {
                final claim = await firebase.ageGroupClaim(session.uid);
                if (claim != null) return claim;
                try {
                  return await childAccounts.readConsentAgeGroup();
                } on AuthGatewayException {
                  // A failed consent read cannot relax this account's age.
                  return null;
                }
              },
        eraseHolderState: device == null
            ? null
            : () async {
                await ref.read(syncRuntimeProvider).quiesce(flush: false);
                firebase?.discardPendingGoogleCredential();
                await wiper().wipeAll();
                await device.clearSharedAccountPreferences();
              },
      );
    }),
  ];
}

Future<void> bootstrapAuthSession(
  ProviderContainer container,
  FirebaseBootstrapResult firebaseResult,
) async {
  if (firebaseResult != FirebaseBootstrapResult.configured) return;

  try {
    await container.read(authRepositoryProvider).ensureAnonymous();
  } catch (error, stackTrace) {
    debugPrint('Anonymous Auth bootstrap failed: $error\n$stackTrace');
  }
}
