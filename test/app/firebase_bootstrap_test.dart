import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/app/flavor.dart';

void main() {
  test('firebaseConfigForFlavor returns null until generated options exist',
      () {
    expect(firebaseConfigForFlavor(Flavor.dev), isNull);
    expect(firebaseConfigForFlavor(Flavor.prod), isNull);
    expect(firebaseConfigForFlavor(Flavor.staging), isNull);
  });

  test('bootstrapFirebase skips initialization when options are unavailable',
      () async {
    final adapter = RecordingFirebaseBootAdapter();

    await bootstrapFirebase(Flavor.dev, adapter: adapter);

    expect(adapter.initialized, isFalse);
    expect(adapter.activatedProvider, isNull);
  });

  test('bootstrapFirebase activates debug App Check for dev when configured',
      () async {
    final adapter = RecordingFirebaseBootAdapter();

    await bootstrapFirebase(
      Flavor.dev,
      adapter: adapter,
      configSelector: (_) => const FirebaseAppConfig(name: 'dev'),
    );

    expect(adapter.initialized, isTrue);
    expect(adapter.activatedProvider, AppCheckProvider.debug);
  });

  test('bootstrapFirebase activates Play Integrity for prod when configured',
      () async {
    final adapter = RecordingFirebaseBootAdapter();

    await bootstrapFirebase(
      Flavor.prod,
      adapter: adapter,
      configSelector: (_) => const FirebaseAppConfig(name: 'prod'),
    );

    expect(adapter.initialized, isTrue);
    expect(adapter.activatedProvider, AppCheckProvider.playIntegrity);
  });
}

class RecordingFirebaseBootAdapter implements FirebaseBootAdapter {
  bool initialized = false;
  AppCheckProvider? activatedProvider;

  @override
  Future<void> initialize(FirebaseAppConfig config) async {
    initialized = true;
  }

  @override
  Future<void> activateAppCheck(AppCheckProvider provider) async {
    activatedProvider = provider;
  }
}
