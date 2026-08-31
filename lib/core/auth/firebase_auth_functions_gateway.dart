import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/auth/auth_repository.dart';

abstract interface class AuthFunctionsCallableClient {
  Future<Object?> call({required String region, required String name});
}

class FirebaseFunctionsCallableClient implements AuthFunctionsCallableClient {
  const FirebaseFunctionsCallableClient();

  @override
  Future<Object?> call({required String region, required String name}) async {
    final functions = FirebaseFunctions.instanceFor(region: region);
    final result = await functions.httpsCallable(name).call<Object?>();
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
