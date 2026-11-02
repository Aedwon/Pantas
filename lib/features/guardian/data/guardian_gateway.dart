import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/platform/callable_options.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';

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
    String? studentName,
  });

  /// Reads the link for the guardian page. Never confirms.
  Future<GuardianLinkView> readLink(String token);

  Future<GuardianAnswer> answer({
    required String token,
    required bool confirm,
    required bool agreed,
  });
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
    String? studentName,
  }) async {
    final reply = _map(
      await _client.call('sendGuardianLink', {
        'guardianName': guardianName,
        'guardianEmail': guardianEmail,
        if (studentName != null) 'studentName': studentName,
      }),
    );
    return GuardianStatus.fromJson({...reply, 'status': 'pending'});
  }

  @override
  Future<GuardianLinkView> readLink(String token) async {
    final reply =
        _map(await _client.call('getGuardianRequest', {'token': token}));
    final expires = reply['expiresAt'];
    if (reply['state'] == 'open' && expires is int) {
      final name = reply['studentName'];
      return GuardianLinkOpen(
        studentName: name is String ? name : null,
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
  Future<GuardianAnswer> answer({
    required String token,
    required bool confirm,
    required bool agreed,
  }) async {
    final reply = _map(
      await _client.call('answerGuardianRequest', {
        'token': token,
        'decision': confirm ? 'confirm' : 'decline',
        'agreed': agreed,
      }),
    );
    return switch (reply['state']) {
      'confirmed' => GuardianAnswer.confirmed,
      'declined' => GuardianAnswer.declined,
      'used' => GuardianAnswer.used,
      'expired' => GuardianAnswer.expired,
      _ => GuardianAnswer.unknown,
    };
  }
}
