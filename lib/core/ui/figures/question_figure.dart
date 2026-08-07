import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/figures/fluid_vessel_figure.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/core/ui/figures/lever_balance_figure.dart';
import 'package:pantas/core/ui/figures/pulley_system_figure.dart';
import 'package:pantas/core/ui/figures/shape_row_figure.dart';
import 'package:pantas/core/ui/figures/spring_scale_figure.dart';
import 'package:pantas/core/ui/figures/stability_shape_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A question's diagram, drawn from the spec in its own content file.
///
/// **Why drawn and not an image.** 155 questions were parked on pictures
/// that did not exist, and they were ten families of about fifteen rather
/// than 155 drawings. Every one is geometric.
/// `specs/2026-08-13-drawn-figures-design.md` has the argument.
///
/// **A bad spec draws a box that says so.** It never draws something
/// plausible, because a figure that disagrees with its own question makes
/// the question unanswerable and no test can catch that.
class QuestionFigure extends StatelessWidget {
  const QuestionFigure({required this.specJson, super.key});

  /// The `figureSpecJson` from the question. Null draws nothing at all.
  final String? specJson;

  @override
  Widget build(BuildContext context) {
    final raw = specJson;
    if (raw == null || raw.trim().isEmpty) return const SizedBox.shrink();

    Map<String, Object?> spec;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const _MissingFigure(reason: 'spec is not a map');
      }
      spec = decoded.cast<String, Object?>();
    } on FormatException {
      return const _MissingFigure(reason: 'spec is not valid JSON');
    }

    final kind = spec['kind'];
    if (kind is! String) {
      return const _MissingFigure(reason: 'spec has no kind');
    }

    final figure = _build(kind, spec);
    if (figure == null) return _MissingFigure(reason: 'no painter for $kind');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: figure,
    );
  }

  Widget? _build(String kind, Map<String, Object?> spec) {
    switch (kind) {
      case GearTrainFigure.kind:
        return GearTrainFigure.fromSpec(spec);
      case SpringScaleFigure.kind:
        return SpringScaleFigure.fromSpec(spec);
      case LeverBalanceFigure.kind:
        return LeverBalanceFigure.fromSpec(spec);
      case PulleySystemFigure.kind:
        return PulleySystemFigure.fromSpec(spec);
      case StabilityShapeFigure.kind:
        return StabilityShapeFigure.fromSpec(spec);
      case FluidVesselFigure.kind:
        return FluidVesselFigure.fromSpec(spec);
      case ShapeRowFigure.kind:
        return ShapeRowFigure.fromSpec(spec);
      default:
        return null;
    }
  }
}

/// Says the figure is missing, in the app's own voice, and stops.
class _MissingFigure extends StatelessWidget {
  const _MissingFigure({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(border: Border.all(color: colors.ruleFaint)),
      child: Text(
        'This question needs a diagram that has not been drawn yet.',
        style: styles.bodySmall.copyWith(color: colors.inkMuted),
        semanticsLabel: 'Diagram missing: $reason',
      ),
    );
  }
}
