import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Only the local runner sets this. No real project options enter this build.
const localEmulatorHost = String.fromEnvironment('LOCAL_EMULATOR_HOST');
const localEmulators = localEmulatorHost != '';
const localFirebaseOptions = FirebaseOptions(
  apiKey: 'demo-pantas-local-api-key',
  appId: '1:123456789:web:local',
  messagingSenderId: '123456789',
  projectId: 'demo-pantas-local',
  storageBucket: 'demo-pantas-local.appspot.com',
);

/// `?localAccount=` as it was when startup began. Routing rewrites the page
/// address before Firebase starts, so startup records it first.
String? _startAccount;

/// Records `?localAccount=` from the page address. Call first thing in startup.
void rememberLocalAccount() {
  if (!localEmulators || !kIsWeb) return;
  _startAccount = Uri.base.queryParameters['localAccount'];
}

Future<void> connectLocalFirebase() async {
  if (!localEmulators) return;
  if (!kIsWeb || kReleaseMode) {
    throw StateError('Local emulators require a non-release web build.');
  }
  // Lets a second local run sit beside the first. Zero everywhere else.
  const offset = int.fromEnvironment('LOCAL_EMULATOR_PORT_OFFSET');
  await FirebaseAuth.instance.useAuthEmulator(localEmulatorHost, 9099 + offset);
  FirebaseFirestore.instance
      .useFirestoreEmulator(localEmulatorHost, 8080 + offset);
  FirebaseFunctions.instanceFor(region: 'asia-southeast1')
      .useFunctionsEmulator(localEmulatorHost, 5001 + offset);
  await FirebaseStorage.instance
      .useStorageEmulator(localEmulatorHost, 9199 + offset);

  // The app uses Google sign-in. These local-only links select password test
  // accounts before the normal auth bootstrap, without adding a product UI.
  final account = _startAccount ?? Uri.base.queryParameters['localAccount'];
  if (const {'free', 'pro', 'free2', 'pro2'}.contains(account)) {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: '$account@pantas.local',
      password: 'Local-visual-check-123!',
    );
  }
}
