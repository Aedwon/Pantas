import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/features/child_setup/application/child_account_closer.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/data/child_setup_gateway.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';

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

  // The guardian code gate and the parent's actions on one child.
  final codeRequests = <(GuardianAction, String?)>[];
  final codeChecks = <(GuardianAction, String?, String)>[];
  final closed = <(GuardianAction, String, String)>[];
  GuardianCodeSent sent = const GuardianCodeSent(
    maskedEmail: 'p***@example.test',
    resendAfterSeconds: 60,
    expiresInSeconds: 600,
  );
  String proof = 'proof-1';

  /// Thrown by the next call of each kind, when set.
  Exception? requestError;
  Exception? verifyError;
  Exception? closeError;

  @override
  Future<GuardianCodeSent> requestGuardianCode({
    required GuardianAction action,
    String? childId,
  }) async {
    codeRequests.add((action, childId));
    final error = requestError;
    if (error != null) throw error;
    return sent;
  }

  @override
  Future<String> verifyGuardianCode({
    required GuardianAction action,
    required String code,
    String? childId,
  }) async {
    codeChecks.add((action, childId, code));
    final error = verifyError;
    if (error != null) throw error;
    return proof;
  }

  @override
  Future<void> withdrawChild({
    required String childId,
    required String guardianProofId,
  }) async {
    final error = closeError;
    if (error != null) throw error;
    closed.add((GuardianAction.withdraw, childId, guardianProofId));
  }

  @override
  Future<void> deleteChild({
    required String childId,
    required String guardianProofId,
  }) async {
    final error = closeError;
    if (error != null) throw error;
    closed.add((GuardianAction.delete, childId, guardianProofId));
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

class FakeChildAccountCloser implements ChildAccountCloser {
  /// One entry per call: whether the parent's own session closed the account.
  final finished = <bool>[];

  /// The child each call closed.
  final children = <String>[];

  @override
  Future<void> finish({
    required bool holderSession,
    required String childId,
  }) async {
    finished.add(holderSession);
    children.add(childId);
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
