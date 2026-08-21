import 'package:flutter/material.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A figure embedded in a lesson Portable Text body.
class LessonFigureWidget extends StatelessWidget {
  const LessonFigureWidget({
    required this.spec,
    required this.semanticsLabel,
    super.key,
  });

  final Map<String, Object?> spec;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final kind = spec['kind'];
    if (kind is! String) {
      return const _MissingLessonFigure(reason: 'spec has no kind');
    }

    final figure = FigureRegistry.build(spec);
    if (figure == null) {
      return _MissingLessonFigure(reason: 'no painter for $kind');
    }

    final padded = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: figure,
    );
    if (semanticsLabel.trim().isEmpty) return padded;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: padded,
    );
  }
}

class _MissingLessonFigure extends StatelessWidget {
  const _MissingLessonFigure({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(border: Border.all(color: colors.ruleFaint)),
      child: Text(
        'This lesson needs a diagram that has not been drawn yet.',
        style: context.textStyles.bodySmall.copyWith(color: colors.inkMuted),
        semanticsLabel: 'Lesson diagram missing: $reason',
      ),
    );
  }
}
