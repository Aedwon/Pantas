import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/platform/account_access.dart';
import 'package:pantas/core/platform/callable_options.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';

/// The callables of parent-held child setup, the guardian code gate and the
/// parent's actions on one child.
abstract interface class ChildSetupGateway {
  /// Records both ticks and creates the child. Throws [ChildSetupException].
  Future<ChildSetupResult> setupChildAccount({
    String? nickname,
    String? guardianProofId,
  });

  /// Names the child from the child's own session. Throws
  /// [ChildSetupException].
  Future<void> setChildNickname({
    required String childId,
    required String nickname,
  });

  /// Mails a 6-digit code to the parent or guardian for [action]. A
  /// [GuardianAction.addChild] names no child. Throws [GuardianGateException].
  Future<GuardianCodeSent> requestGuardianCode({
    required GuardianAction action,
    String? childId,
  });

  /// Checks the code and returns the proof id the guarded action consumes.
  /// Throws [GuardianGateException].
  Future<String> verifyGuardianCode({
    required GuardianAction action,
    required String code,
    String? childId,
  });

  /// Closes the child's account and erases the study data, behind a verified
  /// [GuardianAction.withdraw] proof. Throws [GuardianGateException].
  Future<void> withdrawChild({
    required String childId,
    required String guardianProofId,
  });

  /// Deletes the child's account behind a verified [GuardianAction.delete]
  /// proof. Throws [GuardianGateException].
  Future<void> deleteChild({
    required String childId,
    required String guardianProofId,
  });
}

/// One callable call. It returns the data or throws the platform's error, so
/// a test can raise any refusal.
// Single-method interface is intentional for callable-client test DI.
// ignore: one_member_abstracts
abstract interface class ChildCallableClient {
  Future<Object?> call(String name, Map<String, Object?> data);
}

class FirebaseChildCallableClient implements ChildCallableClient {
  const FirebaseChildCallableClient();
  static const region = 'asia-southeast1';

  @override
  Future<Object?> call(String name, Map<String, Object?> data) async {
    final callable = FirebaseFunctions.instanceFor(region: region)
        .httpsCallable(name, options: callableOptionsFor(name));
    final result = await callable.callForAccount<Object?>(data);
    return result.data;
  }
}

class CallableChildSetupGateway implements ChildSetupGateway {
  const CallableChildSetupGateway([
    this._client = const FirebaseChildCallableClient(),
  ]);
  final ChildCallableClient _client;

  /// A refusal carries the reason in the error details.
  ChildSetupException _refusal(FirebaseFunctionsException error) {
    final details = error.details;
    final reason = details is Map ? details['reason'] : null;
    final failure = ChildSetupFailure.fromReason(
      reason is String ? reason : null,
    );
    if (failure == ChildSetupFailure.other &&
        error.code == 'resource-exhausted') {
      return const ChildSetupException(ChildSetupFailure.rateLimited);
    }
    return ChildSetupException(failure);
  }

  @override
  Future<ChildSetupResult> setupChildAccount({
    String? nickname,
    String? guardianProofId,
  }) async {
    final Object? raw;
    try {
      raw = await _client.call('setupChildAccount', {
        'tick1TextVersion': ChildSetupVersions.tick1,
        'tick2TextVersion': ChildSetupVersions.tick2,
        'termsVersion': guardianDocumentVersions['terms'],
        'childNoticeVersion': ChildSetupVersions.childNotice,
        if (nickname != null) 'nickname': nickname,
        if (guardianProofId != null) 'guardianProofId': guardianProofId,
      });
    } on FirebaseFunctionsException catch (error) {
      throw _refusal(error);
    }
    if (raw is Map) {
      final childUid = raw['childUid'];
      final token = raw['customToken'];
      if (childUid is String && token is String) {
        return ChildSetupResult(childUid: childUid, customToken: token);
      }
    }
    throw const ChildSetupException(ChildSetupFailure.other);
  }

  @override
  Future<void> setChildNickname({
    required String childId,
    required String nickname,
  }) async {
    try {
      await _client.call('setChildNickname', {
        'childId': childId,
        'nickname': nickname,
      });
    } on FirebaseFunctionsException catch (error) {
      throw _refusal(error);
    }
  }

  GuardianGateException _gateRefusal(FirebaseFunctionsException error) {
    final details = error.details;
    final reason = details is Map ? details['reason'] : null;
    final tries = details is Map ? details['triesLeft'] : null;
    return GuardianGateException(
      GuardianGateFailure.from(
        reason: reason is String ? reason : null,
        code: error.code,
      ),
      triesLeft: tries is int ? tries : null,
    );
  }

  Future<Object?> _gateCall(String name, Map<String, Object?> data) async {
    try {
      return await _client.call(name, data);
    } on FirebaseFunctionsException catch (error) {
      throw _gateRefusal(error);
    }
  }

  @override
  Future<GuardianCodeSent> requestGuardianCode({
    required GuardianAction action,
    String? childId,
  }) async {
    final raw = await _gateCall('requestGuardianCode', {
      'action': action.serverName,
      if (childId != null) 'childId': childId,
    });
    if (raw is Map) {
      final masked = raw['maskedEmail'];
      final resend = raw['resendAfterSeconds'];
      final expires = raw['expiresInSeconds'];
      if (masked is String && resend is num && expires is num) {
        return GuardianCodeSent(
          maskedEmail: masked,
          resendAfterSeconds: resend.toInt(),
          expiresInSeconds: expires.toInt(),
        );
      }
    }
    throw const GuardianGateException(GuardianGateFailure.other);
  }

  @override
  Future<String> verifyGuardianCode({
    required GuardianAction action,
    required String code,
    String? childId,
  }) async {
    final raw = await _gateCall('verifyGuardianCode', {
      'action': action.serverName,
      if (childId != null) 'childId': childId,
      'code': code,
    });
    final proof = raw is Map ? raw['proof'] : null;
    if (proof is String && proof.isNotEmpty) return proof;
    throw const GuardianGateException(GuardianGateFailure.other);
  }

  @override
  Future<void> withdrawChild({
    required String childId,
    required String guardianProofId,
  }) async {
    await _gateCall('withdrawChild', {
      'childId': childId,
      'guardianProofId': guardianProofId,
    });
  }

  @override
  Future<void> deleteChild({
    required String childId,
    required String guardianProofId,
  }) async {
    await _gateCall('deleteChild', {
      'childId': childId,
      'guardianProofId': guardianProofId,
    });
  }
}
