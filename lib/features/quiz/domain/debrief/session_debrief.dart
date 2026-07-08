import 'dart:math';

import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/debrief/miss_cause.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';

class DebriefMiss {
  const DebriefMiss({
    required this.questionId,
    required this.label,
    required this.labelIsStem,
    required this.topicName,
    required this.pickedLabel,
    required this.answerLabel,
    this.cause,
    this.tag,
  });

  final QuestionId questionId;
  final String label;
  final bool labelIsStem;
  final String topicName;
  final String pickedLabel;
  final String answerLabel;
  final MissCause? cause;
  final MistakeTag? tag;

  DebriefMiss copyWith({
    MistakeTag? tag,
  }) {
    return DebriefMiss(
      questionId: questionId,
      label: label,
      labelIsStem: labelIsStem,
      topicName: topicName,
      pickedLabel: pickedLabel,
      answerLabel: answerLabel,
      cause: cause,
      tag: tag ?? this.tag,
    );
  }
}

class SessionDebrief {
  const SessionDebrief({
    required this.headline,
    required this.correct,
    required this.total,
    required this.minutes,
    required this.sourceLine,
    required this.misses,
    required this.returnPromise,
  });

  final String headline;
  final int correct;
  final int total;
  final int minutes;
  final String sourceLine;
  final List<DebriefMiss> misses;
  final String returnPromise;

  bool get isClean => misses.isEmpty;
}

const _spelledHeadline = <int, String>{
  1: 'One',
  2: 'Two',
  3: 'Three',
  4: 'Four',
  5: 'Five',
  6: 'Six',
  7: 'Seven',
  8: 'Eight',
  9: 'Nine',
  10: 'Ten',
  11: 'Eleven',
  12: 'Twelve',
  15: 'Fifteen',
  20: 'Twenty',
};

const _spelledLower = <int, String>{
  1: 'one',
  2: 'two',
  3: 'three',
  4: 'four',
  5: 'five',
  6: 'six',
  7: 'seven',
  8: 'eight',
  9: 'nine',
  10: 'ten',
  11: 'eleven',
  12: 'twelve',
  15: 'fifteen',
  20: 'twenty',
};

abstract class BuildSessionDebrief {
  static SessionDebrief call({
    required QuizSession session,
    required Map<TopicId, String> topicNames,
    required Map<TopicId, int> topicAverageMs,
    required Map<TopicId, int> topicAnswerCount,
    required Map<QuestionId, DateTime?> priorCorrect,
    required Set<QuestionId> priorAttemptedQuestionIds,
    required bool proIsActive,
    required DateTime now,
  }) {
    final total = session.questions.length;
    final (correct, _) = session.score;

    final headlineWord = _spelledHeadline[total] ?? '$total';
    final headline = '$headlineWord answered.';

    final minutes = max(1, now.difference(session.startedAt).inMinutes);

    final opener = switch (session.origin) {
      SessionOrigin.todayTopic ||
      SessionOrigin.todayInterleaved =>
        "Today's session.",
      SessionOrigin.drill => 'Practice.',
      SessionOrigin.retake => 'Your mistakes.',
      SessionOrigin.inline => 'From the lesson.',
      SessionOrigin.assessment => 'Assessment.',
    };

    final topicIdsInSession = <TopicId>[];
    for (final q in session.questions) {
      if (!topicIdsInSession.contains(q.topicId)) {
        topicIdsInSession.add(q.topicId);
      }
    }

    final names = topicIdsInSession
        .map((tid) => topicNames[tid] ?? 'this topic')
        .toList();

    final String sourceLine;
    if (names.isEmpty) {
      sourceLine = opener;
    } else if (names.length == 1) {
      sourceLine = '$opener ${names[0]}.';
    } else if (names.length == 2) {
      sourceLine = '$opener ${names[0]} and ${names[1]}.';
    } else {
      final leading = names.sublist(0, names.length - 1).join(', ');
      sourceLine = '$opener $leading and ${names.last}.';
    }

    final misses = <DebriefMiss>[];
    for (final outcome in session.outcomes) {
      if (outcome.isCorrect) continue;

      final question = session.questions.firstWhere(
        (q) => q.id == outcome.questionId,
        orElse: () => Question(
          id: outcome.questionId,
          version: outcome.questionVersion,
          examIds: [session.examId],
          topicId: '',
          language: 'en',
          stem: '',
          choices: const [],
          explanation: '',
        ),
      );

      final labelIsStem =
          question.shortLabel == null || question.shortLabel!.isEmpty;
      final label = labelIsStem ? question.stem : question.shortLabel!;

      final topicName = topicNames[question.topicId] ?? 'this topic';

      final pickedChoice = question.choices.firstWhere(
        (c) => c.id == outcome.chosenChoiceId,
        orElse: () => Choice(
          id: outcome.chosenChoiceId,
          label: '?',
          text: '',
          isCorrect: false,
        ),
      );
      final answerChoice = question.choices.firstWhere(
        (c) => c.id == outcome.correctChoiceId,
        orElse: () => Choice(
          id: outcome.correctChoiceId,
          label: '?',
          text: '',
          isCorrect: true,
        ),
      );

      MissCause? cause;
      if (proIsActive) {
        final lastCorrect = priorCorrect[question.id];
        if (lastCorrect != null) {
          cause = SlippedCause(lastCorrect);
        } else {
          final hasAnyHistory =
              priorAttemptedQuestionIds.contains(question.id) ||
                  priorCorrect.containsKey(question.id);
          if (!hasAnyHistory) {
            cause = const NewCause();
          } else {
            final usualMs = topicAverageMs[question.topicId];
            final answers = topicAnswerCount[question.topicId] ?? 0;
            if (usualMs != null && answers >= rushedMinimumAnswers) {
              if (outcome.responseMs <= usualMs * rushedFraction) {
                cause = RushedCause(
                  responseSeconds: (outcome.responseMs / 1000).round(),
                  usualSeconds: (usualMs / 1000).round(),
                  topicName: topicName,
                );
              }
            }
          }
        }
      }

      misses.add(
        DebriefMiss(
          questionId: question.id,
          label: label,
          labelIsStem: labelIsStem,
          topicName: topicName,
          pickedLabel: pickedChoice.label,
          answerLabel: answerChoice.label,
          cause: cause,
        ),
      );
    }

    final String returnPromise;
    if (misses.isEmpty) {
      returnPromise = '';
    } else {
      var maxInterval = 1;
      for (final outcome in session.outcomes) {
        if (!outcome.isCorrect &&
            outcome.nextReviewIntervalDays > maxInterval) {
          maxInterval = outcome.nextReviewIntervalDays;
        }
      }

      final count = misses.length;
      final countWord = _spelledLower[count] ?? '$count';

      if (maxInterval == 1) {
        if (count == 1) {
          returnPromise = "You'll see it again tomorrow.";
        } else if (count == 2) {
          returnPromise = "You'll see both again tomorrow.";
        } else {
          returnPromise = "You'll see all $countWord again tomorrow.";
        }
      } else {
        if (count == 1) {
          returnPromise = "You'll see it again within $maxInterval days.";
        } else if (count == 2) {
          returnPromise = "You'll see both again within $maxInterval days.";
        } else {
          returnPromise =
              "You'll see all $countWord again within $maxInterval days.";
        }
      }
    }

    return SessionDebrief(
      headline: headline,
      correct: correct,
      total: total,
      minutes: minutes,
      sourceLine: sourceLine,
      misses: misses,
      returnPromise: returnPromise,
    );
  }
}
