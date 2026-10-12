import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';

class StudyMapEntry extends StatelessWidget {
  const StudyMapEntry({required this.child, required this.delay, super.key});
  final Widget child;
  final Duration delay;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : Duration(milliseconds: delay.inMilliseconds + 450),
        curve: Interval(
          delay.inMilliseconds / (delay.inMilliseconds + 450),
          1,
          curve: PantasCurves.houseOut,
        ),
        builder: (context, value, child) => ExcludeFocus(
          excluding: value == 0,
          child: ExcludeSemantics(
            excluding: value == 0,
            child: Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            ),
          ),
        ),
        child: child,
      );
}
