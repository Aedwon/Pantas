import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A count that rolls up a vertical strip of digits, one row per number.
///
/// [count] runs from 0 to [last]. At 1.5 the strip sits half way between row
/// 1 and row 2. The clip is one row tall. Rows far from the current number
/// are not built, so a large count costs three rows, not all of them.
///
/// The quiz result gauge and the first-run end screen share it. [fade] adds
/// the first-run board's top and bottom fade (`mask-image`); the gauge does
/// not use it.
class RollingDigits extends StatelessWidget {
  const RollingDigits({
    required this.count,
    required this.last,
    required this.style,
    required this.rowHeight,
    this.fade = false,
    super.key,
  });

  /// The rolled value, 0 up to [last].
  final Animation<double> count;

  /// The final number. It sets the width, so the digits do not move the
  /// text beside them while they roll.
  final int last;

  /// The digit style. Its font size is the size the board draws.
  final TextStyle style;

  /// A row's height at a text scale of 1.
  final double rowHeight;

  /// Fades the top and bottom edges of the clip.
  final bool fade;

  @override
  Widget build(BuildContext context) {
    final fontSize = style.fontSize!;
    final scaler = MediaQuery.textScalerOf(context);
    final extent = rowHeight * scaler.scale(fontSize) / fontSize;
    final measure = TextPainter(
      text: TextSpan(
        text: '${math.max(last, count.value.ceil())}',
        style: style,
      ),
      textDirection: Directionality.of(context),
      textScaler: scaler,
    )..layout();
    final width = measure.width;
    measure.dispose();
    Widget clip = ClipRect(
      child: SizedBox(
        width: width,
        height: extent,
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: double.infinity,
          child: AnimatedBuilder(
            animation: count,
            builder: (context, _) => Transform.translate(
              key: const ValueKey('quiz-count-strip'),
              offset: Offset(0, -count.value * extent),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Keep only the current number and its neighbors.
                  // Preserve the board's absolute offset with a spacer.
                  SizedBox(
                    height: math.max(0, count.value.floor() - 1) * extent,
                  ),
                  for (var i = math.max(0, count.value.floor() - 1);
                      i <=
                          math.min(
                            math.max(last, count.value.ceil()),
                            count.value.ceil() + 1,
                          );
                      i++)
                    SizedBox(
                      height: extent,
                      child: Center(child: Text('$i', style: style)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (fade) {
      clip = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // ds-board: P06 `linear-gradient(transparent, #000 18%, #000 82%,
          // transparent)`
          stops: const [0, .18, .82, 1],
          // Only the alpha counts in a dstIn mask; any opaque role works.
          colors: [
            Colors.transparent,
            context.colors.textPrimary,
            context.colors.textPrimary,
            Colors.transparent,
          ],
        ).createShader(rect),
        child: clip,
      );
    }
    return clip;
  }
}
