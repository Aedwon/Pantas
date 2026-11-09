import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_catalog.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';

import '../../../helpers/in_memory_database.dart';

/// Serves the documents the server's upload tool builds from the real
/// `content/` tree, exactly as `getContent` would.
class _DiskRemote implements ContentRemote {
  _DiskRemote(this.dir);
  final Directory dir;

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async {
    final entries = <String, RemoteEntry>{};
    for (final id in ids) {
      final file = File('${dir.path}/${kind.wire}/$id.json');
      entries[id] = file.existsSync()
          ? RemoteEntry.ok(
              version: 'v.f',
              data: (jsonDecode(file.readAsStringSync()) as Map)
                  .cast<String, Object?>(),
            )
          : const RemoteEntry.missing();
    }
    return ContentFetch(tier: 'free', entries: entries);
  }
}

bool _have(String tool) => Process.runSync('which', [tool]).exitCode == 0;

void main() {
  late Directory out;
  String? skip;

  setUpAll(() {
    if (!_have('node') || !_have('dart')) {
      skip = 'node and dart are needed to build the server documents';
      return;
    }
    if (!File('functions/lib/contentUpload.js').existsSync()) {
      skip = 'run `npm --prefix functions run build` first';
      return;
    }
    out = Directory.systemTemp.createTempSync('catalog-contract-');
    final result = Process.runSync('node', [
      'tools/upload_content/upload_content.mjs',
      '--skip-invalid',
      '--out-dir',
      out.path,
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
  });

  tearDownAll(() {
    if (skip == null) out.deleteSync(recursive: true);
  });

  test('the Dart parser reads every catalog document the server builds', () {
    if (skip != null) return;
    final catalogDir = Directory('${out.path}/catalog');
    Map<String, Object?> read(String id) =>
        (jsonDecode(File('${catalogDir.path}/$id.json').readAsStringSync())
                as Map)
            .cast<String, Object?>();

    for (final file in catalogDir.listSync().whereType<File>()) {
      expect(
        file.lengthSync(),
        lessThan(1024 * 1024),
        reason: '${file.path} must fit a Firestore document',
      );
    }
    final index = parseCatalogIndex(read('index'));
    expect(index.exams, isNotEmpty);
    expect(index.catalogs, contains('exam_upcat'));
    var sets = 0;
    var lessons = 0;
    for (final examId in index.catalogs) {
      final exam = parseExamCatalog(read(examId));
      expect(exam.id, examId);
      for (final part in exam.parts) {
        final p = parseExamCatalog(read(part));
        sets += p.sets.length;
        lessons += p.lessons.length;
      }
      sets += exam.sets.length;
      lessons += exam.lessons.length;
      for (final set in exam.sets) {
        // Every listed set is a document the server serves, with every
        // listed question in it.
        final served = (jsonDecode(
          File('${out.path}/questions/${set.id}.json').readAsStringSync(),
        ) as Map)
            .cast<String, Object?>();
        final ids = [
          for (final q in served['questions']! as List)
            (q as Map)['id'] as String,
        ];
        expect(ids, containsAll(set.questions.map((q) => q.id)));
        for (final q in set.questions) {
          if (q.passageId != null) {
            final passages = [
              for (final p in served['passages']! as List) (p as Map)['id'],
            ];
            expect(passages, contains(q.passageId), reason: set.id);
          }
        }
      }
    }
    expect(sets, greaterThan(100));
    expect(lessons, greaterThan(100));
  });

  test('the mirror reads the real server documents end to end', () async {
    if (skip != null) return;
    final appDb = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    addTearDown(appDb.close);
    addTearDown(contentDb.close);
    final service = ContentService(
      remote: _DiskRemote(out),
      cache: ContentCache(appDb),
    );
    addTearDown(service.dispose);
    final mirror = ContentMirror(db: contentDb, service: service);
    addTearDown(mirror.dispose);
    await mirror.start();
    await mirror.idle;

    final repo = ContentRepository(contentDb, fetchHook: mirror);
    final topics = await contentDb.select(contentDb.contentTopics).get();
    expect(topics, isNotEmpty);

    // A reading comprehension question comes with its passage.
    final withPassage = await (contentDb.select(contentDb.contentQuestions)
          ..where((q) => q.passageId.isNotNull())
          ..limit(1))
        .getSingle();
    final question = (await repo.questionById(withPassage.id))!;
    expect(question.choices, isNotEmpty);
    final passage = (await repo.passageById(withPassage.passageId!))!;
    expect(passage.body, isNotEmpty);
    expect(passage.wordCount, greaterThan(0));

    // And a lesson comes with a body.
    final lessonRow =
        (await contentDb.select(contentDb.contentLessons).get()).first;
    final lesson = (await repo.lessonById(lessonRow.id))!;
    expect(lesson.bodyJson, isNotEmpty);

    // Every question the catalog lists can be fetched with text.
    final all = (await contentDb.select(contentDb.contentQuestions).get())
        .map((q) => q.id)
        .toList();
    final ready = await mirror.ensureQuestions(all);
    expect(
      ready.length,
      all.length,
      reason: 'ids listed in the catalog but missing from their set: '
          '${all.where((id) => !ready.contains(id)).take(5).toList()}',
    );
  });

  test('the custom picker offers only what holds a question on the server',
      () async {
    if (skip != null) return;
    Map<String, Object?> read(String id) => (jsonDecode(
          File('${out.path}/catalog/$id.json').readAsStringSync(),
        ) as Map)
            .cast<String, Object?>();

    // The topics of every set that carries a question, from the same
    // documents the server builds a custom exam's corpus from.
    final served = <String>{};
    void addSets(ExamCatalog catalog) {
      for (final set in catalog.sets) {
        if (set.questions.isNotEmpty) served.add(set.topicId);
      }
    }

    for (final examId in parseCatalogIndex(read('index')).catalogs) {
      final exam = parseExamCatalog(read(examId));
      addSets(exam);
      exam.parts.map((part) => parseExamCatalog(read(part))).forEach(addSets);
    }

    final appDb = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    addTearDown(appDb.close);
    addTearDown(contentDb.close);
    final service = ContentService(
      remote: _DiskRemote(out),
      cache: ContentCache(appDb),
    );
    addTearDown(service.dispose);
    final mirror = ContentMirror(db: contentDb, service: service);
    addTearDown(mirror.dispose);
    await mirror.start();
    await mirror.idle;

    final container = ProviderContainer(
      overrides: [contentDatabaseProvider.overrideWithValue(contentDb)],
    );
    addTearDown(container.dispose);
    final subjects =
        await container.read(corpusSubjectsWithTopicsProvider.future);

    // On the web there is no demo data, so a subject with no question is gone.
    expect(subjects.keys.toSet(), {
      'Mathematics',
      'Science',
      'Language Proficiency (English & Filipino)',
      'Reading Comprehension (English & Filipino)',
      'Reasoning',
      'General Information',
    });
    expect(subjects.keys, isNot(contains('Verbal Ability')));
    final offered = {for (final topics in subjects.values) ...topics};
    expect(offered, isNotEmpty);
    final counts = await ContentRepository(contentDb)
        .activeQuestionCountsByTopics(offered);
    for (final topicId in offered) {
      expect(counts[topicId], greaterThan(0), reason: topicId);
      expect(served, contains(topicId), reason: topicId);
    }

    // What's Included lists the same ground, one id for each topic name.
    for (final topic in await corpusTopics(ContentRepository(contentDb))) {
      expect(served, contains(topic.id), reason: topic.id);
    }
  });
}
