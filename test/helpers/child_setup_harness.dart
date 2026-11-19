import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/data/child_setup_gateway.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';

class FakeChildSetupGateway implements ChildSetupGateway {
  int setups = 0;
  final nicknames = <(String, String)>[];

  /// Thrown by the next setup call, when set.
  Exception? setupError;
  Exception? nicknameError;

  @override
  Future<ChildSetupResult> setupChildAccount({
    String? nickname,
    String? guardianProofId,
  }) async {
    setups++;
    final error = setupError;
    if (error != null) throw error;
    return const ChildSetupResult(childUid: 'child-1', customToken: 'token-1');
  }

  @override
  Future<void> setChildNickname({
    required String childId,
    required String nickname,
  }) async {
    final error = nicknameError;
    if (error != null) throw error;
    nicknames.add((childId, nickname));
  }
}

class FakeChildSessionStarter implements ChildSessionStarter {
  final started = <String>[];

  @override
  Future<void> start({
    required String childUid,
    required String customToken,
  }) async {
    started.add(childUid);
  }
}

class MockAuthRepository extends Mock implements AuthRepository {}

MockAuthRepository fakeAuth({
  SignInResult google = const SignInResult.cancelled(),
}) {
  final auth = MockAuthRepository();
  when(auth.signInWithGoogle).thenAnswer((_) async => google);
  when(auth.signOut).thenAnswer((_) async {});
  return auth;
}
