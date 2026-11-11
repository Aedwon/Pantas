// SDK platform fakes keep this test offline while using the production clients.
// Keep these process-wide SDK replacements out of shared CI bundles.
@TestOn('vm')
library;
// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/auth/firebase_auth_functions_gateway.dart';
import 'package:pantas/core/platform/account_access.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _User extends Mock
    with MockPlatformInterfaceMixin
    implements UserPlatform {}

class _Auth extends FirebaseAuthPlatform {
  _Auth(this.user);
  final UserPlatform user;
  @override
  UserPlatform get currentUser => user;
  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) => this;
  @override
  FirebaseAuthPlatform setInitialValues({
    InternalUserDetails? currentUser,
    String? languageCode,
  }) =>
      this;
}

class _Functions extends FirebaseFunctionsPlatform {
  _Functions() : super(null, 'asia-southeast1');
  @override
  FirebaseFunctionsPlatform delegateFor({
    required String region,
    FirebaseApp? app,
  }) =>
      this;
  @override
  HttpsCallablePlatform httpsCallable(
    String? origin,
    String name,
    HttpsCallableOptions options,
  ) =>
      _Refusal(this, origin, name, options);
}

class _Refusal extends HttpsCallablePlatform {
  _Refusal(
    FirebaseFunctionsPlatform functions,
    String? origin,
    String name,
    HttpsCallableOptions options,
  ) : super(functions, origin, name, options, null);
  @override
  Future<Object?> call([Object? parameters]) async =>
      throw FirebaseFunctionsException(
        code: 'permission-denied',
        message: 'This account is being deleted.',
        details: const {'reason': 'account-closed'},
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('real auth callable client publishes the server closure for its owner',
      () async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    final oldAuth = FirebaseAuthPlatform.instance;
    final oldFunctions = FirebaseFunctionsPlatform.instance;
    addTearDown(() {
      FirebaseAuthPlatform.instance = oldAuth;
      FirebaseFunctionsPlatform.instance = oldFunctions;
    });
    final user = _User();
    when(() => user.uid).thenReturn('callable-owner');
    FirebaseAuthPlatform.instance = _Auth(user);
    FirebaseFunctionsPlatform.instance = _Functions();
    final closures = <String>[];
    final sub = accountAccess.closures.listen(closures.add);
    addTearDown(sub.cancel);
    await expectLater(
      FirebaseAuthFunctionsGateway().recordSignInEvent(),
      throwsA(
        isA<AuthGatewayException>()
            .having((e) => e.code, 'code', 'account-closed'),
      ),
    );
    expect(closures, ['callable-owner']);
    expect(accountAccess.isClosed('callable-owner'), isTrue);
    expect(accountAccess.isClosed('other-owner'), isFalse);
  });
}
