import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pantas/core/storage/data/repos/lesson_bookmarks_repository.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/model/sync_document.dart';

import 'support/firebase_emulator_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Scenario 6 resolves a stale conflict and enforces cross-user '
    'Firestore isolation',
    (tester) async {
      final harnessA = await FirebaseEmulatorHarness.start();
      FirebaseEmulatorHarness? harnessB;
      try {
        const userA = NamedFirebaseEmulatorUser(
          email: 'release-conflict-a@example.test',
          password: 'release-conflict-password-a',
        );
        const userB = NamedFirebaseEmulatorUser(
          email: 'release-conflict-b@example.test',
          password: 'release-conflict-password-b',
        );
        const generationA = 'release-conflict-generation-a';
        const generationB = 'release-conflict-generation-b';
        const lessonId = 'release-conflict-lesson';
        final baselineVersion = DateTime.utc(2026, 1, 3, 1);
        final baselineMarkedAt = DateTime.utc(2026, 1, 3);
        final winningVersion = DateTime.utc(2026, 1, 4, 1);
        final winningMarkedAt = DateTime.utc(2026, 1, 4);

        final uidA = await harnessA.createNamedProUser(userA);
        expect(harnessA.authGateway.currentSession?.uid, uidA);
        expect(await harnessA.claimGateway.refreshProClaim(uid: uidA), isTrue);
        await harnessA.provisionActiveGeneration(
          uid: uidA,
          generationId: generationA,
        );
        await harnessA.seedSyncDocument(
          uid: uidA,
          generationId: generationA,
          collection: 'lesson_bookmarks',
          rowId: lessonId,
          updatedAt: baselineVersion,
          originDeviceId: 'release-baseline-server',
          mutationId: 'release-conflict-baseline',
          deleted: false,
          payload: <String, Object?>{
            'lessonId': lessonId,
            'markedAt': baselineMarkedAt.toIso8601String(),
            'sortIndex': 0,
          },
        );

        final dbA = harnessA.openIsolatedDatabase();
        var engineA = await harnessA.startProductionRuntime(
          db: dbA,
          uid: uidA,
          generationId: generationA,
          deviceId: 'release-conflict-device-a',
        );
        final repoA = LessonBookmarksRepository(dbA);
        try {
          await harnessA.waitUntil(
            () async {
              final base = await harnessA.acceptedBase(
                db: dbA,
                collection: 'lesson_bookmarks',
                rowId: lessonId,
              );
              final rows = await repoA.recentFirst();
              return base?.state == SyncCausalBaseState.knownVersion &&
                  base!.updatedAt!.isAtSameMomentAs(baselineVersion) &&
                  rows.length == 1 &&
                  rows.single.sortIndex == 0;
            },
            description: 'baseline conflict state',
          );

          await engineA.stop();
          await repoA.mark(lessonId);
          final locallyChanged = (await repoA.recentFirst()).single;
          expect(locallyChanged.syncState, 'pending');
          expect(locallyChanged.sortIndex, -1);

          await harnessA.seedSyncDocument(
            uid: uidA,
            generationId: generationA,
            collection: 'lesson_bookmarks',
            rowId: lessonId,
            updatedAt: winningVersion,
            originDeviceId: 'release-winning-server',
            mutationId: 'release-conflict-winner',
            deleted: false,
            payload: <String, Object?>{
              'lessonId': lessonId,
              'markedAt': winningMarkedAt.toIso8601String(),
              'sortIndex': 7,
            },
          );

          engineA = await harnessA.startProductionRuntime(
            db: dbA,
            uid: uidA,
            generationId: generationA,
            deviceId: 'release-conflict-device-a',
          );
          await engineA.forceFlush();
          await harnessA.waitUntil(
            () async {
              final row = (await repoA.recentFirst()).singleOrNull;
              return row != null &&
                  row.sortIndex == 7 &&
                  row.markedAt.isAtSameMomentAs(winningMarkedAt) &&
                  row.syncState == 'synced';
            },
            description: 'production reconciliation winner',
          );

          final cloudPath = harnessA.syncDocumentPath(
            uid: uidA,
            generationId: generationA,
            collection: 'lesson_bookmarks',
            rowId: lessonId,
          );
          final cloud = await harnessA.firestoreGateway.readDocument(cloudPath);
          expect(cloud, isNotNull);
          expect(cloud!.updatedAt, winningVersion);
          expect(cloud.originDeviceId, 'release-winning-server');
          expect(cloud['sortIndex'], 7);
          expect(cloud.mutationId, 'release-conflict-winner');

          await engineA.stop();

          harnessB = await FirebaseEmulatorHarness.start(
            config: harnessA.config,
          );
          final uidB = await harnessB.createNamedProUser(userB);
          expect(uidB, isNot(uidA));
          expect(harnessB.authGateway.currentSession?.uid, uidB);
          expect(
            await harnessB.claimGateway.refreshProClaim(uid: uidB),
            isTrue,
          );
          await harnessB.provisionActiveGeneration(
            uid: uidB,
            generationId: generationB,
          );

          final dbB = harnessB.openIsolatedDatabase();
          final engineB = await harnessB.startProductionRuntime(
            db: dbB,
            uid: uidB,
            generationId: generationB,
            deviceId: 'release-conflict-device-b',
          );
          try {
            final repoB = LessonBookmarksRepository(dbB);
            expect(await repoB.isMarked(lessonId), isFalse);

            final collectionA =
                'users/$uidA/sync_generations/$generationA/lesson_bookmarks';
            await _expectPermissionDenied(
              () async {
                await harnessB!.firestoreGateway.readCollection(collectionA);
              },
            );
            await _expectPermissionDenied(
              () => harnessB!.firestoreGateway.commitBatch(
                <FirestoreWrite>[
                  FirestoreWrite.set(
                    path: cloudPath,
                    merge: false,
                    data: <String, Object?>{
                      'lessonId': lessonId,
                      'markedAt': winningMarkedAt.toIso8601String(),
                      'sortIndex': 99,
                      'updatedAt': FirestoreServerTimestamp.value,
                      'originDeviceId': 'release-cross-user-device',
                      'mutationId': 'release-cross-user-write',
                      'schemaVersion': 1,
                      'deleted': false,
                    },
                  ),
                ],
              ),
            );
            expect(await repoB.isMarked(lessonId), isFalse);
          } finally {
            await engineB.stop();
            await dbB.close();
          }
        } finally {
          await engineA.stop();
          await dbA.close();
        }
      } finally {
        if (harnessB != null) await harnessB.close();
        await harnessA.close();
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<void> _expectPermissionDenied(Future<void> Function() action) async {
  try {
    await action();
    fail('Expected Firestore permission-denied');
  } on FirebaseException catch (error) {
    expect(error.code, 'permission-denied');
  }
}
