// JSON mapping for the server roadmap. Pure Dart: no dart:js_interop, so the
// Dart VM reference run and the compiled JS run use the exact same code.
//
// Time contract: every date in and out is a local calendar value with no
// offset ("2026-09-30" or "2026-09-30T08:00:00"). The engine never calls
// DateTime.now(); the caller passes `today`.
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/data/topic_prerequisites.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

String _two(int v) => v.toString().padLeft(2, '0');

String dayString(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

String stampString(DateTime d) =>
    '${dayString(d)}T${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}';

DateTime _parse(Object? v) => DateTime.parse(v! as String);
DateTime? _parseOpt(Object? v) => v == null ? null : _parse(v);

List<T> _list<T>(Object? v, T Function(Map<String, Object?>) f) =>
    [for (final e in v! as List<Object?>) f(e! as Map<String, Object?>)];

RoadmapInputs inputsFromJson(Map<String, Object?> j) {
  final exam = j['examDate'] as Map<String, Object?>?;
  final mock = j['mock']! as Map<String, Object?>;
  return RoadmapInputs(
    today: _parse(j['today']),
    examId: j['examId']! as String,
    examDate: exam == null
        ? null
        : exam['precision'] == 'month'
            ? ExamDate.inMonth(
                year: exam['year']! as int,
                month: exam['month']! as int,
              )
            : ExamDate.onDay(_parse(exam['day'])),
    topics: _list(
      j['topics'],
      (m) => RoadmapTopic(
        id: m['id']! as String,
        authoredIndex: m['authoredIndex']! as int,
        name: m['name']! as String,
      ),
    ),
    // Left out of the JSON, the links are the app's own list, so the server
    // never holds a second copy.
    prerequisites: j['prerequisites'] == null
        ? topicPrerequisites
        : {
            for (final e
                in (j['prerequisites']! as Map<String, Object?>).entries)
              e.key: [for (final p in e.value! as List<Object?>) p! as String],
          },
    lessons: _list(
      j['lessons'],
      (m) => RoadmapLesson(
        id: m['id']! as String,
        topicId: m['topicId']! as String,
        ordering: m['ordering']! as int,
        readAt: _parseOpt(m['readAt']),
      ),
    ),
    questions: _list(
      j['questions'],
      (m) => RoadmapQuestion(
        id: m['id']! as String,
        topicId: m['topicId']! as String,
        lessonId: m['lessonId'] as String?,
        passageId: m['passageId'] as String?,
      ),
    ),
    seenQuestionIds: {
      for (final s in j['seenQuestionIds']! as List<Object?>) s! as String,
    },
    dueReviews: _list(
      j['dueReviews'],
      (m) => RoadmapReview(
        id: m['id']! as String,
        due: _parse(m['due']),
        retrievability: (m['retrievability']! as num).toDouble(),
      ),
    ),
    scores: {
      for (final e in (j['scores']! as Map<String, Object?>).entries)
        e.key: RoadmapTopicScore(
          id: e.key,
          correct: (e.value! as Map<String, Object?>)['correct']! as int,
          answered: (e.value! as Map<String, Object?>)['answered']! as int,
        ),
    },
    answeredPerActiveDay: [
      for (final n in j['answeredPerActiveDay']! as List<Object?>)
        (n! as num).toInt(),
    ],
    mock: RoadmapMockFacts(
      examHasMock: mock['examHasMock']! as bool,
      proIsActive: mock['proIsActive']! as bool,
      lastSubmittedAt: _parseOpt(mock['lastSubmittedAt']),
    ),
    assessmentCompleted: j['assessmentCompleted']! as bool,
    contentRevision: j['contentRevision']! as String,
    anchoredReviewOnlyFrom: _parseOpt(j['anchoredReviewOnlyFrom']),
    studyDays: StudyDays([
      for (final d in j['studyDays']! as List<Object?>) (d! as num).toInt(),
    ]),
    treatTodayAsStudyDay: j['treatTodayAsStudyDay']! as bool,
  );
}

/// Used only by the fixture generator.
Map<String, Object?> inputsToJson(RoadmapInputs i) => {
      'today': stampString(i.today),
      'examId': i.examId,
      'examDate': i.examDate == null
          ? null
          : i.examDate!.day != null
              ? {'precision': 'day', 'day': dayString(i.examDate!.day!)}
              : {
                  'precision': 'month',
                  'year': i.examDate!.year,
                  'month': i.examDate!.month,
                },
      'topics': [
        for (final t in i.topics)
          {'id': t.id, 'authoredIndex': t.authoredIndex, 'name': t.name},
      ],
      'prerequisites': i.prerequisites,
      'lessons': [
        for (final l in i.lessons)
          {
            'id': l.id,
            'topicId': l.topicId,
            'ordering': l.ordering,
            'readAt': l.readAt == null ? null : stampString(l.readAt!),
          },
      ],
      'questions': [
        for (final q in i.questions)
          {
            'id': q.id,
            'topicId': q.topicId,
            'lessonId': q.lessonId,
            'passageId': q.passageId,
          },
      ],
      'seenQuestionIds': i.seenQuestionIds.toList()..sort(),
      'dueReviews': [
        for (final r in i.dueReviews)
          {
            'id': r.id,
            'due': stampString(r.due),
            'retrievability': r.retrievability,
          },
      ],
      'scores': {
        for (final e in i.scores.entries)
          e.key: {'correct': e.value.correct, 'answered': e.value.answered},
      },
      'answeredPerActiveDay': i.answeredPerActiveDay,
      'mock': {
        'examHasMock': i.mock.examHasMock,
        'proIsActive': i.mock.proIsActive,
        'lastSubmittedAt': i.mock.lastSubmittedAt == null
            ? null
            : stampString(i.mock.lastSubmittedAt!),
      },
      'assessmentCompleted': i.assessmentCompleted,
      'contentRevision': i.contentRevision,
      'anchoredReviewOnlyFrom': i.anchoredReviewOnlyFrom == null
          ? null
          : stampString(i.anchoredReviewOnlyFrom!),
      'studyDays': i.studyDays.weekdays.toList()..sort(),
      'treatTodayAsStudyDay': i.treatTodayAsStudyDay,
    };

String? _d(DateTime? d) => d == null ? null : dayString(d);

Map<String, Object?> roadmapToJson(Roadmap r) => {
      'state': r.state.name,
      'today': {
        'day': dayString(r.today.day),
        'lessonIds': r.today.lessonIds,
        'reviewQuestionIds': r.today.reviewQuestionIds,
        'newQuestionIds': r.today.newQuestionIds,
        'isMockDay': r.today.isMockDay,
        'isRestDay': r.today.isRestDay,
        'advancedIds': r.today.advancedIds.toList()..sort(),
      },
      'examDay': _d(r.examDay),
      'reviewOnlyFrom': _d(r.reviewOnlyFrom),
      'mockDay': _d(r.mockDay),
      'weeksAhead': [
        for (final w in r.weeksAhead)
          {'weekStart': dayString(w.weekStart), 'topicIds': w.topicIds},
      ],
      'topicOrder': r.topicOrder,
      'changes': [
        for (final c in r.changes)
          {
            'cause': c.cause.name,
            'occurredAt': stampString(c.occurredAt),
            'before': c.before?.toJson(),
            'after': c.after?.toJson(),
            'firstTopicsBefore': c.firstTopicsBefore,
            'firstTopicsAfter': c.firstTopicsAfter,
            'advancedCompleted': c.advancedCompleted,
          },
      ],
      'backlogCapped': r.backlogCapped,
      'cycleDetected': r.cycleDetected,
    };
