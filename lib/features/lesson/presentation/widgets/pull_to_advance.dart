import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class PullToAdvance extends StatefulWidget {
  const PullToAdvance({
    required this.nextTitle,
    required this.onAdvance,
    required this.isAtEnd,
    required this.lessonId,
    this.child,
    this.contentBuilder,
    this.incomingChild,
    this.destinationKey,
    this.contentKey,
    this.requireIncoming = false,
    this.enabled = true,
    this.finishDay = false,
    this.footerPadding = const EdgeInsets.fromLTRB(0, 36, 0, 60),
    this.onTransition,
    this.onCommit,
    super.key,
  }) : assert(child != null || contentBuilder != null, 'Content is required.');

  final Widget? child;
  final Widget Function(Widget footer)? contentBuilder;
  final Widget? incomingChild;
  final Object? destinationKey;
  final Object? contentKey;
  final bool requireIncoming;
  final bool enabled;
  final bool finishDay;
  final EdgeInsets footerPadding;
  final ValueChanged<double>? onTransition;
  final VoidCallback? onCommit;
  final String? nextTitle;
  final VoidCallback? onAdvance;
  final String lessonId;
  final ValueListenable<bool> isAtEnd;

  @override
  State<PullToAdvance> createState() => _PullToAdvanceState();
}

class _PullToAdvanceState extends State<PullToAdvance>
    with TickerProviderStateMixin {
  static const _threshold = 90.0;
  late final AnimationController _motion;
  late final AnimationController _arrow;
  double _lift = 0;
  double _from = 0;
  double _to = 0;
  bool _committing = false;
  bool _holding = false;
  bool _still = false;
  bool _pointerCanceled = false;
  bool _settling = false;
  Widget? _incoming;
  Object? _destination;
  VoidCallback? _advance;

  Object get _content => widget.contentKey ?? widget.lessonId;
  Object? get _next => widget.destinationKey ?? widget.nextTitle;
  bool get _busy => _committing || _holding;
  bool get _armed => !_settling && _lift >= _threshold;
  bool get _hasDestination =>
      widget.nextTitle != null &&
      widget.onAdvance != null &&
      (!widget.requireIncoming || widget.incomingChild != null);
  bool get _hasHandle =>
      widget.enabled && _hasDestination && widget.isAtEnd.value;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this)
      ..addListener(_tick)
      ..addStatusListener(_status);
    _arrow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    widget.isAtEnd.addListener(_endChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _arrow
        ..stop()
        ..value = _armed ? 1 : 0;
      if (_motion.isAnimating) {
        // Complete after dependencies rebuild to keep the parent handoff safe.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _still && _motion.isAnimating) _motion.value = 1;
        });
      }
    }
  }

  @override
  void didUpdateWidget(PullToAdvance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAtEnd != widget.isAtEnd) {
      oldWidget.isAtEnd.removeListener(_endChanged);
      widget.isAtEnd.addListener(_endChanged);
    }
    if (!widget.enabled ||
        (oldWidget.contentKey ?? oldWidget.lessonId) != _content ||
        (_busy && _destination != _next)) {
      _reset(notify: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_busy) widget.onTransition?.call(0);
      });
    }
  }

  void _reset({bool notify = true}) {
    _motion.stop();
    _arrow
      ..stop()
      ..value = 0;
    _lift = 0;
    _settling = false;
    _committing = false;
    _holding = false;
    _incoming = null;
    _advance = null;
    if (notify) widget.onTransition?.call(0);
  }

  void _endChanged() {
    if (!mounted) return;
    setState(() {
      if (!widget.isAtEnd.value) _reset();
    });
  }

  @override
  void dispose() {
    widget.isAtEnd.removeListener(_endChanged);
    _motion.dispose();
    _arrow.dispose();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    final fraction = PantasCurves.slideA.transform(_motion.value);
    setState(() => _lift = _from + (_to - _from) * fraction);
    if (_committing) widget.onTransition?.call(_motion.value);
    if (_committing && _motion.value == 1) _status(AnimationStatus.completed);
  }

  void _status(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_committing || !mounted) return;
    _motion.stop();
    final callback = _advance;
    if (_destination != _next || !_hasHandle) {
      setState(_reset);
      return;
    }
    setState(() {
      _committing = false;
      _holding = _incoming != null;
    });
    callback?.call();
  }

  void _run(double to, Duration duration) {
    _motion.stop();
    _from = _lift;
    _to = to;
    _motion.duration = duration;
    if (_still) {
      _motion.value = 0;
      _motion.value = 1;
    } else {
      _motion.forward(from: 0);
    }
  }

  void _drag(DragUpdateDetails details) {
    if (!_hasHandle || _busy) return;
    _motion.stop();
    _settling = false;
    final wasArmed = _armed;
    setState(() => _lift = (_lift - details.delta.dy).clamp(0.0, 150.0));
    if (wasArmed != _armed) {
      if (_armed && !_still) {
        _arrow.forward(from: 0);
      } else {
        _arrow
          ..stop()
          ..value = _armed ? 1 : 0;
      }
    }
  }

  void _cancel() {
    if (!mounted || _busy || _lift == 0) return;
    _arrow
      ..stop()
      ..value = 0;
    setState(() => _settling = true);
    _run(0, const Duration(milliseconds: 190));
  }

  void _release(DragEndDetails details) {
    if (!_hasHandle || _busy) return;
    if (_pointerCanceled) return _cancel();
    if (_armed) {
      _commit();
    } else {
      _cancel();
    }
  }

  void _commit() {
    if (!_hasHandle || _busy) return;
    final box = context.findRenderObject()! as RenderBox;
    _incoming = widget.incomingChild;
    _destination = _next;
    _advance = widget.onAdvance;
    _committing = true;
    widget.onCommit?.call();
    _run(box.size.height + _lift, const Duration(milliseconds: 480));
  }

  Widget _footer(BuildContext context) {
    if (!_hasDestination) return const SizedBox(width: double.infinity);
    final colors = context.colors;
    final arrowColor = Theme.of(context).brightness == Brightness.dark
        ? colors.controlOutline
        : const Color(0xFF8E8E93);
    final duration = _still ? Duration.zero : const Duration(milliseconds: 150);
    Widget label({required bool armed}) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.finishDay
                  ? (armed
                      ? 'Let go to finish today'
                      : 'Pull up to finish today')
                  : armed
                      ? 'Let go for'
                      : 'Pull up for',
              textAlign: TextAlign.center,
              style:
                  context.type.subhead.copyWith(color: colors.secondaryLabel),
            ),
            if (!widget.finishDay) ...[
              const SizedBox(height: 2),
              Text(
                widget.nextTitle!,
                textAlign: TextAlign.center,
                style: context.type.subhead.copyWith(
                  fontWeight: FontWeight.w600,
                  color: armed ? colors.accent : colors.label,
                ),
              ),
            ],
          ],
        );
    return Visibility(
      visible: _hasHandle,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      child: Padding(
        padding: widget.footerPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              label: widget.finishDay
                  ? 'Finish today'
                  : 'Next lesson: ${widget.nextTitle}',
              onTap: _commit,
              child: ExcludeSemantics(
                child: GestureDetector(
                  onTap: _commit,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox.square(
                    dimension: 44,
                    key: const ValueKey('pull-handle'),
                    child: ProgressRing.pull(
                      fraction: (_lift / _threshold).clamp(0.0, 1.0),
                      child: AnimatedBuilder(
                        animation: _arrow,
                        builder: (_, __) {
                          final t = _arrow.value * 260;
                          final scale = t <= 90
                              ? 1 + .2 * PantasCurves.easeOut.transform(t / 90)
                              : 1.2 -
                                  .2 *
                                      PantasCurves.easeOut
                                          .transform((t - 90) / 170);
                          return Transform.scale(
                            scale: scale,
                            child: CustomPaint(
                              size: const Size(20, 20),
                              painter: _PullArrowPainter(
                                color: Color.lerp(
                                  arrowColor,
                                  colors.accent,
                                  _armed
                                      ? PantasCurves.easeOut
                                          .transform((t / 90).clamp(0.0, 1.0))
                                      : 0,
                                )!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                AnimatedOpacity(
                  duration: duration,
                  opacity: _armed ? 0 : 1,
                  child: ExcludeSemantics(
                    excluding: _armed,
                    child: label(armed: false),
                  ),
                ),
                AnimatedOpacity(
                  duration: duration,
                  opacity: _armed ? 1 : 0,
                  child: ExcludeSemantics(
                    excluding: !_armed,
                    child: label(armed: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final footer = _footer(context);
    final body = widget.contentBuilder?.call(footer) ??
        Column(
          children: [
            Expanded(child: widget.child!),
            footer,
          ],
        );
    final fraction = _holding
        ? 1.0
        : _committing
            ? PantasCurves.slideA.transform(_motion.value)
            : 0.0;
    return Listener(
      onPointerDown: (_) => _pointerCanceled = false,
      onPointerCancel: (_) => _pointerCanceled = true,
      child: GestureDetector(
        onVerticalDragUpdate: _drag,
        onVerticalDragEnd: _release,
        onVerticalDragCancel: _cancel,
        behavior: HitTestBehavior.translucent,
        excludeFromSemantics: true,
        child: ClipRect(
          child: LayoutBuilder(
            builder: (_, constraints) => Stack(
              children: [
                Positioned.fill(
                  child: Transform.translate(
                    key: const ValueKey('pull-outgoing'),
                    offset: Offset(0, -_lift),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.depth != 0) return false;
                        if (notification is OverscrollNotification &&
                            notification.dragDetails != null &&
                            notification.overscroll > 0) {
                          _drag(
                            DragUpdateDetails(
                              globalPosition:
                                  notification.dragDetails!.globalPosition,
                              delta: Offset(0, -notification.overscroll),
                            ),
                          );
                        } else if (notification is ScrollUpdateNotification &&
                            notification.dragDetails != null &&
                            notification.metrics.pixels >
                                notification.metrics.maxScrollExtent &&
                            (notification.scrollDelta ?? 0) > 0) {
                          _drag(
                            DragUpdateDetails(
                              globalPosition:
                                  notification.dragDetails!.globalPosition,
                              delta: Offset(0, -notification.scrollDelta!),
                            ),
                          );
                        } else if (notification is ScrollEndNotification &&
                            _lift > 0 &&
                            !_busy) {
                          _release(DragEndDetails());
                        }
                        return false;
                      },
                      child: body,
                    ),
                  ),
                ),
                if (_incoming != null)
                  Positioned.fill(
                    child: Transform.translate(
                      key: const ValueKey('pull-incoming'),
                      offset: Offset(0, constraints.maxHeight * (1 - fraction)),
                      child: ExcludeFocus(
                        child: ExcludeSemantics(
                          child: IgnorePointer(child: _incoming),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PullArrowPainter extends CustomPainter {
  const _PullArrowPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 24, size.height / 24)
      ..drawPath(
        Path()
          ..moveTo(12, 19)
          ..lineTo(12, 5)
          ..moveTo(6, 11)
          ..lineTo(12, 5)
          ..lineTo(18, 11),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_PullArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
