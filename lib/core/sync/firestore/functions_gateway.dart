// ignore: one_member_abstracts
abstract interface class SyncFunctionsGateway {
  Future<void> resetCloudUserData();
}

class FakeSyncFunctionsGateway implements SyncFunctionsGateway {
  int resetCloudUserDataCalls = 0;

  @override
  Future<void> resetCloudUserData() async {
    resetCloudUserDataCalls += 1;
  }
}
