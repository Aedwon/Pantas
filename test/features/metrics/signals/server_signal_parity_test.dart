import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_resolver.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';
import 'package:pantas/features/metrics/signals/mock_pacing_signal.dart';
import 'package:pantas/features/metrics/signals/mock_stamina_signal.dart';
import 'package:pantas/features/metrics/signals/per_question_speed_signal.dart';
import 'package:pantas/features/metrics/signals/read_then_quiz_signal.dart';
import 'package:pantas/features/metrics/signals/retention_shape_signal.dart';
import 'package:pantas/features/metrics/signals/session_shape_signal.dart';
import 'package:pantas/features/metrics/signals/subject_affinity_signal.dart';
import 'package:pantas/features/metrics/signals/test_mode_delta_signal.dart';
import 'package:pantas/features/metrics/signals/time_of_day_signal.dart';

import '../../../../server_dart/insights_codec.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  for (final scenario in ['early', 'forming', 'clear']) {
    test('populated native readers and bridge agree: $scenario', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final content = ContentDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      addTearDown(content.close);
      const exam = 'exam_cse';
      final now = DateTime(2026, 10, 24, 10);
      final started = DateTime(2026, 10, 20, 9);
      final finished = started.add(const Duration(minutes: 10));
      final count = scenario == 'early' ? 2 : 120;
      final correctCount = scenario == 'clear' ? 30 : count ~/ 2;
      await seedContentExam(
        content,
        examId: exam,
        code: 'CSE',
        name: 'Civil Service',
        shortName: 'CSE',
      );
      await seedContentSubject(
        content,
        subjectId: 'subject',
        examId: exam,
        name: 'Verbal',
      );
      final lessonRows = <Map<String, Object?>>[];
      for (var i = 0; i < 12; i++) {
        final topic = 'topic$i';
        final lesson = 'lesson$i';
        await seedContentTopic(
          content,
          topicId: topic,
          subjectId: 'subject',
          name: topic,
        );
        await seedContentLesson(
          content,
          lessonId: lesson,
          topicId: topic,
          title: lesson,
          summary: '',
          bodyJson: '{}',
        );
        final readFirst = scenario == 'clear' ? i < 11 : i < 6;
        final readAt = started.add(Duration(days: readFirst ? -1 : 1));
        await db.into(db.lessonProgressLocal).insert(
              LessonProgressLocalCompanion.insert(
                lessonId: lesson,
                readAt: readAt,
              ),
            );
        lessonRows.add({
          'examId': exam,
          'topicId': topic,
          'readAt': readAt.toIso8601String(),
        });
      }
      final nativeItems = <Map<String, Object?>>[];
      final items = <Map<String, Object?>>[];
      for (var i = 0; i < count; i++) {
        final id = 'q$i';
        await seedContentQuestionWithChoices(
          content,
          questionId: id,
          topicId: 'topic${i % 12}',
          examId: exam,
          choices: [
            {'id': '${id}_a', 'label': 'A', 'text': 'A', 'isCorrect': true},
            {'id': '${id}_b', 'label': 'B', 'text': 'B', 'isCorrect': false},
          ],
          stem: id,
          explanation: '',
        );
        final correct = i < correctCount;
        final ms = scenario == 'clear'
            ? (correct ? 8000 : 20000) + i % 7 * 100
            : 10000 + i % 5 * 100;
        nativeItems.add({
          'questionId': id,
          'questionVersion': 1,
          'chosenChoiceId': correct ? 'a' : 'b',
          'correctChoiceId': 'a',
          'responseMs': ms,
        });
        items.add({
          'questionId': id,
          'correct': correct,
          'chosen': correct ? 'a' : 'b',
          'responseMs': ms,
          'questionVersion': 1,
          'topicId': 'topic${i % 12}',
          'subjectName': 'Verbal',
        });
      }
      await db.into(db.attemptsLocal).insert(
            AttemptsLocalCompanion.insert(
              id: 'practice',
              examId: exam,
              origin: const Value('drill'),
              startedAt: started,
              completedAt: Value(finished),
              itemsJson: jsonEncode(nativeItems),
            ),
          );
      final sessionRows = <Map<String, Object?>>[];
      for (var i = 0; i < 14; i++) {
        await db.into(db.quizSessions).insert(
              QuizSessionsCompanion.insert(
                id: 'session$i',
                userId: 'user',
                examId: exam,
                origin: 'drill',
                questionIdsJson: '[]',
                currentIndex: Value(i == 0 ? count : 0),
                correctCount: Value(i == 0 ? correctCount : 0),
                startedAt: started,
                completedAt: Value(finished),
              ),
            );
        sessionRows.add({
          'examId': exam,
          'origin': 'drill',
          'startedAt': started.toIso8601String(),
          'finishedAt': finished.toIso8601String(),
          'total': i == 0 ? count : 0,
          'correct': i == 0 ? correctCount : 0,
        });
      }
      final mockRows = <Map<String, Object?>>[];
      if (scenario != 'early') {
        final selected = <String, Object?>{};
        final observations = <Map<String, Object?>>[];
        for (var i = 0; i < 60; i++) {
          // Includes real blanks in both halves. Native stamina counts them,
          // pressure excludes them, and original order fixes the midpoint.
          final blank = i == 12 || i == 42;
          final correct =
              scenario == 'clear' ? (i < 30 ? i < 6 : i < 54) : i.isEven;
          if (!blank) {
            selected['q$i'] = {'selectedIndex': correct ? 0 : 1, 'atSec': i};
          }
          observations.add({
            'questionId': 'q$i',
            'chosen': blank
                ? null
                : correct
                    ? 'a'
                    : 'b',
            'correct': !blank && correct,
          });
        }
        final submitted = started.add(const Duration(hours: 2));
        final correct = observations.where((r) => r['correct']! as bool).length;
        await db.into(db.mockAttempts).insert(
              MockAttemptsCompanion.insert(
                id: 'mock',
                userId: 'user',
                examId: exam,
                blueprintId: 'bp',
                blueprintName: 'Mock',
                durationMinutes: 90,
                status: 'completed',
                strictMode: false,
                sampledQuestionsJson: jsonEncode([
                  {
                    'sectionId': 's',
                    'name': 'Part',
                    'questionIds': [for (var i = 0; i < 60; i++) 'q$i'],
                  }
                ]),
                answersJson: Value(jsonEncode(selected)),
                scoreRaw: Value(correct),
                scoreTotal: const Value(60),
                totalTimeSeconds: const Value(5400),
                startedAt: started,
                submittedAt: Value(submitted),
                lastFlushedAt: submitted,
                updatedAt: submitted,
              ),
            );
        mockRows.add({
          'examId': exam,
          'status': 'completed',
          'startedAt': started.toIso8601String(),
          'submittedAt': submitted.toIso8601String(),
          'durationMs': 5400000,
          'limitMs': 5400000,
          'scoreRaw': correct,
          'scoreTotal': 60,
          'items': observations,
        });
      }
      final reps = scenario == 'clear'
          ? 101
          : scenario == 'forming'
              ? 21
              : 1;
      final lapses = scenario == 'forming' ? 10 : 0;
      await db.into(db.reviewStateLocal).insert(
            ReviewStateLocalCompanion.insert(
              questionId: 'q0',
              questionVersion: 1,
              stage: 'review',
              stability: 9,
              difficulty: 5,
              due: now,
              lastReview: started,
              reps: reps,
              lapses: lapses,
              elapsedDays: 1,
              scheduledDays: 9,
            ),
          );
      final input = <String, Object?>{
        'examId': exam,
        'now': now.toIso8601String(),
        'sessions': sessionRows,
        'attempts': [
          {
            'examId': exam,
            'origin': 'drill',
            'startedAt': started.toIso8601String(),
            'finishedAt': finished.toIso8601String(),
            'items': items,
          }
        ],
        'mocks': mockRows,
        'lessons': lessonRows,
        'reviews': [
          {'stability': 9, 'reps': reps, 'lapses': lapses},
        ],
        'topics': [],
      };
      final bridge = studyInsightsFromJson(input);
      final tendencies = bridge['tendencies']! as Map<String, Object?>;
      final window = ResolvedMetricsWindow(
        window: MetricsWindow.prepWindow,
        start: null,
        end: now,
        sessionCount: 14 + mockRows.length,
        minSessionCount: 0,
      );
      final speed = (await PerQuestionSpeedSignal(db)
          .compute(window: window, examId: exam))!;
      final pressure = (await TestModeDeltaSignal(db, content)
          .compute(window: window, examId: exam))!;
      final stamina = await MockStaminaSignal(db, content)
          .compute(window: window, examId: exam);
      final workflow = (await ReadThenQuizSignal(db, content)
          .compute(window: window, examId: exam))!;
      final memory = (await RetentionShapeSignal(db)
          .compute(window: window, examId: exam))!;
      final confidence = {
        'speed': TendencyEvidence.speed(speed),
        'pressure': TendencyEvidence.pressure(pressure),
        'stamina': stamina == null
            ? TendencyConfidence.early
            : TendencyEvidence.stamina(stamina),
        'study': TendencyEvidence.study(workflow),
        'memory': TendencyEvidence.memory(memory),
      };
      for (final entry in confidence.entries) {
        final actual = tendencies[entry.key]! as Map<String, Object?>;
        expect(
          actual['confidence'],
          entry.value.name,
          reason: '$scenario ${entry.key}',
        );
        if (entry.value != TendencyConfidence.clear) {
          expect(actual['value'], isNull);
        }
      }
      if (confidence['speed'] == TendencyConfidence.clear) {
        final value = (tendencies['speed']! as Map)['value']! as Map;
        expect(value['correctLogMean'], speed.correctLogMean);
        expect(value['incorrectLogVariance'], speed.incorrectLogVariance);
      }
      if (confidence['pressure'] == TendencyConfidence.clear) {
        final value = (tendencies['pressure']! as Map)['value']! as Map;
        expect(value['practiceTotal'], pressure.practiceTotal);
        expect(value['mockTotal'], pressure.mockTotal);
      }
      final hours =
          (await TimeOfDaySignal(db).compute(window: window, examId: exam))!;
      final duration =
          (await SessionShapeSignal(db).compute(window: window, examId: exam))!;
      final affinity = await SubjectAffinitySignal(db, content)
          .compute(window: window, examId: exam);
      final pace =
          await MockPacingSignal(db).compute(window: window, examId: exam);
      final profile = const ArchetypeResolver().resolve(archetypeCatalog, {
        SignalKey.timeOfDay: hours,
        SignalKey.sessionShape: duration,
        SignalKey.perQuestionSpeed: speed,
        if (pressure.practiceTotal > 0 && pressure.mockTotal > 0)
          SignalKey.testModeDelta: pressure,
        if (stamina != null) SignalKey.mockStamina: stamina,
        if (workflow.readThenQuizCount + workflow.quizFirstCount > 0)
          SignalKey.readThenQuiz: workflow,
        SignalKey.retentionShape: memory,
        if (affinity != null) SignalKey.subjectAffinity: affinity,
        if (pace != null) SignalKey.mockPacing: pace,
      });
      expect((bridge['profile'] as Map?)?['id'], profile?.id);
      final when = bridge['whenYouWork']! as Map;
      expect(when['sessionCount'], duration.sessionCount);
      expect(when['averageMinutes'], duration.averageMinutes);
      expect(
        when['peakHour'],
        ([...hours.buckets]..sort((a, b) => b.accuracy.compareTo(a.accuracy)))
            .first
            .hour,
      );
      final dir = Directory('build/w4b-server/parity')
        ..createSync(recursive: true);
      File('${dir.path}/$scenario.json').writeAsStringSync(jsonEncode(input));
      File('${dir.path}/$scenario.expected.json')
          .writeAsStringSync(jsonEncode(bridge));
    });
  }
}
