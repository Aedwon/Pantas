import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/generation_repository.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:pantas/core/sync/model/sync_generation.dart';

void main() {
  test('missing current pointer reports no active generation', () async {
    final repo = GenerationRepository(
      gateway: FakeFirestoreGateway(),
      functionsGateway: FakeSyncFunctionsGateway(),
      uid: 'user-1',
    );

    expect(await repo.readActiveGenerationId(), isNull);
    expect(await repo.readActiveGeneration(), isNull);
  });

  test('active generation is read from exact pointer and generation paths',
      () async {
    final gateway = FakeFirestoreGateway()
      ..documents['users/user-1/sync_state/current'] = {
        'activeGenerationId': 'gen-1',
        'schemaVersion': 1,
        'updatedAt': DateTime.utc(2026, 8, 30),
      }
      ..documents['users/user-1/sync_generations/gen-1'] = {
        'status': 'active',
        'schemaVersion': 1,
        'createdAt': DateTime.utc(2026, 8, 29),
        'createdByDeviceId': 'device-cloud',
        'preferences': {'reminder_time': '07:30'},
      };
    final repo = GenerationRepository(
      gateway: gateway,
      functionsGateway: FakeSyncFunctionsGateway(),
      uid: 'user-1',
    );

    expect(await repo.readActiveGenerationId(), 'gen-1');
    final generation = await repo.readActiveGeneration();
    expect(generation!.id, 'gen-1');
    expect(generation.status, SyncGenerationStatus.active);
    expect(generation.createdByDeviceId, 'device-cloud');
    expect(generation.preferences, {'reminder_time': '07:30'});
  });

  test('meaningful cloud data uses all ten active generation collections',
      () async {
    const names = [
      'quiz_attempts',
      'assessments',
      'fsrs_cards',
      'lesson_progress',
      'lesson_bookmarks',
      'question_flags',
      'mock_exam_attempts',
      'review_logs',
      'track_scope',
      'custom_blueprints',
    ];

    for (final name in names) {
      final gateway = FakeFirestoreGateway()
        ..collections['users/user-1/sync_generations/gen-1/$name'] = [
          {
            'id': 'row-1',
            'deleted': false,
            'updatedAt': DateTime.utc(2026, 8, 30),
          },
        ];
      final repo = GenerationRepository(
        gateway: gateway,
        functionsGateway: FakeSyncFunctionsGateway(),
        uid: 'user-1',
      );
      expect(
        await repo.hasMeaningfulCloudData('gen-1'),
        isTrue,
        reason: name,
      );
    }
  });

  test('deleted rows and preferences-only generation are not meaningful',
      () async {
    final gateway = FakeFirestoreGateway()
      ..documents['users/user-1/sync_generations/gen-1'] = {
        'status': 'active',
        'schemaVersion': 1,
        'createdAt': DateTime.utc(2026, 8, 29),
        'createdByDeviceId': 'device-cloud',
        'preferences': {'reminder_time': '07:30'},
      }
      ..collections['users/user-1/sync_generations/gen-1/quiz_attempts'] = [
        {
          'id': 'old',
          'deleted': true,
          'updatedAt': DateTime.utc(2026, 8, 30),
        },
      ];
    final repo = GenerationRepository(
      gateway: gateway,
      functionsGateway: FakeSyncFunctionsGateway(),
      uid: 'user-1',
    );

    expect(await repo.hasMeaningfulCloudData('gen-1'), isFalse);
  });

  test('staging generation uses exact root path and server timestamp',
      () async {
    final gateway = FakeFirestoreGateway(
      serverNow: () => DateTime.utc(2026, 8, 30, 1),
    );
    final repo = GenerationRepository(
      gateway: gateway,
      functionsGateway: FakeSyncFunctionsGateway(),
      uid: 'user-1',
    );

    await repo.stageGeneration(
      generationId: 'gen-new',
      deviceId: 'device-1',
      preferences: const {'reminder_time': '08:00'},
    );

    expect(gateway.committedBatches, hasLength(1));
    expect(gateway.committedBatches.single, hasLength(2));
    final limit =
        await gateway.readDocument('users/user-1/limits/syncGeneration');
    expect(limit!['generationId'], 'gen-new');
    expect(limit['lastStagedAt'], DateTime.utc(2026, 8, 30, 1));

    final doc = await gateway.readDocument(
      'users/user-1/sync_generations/gen-new',
    );
    expect(doc, isNotNull);
    expect(doc!['status'], 'staging');
    expect(doc['schemaVersion'], 1);
    expect(doc['createdAt'], DateTime.utc(2026, 8, 30, 1));
    expect(doc['createdByDeviceId'], 'device-1');
    expect(doc['preferences'], {'reminder_time': '08:00'});
  });

  test('activation delegates compare-and-swap expected generation exactly',
      () async {
    final functions = FakeSyncFunctionsGateway();
    final repo = GenerationRepository(
      gateway: FakeFirestoreGateway(),
      functionsGateway: functions,
      uid: 'user-1',
    );

    await repo.activateGeneration(
      generationId: 'gen-new',
      expectedActiveGenerationId: 'gen-old',
    );

    expect(functions.activationCalls, hasLength(1));
    expect(functions.activationCalls.single.generationId, 'gen-new');
    expect(
      functions.activationCalls.single.expectedActiveGenerationId,
      'gen-old',
    );
  });
}
