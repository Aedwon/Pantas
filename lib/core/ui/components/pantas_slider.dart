import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// Sets a number within a range by dragging a thumb (design system Slider).
/// In Pantas it sets the lesson text size, from 1.0 to 2.0 times.
///
/// A visible [label] sits above. The row holds a small "A" ([startLabel]),
/// the track, a large "A" ([endLabel]) and the value. The 4 px track is
/// `accent` left of the thumb (a data mark) and `fill` right of it; the 26 px
/// thumb is `switch-thumb` with a 1 px `border-control` ring and the thumb
/// shadow. The hit area is 44 high. There is no hover or pressed change;
/// disabled is 40% opacity.
///
/// When the row is under 17rem of the scaled text wide (`layout-slider-narrow`)
/// the end labels and the value move above the track, and the track takes the
/// full row width.
class PantasSlider extends StatelessWidget {
  const PantasSlider({
    required this.value,
    required this.onChanged,
    required this.valueText,
    this.label,
    this.min = 1,
    this.max = 2,
    this.divisions = 10,
    this.startLabel = 'A',
    this.endLabel = 'A',
    this.semanticValue,
    this.enabled = true,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;

  /// The shown value ("1.5×"). Use the multiplication sign.
  final String valueText;

  /// The visible label above the row.
  final String? label;
  final double min;
  final double max;

  /// Snap steps (`divisions: 10`).
  final int? divisions;

  /// The small and the large end labels. The "A" glyphs are decoration.
  final String startLabel;
  final String endLabel;

  /// What assistive technology hears for the value ("1.5 times").
  final String? semanticValue;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scaler = MediaQuery.textScalerOf(context);
    final startStyle = PantasType.webLabel.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w500,
      height: 1,
    );
    final endStyle = PantasType.webStatUnit.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w500,
      height: 1,
    );
    final valueStyle = PantasType.webLink.copyWith(
      color: colors.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    // 3.2em of the value's own size, at least.
    final valueMin = PantasSpace.s16 *
        3.2 *
        (scaler.scale(PantasSpace.s16) / PantasSpace.s16);

    Widget glyph(String text, TextStyle style) =>
        ExcludeSemantics(child: Text(text, style: style));
    final valueBox = ConstrainedBox(
      constraints: BoxConstraints(minWidth: valueMin),
      child: ExcludeSemantics(
        child: Text(
          valueText,
          key: const ValueKey('slider-value'),
          textAlign: TextAlign.end,
          style: valueStyle,
        ),
      ),
    );
    final slider = _SliderTrack(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      enabled: enabled,
      semanticLabel: label,
      semanticValue: semanticValue ?? valueText,
      onChanged: onChanged,
    );

    return Opacity(
      opacity: enabled ? 1 : PantasOpacity.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null) ...[
            ExcludeSemantics(child: PantasFieldLabel(label!)),
            const SizedBox(height: PantasSpace.s6),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth <
                  PantasLayout.sliderNarrow *
                      (scaler.scale(PantasSpace.s16) / PantasSpace.s16);
              if (narrow) {
                return Column(
                  key: const ValueKey('slider-stacked'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        glyph(startLabel, startStyle),
                        const Spacer(),
                        glyph(endLabel, endStyle),
                        const SizedBox(width: PantasSpace.s12),
                        valueBox,
                      ],
                    ),
                    slider,
                  ],
                );
              }
              return Row(
                key: const ValueKey('slider-row'),
                children: [
                  glyph(startLabel, startStyle),
                  const SizedBox(width: PantasSpace.s12),
                  Expanded(child: slider),
                  const SizedBox(width: PantasSpace.s12),
                  glyph(endLabel, endStyle),
                  const SizedBox(width: PantasSpace.s12),
                  valueBox,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SliderTrack extends StatelessWidget {
  const _SliderTrack({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.enabled,
    required this.semanticLabel,
    required this.semanticValue,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final bool enabled;
  final String? semanticLabel;
  final String semanticValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OffsetFocusRing(
      borderRadius: BorderRadius.circular(PantasRadius.full),
      child: SizedBox(
        height: PantasSize.targetTouch,
        child: SliderTheme(
          data: SliderThemeData(
            trackHeight: PantasSize.sliderTrack,
            activeTrackColor: colors.accent,
            inactiveTrackColor: colors.fill,
            thumbColor: colors.switchThumb,
            overlayColor: Colors.transparent,
            overlayShape: SliderComponentShape.noOverlay,
            tickMarkShape: SliderTickMarkShape.noTickMark,
            trackShape: const RoundedRectSliderTrackShape(),
            thumbShape: _PantasThumb(
              ring: colors.borderControl,
              shadows: context.shadows.thumb,
            ),
          ),
          child: Semantics(
            label: semanticLabel,
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              semanticFormatterCallback: (_) => semanticValue,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// The 26 px thumb: `switch-thumb` with the thumb shadow and a 1 px
/// `border-control` ring that keeps it at 3:1 on the card.
class _PantasThumb extends SliderComponentShape {
  const _PantasThumb({required this.ring, required this.shadows});

  final Color ring;
  final List<BoxShadow> shadows;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.square(PantasSize.sliderThumb);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    const radius = PantasSize.sliderThumb / 2;
    for (final shadow in shadows) {
      canvas.drawCircle(
        center + shadow.offset,
        radius + shadow.spreadRadius,
        shadow.toPaint(),
      );
    }
    canvas
      ..drawCircle(
        center,
        radius,
        Paint()..color = sliderTheme.thumbColor ?? ring,
      )
      ..drawCircle(
        center,
        radius - PantasBorder.ring / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = PantasBorder.ring
          ..color = ring,
      );
  }
}
