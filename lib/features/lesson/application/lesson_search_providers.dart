import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/domain/portable_text_plain.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    FutureProvider<List<LessonSearchHit>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return const [];

  final map = await ref.watch(studyMapProvider.future);
  if (map == null) return const [];

  // Corpus order, and the topic name every row prints, from the map the
  // screen behind is already holding.
  final topicNameByLessonId = <LessonId, String>{};
  final positionByLessonId = <LessonId, int>{};
  final topicIds = <TopicId>[];
  var position = 0;
  for (final subject in map.subjects) {
    for (final topic in subject.topics) {
      topicIds.add(topic.id);
      for (final lesson in topic.lessons) {
        topicNameByLessonId[lesson.id] = topic.name;
        positionByLessonId[lesson.id] = position++;
      }
    }
  }

  final rows = await ref
      .watch(contentRepositoryProvider)
      .searchLessonRows(topicIds: topicIds, query: query);

  final hits = <LessonSearchHit>[];
  for (final row in rows) {
    final titleMatch = buildSearchSnippet(source: row.title, query: query);
    final summaryMatch = buildSearchSnippet(source: row.summary, query: query);

    SearchSnippet? bodySnippet;
    if (titleMatch == null) {
      final plain = portableTextToPlain(
        List<Map<String, dynamic>>.from(jsonDecode(row.bodyJson) as List),
      );
      bodySnippet =
          buildSearchSnippet(source: plain, query: query) ?? summaryMatch;
    }

    // The SQL scan can hit a JSON key or a mark name. If neither the title,
    // the summary nor the flattened body contains the query, it did not
    // match anything a student can see.
    if (titleMatch == null && bodySnippet == null) continue;

    hits.add(
      LessonSearchHit(
        lessonId: row.id,
        title: row.title,
        topicName: topicNameByLessonId[row.id] ?? '',
        estimatedMinutes: row.estimatedMinutes,
        titleMatch: titleMatch,
        bodySnippet: bodySnippet,
      ),
    );
  }

  final matchedTopicIds = <TopicId>[
    for (final subject in map.subjects)
      for (final topic in subject.topics)
        if (topic.name.toLowerCase().contains(query.toLowerCase())) topic.id,
  ];
  if (matchedTopicIds.isNotEmpty) {
    final included = hits.map((hit) => hit.lessonId).toSet();
    final lessons = await ref
        .watch(contentRepositoryProvider)
        .lessonsByTopics(matchedTopicIds);
    for (final topicLessons in lessons.values) {
      for (final lesson in topicLessons) {
        if (!included.add(lesson.id)) continue;
        hits.add(LessonSearchHit(
          lessonId: lesson.id,
          title: lesson.title,
          topicName: topicNameByLessonId[lesson.id] ?? '',
          estimatedMinutes: lesson.estimatedMinutes,
        ));
      }
    }
  }

  hits.sort(
    (a, b) => (positionByLessonId[a.lessonId] ?? 0)
        .compareTo(positionByLessonId[b.lessonId] ?? 0),
  );
  return hits;
});

final searchCorpusSizeProvider = FutureProvider<int>((ref) async {
  final map = await ref.watch(studyMapProvider.future);
  return map?.totalCount ?? 0;
});

final recentlyOpenedLessonsProvider =
    FutureProvider<List<StudyLesson>>((ref) async {
  final map = await ref.watch(studyMapProvider.future);
  if (map == null) return const [];

  final focus = await ref.watch(activeExamFocusProvider.future);
  final examId = focus.exam?.id;
  if (examId == null) return const [];

  final ids = await ref
      .watch(appPreferencesRepositoryProvider)
      .recentlyOpenedLessonIds(examId);

  final lessonById = <LessonId, StudyLesson>{};
  for (final subject in map.subjects) {
    for (final topic in subject.topics) {
      for (final lesson in topic.lessons) {
        lessonById[lesson.id] = lesson;
      }
    }
  }

  final result = <StudyLesson>[];
  for (final id in ids) {
    final lesson = lessonById[id];
    if (lesson != null) {
      result.add(lesson);
    }
  }
  return result;
});
