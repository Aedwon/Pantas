import 'dart:convert';

import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:pantas/features/metrics/signals/per_question_speed_signal.dart';
import 'package:pantas/features/metrics/signals/signal_content_helpers.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The fraction of a student's own average response time below which an answer
/// is considered "answered too fast" (rushed).
///
/// Set to 40% of the student's own average response time so the threshold
/// travels with them: a naturally fast reader is not accused of rushing.
const rushedThresholdFraction = 0.4;

/// Answers needed before this student has a pace to be "far below".
///
/// **Not in the plan, added 9 August.** The plan says "far below this
/// student's own distribution" and `PerQuestionSpeedSignal` returns a
/// distribution from a single answer, so without this a student with one
/// prior answer could be told they went too fast against an average of one.
///
/// Five follows the debrief's `rushedMinimumAnswers`, which makes the same
/// claim and gates it the same way. The pace panel and `averageResponseMs`
/// both gate at seven of their own units. **The number is Aedwon's to change;
/// having no floor at all was not defensible.**
const rushedMinimumAnswers = 5;

@immutable
class MissCauses {
  const MissCauses({
    required this.hadItRightBefore,
    required this.neverSeenIt,
    required this.answeredTooFast,
    required this.topicsByCause,
    required this.selfNotedMisreads,
  });

  /// A prior correct attempt on the same question. T1.
  final int hadItRightBefore;

  /// No prior attempt and no scheduler state. T1.
  final int neverSeenIt;

  /// responseMs far below this student's own distribution. T1.
  final int answeredTooFast;

  /// Pro only. Which topics each cause concentrates in.
  final Map<MissCause, List<String>> topicsByCause;

  /// Pro only. Misreads the student noted themselves in the debrief.
  /// Empty until Quiz plan 5 ships.
  final int selfNotedMisreads;

  int get total => hadItRightBefore + neverSeenIt + answeredTooFast;
}

enum MissCause { hadItRightBefore, neverSeenIt, answeredTooFast, unclassified }

final missCausesProvider = FutureProvider<MissCauses?>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final examId = focus.exam?.id;
  if (examId == null) return null;

  final db = ref.watch(appDatabaseProvider);
  final contentDb = ref.watch(contentDatabaseProvider);

  // 1. Fetch completed attempts for active exam in chronological order
  final attempts = await (db.select(db.attemptsLocal)
        ..where((r) => r.examId.equals(examId) & r.completedAt.isNotNull())
        ..orderBy([(r) => OrderingTerm.asc(r.startedAt)]))
      .get();

  if (attempts.isEmpty) return null;

  // 2. Fetch latency distribution from PerQuestionSpeedSignal
  final speedDistribution = await PerQuestionSpeedSignal(db).compute(
    window: ResolvedMetricsWindow(
      window: MetricsWindow.rolling30d,
      start: null,
      end: DateTime.now(),
      sessionCount: 1,
      minSessionCount: 0,
    ),
    examId: examId,
  );

  final answerCount = speedDistribution?.sampleCount ?? 0;
  final averageMs =
      answerCount >= rushedMinimumAnswers ? speedDistribution!.averageMs : 0;
  final thresholdMs = averageMs * rushedThresholdFraction;

  // 3. Fetch questions in reviewStateLocal
  final reviewStateRows = await db.select(db.reviewStateLocal).get();
  final reviewStateQuestionIds =
      reviewStateRows.map((r) => r.questionId).toSet();

  // 4. Topic names mapping helper
  final content = SignalContentHelpers(contentDb);
  final topicNameCache = <String, String>{};

  Future<String> getTopicName(String questionId) async {
    final topicId = await content.topicIdForQuestion(questionId);
    if (topicId == null) return 'Unknown';
    if (topicNameCache.containsKey(topicId)) {
      return topicNameCache[topicId]!;
    }
    final topicRow = await content.topic(topicId);
    final name = topicRow?.name ?? topicId;
    topicNameCache[topicId] = name;
    return name;
  }

  // 5. Track state across attempts
  final seenQuestionIds = <String>{};
  final priorCorrectQuestionIds = <String>{};

  var hadItRightBeforeCount = 0;
  var neverSeenItCount = 0;
  var answeredTooFastCount = 0;
  var selfNotedMisreadsCount = 0;
  var totalMissesCount = 0;

  final hadItRightTopics = <String>{};
  final neverSeenTopics = <String>{};
  final answeredTooFastTopics = <String>{};
  final unclassifiedTopics = <String>{};

  const itemReader = AttemptItemReader();

  for (final row in attempts) {
    final items = itemReader.read(row.itemsJson);
    final rawDecoded = jsonDecode(row.itemsJson) as List<dynamic>;

    for (var i = 0; i < items.length; i++) {
      final metricItem = items[i];

      // Check mistakeTag from raw json if available
      MistakeTag? tag;
      if (i < rawDecoded.length && rawDecoded[i] is Map<String, dynamic>) {
        final itemJson = rawDecoded[i] as Map<String, dynamic>;
        final tagStr = itemJson['mistakeTag'] as String?;
        if (tagStr != null) {
          tag = MistakeTag.values.firstWhere(
            (e) => e.name == tagStr,
            orElse: () => MistakeTag.unknown,
          );
        }
      }

      if (tag == MistakeTag.misread) {
        selfNotedMisreadsCount++;
      }

      if (!metricItem.isCorrect) {
        totalMissesCount++;

        final topicName = await getTopicName(metricItem.questionId);

        if (priorCorrectQuestionIds.contains(metricItem.questionId)) {
          hadItRightBeforeCount++;
          hadItRightTopics.add(topicName);
        } else if (!seenQuestionIds.contains(metricItem.questionId) &&
            !reviewStateQuestionIds.contains(metricItem.questionId)) {
          neverSeenItCount++;
          neverSeenTopics.add(topicName);
        } else if (!AttemptOrigins.untimed.contains(row.origin) &&
            averageMs > 0 &&
            metricItem.responseMs < thresholdMs) {
          answeredTooFastCount++;
          answeredTooFastTopics.add(topicName);
        } else {
          unclassifiedTopics.add(topicName);
        }
      }

      if (metricItem.isCorrect) {
        priorCorrectQuestionIds.add(metricItem.questionId);
      }
      seenQuestionIds.add(metricItem.questionId);
    }
  }

  if (totalMissesCount == 0) return null;

  return MissCauses(
    hadItRightBefore: hadItRightBeforeCount,
    neverSeenIt: neverSeenItCount,
    answeredTooFast: answeredTooFastCount,
    topicsByCause: {
      MissCause.hadItRightBefore: hadItRightTopics.toList(),
      MissCause.neverSeenIt: neverSeenTopics.toList(),
      MissCause.answeredTooFast: answeredTooFastTopics.toList(),
      MissCause.unclassified: unclassifiedTopics.toList(),
    },
    selfNotedMisreads: selfNotedMisreadsCount,
  );
});
