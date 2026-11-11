import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:pantas/app/flavor.dart';

/// The reCAPTCHA Enterprise site key for the web build, passed at build time
/// with `--dart-define=APP_CHECK_WEB_SITE_KEY=...`. A site key is public. Each
/// Firebase project has its own, so it is a build input, not a constant.
const _webSiteKey = String.fromEnvironment('APP_CHECK_WEB_SITE_KEY');

/// Thrown when a release web build has no reCAPTCHA Enterprise site key.
/// Every callable enforces App Check, so a build without one cannot work.
/// Failing at startup names the cause instead of leaving every request to
/// fail with a vague "unauthenticated".
class AppCheckConfigurationException implements Exception {
  const AppCheckConfigurationException();

  static const message = 'This web build has no App Check site key. Rebuild '
      'with --dart-define=APP_CHECK_WEB_SITE_KEY=<reCAPTCHA Enterprise site '
      'key>.';

  @override
  String toString() => 'AppCheckConfigurationException: $message';
}

/// The App Check provider for web.
///
/// - A site key attests with reCAPTCHA Enterprise, in every build mode.
/// - No key in a debug or profile build uses the web debug provider. The
///   browser console prints a token that is registered in the Firebase
///   console, which is how local runs against the emulator or a test project
///   work.
/// - No key in a release build fails closed with
///   [AppCheckConfigurationException].
WebProvider webAppCheckProvider({
  required String siteKey,
  required bool releaseMode,
}) {
  if (siteKey.isNotEmpty) return ReCaptchaEnterpriseProvider(siteKey);
  if (releaseMode) throw const AppCheckConfigurationException();
  return WebDebugProvider();
}

/// Activates Firebase App Check with flavor-specific providers.
///
/// Swallows activation failures so attestation failure never blocks studying
/// on native. The one exception is a release web build with no site key, which
/// throws [AppCheckConfigurationException] so startup shows a failure.
Future<void> activateAppCheck(
  Flavor flavor, {
  FirebaseAppCheck? appCheck,
  String webSiteKey = _webSiteKey,
  bool isWeb = kIsWeb,
  bool releaseMode = kReleaseMode,
}) async {
  final webProvider = isWeb
      ? webAppCheckProvider(siteKey: webSiteKey, releaseMode: releaseMode)
      : null;
  try {
    final instance = appCheck ?? FirebaseAppCheck.instance;
    // The provider enums became classes in firebase_app_check 0.4, alongside
    // the parameter rename. Same three choices, constructed rather than named.
    final androidProvider = switch (flavor) {
      Flavor.dev || Flavor.staging => const AndroidDebugProvider(),
      Flavor.prod => const AndroidPlayIntegrityProvider(),
    };
    final appleProvider = flavor == Flavor.dev
        ? const AppleDebugProvider()
        : const AppleDeviceCheckProvider();

    await instance.activate(
      providerAndroid: androidProvider,
      providerApple: appleProvider,
      providerWeb: webProvider,
    );
  } catch (error, stackTrace) {
    debugPrint('App Check activation failed: $error\n$stackTrace');
  }
}
