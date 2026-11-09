import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/platform/callable_options.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/guardian/domain/guardian_copy.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';

/// A guardian call failed. The message never carries personal details.
class GuardianGatewayException implements Exception {
  const GuardianGatewayException([this.code = 'unknown']);
  final String code;
  @override
  String toString() => 'GuardianGatewayException($code)';
}

/// The server refused because too many links were requested.
class GuardianRateLimitedException extends GuardianGatewayException {
  const GuardianRateLimitedException() : super('resource-exhausted');
}

/// The server's single source of truth for guardian consent.
abstract interface class GuardianGateway {
  Future<GuardianStatus> status();

  /// Sends a fresh link. Also serves Resend and Change Email: the newest link
  /// is the only one that works.
  Future<GuardianStatus> sendLink({
    required String guardianName,
    required String guardianEmail,
    String? ageCheckNoticeVersion,
  });

  /// Tells the server the student re-checked their age and is now 18 or older.
  Future<void> markAdult();

  /// Reads the link for the guardian page. Never confirms.
  Future<GuardianLinkView> readLink(String token);

  Future<GuardianAnswerResult> answer({
    required String token,
    required bool confirm,
    required bool agreed,
    required bool allowSharing,
  });

  /// Reads the manage page for the link. Never changes anything.
  Future<GuardianManageView> readManage(String token);

  /// Turns optional usage sharing on or off for the student.
  Future<GuardianManageView> setSharing({
    required String token,
    required bool allowed,
  });

  /// Closes the student's account at the guardian's request.
  Future<GuardianWithdrawal> withdraw(String token);
}

// Single-method interface is intentional for callable-client test DI.
// ignore: one_member_abstracts
abstract interface class GuardianCallableClient {
  Future<Object?> call(String name, Map<String, Object?> data);
}

class FirebaseGuardianCallableClient implements GuardianCallableClient {
  const FirebaseGuardianCallableClient();
  static const region = 'asia-southeast1';

  @override
  Future<Object?> call(String name, Map<String, Object?> data) async {
    try {
      final result = await FirebaseFunctions.instanceFor(region: region)
          .httpsCallable(name, options: callableOptionsFor(name))
          .call<Object?>(data);
      return result.data;
    } on FirebaseFunctionsException catch (error) {
      if (error.code == 'resource-exhausted') {
        throw const GuardianRateLimitedException();
      }
      throw GuardianGatewayException(error.code);
    }
  }
}

class CallableGuardianGateway implements GuardianGateway {
  const CallableGuardianGateway([
    this._client = const FirebaseGuardianCallableClient(),
  ]);
  final GuardianCallableClient _client;

  Map<Object?, Object?> _map(Object? raw) {
    if (raw is Map) return raw.cast<Object?, Object?>();
    throw const GuardianGatewayException('malformed-response');
  }

  @override
  Future<GuardianStatus> status() async => GuardianStatus.fromJson(
        _map(await _client.call('getGuardianStatus', {})),
      );

  @override
  Future<GuardianStatus> sendLink({
    required String guardianName,
    required String guardianEmail,
    String? ageCheckNoticeVersion,
  }) async {
    final reply = _map(
      await _client.call('sendGuardianLink', {
        'guardianName': guardianName,
        'guardianEmail': guardianEmail,
        if (ageCheckNoticeVersion != null)
          'ageCheckNoticeVersion': ageCheckNoticeVersion,
      }),
    );
    return GuardianStatus.fromJson({...reply, 'status': 'pending'});
  }

  @override
  Future<void> markAdult() async {
    await _client.call('markGuardianAdult', {});
  }

  @override
  Future<GuardianLinkView> readLink(String token) async {
    final reply =
        _map(await _client.call('getGuardianRequest', {'token': token}));
    final expires = reply['expiresAt'];
    if (reply['state'] == 'open' && expires is int) {
      return GuardianLinkOpen(
        expiresAt: DateTime.fromMillisecondsSinceEpoch(expires, isUtc: true),
      );
    }
    return GuardianLinkClosed(
      switch (reply['state']) {
        'used' => GuardianLinkClosedReason.used,
        'expired' => GuardianLinkClosedReason.expired,
        _ => GuardianLinkClosedReason.unknown,
      },
    );
  }

  @override
  Future<GuardianAnswerResult> answer({
    required String token,
    required bool confirm,
    required bool agreed,
    required bool allowSharing,
  }) async {
    final reply = _map(
      await _client.call('answerGuardianRequest', {
        'token': token,
        'decision': confirm ? 'confirm' : 'decline',
        'agreed': agreed,
        'allowSharing': allowSharing,
        'documentVersions': guardianDocumentVersions,
        'noticeWordingVersion': guardianNoticeWordingVersion,
      }),
    );
    final manage = reply['manageToken'];
    return switch (reply['state']) {
      'confirmed' => GuardianAnswerResult(
          GuardianAnswer.confirmed,
          manageToken: manage is String ? manage : null,
        ),
      'declined' => const GuardianAnswerResult(GuardianAnswer.declined),
      'used' => const GuardianAnswerResult(GuardianAnswer.used),
      'expired' => const GuardianAnswerResult(GuardianAnswer.expired),
      _ => const GuardianAnswerResult(GuardianAnswer.unknown),
    };
  }

  GuardianManageView _manageView(Map<Object?, Object?> reply) =>
      switch (reply['state']) {
        'active' => GuardianManageActive(
            sharingAllowed: reply['sharingAllowed'] == true,
          ),
        'not_confirmed' => const GuardianManageNotConfirmed(),
        _ => const GuardianManageClosed(),
      };

  @override
  Future<GuardianManageView> readManage(String token) async => _manageView(
        _map(await _client.call('getGuardianManage', {'token': token})),
      );

  @override
  Future<GuardianManageView> setSharing({
    required String token,
    required bool allowed,
  }) async =>
      _manageView(
        _map(
          await _client.call(
            'setGuardianSharing',
            {'token': token, 'allowed': allowed},
          ),
        ),
      );

  @override
  Future<GuardianWithdrawal> withdraw(String token) async {
    final reply = _map(
      await _client.call('withdrawGuardianPermission', {'token': token}),
    );
    return switch (reply['state']) {
      'withdrawn' => GuardianWithdrawal.withdrawn,
      'not_confirmed' => GuardianWithdrawal.notConfirmed,
      _ => GuardianWithdrawal.closed,
    };
  }
}
