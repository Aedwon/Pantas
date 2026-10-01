import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';

enum TendencyKind { underPressure, stamina, howYouStudy, howYouAnswer }

@immutable
class TendencyCard {
  const TendencyCard({
    required this.kind,
    required this.heading,
    required this.leftLabel,
    required this.rightLabel,
    required this.figures,
    required this.sentence,
    required this.unlockAction,
    this.confidence = TendencyConfidence.early,
  });

  final TendencyKind kind;
  final String heading;

  /// Both comparison labels are shown even when the figures are not.
  /// Knowing what is being compared is what creates the want.
  final String leftLabel;
  final String rightLabel;

  /// Null when the prerequisite is unmet. The labels above still render.
  final ({String left, String right})? figures;

  /// Present only when the statistical finding is clear.
  final String? sentence;

  /// What unlocks this card, shown when [figures] is null. For example
  /// "Finish one full length mock".
  final String unlockAction;
  final TendencyConfidence confidence;
}

final tendenciesProvider = FutureProvider<List<TendencyCard>>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final examId = focus.exam?.id;

  Future<T?> readSignal<T>(SignalKey key, {bool forTendency = true}) async {
    if (examId == null) return null;
    final res = await ref.watch(
      metricsSignalProvider(
        MetricsSignalRequest(
          signal: key,
          window: MetricsWindow.prepWindow,
          examId: examId,
          now: DateTime.now(),
          forTendency: forTendency,
        ),
      ).future,
    );
    return res?.value as T?;
  }

  final pressureDelta =
      await readSignal<PressureDelta>(SignalKey.testModeDelta);
  final staminaDelta = await readSignal<StaminaDelta>(SignalKey.mockStamina);
  final workflowRatio = await readSignal<WorkflowRatio>(SignalKey.readThenQuiz);
  final speedDist =
      await readSignal<LatencyDistribution>(SignalKey.perQuestionSpeed);

  final cards = <TendencyCard>[];

  final pressureConfidence = pressureDelta == null
      ? TendencyConfidence.early
      : TendencyEvidence.pressure(pressureDelta);
  final staminaConfidence = staminaDelta == null
      ? TendencyConfidence.early
      : TendencyEvidence.stamina(staminaDelta);
  final studyConfidence = workflowRatio == null
      ? TendencyConfidence.early
      : TendencyEvidence.study(workflowRatio);
  final speedConfidence = speedDist == null
      ? TendencyConfidence.early
      : TendencyEvidence.speed(speedDist);
  final pressureUnlock = pressureDelta == null ||
          (pressureDelta.practiceTotal == 0 && pressureDelta.mockTotal == 0)
      ? 'Answer practice questions and finish one full length mock'
      : pressureDelta.practiceTotal == 0
          ? 'Answer practice questions'
          : 'Finish one full length mock';

  final studyUnlock = workflowRatio == null ||
          (workflowRatio.readLessonCount == 0 &&
              workflowRatio.practicedTopicCount == 0)
      ? 'Read a lesson and answer questions in its topic'
      : workflowRatio.practicedTopicCount == 0
          ? 'Answer questions in a topic you have read'
          : 'Read a lesson in a topic you have practiced';

  final speedUnlock = speedDist == null
      ? 'Answer timed questions correctly and incorrectly'
      : speedDist.correctCount == 0
          ? 'Answer timed questions correctly'
          : 'Answer timed questions incorrectly';

  // 1. Under pressure
  if (pressureDelta != null &&
      pressureDelta.practiceTotal > 0 &&
      pressureDelta.mockTotal > 0) {
    final practicePct = (pressureDelta.practiceAccuracy * 100).round();
    final mockPct = (pressureDelta.mockAccuracy * 100).round();
    final diff = practicePct - mockPct;
    final absDiff = diff.abs();
    final sentence = diff > 0
        ? 'Accuracy drops $absDiff% under exam pressure.'
        : (diff < 0
            ? 'Accuracy rises $absDiff% under exam pressure.'
            : 'Accuracy stays even under exam pressure.');
    cards.add(
      TendencyCard(
        kind: TendencyKind.underPressure,
        heading: 'Under pressure',
        leftLabel: 'practicing',
        rightLabel: 'under time',
        figures: (left: '$practicePct%', right: '$mockPct%'),
        sentence:
            pressureConfidence == TendencyConfidence.clear ? sentence : null,
        confidence: pressureConfidence,
        unlockAction: pressureUnlock,
      ),
    );
  } else {
    cards.add(
      TendencyCard(
        kind: TendencyKind.underPressure,
        heading: 'Under pressure',
        leftLabel: 'practicing',
        rightLabel: 'under time',
        figures: null,
        sentence: null,
        unlockAction: pressureUnlock,
      ),
    );
  }

  // 2. Stamina
  if (staminaDelta != null) {
    final firstPct = (staminaDelta.firstHalfAccuracy * 100).round();
    final secondPct = (staminaDelta.secondHalfAccuracy * 100).round();
    final diff = firstPct - secondPct;
    final absDiff = diff.abs();
    final sentence = diff > 0
        ? 'Accuracy drops $absDiff% in the second half of a mock.'
        : (diff < 0
            ? 'Accuracy rises $absDiff% in the second half of a mock.'
            : 'Accuracy stays even across both halves.');
    cards.add(
      TendencyCard(
        kind: TendencyKind.stamina,
        heading: 'Stamina',
        leftLabel: 'first half',
        rightLabel: 'second half',
        figures: (left: '$firstPct%', right: '$secondPct%'),
        sentence:
            staminaConfidence == TendencyConfidence.clear ? sentence : null,
        confidence: staminaConfidence,
        unlockAction: 'Finish one full length mock',
      ),
    );
  } else {
    cards.add(
      const TendencyCard(
        kind: TendencyKind.stamina,
        heading: 'Stamina',
        leftLabel: 'first half',
        rightLabel: 'second half',
        figures: null,
        sentence: null,
        unlockAction: 'Finish one full length mock',
      ),
    );
  }

  // 3. How you study
  if (workflowRatio != null &&
      workflowRatio.readThenQuizCount + workflowRatio.quizFirstCount > 0) {
    final readCount = workflowRatio.readThenQuizCount;
    final quizCount = workflowRatio.quizFirstCount;
    final String sentence;
    if (readCount > quizCount) {
      sentence = 'You usually read the lesson first.';
    } else if (quizCount > readCount) {
      sentence = 'You usually go straight to the questions.';
    } else {
      sentence = 'You split about evenly between the two.';
    }
    cards.add(
      TendencyCard(
        kind: TendencyKind.howYouStudy,
        heading: 'How you study',
        leftLabel: 'read first',
        rightLabel: 'answered first',
        figures: (left: '$readCount', right: '$quizCount'),
        sentence: studyConfidence == TendencyConfidence.clear ? sentence : null,
        confidence: studyConfidence,
        unlockAction: studyUnlock,
      ),
    );
  } else {
    cards.add(
      TendencyCard(
        kind: TendencyKind.howYouStudy,
        heading: 'How you study',
        leftLabel: 'read first',
        rightLabel: 'answered first',
        figures: null,
        sentence: null,
        unlockAction: studyUnlock,
      ),
    );
  }

  // 4. How you answer
  if (speedDist != null &&
      speedDist.correctCount > 0 &&
      speedDist.incorrectCount > 0) {
    final correctSec = (speedDist.correctAverageMs / 1000).round();
    final incorrectSec = (speedDist.incorrectAverageMs / 1000).round();
    final diffSec = incorrectSec - correctSec;
    final absDiff = diffSec.abs();
    final sentence = diffSec > 0
        ? 'You spend ${absDiff}s longer on questions you get wrong.'
        : (diffSec < 0
            ? 'You answer ${absDiff}s faster on questions you get wrong.'
            : 'Your speed is about the same whether correct or wrong.');
    cards.add(
      TendencyCard(
        kind: TendencyKind.howYouAnswer,
        heading: 'How you answer',
        leftLabel: 'when correct',
        rightLabel: 'when wrong',
        figures: (left: '${correctSec}s', right: '${incorrectSec}s'),
        sentence: speedConfidence == TendencyConfidence.clear ? sentence : null,
        confidence: speedConfidence,
        unlockAction: speedUnlock,
      ),
    );
  } else {
    cards.add(
      TendencyCard(
        kind: TendencyKind.howYouAnswer,
        heading: 'How you answer',
        leftLabel: 'when correct',
        rightLabel: 'when wrong',
        figures: null,
        sentence: null,
        unlockAction: speedUnlock,
      ),
    );
  }

  // Data comes first. Both groups use the same order, regardless of gap size.
  const order = [
    TendencyKind.underPressure,
    TendencyKind.stamina,
    TendencyKind.howYouAnswer,
    TendencyKind.howYouStudy,
  ];
  cards.sort((a, b) {
    final aHasData = a.figures != null;
    final bHasData = b.figures != null;
    if (aHasData != bHasData) {
      return aHasData ? -1 : 1;
    }
    return order.indexOf(a.kind).compareTo(order.indexOf(b.kind));
  });

  return cards;
});
