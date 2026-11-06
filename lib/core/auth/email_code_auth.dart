import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/auth/firebase_auth_functions_gateway.dart';
import 'package:pantas/core/auth/sign_in_result.dart';

/// Why an email code step failed. The sign-in screen maps each to its copy.
enum EmailCodeFailure {
  /// The server refused the address.
  invalidEmail,

  /// Too many codes were sent to this address or from this browser.
  tooManyRequests,

  /// The code is wrong. [EmailCodeException.triesLeft] says how many remain.
  wrong,

  /// The code expired, was already used, or was locked after the last try.
  expired,

  /// Five wrong tries locked this code.
  tooManyTries,

  /// The server's attempt limit for this browser.
  rateLimited,

  /// The account is disabled.
  disabled,

  /// Anything else: mail failed, the server is down, or the network is.
  unavailable,
}

class EmailCodeException implements Exception {
  const EmailCodeException(this.failure, {this.triesLeft});

  final EmailCodeFailure failure;
  final int? triesLeft;

  @override
  String toString() => 'EmailCodeException($failure)';
}

/// The server's answer to a code request.
class EmailCodeRequest {
  const EmailCodeRequest({required this.resendAfterSeconds, this.challengeId});

  /// Names the code this caller asked for. Null when the server only reports
  /// a cooldown that this caller did not start: nothing was sent for it.
  final String? challengeId;

  /// Seconds before another code may be requested.
  final int resendAfterSeconds;
}

/// The two server calls behind email code sign-in.
abstract interface class EmailCodeGateway {
  /// Mails a code.
  Future<EmailCodeRequest> requestCode(String email);

  /// Checks a code for [challengeId]. Returns the custom token to sign in with.
  Future<String> verifyCode(String challengeId, String code);
}

/// Signs in with the custom token that [EmailCodeGateway.verifyCode] returns.
// Single-method interface keeps the Firebase call injectable.
// ignore: one_member_abstracts
abstract interface class CustomTokenAuthGateway {
  Future<void> signInWithCustomToken(String token);
}

/// What the sign-in screen needs from email code sign-in.
abstract interface class EmailCodeAuth {
  /// Mails a code. Throws [EmailCodeException].
  Future<EmailCodeRequest> requestCode(String email);

  /// Checks the code for [challengeId] and signs in. Throws
  /// [EmailCodeException] when the code is refused. Returns a
  /// [FailedSignInResult] if Firebase refuses the token, and
  /// [CancelledSignInResult] if the flow was cancelled or the signed-in user
  /// changed while the server was checking; auth is then untouched.
  Future<SignInResult> verifyCode(String challengeId, String code);

  /// Drops any check in flight: its result will not sign anyone in.
  void cancelVerification();
}

class FirebaseEmailCodeGateway implements EmailCodeGateway {
  FirebaseEmailCodeGateway({AuthFunctionsCallableClient? client})
      : _client = client ?? const FirebaseFunctionsCallableClient();

  final AuthFunctionsCallableClient _client;

  @override
  Future<EmailCodeRequest> requestCode(String email) async {
    final data = await _call('requestSignInCode', {'email': email});
    final seconds = data is Map ? data['resendAfterSeconds'] : null;
    final id = data is Map ? data['challengeId'] : null;
    if (seconds is! num || (id != null && id is! String)) {
      throw const EmailCodeException(EmailCodeFailure.unavailable);
    }
    return EmailCodeRequest(
      resendAfterSeconds: seconds.toInt(),
      challengeId: id is String && id.isNotEmpty ? id : null,
    );
  }

  @override
  Future<String> verifyCode(String challengeId, String code) async {
    final data = await _call(
      'verifySignInCode',
      {'challengeId': challengeId, 'code': code},
      verifying: true,
    );
    final token = data is Map ? data['token'] : null;
    if (token is! String || token.isEmpty) {
      throw const EmailCodeException(EmailCodeFailure.unavailable);
    }
    return token;
  }

  Future<Object?> _call(
    String name,
    Map<String, Object?> data, {
    bool verifying = false,
  }) async {
    try {
      return await _client.call(
        region: FirebaseAuthFunctionsGateway.region,
        name: name,
        data: data,
      );
    } on FirebaseFunctionsException catch (error) {
      throw _failureFor(error, verifying: verifying);
    }
  }

  EmailCodeException _failureFor(
    FirebaseFunctionsException error, {
    required bool verifying,
  }) {
    final details = error.details;
    final reason = details is Map ? details['reason'] : null;
    final triesLeft = details is Map ? details['triesLeft'] : null;
    return switch (error.code) {
      'invalid-argument' when reason == 'wrong' => EmailCodeException(
          EmailCodeFailure.wrong,
          triesLeft: triesLeft is num ? triesLeft.toInt() : null,
        ),
      'invalid-argument' => const EmailCodeException(
          EmailCodeFailure.invalidEmail,
        ),
      'not-found' when reason == 'expired' => const EmailCodeException(
          EmailCodeFailure.expired,
        ),
      'resource-exhausted' when reason == 'tooManyTries' =>
        const EmailCodeException(EmailCodeFailure.tooManyTries),
      // Without a reason this is a rate limit: on sending, too many codes;
      // on checking, too many attempts from this browser.
      'resource-exhausted' => EmailCodeException(
          verifying
              ? EmailCodeFailure.rateLimited
              : EmailCodeFailure.tooManyRequests,
        ),
      'permission-denied' => const EmailCodeException(
          EmailCodeFailure.disabled,
        ),
      _ => const EmailCodeException(EmailCodeFailure.unavailable),
    };
  }
}

/// The uid a custom token is for, or null when the token cannot be read.
/// A token for the caller's own uid upgrades the anonymous user in place; any
/// other uid is another account and needs the account switch.
String? customTokenUid(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final uid = payload is Map ? payload['uid'] : null;
    return uid is String ? uid : null;
  } on FormatException {
    return null;
  }
}
