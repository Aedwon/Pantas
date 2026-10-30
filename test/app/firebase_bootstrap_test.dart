import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/firebase_options_dev.dart' as dev_options;
import 'package:pantas/firebase_options_prod.dart' as prod_options;
import 'package:pantas/firebase_options_staging.dart' as staging_options;

void main() {
  test('web flavors select web apps, including the approved prod app', () {
    for (final flavor in Flavor.values) {
      final options = firebaseConfigForFlavor(flavor, isWeb: true);
      expect(options.appId, contains(':web:'));
    }
    final prod = firebaseConfigForFlavor(Flavor.prod, isWeb: true);
    expect(prod.projectId, 'pantas-prod');
    expect(prod.appId, '1:416041343210:web:cdf805fbfb28ca13639f93');
    expect(prod.authDomain, 'pantas-prod.firebaseapp.com');
  });

  test('dev selects the generated dev Firebase options', () {
    expect(
      identical(
        firebaseConfigForFlavor(Flavor.dev),
        dev_options.DefaultFirebaseOptions.android,
      ),
      isTrue,
    );
  });

  test('staging selects the generated staging Firebase options', () {
    expect(
      identical(
        firebaseConfigForFlavor(Flavor.staging),
        staging_options.DefaultFirebaseOptions.android,
      ),
      isTrue,
    );
  });

  test('prod selects the generated prod Firebase options', () {
    expect(
      identical(
        firebaseConfigForFlavor(Flavor.prod),
        prod_options.DefaultFirebaseOptions.android,
      ),
      isTrue,
    );
  });

  test('successful bootstrap initializes Firebase Core exactly once', () async {
    final adapter = RecordingFirebaseBootAdapter();

    await bootstrapFirebase(Flavor.dev, adapter: adapter);

    expect(adapter.initializeCalls, 1);
  });

  test('successful bootstrap returns configured', () async {
    final adapter = RecordingFirebaseBootAdapter();

    final result = await bootstrapFirebase(Flavor.dev, adapter: adapter);

    expect(result, FirebaseBootstrapResult.configured);
  });

  test('failed Firebase Core initialization returns unavailable', () async {
    final adapter = RecordingFirebaseBootAdapter(
      initializationError: Exception('Firebase Core initialization failed'),
    );

    final result = await bootstrapFirebase(Flavor.prod, adapter: adapter);

    expect(result, FirebaseBootstrapResult.unavailable);
    expect(result, isNot(FirebaseBootstrapResult.configured));
    expect(adapter.initializeCalls, 1);
  });
}

class RecordingFirebaseBootAdapter implements FirebaseBootAdapter {
  RecordingFirebaseBootAdapter({this.initializationError});

  final Exception? initializationError;
  int initializeCalls = 0;

  @override
  Future<void> initialize(FirebaseOptions options) async {
    initializeCalls += 1;
    if (initializationError != null) throw initializationError!;
  }
}
