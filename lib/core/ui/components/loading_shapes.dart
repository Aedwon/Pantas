import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';

@immutable
class LoadingShape {
  const LoadingShape({
    required this.widthFraction,
    required this.height,
    this.radius = 6,
  });
  final double widthFraction;
  final double height;
  final double radius;
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
              if (i > 0) const SizedBox(height: 10),
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
