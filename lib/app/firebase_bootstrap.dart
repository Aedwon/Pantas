import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/firebase_options_dev.dart' as dev_options;
import 'package:pantas/firebase_options_prod.dart' as prod_options;
import 'package:pantas/firebase_options_staging.dart' as staging_options;

enum FirebaseBootstrapResult { configured, unavailable }

abstract interface class FirebaseBootAdapter {
  Future<void> initialize(FirebaseOptions options);
}

typedef FirebaseConfigSelector = FirebaseOptions? Function(Flavor flavor);

FirebaseOptions firebaseConfigForFlavor(Flavor flavor) {
  return switch (flavor) {
    Flavor.dev => dev_options.DefaultFirebaseOptions.android,
    Flavor.staging => staging_options.DefaultFirebaseOptions.android,
    Flavor.prod => prod_options.DefaultFirebaseOptions.android,
  };
}

Future<FirebaseBootstrapResult> bootstrapFirebase(
  Flavor flavor, {
  FirebaseBootAdapter adapter = const FirebaseSdkBootAdapter(),
  FirebaseConfigSelector configSelector = firebaseConfigForFlavor,
}) async {
  final config = configSelector(flavor);
  if (config == null) return FirebaseBootstrapResult.unavailable;

  try {
    await adapter.initialize(config);
    return FirebaseBootstrapResult.configured;
  } catch (error, stackTrace) {
    debugPrint('Firebase Core initialization failed: $error\n$stackTrace');
    return FirebaseBootstrapResult.unavailable;
  }
}

class FirebaseSdkBootAdapter implements FirebaseBootAdapter {
  const FirebaseSdkBootAdapter();

  @override
  Future<void> initialize(FirebaseOptions options) async {
    await Firebase.initializeApp(options: options);
  }
}
