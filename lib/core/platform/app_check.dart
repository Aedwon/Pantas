import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:pantas/app/flavor.dart';

/// The reCAPTCHA Enterprise site key for the web build, passed at build time
/// with `--dart-define=APP_CHECK_WEB_SITE_KEY=...`. A site key is public. Each
/// Firebase project has its own, so it is a build input, not a constant.
const _webSiteKey = String.fromEnvironment('APP_CHECK_WEB_SITE_KEY');

/// Activates Firebase App Check with flavor-specific providers.
///
/// Swallows activation failures so attestation failure never blocks studying.
/// Without a web site key, web passes no provider and every callable that
/// enforces App Check refuses the web app.
Future<void> activateAppCheck(
  Flavor flavor, {
  FirebaseAppCheck? appCheck,
  String webSiteKey = _webSiteKey,
}) async {
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
      providerWeb:
          webSiteKey.isEmpty ? null : ReCaptchaEnterpriseProvider(webSiteKey),
    );
  } catch (error, stackTrace) {
    debugPrint('App Check activation failed: $error\n$stackTrace');
  }
}
