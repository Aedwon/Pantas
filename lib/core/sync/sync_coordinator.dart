abstract interface class SyncCoordinator {
  Future<void> pushLocalToCloud();

  Future<void> pullCloudToLocal();
}

class SyncCoordinatorImpl implements SyncCoordinator {
  const SyncCoordinatorImpl({
    required Future<void> Function() fullPush,
    required Future<void> Function() fullPull,
  })  : _fullPush = fullPush,
        _fullPull = fullPull;

  final Future<void> Function() _fullPush;
  final Future<void> Function() _fullPull;

  @override
  Future<void> pushLocalToCloud() => _fullPush();

  @override
  Future<void> pullCloudToLocal() => _fullPull();
}
