import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/pull_pipeline.dart';

void main() {
  test('incoming row inserts when no local row exists', () {
    expect(
      resolveIncomingChange(
        incomingUpdatedAt: DateTime.utc(2026, 5, 18),
        localUpdatedAt: null,
        isEcho: false,
        hasPendingUpsert: false,
        isDelete: false,
      ),
      SyncApplyAction.upsert,
    );
  });

  test('incoming row with newer updatedAt replaces local row', () {
    expect(
      resolveIncomingChange(
        incomingUpdatedAt: DateTime.utc(2026, 5, 19),
        localUpdatedAt: DateTime.utc(2026, 5, 18),
        isEcho: false,
        hasPendingUpsert: false,
        isDelete: false,
      ),
      SyncApplyAction.upsert,
    );
  });

  test('incoming row with older updatedAt is discarded', () {
    expect(
      resolveIncomingChange(
        incomingUpdatedAt: DateTime.utc(2026, 5, 17),
        localUpdatedAt: DateTime.utc(2026, 5, 18),
        isEcho: false,
        hasPendingUpsert: false,
        isDelete: false,
      ),
      SyncApplyAction.ignore,
    );
  });

  test('own echo updates canonical updatedAt only', () {
    expect(
      resolveIncomingChange(
        incomingUpdatedAt: DateTime.utc(2026, 5, 18),
        localUpdatedAt: DateTime.utc(2026, 5, 18),
        isEcho: true,
        hasPendingUpsert: true,
        isDelete: false,
      ),
      SyncApplyAction.adoptTimestamp,
    );
  });

  test('remote delete is ignored when a pending local upsert exists', () {
    expect(
      resolveIncomingChange(
        incomingUpdatedAt: null,
        localUpdatedAt: DateTime.utc(2026, 5, 18),
        isEcho: false,
        hasPendingUpsert: true,
        isDelete: true,
      ),
      SyncApplyAction.ignore,
    );
  });
}
