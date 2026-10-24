import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/remote/content_catalog.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/content/remote/lesson_markdown.dart';
import 'package:pantas/core/content/repos/content_fetch_hook.dart';

/// How long the first start waits for a catalog when none is cached.
const firstCatalogWait = Duration(seconds: 10);

/// Keeps an in-memory [ContentDatabase] in step with the server content, so
/// every repository on web reads the tables it reads on native.
///
/// Three sources fill it: the catalog (structure, no text), items from the
/// cache in the study database at start, and each [ContentService.changes]
/// event. Lesson bodies and question text arrive when a repository first asks
/// for them through the [ContentFetchHook]. Rows are upserted, so a catalog
/// refresh never erases fetched text, and a Free downgrade (which the service
/// announces as a changed item) strips the Pro notes here as well.
class ContentMirror implements ContentFetchHook {
  ContentMirror({required ContentDatabase db, required ContentService service})
      : _db = db,
        _service = service;

  final ContentDatabase _db;
  final ContentService _service;

  /// `kind/id` to the version last applied, so an event for a copy already
  /// in memory costs nothing.
  final _applied = <String, String>{};
  final _lessonsReady = <String>{};
  final _questionsReady = <String>{};
  final _lessonsInCatalog = <String>{};
  final _setOfQuestion = <String, String>{};
  final _setOfPassage = <String, String>{};
  final _passagesReady = <String>{};
  final _revalidated = <String>{};
  final _background = <Future<void>>{};
  Future<void> _queue = Future.value();
  StreamSubscription<ContentItem>? _subscription;
  Future<void>? _refreshing;

  /// Fills the database from the cache in the study database and refreshes the
  /// catalog. With a cached catalog this completes at once and the refresh
  /// runs in the background; with none, it waits up to [firstCatalogWait] for
  /// the first.
  Future<void> start() async {
    _subscription ??= _service.changes.listen(_enqueue);
    // Catalog documents first, so a question set finds its index rows.
    final items = await _service.storedItems()
      ..sort((a, b) => _order(a).compareTo(_order(b)));
    for (final item in items) {
      await _enqueue(item);
    }
    if (_applied.containsKey('catalog/$catalogIndexId')) {
      _track(refreshCatalog());
      return;
    }
    // Nothing is cached: without a catalog no screen has content, so wait for
    // the first one, but not for long when the network is down.
    await refreshCatalog().timeout(firstCatalogWait, onTimeout: () {});
  }

  int _order(ContentItem item) => switch (item.kind) {
        ContentKind.catalog => item.id == catalogIndexId ? 0 : 1,
        ContentKind.lessons => 2,
        ContentKind.questions => 3,
      };

  /// Completes when no refresh, fetch or write is running.
  Future<void> get idle async {
    while (true) {
      final queue = _queue;
      await _service.idle;
      await Future.wait(_background.toList());
      await queue;
      await Future<void>.delayed(Duration.zero);
      if (identical(queue, _queue) && _background.isEmpty && _service.isIdle) {
        return;
      }
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _queue;
  }

  /// Asks the server for the index and every exam catalog it lists.
  Future<void> refreshCatalog() =>
      _refreshing ??= _refreshCatalog().whenComplete(() => _refreshing = null);

  Future<void> _refreshCatalog() async {
    try {
      await _service.refresh(ContentKind.catalog, [catalogIndexId]);
      final index = await _loadStored(ContentKind.catalog, catalogIndexId);
      if (index == null) return;
      final catalogs = parseCatalogIndex(index.data).catalogs;
      if (catalogs.isEmpty) return;
      await _service.refresh(ContentKind.catalog, catalogs);
      final parts = <String>[];
      for (final id in catalogs) {
        final item = await _loadStored(ContentKind.catalog, id);
        if (item != null) parts.addAll(parseExamCatalog(item.data).parts);
      }
      if (parts.isEmpty) return;
      await _service.refresh(ContentKind.catalog, parts);
      for (final id in parts) {
        await _loadStored(ContentKind.catalog, id);
      }
    } on Object catch (error) {
      debugPrint('Catalog refresh failed: $error');
    }
  }

  @override
  Future<bool> ensureLesson(String id) async {
    if (_lessonsReady.contains(id)) {
      _revalidate(ContentKind.lessons, [id]);
      return true;
    }
    // Once the catalog is in memory, an id it does not list does not exist.
    if (_lessonsInCatalog.isNotEmpty && !_lessonsInCatalog.contains(id)) {
      return false;
    }
    await _service.refresh(ContentKind.lessons, [id]);
    await _loadStored(ContentKind.lessons, id);
    _revalidated.add('lessons/$id');
    final ready = _lessonsReady.contains(id);
    if (ready) _track(preloadAfterLesson(id));
    return ready;
  }

  @override
  Future<bool> ensurePassage(String id) async {
    if (_passagesReady.contains(id)) return true;
    // Passage text travels inside the question set that uses it.
    final setId = _setOfPassage[id];
    if (setId == null) return false;
    await _service.refresh(ContentKind.questions, [setId]);
    await _loadStored(ContentKind.questions, setId);
    _revalidated.add('questions/$setId');
    return _passagesReady.contains(id);
  }

  @override
  Future<Set<String>> ensureQuestions(Iterable<String> ids) async {
    final wanted = ids.toSet();
    final missingSets = <String>{
      for (final id in wanted)
        if (!_questionsReady.contains(id) && _setOfQuestion[id] != null)
          _setOfQuestion[id]!,
    };
    if (missingSets.isNotEmpty) {
      await _service.refresh(ContentKind.questions, missingSets.toList());
      for (final setId in missingSets) {
        await _loadStored(ContentKind.questions, setId);
        _revalidated.add('questions/$setId');
      }
    }
    final ready = wanted.where(_questionsReady.contains).toSet();
    _revalidate(
      ContentKind.questions,
      [
        for (final id in ready) _setOfQuestion[id] ?? '',
      ].where((setId) => setId.isNotEmpty),
    );
    return ready;
  }

  /// Fetches the next [count] lessons of [openedId]'s topic that are not
  /// stored yet, in the topic's lesson order unless [ordered] says otherwise.
  Future<void> preloadAfterLesson(
    String openedId, {
    List<String>? ordered,
    int count = 3,
  }) async {
    var order = ordered;
    if (order == null) {
      final row = await (_db.select(_db.contentLessons)
            ..where((l) => l.id.equals(openedId)))
          .getSingleOrNull();
      if (row == null) return;
      final siblings = await (_db.select(_db.contentLessons)
            ..where((l) => l.topicId.equals(row.topicId))
            ..orderBy([
              (l) => OrderingTerm.asc(l.ordering),
              (l) => OrderingTerm.asc(l.id),
            ]))
          .get();
      order = [for (final lesson in siblings) lesson.id];
    }
    await _service.preloadAfter(
      ContentKind.lessons,
      openedId,
      order,
      count: count,
    );
  }

  /// Asks the server whether an item already in memory has a newer copy,
  /// once per item and session.
  void _revalidate(ContentKind kind, Iterable<String> ids) {
    final fresh = [
      for (final id in ids.toSet())
        if (_revalidated.add('${kind.wire}/$id')) id,
    ];
    if (fresh.isNotEmpty) _track(_service.refresh(kind, fresh));
  }

  Future<ContentItem?> _loadStored(ContentKind kind, String id) async {
    final item = await _service.stored(kind, id);
    if (item != null) await _enqueue(item);
    return item;
  }

  Future<void> _enqueue(ContentItem item) {
    return _queue = _queue.then((_) => _apply(item));
  }

  void _track(Future<void> work) {
    _background.add(work);
    unawaited(work.whenComplete(() => _background.remove(work)));
  }

  Future<void> _apply(ContentItem item) async {
    final key = '${item.kind.wire}/${item.id}';
    if (_applied[key] == item.version) return;
    try {
      await _db.transaction(() async {
        switch (item.kind) {
          case ContentKind.catalog:
            if (item.id == catalogIndexId) {
              await _applyIndex(parseCatalogIndex(item.data));
            } else {
              await _applyExamCatalog(parseExamCatalog(item.data));
            }
          case ContentKind.lessons:
            await _applyLesson(item.id, item.data);
          case ContentKind.questions:
            await _applyQuestionSet(item.id, item.data);
        }
      });
      _applied[key] = item.version;
    } on Object catch (error) {
      // One bad document must not stop the rest from loading.
      debugPrint('Content item $key not applied: $error');
    }
  }

  Future<void> _applyIndex(CatalogIndex index) async {
    await _db.batch((batch) {
      batch
        ..insertAllOnConflictUpdate(_db.contentExams, index.exams)
        ..insertAllOnConflictUpdate(_db.contentSubjects, index.subjects)
        ..insertAllOnConflictUpdate(_db.contentTopics, index.topics);
    });
  }

  Future<void> _applyExamCatalog(ExamCatalog catalog) async {
    final now = DateTime.now().toUtc();
    final lessonRows = [
      for (final lesson in catalog.lessons)
        ContentLessonsCompanion.insert(
          id: lesson.id,
          schemaVersion: 1,
          isActive: Value(lesson.isActive),
          updatedAt: now,
          topicId: lesson.topicId,
          subtopicId: Value(lesson.subtopicId),
          title: lesson.title,
          summary: lesson.summary,
          estimatedMinutes: lesson.estimatedMinutes,
          ordering: Value(lesson.ordering),
          // Replaced when the body is fetched; an upsert here never touches it.
          bodyJson: '[]',
        ),
    ];
    final questionRows = <ContentQuestionsCompanion>[];
    final examLinks = <ContentQuestionExamsCompanion>[];
    for (final set in catalog.sets) {
      for (final question in set.questions) {
        questionRows.add(
          ContentQuestionsCompanion.insert(
            id: question.id,
            schemaVersion: 1,
            updatedAt: now,
            topicId: set.topicId,
            subtopicId: Value(set.subtopicId),
            language: set.language,
            // Replaced when the set is fetched; an upsert here never touches
            // them. Quiz planning only needs to know whether a figure exists.
            stemJson: '[]',
            explanationJson: '[]',
            version: 1,
            lessonId: Value(set.lessonId),
            passageId: Value(question.passageId),
            figureSpecJson: Value(question.hasFigure ? '{}' : null),
          ),
        );
        for (final examId in set.examIds) {
          examLinks.add(
            ContentQuestionExamsCompanion.insert(
              questionId: question.id,
              examId: examId,
            ),
          );
        }
        _setOfQuestion[question.id] = set.id;
        final passageId = question.passageId;
        if (passageId != null) _setOfPassage[passageId] = set.id;
      }
    }
    await _db.batch((batch) {
      batch
        ..insertAllOnConflictUpdate(_db.contentSubjects, catalog.subjects)
        ..insertAllOnConflictUpdate(_db.contentTopics, catalog.topics)
        ..insertAllOnConflictUpdate(
          _db.contentDiagnosticSets,
          catalog.diagnosticSets,
        )
        ..insertAllOnConflictUpdate(
          _db.contentMockBlueprints,
          catalog.mockBlueprints,
        )
        ..insertAll(
          _db.contentLessons,
          lessonRows,
          onConflict:
              DoUpdate<$ContentLessonsTable, ContentLessonRow>.withExcluded(
            (old, excluded) => ContentLessonsCompanion.custom(
              isActive: excluded.isActive,
              updatedAt: excluded.updatedAt,
              topicId: excluded.topicId,
              subtopicId: excluded.subtopicId,
              title: excluded.title,
              summary: excluded.summary,
              estimatedMinutes: excluded.estimatedMinutes,
              ordering: excluded.ordering,
            ),
          ),
        )
        ..insertAll(
          _db.contentQuestions,
          questionRows,
          onConflict:
              DoUpdate<$ContentQuestionsTable, ContentQuestionRow>.withExcluded(
            (old, excluded) => ContentQuestionsCompanion.custom(
              updatedAt: excluded.updatedAt,
              topicId: excluded.topicId,
              subtopicId: excluded.subtopicId,
              language: excluded.language,
              lessonId: excluded.lessonId,
              passageId: excluded.passageId,
            ),
          ),
        )
        ..insertAll(
          _db.contentQuestionExams,
          examLinks,
          mode: InsertMode.insertOrIgnore,
        );
    });
    _lessonsInCatalog.addAll(catalog.lessons.map((l) => l.id));
  }

  Future<void> _applyLesson(String id, Map<String, Object?> data) async {
    final topic = '${data['topic']}'.replaceFirst('topic-', '');
    if (data['topic'] == null || topic.isEmpty) {
      throw FormatException('Lesson $id names no topic.');
    }
    final subtopic = id.replaceFirst('lesson-$topic-', '');
    final blocks = lessonBlocksFromMarkdown('${data['body'] ?? ''}');
    await _db.into(_db.contentLessons).insert(
          ContentLessonsCompanion.insert(
            id: id,
            schemaVersion: 1,
            updatedAt: DateTime.now().toUtc(),
            topicId: 'topic_upcat_${topic.replaceAll('-', '_')}',
            subtopicId: Value('subtopic_$subtopic'),
            title: '${data['title']}',
            summary: '${data['summary']}',
            estimatedMinutes: (data['estimatedMinutes'] as num?)?.toInt() ?? 0,
            bodyJson: jsonEncode(blocks),
          ),
          onConflict:
              DoUpdate<$ContentLessonsTable, ContentLessonRow>.withExcluded(
            (old, excluded) => ContentLessonsCompanion.custom(
              updatedAt: excluded.updatedAt,
              title: excluded.title,
              summary: excluded.summary,
              estimatedMinutes: excluded.estimatedMinutes,
              bodyJson: excluded.bodyJson,
            ),
          ),
        );
    _lessonsReady.add(id);
  }

  Future<void> _applyQuestionSet(
    String setId,
    Map<String, Object?> data,
  ) async {
    const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
    final meta = (data['meta']! as Map).cast<String, Object?>();
    final topicSlug = '${meta['topic']}';
    final subtopicSlug = '${meta['subtopic']}';
    final examIds = [
      for (final code in (meta['exams'] as List? ?? const []))
        'exam_${'$code'.replaceAll('-', '_')}',
    ];
    final now = DateTime.now().toUtc();
    final questions = <ContentQuestionsCompanion>[];
    final choices = <ContentChoicesCompanion>[];
    final links = <ContentQuestionExamsCompanion>[];
    final ids = <String>[];
    for (final raw in (data['questions'] as List? ?? const [])) {
      final question = (raw! as Map).cast<String, Object?>();
      final figure = question['figure'];
      final spec = question['figureSpec'];
      // Same rule as the bundled build: a figure not drawn yet is held back.
      if (figure != null && '$figure'.trim().isNotEmpty && spec == null) {
        continue;
      }
      final id = question['id']! as String;
      ids.add(id);
      questions.add(
        ContentQuestionsCompanion.insert(
          id: id,
          schemaVersion: 1,
          updatedAt: now,
          topicId: 'topic_upcat_${topicSlug.replaceAll('-', '_')}',
          subtopicId: Value('subtopic_$subtopicSlug'),
          language: 'en',
          stemJson: _portableText('${question['stem']}'.trim()),
          explanationJson: _portableText('${question['explanation']}'.trim()),
          version: 1,
          lessonId: Value('lesson-$topicSlug-$subtopicSlug'),
          passageId: Value(question['passage'] as String?),
          shortLabel: Value(question['shortLabel'] as String?),
          figureSpecJson: Value(spec == null ? null : jsonEncode(spec)),
        ),
      );
      final served = question['choices'] as List? ?? const [];
      for (var i = 0; i < served.length; i++) {
        final choice = (served[i]! as Map).cast<String, Object?>();
        final note = choice['rationale'];
        choices.add(
          ContentChoicesCompanion.insert(
            id: '${id}_${labels[i].toLowerCase()}',
            schemaVersion: 1,
            updatedAt: now,
            questionId: id,
            label: labels[i],
            textValue: '${choice['text']}'.trim(),
            isCorrect: choice['correct'] == true,
            rationale: Value(note == null ? null : '$note'.trim()),
            ordering: i + 1,
          ),
        );
      }
      for (final examId in examIds) {
        links.add(
          ContentQuestionExamsCompanion.insert(questionId: id, examId: examId),
        );
      }
    }
    final passages = <ContentPassagesCompanion>[
      for (final raw in (data['passages'] as List? ?? const []))
        _passage(
          (raw! as Map).cast<String, Object?>(),
          'topic_upcat_${topicSlug.replaceAll('-', '_')}',
          now,
        ),
    ];
    await (_db.delete(_db.contentChoices)
          ..where((choice) => choice.questionId.isIn(ids)))
        .go();
    await _db.batch((batch) {
      batch
        ..insertAllOnConflictUpdate(_db.contentPassages, passages)
        ..insertAll(
          _db.contentQuestions,
          questions,
          onConflict:
              DoUpdate<$ContentQuestionsTable, ContentQuestionRow>.withExcluded(
            (old, excluded) => ContentQuestionsCompanion.custom(
              updatedAt: excluded.updatedAt,
              topicId: excluded.topicId,
              subtopicId: excluded.subtopicId,
              language: excluded.language,
              stemJson: excluded.stemJson,
              explanationJson: excluded.explanationJson,
              version: excluded.version,
              lessonId: excluded.lessonId,
              passageId: excluded.passageId,
              shortLabel: excluded.shortLabel,
              figureSpecJson: excluded.figureSpecJson,
            ),
          ),
        )
        ..insertAll(
          _db.contentChoices,
          choices,
          mode: InsertMode.insertOrReplace,
        )
        ..insertAll(
          _db.contentQuestionExams,
          links,
          mode: InsertMode.insertOrIgnore,
        );
    });
    _passagesReady.addAll(passages.map((p) => p.id.value));
    for (final id in ids) {
      _questionsReady.add(id);
      _setOfQuestion[id] = setId;
    }
  }

  ContentPassagesCompanion _passage(
    Map<String, Object?> passage,
    String fallbackTopicId,
    DateTime now,
  ) {
    return ContentPassagesCompanion.insert(
      id: passage['id']! as String,
      schemaVersion: 1,
      updatedAt: now,
      topicId: (passage['topic'] as String?) ?? fallbackTopicId,
      title: '${passage['title']}',
      body: '${passage['body']}',
      language: (passage['language'] as String?) ?? 'en',
      wordCount: (passage['wordCount'] as num?)?.toInt() ?? 0,
    );
  }

  String _portableText(String text) => jsonEncode([
        {
          '_type': 'block',
          'style': 'normal',
          'children': [
            {'_type': 'span', 'text': text, 'marks': <String>[]},
          ],
        },
      ]);
}
