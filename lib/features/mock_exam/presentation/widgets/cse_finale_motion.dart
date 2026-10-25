import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_finale_tracks.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';

/// Geometry approved for the taller thirteen-column CSE booklet.
class CseFinaleMotion {
  CseFinaleMotion(MockFinaleInput input)
      : questions = List.unmodifiable([
          for (final part in input.parts) ...part.questions,
        ]) {
    for (var i = 0; i < questions.length; i++) {
      if (questions[i].outcome == MockFinaleOutcome.correct) {
        _correctOrdinals[i] = _correctOrdinals.length;
      }
    }
  }

  final List<MockFinaleQuestion> questions;
  final _correctOrdinals = <int, int>{};
  int get correctCount => _correctOrdinals.length;
  int get blankCount => questions
      .where((question) => question.outcome == MockFinaleOutcome.blank)
      .length;
  bool get hasBall => correctCount > 0;
  int get _rows => (questions.length / 13).ceil();

  Rect get initialCard => Rect.fromLTWH(
        30,
        148,
        330,
        math.max(189, (_rows - 1) * 16 + 79).toDouble(),
      );
  Rect get checkingCard => Rect.fromLTWH(
        19,
        260,
        352,
        math.max(199, (_rows - 1) * 18 + 39).toDouble(),
      );
  double get countY => initialCard.bottom - 40;
  double get scanEnd => 282 + (_rows - 1) * 18 + 14;

  Offset initialPosition(int index) =>
      Offset(58.5 + index % 13 * 22, 166 + index ~/ 13 * 16);
  Offset checkingPosition(int index) =>
      Offset(46.5 + index % 13 * 24, 282 + index ~/ 13 * 18);

  Rect cardAt(double milliseconds) => Rect.lerp(
        initialCard,
        checkingCard,
        cseFinaleInterval(
          milliseconds,
          1007.5395,
          1462.4475,
          const Cubic(.32, .72, 0, 1),
        ),
      )!;

  /// Scan and dots share vertical reflow; grading follows the actual eased bar.
  double scanYAt(double milliseconds) =>
      275 +
      (scanEnd - 275) *
          cseFinaleInterval(
            milliseconds,
            2145.0365,
            2795.051,
            const Cubic(.45, 0, .55, 1),
          );

  CseFinaleDot dotAt(
    int index,
    double milliseconds, {
    double verticalOffset = 0,
    Offset gatheringCenter = const Offset(195, 359),
  }) {
    final checking = checkingPosition(index) + Offset(0, verticalOffset);
    final base = Offset.lerp(
      initialPosition(index) + Offset(0, verticalOffset),
      checking,
      cseFinaleInterval(
        milliseconds,
        1007.5395,
        1462.4475,
        const Cubic(.32, .72, 0, 1),
      ),
    )!;
    final checked = scanYAt(milliseconds) >= checkingPosition(index).dy;
    final ordinal = _correctOrdinals[index];
    if (ordinal == null) {
      return CseFinaleDot(
        position: base,
        scale: 1,
        opacity: 1 - cseFinaleInterval(milliseconds, 2859.973, 2990.044),
        checked: checked,
      );
    }
    final trackIndex = correctCount == 1
        ? 0
        : (ordinal * (cseFlightTracks.length - 1) / (correctCount - 1)).round();
    final track = cseFlightTracks[trackIndex];
    final sample = _sample(track, milliseconds);
    final end = track.last;
    final begin = track[2].t;
    final progress = ((milliseconds - begin) / (end.t - begin)).clamp(0.0, 1.0);
    final correction = Offset(
          gatheringCenter.dx - 4.5 - checking.dx - end.x,
          gatheringCenter.dy - 4.5 - checking.dy - end.y,
        ) *
        progress;
    return CseFinaleDot(
      position: base + Offset(sample.x, sample.y) + correction,
      scale: sample.scaleX,
      opacity: milliseconds < .681 ? 1 : sample.opacity,
      checked: checked,
    );
  }
}

class CseFinaleDot {
  const CseFinaleDot({
    required this.position,
    required this.scale,
    required this.opacity,
    required this.checked,
  });
  final Offset position;
  final double scale;
  final double opacity;
  final bool checked;
}

class CseFinaleSample {
  const CseFinaleSample({
    required this.x,
    required this.y,
    required this.scaleX,
    required this.scaleY,
    required this.rotation,
    required this.opacity,
  });
  final double x;
  final double y;
  final double scaleX;
  final double scaleY;
  final double rotation;
  final double opacity;
}

double cseFinaleInterval(
  double time,
  double begin,
  double end, [
  Curve curve = Curves.linear,
]) =>
    curve.transform(((time - begin) / (end - begin)).clamp(0.0, 1.0));

CseFinaleSample sampleCseFinaleEffect(int id, double milliseconds) =>
    _sample(cseEffectTracks[id]!, milliseconds);

CseFinaleSample _sample(List<CseMotionStop> stops, double milliseconds) {
  var first = stops.first;
  var second = first;
  for (final stop in stops.skip(1)) {
    second = stop;
    if (milliseconds <= stop.t) break;
    first = stop;
  }
  final curve = first.curve;
  final progress = second.t == first.t
      ? 0.0
      : cseFinaleInterval(
          milliseconds,
          first.t,
          second.t,
          Cubic(curve.$1, curve.$2, curve.$3, curve.$4),
        );
  double mix(double a, double b) => a + (b - a) * progress;
  return CseFinaleSample(
    x: mix(first.x, second.x),
    y: mix(first.y, second.y),
    scaleX: mix(first.sx, second.sx),
    scaleY: mix(first.sy, second.sy),
    rotation: mix(first.rotation, second.rotation),
    opacity: mix(first.opacity, second.opacity),
  );
}
