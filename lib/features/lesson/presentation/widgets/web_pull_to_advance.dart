import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';

// Pull up for the next lesson with a mouse wheel or trackpad, on wide web.
//
// Aedwon approved "Pull and let go" from the motion preview (item 9, option
// A). The phone has its own touch version in pull_to_advance.dart and this
// file does not share it: a wheel sends scroll events, not drags.
//
// TUNING. Every number below starts from the preview, whose own page says
// they are starting points. They need trials on a real mouse and a real
// trackpad before sign-off. Change them here and nowhere else.

/// The pull at which the ring is full. About four mouse notches, or a firm
/// 240 px trackpad pull, since a pull moves half as far as the wheel does.
const double webPullFullAt = 120;

/// The most a pull can be stretched while the ring is full.
const double webPullMax = 150;

/// One wheel event counts for at most this many pixels, so a fast flick is
/// not worth more than a few notches.
const double webPullEventLimit = 60;

/// How far the lesson moves for each pixel of wheel, after the limit above.
const double webPullResistance = .5;

/// A rest this long ends a gesture. The next wheel event starts a new one. A
/// trackpad fling that carries on after the fingers lift is one gesture.
/// Only a gesture that began at the end can pull, so momentum from the scroll
/// that reached the end is ignored.
const Duration webPullGestureGap = Duration(milliseconds: 150);

/// A pull that is not full drops back after this much stillness.
const Duration webPullDropBackAfter = Duration(milliseconds: 450);

/// A full ring opens the next lesson after this much stillness.
const Duration webPullOpenAfter = Duration(milliseconds: 280);

/// The drop back, once it starts.
const Duration webPullSpringBack = Duration(milliseconds: 190);

/// The next lesson rising into place. The same 480 ms as the phone.
const Duration webPullRise = Duration(milliseconds: 480);

/// The pop of the arrow when the ring fills.
const Duration webPullPop = Duration(milliseconds: 260);

/// The words on the card swapping as the pull grows.
const Duration webPullLabelFade = Duration(milliseconds: 150);

/// How close to the end still counts as at the end, in pixels. Tight, so a
/// wheel that can still scroll the lesson is never taken for a pull.
const double webPullEndTolerance = 2;

/// What happens when the next lesson has risen. True if the lesson changed.
typedef WebPullAdvance = FutureOr<bool> Function();

/// What the pull is doing, for the lesson and for the Next card.
///
/// Owned by [WebPullToAdvance]. The reader layout listens to it for the
/// wheel, and the Next card listens to it for the ring.
class WebPullController extends ChangeNotifier {
  WebPullController({required TickerProvider vsync}) {
    _motion = AnimationController(vsync: vsync)
      ..addListener(_tick)
      ..addStatusListener(_status);
    _arrow = AnimationController(vsync: vsync, duration: webPullPop)
      ..addListener(notifyListeners);
  }

  late final AnimationController _motion;
  late final AnimationController _arrow;

  // Set by the owner on every build.
  bool enabled = false;
  bool still = false;
  double height = 0;
  Object contentKey = '';
  Object? destination;
  ScrollController? scroll;
  VoidCallback? onCommit;
  WebPullAdvance? onAdvance;
  Widget? Function()? incomingFactory;

  /// The next lesson, drawn from below once the pull commits.
  Widget? incoming;

  double _lift = 0;
  double _from = 0;
  double _to = 0;
  Curve _curve = PantasCurves.scroll;
  Object? _target;
  bool _settling = false;
  bool _committing = false;
  bool _done = false;
  bool _inGesture = false;
  bool _gestureBeganAtEnd = false;
  Timer? _gestureTimer;
  Timer? _idleTimer;

  /// How far the lesson has been lifted, in pixels.
  double get lift => _lift;

  /// How full the ring is, from 0 to 1.
  double get fraction => (_lift / webPullFullAt).clamp(0.0, 1.0);

  /// Whether letting go now opens the next lesson.
  bool get armed => !_settling && !_done && _lift >= webPullFullAt;

  /// Whether the next lesson is opening or has opened.
  bool get going => _committing || _done;

  /// How far the next lesson has risen, from 0 to 1.
  double get open => _done
      ? 1
      : _committing
          ? PantasCurves.scroll.transform(_motion.value)
          : 0;

  /// The pop of the arrow, from 0 to 1 over [webPullPop].
  double get pop => _arrow.value;

  bool get _hasDestination => enabled && onAdvance != null;

  bool get _atEnd {
    final controller = scroll;
    if (controller == null || !controller.hasClients) return false;
    final position = controller.position;
    return position.pixels >= position.maxScrollExtent - webPullEndTolerance;
  }

  /// Applies what the owner currently wants. Called from build, so it never
  /// notifies: the owner is already rebuilding everything that listens.
  void configure({
    required bool enabled,
    required bool still,
    required Object contentKey,
    required Object? destination,
    required ScrollController? scroll,
    required VoidCallback? onCommit,
    required WebPullAdvance? onAdvance,
    required Widget? Function()? incomingFactory,
  }) {
    final changed = this.contentKey != contentKey;
    this.enabled = enabled;
    this.contentKey = contentKey;
    this.destination = destination;
    this.scroll = scroll;
    this.onCommit = onCommit;
    this.onAdvance = onAdvance;
    this.incomingFactory = incomingFactory;
    if (still != this.still) {
      this.still = still;
      if (still) {
        _arrow
          ..stop()
          ..value = 0;
        if (_motion.isAnimating) {
          // Finish after this build, so the handoff stays safe.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (this.still && _motion.isAnimating) _motion.value = 1;
          });
        }
      }
    }
    if (changed || !_hasDestination) _reset();
  }

  void _reset() {
    _motion.stop();
    _arrow
      ..stop()
      ..value = 0;
    _idleTimer?.cancel();
    _lift = 0;
    _settling = false;
    _committing = false;
    _done = false;
    incoming = null;
    _target = null;
  }

  /// Takes every wheel and trackpad scroll over the lesson column.
  void handleSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_hasDestination) return;
    final delta = event.scrollDelta;
    if (delta.dy == 0 || delta.dx.abs() > delta.dy.abs()) return;
    if (going || _wheel(delta.dy)) {
      // Claimed, so nothing else moves for it. At the end the lesson itself
      // has nowhere to go.
      GestureBinding.instance.pointerSignalResolver.register(event, (_) {});
    }
  }

  /// Returns whether the pull took the event.
  bool _wheel(double dy) {
    final fresh = !_inGesture;
    _inGesture = true;
    _gestureTimer?.cancel();
    _gestureTimer = Timer(webPullGestureGap, () => _inGesture = false);
    final atEnd = _atEnd;
    if (fresh) _gestureBeganAtEnd = atEnd;
    if (!atEnd) {
      // Still reading. Scrolling back up eases a pull that is left over.
      if (_lift > 0 && dy < 0) _move(dy);
      return false;
    }
    if (dy < 0) {
      if (_lift == 0) return false;
      _move(dy);
      return true;
    }
    // This scroll began before the end, so it is momentum or a long scroll
    // that ran on. It never pulls.
    if (!_gestureBeganAtEnd) return true;
    _move(dy);
    return true;
  }

  void _move(double dy) {
    _motion.stop();
    _settling = false;
    final wasArmed = armed;
    final step = math.min(dy.abs(), webPullEventLimit) * webPullResistance;
    _lift = (_lift + (dy > 0 ? step : -step)).clamp(0.0, webPullMax);
    if (armed && !wasArmed) {
      if (!still) _arrow.forward(from: 0);
    } else if (!armed && wasArmed) {
      _arrow
        ..stop()
        ..value = 0;
    }
    notifyListeners();
    _idleTimer?.cancel();
    _idleTimer = Timer(
      armed ? webPullOpenAfter : webPullDropBackAfter,
      _stopped,
    );
  }

  void _stopped() {
    if (going) return;
    if (armed && _hasDestination) {
      commit();
    } else if (_lift > 0) {
      _springBack();
    }
  }

  void _springBack() {
    _arrow
      ..stop()
      ..value = 0;
    _settling = true;
    _run(0, webPullSpringBack, PantasCurves.fade);
  }

  /// Opens the next lesson now: the same rise as a pull that was let go. The
  /// right arrow and a click on the Next card come here.
  void commit() {
    if (!_hasDestination || going) return;
    _idleTimer?.cancel();
    _settling = false;
    incoming = incomingFactory?.call();
    _target = destination;
    _committing = true;
    onCommit?.call();
    _run(height + _lift, webPullRise, PantasCurves.scroll);
    notifyListeners();
  }

  void _run(double to, Duration duration, Curve curve) {
    _motion.stop();
    _from = _lift;
    _to = to;
    _curve = curve;
    _motion.duration = duration;
    if (still) {
      _motion
        ..value = 0
        ..value = 1;
    } else {
      _motion.forward(from: 0);
    }
  }

  void _tick() {
    _lift = _from + (_to - _from) * _curve.transform(_motion.value);
    notifyListeners();
    if (_committing && _motion.value == 1) _status(AnimationStatus.completed);
  }

  void _status(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_settling) {
      _settling = false;
      _lift = 0;
      notifyListeners();
      return;
    }
    if (!_committing) return;
    _motion.stop();
    if (_target != destination || !_hasDestination) {
      _reset();
      notifyListeners();
      return;
    }
    _committing = false;
    _done = true;
    notifyListeners();
    final key = contentKey;
    final moved = onAdvance?.call();
    if (moved is Future<bool>) {
      unawaited(_settle(moved, key));
    } else if (moved == false) {
      _release(key);
    }
  }

  Future<void> _settle(Future<bool> moved, Object key) async {
    var changed = false;
    try {
      changed = await moved;
    } finally {
      if (!changed) _release(key);
    }
  }

  /// The advance did not change the lesson, so nothing will clear the sheet.
  /// Gives the lesson back its input and the wheel.
  void _release(Object key) {
    if (_disposed || !_done || contentKey != key) return;
    _reset();
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _gestureTimer?.cancel();
    _idleTimer?.cancel();
    _motion.dispose();
    _arrow.dispose();
    super.dispose();
  }
}

/// Lifts the lesson with a pull and raises the next lesson over it.
///
/// [builder] draws the lesson. Hand the controller to the reader layout for
/// the wheel and to the Next card for the ring.
class WebPullToAdvance extends StatefulWidget {
  const WebPullToAdvance({
    required this.scrollController,
    required this.enabled,
    required this.contentKey,
    required this.destinationKey,
    required this.onAdvance,
    required this.builder,
    this.onCommit,
    this.incomingBuilder,
    super.key,
  });

  final ScrollController scrollController;

  /// Whether this lesson has somewhere to go. When it does not, the wheel
  /// reads the lesson and nothing more.
  final bool enabled;

  /// Which lesson is on screen. A new one clears any pull.
  final Object contentKey;

  /// Where the pull goes. If it changes while the lesson rises, the move is
  /// dropped.
  final Object? destinationKey;

  /// Runs when the next lesson has risen into place. It returns whether the
  /// lesson changed. If the move was dropped, the sheet goes and the lesson
  /// shows again.
  final WebPullAdvance? onAdvance;

  /// Runs the moment the pull commits, before the next lesson rises.
  final VoidCallback? onCommit;

  /// The next lesson as a sheet, or null for none. Built once, when the pull
  /// commits.
  final Widget? Function(BuildContext context)? incomingBuilder;

  final Widget Function(BuildContext context, WebPullController pull) builder;

  @override
  State<WebPullToAdvance> createState() => _WebPullToAdvanceState();
}

class _WebPullToAdvanceState extends State<WebPullToAdvance>
    with TickerProviderStateMixin {
  late final WebPullController _pull = WebPullController(vsync: this);

  @override
  void dispose() {
    _pull.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.incomingBuilder;
    _pull.configure(
      enabled: widget.enabled,
      still: MediaQuery.disableAnimationsOf(context),
      contentKey: widget.contentKey,
      destination: widget.destinationKey,
      scroll: widget.scrollController,
      onCommit: widget.onCommit,
      onAdvance: widget.onAdvance,
      incomingFactory: builder == null ? null : () => builder(context),
    );
    final lesson = widget.builder(context, _pull);
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _pull.height = constraints.maxHeight;
          return AnimatedBuilder(
            animation: _pull,
            child: lesson,
            builder: (context, lesson) {
              final next = _pull.incoming;
              return Stack(
                children: [
                  Positioned.fill(
                    child: Transform.translate(
                      key: const ValueKey('pull-outgoing'),
                      offset: Offset(0, -_pull.lift),
                      child: lesson,
                    ),
                  ),
                  if (next != null)
                    Positioned.fill(
                      child: Transform.translate(
                        key: const ValueKey('pull-incoming'),
                        offset: Offset(
                          0,
                          constraints.maxHeight * (1 - _pull.open),
                        ),
                        child: ExcludeFocus(
                          child: ExcludeSemantics(
                            child: IgnorePointer(child: next),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// The Next card's label. Three phrases share one place and trade places with
/// the pull: the card's own, "Keep going", then "Let go to open".
class WebPullLabel extends StatelessWidget {
  const WebPullLabel({
    required this.pull,
    required this.label,
    required this.style,
    super.key,
  });

  final WebPullController pull;
  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return ListenableBuilder(
      listenable: pull,
      builder: (context, _) {
        final stage = pull.armed
            ? 2
            : pull.lift > 0
                ? 1
                : 0;
        Widget phrase(int index, String text) => ExcludeSemantics(
              excluding: stage != index,
              child: AnimatedOpacity(
                key: ValueKey('web-next-label-$index'),
                duration: still ? Duration.zero : webPullLabelFade,
                opacity: stage == index ? 1 : 0,
                child: Text(
                  text.toUpperCase(),
                  style: style,
                  softWrap: false,
                ),
              ),
            );
        // All three phrases size the stack, so the widest shows in full. They
        // share one line height, so the card does not move.
        return Stack(
          children: [
            phrase(0, label),
            phrase(1, 'Keep going'),
            phrase(2, 'Let go to open'),
          ],
        );
      },
    );
  }
}

/// The arrow circle with the ring around it. The ring is 56 px on the 44 px
/// circle, 2.5 px wide, filling clockwise from the top. It pops when full.
class WebPullCircle extends StatelessWidget {
  const WebPullCircle({
    required this.pull,
    required this.track,
    required this.arc,
    required this.child,
    super.key,
  });

  final WebPullController pull;
  final Color track;
  final Color arc;

  /// The 44 px circle itself.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pull,
      child: child,
      builder: (context, circle) {
        final t = pull.pop * webPullPop.inMilliseconds;
        final scale = t <= 90
            ? 1 + .2 * PantasBoardCurves.easeOut.transform(t / 90)
            : 1.2 - .2 * PantasBoardCurves.easeOut.transform((t - 90) / 170);
        return Transform.scale(
          scale: scale,
          child: SizedBox.square(
            dimension: 44,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -6,
                  top: -6,
                  child: CustomPaint(
                    key: const ValueKey('web-next-ring'),
                    size: const Size.square(56),
                    painter: _PullRingPainter(
                      fraction: pull.fraction,
                      track: track,
                      arc: arc,
                    ),
                  ),
                ),
                circle!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PullRingPainter extends CustomPainter {
  const _PullRingPainter({
    required this.fraction,
    required this.track,
    required this.arc,
  });

  final double fraction;
  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    if (fraction <= 0) return;
    final center = size.center(Offset.zero);
    const radius = 25.0;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas
      ..drawCircle(center, radius, stroke..color = track)
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        stroke..color = arc,
      );
  }

  @override
  bool shouldRepaint(_PullRingPainter oldDelegate) =>
      fraction != oldDelegate.fraction ||
      track != oldDelegate.track ||
      arc != oldDelegate.arc;
}
