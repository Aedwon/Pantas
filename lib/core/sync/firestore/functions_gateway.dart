class SyncGenerationActivationCall {
  const SyncGenerationActivationCall({
    required this.generationId,
    required this.expectedActiveGenerationId,
  });

  final String generationId;
  final String? expectedActiveGenerationId;
}

// ignore: one_member_abstracts
abstract interface class SyncFunctionsGateway {
  Future<void> activateGeneration({
    required String generationId,
    required String? expectedActiveGenerationId,
  });
}

class FakeSyncFunctionsGateway implements SyncFunctionsGateway {
  final activationCalls = <SyncGenerationActivationCall>[];

  @override
  Future<void> activateGeneration({
    required String generationId,
    required String? expectedActiveGenerationId,
  }) async {
    activationCalls.add(
      SyncGenerationActivationCall(
        generationId: generationId,
        expectedActiveGenerationId: expectedActiveGenerationId,
      ),
    );
  }
}
