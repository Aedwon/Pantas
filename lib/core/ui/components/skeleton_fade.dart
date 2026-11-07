import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';

/// Hands loading shapes over to the loaded content with a cross-fade, as
/// approved on the Splash Hand-off canvas (Web_B_Still, Phone_B_Fade).
///
/// While [loading] only [skeleton] is drawn. When [loading] ends the content
/// fades in over the shapes while they fade out underneath: shapes 1 to 0 over
/// 200 ms, content 0 to 1 over 300 ms starting at 60 ms, both on the shared
/// `ease` curve. The shapes stay in the tree until the fade ends. Nothing
/// slides or scales, and the content takes its final place at once, so it
/// never replays an entrance.
///
/// The swap is instant under reduced motion, and when [fade] is false (a
/// failure replaces the shapes, which is not an arrival of data). Content that
/// was never behind shapes appears as it is.
class SkeletonFade extends StatefulWidget {
  const SkeletonFade({
    required this.loading,
    required this.skeleton,
    required this.content,
    this.fade = true,
    super.key,
  });

  /// True until the data has arrived.
  final bool loading;

  /// Whether the end of loading is data arriving, which fades. False swaps.
  final bool fade;
  final Widget skeleton;
  final Widget content;

  @visibleForTesting
  static const shapesFadeKey = ValueKey<String>('skeleton-fade-shapes');
  @visibleForTesting
  static const contentFadeKey = ValueKey<String>('skeleton-fade-content');

  static const _total = Duration(milliseconds: 360);
  static const _shapesEnd = 200 / 360;
  static const _contentStart = 60 / 360;

  @override
  State<SkeletonFade> createState() => _SkeletonFadeState();
}

class _SkeletonFadeState extends State<SkeletonFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shapes;
  late final Animation<double> _content;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SkeletonFade._total,
      value: widget.loading ? 0 : 1,
    );
    _shapes = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0,
          SkeletonFade._shapesEnd,
          curve: PantasCurves.ease,
        ),
      ),
    );
    _content = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        SkeletonFade._contentStart,
        1,
        curve: PantasCurves.ease,
      ),
    );
  }

  /// Keeps the shapes' state (their pulse) when they move from sizing the
  /// block to sitting under the content.
  final GlobalKey _shapesKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();

  /// Both layers are on screen, mid-fade.
  bool _crossing = false;

  @override
  void didUpdateWidget(SkeletonFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loading && !widget.loading) {
      if (widget.fade && !MediaQuery.disableAnimationsOf(context)) {
        _crossing = true;
        _controller.forward(from: 0).whenComplete(() {
          if (mounted) setState(() => _crossing = false);
        });
      } else {
        _controller.value = 1;
        _crossing = false;
      }
    } else if (!oldWidget.loading && widget.loading) {
      _controller
        ..stop()
        ..value = 0;
      _crossing = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shapes = KeyedSubtree(key: _shapesKey, child: widget.skeleton);
    return Stack(
      fit: StackFit.passthrough,
      // The shapes can be taller than the content they fade under.
      clipBehavior: Clip.none,
      children: [
        if (widget.loading)
          shapes
        else ...[
          if (_crossing)
            // Under the content, out of the layout: the page takes the
            // content's size from the first frame, so nothing below moves.
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: FadeTransition(
                      key: SkeletonFade.shapesFadeKey,
                      opacity: _shapes,
                      child: shapes,
                    ),
                  ),
                ),
              ),
            ),
          FadeTransition(
            key: SkeletonFade.contentFadeKey,
            opacity: _content,
            child: KeyedSubtree(key: _contentKey, child: widget.content),
          ),
        ],
      ],
    );
  }
}
