import 'package:pantas/app/flavor.dart';
import 'package:pantas/core/platform/app_check.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAppCheck extends Mock implements FirebaseAppCheck {}

void main() {
  setUpAll(() {
    registerFallbackValue(AndroidProvider.debug);
    registerFallbackValue(AppleProvider.debug);
  });

  late MockFirebaseAppCheck mockAppCheck;

  setUp(() {
    mockAppCheck = MockFirebaseAppCheck();
    when(
      () => mockAppCheck.activate(
        androidProvider: any(named: 'androidProvider'),
        appleProvider: any(named: 'appleProvider'),
      ),
    ).thenAnswer((_) async {});
  });

  test('activates with debug provider for Flavor.dev', () async {
    await activateAppCheck(Flavor.dev, appCheck: mockAppCheck);

    verify(
      () => mockAppCheck.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      ),
    ).called(1);
  });

  test('activates with playIntegrity for Flavor.staging', () async {
    await activateAppCheck(Flavor.staging, appCheck: mockAppCheck);

    verify(
      () => mockAppCheck.activate(),
    ).called(1);
  });

  test('activates with playIntegrity for Flavor.prod', () async {
    await activateAppCheck(Flavor.prod, appCheck: mockAppCheck);

    verify(
      () => mockAppCheck.activate(),
    ).called(1);
  });

  test('swallows activation throwing error', () async {
    when(
      () => mockAppCheck.activate(
        androidProvider: any(named: 'androidProvider'),
        appleProvider: any(named: 'appleProvider'),
      ),
    ).thenThrow(Exception('App check failure'));

    await expectLater(
      activateAppCheck(Flavor.dev, appCheck: mockAppCheck),
      completes,
    );
  });
}
