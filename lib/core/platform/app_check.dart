import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:pantas/app/flavor.dart';

/// Activates Firebase App Check with flavor-specific providers.
///
/// Swallows activation failures so attestation failure never blocks studying.
Future<void> activateAppCheck(
  Flavor flavor, {
  FirebaseAppCheck? appCheck,
}) async {
  try {
    final instance = appCheck ?? FirebaseAppCheck.instance;
    final androidProvider = flavor == Flavor.dev
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity;
    final appleProvider =
        flavor == Flavor.dev ? AppleProvider.debug : AppleProvider.deviceCheck;

    await instance.activate(
      androidProvider: androidProvider,
      appleProvider: appleProvider,
    );
  } catch (error, stackTrace) {
    debugPrint('App Check activation failed: $error\n$stackTrace');
  }
}
