import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class PartTransitionPage extends StatefulWidget {
  const PartTransitionPage({
    required this.partNames,
    required this.nextPartIndex,
    required this.answeredQuestions,
    required this.endedEarly,
    required this.onStartNext,
    super.key,
  }) : assert(
          nextPartIndex > 0 && nextPartIndex < partNames.length,
          'A transition requires both a closed part and a next part.',
        );

  final List<String> partNames;
  final int nextPartIndex;
  final List<bool> answeredQuestions;
  final bool endedEarly;
  final VoidCallback onStartNext;

  @override
  State<PartTransitionPage> createState() => _PartTransitionPageState();
}

class _PartTransitionPageState extends State<PartTransitionPage>
    with SingleTickerProviderStateMixin {
  late final int _duration =
      math.max(2050, 400 + (widget.answeredQuestions.length - 1) * 12);
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _duration),
  );
  bool? _still;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (_still == still) return;
    final first = _still == null;
    _still = still;
    if (still) {
      _motion
        ..stop()
        ..value = 1;
    } else if (first || _motion.value < 1) {
      _motion.forward();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  double segment(int start, int length, Curve curve) {
    final elapsed = _motion.value * _duration - start;
    if (elapsed < .000001) return 0;
    if (elapsed >= length - .000001) return 1;
    return curve.transform(elapsed / length);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final answered = widget.answeredQuestions.where((value) => value).length;
    final closedIndex = widget.nextPartIndex - 1;
    final blank = widget.answeredQuestions.length - answered;
    final rowHeight = math
        .max(50, MediaQuery.textScalerOf(context).scale(17) * 1.35 + 4)
        .toDouble();
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 54, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.endedEarly
                                  ? 'Part ${widget.nextPartIndex} ended.'
                                  : 'Time is up.',
                              style: context.type.largeTitle.copyWith(
                                fontSize: 32,
                                height: 1.12,
                                letterSpacing: -.704,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Part ${widget.nextPartIndex} · '
                              '${widget.partNames[closedIndex]}',
                              style: context.type.subhead.copyWith(
                                fontSize: 16,
                                color: c.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          child: Column(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final columns = math.min(
                                    12,
                                    ((constraints.maxWidth + 7) / 25).floor(),
                                  );
                                  return SizedBox(
                                    width: columns * 25 - 7,
                                    child: AnimatedBuilder(
                                      animation: _motion,
                                      builder: (context, _) => Wrap(
                                        spacing: 7,
                                        runSpacing: 7,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          for (var i = 0;
                                              i <
                                                  widget
                                                      .answeredQuestions.length;
                                              i++)
                                            _dot(context, i),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _legend(
                                    context,
                                    '$answered answered',
                                    blank: false,
                                  ),
                                  _legend(
                                    context,
                                    '$blank blank',
                                    blank: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedBuilder(
                          animation: _motion,
                          builder: (context, _) {
                            final pop = segment(1400, 220, PantasCurves.popA);
                            final settle =
                                segment(1620, 160, PantasCurves.popA);
                            final scale = _motion.value * _duration < 1620
                                ? .5 + .65 * pop
                                : 1.15 - .15 * settle;
                            return Stack(
                              children: [
                                Column(
                                  children: [
                                    for (var i = 0;
                                        i < widget.partNames.length;
                                        i++)
                                      SizedBox(
                                        height: rowHeight,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 26),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 24,
                                                height: rowHeight,
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  alignment: Alignment.center,
                                                  children: [
                                                    if (i <
                                                        widget.partNames
                                                                .length -
                                                            1)
                                                      Positioned(
                                                        top: rowHeight / 2 + 12,
                                                        bottom: -12,
                                                        child: Container(
                                                          width: 2,
                                                          color: c.accentFill,
                                                        ),
                                                      ),
                                                    Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: i < closedIndex
                                                            ? c.accentFill
                                                            : c.surface,
                                                        border: Border.all(
                                                          color: c.accentFill,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: i < closedIndex
                                                          ? Icon(
                                                              PantasIcons.check,
                                                              size: 13,
                                                              color: c.onAccent,
                                                            )
                                                          : null,
                                                    ),
                                                    if (i == closedIndex)
                                                      Opacity(
                                                        opacity: pop.clamp(
                                                          0.0,
                                                          1.0,
                                                        ),
                                                        child: Transform.scale(
                                                          scale: scale,
                                                          child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  c.accentFill,
                                                            ),
                                                            child: Icon(
                                                              PantasIcons.check,
                                                              size: 13,
                                                              color: c.onAccent,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Text(
                                                  widget.partNames[i],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context.type.body
                                                      .copyWith(
                                                    fontWeight: i ==
                                                            widget.nextPartIndex
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                    color: i ==
                                                            widget.nextPartIndex
                                                        ? c.label
                                                        : c.secondaryLabel,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Positioned(
                                  left: 4,
                                  top: 0,
                                  child: Transform.translate(
                                    key: const ValueKey('part-arrow'),
                                    offset: Offset(
                                      0,
                                      18 +
                                          rowHeight *
                                              (closedIndex +
                                                  segment(
                                                    1600,
                                                    450,
                                                    PantasCurves.slideA,
                                                  )),
                                    ),
                                    child: CustomPaint(
                                      size: const Size(12, 14),
                                      painter: _PartArrow(c.accentFill),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PantasButton(
                      label: 'Start Part ${widget.nextPartIndex + 1}',
                      onPressed: widget.onStartNext,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The clock starts when you tap.',
                      textAlign: TextAlign.center,
                      style: context.type.footnote
                          .copyWith(color: c.secondaryLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(BuildContext context, int index) {
    final progress = segment(200 + 12 * index, 200, PantasCurves.houseOut);
    final answered = widget.answeredQuestions[index];
    final c = context.colors;
    return SizedBox(
      width: 18,
      height: 18,
      child: Opacity(
        key: ValueKey('part-dot-opacity-$index'),
        opacity: progress,
        child: Transform.scale(
          scale: .4 + .6 * progress,
          child: DecoratedBox(
            key: ValueKey('part-dot-$index'),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: answered ? c.pendingMark : null,
              border: answered
                  ? null
                  : Border.all(color: c.tertiaryLabel, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _legend(BuildContext context, String label, {required bool blank}) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: blank ? null : context.colors.pendingMark,
              border: blank
                  ? Border.all(
                      color: context.colors.tertiaryLabel,
                      width: 1.5,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: context.type.footnote.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.secondaryLabel,
              ),
            ),
          ),
        ],
      );
}

class _PartArrow extends CustomPainter {
  const _PartArrow(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(1, 1.5)
      ..lineTo(1, 12.5)
      ..lineTo(11, 7)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PartArrow oldDelegate) => oldDelegate.color != color;
}
