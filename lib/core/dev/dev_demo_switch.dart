import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';

/// A debug-only service extension that allows the `tools/demo` bash script
/// to reset the database and populate it with faux data.
Future<void> registerDevDemoSwitch(ProviderContainer container) async {
  if (!kDebugMode) return;

  final db = container.read(appDatabaseProvider);
  final contentDb = container.read(contentDatabaseProvider);

  developer.registerExtension('ext.pantas.demo', (method, parameters) async {
    final action = parameters['action'];
    if (action == 'reset') {
      await _resetData(db);
    } else if (action == 'populate') {
      await _populateFauxData(db, contentDb);
    }

    // Invalidate all providers so memory caches clear immediately
    for (final element in container.getAllProviderElements()) {
      element.invalidateSelf();
    }

    return developer.ServiceExtensionResponse.result(
      jsonEncode({'status': 'ok', 'action': action}),
    );
  });
}

Future<void> _resetData(AppDatabase db, {bool clearPrefs = true}) async {
  await db.transaction(() async {
    if (clearPrefs) {
      await db.delete(db.accountPrefs).go();
      await db.delete(db.appPreferencesLocal).go();
      await db.delete(db.devicePrefs).go();
    }
    await db.delete(db.assessmentResultsLocal).go();
    await db.delete(db.attemptsLocal).go();
    await db.delete(db.customBlueprintsLocal).go();
    await db.delete(db.dailyNewCardIntro).go();
    await db.delete(db.lessonBookmarksLocal).go();
    await db.delete(db.lessonProgressLocal).go();
    await db.delete(db.mockAttempts).go();
    await db.delete(db.pendingSync).go();
    await db.delete(db.questionFlagsLocal).go();
    await db.delete(db.quizNudgeDismissedLocal).go();
    await db.delete(db.quizSessions).go();
    await db.delete(db.reviewLogs).go();
    await db.delete(db.reviewStateLocal).go();
    await db.delete(db.streakLocal).go();
    await db.delete(db.syncMeta).go();
    await db.delete(db.trackScopeLocal).go();
    await db.delete(db.userMetricsArchetypesLocal).go();
    await db.delete(db.userMetricsArtifactsLocal).go();
  });
}

Future<void> _populateFauxData(
  AppDatabase db,
  ContentDatabase contentDb,
) async {
  debugPrint('DEMO: _populateFauxData CALLED!');
  final currentExamIdRow = await (db.select(db.devicePrefs)
        ..where((t) => t.key.equals('selected_exam_id')))
      .getSingleOrNull();

  String? legacyExamId;
  if (currentExamIdRow == null) {
    final legacyRow = await (db.select(db.appPreferencesLocal)
          ..where((t) => t.key.equals('selected_exam_id')))
        .getSingleOrNull();
    legacyExamId = legacyRow?.value;
  }

  var fallbackExamId = 'exam_cse_pro';
  final activeExams = await (contentDb.select(contentDb.contentExams)
        ..where((e) => e.isActive.equals(true)))
      .get();
  if (activeExams.isNotEmpty) {
    fallbackExamId = activeExams.first.id;
  }

  final examId = currentExamIdRow?.value ?? legacyExamId ?? fallbackExamId;
  debugPrint('DEMO: Generating data for examId = $examId');

  await _resetData(db, clearPrefs: false);

  final now = DateTime.now().toUtc();

  await db.transaction(() async {
    // Pass the age gate and setup an exam
    await db.into(db.devicePrefs).insertOnConflictUpdate(
          const DevicePrefsCompanion(
            key: Value('passed_age_gate'),
            value: Value('true'),
          ),
        );
    await db.into(db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion(
            key: const Value('selected_exam_id'),
            value: Value(examId),
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          const AccountPrefsCompanion(
            key: Value('exam_date'),
            value: Value('2027-03-15'),
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          const AccountPrefsCompanion(
            key: Value('exam_date_precision'),
            value: Value('day'),
          ),
        );

    // Insert fake streak
    await db.into(db.streakLocal).insertOnConflictUpdate(
          StreakLocalCompanion.insert(
            current: const Value(3),
            longest: const Value(5),
            lastActiveDate: Value(
              DateTime(now.year, now.month, now.day)
                  .subtract(const Duration(days: 1)),
            ),
            freezesRemaining: const Value(2),
          ),
        );

    // Filter lessons and questions by the current examId
    final subjects = await (contentDb.select(contentDb.contentSubjects)
          ..where((t) => t.examId.equals(examId)))
        .get();
    final subjectIds = subjects.map((s) => s.id).toList();

    if (subjectIds.isNotEmpty) {
      final topics = await (contentDb.select(contentDb.contentTopics)
            ..where((t) => t.subjectId.isIn(subjectIds)))
          .get();
      final topicIds = topics.map((t) => t.id).toList();

      final lessons = await (contentDb.select(contentDb.contentLessons)
            ..where((l) => l.topicId.isIn(topicIds)))
          .get();

      final questions = await (contentDb.select(contentDb.contentQuestions)
            ..where((q) => q.topicId.isIn(topicIds)))
          .get();

      final choicesRows = await (contentDb.select(contentDb.contentChoices)
            ..where((c) => c.isActive.equals(true)))
          .get();

      final choicesByQuestion = <String, List<ContentChoiceRow>>{};
      for (final c in choicesRows) {
        choicesByQuestion.putIfAbsent(c.questionId, () => []).add(c);
      }

      final correctIndexByQuestion = <String, int>{};
      final correctChoiceIdByQuestion = <String, String>{};
      final wrongChoiceIdByQuestion = <String, String>{};

      for (final entry in choicesByQuestion.entries) {
        final sorted = entry.value
          ..sort((a, b) => a.ordering.compareTo(b.ordering));
        for (var i = 0; i < sorted.length; i++) {
          if (sorted[i].isCorrect) {
            correctIndexByQuestion[entry.key] = i;
            correctChoiceIdByQuestion[entry.key] = sorted[i].id;
          } else {
            wrongChoiceIdByQuestion[entry.key] = sorted[i].id;
          }
        }
      }

      final rng = Random();

      // 0. Assessment Result
      debugPrint(
        'DEMO: Injecting faux assessment result for exam $examId with '
        'topics: ${topics.length}',
      );
      // Insert a faux assessment result so the Home tab thinks we took it.
      final topicScores = <Map<String, dynamic>>[];
      for (var i = 0; i < topics.length && i < 5; i++) {
        topicScores.add({
          'topicId': topics[i].id,
          'correct': 3 + rng.nextInt(3), // 3 to 5
          'total': 5,
        });
      }

      debugPrint('DEMO: topicScoresJson = ${jsonEncode(topicScores)}');

      try {
        await db.into(db.assessmentResultsLocal).insertOnConflictUpdate(
              AssessmentResultsLocalCompanion.insert(
                examId: examId,
                completedAt: now.subtract(const Duration(days: 60)),
                topicScoresJson: jsonEncode(topicScores),
              ),
            );
        debugPrint('DEMO: Inserted assessment result successfully!');
      } catch (e, stack) {
        debugPrint(
          'DEMO ERROR: Failed to insert assessment result: $e\n$stack',
        );
      }

      // 1. Lesson Progress
      // Distribute lesson reads over the last 60 days
      for (var i = 0; i < lessons.length; i++) {
        // ~80% completion
        if (rng.nextDouble() < 0.2) continue;

        final daysAgo = 60 - rng.nextInt(60);
        await db.into(db.lessonProgressLocal).insertOnConflictUpdate(
              LessonProgressLocalCompanion.insert(
                lessonId: lessons[i].id,
                readAt: now.subtract(Duration(days: daysAgo)),
              ),
            );
      }

      // 2. Review States (Spaced Repetition)
      for (final q in questions) {
        if (rng.nextDouble() < 0.3) continue; // 70% of questions are in review

        final isMature = rng.nextDouble() > 0.5;
        await db.into(db.reviewStateLocal).insertOnConflictUpdate(
              ReviewStateLocalCompanion.insert(
                questionId: q.id,
                questionVersion: q.version,
                stage: 'review',
                stability: isMature
                    ? 5.0 + rng.nextDouble() * 20.0
                    : 0.5 + rng.nextDouble() * 2.0,
                difficulty: 0.2 + rng.nextDouble() * 0.6,
                due: now.subtract(Duration(hours: rng.nextInt(72))),
                lastReview: now.subtract(Duration(days: 1 + rng.nextInt(10))),
                reps: isMature ? 5 + rng.nextInt(10) : 1 + rng.nextInt(3),
                lapses: rng.nextInt(2),
                elapsedDays: isMature ? 10.0 + rng.nextDouble() * 10 : 2.0,
                scheduledDays: isMature ? 20.0 : 3.0,
              ),
            );
      }

      // 3. Quiz Attempts (120 quizzes over 60 days)
      for (var i = 0; i < 120; i++) {
        final daysAgo = 60 - (i / 2).floor();
        final attemptDate = now.subtract(
          Duration(days: daysAgo, hours: rng.nextInt(12) + 8),
        ); // 8am to 8pm

        // Progress from 40% accuracy to 85% accuracy
        final progressRatio =
            1.0 - (daysAgo / 60.0); // 0.0 at day 60, 1.0 at day 0
        final targetAccuracy = 0.40 + (0.45 * progressRatio);

        // Speed progresses from 20s to 8s
        final targetSpeedMs = 20000 - (12000 * progressRatio).round();

        // Pick a random topic for this session
        final topic = topics[rng.nextInt(topics.length)];
        final topicQuestions =
            questions.where((q) => q.topicId == topic.id).toList();
        if (topicQuestions.isEmpty) continue;

        topicQuestions.shuffle(rng);
        final sessionQuestions =
            topicQuestions.take(10).toList(); // Up to 10 questions

        var correctCount = 0;
        final attemptItems = <Map<String, dynamic>>[];

        for (final q in sessionQuestions) {
          final isCorrect = rng.nextDouble() < targetAccuracy;
          if (isCorrect) correctCount++;

          // Speed varies randomly around target speed
          final responseMs =
              (targetSpeedMs * (0.8 + rng.nextDouble() * 0.4)).round();

          final correctId = correctChoiceIdByQuestion[q.id] ?? 'c_1';
          final wrongId = wrongChoiceIdByQuestion[q.id] ?? 'c_2';

          attemptItems.add({
            'questionId': q.id,
            'questionVersion': q.version,
            'chosenChoiceId': isCorrect ? correctId : wrongId,
            'correctChoiceId': correctId,
            'responseMs': responseMs,
          });
        }

        final sessionId = 'fake_quiz_session_$i';

        await db.into(db.attemptsLocal).insertOnConflictUpdate(
              AttemptsLocalCompanion.insert(
                id: 'fake_attempt_$i',
                examId: examId,
                startedAt: attemptDate,
                completedAt:
                    Value(attemptDate.add(const Duration(minutes: 10))),
                origin: const Value('today_topic'),
                itemsJson: jsonEncode(attemptItems),
              ),
            );

        await db.into(db.quizSessions).insertOnConflictUpdate(
              QuizSessionsCompanion.insert(
                id: sessionId,
                userId: 'local',
                examId: examId,
                origin: 'today_topic',
                questionIdsJson:
                    jsonEncode(sessionQuestions.map((q) => q.id).toList()),
                startedAt: attemptDate,
                completedAt:
                    Value(attemptDate.add(const Duration(minutes: 10))),
                currentIndex: Value(sessionQuestions.length),
                correctCount: Value(correctCount),
              ),
            );
      }

      // 4. Mock Exams (4 mocks evenly spaced: 45, 30, 15, 1 days ago)
      final mockIntervals = [45, 30, 15, 1];
      for (var i = 0; i < mockIntervals.length; i++) {
        final daysAgo = mockIntervals[i];
        final attemptDate =
            now.subtract(Duration(days: daysAgo, hours: 9)); // 9 AM mock

        final progressRatio = 1.0 - (daysAgo / 60.0);
        final targetAccuracy = 0.45 + (0.37 * progressRatio); // 45% -> 82%

        final sampledQuestions = <Map<String, dynamic>>[];
        final mockAnswers = <String, Map<String, dynamic>>{};
        final sectionResults = <Map<String, dynamic>>[];

        var totalRawScore = 0;
        var totalQuestions = 0;
        var totalElapsedSeconds = 0;

        for (var s = 0; s < subjects.length; s++) {
          final subject = subjects[s];
          final subjectTopics = topics
              .where((t) => t.subjectId == subject.id)
              .map((t) => t.id)
              .toSet();
          final subjectQs = questions
              .where((q) => subjectTopics.contains(q.topicId))
              .toList();

          if (subjectQs.isEmpty) continue;

          // Take up to 20 questions per subject
          subjectQs.shuffle(rng);
          final sectionQs = subjectQs.take(20).toList();

          sampledQuestions.add({
            'sectionId': 'sec_$s',
            'name': subject.name,
            'questionIds': sectionQs.map((q) => q.id).toList(),
          });

          var secCorrect = 0;
          var secElapsed = 0;

          for (final q in sectionQs) {
            totalQuestions++;
            // First half vs second half stamina diff
            final isFirstHalf = totalQuestions < (subjects.length * 10);
            final staminaMod = isFirstHalf ? 0.05 : -0.05;
            final isCorrect = rng.nextDouble() < (targetAccuracy + staminaMod);

            if (isCorrect) {
              secCorrect++;
              totalRawScore++;
            }

            final correctIdx = correctIndexByQuestion[q.id] ?? 0;
            final wrongIdx = (correctIdx == 0) ? 1 : 0;
            final selectedIdx = isCorrect ? correctIdx : wrongIdx;

            final qTime = 15 + rng.nextInt(30);
            secElapsed += qTime;

            mockAnswers[q.id] = {
              'selectedIndex': selectedIdx,
              'atSec': secElapsed + totalElapsedSeconds,
            };
          }

          sectionResults.add({
            'sectionId': 'sec_$s',
            'name': subject.name,
            'correct': secCorrect,
            'total': sectionQs.length,
            'retiredCount': 0,
            'timeSeconds': secElapsed,
          });

          totalElapsedSeconds += secElapsed;
        }

        await db.into(db.mockAttempts).insertOnConflictUpdate(
              MockAttemptsCompanion.insert(
                id: 'fake_mock_$i',
                userId: 'local',
                examId: examId,
                blueprintId: 'bp_$i',
                blueprintName: 'Full Mock Exam ${i + 1}',
                durationMinutes: 180,
                status: 'completed',
                strictMode: true,
                sampledQuestionsJson: jsonEncode(sampledQuestions),
                elapsedSeconds: Value(totalElapsedSeconds),
                scoreRaw: Value(totalRawScore),
                scoreTotal: Value(totalQuestions),
                answersJson: Value(jsonEncode(mockAnswers)),
                sectionResultsJson: Value(jsonEncode(sectionResults)),
                startedAt: attemptDate,
                lastFlushedAt: attemptDate,
                submittedAt: Value(
                  attemptDate.add(Duration(seconds: totalElapsedSeconds)),
                ),
                updatedAt: attemptDate,
              ),
            );
      }

      await db.into(db.userMetricsArchetypesLocal).insertOnConflictUpdate(
            UserMetricsArchetypesLocalCompanion.insert(
              userId: 'local',
              examId: examId,
              window: 'prepWindow',
              archetypeId: 'night_owl_sprinter',
              matchScore: 0.95,
              synthesizedCopy: 'Sharpest at 9 pm, in 8 minute sits.',
              computedAt: now,
              validUntil: now.add(const Duration(days: 7)),
            ),
          );
    }
  });
}
