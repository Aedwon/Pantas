// Writes fixtures/scenarios.json (inputs) deterministically. Run once with
// `dart run server_dart/make_fixtures.dart`.
import 'dart:convert';
import 'dart:io';

import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

import 'roadmap_codec.dart';

String _id(String p, int i) => '$p${i.toString().padLeft(4, '0')}';

RoadmapInputs rich({
  required DateTime today,
  ExamDate? examDate,
  bool noExam = false,
  int topicCount = 6,
  int lessonsPerTopic = 20,
  int questionsPerLesson = 8,
  bool assessed = true,
  Map<String, List<String>>? prerequisites,
  StudyDays studyDays = StudyDays.all,
  DateTime? anchor,
  bool hasMock = true,
  int dueCount = 40,
  bool treatTodayAsStudyDay = false,
}) {
  final topics = [
    for (var t = 0; t < topicCount; t++)
      RoadmapTopic(id: _id('t', t), authoredIndex: t, name: 'Topic $t'),
  ];
  final lessons = <RoadmapLesson>[];
  final questions = <RoadmapQuestion>[];
  final seen = <String>{};
  var order = 0;
  for (var t = 0; t < topicCount; t++) {
    for (var l = 0; l < lessonsPerTopic; l++) {
      final lid = _id('l', t * lessonsPerTopic + l);
      // First third of topic 0 and 1 already read, at varied hours.
      final read = t < 2 && l < lessonsPerTopic ~/ 3;
      lessons.add(
        RoadmapLesson(
          id: lid,
          topicId: _id('t', t),
          ordering: order++,
          readAt: read ? DateTime(2026, 9, 1 + l, 7 + l % 12, 30) : null,
        ),
      );
      for (var q = 0; q < questionsPerLesson; q++) {
        final n = (t * lessonsPerTopic + l) * questionsPerLesson + q;
        final qid = _id('q', n);
        questions.add(
          RoadmapQuestion(
            id: qid,
            topicId: _id('t', t),
            lessonId: q < questionsPerLesson - 2 ? lid : null,
            passageId: q >= questionsPerLesson - 3 && q.isEven
                ? _id('p', n ~/ 3)
                : null,
          ),
        );
        if (read && q < 4) seen.add(qid);
      }
    }
  }
  final seenList = seen.toList()..sort();
  return RoadmapInputs(
    today: today,
    examId: 'exam_upcat',
    examDate:
        noExam ? null : (examDate ?? ExamDate.onDay(DateTime(2026, 12, 7))),
    topics: topics,
    lessonLinks: {
      for (final entry in (prerequisites ??
              {
                _id('t', 1): [_id('t', 0)],
                _id('t', 2): [_id('t', 0), _id('t', 1)],
                _id('t', 4): [_id('t', 3)],
              })
          .entries)
        _id('l', int.parse(entry.key.substring(1)) * lessonsPerTopic): [
          for (final topic in entry.value)
            LessonLink(
              lessonId:
                  _id('l', int.parse(topic.substring(1)) * lessonsPerTopic),
              strength: LinkStrength.required,
            ),
        ],
    },
    lessons: lessons,
    questions: questions,
    seenQuestionIds: seen,
    dueReviews: [
      for (var i = 0; i < dueCount; i++)
        RoadmapReview(
          id: seenList[i % seenList.length],
          due: DateTime(2026, 9, 29, 6 + i % 15, i % 60),
          retrievability: 0.55 + (i % 40) / 100,
        ),
    ],
    scores: {
      for (var t = 0; t < topicCount; t++)
        _id('t', t): RoadmapTopicScore(
          id: _id('t', t),
          correct: 3 + t * 2,
          answered: t == 5 ? 2 : 12 + t,
        ),
    },
    answeredPerActiveDay: const [22, 31, 0, 18, 40, 25, 12],
    mock: RoadmapMockFacts(
      examHasMock: hasMock,
      proIsActive: true,
      lastSubmittedAt: hasMock ? DateTime(2026, 9, 12, 20, 15) : null,
    ),
    assessmentCompleted: assessed,
    contentRevision: 'rev7',
    anchoredReviewOnlyFrom: anchor,
    studyDays: studyDays,
    treatTodayAsStudyDay: treatTodayAsStudyDay,
  );
}

void main() {
  final tue = DateTime(2026, 9, 29, 8, 5); // a Tuesday, with a time of day
  final scenarios = <String, RoadmapInputs>{
    'planning_rich': rich(today: tue),
    'planning_mon_to_sat': rich(
      today: DateTime(2026, 10, 4), // Sunday: rest day
      studyDays: StudyDays(const [1, 2, 3, 4, 5, 6]),
    ),
    'planning_large_120x900': rich(
      today: tue,
      topicCount: 1,
      lessonsPerTopic: 120,
      questionsPerLesson: 7,
      prerequisites: const {},
    ),
    'review_only_anchored': rich(
      today: DateTime(2026, 12, 3),
      anchor: DateTime(2026, 11, 30),
    ),
    'exam_passed': rich(
      today: DateTime(2026, 12, 20),
      examDate: ExamDate.onDay(DateTime(2026, 12, 7)),
    ),
    'month_precision_exam': rich(
      today: tue,
      examDate: ExamDate.inMonth(year: 2027, month: 2),
    ),
    'no_exam_date': rich(today: tue, noExam: true),
    'prerequisite_cycle': rich(
      today: tue,
      prerequisites: {
        _id('t', 0): [_id('t', 1)],
        _id('t', 1): [_id('t', 0)],
      },
    ),
    'needs_assessment': rich(today: tue, assessed: false),
    'no_content': rich(
      today: tue,
      topicCount: 0,
      prerequisites: const {},
      dueCount: 0,
    ),
  };
  final out = {
    for (final e in scenarios.entries) e.key: inputsToJson(e.value),
    ..._r1Scenarios(tue),
  };
  File('server_dart/fixtures/diagnosis_scenarios.json').writeAsStringSync(
    jsonEncode(_diagnosisScenarios(out['r1_weak_chain']!)),
  );
  stdout.writeln('wrote diagnosis scenarios');
  File('server_dart/fixtures/roadmap_scenarios.json')
      .writeAsStringSync(jsonEncode(out));
  stdout.writeln('wrote ${out.length} scenarios');
  File('server_dart/fixtures/mock_scenarios.json')
      .writeAsStringSync(jsonEncode(_mockScenarios()));
  stdout.writeln('wrote mock scenarios');
}

String _sections(List<Map<String, Object?>> sections) => jsonEncode(sections);

Map<String, Object?> _mockScenarios() {
  Map<String, Object?> section(String id, int count, List<String> topics) => {
        'id': id,
        'name': 'Section $id',
        'questionCount': count,
        'suggestedMinutes': 30,
        'sectionalMinutes': 30,
        'topicIds': topics,
        'topicWeights': {for (final t in topics) t: 1 / topics.length},
      };
  List<String> pool(String p, int n) => [for (var i = 0; i < n; i++) _id(p, i)];
  final pools = {
    'topic_a': pool('a', 40),
    'topic_b': pool('b', 25),
    'topic_c': pool('c', 12),
    'topic_d': pool('d', 60),
  };
  final passages = {
    'topic_d': {
      'pd1': pool('d', 5),
      'pd2': pool('d', 12).sublist(5, 9),
      'pd3': pool('d', 20).sublist(12, 20),
    },
  };
  final two = _sections([
    section('s1', 30, ['topic_a', 'topic_b']),
    section('s2', 20, ['topic_c', 'topic_d']),
  ]);
  return {
    'two_sections': {
      'sectionsJson': two,
      'poolsByTopic': pools,
      'passageSetsByTopic': passages,
      'recentlySampledQuestionIds': <String>[],
      'seed': 12345,
    },
    'same_inputs_other_seed': {
      'sectionsJson': two,
      'poolsByTopic': pools,
      'passageSetsByTopic': passages,
      'recentlySampledQuestionIds': <String>[],
      'seed': 4000000007,
    },
    'avoids_recent': {
      'sectionsJson': two,
      'poolsByTopic': pools,
      'passageSetsByTopic': passages,
      'recentlySampledQuestionIds': [...pool('a', 20), ...pool('b', 10)],
      'seed': 99,
    },
    'short_pool': {
      'sectionsJson': _sections([
        section('s1', 30, ['topic_c', 'topic_a']),
      ]),
      'poolsByTopic': pools,
      'passageSetsByTopic': null,
      'recentlySampledQuestionIds': <String>[],
      'seed': 7,
    },
  };
}

Map<String, Map<String, Object?>> _r1Scenarios(DateTime today) {
  final base = <String, Object?>{
    ...inputsToJson(rich(today: today)),
    'topics': [
      {'id': 't', 'authoredIndex': 0, 'name': 'Topic'},
    ],
    'lessons': [
      for (final (index, id) in ['target', 'middle', 'base', 'empty'].indexed)
        {
          'id': id,
          'topicId': 't',
          'ordering': index,
          'readAt': id == 'target' ? null : '2026-09-01T08:00:00',
        },
    ],
    'questions': [
      for (final id in ['target', 'middle', 'base'])
        {'id': 'q-$id', 'topicId': 't', 'lessonId': id},
    ],
    'seenQuestionIds': ['q-base', 'q-middle'],
    'dueReviews': <Object?>[],
    'scores': <String, Object?>{},
    'lessonLinks': {
      'target': [
        {'lesson': 'middle', 'strength': 'required'},
      ],
      'middle': [
        {'lesson': 'base', 'strength': 'required'},
      ],
    },
    'history': [
      for (final id in ['base', 'middle'])
        {
          'id': 'q-$id',
          'answered': 5,
          'recent': [false, false, true],
        },
    ],
    'recall': {'q-base': 0.4, 'q-middle': 0.5},
    'gapTags': {'q-target_b': 'middle'},
  };
  const upcat = {
    'topic_upcat_algebra': ['topic_upcat_arithmetic_number_sense'],
    'topic_upcat_trigonometry': ['topic_upcat_geometry'],
    'topic_upcat_precalculus_basic_calculus': ['topic_upcat_algebra'],
    'topic_upcat_language_application': ['topic_upcat_grammar_and_structure'],
  };
  final topics = {...upcat.keys, ...upcat.values.expand((ids) => ids)}.toList()
    ..sort();
  final optional = Map<String, Object?>.of(base)
    ..remove('lessonLinks')
    ..remove('history')
    ..remove('recall')
    ..remove('gapTags');
  final raw = {
    'r1_weak_chain': base,
    'r1_tag_follow_up': {
      ...base,
      'history': [
        ...(base['history']! as List<Object?>),
        {
          'id': 'q-target',
          'answered': 1,
          'recent': [false],
          'lastWrongChoiceId': 'q-target_b',
        },
      ],
    },
    'r1_cycle': {
      ...base,
      'lessonLinks': {
        ...(base['lessonLinks']! as Map<String, Object?>),
        'base': [
          {'lesson': 'target', 'strength': 'required'},
        ],
      },
    },
    'r1_no_question_lesson': {
      ...base,
      'lessonLinks': {
        'target': [
          {'lesson': 'empty', 'strength': 'required'},
        ],
      },
    },
    'r1_optional_defaults': optional,
    'r1_upcat_equivalent': {
      ...base,
      'topics': [
        for (final (index, id) in topics.indexed)
          {'id': id, 'authoredIndex': index, 'name': id},
      ],
      'lessons': [
        for (final (index, id) in topics.indexed)
          {'id': 'lesson-$id', 'topicId': id, 'ordering': index},
      ],
      'questions': <Object?>[],
      'history': <Object?>[],
      'recall': <String, Object?>{},
      'gapTags': <String, Object?>{},
      'lessonLinks': {
        for (final entry in upcat.entries)
          'lesson-${entry.key}': [
            for (final id in entry.value)
              {'lesson': 'lesson-$id', 'strength': 'required'},
          ],
      },
    },
  };
  return {
    for (final entry in raw.entries)
      entry.key: entry.key == 'r1_optional_defaults'
          ? entry.value
          : inputsToJson(inputsFromJson(entry.value)),
  };
}

Map<String, Object?> _diagnosisScenarios(Map<String, Object?> inputs) {
  final base = <String, Object?>{
    'inputs': inputs,
    'session': {
      'sessionId': 'session-r1',
      'answers': [
        {'questionId': 'q-target', 'chosen': 'q-target_b', 'correct': false},
        {'questionId': 'q-base', 'chosen': null, 'correct': false},
        {'questionId': 'q-base', 'chosen': 'q-base_b', 'correct': false},
        {'questionId': 'q-middle', 'chosen': 'q-middle_a', 'correct': true},
        {'questionId': 'q-middle', 'chosen': 'q-middle_b', 'correct': false},
        {'questionId': 'unknown', 'chosen': 'unknown_b', 'correct': false},
      ],
    },
    'notes': {
      'q-target_b': 'Check the base.',
      'q-middle_b': 'Review the base.',
    },
  };
  return {
    'free': {...base, 'includeDetail': false},
    'pro': {...base, 'includeDetail': true},
    'empty': {
      ...base,
      'session': {'sessionId': 'empty', 'answers': <Object?>[]},
      'includeDetail': true,
    },
    'solid': {
      ...base,
      'inputs': {
        ...inputs,
        'history': [
          for (final id in ['base', 'middle'])
            {
              'id': 'q-$id',
              'answered': 5,
              'recent': [true, true, true],
            },
        ],
        'recall': {'q-base': 0.9, 'q-middle': 0.9},
      },
      'includeDetail': true,
    },
  };
}
