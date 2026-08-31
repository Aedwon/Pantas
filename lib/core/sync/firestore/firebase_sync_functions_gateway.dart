import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';

class SyncFunctionsClientException implements Exception {
  const SyncFunctionsClientException({
    required this.code,
    this.details,
  });

  final String code;
  final Object? details;
}

// ignore: one_member_abstracts
abstract interface class SyncFunctionsCallableClient {
  Future<Object?> call({
    required String region,
    required String name,
    required Map<String, Object?> data,
  });
}

class FirebaseSyncFunctionsCallableClient
    implements SyncFunctionsCallableClient {
  const FirebaseSyncFunctionsCallableClient();

  @override
  Future<Object?> call({
    required String region,
    required String name,
    required Map<String, Object?> data,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: region);
      final result = await functions.httpsCallable(name).call<Object?>(data);
      return result.data;
    } on FirebaseFunctionsException catch (error) {
      throw SyncFunctionsClientException(
        code: error.code,
        details: error.details,
      );
    }
  }
}

class FirebaseSyncFunctionsGateway implements SyncFunctionsGateway {
  FirebaseSyncFunctionsGateway({SyncFunctionsCallableClient? client})
      : _client = client ?? const FirebaseSyncFunctionsCallableClient();

  static const region = 'asia-southeast1';
  static const activateSyncGenerationCallable = 'activateSyncGeneration';

  final SyncFunctionsCallableClient _client;

  @override
  Future<void> activateGeneration({
    required String generationId,
    required String? expectedActiveGenerationId,
  }) async {
    try {
      final response = await _client.call(
        region: region,
        name: activateSyncGenerationCallable,
        data: {
          'generationId': generationId,
          'expectedActiveGenerationId': expectedActiveGenerationId,
        },
      );
      if (response is! Map ||
          response['activeGenerationId'] != generationId ||
          response['alreadyActive'] is! bool) {
        throw const SyncGatewayException('malformed-activation-response');
      }
    } on SyncFunctionsClientException catch (error) {
      final details = _stringKeyedMap(error.details);
      if (details?['code'] == 'generation-conflict') {
        throw SyncGatewayException(
          'generation-conflict',
          details: details,
        );
      }
      throw SyncGatewayException(error.code, details: details);
    }
  }

  static Map<String, Object?>? _stringKeyedMap(Object? value) {
    if (value is! Map) {
      return null;
    }
    return {
      for (final entry in value.entries) entry.key.toString(): entry.value,
    };
  }
}
