import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

@immutable
class LoadingShape {
  const LoadingShape({
    required this.widthFraction,
    required this.height,
    this.radius,
  });
  final double widthFraction;
  final double height;

  /// Null takes the Skeleton default: `radius-xs` for a line.
  final double? radius;
}

/// A short stack of pulsing lines for a section whose loaded layout has no
/// fixed shape. Screens with a known layout use their own skeleton built from
/// [SkeletonBlock] inside a [SkeletonPulse].
class LoadingShapes extends StatelessWidget {
  const LoadingShapes({
    this.proGate = false,
    this.shapes = const [
      LoadingShape(widthFraction: .34, height: 11),
      LoadingShape(widthFraction: .46, height: 20),
      LoadingShape(widthFraction: .28, height: 12),
    ],
    super.key,
  });
  final bool proGate;
  final List<LoadingShape> shapes;

  @override
  Widget build(BuildContext context) => SkeletonPulse(
        still: proGate,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < shapes.length; i++) ...[
              if (i > 0) const SizedBox(height: PantasSpace.s10),
              FractionallySizedBox(
                widthFactor: shapes[i].widthFraction,
                alignment: Alignment.centerLeft,
                child: SkeletonBlock(
                  height: shapes[i].height,
                  radius: shapes[i].radius,
                ),
              ),
            ],
          ],
        ),
      );
}
