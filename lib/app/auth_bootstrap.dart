import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/firebase_auth_functions_gateway.dart';
import 'package:pantas/core/auth/firebase_auth_gateway.dart';
import 'package:pantas/core/auth/firebase_google_sign_in_gateway.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';

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

      return AuthRepository(
        gateway: (authGatewayBuilder ?? FirebaseAuthGateway.new)(),
        googleGateway:
            (googleGatewayBuilder ?? FirebaseGoogleSignInGateway.new)(),
        functionsGateway:
            (functionsGatewayBuilder ?? FirebaseAuthFunctionsGateway.new)(),
        accountTransitionGateway: accountTransitionGatewayBuilder?.call(ref) ??
            const NoopAccountTransitionGateway(),
        localStateWiper: localStateWiperBuilder?.call(ref) ??
            SyncLocalStateWiper(
              ref.watch(appDatabaseProvider),
              notifications: ref.watch(notificationServiceProvider),
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
