import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';

import '../../../helpers/in_memory_database.dart';

const _stamp = '2026-01-01T00:00:00.000Z';
const _original = 'lesson-data-interpretation-tables-and-charts';
const _parts = [
  'lesson-data-interpretation-table-values-and-totals',
  'lesson-data-interpretation-chart-scales-and-differences',
  'lesson-data-interpretation-averages-and-pie-chart-shares',
];
const _topic = 'topic_upcat_data_interpretation';

Map<String, Object?> _doc(String id, Map<String, Object?> fields) => {
      '_id': id,
      '_updatedAt': _stamp,
      'schemaVersion': 1,
      'isActive': true,
      ...fields,
    };

class _Remote implements ContentRemote {
  final docs = <String, Map<String, Object?>>{};

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async =>
      ContentFetch(
        tier: 'free',
        entries: {
          for (final id in ids)
            id: docs.containsKey('${kind.wire}/$id')
                ? RemoteEntry.ok(
                    version: 'v1.f',
                    data: docs['${kind.wire}/$id'] ?? const {},
                  )
                : const RemoteEntry.missing(),
        },
      );
}

/// The catalog as the web mirror receives it after the split: the original is
/// retired and the parts are active, each with its own questions.
Map<String, Object?> _splitCatalog() => {
      'id': 'exam_upcat',
      'lessons': [
        {
          'id': _original,
          'topic': _topic,
          'title': 'Tables and charts',
          'summary': 'Original.',
          'ordering': 1,
          'status': 'retired',
          'replacedBy': _parts,
        },
        for (var i = 0; i < _parts.length; i++)
          {
            'id': _parts[i],
            'topic': _topic,
            'title': 'Part ${i + 1}',
            'summary': 'Part.',
            'ordering': 2 + i,
            'part': i + 1,
            'partCount': _parts.length,
          },
      ],
      'sets': [
        {
          'id': 'qs-di',
          'topic': _topic,
          'subtopic': 'subtopic_di',
          'lesson': _parts.first,
          'exams': ['exam_upcat'],
          'questions': [
            for (var i = 0; i < _parts.length; i++)
              {'id': 'di-$i', 'lesson': _parts[i], 'keyPoint': 1},
          ],
        },
      ],
    };

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ContentService service;
  late ContentMirror mirror;
  late ProviderContainer container;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    final remote = _Remote()
      ..docs['catalog/index'] = {
        'id': 'index',
        'exams': [
          _doc('exam_upcat', {
            'code': 'UPCAT',
            'name': 'UP College Admission Test',
            'shortName': 'UPCAT',
            'language': 'en',
            'ordering': 1,
          }),
        ],
        'subjects': [
          _doc('subj_upcat_math', {
            'exam': {'_ref': 'exam_upcat'},
            'name': 'Mathematics',
            'ordering': 1,
          }),
        ],
        'topics': [
          _doc(_topic, {
            'subject': {'_ref': 'subj_upcat_math'},
            'name': 'Data Interpretation',
            'ordering': 1,
          }),
        ],
        'catalogs': ['exam_upcat'],
      }
      ..docs['catalog/exam_upcat'] = _splitCatalog();
    service = ContentService(remote: remote, cache: ContentCache(db));
    mirror = ContentMirror(db: contentDb, service: service);
    await mirror.start();
    await mirror.idle;
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('exam_upcat');
    await SyncActiveContextStore(db).clearStable();
  });

  tearDown(() async {
    container.dispose();
    await mirror.dispose();
    await service.dispose();
    await db.close();
    await contentDb.close();
  });

  Future<StudyTopic> topic() async {
    final map = (await container.read(studyMapProvider.future))!;
    return map.subjects.expand((s) => s.topics).single;
  }

  Future<void> markRead(String id) async {
    await container.read(lessonProgressRepositoryProvider).markRead(id);
    container.invalidate(studyMapProvider);
  }

  test('a fresh account sees nothing read', () async {
    final t = await topic();
    expect(t.lessons.map((l) => l.id), _parts);
    expect(t.lessons.any((l) => l.isRead), isFalse);
    expect(t.readCount, 0);
    for (final id in _parts) {
      final context = await container.read(readerContextProvider(id).future);
      expect(context!.isRead, isFalse);
    }
  });

  test('reads stored on the original credit every part on every surface',
      () async {
    await markRead(_original);

    final t = await topic();
    // The study list rows, and so the contents sheet and search rows.
    expect(t.lessons.map((l) => l.isRead), [true, true, true]);
    // The topic progress arc.
    expect(t.readCount, 3);
    expect(t.totalCount, 3);
    // Each part's lesson end.
    for (final id in _parts) {
      final context = await container.read(readerContextProvider(id).future);
      expect(context!.isRead, isTrue, reason: id);
    }
    final progress = container.read(lessonProgressRepositoryProvider);
    expect(await progress.readLessonIds(), _parts.toSet());
    final partRead =
        await container.read(isLessonReadProvider(_parts[1]).future);
    expect(partRead, isTrue);
    expect(await container.read(readCountForTopicProvider(_topic).future), 3);
  });

  test('a part read directly counts only itself and moves the arc', () async {
    await markRead(_parts[1]);

    var t = await topic();
    expect(t.lessons.map((l) => l.isRead), [false, true, false]);
    expect(t.readCount, 1);

    await markRead(_parts[2]);
    t = await topic();
    expect(t.readCount, 2);
  });

  test('reading a part moves the arc when the original was read too', () async {
    // A part is credited by the original; reading the rest still adds nothing
    // wrong, and an uncredited topic moves on each new part read.
    await markRead(_parts[0]);
    expect((await topic()).readCount, 1);
    await markRead(_parts[2]);
    expect((await topic()).readCount, 2);
  });
}
