import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/core/platform/app_check.dart';

class MockFirebaseAppCheck extends Mock implements FirebaseAppCheck {}

/// firebase_app_check 0.4 renamed the activate parameters and turned the two
/// provider enums into class hierarchies, so a provider can no longer be
/// compared by identity. Each class carries a `type` string, and that is what
/// these assert on.
///
/// **The upgrade quietly emptied two of these tests.** They kept their names,
/// "activates with playIntegrity", while verifying a bare `activate()` that
/// says nothing about which provider was chosen. A test that cannot fail is
/// worse than no test, because it reads as covered.
void main() {
  setUpAll(() {
    registerFallbackValue(const AndroidDebugProvider());
    registerFallbackValue(const AppleDebugProvider());
    registerFallbackValue(ReCaptchaEnterpriseProvider('fallback'));
  });

  late MockFirebaseAppCheck mockAppCheck;

  setUp(() {
    mockAppCheck = MockFirebaseAppCheck();
    when(
      () => mockAppCheck.activate(
        providerAndroid: any(named: 'providerAndroid'),
        providerApple: any(named: 'providerApple'),
        providerWeb: any(named: 'providerWeb'),
      ),
    ).thenAnswer((_) async {});
  });

  /// The pair of provider `type` strings handed to activate.
  (String, String) capturedProviders() {
    final captured = verify(
      () => mockAppCheck.activate(
        providerAndroid: captureAny(named: 'providerAndroid'),
        providerApple: captureAny(named: 'providerApple'),
        providerWeb: any(named: 'providerWeb'),
      ),
    ).captured;
    return (
      (captured[0] as AndroidAppCheckProvider).type,
      (captured[1] as AppleAppCheckProvider).type,
    );
  }

  test('dev attests with the debug providers', () async {
    await activateAppCheck(Flavor.dev, appCheck: mockAppCheck);
    expect(capturedProviders(), ('debug', 'debug'));
  });

  test('staging uses Android debug and Apple Device Check', () async {
    await activateAppCheck(Flavor.staging, appCheck: mockAppCheck);
    expect(capturedProviders(), ('debug', 'deviceCheck'));
  });

  test('prod attests with Play Integrity and Device Check', () async {
    await activateAppCheck(Flavor.prod, appCheck: mockAppCheck);
    expect(capturedProviders(), ('playIntegrity', 'deviceCheck'));
  });

  test('a failure to attest never blocks studying', () async {
    when(
      () => mockAppCheck.activate(
        providerAndroid: any(named: 'providerAndroid'),
        providerApple: any(named: 'providerApple'),
        providerWeb: any(named: 'providerWeb'),
      ),
    ).thenThrow(Exception('App check failure'));

    await expectLater(
      activateAppCheck(Flavor.dev, appCheck: mockAppCheck),
      completes,
    );
  });

  test('web attests with reCAPTCHA Enterprise when a site key is built in',
      () async {
    await activateAppCheck(
      Flavor.staging,
      appCheck: mockAppCheck,
      webSiteKey: 'site-key-1',
    );
    final web = verify(
      () => mockAppCheck.activate(
        providerAndroid: any(named: 'providerAndroid'),
        providerApple: any(named: 'providerApple'),
        providerWeb: captureAny(named: 'providerWeb'),
      ),
    ).captured.single;
    expect(web, isA<ReCaptchaEnterpriseProvider>());
    expect((web! as ReCaptchaEnterpriseProvider).siteKey, 'site-key-1');
  });

  test('without a site key no web provider is passed', () async {
    await activateAppCheck(Flavor.staging, appCheck: mockAppCheck);
    final web = verify(
      () => mockAppCheck.activate(
        providerAndroid: any(named: 'providerAndroid'),
        providerApple: any(named: 'providerApple'),
        providerWeb: captureAny(named: 'providerWeb'),
      ),
    ).captured.single;
    expect(web, isNull);
  });
}
