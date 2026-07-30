import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    required this.pointsAtStake,
  });

  final TendencyKind kind;
  final String heading;

  /// Both comparison labels are shown even when the figures are not.
  /// Knowing what is being compared is what creates the want.
  final String leftLabel;
  final String rightLabel;

  /// Null when the prerequisite is unmet. The labels above still render.
  final ({String left, String right})? figures;

  /// Null when the prerequisite is unmet.
  final String? sentence;

  /// What unlocks this card, shown when [figures] is null. For example
  /// "Finish one full length mock".
  final String unlockAction;

  /// Ordering key. Worst first, descending. Cards with no figures sort last.
  final double pointsAtStake;
}

final tendenciesProvider = FutureProvider<List<TendencyCard>>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final examId = focus.exam?.id;

  Future<T?> readSignal<T>(SignalKey key) async {
    if (examId == null) return null;
    final res = await ref.watch(
      metricsSignalProvider(
        MetricsSignalRequest(
          signal: key,
          window: MetricsWindow.prepWindow,
          examId: examId,
          now: DateTime.now(),
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

  // 1. Under pressure
  if (pressureDelta != null) {
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
        leftLabel: 'practising',
        rightLabel: 'under time',
        figures: (left: '$practicePct%', right: '$mockPct%'),
        sentence: sentence,
        unlockAction: 'Finish one full length mock',
        pointsAtStake:
            (pressureDelta.practiceAccuracy - pressureDelta.mockAccuracy).abs(),
      ),
    );
  } else {
    cards.add(
      const TendencyCard(
        kind: TendencyKind.underPressure,
        heading: 'Under pressure',
        leftLabel: 'practising',
        rightLabel: 'under time',
        figures: null,
        sentence: null,
        unlockAction: 'Finish one full length mock',
        pointsAtStake: -1,
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
        sentence: sentence,
        unlockAction: 'Finish one full length mock',
        pointsAtStake:
            (staminaDelta.firstHalfAccuracy - staminaDelta.secondHalfAccuracy)
                .abs(),
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
        pointsAtStake: -1,
      ),
    );
  }

  // 3. How you study
  // howYouStudy is always 0, because neither direction is a loss and
  // there is nothing at stake to rank it by. That puts it after the
  // measurable cards and before the blocked ones.
  if (workflowRatio != null) {
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
        sentence: sentence,
        unlockAction: 'Read lessons or attempt topics',
        pointsAtStake: 0,
      ),
    );
  } else {
    cards.add(
      const TendencyCard(
        kind: TendencyKind.howYouStudy,
        heading: 'How you study',
        leftLabel: 'read first',
        rightLabel: 'answered first',
        figures: null,
        sentence: null,
        unlockAction: 'Read lessons or attempt topics',
        pointsAtStake: -1,
      ),
    );
  }

  // 4. How you answer
  if (speedDist != null) {
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
        sentence: sentence,
        unlockAction: 'Answer more questions',
        pointsAtStake:
            (speedDist.correctAverageMs - speedDist.incorrectAverageMs).abs() /
                1000.0,
      ),
    );
  } else {
    cards.add(
      const TendencyCard(
        kind: TendencyKind.howYouAnswer,
        heading: 'How you answer',
        leftLabel: 'when correct',
        rightLabel: 'when wrong',
        figures: null,
        sentence: null,
        unlockAction: 'Answer more questions',
        pointsAtStake: -1,
      ),
    );
  }

  // Worst first, descending. Cards blocked by a missing prerequisite sort last.
  cards.sort((a, b) {
    final aHasData = a.figures != null;
    final bHasData = b.figures != null;
    if (aHasData != bHasData) {
      return aHasData ? -1 : 1;
    }
    final cmp = b.pointsAtStake.compareTo(a.pointsAtStake);
    if (cmp != 0) return cmp;
    return a.kind.index.compareTo(b.kind.index);
  });

  return cards;
});
