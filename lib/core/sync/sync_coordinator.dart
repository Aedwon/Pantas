import 'package:pantas/core/sync/bootstrap/full_pull.dart';
import 'package:pantas/core/sync/bootstrap/full_push.dart';

typedef SyncContinuation = bool Function();

abstract interface class SyncCoordinator {
  Future<FullPushResult> keepThisDevice({
    required String uid,
    required String? expectedActiveGenerationId,
    SyncContinuation? shouldContinue,
  });

  Future<FullPullResult> keepMyAccount({
    required String uid,
    required String generationId,
    SyncContinuation? shouldContinue,
  });
}

typedef FullPushRunner = Future<FullPushResult> Function({
  required String uid,
  required String? expectedActiveGenerationId,
  SyncContinuation? shouldContinue,
});

typedef FullPullRunner = Future<FullPullResult> Function({
  required String uid,
  required String generationId,
  SyncContinuation? shouldContinue,
});

class SyncCoordinatorImpl implements SyncCoordinator {
  const SyncCoordinatorImpl({
    required FullPushRunner fullPush,
    required FullPullRunner fullPull,
  })  : _fullPush = fullPush,
        _fullPull = fullPull;

  final FullPushRunner _fullPush;
  final FullPullRunner _fullPull;

  @override
  Future<FullPushResult> keepThisDevice({
    required String uid,
    required String? expectedActiveGenerationId,
    SyncContinuation? shouldContinue,
  }) {
    return _fullPush(
      uid: uid,
      expectedActiveGenerationId: expectedActiveGenerationId,
      shouldContinue: shouldContinue,
    );
  }

  @override
  Future<FullPullResult> keepMyAccount({
    required String uid,
    required String generationId,
    SyncContinuation? shouldContinue,
  }) {
    return _fullPull(
      uid: uid,
      generationId: generationId,
      shouldContinue: shouldContinue,
    );
  }
}
