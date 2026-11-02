import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/score_breakdown_row.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';

/// One timeline for the results screen, held by the page so a rebuild or a
/// resize never plays it again. The title and score card come in first, the
/// ring fills and the score counts up, the subject bars grow in order from
/// the weakest, then the plan card appears.
class AssessmentResultsSequence {
  AssessmentResultsSequence(this.controller, {required int subjectCount})
      : title = _window(controller, 0, 300, PantasCurves.riseIn),
        subtitle = _window(controller, 60, 300, PantasCurves.riseIn),
        score = _window(controller, 120, 300, PantasCurves.riseIn),
        ring = _window(controller, 250, 750, PantasCurves.houseOut),
        subjects = _window(controller, 500, 300, PantasCurves.riseIn),
        plan = _window(controller, 1000, 400, PantasCurves.riseIn),
        bars = [
          for (var i = 0; i < subjectCount; i++)
            _window(
              controller,
              600 + i * _barStep(subjectCount),
              450,
              PantasCurves.houseOut,
            ),
        ];

  static const duration = Duration(milliseconds: 1400);

  final AnimationController controller;
  final Animation<double> title;
  final Animation<double> subtitle;
  final Animation<double> score;
  final Animation<double> ring;
  final Animation<double> subjects;
  final Animation<double> plan;
  final List<Animation<double>> bars;

  /// The last bar starts no later than 300 ms after the first.
  static int _barStep(int count) =>
      count < 2 ? 0 : (300 ~/ (count - 1)).clamp(0, 90);

  static Animation<double> _window(
    AnimationController controller,
    int startMs,
    int lengthMs,
    Curve curve,
  ) {
    final total = duration.inMilliseconds;
    return controller.drive(
      CurveTween(
        curve: Interval(
          startMs / total,
          (startMs + lengthMs) / total,
          curve: curve,
        ),
      ),
    );
  }

  /// The animation for bar [index], or a finished one when none was planned.
  Animation<double> bar(int index) =>
      index < bars.length ? bars[index] : const AlwaysStoppedAnimation(1);
}

/// A calm fade with a short rise. The child keeps its place in the layout the
/// whole time, so nothing moves when it appears.
class ResultsReveal extends StatelessWidget {
  const ResultsReveal({
    required this.animation,
    required this.child,
    this.rise = 10,
    super.key,
  });
  final Animation<double> animation;
  final Widget child;
  final double rise;

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: animation,
        child: AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, rise * (1 - animation.value)),
            child: child,
          ),
        ),
      );
}

/// The mock results' half ring and score, driven by the entrance so the ring
/// fills and the percent counts up on the page's own timeline. The caption
/// reuses the mock's wording.
class AssessmentScoreGauge extends StatelessWidget {
  const AssessmentScoreGauge({
    required this.correct,
    required this.total,
    this.sequence,
    this.web = false,
    super.key,
  });
  final int correct;
  final int total;
  final AssessmentResultsSequence? sequence;
  final bool web;

  @override
  Widget build(BuildContext context) {
    final target = total == 0 ? 0.0 : correct / total;
    final ring = sequence?.ring ?? const AlwaysStoppedAnimation<double>(1);
    return AnimatedBuilder(
      animation: ring,
      builder: (context, _) => MediaQuery(
        // The page owns the timing, as the mock finale does.
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: HalfRingGauge.mock(
          web: web,
          fraction: target * ring.value,
          displayedFraction: target * ring.value,
          label: '$correct of $total correct answers',
        ),
      ),
    );
  }
}

/// A subject row from the mock results, with its bar grown by the entrance.
class AssessmentSubjectRow extends StatelessWidget {
  const AssessmentSubjectRow({
    required this.name,
    required this.correct,
    required this.total,
    required this.divider,
    this.bar,
    super.key,
  });
  final String name;
  final int correct;
  final int total;
  final bool divider;
  final Animation<double>? bar;

  @override
  Widget build(BuildContext context) {
    final accuracy = total == 0 ? 0.0 : correct / total;
    final grow = bar ?? const AlwaysStoppedAnimation<double>(1);
    return AnimatedBuilder(
      animation: grow,
      builder: (context, _) => ScoreBreakdownRow(
        name: name,
        correct: correct,
        total: total,
        divider: divider,
        animatedAccuracy: accuracy * grow.value,
      ),
    );
  }
}
