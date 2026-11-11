import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

/// The numbers of the approved Nov 3 motion preview, Option A for item 1 and
/// item 15. Both run on one 240 ms clock (`PantasDurations.medium1`).
abstract final class PaneMotion {
  static const double _totalMs = 240;

  /// Item 15, the detail leaving: opacity 1 to 0 over 0 to 90 ms, `ease`.
  static const double outEndMs = 90;

  /// Item 15, the detail arriving: opacity 0 to 1 over 70 to 240 ms, the
  /// shared ease, rising [rise] px as it does.
  static const double inStartMs = 70;

  /// How far the arriving detail travels, in px.
  static const double rise = 8;

  static double _phase(double progress, double fromMs, double toMs) =>
      ((progress.clamp(0, 1) * _totalMs - fromMs) / (toMs - fromMs))
          .clamp(0.0, 1.0);

  /// Opacity of the detail being left. [progress] is the 0 to 1 run of the
  /// pane that covers it.
  static double outgoingOpacity(double progress) {
    final t = _phase(progress, 0, outEndMs);
    return 1 - PantasCurves.fade.transform(t);
  }

  /// Opacity of the detail arriving. [progress] is its own route's 0 to 1 run.
  static double incomingOpacity(double progress) =>
      PantasCurves.move.transform(_phase(progress, inStartMs, _totalMs));

  /// How far below its place the arriving detail still sits, in px.
  static double incomingLift(double progress) =>
      (1 - incomingOpacity(progress)) * rise;

  /// Item 1, a whole page fading in: `ease` over the full 240 ms.
  static double fadeOpacity(double progress) =>
      PantasCurves.fade.transform(progress.clamp(0.0, 1.0));
}

/// What a page does when it opens.
enum PaneTransition {
  /// The platform's own page transition, unchanged.
  platform,

  /// No page-level motion at all. The page animates its own detail pane with
  /// [PaneDetailMotion], so a list and heading beside it stay perfectly still.
  detail,

  /// The page fades in over the one behind it, which does not move.
  fade,

  /// The route itself moves nothing and takes no time. The page handles its
  /// own motion: a dialog over a copy of the page behind.
  instant,
}

/// A page whose route moves as [transition] says.
///
/// [transition] is asked when the route opens and again whenever it needs an
/// answer, so layout can decide: wide web gets the new motion, a phone keeps
/// the platform's.
class PaneTransitionPage<T> extends Page<T> {
  const PaneTransitionPage({
    required this.child,
    required this.transition,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final PaneTransition Function(BuildContext context) transition;

  @override
  Route<T> createRoute(BuildContext context) =>
      PaneTransitionRoute<T>(page: this);
}

/// The route for a [PaneTransitionPage].
///
/// The route below never moves while this one opens: its own transition would
/// otherwise parallax it left, which is what made the list slide.
class PaneTransitionRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  PaneTransitionRoute({required PaneTransitionPage<T> page})
      : super(settings: page);

  PaneTransitionPage<T> get _page => settings as PaneTransitionPage<T>;

  /// Every pane route that is open, bottom first.
  static final List<PaneTransitionRoute<dynamic>> _open = [];

  /// Pinged by every open route's animation, so a page under one can follow it.
  static final _Ping _ping = _Ping();

  PaneTransition get _kind {
    final context = navigator?.context;
    return context == null
        ? PaneTransition.platform
        : _page.transition(context);
  }

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => switch (_kind) {
        PaneTransition.platform => super.transitionDuration,
        PaneTransition.instant => Duration.zero,
        _ => PantasDurations.medium1,
      };

  @override
  Duration get reverseTransitionDuration => switch (_kind) {
        PaneTransition.platform => super.reverseTransitionDuration,
        PaneTransition.instant => Duration.zero,
        _ => PantasDurations.medium1,
      };

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      _kind == PaneTransition.platform ? super.delegatedTransition : null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      _kind == PaneTransition.platform &&
      super.canTransitionFrom(previousRoute);

  @override
  void install() {
    super.install();
    _open.add(this);
    animation?.addListener(_ping.ping);
  }

  @override
  void dispose() {
    animation?.removeListener(_ping.ping);
    _open.remove(this);
    // A page left under this route has nothing to follow any more.
    SchedulerBinding.instance.addPostFrameCallback((_) => _ping.ping());
    super.dispose();
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (_kind) {
      case PaneTransition.platform:
        return super.buildTransitions(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      case PaneTransition.detail:
      case PaneTransition.instant:
        return child;
      case PaneTransition.fade:
        if (MediaQuery.disableAnimationsOf(context)) return child;
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: PantasCurves.fade)),
          child: child,
        );
    }
  }

  /// The open detail route that sits on top of [below], or null.
  ///
  /// A route that is not itself a pane route (the tab shell, for one) is
  /// covered by the first detail route open.
  static PaneTransitionRoute<dynamic>? _coverOf(Route<dynamic>? below) {
    final start = below is PaneTransitionRoute ? _open.indexOf(below) + 1 : 0;
    for (var i = start; i < _open.length; i++) {
      final candidate = _open[i];
      if (candidate._kind == PaneTransition.detail) return candidate;
    }
    return null;
  }
}

class _Ping extends ChangeNotifier {
  void ping() => notifyListeners();
}

/// The detail pane of a page that sits beside a list.
///
/// On its own route's way in, the pane fades and rises per [PaneMotion]. When
/// another pane route opens over its page, it fades out. Everything outside
/// the pane is the page's own and does not move.
///
/// While the pane is part-way in or out it paints no background of its own, so
/// the pane of the page behind shows through and fades in step. The rest of
/// the time it paints [background], as the page always has.
///
/// With reduced motion the pane is simply there.
class PaneDetailMotion extends StatefulWidget {
  const PaneDetailMotion({
    required this.background,
    required this.child,
    super.key,
  });

  final Color background;
  final Widget child;

  @override
  State<PaneDetailMotion> createState() => _PaneDetailMotionState();
}

class _PaneDetailMotionState extends State<PaneDetailMotion> {
  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final route = _route;
    final own =
        route is PaneTransitionRoute && route._kind == PaneTransition.detail
            ? route
            : null;
    return ListenableBuilder(
      listenable: Listenable.merge([PaneTransitionRoute._ping, own?.animation]),
      builder: (context, child) {
        var opacity = 1.0;
        var lift = 0.0;
        var entering = false;
        if (!reduced) {
          final enter = own?.animation?.value;
          if (enter != null) {
            opacity = PaneMotion.incomingOpacity(enter);
            lift = PaneMotion.incomingLift(enter);
            entering = enter < 1;
          }
          final cover = PaneTransitionRoute._coverOf(route)?.animation?.value;
          if (cover != null) opacity *= PaneMotion.outgoingOpacity(cover);
        }
        return ColoredBox(
          color: entering ? const Color(0x00000000) : widget.background,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(offset: Offset(0, lift), child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
