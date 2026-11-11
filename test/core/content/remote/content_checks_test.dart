import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_checks.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/content_check_store.dart';

class _Remote implements ContentRemote {
  final calls = <List<String>>[];
  String tier = 'free';
  Exception? failWith;
  int version = 1;
  Map<String, Object?> Function(String id, String tier)? data;

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async {
    calls.add(List.of(ids));
    final error = failWith;
    if (error != null) throw error;
    final suffix = tier == 'pro' ? 'p' : 'f';
    return ContentFetch(
      tier: tier,
      entries: {
        for (final id in ids)
          id: knownVersions[id] == 'v$version.$suffix'
              ? RemoteEntry.unchanged(version: 'v$version.$suffix')
              : RemoteEntry.ok(
                  version: 'v$version.$suffix',
                  data: data?.call(id, tier) ?? {'id': id},
                ),
      },
    );
  }
}

void main() {
  late AppDatabase db;
  late _Remote remote;
  late DateTime now;

  ContentService build() => ContentService(
        remote: remote,
        cache: ContentCache(db),
        checks: ContentChecks(store: AppDatabaseCheckStore(db), now: () => now),
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remote = _Remote();
    now = DateTime(2026, 11, 2, 9);
  });
  tearDown(() => db.close());

  test('an item checked today is not asked for again the same local day',
      () async {
    final service = build();
    await service.refresh(ContentKind.lessons, ['a']);
    await service.refresh(ContentKind.lessons, ['a']);
    expect(remote.calls, [
      ['a'],
    ]);
    now = DateTime(2026, 11, 2, 23, 59);
    await service.refresh(ContentKind.lessons, ['a']);
    expect(remote.calls, hasLength(1));
    now = DateTime(2026, 11, 3, 0, 1);
    await service.refresh(ContentKind.lessons, ['a']);
    expect(remote.calls, hasLength(2));
  });

  test('the once-a-day check survives a reload', () async {
    await build().refresh(ContentKind.lessons, ['a', 'b']);
    final reloaded = build();
    await reloaded.refresh(ContentKind.lessons, ['a', 'b', 'c']);
    expect(remote.calls, [
      ['a', 'b'],
      ['c'],
    ]);
  });

  test('a failed request is not recorded as a check', () async {
    final service = build();
    remote.failWith = Exception('offline');
    await service.refresh(ContentKind.lessons, ['a']);
    remote.failWith = null;
    await service.refresh(ContentKind.lessons, ['a']);
    expect(remote.calls, hasLength(2));
  });

  test('a missing local copy is fetched even if it was checked today',
      () async {
    final service = build();
    await service.refresh(ContentKind.lessons, ['a']);
    await db.delete(db.cachedContent).go();
    await service.refresh(ContentKind.lessons, ['a']);
    expect(remote.calls, hasLength(2));
  });

  test('a corrupt local copy that is forgotten is fetched again', () async {
    final service = build();
    await service.refresh(ContentKind.lessons, ['a']);
    await service.forgetCheck(ContentKind.lessons, 'a');
    await service.refresh(ContentKind.lessons, ['a']);
    expect(remote.calls, hasLength(2));
  });

  test('a manual retry (force) fetches even when checked today', () async {
    final service = build();
    await service.refresh(ContentKind.lessons, ['a']);
    await service.refresh(ContentKind.lessons, ['a'], force: true);
    expect(remote.calls, hasLength(2));
  });

  test('a different account fetches at once and the old checks are gone',
      () async {
    final service = build();
    await service.useAccount('u1');
    await service.refresh(ContentKind.lessons, ['a']);
    expect(await service.useAccount('u2'), isTrue);
    await service.refresh(ContentKind.lessons, ['a']);
    expect(remote.calls, hasLength(2));
    // A reload by the same account keeps its checks.
    final reloaded = build();
    expect(await reloaded.useAccount('u2'), isFalse);
    await reloaded.refresh(ContentKind.lessons, ['a']);
    expect(remote.calls, hasLength(2));
  });

  test('signing out clears the checks', () async {
    final service = build();
    await service.useAccount('u1');
    await service.refresh(ContentKind.lessons, ['a']);
    await service.useAccount(null);
    await service.refresh(ContentKind.lessons, ['a']);
    expect(remote.calls, hasLength(2));
  });

  test('buying Pro fetches the Pro notes right away', () async {
    remote.data = (id, tier) => {
          'id': id,
          'questions': [
            {
              'choices': [
                {'text': 'a', if (tier == 'pro') 'rationale': 'why'},
              ],
            },
          ],
        };
    final service = build();
    await service.useAccess('free');
    await service.refresh(ContentKind.questions, ['s1']);
    var item = await service.stored(ContentKind.questions, 's1');
    expect(item!.tier, 'free');

    remote.tier = 'pro';
    expect(await service.useAccess('pro'), isTrue);
    await service.refresh(ContentKind.questions, ['s1']);
    item = await service.stored(ContentKind.questions, 's1');
    expect(item!.tier, 'pro');
    expect(item.version, 'v1.p');
    expect(remote.calls, hasLength(2));
  });

  test('Pro ending fetches at once and the next daily check stays cheap',
      () async {
    final service = build();
    remote.tier = 'pro';
    await service.useAccess('pro');
    await service.refresh(ContentKind.questions, ['s1']);
    remote.tier = 'free';
    expect(await service.useAccess('free'), isTrue);
    await service.refresh(ContentKind.questions, ['s1']);
    expect(remote.calls, hasLength(2));
    final item = await service.stored(ContentKind.questions, 's1');
    expect(item!.tier, 'free');
  });

  test('the same access after a reload does not clear the checks', () async {
    final service = build();
    await service.useAccess('pro');
    await service.refresh(ContentKind.lessons, ['a']);
    final reloaded = build();
    expect(await reloaded.useAccess('pro'), isFalse);
    await reloaded.refresh(ContentKind.lessons, ['a']);
    expect(remote.calls, hasLength(1));
  });

  test('a daily limit answer sets the flag, stores nothing, and recovers',
      () async {
    final flags = <bool>[];
    final service = ContentService(
      remote: remote,
      cache: ContentCache(db),
      checks: ContentChecks(store: AppDatabaseCheckStore(db), now: () => now),
      onLimitReached: flags.add,
    );
    remote.failWith = const ContentLimitReached();
    await service.refresh(ContentKind.lessons, ['a']);
    expect(flags, [true]);
    expect(await service.stored(ContentKind.lessons, 'a'), isNull);
    remote.failWith = null;
    await service.refresh(ContentKind.lessons, ['a']);
    expect(flags, [true, false]);
    expect(await service.stored(ContentKind.lessons, 'a'), isNotNull);
  });

  test('a limited entry is not stored or recorded as checked', () async {
    final flags = <bool>[];
    final limited = _LimitedRemote();
    final service = ContentService(
      remote: limited,
      cache: ContentCache(db),
      checks: ContentChecks(store: AppDatabaseCheckStore(db), now: () => now),
      onLimitReached: flags.add,
    );
    await service.refresh(ContentKind.lessons, ['a']);
    expect(await service.stored(ContentKind.lessons, 'a'), isNull);
    await service.refresh(ContentKind.lessons, ['a']);
    expect(limited.calls, 2);
    expect(flags, [true, true]);
  });
}

class _LimitedRemote implements ContentRemote {
  int calls = 0;
  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async {
    calls++;
    return ContentFetch(
      tier: 'free',
      entries: {for (final id in ids) id: const RemoteEntry.limited()},
    );
  }
}
