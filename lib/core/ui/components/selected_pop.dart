import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

/// The chosen date cell pops (DatePicker, States): 350 ms (`dur-switch`),
/// scale 0.4 to 1.08 on `motion-enter` for the first 60 percent, then back to
/// 1 on `motion-fade`, fading in with it. Keyframes are the system's `pn-pop`.
/// It plays when a cell becomes the chosen one, and not at all under reduced
/// motion. Shared by the wide and the phone date grids.
class SelectedPop extends StatefulWidget {
  const SelectedPop({
    required this.selected,
    required this.child,
    super.key,
  });

  final bool selected;
  final Widget child;

  @override
  State<SelectedPop> createState() => _SelectedPopState();
}

class _SelectedPopState extends State<SelectedPop>
    with SingleTickerProviderStateMixin {
  // ds-board: pn-pop keyframes in design/system/components/bundle.css; the
  // system sets no scale token.
  static const double _from = 0.4;
  static const double _peak = 1.08;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PantasDurations.switchDuration,
    value: 1,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: _from, end: _peak)
          .chain(CurveTween(curve: PantasCurves.enter)),
      weight: 60,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: _peak, end: 1)
          .chain(CurveTween(curve: PantasCurves.fade)),
      weight: 40,
    ),
  ]).animate(_controller);

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1), weight: 60),
    TweenSequenceItem(tween: ConstantTween<double>(1), weight: 40),
  ]).animate(_controller);

  @override
  void didUpdateWidget(SelectedPop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected &&
        !oldWidget.selected &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) => Opacity(
          opacity: _opacity.value,
          child: Transform.scale(scale: _scale.value, child: child),
        ),
      );
}
