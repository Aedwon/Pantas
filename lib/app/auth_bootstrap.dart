import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/email_code_auth.dart';
import 'package:pantas/core/auth/email_link_auth.dart';
import 'package:pantas/core/auth/firebase_auth_functions_gateway.dart';
import 'package:pantas/core/auth/firebase_auth_gateway.dart';
import 'package:pantas/core/auth/firebase_google_sign_in_gateway.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/platform/report_providers.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/runtime/sync_account_transition_gateway.dart';
import 'package:pantas/core/sync/unsent_sync_data.dart';

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
      // Study changes upload only for a real account with Pro sync on. For a
      // Free or guest account they can never upload, so they never hold a
      // sign-out. This account's own pending reports always do.
      Future<bool> unsent() => hasUnsentForSignOut(
            ref.read(appDatabaseProvider),
            canUploadStudyData: ref.read(syncEntitlementProvider) ==
                    SyncEntitlement.pro &&
                ref.read(authStateProvider).valueOrNull is SignedInAuthState,
            reports: ref.read(reportQueueProvider),
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
            SyncAccountTransitionGateway(
              () => ref.read(syncRuntimeProvider),
              // The queued question reports go out under the account that
              // wrote them before its data is wiped.
              flushReports: () => ref.read(reportQueueProvider).sendPending(),
              flushNow: () => ref.read(syncRuntimeProvider).forceFlush(),
              // Sign-out and an account switch wipe this device. They stop
              // while study changes or reports are still unsent.
              hasUnsentData: unsent,
            ),
        localStateWiper: localStateWiperBuilder?.call(ref) ??
            SyncLocalStateWiper(
              ref.watch(appDatabaseProvider),
              notifications: ref.watch(notificationServiceProvider),
              clearCustomExams: () =>
                  deleteCustomContentExams(ref.read(contentDatabaseProvider)),
            ),
      )
        // Checked again inside the wipe's own transaction, so nothing written
        // after the first check can be deleted.
        ..signOutWipeGuard = (wipe) => wipeUnlessUnsent(
              ref.read(appDatabaseProvider),
              hasUnsent: unsent,
              wipe: wipe,
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
