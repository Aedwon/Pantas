import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/figures/figure_matrix_figure.dart';
import 'package:pantas/core/ui/figures/figure_series_figure.dart';
import 'package:pantas/core/ui/figures/shape_row_figure.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

/// One figure of a figure choice, ready to draw.
///
/// A figure choice carries one item of its question's figure: a series item,
/// a matrix cell or a shape-row shape. This reads that item by the question
/// figure's kind and draws it with the same painters the question figure
/// uses, so a choice and its source item look identical.
///
/// Only the kinds below have a single-item painter. A cube net never has
/// figure choices, and a paper fold has no single-result painter, so a
/// question on either keeps its text rows.
@immutable
sealed class ChoiceFigure {
  const ChoiceFigure();

  /// The question figure kinds whose items can be drawn as a choice.
  static const kinds = {
    FigureSeriesFigure.kind,
    FigureMatrixFigure.kind,
    ShapeRowFigure.kind,
  };

  /// The kind named in a question's `figureSpecJson`, or null when the spec
  /// is missing or cannot be read.
  static String? kindOf(String? specJson) {
    if (specJson == null || specJson.trim().isEmpty) return null;
    try {
      final spec = jsonDecode(specJson);
      if (spec is Map && spec['kind'] is String) return spec['kind'] as String;
    } on FormatException {
      return null;
    }
    return null;
  }

  /// The drawable figure for [figureJson] under a question figure of [kind],
  /// or null when there is none, the kind has no single-item painter, or the
  /// item cannot be read.
  static ChoiceFigure? parse(String? kind, String? figureJson) {
    if (kind == null || figureJson == null || figureJson.trim().isEmpty) {
      return null;
    }
    final Object? raw;
    try {
      raw = jsonDecode(figureJson);
    } on FormatException {
      return null;
    }
    switch (kind) {
      case FigureSeriesFigure.kind:
      case FigureMatrixFigure.kind:
        final item = FigureSeriesFigure.parseItem(raw);
        return item == null ? null : _SeriesChoiceFigure(item);
      case ShapeRowFigure.kind:
        final shape = ShapeRowFigure.parseShape(raw);
        return shape == null ? null : _ShapeChoiceFigure(shape);
    }
    return null;
  }

  /// The figures for every choice of [choices], or null unless each one can
  /// be drawn. One bad choice sends the whole question back to text rows, so
  /// a question never mixes tiles and rows.
  static List<ChoiceFigure>? parseAll(
    String? specJson,
    List<Choice> choices,
  ) {
    final kind = kindOf(specJson);
    if (kind == null || choices.isEmpty) return null;
    final out = <ChoiceFigure>[];
    for (final choice in choices) {
      final figure = parse(kind, choice.figureJson);
      if (figure == null) return null;
      out.add(figure);
    }
    return out;
  }

  /// The ratio of the figure's radius to the side of the square it is drawn
  /// in. The question figures use the same ratio against their height.
  double get radiusShare;

  void paint(Canvas canvas, Offset centre, double radius);
}

class _SeriesChoiceFigure extends ChoiceFigure {
  const _SeriesChoiceFigure(this.item);

  final SeriesItem item;

  @override
  double get radiusShare => 0.36;

  @override
  void paint(Canvas canvas, Offset centre, double radius) =>
      FigureSeriesFigure.paintItem(
        canvas,
        item,
        centre,
        radius,
        SeriesPalette.fixed,
      );
}

class _ShapeChoiceFigure extends ChoiceFigure {
  const _ShapeChoiceFigure(this.shape);

  final RowShape shape;

  @override
  double get radiusShare => 0.34;

  @override
  void paint(Canvas canvas, Offset centre, double radius) =>
      ShapeRowFigure.paintShape(
        canvas,
        shape,
        centre,
        radius,
        PantasColors.light.textPrimary,
      );
}

/// Draws [figure] in the largest square that fits, centered, in the ink of a
/// printed figure. It sits on the white figure backing in both themes, so it
/// never takes a theme color.
class ChoiceFigureDrawing extends StatelessWidget {
  const ChoiceFigureDrawing({required this.figure, super.key});

  final ChoiceFigure figure;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ChoicePainter(figure),
        size: Size.infinite,
      );
}

class _ChoicePainter extends CustomPainter {
  _ChoicePainter(this.figure);

  final ChoiceFigure figure;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    figure.paint(
      canvas,
      size.center(Offset.zero),
      side * figure.radiusShare,
    );
  }

  @override
  bool shouldRepaint(_ChoicePainter old) => old.figure != figure;
}

/// What a question shows for its choices, decided in one place so the phone
/// and the web agree.
@immutable
class QuestionChoicePlan {
  const QuestionChoicePlan._(this.figures, this.showQuestionFigure);

  /// Tiles show when the question asks for them and every choice has a
  /// figure it can draw. Anything else, mixed or bad data included, keeps
  /// today's text rows. The question figure hides only when tiles show: a
  /// question that falls back to rows still needs its figure.
  factory QuestionChoicePlan.of(Question question) {
    final figures = question.choiceKind == ChoiceKind.figure
        ? ChoiceFigure.parseAll(question.figureSpecJson, question.choices)
        : null;
    return QuestionChoicePlan._(
      figures,
      figures == null || question.showQuestionFigure,
    );
  }

  /// One figure per choice when the choices are drawn as tiles, else null.
  final List<ChoiceFigure>? figures;

  /// Whether the question's own figure shows.
  final bool showQuestionFigure;

  bool get tiles => figures != null;
}
