import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
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
import 'package:pantas/core/platform/account_access.dart';
import 'package:pantas/core/platform/report_providers.dart';
import 'package:pantas/core/platform/reports_first_gateway.dart';
import 'package:pantas/core/platform/restorable_email_link_store.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/runtime/sync_account_transition_gateway.dart';

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
      // Sign-out clears the pending email-link address before it asks the
      // reports check; a refusal puts it back.
      final emailLinkStore = RestorableEmailLinkStore(
        const BrowserEmailLinkStore(),
      );
      return AuthRepository(
        gateway: gateway,
        emailLinkStore: emailLinkStore,
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
        // Question reports are sent first, before any teardown, and a report
        // that cannot be sent refuses the sign-out or switch.
        accountTransitionGateway: ReportsFirstTransitionGateway(
          accountTransitionGatewayBuilder?.call(ref) ??
              SyncAccountTransitionGateway(() => ref.read(syncRuntimeProvider)),
          () => ref.read(reportQueueProvider),
          // A closed account's reports can never be sent: its cleanup runs
          // without the check.
          isClosed: accountAccess.isClosed,
          onRefused: emailLinkStore.restore,
          onPassed: emailLinkStore.forget,
        ),
        localStateWiper: localStateWiperBuilder?.call(ref) ??
            SyncLocalStateWiper(
              ref.watch(appDatabaseProvider),
              notifications: ref.watch(notificationServiceProvider),
              clearCustomExams: () =>
                  deleteCustomContentExams(ref.read(contentDatabaseProvider)),
            ),
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
