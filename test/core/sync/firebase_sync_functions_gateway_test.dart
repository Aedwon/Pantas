import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/firestore/firebase_sync_functions_gateway.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';

void main() {
  test('calls certified activateSyncGeneration callable in asia-southeast1',
      () async {
    final client = RecordingSyncFunctionsClient()
      ..result = {'activeGenerationId': 'g2', 'alreadyActive': false};
    final gateway = FirebaseSyncFunctionsGateway(client: client);

    await gateway.activateGeneration(
      generationId: 'g2',
      expectedActiveGenerationId: 'g1',
    );

    expect(client.region, 'asia-southeast1');
    expect(client.name, 'activateSyncGeneration');
    expect(client.data, {
      'generationId': 'g2',
      'expectedActiveGenerationId': 'g1',
    });
  });

  test('passes null expected generation exactly for first activation',
      () async {
    final client = RecordingSyncFunctionsClient()
      ..result = {'activeGenerationId': 'g1', 'alreadyActive': false};

    await FirebaseSyncFunctionsGateway(client: client).activateGeneration(
      generationId: 'g1',
      expectedActiveGenerationId: null,
    );

    expect(client.data?['expectedActiveGenerationId'], isNull);
  });

  test('normalizes backend generation-conflict details to stable client code',
      () async {
    final client = RecordingSyncFunctionsClient()
      ..error = const SyncFunctionsClientException(
        code: 'failed-precondition',
        details: {
          'code': 'generation-conflict',
          'activeGenerationId': 'g3',
        },
      );
    final gateway = FirebaseSyncFunctionsGateway(client: client);

    expect(
      gateway.activateGeneration(
        generationId: 'g2',
        expectedActiveGenerationId: 'g1',
      ),
      throwsA(
        isA<SyncGatewayException>()
            .having((error) => error.code, 'code', 'generation-conflict')
            .having(
              (error) => error.details?['activeGenerationId'],
              'active generation',
              'g3',
            ),
      ),
    );
  });
}

class RecordingSyncFunctionsClient implements SyncFunctionsCallableClient {
  String? region;
  String? name;
  Map<String, Object?>? data;
  Object? result;
  SyncFunctionsClientException? error;

  @override
  Future<Object?> call({
    required String region,
    required String name,
    required Map<String, Object?> data,
  }) async {
    this.region = region;
    this.name = name;
    this.data = data;
    final currentError = error;
    if (currentError != null) {
      throw currentError;
    }
    return result;
  }
}
