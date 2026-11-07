import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/platform/callable_options.dart';

// Single-method interface is intentional for callable-client test DI.
// ignore: one_member_abstracts
abstract interface class AuthFunctionsCallableClient {
  Future<Object?> call({
    required String region,
    required String name,
    Object? data,
  });
}

class FirebaseFunctionsCallableClient implements AuthFunctionsCallableClient {
  const FirebaseFunctionsCallableClient();

  @override
  Future<Object?> call({
    required String region,
    required String name,
    Object? data,
  }) async {
    final functions = FirebaseFunctions.instanceFor(region: region);
    final result = await functions
        .httpsCallable(name, options: callableOptionsFor(name))
        .call<Object?>(data);
    return result.data;
  }
}

class FirebaseAuthFunctionsGateway implements AuthFunctionsGateway {
  FirebaseAuthFunctionsGateway({AuthFunctionsCallableClient? client})
      : _client = client ?? const FirebaseFunctionsCallableClient();

  static const region = 'asia-southeast1';

  final AuthFunctionsCallableClient _client;

  @override
  Future<void> recordSignInEvent() async {
    await _call('recordSignInEvent');
  }

  @override
  Future<Uri> exportData() async {
    final data = await _call('exportData');
    if (data is! Map) {
      throw const AuthGatewayException('malformed-export-response');
    }
    final downloadUrl = data['downloadUrl'];
    if (downloadUrl is! String) {
      throw const AuthGatewayException('malformed-export-response');
    }
    final uri = Uri.tryParse(downloadUrl);
    if (uri == null || !uri.hasScheme) {
      throw const AuthGatewayException('malformed-export-response');
    }
    return uri;
  }

  @override
  Future<void> deleteAccount() async {
    await _call('deleteAccount');
  }

  Future<Object?> _call(String name) async {
    try {
      return await _client.call(region: region, name: name);
    } on FirebaseFunctionsException catch (error) {
      final details = error.details;
      if (details is Map) {
        final reason = details['reason'];
        if (reason is String) {
          throw AuthGatewayException(reason);
        }
      }
      throw AuthGatewayException(error.code);
    }
  }
}

/// Calls `exchangeGoogleSignIn`: Google's ID token in, a custom token for the
/// existing account out. Every refusal becomes the callable's error code.
class FirebaseGoogleAccountExchangeGateway
    implements GoogleAccountExchangeGateway {
  FirebaseGoogleAccountExchangeGateway({AuthFunctionsCallableClient? client})
      : _client = client ?? const FirebaseFunctionsCallableClient();

  final AuthFunctionsCallableClient _client;

  @override
  Future<String> exchange(String idToken) async {
    final Object? data;
    try {
      data = await _client.call(
        region: FirebaseAuthFunctionsGateway.region,
        name: 'exchangeGoogleSignIn',
        data: {'idToken': idToken},
      );
    } on FirebaseFunctionsException catch (error) {
      throw AuthGatewayException(error.code);
    }
    final token = data is Map ? data['token'] : null;
    if (token is! String || token.isEmpty) {
      throw const AuthGatewayException('malformed-exchange-response');
    }
    return token;
  }
}
