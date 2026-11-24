import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/presentation/session_end_timeline.dart';

/// What the last Finish hands to the session end (core loops B2): where the
/// marks of the answer track were on screen, whether each answer was right,
/// and a picture of the question screen to fade out. The picture is optional:
/// without it the screen is simply gone.
class QuizEndFlight {
  QuizEndFlight({required this.from, required this.correct, this.ghost});

  /// One rectangle per question, in screen coordinates. Empty over 20
  /// questions, which fly nothing.
  final List<Rect> from;
  final List<bool> correct;
  ui.Image? ghost;

  /// Frees the picture. Safe to call twice.
  void disposeGhost() {
    ghost?.dispose();
    ghost = null;
  }
}

/// What a session end needs to play one flight: the clock, the timeline, and
/// where each circle of the results row is.
class EndFlightRun {
  EndFlightRun({
    required this.timeline,
    required this.controller,
    required this.slotKeys,
  });

  final SessionEndTimeline timeline;

  /// Runs from 0 to [SessionEndTimeline.length] milliseconds.
  final AnimationController controller;
  final List<GlobalKey> slotKeys;

  /// How big each circle is once landed, set as the row builds.
  late final List<Size> landing = List.filled(slotKeys.length, Size.zero);

  /// Milliseconds since Finish.
  double get elapsed => controller.value * controller.duration!.inMilliseconds;

  /// Wraps the circle for question [index] in the results row. It is empty
  /// until its mark lands (or, over 20 questions, until the row fades in with
  /// the ring), and it tells the flight where to land: [size] centered in
  /// whatever room the circle has.
  Widget slot(int index, Widget circle, {required Size size}) {
    final t = timeline;
    landing[index] = size;
    return AnimatedBuilder(
      animation: controller,
      child: KeyedSubtree(
        key: ValueKey('end-circle-$index'),
        child: KeyedSubtree(
          key: slotKeys[index],
          child: circle,
        ),
      ),
      builder: (context, child) {
        final double opacity;
        if (t.flies) {
          opacity = elapsed >= t.land(index) ? 1 : 0;
        } else {
          opacity = PantasCurves.house.transform(
            ((elapsed - t.rowStart) / _rowFade).clamp(0.0, 1.0),
          );
        }
        return IgnorePointer(
          ignoring: opacity == 0,
          child: Opacity(opacity: opacity, child: child),
        );
      },
    );
  }

  static const int _rowFade = 300;
}

/// Plays the flight over [builder]'s results: the picture of the question
/// screen fades out, then the marks fly from the bar into the row. Under
/// reduced motion nothing travels: the page is simply there.
class QuizEndFlightHost extends StatefulWidget {
  const QuizEndFlightHost({
    required this.flight,
    required this.builder,
    super.key,
  });

  final QuizEndFlight flight;
  final Widget Function(BuildContext context, EndFlightRun run) builder;

  @override
  State<QuizEndFlightHost> createState() => _QuizEndFlightHostState();
}

class _QuizEndFlightHostState extends State<QuizEndFlightHost>
    with SingleTickerProviderStateMixin {
  late final SessionEndTimeline _timeline =
      SessionEndTimeline.flight(count: widget.flight.correct.length);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _timeline.length),
  );
  late final List<GlobalKey> _slots = [
    for (var i = 0; i < widget.flight.correct.length; i++)
      GlobalKey(debugLabel: 'end slot $i'),
  ];
  late final EndFlightRun _run = EndFlightRun(
    timeline: _timeline,
    controller: _controller,
    slotKeys: _slots,
  );
  final GlobalKey _layer = GlobalKey(debugLabel: 'end flight layer');
  bool? _still;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still == _still) return;
    _still = still;
    if (still) {
      _controller
        ..stop()
        ..value = 1;
    } else if (_controller.value == 0) {
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.flight.disposeGhost();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          widget.builder(context, _run),
          Positioned.fill(
            child: IgnorePointer(
              child: _FlightLayer(
                key: _layer,
                flight: widget.flight,
                run: _run,
              ),
            ),
          ),
        ],
      );
}

class _FlightLayer extends StatelessWidget {
  const _FlightLayer({required this.flight, required this.run, super.key});

  final QuizEndFlight flight;
  final EndFlightRun run;

  Rect? _landing(int index) {
    final context = run.slotKeys[index].currentContext;
    final box = context?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    final room = box.localToGlobal(Offset.zero) & box.size;
    final size = run.landing[index];
    return size == Size.zero
        ? room
        : Rect.fromCenter(
            center: room.center,
            width: size.width,
            height: size.height,
          );
  }

  @override
  Widget build(BuildContext context) {
    final t = run.timeline;
    final colors = context.colors;
    final labelStyle =
        context.wideWeb ? PantasType.webFieldLabel : PantasType.phoneCaption;
    final here = context.findRenderObject();
    final origin = here is RenderBox && here.attached
        ? here.localToGlobal(Offset.zero)
        : Offset.zero;
    return AnimatedBuilder(
      animation: run.controller,
      builder: (context, _) {
        final now = run.elapsed;
        final fading = now < t.fade;
        final flying = t.flies && now < t.lastLand;
        if (!fading && !flying) return const SizedBox.shrink();
        final ghost = flight.ghost;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (fading && ghost != null)
              Positioned.fill(
                key: const ValueKey('end-flight-ghost'),
                child: Opacity(
                  opacity: 1 - (now / t.fade).clamp(0.0, 1.0),
                  child: RawImage(image: ghost, fit: BoxFit.fill),
                ),
              ),
            if (flying)
              for (var i = 0; i < flight.from.length; i++)
                if (now < t.land(i)) _mark(i, now, origin, colors, labelStyle),
          ],
        );
      },
    );
  }

  Widget _mark(
    int i,
    double now,
    Offset origin,
    PantasColors colors,
    TextStyle labelStyle,
  ) {
    final t = run.timeline;
    final fly = PantasDurations.trackFly.inMilliseconds;
    final progress = ((now - t.takeOff(i)) / fly).clamp(0.0, 1.0);
    final eased = PantasCurves.move.transform(progress);
    final from = flight.from[i];
    final to = _landing(i) ?? from;
    final rect = Rect.lerp(from, to, eased)!.shift(-origin);
    final right = flight.correct[i];
    final solid = right ? colors.accent : colors.danger;
    final tint = right ? colors.accentTint : colors.dangerTint;
    final ink = right ? colors.accentTintText : colors.dangerText;
    return Positioned.fromRect(
      key: ValueKey('end-flight-mark-$i'),
      rect: rect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.lerp(solid, tint, eased),
          borderRadius: BorderRadius.circular(PantasRadius.full),
        ),
        child: ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Opacity(
              // The number shows in the second half of the flight.
              opacity: ((progress - .5) / .5).clamp(0.0, 1.0),
              child: Text('${i + 1}', style: labelStyle.copyWith(color: ink)),
            ),
          ),
        ),
      ),
    );
  }
}
