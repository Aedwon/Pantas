class SyncGenerationActivationCall {
  const SyncGenerationActivationCall({
    required this.generationId,
    required this.expectedActiveGenerationId,
  });

  final String generationId;
  final String? expectedActiveGenerationId;
}

abstract interface class SyncFunctionsGateway {
  Future<void> activateGeneration({
    required String generationId,
    required String? expectedActiveGenerationId,
  });

  @Deprecated('Legacy placeholder bootstrap compatibility only.')
  Future<void> resetCloudUserData();
}

class FakeSyncFunctionsGateway implements SyncFunctionsGateway {
  int resetCloudUserDataCalls = 0;
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

  @override
  Future<void> resetCloudUserData() async {
    resetCloudUserDataCalls += 1;
  }
}
