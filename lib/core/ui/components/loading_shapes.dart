import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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

class LoadingShapes extends StatefulWidget {
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
  State<LoadingShapes> createState() => _LoadingShapesState();
}

class _LoadingShapesState extends State<LoadingShapes>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  Timer? _delay;
  bool _shown = false;
  @override
  void initState() {
    super.initState();
    _delay = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _shown = true);
      _updatePulse();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePulse();
  }

  @override
  void didUpdateWidget(LoadingShapes oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePulse();
  }

  void _updatePulse() {
    if (_shown && !widget.proGate && !MediaQuery.disableAnimationsOf(context)) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shown) return const SizedBox.shrink();
    return Semantics(
      label: 'Loading',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = _pulse.value;
          final opacity = t <= .5
              ? 1 - .55 * PantasCurves.easeInOut.transform(t * 2)
              : .45 + .55 * PantasCurves.easeInOut.transform((t - .5) * 2);
          return Opacity(
            key: const ValueKey('loading-shapes-opacity'),
            opacity: opacity,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < widget.shapes.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: widget.shapes[i].widthFraction,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: widget.shapes[i].height,
                  decoration: BoxDecoration(
                    color: context.colors.skeleton,
                    borderRadius: BorderRadius.circular(
                      widget.shapes[i].radius,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
