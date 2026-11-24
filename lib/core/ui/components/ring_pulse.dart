import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_motion_recipes.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// Starts a [RingPulse] from outside the widget tree below it.
class RingPulseController {
  _RingPulseState? _state;

  /// Plays the ring once. Nothing happens under reduced motion or before the
  /// pulse is on screen.
  void play() => _state?._play();
}

/// The ring that spreads from a control and fades: `accent` at
/// `opacity-ripple` (0.38) to 0, spreading 0 to 16 px, 700 ms, ease-out (the
/// motion recipe "Right-answer ripple"). It plays once each time
/// [RingPulseController.play] is called, and never under reduced motion.
class RingPulse extends StatefulWidget {
  const RingPulse({
    required this.controller,
    required this.borderRadius,
    required this.child,
    super.key,
  });

  final RingPulseController controller;

  /// The radius of the control; the ring adds its spread to it.
  final BorderRadius borderRadius;
  final Widget child;

  @override
  State<RingPulse> createState() => _RingPulseState();
}

class _RingPulseState extends State<RingPulse>
    with SingleTickerProviderStateMixin {
  static const _recipe = PantasMotionRecipes.ripple;
  static const double _spread = PantasSpace.s16;

  late final AnimationController _animation =
      AnimationController(vsync: this, duration: _recipe.duration);

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void didUpdateWidget(RingPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._state = null;
      widget.controller._state = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _animation.dispose();
    super.dispose();
  }

  void _play() {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    _animation.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accent;
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final t = _animation.value;
        final playing = t > 0 && t < 1;
        final e = _recipe.curve.transform(t);
        final spread = _spread * e;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child!,
            if (playing)
              Positioned(
                left: -spread,
                top: -spread,
                right: -spread,
                bottom: -spread,
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: DecoratedBox(
                      key: const ValueKey('ring-pulse'),
                      decoration: BoxDecoration(
                        borderRadius: widget.borderRadius.add(
                          BorderRadius.circular(spread),
                        ),
                        border: Border.all(
                          color: accent.withValues(
                            alpha: PantasOpacity.ripple * (1 - e),
                          ),
                          width: spread,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
