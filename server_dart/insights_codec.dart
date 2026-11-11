import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_resolver.dart';
import 'package:pantas/features/metrics/domain/metrics_thresholds.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';

typedef Row = Map<String, Object?>;
List<Row> _rows(Object? value) => [
      for (final raw in value as List? ?? const [])
        (raw as Map).cast<String, Object?>(),
    ];
int _int(Row row, String key) => (row[key]! as num).toInt();
DateTime _date(Row row, String key) => DateTime.parse(row[key]! as String);
bool _by(Row row, String key, DateTime end) => !_date(row, key).isAfter(end);
MetricAttemptItem _item(Row row) => MetricAttemptItem(
      questionId: row['questionId']! as String,
      questionVersion: (row['questionVersion'] as num?)?.toInt() ?? 1,
      chosenChoiceId: row['correct']! as bool ? 'correct' : 'wrong',
      correctChoiceId: 'correct',
      responseMs: (row['responseMs'] as num?)?.toInt() ?? 0,
    );
List<Row> _items(Row row) => _rows(row['items']);

/// JSON has actual observations only. Missing timing/flags/section clocks stay
/// absent. Window and aggregation semantics match the native row readers.
Row studyInsightsFromJson(Row input) {
  final now = _date(input, 'now');
  final examId = input['examId']! as String;
  final sessions =
      _rows(input['sessions']).where((r) => r['examId'] == examId).toList();
  final attempts =
      _rows(input['attempts']).where((r) => r['examId'] == examId).toList();
  final mocks =
      _rows(input['mocks']).where((r) => r['examId'] == examId).toList();
  final lessons =
      _rows(input['lessons']).where((row) => _by(row, 'readAt', now)).toList();
  final reviews = _rows(input['reviews']);
  final count = sessions.where((r) => _by(r, 'finishedAt', now)).length +
      mocks
          .where(
            (r) =>
                _by(r, 'submittedAt', now) &&
                const ['completed', 'forfeited'].contains(r['status']),
          )
          .length;
  final profileEnough =
      count >= MetricsThresholds.minSessionsFor(MetricsWindow.prepWindow);
  final timed = attempts.where(
    (r) =>
        _by(r, 'startedAt', now) &&
        !AttemptOrigins.untimed.contains(r['origin']),
  );
  final speed = MetricCalculations.speed([
    for (final row in timed)
      for (final item in _items(row))
        if (item['responseMs'] != null) _item(item),
  ]);
  final pressure = MetricCalculations.pressure(
    practice: [
      for (final row in attempts)
        if (!AttemptOrigins.mirrored.contains(row['origin']))
          for (final item in _items(row)) item['correct']! as bool,
    ],
    mock: [
      for (final row in mocks)
        for (final item in _items(row))
          if (item['chosen'] != null) item['correct']! as bool,
    ],
    allowEmpty: true,
  );
  final stamina = MetricCalculations.stamina([
    for (final row in mocks)
      if (_by(row, 'submittedAt', now))
        [for (final item in _items(row)) item['correct']! as bool],
  ]);
  final workflow = MetricCalculations.workflow(
    attempts: [
      for (final row in attempts)
        for (final item in _items(row))
          if (item['topicId'] is String)
            (
              topicId: item['topicId']! as String,
              startedAt: _date(row, 'startedAt')
            ),
    ],
    lessons: [
      for (final row in lessons)
        (
          topicId: row['topicId']! as String,
          readAt: _date(row, 'readAt'),
          inExam: row['examId'] == examId
        ),
    ],
    allowEmpty: true,
  );
  final memory = MetricCalculations.retention([
    for (final row in reviews)
      (
        stability: (row['stability']! as num).toDouble(),
        reps: _int(row, 'reps'),
        lapses: _int(row, 'lapses')
      ),
  ]);
  final hours = profileEnough
      ? MetricCalculations.timeOfDay([
          for (final row in sessions)
            if (_by(row, 'startedAt', now) && _int(row, 'total') > 0)
              (
                hour: _date(row, 'startedAt').hour,
                correct: _int(row, 'correct'),
                total: _int(row, 'total')
              ),
          for (final row in mocks)
            if (_by(row, 'submittedAt', now) && _int(row, 'scoreTotal') > 0)
              (
                hour: _date(row, 'submittedAt').hour,
                correct: _int(row, 'scoreRaw'),
                total: _int(row, 'scoreTotal')
              ),
        ])
      : null;
  final duration = profileEnough
      ? MetricCalculations.sessionShape([
          for (final row in sessions)
            if (_by(row, 'startedAt', now))
              _date(row, 'finishedAt')
                      .difference(_date(row, 'startedAt'))
                      .inSeconds /
                  60,
          for (final row in mocks)
            if (_by(row, 'submittedAt', now))
              (row['durationMs']! as num) / 60000,
        ])
      : null;
  final affinity = profileEnough
      ? MetricCalculations.subjectAffinity([
          for (final row in attempts)
            if (_by(row, 'startedAt', now))
              for (final item in _items(row))
                if (item['subjectName'] is String)
                  (
                    subject: item['subjectName']! as String,
                    item: _item(item),
                    timed: !AttemptOrigins.untimed.contains(row['origin']) &&
                        item['responseMs'] != null
                  ),
        ])
      : null;
  final pace = profileEnough
      ? MetricCalculations.pacing([
          for (final row in mocks)
            if (_by(row, 'submittedAt', now))
              (
                spareSeconds:
                    ((_int(row, 'limitMs') - _int(row, 'durationMs')) / 1000)
                        .truncate(),
                sectionTimes: ((row['sectionTimes'] as Map?) ?? const {})
                    .cast<String, int>()
              ),
        ])
      : null;
  final flags = profileEnough
      ? MetricCalculations.flagRevisit([
          for (final row in mocks)
            if (_by(row, 'submittedAt', now) && row['flags'] != null)
              (
                flagged: (row['flags']! as List).cast<String>().toSet(),
                answered: {
                  for (final item in _items(row))
                    if (item['chosen'] != null) item['questionId']! as String,
                }
              ),
        ])
      : null;
  final signals = <SignalKey, Object>{
    if (hours != null) SignalKey.timeOfDay: hours,
    if (duration != null) SignalKey.sessionShape: duration,
    if (profileEnough && speed != null) SignalKey.perQuestionSpeed: speed,
    if (profileEnough &&
        pressure != null &&
        pressure.practiceTotal > 0 &&
        pressure.mockTotal > 0)
      SignalKey.testModeDelta: pressure,
    if (profileEnough && stamina != null) SignalKey.mockStamina: stamina,
    if (profileEnough &&
        workflow != null &&
        workflow.readThenQuizCount + workflow.quizFirstCount > 0)
      SignalKey.readThenQuiz: workflow,
    if (profileEnough && memory != null) SignalKey.retentionShape: memory,
    if (affinity != null) SignalKey.subjectAffinity: affinity,
    if (pace != null) SignalKey.mockPacing: pace,
    if (flags != null) SignalKey.flagRevisit: flags,
  };
  // Coverage is allTime-only natively and must not enter a prepWindow profile.
  final profile = const ArchetypeResolver().resolve(archetypeCatalog, signals);
  Row finding(TendencyConfidence confidence, Row? value, List<String> unmet) =>
      {
        'unmetRequirements': unmet,
        'confidence': confidence.name,
        'value': confidence == TendencyConfidence.clear ? value : null,
      };
  final pressureConfidence = pressure == null
      ? TendencyConfidence.early
      : TendencyEvidence.pressure(pressure);
  final staminaConfidence = stamina == null
      ? TendencyConfidence.early
      : TendencyEvidence.stamina(stamina);
  final studyConfidence = workflow == null
      ? TendencyConfidence.early
      : TendencyEvidence.study(workflow);
  final speedConfidence =
      speed == null ? TendencyConfidence.early : TendencyEvidence.speed(speed);
  final memoryConfidence = memory == null
      ? TendencyConfidence.early
      : TendencyEvidence.memory(memory);
  return {
    'profile': profile == null ? null : {'id': profile.id},
    'tendencies': {
      'pressure': finding(
        pressureConfidence,
        pressure == null
            ? null
            : {
                'practiceAccuracy': pressure.practiceAccuracy,
                'mockAccuracy': pressure.mockAccuracy,
                'practiceCorrect': pressure.practiceCorrect,
                'practiceTotal': pressure.practiceTotal,
                'mockCorrect': pressure.mockCorrect,
                'mockTotal': pressure.mockTotal,
              },
        [
          if (pressure == null || pressure.practiceTotal == 0) 'practice',
          if (pressure == null || pressure.mockTotal == 0) 'mock',
        ],
      ),
      'stamina': finding(
        staminaConfidence,
        stamina == null
            ? null
            : {
                'firstHalfAccuracy': stamina.firstHalfAccuracy,
                'secondHalfAccuracy': stamina.secondHalfAccuracy,
                'firstHalfCorrect': stamina.firstHalfCorrect,
                'firstHalfTotal': stamina.firstHalfTotal,
                'secondHalfCorrect': stamina.secondHalfCorrect,
                'secondHalfTotal': stamina.secondHalfTotal,
              },
        [if (stamina == null) 'mock'],
      ),
      'study': finding(
        studyConfidence,
        workflow == null
            ? null
            : {
                'readThenQuizCount': workflow.readThenQuizCount,
                'quizFirstCount': workflow.quizFirstCount,
                'readLessonCount': workflow.readLessonCount,
                'practicedTopicCount': workflow.practicedTopicCount,
              },
        [
          if (workflow == null || workflow.readLessonCount == 0) 'lesson',
          if (workflow == null || workflow.practicedTopicCount == 0) 'practice',
          if (workflow != null &&
              workflow.readLessonCount > 0 &&
              workflow.practicedTopicCount > 0 &&
              workflow.readThenQuizCount + workflow.quizFirstCount == 0)
            'matchedTopic',
        ],
      ),
      'speed': finding(
        speedConfidence,
        speed == null
            ? null
            : {
                'averageMs': speed.averageMs,
                'correctAverageMs': speed.correctAverageMs,
                'incorrectAverageMs': speed.incorrectAverageMs,
                'sampleCount': speed.sampleCount,
                'correctCount': speed.correctCount,
                'incorrectCount': speed.incorrectCount,
                'correctLogMean': speed.correctLogMean,
                'incorrectLogMean': speed.incorrectLogMean,
                'correctLogVariance': speed.correctLogVariance,
                'incorrectLogVariance': speed.incorrectLogVariance,
              },
        [
          if (speed == null || speed.correctCount == 0) 'correct',
          if (speed == null || speed.incorrectCount == 0) 'incorrect',
        ],
      ),
      'memory': finding(
        memoryConfidence,
        memory == null
            ? null
            : {
                'averageStability': memory.averageStability,
                'lapseRate': memory.lapseRate,
                'lapseCount': memory.lapseCount,
                'reviewCount': memory.reviewCount,
              },
        [if (memory == null || memory.reviewCount == 0) 'reviews'],
      ),
    },
    'whenYouWork': hours == null || duration == null || hours.buckets.isEmpty
        ? null
        : {
            'peakHour': ([...hours.buckets]
                  ..sort((a, b) => b.accuracy.compareTo(a.accuracy)))
                .first
                .hour,
            'averageMinutes': duration.averageMinutes,
            'sessionCount': duration.sessionCount,
          },
  };
}
