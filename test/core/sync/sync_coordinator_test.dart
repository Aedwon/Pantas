import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/bootstrap/full_pull.dart';
import 'package:pantas/core/sync/bootstrap/full_push.dart';
import 'package:pantas/core/sync/sync_coordinator.dart';

void main() {
  test('keepThisDevice delegates UID and expected generation', () async {
    String? seenUid;
    String? seenExpected;
    final coordinator = SyncCoordinatorImpl(
      fullPush: ({
        required uid,
        required expectedActiveGenerationId,
        shouldContinue,
      }) async {
        seenUid = uid;
        seenExpected = expectedActiveGenerationId;
        return const FullPushResult(
          outcome: FullPushOutcome.activated,
          generationId: 'gen-new',
        );
      },
      fullPull: ({required uid, required generationId, shouldContinue}) async =>
          const FullPullResult(FullPullOutcome.applied),
    );

    final result = await coordinator.keepThisDevice(
      uid: 'user-1',
      expectedActiveGenerationId: 'gen-old',
    );

    expect(seenUid, 'user-1');
    expect(seenExpected, 'gen-old');
    expect(result.generationId, 'gen-new');
  });

  test('keepMyAccount delegates UID and generation', () async {
    String? seenUid;
    String? seenGeneration;
    final coordinator = SyncCoordinatorImpl(
      fullPush: ({
        required uid,
        required expectedActiveGenerationId,
        shouldContinue,
      }) async =>
          const FullPushResult(
        outcome: FullPushOutcome.activated,
        generationId: 'unused',
      ),
      fullPull: ({required uid, required generationId, shouldContinue}) async {
        seenUid = uid;
        seenGeneration = generationId;
        return const FullPullResult(FullPullOutcome.applied);
      },
    );

    final result = await coordinator.keepMyAccount(
      uid: 'user-1',
      generationId: 'gen-cloud',
    );

    expect(seenUid, 'user-1');
    expect(seenGeneration, 'gen-cloud');
    expect(result.outcome, FullPullOutcome.applied);
  });
}
