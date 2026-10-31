import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/dev/local_study_reset.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/fsrs/rating_heuristic.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/assessment_question.dart';
import 'package:pantas/core/storage/domain/assessment_question_selector.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/core/time/study_days.dart';

/// The four local sample students. The panel ids are the [id] values.
enum SampleStudent {
  newStudent('new'),
  steady('steady'),
  behind('behind'),
  examWeek('examWeek');

  const SampleStudent(this.id);

  final String id;

  static SampleStudent? fromId(String id) {
    for (final student in values) {
      if (student.id == id) return student;
    }
    return null;
  }
}

/// CSE Professional, the exam every sample student studies.
const sampleExamId = 'exam_cse_pro';

// The local profile that owns quiz sessions and mocks (`quizLocalUserId`,
// `mockAttemptLocalUserId`). Core cannot import those constants.
const _localUser = 'local';

// `kRatingHeuristicVersion` in the quiz feature. A test keeps them equal.
const _ratingHeuristicVersion = 1;

// `SettingsPrefKeys` in the settings feature. A test reads these back through
// the settings repository, so a renamed key fails there.
const _nameKey = 'settings.name';
const _studyDaysKey = 'settings.study_days';
const _examDateKey = 'settings.exam_date';
const _examDatePrecisionKey = 'settings.exam_date_precision';
const _policyAcceptedAtKey = 'settings.policy_accepted_at';
const _policyVersionKey = 'settings.policy_version';
const _updatedAtKey = 'settings.updated_at';

const _blueprintId = 'mock_blueprint_cse_pro';
const _blueprintName = 'CSE Professional Practice Paper';
const _mockMinutes = 190;
const _mockQuestionsPerSection = 12;

class _Profile {
  const _Profile({
    required this.startDaysAgo,
    required this.lastStudyDaysAgo,
    required this.streakDays,
    required this.answers,
    required this.lessons,
    required this.accuracy,
    required this.examInDays,
    required this.poolSize,
    this.earlierRate = 0,
    this.assessmentLimit,
    this.weakShare = 0,
    this.breakStreak = false,
    this.mockAt = const [],
    this.mockAccuracy = const [],
  });

  /// Calendar days from the first study day to today.
  final int startDaysAgo;

  /// Days from the last study day to today.
  final int lastStudyDaysAgo;

  /// Study days in the run that ends on the last study day.
  final int streakDays;

  /// Chance that a study day before the run was studied.
  final double earlierRate;

  /// Target total answers: assessment, sessions and mocks.
  final int answers;
  final int lessons;
  final double accuracy;
  final int examInDays;
  final int poolSize;
  final int? assessmentLimit;

  /// Share of each session taken from a small set of questions the student
  /// keeps missing.
  final double weakShare;

  /// The run has ended: today the streak reads 0.
  final bool breakStreak;

  /// Where each mock sits along the study days, 0 first and 1 last.
  final List<double> mockAt;
  final List<double> mockAccuracy;
}

const _profiles = <SampleStudent, _Profile>{
  SampleStudent.newStudent: _Profile(
    startDaysAgo: 1,
    lastStudyDaysAgo: 1,
    streakDays: 1,
    answers: 12,
    lessons: 1,
    accuracy: 0.70,
    examInDays: 120,
    poolSize: 40,
    assessmentLimit: 8,
  ),
  SampleStudent.steady: _Profile(
    startDaysAgo: 21,
    lastStudyDaysAgo: 1,
    streakDays: 18,
    answers: 400,
    lessons: 30,
    accuracy: 0.75,
    examInDays: 28,
    poolSize: 220,
    mockAt: [0.7],
    mockAccuracy: [0.70],
  ),
  SampleStudent.behind: _Profile(
    startDaysAgo: 35,
    lastStudyDaysAgo: 6,
    streakDays: 6,
    earlierRate: 0.55,
    answers: 250,
    lessons: 14,
    accuracy: 0.55,
    examInDays: 45,
    poolSize: 160,
    weakShare: 0.3,
    breakStreak: true,
  ),
  SampleStudent.examWeek: _Profile(
    startDaysAgo: 70,
    lastStudyDaysAgo: 1,
    streakDays: 24,
    earlierRate: 0.7,
    answers: 900,
    lessons: 60,
    accuracy: 0.80,
    examInDays: 5,
    poolSize: 420,
    mockAt: [0.35, 0.55, 0.75, 0.92],
    mockAccuracy: [0.55, 0.65, 0.73, 0.80],
  ),
};

/// Replaces the local study data with a generated student.
///
/// Records are written in the shapes the app writes them, dated backwards from
/// [today], from a random source seeded with the student's id. Nothing a
/// student sees is stored as a figure: the streak, accuracy, due reviews and
/// mock percent are all read back from these records by the app.
///
/// [fetchHook] is the web content hook. It makes sure question text is
/// present before it is read; native builds pass none.
Future<void> loadSampleStudent(
  AppDatabase db,
  ContentDatabase content,
  SampleStudent student, {
  required DateTime today,
  ContentFetchHook? fetchHook,
}) async {
  final profile = _profiles[student]!;
  final run = _Run(
    db: db,
    content: content,
    profile: profile,
    id: student.id,
    today: DateTime(today.year, today.month, today.day),
    repo: ContentRepository(content, fetchHook: fetchHook),
  );
  // Clear first: the placement test is chosen from the review state.
  await resetLocalStudyData(db, clearPrefs: false, keepSyncMeta: true);
  await db.delete(db.accountPrefs).go();
  await run.build();
  await run.write();
}

/// The parts of a sample student the web app keeps on this device. On web the
/// server holds the study records and the plan; the device keeps the signed-in
/// student's onboarding answers and the day streak.
class SampleStudentProfile {
  const SampleStudentProfile({
    required this.examDate,
    required this.streak,
    required this.longest,
    required this.lastActiveDate,
  });

  /// Reads the result the local server's seed returns.
  factory SampleStudentProfile.fromJson(Map<String, Object?> json) {
    final last = json['lastActiveDate'] as String?;
    return SampleStudentProfile(
      examDate: DateTime.parse(json['examDate']! as String),
      streak: json['streak']! as int,
      longest: json['longest']! as int,
      lastActiveDate: last == null ? null : DateTime.parse(last),
    );
  }

  final DateTime examDate;
  final int streak;
  final int longest;
  final DateTime? lastActiveDate;
}

/// Web: clears the device's study data and writes only what the device owns
/// for a student whose records the server already holds: finished onboarding
/// and the streak, and marks the placement test as taken. No answers are
/// written, so no upload follows.
Future<void> loadSampleStudentProfile(
  AppDatabase db,
  SampleStudentProfile profile, {
  required DateTime today,
}) async {
  await resetLocalStudyData(db, clearPrefs: false, keepSyncMeta: true);
  await db.delete(db.accountPrefs).go();
  await db.batch((batch) {
    _writeOnboarding(
      batch,
      db,
      stamp: DateTime(today.year, today.month, today.day).toUtc(),
      examDate: profile.examDate,
    );
    _writeStreak(
      batch,
      db,
      streak: profile.streak,
      longest: profile.longest,
      lastActive: profile.lastActiveDate,
    );
    // The app sends this flag to the server with the settings, and the plan
    // waits for the placement test when it is false. The server holds the
    // placement answers; this only marks the test as taken.
    batch.insert(
      db.assessmentResultsLocal,
      AssessmentResultsLocalCompanion.insert(
        examId: sampleExamId,
        completedAt: today,
        topicScoresJson: '[]',
      ),
      mode: InsertMode.insertOrReplace,
    );
  });
}

void _writeOnboarding(
  Batch batch,
  AppDatabase db, {
  required DateTime stamp,
  required DateTime examDate,
}) {
  final studyDays = StudyDays(const [1, 2, 3, 4, 5, 6]);
  final stampText = stamp.toIso8601String();
  void device(String key, String value) => batch.insert(
        db.devicePrefs,
        DevicePrefsCompanion.insert(key: key, value: value),
        mode: InsertMode.insertOrReplace,
      );
  void account(String key, String value) => batch.insert(
        db.accountPrefs,
        AccountPrefsCompanion.insert(key: key, value: value),
        mode: InsertMode.insertOrReplace,
      );

  device('passed_age_gate', 'true');
  device('selected_exam_id', sampleExamId);
  device('onboarding_complete', 'true');
  device('onboarding.date_answered', 'true');
  device('notifications.rationale_shown', 'true');
  account(_nameKey, 'Aerol');
  account(_studyDaysKey, studyDays.storageValue);
  account(_examDateKey, _dateText(examDate));
  account(_examDatePrecisionKey, 'day');
  account(_policyAcceptedAtKey, stampText);
  account(_policyVersionKey, '1');
  account(_updatedAtKey, stampText);
}

void _writeStreak(
  Batch batch,
  AppDatabase db, {
  required int streak,
  required int longest,
  required DateTime? lastActive,
}) {
  if (lastActive == null) return;
  batch.insert(
    db.streakLocal,
    StreakLocalCompanion.insert(
      current: Value(streak),
      longest: Value(longest),
      lastActiveDate: Value(lastActive),
    ),
    mode: InsertMode.insertOrReplace,
  );
}

DateTime _addDays(DateTime day, int days) =>
    DateTime(day.year, day.month, day.day + days);

DateTime _at(DateTime day, int hour, [int minute = 0]) =>
    DateTime(day.year, day.month, day.day, hour, minute);

String _dateText(DateTime day) => '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

String _stageText(ReviewStage stage) => switch (stage) {
      ReviewStage.newCard => 'new',
      ReviewStage.learning => 'learning',
      ReviewStage.review => 'review',
      ReviewStage.relearning => 'relearning',
    };

class _Mock {
  _Mock(this.day, this.accuracy);

  final DateTime day;
  final double accuracy;
}

class _Run {
  _Run({
    required this.db,
    required this.content,
    required this.profile,
    required this.id,
    required this.today,
    required this.repo,
  }) : rng = Random(_seedOf(id));

  final AppDatabase db;
  final ContentDatabase content;
  final _Profile profile;
  final String id;
  final DateTime today;
  final ContentRepository repo;
  final Random rng;
  final FsrsScheduler scheduler = const FsrsScheduler();
  final StudyDays studyDays = StudyDays(const [1, 2, 3, 4, 5, 6]);

  final known = <String, Question>{};
  final states = <String, ReviewState>{};
  final logs = <ReviewLogsCompanion>[];
  final attempts = <AttemptsLocalCompanion>[];
  final sessions = <QuizSessionsCompanion>[];
  final lessonReads = <LessonProgressLocalCompanion>[];
  final mocks = <MockAttemptsCompanion>[];
  final newCardsByDay = <DateTime, int>{};
  AssessmentResultsLocalCompanion? assessment;
  late DateTime examDate;

  int streak = 0;
  int longest = 0;
  DateTime? lastActive;

  static int _seedOf(String id) => id.codeUnits
      .fold<int>(17, (hash, unit) => (hash * 31 + unit) & 0x7fffffff);

  List<T> _shuffled<T>(Iterable<T> items) => items.toList()..shuffle(rng);

  Future<void> build() async {
    final subjects = await (content.select(content.contentSubjects)
          ..where(
            (s) => s.examId.equals(sampleExamId) & s.isActive.equals(true),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.ordering)]))
        .get();
    final topics = subjects.isEmpty
        ? <ContentTopicRow>[]
        : await (content.select(content.contentTopics)
              ..where(
                (t) =>
                    t.subjectId.isIn([for (final s in subjects) s.id]) &
                    t.isActive.equals(true),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.ordering)]))
            .get();
    final subjectOfTopic = {for (final t in topics) t.id: t.subjectId};
    final pool = await _buildPool(topics);

    // Study days: the run ending on the last study day, then earlier days.
    final anchor = _addDays(today, -profile.lastStudyDaysAgo);
    final window = <DateTime>[anchor];
    var cursor = anchor;
    while (window.length < profile.streakDays) {
      cursor = _addDays(cursor, -1);
      if (cursor.weekday != DateTime.sunday) window.add(cursor);
    }
    window.sort();
    final studied = <DateTime>{...window};
    var skipped = _addDays(window.first, -1);
    while (skipped.weekday == DateTime.sunday) {
      skipped = _addDays(skipped, -1);
    }
    for (var day = _addDays(today, -profile.startDaysAgo);
        day.isBefore(window.first);
        day = _addDays(day, 1)) {
      if (day.weekday == DateTime.sunday || day == skipped) continue;
      if (rng.nextDouble() < profile.earlierRate) studied.add(day);
    }
    final days = studied.toList()..sort();

    // The placement test, chosen the way the app chooses it.
    final selected = await AssessmentQuestionSelector(
      repo,
      ReviewStateRepository(db),
    ).select(sampleExamId);
    final placement = selected.take(profile.assessmentLimit ?? 30).toList();
    for (final item in placement) {
      known[item.question.id] = item.question;
    }

    // Mocks: one section per subject, drawn from the hydrated pool.
    final sections = <({String id, String name, List<String> pool})>[];
    for (final subject in subjects) {
      final ids = [
        for (final q in pool)
          if (subjectOfTopic[known[q]!.topicId] == subject.id) q,
      ];
      if (ids.isNotEmpty) {
        sections.add((id: 'sec_${subject.id}', name: subject.name, pool: ids));
      }
    }
    final perMock = [
      for (final s in sections) min(_mockQuestionsPerSection, s.pool.length),
    ].fold<int>(0, (a, b) => a + b);
    final mockByIndex = <int, _Mock>{};
    for (var i = 0; i < profile.mockAt.length && sections.isNotEmpty; i++) {
      final at = (profile.mockAt[i] * (days.length - 1)).round();
      mockByIndex[at] = _Mock(days[at], profile.mockAccuracy[i]);
    }

    // Session sizes: the answers left after the placement test and mocks.
    final sessionTotal = max(
      days.length,
      profile.answers - placement.length - mockByIndex.length * perMock,
    );
    final weights = [for (final _ in days) 0.7 + rng.nextDouble() * 0.6];
    final weightSum = weights.fold<double>(0, (a, b) => a + b);
    final sizes = [
      for (final w in weights) max(1, (sessionTotal * w / weightSum).round()),
    ];
    sizes[sizes.length - 1] = max(
      1,
      sessionTotal - sizes.take(sizes.length - 1).fold<int>(0, (a, b) => a + b),
    );

    // Lessons, in subject, topic and lesson order.
    final lessonRows = topics.isEmpty
        ? <ContentLessonRow>[]
        : await (content.select(content.contentLessons)
              ..where(
                (l) =>
                    l.topicId.isIn([for (final t in topics) t.id]) &
                    l.isActive.equals(true),
              ))
            .get();
    final subjectOrder = {
      for (var i = 0; i < subjects.length; i++) subjects[i].id: i,
    };
    final topicOrder = {
      for (var i = 0; i < topics.length; i++) topics[i].id: i,
    };
    lessonRows.sort((a, b) {
      final bySubject = subjectOrder[subjectOfTopic[a.topicId]]!
          .compareTo(subjectOrder[subjectOfTopic[b.topicId]]!);
      if (bySubject != 0) return bySubject;
      final byTopic = topicOrder[a.topicId]!.compareTo(topicOrder[b.topicId]!);
      if (byTopic != 0) return byTopic;
      final byOrdering = a.ordering.compareTo(b.ordering);
      return byOrdering != 0 ? byOrdering : a.id.compareTo(b.id);
    });
    final lessonCount = min(profile.lessons, lessonRows.length);
    final lessonsByDay = <int, List<String>>{};
    for (var k = 0; k < lessonCount; k++) {
      final at = min(days.length - 1, k * days.length ~/ lessonCount);
      lessonsByDay.putIfAbsent(at, () => []).add(lessonRows[k].id);
    }

    final weak = _shuffled(pool).take(18).toSet();
    final unseen = _shuffled(pool);

    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      final progress = days.length == 1 ? 1.0 : i / (days.length - 1);

      final mock = mockByIndex[i];
      if (mock != null) _addMock(i, mock, sections);

      var minute = 0;
      for (final lessonId in lessonsByDay[i] ?? const <String>[]) {
        lessonReads.add(
          LessonProgressLocalCompanion.insert(
            lessonId: lessonId,
            readAt: _at(day, 16, minute),
          ),
        );
        minute += 5;
      }

      if (i == 0 && placement.isNotEmpty) {
        _addAssessment(day, placement);
      }

      if (pool.isEmpty) continue;
      _addSession(
        index: i,
        day: day,
        size: sizes[i],
        progress: progress,
        pool: pool,
        weak: weak,
        unseen: unseen,
      );
    }

    if (profile.breakStreak) streak = 0;
    examDate = _addDays(today, profile.examInDays);
  }

  Future<List<String>> _buildPool(List<ContentTopicRow> topics) async {
    final rows = await repo.selectionRowsByExam(sampleExamId);
    final byTopic = <String, List<String>>{};
    for (final row in rows) {
      byTopic.putIfAbsent(row.topicId, () => []).add(row.id);
    }
    final queues = [
      for (final topic in byTopic.keys.toList()..sort())
        _shuffled(byTopic[topic]!.toList()..sort()),
    ];
    final picked = <String>[];
    for (var round = 0; picked.length < profile.poolSize; round++) {
      var any = false;
      for (final queue in queues) {
        if (round < queue.length && picked.length < profile.poolSize) {
          picked.add(queue[round]);
          any = true;
        }
      }
      if (!any) break;
    }
    final hydrated = await repo.questionsByIds(picked);
    final pool = <String>[];
    for (final qid in picked) {
      final q = hydrated[qid];
      if (q == null ||
          q.choices.length < 2 ||
          !q.choices.any((c) => c.isCorrect)) {
        continue;
      }
      known[qid] = q;
      pool.add(qid);
    }
    return pool;
  }

  List<String> _pick({
    required int size,
    required DateTime dayEnd,
    required List<String> pool,
    required Set<String> weak,
    required List<String> unseen,
  }) {
    final picks = <String>[];
    if (profile.weakShare > 0) {
      for (final qid
          in _shuffled(weak).take((size * profile.weakShare).round())) {
        picks.add(qid);
      }
    }
    final due = states.values
        .where((s) => !s.due.isAfter(dayEnd) && !picks.contains(s.questionId))
        .toList()
      ..sort((a, b) => a.due.compareTo(b.due));
    for (final s in due.take((size * 0.4).round())) {
      if (picks.length < size) picks.add(s.questionId);
    }
    for (final qid in unseen) {
      if (picks.length >= size) break;
      if (!states.containsKey(qid) && !picks.contains(qid)) picks.add(qid);
    }
    var guard = 0;
    while (picks.length < size && guard++ < size * 20) {
      final qid = pool[rng.nextInt(pool.length)];
      if (!picks.contains(qid)) picks.add(qid);
      if (picks.length >= pool.length) break;
    }
    return picks;
  }

  void _addSession({
    required int index,
    required DateTime day,
    required int size,
    required double progress,
    required List<String> pool,
    required Set<String> weak,
    required List<String> unseen,
  }) {
    final picks = _pick(
      size: size,
      dayEnd: _at(day, 23, 59),
      pool: pool,
      weak: weak,
      unseen: unseen,
    );
    if (picks.isEmpty) return;
    final origin = switch (index % 3) {
      0 => 'today_topic',
      1 => 'new_questions',
      _ => 'today_interleaved',
    };
    final sessionId = 'sample-$id-session-$index';
    final started = _at(day, 17 + rng.nextInt(4), 10 + rng.nextInt(40));
    // The questions the student keeps missing are right 20% of the time. The
    // rest are right often enough that the whole comes to the profile.
    final base = profile.weakShare > 0
        ? (profile.accuracy - profile.weakShare * 0.2) / (1 - profile.weakShare)
        : profile.accuracy;
    final accuracy = (base + (progress - 0.5) * 0.1).clamp(0.2, 0.95);
    var now = started;
    var correctCount = 0;
    var introduced = 0;
    final items = <AttemptItem>[];
    final outcomes = <Map<String, Object>>[];
    for (final qid in picks) {
      final q = known[qid]!;
      final correct = rng.nextDouble() <
          (weak.contains(qid) && profile.weakShare > 0 ? 0.2 : accuracy);
      final right = q.choices.firstWhere((c) => c.isCorrect);
      final wrong = _shuffled(q.choices.where((c) => !c.isCorrect)).first;
      final chosen = correct ? right : wrong;
      final responseMs = 4000 +
          rng.nextInt(16000) +
          (rng.nextDouble() < 0.05 ? 20000 : 0) +
          (correct ? 0 : 3000);
      now = now.add(Duration(milliseconds: responseMs));
      if (!states.containsKey(qid)) introduced++;
      final next =
          _review(q, correct: correct, responseMs: responseMs, at: now);
      if (correct) correctCount++;
      items.add(
        AttemptItem(
          questionId: qid,
          questionVersion: q.version,
          chosenChoiceId: chosen.id,
          correctChoiceId: right.id,
          responseMs: responseMs,
        ),
      );
      outcomes.add({
        'questionId': qid,
        'questionVersion': q.version,
        'chosenChoiceId': chosen.id,
        'correctChoiceId': right.id,
        'responseMs': responseMs,
        'derivedRating': next.rating.grade,
        'nextReviewIntervalDays': max(1, next.state.scheduledDays.ceil()),
      });
    }
    final completed = now.add(const Duration(seconds: 5));
    attempts.add(
      AttemptsLocalCompanion.insert(
        id: sessionId,
        examId: sampleExamId,
        startedAt: started,
        completedAt: Value(completed),
        origin: Value(origin),
        itemsJson: jsonEncode([for (final item in items) item.toJson()]),
      ),
    );
    sessions.add(
      QuizSessionsCompanion.insert(
        id: sessionId,
        userId: _localUser,
        examId: sampleExamId,
        origin: origin,
        topicId: origin == 'today_topic'
            ? Value<String?>(known[picks.first]!.topicId)
            : const Value<String?>.absent(),
        questionIdsJson: jsonEncode(picks),
        outcomesJson: Value(jsonEncode(outcomes)),
        currentIndex: Value(picks.length),
        correctCount: Value(correctCount),
        startedAt: started,
        lastAnsweredAt: Value(now),
        completedAt: Value(completed),
      ),
    );
    if (introduced > 0) newCardsByDay[day] = introduced;
    _creditStreak(completed);
  }

  /// One answer: the scheduler moves the state and a review log row records
  /// the state it started from, as the quiz does.
  ({Rating rating, ReviewState state}) _review(
    Question q, {
    required bool correct,
    required int responseMs,
    required DateTime at,
  }) {
    final prev = states[q.id] ??
        ReviewState.seed(questionId: q.id, questionVersion: q.version, now: at);
    final rating = FsrsRatingHeuristic.derive(
      isCorrect: correct,
      responseMs: responseMs,
      currentIntervalDays: 0,
    );
    final next = scheduler.next(prev: prev, rating: rating, now: at);
    states[q.id] = next;
    logs.add(
      ReviewLogsCompanion.insert(
        id: '${q.id}-${at.microsecondsSinceEpoch}',
        questionId: q.id,
        rating: rating.grade,
        state: prev.stage.index,
        due: prev.due,
        stability: prev.stability,
        difficulty: prev.difficulty,
        elapsedDays: prev.elapsedDays,
        lastElapsedDays: prev.elapsedDays,
        scheduledDays: prev.scheduledDays,
        review: at,
        durationMs: responseMs,
        isCorrect: correct,
        heuristicVersion: const Value(_ratingHeuristicVersion),
      ),
    );
    return (rating: rating, state: next);
  }

  void _creditStreak(DateTime completedAt) {
    final day = DateTime(completedAt.year, completedAt.month, completedAt.day);
    final last = lastActive;
    if (last == day) return;
    streak =
        last == null || studyDays.missedBetween(last, day) > 0 ? 1 : streak + 1;
    longest = max(longest, streak);
    lastActive = day;
  }

  void _addAssessment(DateTime day, List<AssessmentQuestion> questions) {
    final at = _at(day, 16, 30);
    var now = at;
    final scores = <String, ({int correct, int total})>{};
    final items = <AttemptItem>[];
    for (final item in questions) {
      final q = item.question;
      final correct = rng.nextDouble() < profile.accuracy;
      final right = q.choices.firstWhere((c) => c.isCorrect);
      final wrong = _shuffled(q.choices.where((c) => !c.isCorrect)).first;
      final responseMs = 6000 + rng.nextInt(14000);
      now = now.add(Duration(milliseconds: responseMs));
      final score = scores[item.topicId] ?? (correct: 0, total: 0);
      scores[item.topicId] = (
        correct: score.correct + (correct ? 1 : 0),
        total: score.total + 1,
      );
      items.add(
        AttemptItem(
          questionId: q.id,
          questionVersion: q.version,
          chosenChoiceId: (correct ? right : wrong).id,
          correctChoiceId: right.id,
          responseMs: responseMs,
        ),
      );
      // The placement test seeds the schedule with good or again.
      final prev = states[q.id] ??
          ReviewState.seed(
            questionId: q.id,
            questionVersion: q.version,
            now: now,
          );
      states[q.id] = scheduler.next(
        prev: prev,
        rating: correct ? Rating.good : Rating.again,
        now: now,
      );
    }
    attempts.add(
      AttemptsLocalCompanion.insert(
        id: 'sample-$id-assessment',
        examId: sampleExamId,
        startedAt: at,
        completedAt: Value(now),
        origin: const Value('assessment'),
        itemsJson: jsonEncode([for (final item in items) item.toJson()]),
      ),
    );
    assessment = AssessmentResultsLocalCompanion.insert(
      examId: sampleExamId,
      completedAt: now,
      topicScoresJson: jsonEncode([
        for (final entry in scores.entries)
          {
            'topicId': entry.key,
            'correct': entry.value.correct,
            'total': entry.value.total,
          },
      ]),
    );
  }

  void _addMock(
    int index,
    _Mock mock,
    List<({String id, String name, List<String> pool})> sections,
  ) {
    final mockId = 'sample-$id-mock-$index';
    final started = _at(mock.day, 9, 30);
    final sampled = <Map<String, Object>>[];
    final answers = <String, Map<String, int>>{};
    final results = <Map<String, Object>>[];
    final mirrored = <AttemptItem>[];
    final ratings = <({Question question, Rating rating})>[];
    var scoreRaw = 0;
    var scoreTotal = 0;
    var atSec = 0;
    for (final section in sections) {
      final ids = _shuffled(section.pool)
          .take(min(_mockQuestionsPerSection, section.pool.length))
          .toList();
      sampled.add({
        'sectionId': section.id,
        'name': section.name,
        'questionIds': ids,
      });
      final sectionStart = atSec;
      var correct = 0;
      var wrong = 0;
      var blank = 0;
      for (final qid in ids) {
        final q = known[qid]!;
        final correctIndex = q.choices.indexWhere((c) => c.isCorrect);
        final roll = rng.nextDouble();
        if (roll >= 0.97) {
          blank++;
          continue;
        }
        atSec += 25 + rng.nextInt(35);
        final isCorrect = roll < mock.accuracy;
        final others = [
          for (var k = 0; k < q.choices.length; k++)
            if (k != correctIndex) k,
        ];
        final selected = isCorrect ? correctIndex : _shuffled(others).first;
        answers[qid] = {'selectedIndex': selected, 'atSec': atSec};
        if (isCorrect) {
          correct++;
        } else {
          wrong++;
        }
        mirrored.add(
          AttemptItem(
            questionId: qid,
            questionVersion: q.version,
            chosenChoiceId: q.choices[selected].id,
            correctChoiceId: q.choices[correctIndex].id,
            responseMs: 0,
          ),
        );
        ratings.add(
          (question: q, rating: isCorrect ? Rating.good : Rating.again),
        );
      }
      scoreRaw += correct;
      scoreTotal += ids.length;
      results.add({
        'sectionId': section.id,
        'name': section.name,
        'correct': correct,
        'wrong': wrong,
        'blank': blank,
        'total': ids.length,
        'retiredCount': 0,
        'timeSeconds': atSec - sectionStart,
      });
    }
    final submitted = started.add(Duration(seconds: atSec));
    mocks.add(
      MockAttemptsCompanion.insert(
        id: mockId,
        userId: _localUser,
        examId: sampleExamId,
        blueprintId: _blueprintId,
        blueprintName: _blueprintName,
        durationMinutes: _mockMinutes,
        status: 'completed',
        strictMode: false,
        sampledQuestionsJson: jsonEncode(sampled),
        elapsedSeconds: Value(atSec),
        answersJson: Value(jsonEncode(answers)),
        currentIndex: Value(scoreTotal),
        scoreRaw: Value(scoreRaw),
        scoreTotal: Value(scoreTotal),
        sectionResultsJson: Value(jsonEncode({'sections': results})),
        totalTimeSeconds: Value(atSec),
        startedAt: started,
        lastFlushedAt: submitted,
        submittedAt: Value(submitted),
        updatedAt: submitted,
      ),
    );
    // A submitted mock is also recorded as ordinary answers, untimed.
    attempts.add(
      AttemptsLocalCompanion.insert(
        id: mockId,
        examId: sampleExamId,
        startedAt: started,
        completedAt: Value(submitted),
        origin: const Value('mock'),
        itemsJson: jsonEncode([for (final item in mirrored) item.toJson()]),
      ),
    );
    for (final entry in ratings) {
      final existing = states[entry.question.id];
      if (existing != null && existing.lastReview.isAfter(submitted)) continue;
      final prev = existing ??
          ReviewState.seed(
            questionId: entry.question.id,
            questionVersion: entry.question.version,
            now: submitted,
          );
      states[entry.question.id] =
          scheduler.next(prev: prev, rating: entry.rating, now: submitted);
    }
  }

  Future<void> write() async {
    await db.batch((batch) {
      _writeOnboarding(batch, db, stamp: today.toUtc(), examDate: examDate);

      final result = assessment;
      if (result != null) {
        batch.insert(
          db.assessmentResultsLocal,
          result,
          mode: InsertMode.insertOrReplace,
        );
      }
      batch
        ..insertAll(
          db.attemptsLocal,
          attempts,
          mode: InsertMode.insertOrReplace,
        )
        ..insertAll(db.quizSessions, sessions, mode: InsertMode.insertOrReplace)
        ..insertAll(db.reviewLogs, logs, mode: InsertMode.insertOrReplace)
        ..insertAll(
          db.lessonProgressLocal,
          lessonReads,
          mode: InsertMode.insertOrReplace,
        )
        ..insertAll(db.mockAttempts, mocks, mode: InsertMode.insertOrReplace)
        ..insertAll(
          db.reviewStateLocal,
          [
            for (final s in states.values)
              ReviewStateLocalCompanion.insert(
                questionId: s.questionId,
                questionVersion: s.questionVersion,
                stage: _stageText(s.stage),
                stability: s.stability,
                difficulty: s.difficulty,
                due: s.due,
                lastReview: s.lastReview,
                reps: s.reps,
                lapses: s.lapses,
                elapsedDays: s.elapsedDays,
                scheduledDays: s.scheduledDays,
              ),
          ],
          mode: InsertMode.insertOrReplace,
        )
        ..insertAll(
          db.dailyNewCardIntro,
          [
            for (final entry in newCardsByDay.entries)
              DailyNewCardIntroCompanion.insert(
                userId: _localUser,
                examId: sampleExamId,
                day: entry.key,
                newCardsIntroduced: Value(entry.value),
              ),
          ],
          mode: InsertMode.insertOrReplace,
        );
      _writeStreak(
        batch,
        db,
        streak: streak,
        longest: longest,
        lastActive: lastActive,
      );
    });
  }
}
