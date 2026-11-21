import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/platform/account_access.dart';
import 'package:pantas/core/platform/callable_options.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';

/// The two callables of parent-held child setup.
abstract interface class ChildSetupGateway {
  /// Records both ticks and creates the child. Call after both ticks are set.
  /// Throws [ChildSetupException].
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
        'tick1Accepted': true,
        'tick2Accepted': true,
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
}
