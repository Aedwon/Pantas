import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';

class FakeRemote implements ContentRemote {
  FakeRemote(this.respond);

  final ContentFetch Function(
    ContentKind kind,
    List<String> ids,
    Map<String, String> known,
  ) respond;
  final calls = <List<String>>[];
  Completer<void>? gate;

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async {
    calls.add(List.of(ids));
    final pending = gate;
    if (pending != null) await pending.future;
    return respond(kind, ids, knownVersions);
  }
}

ContentFetch ok(
  String tier,
  String version,
  String id, [
  Map<String, Object?>? extra,
]) =>
    ContentFetch(
      tier: tier,
      entries: {
        id: RemoteEntry.ok(version: version, data: {'id': id, ...?extra}),
      },
    );

Map<String, Object?> set(String id, {String? note}) => {
      'id': id,
      'meta': {'topic': 't'},
      'questions': [
        {
          'id': 'q1',
          'choices': [
            {'text': 'a', 'correct': true, if (note != null) 'rationale': note},
            {'text': 'b'},
          ],
        },
      ],
    };

Map<String, Object?> firstChoice(ContentItem? item) {
  final question = (item!.data['questions']! as List).first as Map;
  return ((question['choices']! as List).first as Map).cast<String, Object?>();
}

void main() {
  late AppDatabase db;
  late ContentCache cache;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    cache = ContentCache(db);
  });
  tearDown(() => db.close());

  test('returns the cached item first, then updates it and notifies', () async {
    await cache.put(
      const ContentItem(
        kind: ContentKind.lessons,
        id: 'l1',
        version: 'v1.f',
        tier: 'free',
        data: {'id': 'l1', 'title': 'old'},
      ),
    );
    final remote = FakeRemote(
      (k, ids, known) => known['l1'] == 'v2.f'
          ? const ContentFetch(
              tier: 'free',
              entries: {'l1': RemoteEntry.unchanged(version: 'v2.f')},
            )
          : ok('free', 'v2.f', 'l1', {'title': 'new'}),
    );
    final service = ContentService(remote: remote, cache: cache);
    final changes = <ContentItem>[];
    service.changes.listen(changes.add);

    final first = await service.read(ContentKind.lessons, 'l1');
    expect(first!.data['title'], 'old');
    await service.idle;
    expect(remote.calls, [
      ['l1'],
    ]);
    final after = await service.read(ContentKind.lessons, 'l1');
    expect(after!.data['title'], 'new');
    await Future<void>.delayed(Duration.zero);
    expect(changes.map((c) => c.version), ['v2.f']);
  });

  test('sends the cached version and an unchanged answer keeps the cache',
      () async {
    await cache.put(
      const ContentItem(
        kind: ContentKind.lessons,
        id: 'l1',
        version: 'v1.f',
        tier: 'free',
        data: {'id': 'l1', 'title': 'kept'},
      ),
    );
    Map<String, String>? sent;
    final remote = FakeRemote((k, ids, known) {
      sent = known;
      return const ContentFetch(
        tier: 'free',
        entries: {'l1': RemoteEntry.unchanged(version: 'v1.f')},
      );
    });
    final service = ContentService(remote: remote, cache: cache);
    final changes = <ContentItem>[];
    service.changes.listen(changes.add);
    await service.read(ContentKind.lessons, 'l1');
    await service.idle;
    expect(sent, {'l1': 'v1.f'});
    expect((await cache.get(ContentKind.lessons, 'l1'))!.data['title'], 'kept');
    expect(changes, isEmpty);
  });

  test('a missing cache entry waits for the server', () async {
    final remote = FakeRemote((k, ids, known) => ok('free', 'v1.f', 'l9'));
    final service = ContentService(remote: remote, cache: cache);
    final item = await service.read(ContentKind.lessons, 'l9');
    expect(item!.version, 'v1.f');
    expect(await cache.get(ContentKind.lessons, 'l9'), isNotNull);
  });

  test('a failed request leaves the cache alone and does not throw', () async {
    await cache.put(
      const ContentItem(
        kind: ContentKind.lessons,
        id: 'l1',
        version: 'v1.f',
        tier: 'free',
        data: {'id': 'l1'},
      ),
    );
    final remote = FakeRemote((k, ids, known) => throw StateError('offline'));
    final service = ContentService(remote: remote, cache: cache);
    expect(await service.read(ContentKind.lessons, 'l1'), isNotNull);
    await service.idle;
    expect(await service.read(ContentKind.lessons, 'zzz'), isNull);
  });

  test('Pro notes are stored only when the server sends them', () async {
    final remote = FakeRemote(
      (k, ids, known) => ContentFetch(
        tier: 'free',
        entries: {
          's1': RemoteEntry.ok(version: 'v.f', data: set('s1')),
        },
      ),
    );
    final service = ContentService(remote: remote, cache: cache);
    final item = await service.read(ContentKind.questions, 's1');
    expect(firstChoice(item).containsKey('rationale'), isFalse);
  });

  test('sign out removes cached Pro notes and relabels the copy as Free',
      () async {
    final remote = FakeRemote(
      (k, ids, known) => ContentFetch(
        tier: 'pro',
        entries: {
          's1': RemoteEntry.ok(version: 'v.p', data: set('s1', note: 'why')),
        },
      ),
    );
    final service = ContentService(remote: remote, cache: cache);
    final pro = await service.read(ContentKind.questions, 's1');
    expect(
      firstChoice(pro)['rationale'],
      'why',
    );
    await service.onSignedOut();
    final after = await cache.get(ContentKind.questions, 's1');
    expect(after!.tier, 'free');
    expect(after.version, 'v.f');
    expect(
      firstChoice(after).containsKey('rationale'),
      isFalse,
    );
  });

  test('a Free answer after a Pro one clears Pro notes (Pro ended)', () async {
    var tier = 'pro';
    final remote = FakeRemote(
      (k, ids, known) => tier == 'pro'
          ? ContentFetch(
              tier: 'pro',
              entries: {
                's1': RemoteEntry.ok(
                  version: 'v.p',
                  data: set('s1', note: 'why'),
                ),
              },
            )
          : ContentFetch(
              tier: 'free',
              entries: {
                for (final id in ids) id: const RemoteEntry.missing(),
              },
            ),
    );
    final service = ContentService(remote: remote, cache: cache);
    await service.read(ContentKind.questions, 's1');
    tier = 'free';
    await service.refresh(ContentKind.questions, ['other']);
    final after = await cache.get(ContentKind.questions, 's1');
    expect(after!.tier, 'free');
    expect(after.version, 'v.f');
    expect(
      firstChoice(after).containsKey('rationale'),
      isFalse,
    );
  });

  test('refresh splits requests at 20 ids per call', () async {
    final remote = FakeRemote(
      (k, ids, known) => ContentFetch(
        tier: 'free',
        entries: {
          for (final id in ids)
            id: RemoteEntry.ok(version: 'v.f', data: {'id': id}),
        },
      ),
    );
    final service = ContentService(remote: remote, cache: cache);
    final ids = [for (var i = 0; i < 45; i++) 'l$i'];
    await service.refresh(ContentKind.lessons, [...ids, 'l0']);
    expect(remote.calls.map((c) => c.length), [20, 20, 5]);
  });

  test('preload fetches only the next uncached items after the opened one',
      () async {
    final remote = FakeRemote(
      (k, ids, known) => ContentFetch(
        tier: 'free',
        entries: {
          for (final id in ids)
            id: RemoteEntry.ok(version: 'v.f', data: {'id': id}),
        },
      ),
    );
    final service = ContentService(remote: remote, cache: cache);
    await cache.put(
      const ContentItem(
        kind: ContentKind.lessons,
        id: 'b',
        version: 'v.f',
        tier: 'free',
        data: {'id': 'b'},
      ),
    );
    await service.preloadAfter(
      ContentKind.lessons,
      'a',
      ['a', 'b', 'c', 'd', 'e', 'f'],
    );
    expect(remote.calls, [
      ['c', 'd'],
    ]);
  });

  test('preload caps at 20 ids even for a large count', () async {
    final remote = FakeRemote(
      (k, ids, known) => ContentFetch(
        tier: 'free',
        entries: {
          for (final id in ids)
            id: RemoteEntry.ok(version: 'v.f', data: {'id': id}),
        },
      ),
    );
    final service = ContentService(remote: remote, cache: cache);
    final ids = [for (var i = 0; i < 60; i++) 'l$i'];
    await service.preloadAfter(ContentKind.lessons, 'l0', ids, count: 50);
    expect(remote.calls.every((c) => c.length <= 20), isTrue);
  });
}
