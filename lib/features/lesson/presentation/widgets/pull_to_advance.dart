import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class PullToAdvance extends StatefulWidget {
  const PullToAdvance({
    required this.child,
    required this.nextTitle,
    required this.onAdvance,
    required this.isAtEnd,
    required this.lessonId,
    super.key,
  });

  final Widget child;
  final String? nextTitle;
  final VoidCallback? onAdvance;

  /// Changes when the lesson does, which is what tells the arriving half of
  /// the movement that the new body is on screen.
  final String lessonId;

  /// Whether the reader has reached the end of the lesson.
  ///
  /// The handle used to sit under every lesson from the first line, offering
  /// the next topic to someone who had not read a word of this one. It is an
  /// ending, so it arrives at the end.
  final ValueListenable<bool> isAtEnd;

  @override
  State<PullToAdvance> createState() => _PullToAdvanceState();
}

class _PullToAdvanceState extends State<PullToAdvance>
    with SingleTickerProviderStateMixin {
  static const _maxRange = 150.0;
  static const _threshold = 90.0;
  static const _leaving = Duration(milliseconds: 190);
  static const _arriving = Duration(milliseconds: 320);

  /// How far the body is lifted. Positive is up, negative is below the fold.
  double _lift = 0;
  // Created in initState, not lazily. A `late final` initialiser runs on
  // first touch, and the first touch is `dispose()` when the reader is
  // closed without ever being pulled, which asks a deactivated state for a
  // ticker.
  late final AnimationController _controller;
  // ignore: use_late_for_private_fields_and_variables
  Animation<double>? _liftAnimation;
  bool _committing = false;

  bool get _hasHandle =>
      widget.nextTitle != null &&
      widget.onAdvance != null &&
      widget.isAtEnd.value;
  bool get _isArmed => _lift >= _threshold;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _leaving);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PullToAdvance oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The new lesson is mounted. Bring it up from below, which is the second
    // half of the movement the hand started.
    if (_committing && oldWidget.lessonId != widget.lessonId) {
      _committing = false;
      _run(from: -_viewportHeight, to: 0, duration: _arriving);
    }
  }

  double get _viewportHeight {
    final box = context.findRenderObject() as RenderBox?;
    return box?.size.height ?? 600;
  }

  void _run({
    required double from,
    required double to,
    required Duration duration,
    VoidCallback? whenDone,
  }) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      setState(() => _lift = to);
      whenDone?.call();
      return;
    }
    _controller
      ..stop()
      ..duration = duration
      ..reset();
    _liftAnimation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() => _lift = _liftAnimation!.value);
      });
    _controller.forward().whenComplete(() {
      if (mounted) whenDone?.call();
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_hasHandle || _committing) return;
    setState(() {
      _lift = (_lift - details.delta.dy).clamp(0.0, _maxRange);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_hasHandle || _committing) return;
    if (!_isArmed) {
      _run(from: _lift, to: 0, duration: _leaving);
      return;
    }
    _commitAdvance();
  }

  void _commitAdvance() {
    if (!_hasHandle || _committing) return;
    // The hand let go mid-movement, so the body finishes leaving before the
    // next one starts arriving. The bar and the rail never move: they
    // describe the reader, not the lesson.
    _committing = true;
    _run(
      from: _lift,
      to: _viewportHeight,
      duration: _leaving,
      whenDone: () => widget.onAdvance?.call(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final animationDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 260);
    final handleDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 120);

    Widget footer() => !_hasHandle
        ? const SizedBox(width: double.infinity)
        : AnimatedOpacity(
            opacity: 1,
            duration: animationDuration,
            child: Semantics(
              button: true,
              label: 'Next lesson: ${widget.nextTitle}',
              onTap: _commitAdvance,
              child: ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        key: const ValueKey('pull-handle'),
                        duration: handleDuration,
                        width: _isArmed ? 52 : 36,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _isArmed ? colors.board : colors.rule,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pull up for ',
                              style: textStyles.bodySmall.copyWith(
                                color: colors.inkMuted,
                              ),
                            ),
                            TextSpan(
                              text: widget.nextTitle,
                              style: textStyles.bodySmall.copyWith(
                                color: _isArmed ? colors.board : colors.ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      // Clipped to its own box. The lift paints outside its bounds
      // otherwise, so a pulled sheet slid its first lines up over the reader
      // bar and off the top of the screen instead of disappearing under it,
      // which is what the same text does when you simply scroll.
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(0, -_lift),
          child: Column(
            children: [
              Expanded(child: widget.child),
              // Fades and grows in as the end comes into view rather than
              // appearing outright, so the arrival is part of the reading.
              ValueListenableBuilder<bool>(
                valueListenable: widget.isAtEnd,
                builder: (context, _, __) {
                  final child = footer();
                  if (MediaQuery.disableAnimationsOf(context)) return child;
                  return AnimatedSize(
                    duration: animationDuration,
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: child,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
