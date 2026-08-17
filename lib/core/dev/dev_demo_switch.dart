import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/content.dart';

/// A debug-only service extension that allows the `tools/demo` bash script
/// to reset the database and populate it with faux data.
Future<void> registerDevDemoSwitch(ProviderContainer container) async {
  if (!kDebugMode) return;

  final db = container.read(appDatabaseProvider);
  final contentDb = container.read(contentDatabaseProvider);

  developer.registerExtension('ext.pantas.demo', (method, parameters) async {
    final action = parameters['action'];
    if (action == 'reset') {
      await _resetData(db, clearPrefs: true);
    } else if (action == 'populate') {
      await _populateFauxData(db, contentDb);
    }
    
    // Invalidate app preferences so the app realizes it needs to re-read
    container.invalidate(appPreferencesRepositoryProvider);
    
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

Future<void> _populateFauxData(AppDatabase db, ContentDatabase contentDb) async {
  final currentExamIdRow = await (db.select(db.appPreferencesLocal)
        ..where((t) => t.key.equals('selected_exam_id')))
      .getSingleOrNull();
  final examId = currentExamIdRow?.value ?? 'exam_cse_pro';

  await _resetData(db, clearPrefs: false);

  final now = DateTime.now().toUtc();
  
  await db.transaction(() async {
    // Pass the age gate and setup an exam
    await db.into(db.appPreferencesLocal).insertOnConflictUpdate(
      const AppPreferencesLocalCompanion(
        key: Value('passed_age_gate'),
        value: Value('true'),
      ),
    );
    await db.into(db.appPreferencesLocal).insertOnConflictUpdate(
      AppPreferencesLocalCompanion(
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
        lastActiveDate: Value(DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1))),
        freezesRemaining: const Value(2),
      ),
    );

    // Filter lessons and questions by the current examId
    final subjects = await (contentDb.select(contentDb.contentSubjects)
          ..where((t) => t.examId.equals(examId)))
        .get();
    final subjectIds = subjects.map((s) => s.id).toList();

    List<String> topicIds = [];
    if (subjectIds.isNotEmpty) {
      final topics = await (contentDb.select(contentDb.contentTopics)
            ..where((t) => t.subjectId.isIn(subjectIds)))
          .get();
      topicIds = topics.map((t) => t.id).toList();
    }

    if (topicIds.isNotEmpty) {
      // Grab some lessons to mark as complete
      final lessons = await (contentDb.select(contentDb.contentLessons)
            ..where((t) => t.topicId.isIn(topicIds))
            ..limit(5))
          .get();
      for (final lesson in lessons) {
        await db.into(db.lessonProgressLocal).insertOnConflictUpdate(
          LessonProgressLocalCompanion.insert(
            lessonId: lesson.id,
            readAt: now.subtract(const Duration(days: 1)),
          ),
        );
      }

      // Grab some questions to mark as attempted
      final questions = await (contentDb.select(contentDb.contentQuestions)
            ..where((t) => t.topicId.isIn(topicIds))
            ..limit(100))
          .get();
      final rng = Random();
      for (final q in questions) {
        await db.into(db.reviewStateLocal).insertOnConflictUpdate(
          ReviewStateLocalCompanion.insert(
            questionId: q.id,
            questionVersion: q.version,
            stage: 'review',
            stability: 0.5 + (rng.nextDouble() * 0.5),
            difficulty: 0.5,
            due: now.subtract(Duration(hours: rng.nextInt(24))),
            lastReview: now.subtract(Duration(days: 1 + rng.nextInt(3))),
            reps: 2 + rng.nextInt(3),
            lapses: 0,
            elapsedDays: 0.0,
            scheduledDays: 0.0,
          ),
        );
      }

      final topicScores = [
        for (final id in topicIds)
          {
            'topicId': id,
            'correct': 6 + rng.nextInt(5),
            'total': 10,
          }
      ];
      await db.into(db.assessmentResultsLocal).insertOnConflictUpdate(
        AssessmentResultsLocalCompanion.insert(
          examId: examId,
          completedAt: now.subtract(const Duration(days: 2)),
          topicScoresJson: jsonEncode(topicScores),
        ),
      );
      
      // Ensure we have enough questions to distribute
      final questionIds = questions.map((q) => q.id).toList();
      final mockQ1 = questionIds.isNotEmpty ? questionIds[0] : 'q_1';
      final mockQ2 = questionIds.length > 1 ? questionIds[1] : 'q_2';

      // Generate 14 quiz attempts over the last 14 days
      for (int i = 0; i < 14; i++) {
        final daysAgo = 14 - i;
        final attemptDate = now.subtract(Duration(days: daysAgo, hours: 2));
        
        final attemptItems = List.generate(2, (j) {
          final isCorrect = rng.nextDouble() > 0.3; // 70% accuracy
          final responseMs = isCorrect ? 8000 + rng.nextInt(5000) : 15000 + rng.nextInt(10000); 
          final qId = (j == 0) ? mockQ1 : mockQ2;
          return {
            'questionId': qId,
            'questionVersion': 1,
            'chosenChoiceId': isCorrect ? 'c_1' : 'c_2',
            'correctChoiceId': 'c_1', // Using fake choices, attempt reader doesn't check correctIndex for quizzes, just checks chosenChoiceId == correctChoiceId!
            'responseMs': responseMs,
          };
        });

        await db.into(db.attemptsLocal).insertOnConflictUpdate(
          AttemptsLocalCompanion.insert(
            id: 'fake_attempt_$i',
            examId: examId,
            startedAt: attemptDate,
            completedAt: Value(attemptDate.add(const Duration(minutes: 10))),
            origin: const Value('today_topic'),
            itemsJson: jsonEncode(attemptItems),
          ),
        );
        
        await db.into(db.quizSessions).insertOnConflictUpdate(
          QuizSessionsCompanion.insert(
            id: 'fake_quiz_session_$i',
            userId: 'local',
            examId: examId,
            origin: 'today_topic',
            questionIdsJson: '[]',
            startedAt: attemptDate,
            completedAt: Value(attemptDate.add(const Duration(minutes: 10))),
            currentIndex: const Value(2),
            correctCount: const Value(1),
          ),
        );
      }

      // Generate 2 MockAttempts
      for (int i = 0; i < 2; i++) {
        final daysAgo = 10 - (i * 5); // 10 days ago, 5 days ago
        final attemptDate = now.subtract(Duration(days: daysAgo));
        
        // Mock payload JSONs
        final sampledQuestions = [
          {
            'sectionId': 'sec_1',
            'name': 'Section 1',
            'questionIds': [mockQ1, mockQ2],
          }
        ];
        
        final mockAnswers = {
          mockQ1: {'selectedIndex': 0, 'atSec': 30},
          mockQ2: {'selectedIndex': 1, 'atSec': 45}, 
        };

        final sectionResults = [
          {
            'sectionId': 'sec_1',
            'name': 'Section 1',
            'correct': 1,
            'total': 2,
            'retiredCount': 0,
            'timeSeconds': 120,
          }
        ];

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
            elapsedSeconds: const Value(7200),
            scoreRaw: Value(65 + (i * 10)),
            scoreTotal: const Value(100),
            answersJson: Value(jsonEncode(mockAnswers)),
            sectionResultsJson: Value(jsonEncode(sectionResults)),
            startedAt: attemptDate,
            lastFlushedAt: attemptDate,
            submittedAt: Value(attemptDate.add(const Duration(hours: 2))),
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
