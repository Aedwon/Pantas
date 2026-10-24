import 'package:pantas/features/roadmap/domain/roadmap.dart';

Map<String, Object?> studyMap(Object? value) {
  if (value is! Map) throw const FormatException('Invalid study object');
  return Map<String, Object?>.unmodifiable(value.cast<String, Object?>());
}

List<Map<String, Object?>> studyRows(Object? value) {
  if (value is! List) throw const FormatException('Invalid study rows');
  return List.unmodifiable(value.map(studyMap));
}

int studyWhole(Object? value) {
  if (value is! num ||
      !value.isFinite ||
      value < 0 ||
      value != value.roundToDouble()) {
    throw const FormatException('Invalid measured count');
  }
  return value.toInt();
}

String studyString(Object? value) {
  if (value is! String || value.isEmpty) {
    throw const FormatException('Missing study identity');
  }
  return value;
}

DateTime studyDay(Object? value) {
  final text = studyString(value);
  final day = DateTime.tryParse(text);
  if (day == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
    throw const FormatException('Invalid plan day');
  }
  return DateTime(day.year, day.month, day.day);
}

List<String> _ids(Object? value) {
  if (value is! List) throw const FormatException('Invalid membership');
  final ids = value.map(studyString).toList();
  if (ids.toSet().length != ids.length) {
    throw const FormatException('Repeated membership');
  }
  return List.unmodifiable(ids);
}

DayPlan decodeStudyDayPlan(Object? value) {
  final map = studyMap(value);
  if (map['isMockDay'] is! bool || map['isRestDay'] is! bool) {
    throw const FormatException('Invalid plan flags');
  }
  return DayPlan(
    day: studyDay(map['day']),
    lessonIds: _ids(map['lessonIds']),
    reviewQuestionIds: _ids(map['reviewQuestionIds']),
    newQuestionIds: _ids(map['newQuestionIds']),
    isMockDay: map['isMockDay']! as bool,
    isRestDay: map['isRestDay']! as bool,
    advancedIds: _ids(map['advancedIds']).toSet(),
  );
}

class StudyEnvelope {
  StudyEnvelope(Map<String, Object?> map, String examId)
      : examId = studyString(map['examId']),
        serverNow = studyWhole(map['serverNow']),
        accessRecheckAt = map['accessRecheckAt'] == null
            ? null
            : studyWhole(map['accessRecheckAt']),
        proCovered = map['proCovered'] == true {
    if (this.examId != examId || map['proCovered'] is! bool) {
      throw const FormatException('Study exam changed');
    }
  }
  final String examId;
  final int serverNow;
  final int? accessRecheckAt;
  final bool proCovered;
}

class StudyPerformanceRow {
  StudyPerformanceRow(Map<String, Object?> row)
      : id = studyString(row['id']),
        title = studyString(row['title']),
        parentId = row['parentId'] as String?,
        correct = studyWhole(row['correct']),
        answered = studyWhole(row['answered']),
        topicCount =
            row['topicCount'] == null ? null : studyWhole(row['topicCount']) {
    if (correct > answered) throw const FormatException('Invalid accuracy');
  }
  final String id;
  final String title;
  final String? parentId;
  final int correct;
  final int answered;
  final int? topicCount;
  double? get accuracy => answered == 0 ? null : correct / answered;
}

class StudyInsights extends StudyEnvelope {
  StudyInsights._(
    super.map,
    super.examId, {
    required this.revision,
    required this.correct,
    required this.answered,
    required this.subjects,
    required this.topics,
    required this.lessons,
    required this.lessonLevelAvailable,
    this.profileId,
    this.tendencies,
    this.whenYouWork,
    this.trialEndsAt,
    this.topicDetails = const [],
  });
  factory StudyInsights.decode(Object? value, {required String examId}) {
    final map = studyMap(value);
    final performance = studyMap(map['performance']);
    final overall = studyMap(performance['overall']);
    final correct = studyWhole(overall['correct']);
    final answered = studyWhole(overall['answered']);
    if (correct > answered) {
      throw const FormatException('Invalid overall accuracy');
    }
    final pro = map['proCovered'] == true;
    List<StudyPerformanceRow> rows(String key) => performance[key] == null
        ? const []
        : List.unmodifiable(
            studyRows(performance[key])
                .map(StudyPerformanceRow.new)
                .where((r) => r.answered > 0),
          );
    return StudyInsights._(
      map,
      examId,
      revision: studyString(map['revision']),
      correct: correct,
      answered: answered,
      subjects: rows('subjects'),
      topics: pro ? rows('topics') : const [],
      lessons: pro ? rows('lessons') : const [],
      topicDetails: pro && performance['topicDetails'] != null
          ? studyRows(performance['topicDetails'])
          : const [],
      lessonLevelAvailable: performance['lessonLevelAvailable'] == true,
      profileId: map['profile'] == null
          ? null
          : studyString(studyMap(map['profile'])['id']),
      tendencies:
          pro && map['tendencies'] != null ? studyMap(map['tendencies']) : null,
      whenYouWork: pro && map['whenYouWork'] != null
          ? studyMap(map['whenYouWork'])
          : null,
      trialEndsAt:
          map['trialEndsAt'] == null ? null : studyWhole(map['trialEndsAt']),
    );
  }
  final List<Map<String, Object?>> topicDetails;
  final String revision;
  final int correct;
  final int answered;
  final List<StudyPerformanceRow> subjects;
  final List<StudyPerformanceRow> topics;
  final List<StudyPerformanceRow> lessons;
  final bool lessonLevelAvailable;
  final String? profileId;
  final Map<String, Object?>? tendencies;
  final Map<String, Object?>? whenYouWork;
  final int? trialEndsAt;
}

class StudyRoadmap extends StudyEnvelope {
  StudyRoadmap._(
    super.map,
    super.examId, {
    required this.revision,
    required this.state,
    required this.today,
    required this.remaining,
    required this.originalDone,
    required this.canAdvance,
    required this.todayTopicOrder,
    required this.weekDays,
    this.homeExtras,
    this.comingUp,
    this.history,
  });
  factory StudyRoadmap.decode(Object? value, {required String examId}) {
    final map = studyMap(value);
    if (map['originalDone'] is! bool || map['canAdvance'] is! bool) {
      throw const FormatException('Invalid completion facts');
    }
    final today = decodeStudyDayPlan(map['today']);
    final remaining = decodeStudyDayPlan(map['remaining']);
    if (remaining.day != today.day ||
        !remaining.lessonIds.every(today.lessonIds.contains) ||
        !remaining.reviewQuestionIds.every(today.reviewQuestionIds.contains) ||
        !remaining.newQuestionIds.every(today.newQuestionIds.contains)) {
      throw const FormatException('Invalid remaining membership');
    }
    final pro = map['proCovered'] == true;
    return StudyRoadmap._(
      map,
      examId,
      revision: studyString(map['revision']),
      state: RoadmapState.values.firstWhere(
        (s) => s.name == map['state'],
        orElse: () => throw const FormatException('Invalid plan state'),
      ),
      today: today,
      remaining: remaining,
      originalDone: map['originalDone']! as bool,
      canAdvance: map['canAdvance']! as bool,
      todayTopicOrder: _ids(map['todayTopicOrder']),
      weekDays: studyRows(map['weekDays']),
      homeExtras:
          map['homeExtras'] == null ? null : studyMap(map['homeExtras']),
      comingUp:
          pro && map['comingUp'] != null ? studyMap(map['comingUp']) : null,
      history: pro && map['history'] != null ? studyMap(map['history']) : null,
    );
  }
  final String revision;
  final RoadmapState state;
  final DayPlan today;
  final DayPlan remaining;
  final bool originalDone;
  final bool canAdvance;
  final List<String> todayTopicOrder;
  final List<Map<String, Object?>> weekDays;
  final Map<String, Object?>? homeExtras;
  final Map<String, Object?>? comingUp;
  final Map<String, Object?>? history;
}
