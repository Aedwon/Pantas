import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pantas/core/storage/data/repos/lesson_bookmarks_repository.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';

import 'support/firebase_emulator_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Scenario 5 syncs meaningful local state and reconstructs it '
    'in an isolated database',
    (tester) async {
      final harness = await FirebaseEmulatorHarness.start();
      try {
        const user = NamedFirebaseEmulatorUser(
          email: 'release-roundtrip@example.test',
          password: 'release-roundtrip-password',
        );
        const generationId = 'release-roundtrip-generation';
        const lessonId = 'release-roundtrip-lesson';
        final baselineVersion = DateTime.utc(2026, 1, 2, 3, 4, 5);

        final uid = await harness.createNamedProUser(user);
        final session = harness.authGateway.currentSession;
        expect(session, isNotNull);
        expect(session!.uid, uid);
        expect(session.isAnonymous, isFalse);
        expect(await harness.claimGateway.refreshProClaim(uid: uid), isTrue);

        await harness.provisionActiveGeneration(
          uid: uid,
          generationId: generationId,
        );
        await harness.seedSyncDocument(
          uid: uid,
          generationId: generationId,
          collection: 'lesson_bookmarks',
          rowId: lessonId,
          updatedAt: baselineVersion,
          originDeviceId: 'release-setup',
          mutationId: 'release-roundtrip-baseline',
          deleted: true,
        );

        final dbA = harness.openIsolatedDatabase();
        final engineA = await harness.startProductionRuntime(
          db: dbA,
          uid: uid,
          generationId: generationId,
          deviceId: 'release-roundtrip-device-a',
        );
        try {
          final repoA = LessonBookmarksRepository(dbA);
          await harness.waitUntil(
            () async {
              final base = await harness.acceptedBase(
                db: dbA,
                collection: 'lesson_bookmarks',
                rowId: lessonId,
              );
              return base?.state == SyncCausalBaseState.knownVersion &&
                  base!.updatedAt!.isAtSameMomentAs(baselineVersion);
            },
            description: 'baseline tombstone causal version',
          );
          expect(await repoA.isMarked(lessonId), isFalse);

          await repoA.mark(lessonId);
          expect(await repoA.isMarked(lessonId), isTrue);
          await engineA.forceFlush();

          final cloudPath = harness.syncDocumentPath(
            uid: uid,
            generationId: generationId,
            collection: 'lesson_bookmarks',
            rowId: lessonId,
          );
          await harness.waitUntil(
            () async {
              final cloud =
                  await harness.firestoreGateway.readDocument(cloudPath);
              return cloud != null &&
                  !cloud.deleted &&
                  cloud['lessonId'] == lessonId &&
                  cloud.originDeviceId == 'release-roundtrip-device-a' &&
                  cloud.updatedAt != null;
            },
            description: 'production sync upload',
          );

          final cloud = await harness.firestoreGateway.readDocument(cloudPath);
          expect(cloud, isNotNull);
          expect(cloud!.deleted, isFalse);
          expect(cloud['schemaVersion'], 1);
          expect(cloud.mutationId, isNotEmpty);
          expect(cloud.updatedAt, isNotNull);

          await harness.waitUntil(
            () async {
              final rows = await repoA.recentFirst();
              return rows.length == 1 && rows.single.syncState == 'synced';
            },
            description: 'source repository sync settlement',
          );

          final dbB = harness.openIsolatedDatabase();
          final engineB = await harness.startProductionRuntime(
            db: dbB,
            uid: uid,
            generationId: generationId,
            deviceId: 'release-roundtrip-device-b',
          );
          try {
            final repoB = LessonBookmarksRepository(dbB);
            await harness.waitUntil(
              () => repoB.isMarked(lessonId),
              description: 'isolated database pull',
            );
            final sourceRows = await repoA.recentFirst();
            final reconstructedRows = await repoB.recentFirst();
            expect(reconstructedRows, sourceRows);
          } finally {
            await engineB.stop();
            await dbB.close();
          }
        } finally {
          await engineA.stop();
          await dbA.close();
        }
      } finally {
        await harness.close();
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
