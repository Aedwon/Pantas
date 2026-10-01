import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';
import 'package:pantas/features/metrics/providers/current_archetype_provider.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

enum TendencyId {
  underPressure,
  stamina,
  howYouStudy,
  howYouAnswer,
  howLongYouRemember,
}

@immutable
class Tendency {
  const Tendency({
    required this.id,
    required this.heading,
    required this.leftLabel,
    required this.rightLabel,
    required this.gap,
    required this.leftFigure,
    required this.rightFigure,
    required this.sentence,
    required this.isLoss,
    required this.unlockAction,
    this.confidence = TendencyConfidence.early,
  });

  final TendencyId id;
  final String heading;
  final String leftLabel;
  final String rightLabel;

  /// The serif 34/700 figure on the left. Null when the prerequisite is
  /// unmet; the labels still render.
  final String? gap;

  /// Demoted to an 11.5px caption beneath the sentence.
  final String? leftFigure;
  final String? rightFigure;

  final String? sentence;

  /// Losses carry rust. Gains stay ink.
  final bool isLoss;

  final String unlockAction;
  final TendencyConfidence confidence;
}

@immutable
class HowYouWork {
  const HowYouWork({
    required this.name,
    required this.archetype,
    required this.archetypeLine,
    required this.tendencies,
    required this.whenYouWork,
  });

  final String? name;
  final String? archetype;
  final String? archetypeLine;

  /// Always five, in the spec's order. Never filtered.
  final List<Tendency> tendencies;

  /// Three rows: the meta column holds the answer, the subtext says what
  /// it is measured against. Empty when the signals return null.
  final List<({String title, String subtext, String meta})> whenYouWork;
}

final howYouWorkProvider = FutureProvider<HowYouWork>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final examId = focus.exam?.id;

  final userSettings = await ref.watch(userSettingsProvider.future);
  final rawName = userSettings.name?.trim();
  final name = (rawName == null || rawName.isEmpty) ? null : rawName;

  String? archetype;
  String? archetypeLine;

  if (examId != null) {
    final now = DateTime.now();
    final archetypeResult = await ref.watch(
      currentArchetypeProvider(
        CurrentArchetypeRequest(
          userId: 'local',
          examId: examId,
          window: MetricsWindow.prepWindow,
          now: now,
        ),
      ).future,
    );
    if (archetypeResult != null) {
      archetype = archetypeResult.label;
      archetypeLine = archetypeResult.synthesizedCopy;
    }
  }

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
  final retentionShape =
      await readSignal<RetentionCurve>(SignalKey.retentionShape);
  final timeOfDay = await readSignal<DayHourHistogram>(
    SignalKey.timeOfDay,
    forTendency: false,
  );
  final sessionShape = await readSignal<DurationDistribution>(
    SignalKey.sessionShape,
    forTendency: false,
  );

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
  Tendency underPressure;
  if (pressureDelta != null &&
      pressureDelta.practiceTotal > 0 &&
      pressureDelta.mockTotal > 0) {
    final practicePct = (pressureDelta.practiceAccuracy * 100).round();
    final mockPct = (pressureDelta.mockAccuracy * 100).round();
    final diff = practicePct - mockPct;
    final absDiff = diff.abs();
    final isLoss = pressureDelta.mockAccuracy < pressureDelta.practiceAccuracy;
    final sentence = diff > 0
        ? 'Accuracy drops $absDiff% under exam pressure.'
        : (diff < 0
            ? 'Accuracy rises $absDiff% under exam pressure.'
            : 'Accuracy stays even under exam pressure.');
    underPressure = Tendency(
      id: TendencyId.underPressure,
      heading: 'Under pressure',
      leftLabel: 'practicing',
      rightLabel: 'under time',
      gap: '$absDiff',
      leftFigure: '$practicePct%',
      rightFigure: '$mockPct%',
      sentence:
          pressureConfidence == TendencyConfidence.clear ? sentence : null,
      confidence: pressureConfidence,
      isLoss: isLoss,
      unlockAction: pressureUnlock,
    );
  } else {
    underPressure = Tendency(
      id: TendencyId.underPressure,
      heading: 'Under pressure',
      leftLabel: 'practicing',
      rightLabel: 'under time',
      gap: null,
      leftFigure: null,
      rightFigure: null,
      sentence: null,
      isLoss: false,
      unlockAction: pressureUnlock,
    );
  }

  // 2. Stamina
  Tendency stamina;
  if (staminaDelta != null) {
    final firstPct = (staminaDelta.firstHalfAccuracy * 100).round();
    final secondPct = (staminaDelta.secondHalfAccuracy * 100).round();
    final diff = firstPct - secondPct;
    final absDiff = diff.abs();
    final isLoss =
        staminaDelta.secondHalfAccuracy < staminaDelta.firstHalfAccuracy;
    final sentence = diff > 0
        ? 'Accuracy drops $absDiff% in the second half of a mock.'
        : (diff < 0
            ? 'Accuracy rises $absDiff% in the second half of a mock.'
            : 'Accuracy stays even across both halves.');
    stamina = Tendency(
      id: TendencyId.stamina,
      heading: 'Stamina',
      leftLabel: 'first half',
      rightLabel: 'second half',
      gap: '$absDiff',
      leftFigure: '$firstPct%',
      rightFigure: '$secondPct%',
      sentence: staminaConfidence == TendencyConfidence.clear ? sentence : null,
      confidence: staminaConfidence,
      isLoss: isLoss,
      unlockAction: 'Finish one full length mock',
    );
  } else {
    stamina = const Tendency(
      id: TendencyId.stamina,
      heading: 'Stamina',
      leftLabel: 'first half',
      rightLabel: 'second half',
      gap: null,
      leftFigure: null,
      rightFigure: null,
      sentence: null,
      isLoss: false,
      unlockAction: 'Finish one full length mock',
    );
  }

  // 3. How you study
  Tendency howYouStudy;
  if (workflowRatio != null &&
      workflowRatio.readThenQuizCount + workflowRatio.quizFirstCount > 0) {
    final readCount = workflowRatio.readThenQuizCount;
    final quizCount = workflowRatio.quizFirstCount;
    final diff = (readCount - quizCount).abs();
    String sentence;
    if (readCount > quizCount) {
      sentence = 'You usually read the lesson first.';
    } else if (quizCount > readCount) {
      sentence = 'You usually go straight to the questions.';
    } else {
      sentence = 'You split about evenly between the two.';
    }
    howYouStudy = Tendency(
      id: TendencyId.howYouStudy,
      heading: 'How you study',
      leftLabel: 'read first',
      rightLabel: 'answered first',
      gap: '$diff',
      leftFigure: '$readCount',
      rightFigure: '$quizCount',
      sentence: studyConfidence == TendencyConfidence.clear ? sentence : null,
      confidence: studyConfidence,
      isLoss: false,
      unlockAction: studyUnlock,
    );
  } else {
    howYouStudy = Tendency(
      id: TendencyId.howYouStudy,
      heading: 'How you study',
      leftLabel: 'read first',
      rightLabel: 'answered first',
      gap: null,
      leftFigure: null,
      rightFigure: null,
      sentence: null,
      isLoss: false,
      unlockAction: studyUnlock,
    );
  }

  // 4. How you answer
  Tendency howYouAnswer;
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
    howYouAnswer = Tendency(
      id: TendencyId.howYouAnswer,
      heading: 'How you answer',
      leftLabel: 'when correct',
      rightLabel: 'when wrong',
      gap: '${absDiff}s',
      leftFigure: '${correctSec}s',
      rightFigure: '${incorrectSec}s',
      sentence: speedConfidence == TendencyConfidence.clear ? sentence : null,
      confidence: speedConfidence,
      isLoss: diffSec != 0,
      unlockAction: speedUnlock,
    );
  } else {
    howYouAnswer = Tendency(
      id: TendencyId.howYouAnswer,
      heading: 'How you answer',
      leftLabel: 'when correct',
      rightLabel: 'when wrong',
      gap: null,
      leftFigure: null,
      rightFigure: null,
      sentence: null,
      isLoss: false,
      unlockAction: speedUnlock,
    );
  }

  final memoryConfidence = retentionShape == null
      ? TendencyConfidence.early
      : TendencyEvidence.memory(retentionShape);

  // 5. How long you remember
  Tendency howLongYouRemember;
  if (retentionShape != null && retentionShape.reviewCount > 0) {
    final days = retentionShape.averageStability.round();
    final lapsePct = (retentionShape.lapseRate * 100).round();
    final daysText = _daysInWords(days);
    final sentence =
        'what you learn holds about $daysText days before you need it again';
    howLongYouRemember = Tendency(
      id: TendencyId.howLongYouRemember,
      heading: 'How long you remember',
      leftLabel: 'memory holds',
      rightLabel: 'lapse rate',
      gap: '${days}d',
      leftFigure: '${days}d',
      rightFigure: '$lapsePct%',
      sentence: memoryConfidence == TendencyConfidence.clear ? sentence : null,
      confidence: memoryConfidence,
      isLoss: retentionShape.lapseRate > 0.15,
      unlockAction: 'Review more questions',
    );
  } else {
    howLongYouRemember = const Tendency(
      id: TendencyId.howLongYouRemember,
      heading: 'How long you remember',
      leftLabel: 'memory holds',
      rightLabel: 'lapse rate',
      gap: null,
      leftFigure: null,
      rightFigure: null,
      sentence: null,
      isLoss: false,
      unlockAction: 'Review more questions',
    );
  }

  final tendencies = [
    underPressure,
    stamina,
    howYouStudy,
    howYouAnswer,
    howLongYouRemember,
  ];

  final whenYouWork = <({String title, String subtext, String meta})>[];
  if (timeOfDay != null &&
      sessionShape != null &&
      timeOfDay.buckets.isNotEmpty) {
    final bestBucket = [...timeOfDay.buckets]
      ..sort((a, b) => b.accuracy.compareTo(a.accuracy));
    final bestHour = bestBucket.first.hour;
    whenYouWork.addAll([
      (
        title: 'Peak hour',
        subtext: 'Measured from your highest accuracy',
        meta: _formatHour(bestHour),
      ),
      (
        title: 'Session length',
        subtext: 'Average sit duration',
        meta: '${sessionShape.averageMinutes.round()} minutes',
      ),
      (
        title: 'Total sits',
        subtext: 'Completed study sessions',
        meta: '${sessionShape.sessionCount} sessions',
      ),
    ]);
  }

  return HowYouWork(
    name: name,
    archetype: archetype,
    archetypeLine: archetypeLine,
    tendencies: tendencies,
    whenYouWork: whenYouWork,
  );
});

String _daysInWords(int n) {
  const words = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
  ];
  if (n >= 0 && n < words.length) return words[n];
  return n.toString();
}

String _formatHour(int hour) {
  if (hour == 0) return '12 am';
  if (hour == 12) return '12 pm';
  if (hour < 12) return '$hour am';
  return '${hour - 12} pm';
}
