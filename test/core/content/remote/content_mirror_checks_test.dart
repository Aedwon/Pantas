import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_checks.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';

import '../../../helpers/in_memory_database.dart';

const _stamp = '2026-01-01T00:00:00.000Z';

Map<String, Object?> _doc(String id, Map<String, Object?> f) => {
      '_id': id,
      '_updatedAt': _stamp,
      'schemaVersion': 1,
      'isActive': true,
      ...f,
    };

final _index = <String, Object?>{
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
  'subjects': <Object>[],
  'topics': <Object>[],
  'catalogs': ['exam_upcat'],
};

final _exam = <String, Object?>{
  'id': 'exam_upcat',
  'sets': [
    {
      'id': 'qs-1',
      'topic': 'topic_upcat_biology',
      'subtopic': 'subtopic_cells',
      'exams': ['exam_upcat'],
      'questions': [
        {'id': 'bio-1'},
      ],
    },
  ],
};

Map<String, Object?> _set(String tier) => {
      'id': 'qs-1',
      'meta': {
        'subject': 'science',
        'topic': 'biology',
        'subtopic': 'cells',
        'exams': ['upcat'],
      },
      'questions': [
        {
          'id': 'bio-1',
          'stem': 'S',
          'explanation': 'E',
          'choices': [
            {'text': 'A', 'correct': true},
            {'text': 'B', if (tier == 'pro') 'rationale': 'Why not B.'},
          ],
        },
      ],
    };

class _Remote implements ContentRemote {
  final calls = <String>[];
  String tier = 'free';
  Exception? failWith;

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> known,
  ) async {
    calls.add('${kind.wire}:${ids.join(",")}');
    if (failWith != null) throw failWith!;
    final suffix = tier == 'pro' ? 'p' : 'f';
    final docs = <String, Map<String, Object?>>{
      'catalog/index': _index,
      'catalog/exam_upcat': _exam,
      'questions/qs-1': _set(tier),
    };
    return ContentFetch(
      tier: tier,
      entries: {
        for (final id in ids)
          id: docs.containsKey('${kind.wire}/$id')
              ? (known[id] == 'v1.$suffix'
                  ? RemoteEntry.unchanged(version: 'v1.$suffix')
                  : RemoteEntry.ok(
                      version: 'v1.$suffix',
                      data: docs['${kind.wire}/$id'] ?? const {},
                    ))
              : const RemoteEntry.missing(),
      },
    );
  }
}

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late _Remote remote;
  late List<bool> flags;

  ContentService newService() => ContentService(
        remote: remote,
        cache: ContentCache(appDb),
        checks: ContentChecks(store: DevicePrefsCheckStore(appDb)),
        onLimitReached: flags.add,
      );

  setUp(() {
    appDb = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    remote = _Remote();
    flags = [];
  });
  tearDown(() async {
    await appDb.close();
    await contentDb.close();
  });

  test('a second start the same day makes no catalog request', () async {
    final first = ContentMirror(db: contentDb, service: newService());
    await first.start();
    await first.idle;
    await first.dispose();
    expect(remote.calls, ['catalog:index', 'catalog:exam_upcat']);

    remote.calls.clear();
    final second = ContentMirror(db: contentDb, service: newService());
    await second.start();
    await second.idle;
    await second.dispose();
    expect(remote.calls, isEmpty);
    expect(
      (await contentDb.select(contentDb.contentExams).get()).single.id,
      'exam_upcat',
    );
  });

  test('the daily limit with nothing cached sets the flag and stores nothing',
      () async {
    remote.failWith = const ContentLimitReached();
    final mirror = ContentMirror(db: contentDb, service: newService());
    await mirror.start();
    await mirror.dispose();
    expect(flags, [true]);
    expect(await contentDb.select(contentDb.contentExams).get(), isEmpty);
    expect(await appDb.select(appDb.cachedContent).get(), isEmpty);

    // The next day the same start recovers on its own.
    remote.failWith = null;
    final later = ContentMirror(db: contentDb, service: newService());
    await later.start();
    await later.idle;
    await later.dispose();
    expect(flags.last, isFalse);
    expect(await contentDb.select(contentDb.contentExams).get(), isNotEmpty);
  });

  test('buying Pro brings the Pro notes in at once, without opening the set',
      () async {
    final service = newService();
    final mirror = ContentMirror(db: contentDb, service: service);
    await service.useAccess('free');
    await mirror.start();
    await mirror.idle;
    expect(await mirror.ensureQuestions(['bio-1']), {'bio-1'});
    await mirror.idle;
    var choices = await contentDb.select(contentDb.contentChoices).get();
    expect(choices.every((c) => c.rationale == null), isTrue);

    remote.tier = 'pro';
    remote.calls.clear();
    expect(await service.useAccess('pro'), isTrue);
    await mirror.onAccessChanged();
    await mirror.idle;
    choices = await contentDb.select(contentDb.contentChoices).get();
    expect(choices.map((c) => c.rationale), contains('Why not B.'));
    expect(remote.calls.first, 'questions:qs-1');
    await mirror.dispose();
  });
}
