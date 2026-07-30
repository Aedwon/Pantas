import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/sync/content_sync_coordinator.dart';
import 'package:pantas/core/content/sync/sync_status.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentDatabase db;
  final now = DateTime.utc(2026, 5, 17, 8);

  setUp(() {
    db = ContentDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('first sync uses full fetchers when lastSyncedAt is missing', () async {
    final fetcher = RecordingFetcher('exam');
    final coordinator = ContentSyncCoordinator(
      db: db,
      fetchers: [fetcher],
      now: () => now,
    );

    await coordinator.refreshNow();

    expect(fetcher.fullCalls, equals(1));
    expect(fetcher.deltaCalls, equals(0));
  });

  test('subsequent sync uses delta fetchers with lastSyncedAt', () async {
    await db.into(db.contentMeta).insert(
          ContentMetaCompanion.insert(
            key: ContentSyncCoordinator.lastSyncedAtKey,
            value: '2026-05-17T00:00:00.000Z',
          ),
        );
    final fetcher = RecordingFetcher('exam');
    final coordinator = ContentSyncCoordinator(
      db: db,
      fetchers: [fetcher],
      now: () => now,
    );

    await coordinator.refreshNow();

    expect(fetcher.fullCalls, equals(0));
    expect(fetcher.deltaCalls, equals(1));
    expect(fetcher.lastSince, equals(DateTime.utc(2026, 5, 17)));
  });

  test('one doctype failure emits partialFailure and leaves prior rows',
      () async {
    await db.into(db.contentMeta).insert(
          ContentMetaCompanion.insert(key: 'prior', value: 'kept'),
        );
    final coordinator = ContentSyncCoordinator(
      db: db,
      fetchers: [
        RecordingFetcher('exam'),
        RecordingFetcher('question', result: ContentFetchResult.failure),
      ],
      now: () => now,
    );

    final status = await coordinator.refreshNow();

    expect(status, isA<SyncPartialFailure>());
    expect((status as SyncPartialFailure).failedDoctypes, ['question']);
    expect(
      await (db.select(db.contentMeta)..where((row) => row.key.equals('prior')))
          .getSingleOrNull(),
      isNotNull,
    );
  });

  test('all doctypes failing emits failure', () async {
    final coordinator = ContentSyncCoordinator(
      db: db,
      fetchers: [RecordingFetcher('exam', result: ContentFetchResult.failure)],
      now: () => now,
    );

    expect(await coordinator.refreshNow(), isA<SyncFailure>());
  });

  test('refreshNow bypasses throttle', () async {
    await db.into(db.contentMeta).insert(
          ContentMetaCompanion.insert(
            key: ContentSyncCoordinator.lastSyncedAtKey,
            value: now.subtract(const Duration(hours: 1)).toIso8601String(),
          ),
        );
    final fetcher = RecordingFetcher('exam');
    final coordinator = ContentSyncCoordinator(
      db: db,
      fetchers: [fetcher],
      now: () => now,
    );

    await coordinator.refreshNow();

    expect(fetcher.deltaCalls, equals(1));
  });

  test('syncIfStale no-ops inside throttle window', () async {
    await db.into(db.contentMeta).insert(
          ContentMetaCompanion.insert(
            key: ContentSyncCoordinator.lastSyncedAtKey,
            value: now.subtract(const Duration(hours: 1)).toIso8601String(),
          ),
        );
    final fetcher = RecordingFetcher('exam');
    final coordinator = ContentSyncCoordinator(
      db: db,
      fetchers: [fetcher],
      now: () => now,
    );

    final status = await coordinator.syncIfStale();

    expect(status, isA<SyncIdle>());
    expect(fetcher.fullCalls + fetcher.deltaCalls, equals(0));
  });

  test('concurrent sync calls share one in-flight future', () async {
    final fetcher =
        RecordingFetcher('exam', delay: const Duration(milliseconds: 5));
    final coordinator = ContentSyncCoordinator(
      db: db,
      fetchers: [fetcher],
      now: () => now,
    );

    final first = coordinator.refreshNow();
    final second = coordinator.refreshNow();

    expect(identical(first, second), isTrue);
    await first;
    expect(fetcher.fullCalls, equals(1));
  });
}

class RecordingFetcher implements ContentDoctypeFetcher {
  RecordingFetcher(
    this.doctype, {
    this.result = ContentFetchResult.success,
    this.delay = Duration.zero,
  });

  @override
  final String doctype;
  final ContentFetchResult result;
  final Duration delay;
  int fullCalls = 0;
  int deltaCalls = 0;
  DateTime? lastSince;

  @override
  Future<ContentFetchResult> fetchFull() async {
    fullCalls++;
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    return result;
  }

  @override
  Future<ContentFetchResult> fetchDelta(DateTime since) async {
    deltaCalls++;
    lastSince = since;
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    return result;
  }
}
