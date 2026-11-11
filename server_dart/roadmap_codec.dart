// JSON mapping for the server roadmap. Pure Dart: no dart:js_interop, so the
// Dart VM reference run and the compiled JS run use the exact same code.
//
// Time contract: every date in and out is a local calendar value with no
// offset ("2026-09-30" or "2026-09-30T08:00:00"). The engine never calls
// DateTime.now(); the caller passes `today`.
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/lesson_mastery.dart';
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
    lessonLinks: {
      for (final e
          in (j['lessonLinks'] as Map<String, Object?>? ?? const {}).entries)
        e.key: _list(
          e.value,
          (m) => LessonLink(
            lessonId: m['lesson']! as String,
            strength: LinkStrength.values.byName(m['strength']! as String),
          ),
        ),
    },
    history: _list(
      j['history'] ?? const <Object?>[],
      (m) => QuestionHistory(
        id: m['id']! as String,
        answered: m['answered']! as int,
        recent: (m['recent']! as List<Object?>).cast<bool>(),
        lastWrongChoiceId: m['lastWrongChoiceId'] as String?,
      ),
    ),
    recall: {
      for (final e
          in (j['recall'] as Map<String, Object?>? ?? const {}).entries)
        e.key: (e.value! as num).toDouble(),
    },
    gapTags: (j['gapTags'] as Map<String, Object?>? ?? const {})
        .cast<String, String>(),
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
      'lessonLinks': {
        for (final id in i.lessonLinks.keys.toList()..sort())
          id: [
            for (final link in i.lessonLinks[id]!.toList()
              ..sort((a, b) {
                final id = a.lessonId.compareTo(b.lessonId);
                return id != 0
                    ? id
                    : a.strength.index.compareTo(b.strength.index);
              }))
              {'lesson': link.lessonId, 'strength': link.strength.name},
          ],
      },
      'history': [
        for (final row
            in i.history.toList()..sort((a, b) => a.id.compareTo(b.id)))
          {
            'id': row.id,
            'answered': row.answered,
            'recent': row.recent,
            if (row.lastWrongChoiceId != null)
              'lastWrongChoiceId': row.lastWrongChoiceId,
          },
      ],
      'recall': {
        for (final id in i.recall.keys.toList()..sort()) id: i.recall[id],
      },
      'gapTags': {
        for (final id in i.gapTags.keys.toList()..sort()) id: i.gapTags[id],
      },
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
        for (final id in i.scores.keys.toList()..sort())
          id: {
            'correct': i.scores[id]!.correct,
            'answered': i.scores[id]!.answered,
          },
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
        if (r.today.reasons.isNotEmpty)
          'reasons': reasonsToJson(r.today.reasons),
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

Map<String, Object?> reasonsToJson(Map<String, PlanReason> reasons) => {
      for (final id in reasons.keys.toList()..sort())
        id: {
          'kind': reasons[id]!.kind.name,
          if (reasons[id]!.forLessonId != null)
            'forLesson': reasons[id]!.forLessonId,
        },
    };
