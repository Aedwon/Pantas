import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';

import '../../../helpers/in_memory_database.dart';
import 'web_stale_catalog_test.dart'
    show StaleRemote, newCatalog, splitQuestionSet, staleCatalog, staleIndex;

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late StaleRemote remote;
  late DateTime clock;
  late ContentService service;
  late ContentMirror mirror;

  ContentMirror newMirror() => ContentMirror(
        db: contentDb,
        service: service,
        now: () => clock,
      );

  setUp(() async {
    clock = DateTime.utc(2026, 11, 15, 8);
    appDb = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    remote = StaleRemote()
      ..docs['catalog/index'] = staleIndex()
      ..docs['catalog/exam_upcat'] = staleCatalog()
      ..versions['catalog/exam_upcat'] = 'old.f'
      ..docs['questions/qs-di'] = splitQuestionSet();
    service = ContentService(remote: remote, cache: ContentCache(appDb));
    // A first run caches the stale catalog, like a tester's earlier visit.
    final first = newMirror();
    await first.start();
    await first.idle;
    await first.dispose();
    remote.catalogAsks.clear();
    mirror = newMirror();
  });

  tearDown(() async {
    await mirror.dispose();
    await service.dispose();
    await appDb.close();
    await contentDb.close();
  });

  Future<String> originalStatus() async => (await (contentDb
              .select(contentDb.contentLessons)
            ..where((l) => l.id.equals('lesson-data-interpretation-averages')))
          .getSingle())
      .status;

  test('app open with a changed server version refreshes the catalog once',
      () async {
    remote
      ..docs['catalog/exam_upcat'] = newCatalog()
      ..versions['catalog/exam_upcat'] = 'new.f';
    await mirror.start();
    await mirror.idle;
    expect(remote.catalogAsks.where((id) => id == 'exam_upcat'), hasLength(1));
    expect(await originalStatus(), 'retired');
  });

  test('app open with an unchanged version applies nothing new', () async {
    await mirror.start();
    await mirror.idle;
    expect(await originalStatus(), 'active');
    // The cached copy is current, so a later safe point finds no change.
    clock = clock.add(contentVersionCheckInterval);
    expect(await mirror.checkContentVersion(), isFalse);
  });

  test('a safe point after the interval picks up a changed version once',
      () async {
    await mirror.start();
    await mirror.idle;
    remote
      ..docs['catalog/exam_upcat'] = newCatalog()
      ..versions['catalog/exam_upcat'] = 'new.f';
    // Inside the interval the safe point does not ask the server.
    remote.catalogAsks.clear();
    clock = clock.add(contentVersionCheckInterval ~/ 2);
    expect(await mirror.checkContentVersion(), isFalse);
    expect(remote.catalogAsks, isEmpty);
    expect(await originalStatus(), 'active');
    clock = clock.add(contentVersionCheckInterval);
    expect(await mirror.checkContentVersion(), isTrue);
    expect(await originalStatus(), 'retired');
    // The same version again is not a change.
    clock = clock.add(contentVersionCheckInterval);
    expect(await mirror.checkContentVersion(), isFalse);
  });
}
