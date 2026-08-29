import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/model/sync_document.dart';

void main() {
  final v1 = DateTime.utc(2026, 8, 29, 10);
  final v2 = DateTime.utc(2026, 8, 29, 11);

  test('known-absent create commits only while cloud remains absent', () async {
    final gateway = FakeFirestoreGateway(serverNow: () => v2);

    final result = await gateway.commitRowIfBaseMatches(
      path: 'users/u/sync_generations/g/quiz_attempts/a',
      base: const SyncCausalBase.knownAbsent(),
      data: {
        'value': 1,
        'updatedAt': FirestoreServerTimestamp.value,
      },
    );

    expect(result, isA<RowCommitted>());
    final committed = (result as RowCommitted).authoritative;
    expect(committed.updatedAt, v2);
    expect(committed.data['value'], 1);

    final stale = await gateway.commitRowIfBaseMatches(
      path: 'users/u/sync_generations/g/quiz_attempts/a',
      base: const SyncCausalBase.knownAbsent(),
      data: {'value': 2},
    );
    expect(stale, isA<RowStale>());
    expect((stale as RowStale).current?.data['value'], 1);
  });

  test('known-version matching update commits and returns authoritative state',
      () async {
    final path = 'users/u/sync_generations/g/fsrs_cards/q';
    final gateway = FakeFirestoreGateway(serverNow: () => v2)
      ..documents[path] = {'updatedAt': v1, 'value': 1};

    final result = await gateway.commitRowIfBaseMatches(
      path: path,
      base: SyncCausalBase.knownVersion(v1),
      data: {
        'value': 2,
        'updatedAt': FirestoreServerTimestamp.value,
      },
    );

    expect(result, isA<RowCommitted>());
    expect((result as RowCommitted).authoritative.updatedAt, v2);
    expect(result.authoritative.data['value'], 2);
  });

  test('stale update/delete returns current cloud state without overwriting it',
      () async {
    final path = 'users/u/sync_generations/g/question_flags/q';
    final gateway = FakeFirestoreGateway()
      ..documents[path] = {'updatedAt': v2, 'deleted': false};

    final update = await gateway.commitRowIfBaseMatches(
      path: path,
      base: SyncCausalBase.knownVersion(v1),
      data: {'deleted': false, 'updatedAt': FirestoreServerTimestamp.value},
    );
    final delete = await gateway.commitRowIfBaseMatches(
      path: path,
      base: SyncCausalBase.knownVersion(v1),
      data: {'deleted': true, 'updatedAt': FirestoreServerTimestamp.value},
    );

    expect(update, isA<RowStale>());
    expect(delete, isA<RowStale>());
    expect((update as RowStale).current?.updatedAt, v2);
    expect((delete as RowStale).current?.data['deleted'], false);
    expect(gateway.documents[path]?['deleted'], false);
  });

  test('known-version against physically missing current row is stale',
      () async {
    final gateway = FakeFirestoreGateway();
    final result = await gateway.commitRowIfBaseMatches(
      path: 'users/u/sync_generations/g/lesson_progress/l',
      base: SyncCausalBase.knownVersion(v1),
      data: {'updatedAt': FirestoreServerTimestamp.value},
    );

    expect(result, isA<RowStale>());
    expect((result as RowStale).current, isNull);
  });

  test('unbound causal state is rejected by conditional commit', () async {
    final gateway = FakeFirestoreGateway();
    expect(
      gateway.commitRowIfBaseMatches(
        path: 'users/u/sync_generations/g/lesson_progress/l',
        base: const SyncCausalBase.unbound(),
        data: const {},
      ),
      throwsA(
        isA<SyncGatewayException>().having(
          (error) => error.code,
          'code',
          'unbound-causal-base',
        ),
      ),
    );
  });

  test('fake functions gateway records certified activation request', () async {
    final gateway = FakeSyncFunctionsGateway();
    await gateway.activateGeneration(
      generationId: 'g2',
      expectedActiveGenerationId: 'g1',
    );

    expect(gateway.activationCalls, hasLength(1));
    expect(gateway.activationCalls.single.generationId, 'g2');
    expect(gateway.activationCalls.single.expectedActiveGenerationId, 'g1');
  });
}
