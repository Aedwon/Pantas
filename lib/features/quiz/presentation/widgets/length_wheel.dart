import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/domain/picker/practice_summary.dart';

/// Fixed column width, so every value lands on one optical centre whatever
/// its number of digits.
const wheelColumnWidth = 52.0;
const wheelHeight = 58.0;
const _bandHeight = 38.0;

/// Questions 3 to 50 by one. Minutes 2 to 30 by one, then 35 to 60 by five.
List<int> wheelValues(PracticeUnitMode mode) => switch (mode) {
      PracticeUnitMode.questions => [for (var i = 3; i <= 50; i++) i],
      PracticeUnitMode.minutes => [
          for (var i = 2; i <= 30; i++) i,
          for (var i = 35; i <= 60; i += 5) i,
        ],
    };

/// The nearest value in [candidates], so switching units and back does not
/// drift the number a step at a time.
int snapToNearest(int value, List<int> candidates) {
  var best = candidates.first;
  var bestDistance = (value - best).abs();
  for (final candidate in candidates) {
    final distance = (value - candidate).abs();
    if (distance < bestDistance) {
      best = candidate;
      bestDistance = distance;
    }
  }
  return best;
}

/// The picker footer's length control.
///
/// Scroll-snapped rather than a slider: the values are discrete, and a slider
/// would invite a drag to a number between two steps.
class LengthWheel extends StatefulWidget {
  const LengthWheel({
    required this.mode,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final PracticeUnitMode mode;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<LengthWheel> createState() => _LengthWheelState();
}

class _LengthWheelState extends State<LengthWheel> {
  late FixedExtentScrollController _controller;

  List<int> get _values => wheelValues(widget.mode);

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: _values.indexOf(widget.value).clamp(0, _values.length - 1),
    );
  }

  @override
  void didUpdateWidget(LengthWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _values.indexOf(widget.value);
    if (target >= 0 && target != _controller.selectedItem) {
      _controller.jumpToItem(target);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SizedBox(
      height: wheelHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // No rails and no border. The list above this footer is nothing but
          // hairlines, and a tint marks the choice without adding a fourth
          // kind of rule to the screen.
          Container(
            width: wheelColumnWidth,
            height: _bandHeight,
            color: colors.boardTint,
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0, 0.22, 0.78, 1],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: RotatedBox(
              quarterTurns: -1,
              child: ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: wheelColumnWidth,
                perspective: 0.002,
                diameterRatio: 100,
                physics: const FixedExtentScrollPhysics(),
                // The value commits on scroll, not only on tap: whatever sits
                // inside the band is the value.
                onSelectedItemChanged: (index) {
                  if (!reduceMotion) unawaited(HapticFeedback.selectionClick());
                  widget.onChanged(_values[index]);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _values.length,
                  builder: (context, index) {
                    final isSelected = _values[index] == widget.value;
                    return RotatedBox(
                      quarterTurns: 1,
                      child: Center(
                        child: Text(
                          '${_values[index]}',
                          style: isSelected
                              ? styles.displaySmall.copyWith(
                                  fontSize: 21,
                                  color: colors.ink,
                                )
                              : styles.bodyMedium.copyWith(
                                  fontSize: 14.5,
                                  color: colors.inkMuted,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
