import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/presentation/mock_hourglass.dart';

/// MK_PauseA and the pause half of MK_PauseFlow.
///
/// On entry a large hourglass appears mid-screen, grains fall, and it shrinks
/// into place before the rest of the screen arrives. Resume plays it backwards.
/// Under reduced motion the screen is simply its last frame and Resume acts
/// at once. The clock restarts when [onResume] is called, which is after the
/// closing sequence, so the sequence never costs the student time.
class PausePage extends StatefulWidget {
  const PausePage({
    required this.partNames,
    required this.currentPartIndex,
    required this.remaining,
    required this.partLength,
    required this.answeredCount,
    required this.onResume,
    required this.onDiscard,
    this.paper,
    super.key,
  });

  /// Every part of the paper, in order. A one-block paper has one unnamed part
  /// and shows no list.
  final List<String> partNames;
  final int currentPartIndex;
  final Duration remaining;

  /// How long the open part is, so the sand shows time left of the whole.
  final Duration partLength;
  final int answeredCount;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  /// The frozen paper beneath the approved entry/Resume crossfade.
  final Widget? paper;

  static const entryMilliseconds = 2900;
  static const exitMilliseconds = 2600;
  static const wobbleMilliseconds = 6000;

  @override
  State<PausePage> createState() => _PausePageState();
}

class _PausePageState extends State<PausePage> with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: PausePage.entryMilliseconds),
  );
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: PausePage.exitMilliseconds),
  );
  late final AnimationController _wobble = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: PausePage.wobbleMilliseconds),
  );
  bool? _still;
  var _leaving = false;

  @override
  void initState() {
    super.initState();
    _entry.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          !_leaving &&
          !(_still ?? false)) {
        _wobble.repeat();
      }
    });
    _exit.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onResume();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still == _still) return;
    final first = _still == null;
    _still = still;
    if (still) {
      _wobble.stop();
      _entry.value = 1;
    } else if (first) {
      _entry.forward();
    }
  }

  @override
  void dispose() {
    _entry.dispose();
    _exit.dispose();
    _wobble.dispose();
    super.dispose();
  }

  void _resume() {
    if (_leaving) return;
    if (_still ?? false) {
      widget.onResume();
      return;
    }
    setState(() => _leaving = true);
    _wobble.stop();
    _entry.value = 1;
    _exit.forward();
  }

  void _confirmDiscard() {
    final n = widget.answeredCount;
    final answers = n == 1 ? 'answer gets' : 'answers get';
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: context.colors.shadow.withValues(alpha: .34),
        builder: (dialogContext) => CenteredDialog(
          title: 'Discard this mock?',
          message: "Your $n $answers deleted, and this attempt won't appear "
              "in your record. It also doesn't use up a mock attempt.",
          primaryLabel: 'Discard',
          secondaryLabel: 'Keep It',
          destructive: true,
          onCancel: () => Navigator.pop(dialogContext),
          onConfirm: () {
            Navigator.pop(dialogContext);
            widget.onDiscard();
          },
        ),
      ),
    );
  }

  // ---- the board's timelines, in milliseconds since each sequence began ----

  static double _lerp(double t, double from, double to, double a, double b) =>
      a + (b - a) * ((t - from) / (to - from)).clamp(0.0, 1.0);

  static double _ease(double t, double from, double to) =>
      PantasCurves.edgeGrow.transform(((t - from) / (to - from)).clamp(0, 1));

  /// How far the hourglass is from rest: 1 is large and low, 0 is in place.
  double _bigness(double entry, double exit) =>
      _leaving ? _ease(exit, 300, 800) : 1 - _ease(entry, 2000, 2600);

  double _hourglassOpacity(double entry, double exit) =>
      _leaving ? 1 - _ease(exit, 2000, 2400) : _ease(entry, 0, 350);

  double _pageOpacity(double entry, double exit) =>
      _leaving ? 1 - _lerp(exit, 2200, 2600, 0, 1) : _lerp(entry, 0, 200, 0, 1);

  double _contentOpacity(double entry, double exit) =>
      _leaving ? 1 - _lerp(exit, 0, 250, 0, 1) : _lerp(entry, 2500, 2900, 0, 1);

  /// The falling grains: dash offset and opacity.
  (double, double) _stream(double entry, double exit) {
    if (_leaving) {
      if (exit < 500) return (0, 0);
      if (exit < 650) {
        return (_lerp(exit, 500, 650, 0, -8), _lerp(exit, 500, 650, 0, 1));
      }
      if (exit < 1900) return (_lerp(exit, 650, 1900, -8, -56), 1);
      return (
        _lerp(exit, 1900, 2100, -56, -64),
        _lerp(exit, 1900, 2100, 1, 0),
      );
    }
    if (entry < 200) return (0, 0);
    if (entry < 350) {
      return (_lerp(entry, 200, 350, 0, -8), _lerp(entry, 200, 350, 0, 1));
    }
    if (entry < 1600) return (_lerp(entry, 350, 1600, -8, -56), 1);
    return (
      _lerp(entry, 1600, 1800, -56, -64),
      _lerp(entry, 1600, 1800, 1, 0),
    );
  }

  /// The slow tip, once the hourglass is in place.
  double _tipDegrees(double wobble) {
    const curve = Cubic(.4, 0, .2, 1);
    double segment(double from, double to, double a, double b) =>
        a + (b - a) * curve.transform(_lerp(wobble, from, to, 0, 1));
    if (wobble < 2400) return 0;
    if (wobble < 2700) return segment(2400, 2700, 0, -6);
    if (wobble < 3000) return segment(2700, 3000, -6, 5);
    if (wobble < 3250) return segment(3000, 3250, 5, 0);
    return 0;
  }

  String _clock() {
    final seconds = widget.remaining.inSeconds.clamp(0, 1 << 31);
    final hours = seconds ~/ 3600;
    final minutes = (seconds ~/ 60) % 60;
    final secs = seconds % 60;
    return '${hours > 0 ? '$hours:' : ''}'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fraction = widget.partLength.inMilliseconds <= 0
        ? 0.0
        : widget.remaining.inMilliseconds / widget.partLength.inMilliseconds;
    final showParts = widget.partNames.length > 1;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            Text(
              'Paused',
              style: context.type.largeTitle.copyWith(
                fontSize: 30,
                height: 1.12,
                letterSpacing: -.66,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _clock(),
                  style: context.type.emphasized.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'left in this part',
                    style: context.type.subhead.copyWith(
                      fontSize: 16,
                      color: c.secondaryLabel,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (showParts) ...[
          const SizedBox(height: 22),
          _PartList(
            names: widget.partNames,
            currentIndex: widget.currentPartIndex,
          ),
        ],
      ],
    );

    final bottom = Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.background.withValues(alpha: 0), c.background],
          stops: const [0, .26],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PantasButton(label: 'Resume', onPressed: _resume),
          const SizedBox(height: 8),
          Semantics(
            button: true,
            label: 'Discard This Mock',
            hint: 'Opens a confirmation',
            excludeSemantics: true,
            child: InkWell(
              onTap: _leaving ? null : _confirmDiscard,
              child: SizedBox(
                height: 44,
                child: Center(
                  child: Text(
                    'Discard This Mock',
                    style: context.type.emphasized.copyWith(
                      color: c.destructive,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: Listenable.merge([_entry, _exit, _wobble]),
          builder: (context, _) {
            final entry = _entry.value * PausePage.entryMilliseconds;
            final exit = _exit.value * PausePage.exitMilliseconds;
            final (offset, grains) = _stream(entry, exit);
            final big = _bigness(entry, exit);
            final tip = _leaving || _entry.value < 1
                ? 0.0
                : _tipDegrees(_wobble.value * PausePage.wobbleMilliseconds);
            final hourglass = Opacity(
              opacity: _hourglassOpacity(entry, exit).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 290 * big),
                child: Transform.scale(
                  scale: 1 + 1.4 * big,
                  child: Transform.rotate(
                    key: const ValueKey('pause-hourglass-tip'),
                    angle: tip * math.pi / 180,
                    child: MockHourglass(
                      remainingFraction: fraction,
                      sandColor: c.accentFill,
                      outlineColor: c.label,
                      streamOffset: offset,
                      streamOpacity: grains,
                    ),
                  ),
                ),
              ),
            );
            return Stack(
              fit: StackFit.expand,
              children: [
                if (widget.paper != null)
                  IgnorePointer(
                    child: ExcludeSemantics(
                      child: Opacity(
                        key: const ValueKey('pause-paper'),
                        opacity: 1 - _pageOpacity(entry, exit).clamp(0.0, 1.0),
                        child: widget.paper,
                      ),
                    ),
                  ),
                Opacity(
                  opacity: _pageOpacity(entry, exit).clamp(0.0, 1.0),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(child: hourglass),
                                const SizedBox(height: 18),
                                Opacity(
                                  key: const ValueKey('pause-content'),
                                  opacity: _contentOpacity(entry, exit)
                                      .clamp(0.0, 1.0),
                                  child: content,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: _contentOpacity(entry, exit).clamp(0.0, 1.0),
                          child: IgnorePointer(
                            ignoring: _contentOpacity(entry, exit) < 1,
                            child: bottom,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PartList extends StatelessWidget {
  const _PartList({required this.names, required this.currentIndex});

  final List<String> names;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rowHeight = math
        .max(50, MediaQuery.textScalerOf(context).scale(17) * 1.35 + 4)
        .toDouble();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 14, 16, 14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            children: [
              Column(
                children: [
                  for (var i = 0; i < names.length; i++)
                    SizedBox(
                      height: rowHeight,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: rowHeight,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                if (i < names.length - 1)
                                  Positioned(
                                    top: rowHeight / 2 + 12,
                                    bottom: -12,
                                    child: Container(
                                      width: 2,
                                      color: i < currentIndex
                                          ? c.accentFill
                                          : c.separator,
                                    ),
                                  ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i < currentIndex
                                        ? c.accentFill
                                        : c.surface,
                                    border: i < currentIndex
                                        ? null
                                        : Border.all(
                                            color: i == currentIndex
                                                ? c.accentFill
                                                : c.separator,
                                            width: 2,
                                          ),
                                  ),
                                  child: i < currentIndex
                                      ? Icon(
                                          PantasIcons.check,
                                          size: 13,
                                          color: c.onAccent,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              names[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.type.body.copyWith(
                                fontWeight: i == currentIndex
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: i < currentIndex
                                    ? c.secondaryLabel
                                    : c.label,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Positioned(
                left: 4,
                top: 0,
                child: Transform.translate(
                  key: const ValueKey('pause-part-arrow'),
                  offset: Offset(0, 18 + rowHeight * currentIndex),
                  child: CustomPaint(
                    size: const Size(12, 14),
                    painter: _Arrow(c.accentFill),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Arrow extends CustomPainter {
  const _Arrow(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(1, 1.5)
        ..lineTo(1, 12.5)
        ..lineTo(11, 7)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_Arrow old) => old.color != color;
}
