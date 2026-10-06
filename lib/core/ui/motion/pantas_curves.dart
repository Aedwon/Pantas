import 'package:flutter/animation.dart';

abstract final class PantasCurves {
  static const houseOut = Cubic(0.3, 0.9, 0.3, 1);
  static const riseIn = Cubic(0.2, 0.9, 0.3, 1);
  static const slideA = Cubic(0.22, 1, 0.36, 1);
  static const slideB = Cubic(0.2, 0.8, 0.25, 1);
  static const slideC = Cubic(0.2, 1, 0.35, 1);
  static const edgeGrow = Cubic(0.32, 0.72, 0, 1);
  static const popA = Cubic(0.3, 1.4, 0.5, 1);
  static const popB = Cubic(0.3, 1.5, 0.5, 1);
  static const popC = Cubic(0.34, 1.56, 0.64, 1);
  static const checkDraw = Cubic(0.6, 0, 0.3, 1);
  static const shake = Cubic(0.36, 0.07, 0.19, 0.97);
  static const burst = Cubic(0.15, 0.7, 0.35, 1);
  static const liquid = Cubic(0.45, 0, 0.25, 1);
  static const ease = Cubic(0.25, 0.1, 0.25, 1);
  static const easeOut = Cubic(0, 0, 0.58, 1);
  static const easeInOut = Cubic(0.42, 0, 0.58, 1);
  static const linear = Curves.linear;

  static Curve steps(int count) => _Steps(count);
}

class _Steps extends Curve {
  const _Steps(this.count) : assert(count > 0, 'steps must be positive');
  final int count;
  @override
  double transformInternal(double t) => (t * count).floor() / count;
}
