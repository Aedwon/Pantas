import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.subject,
    required this.stem,
    this.figure,
    this.passage,
    this.choices = const [],
    super.key,
  });
  final String subject;
  final String stem;
  final Widget? figure;
  final Widget? passage;
  final List<Widget> choices;
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (passage != null) ...[passage!, const SizedBox(height: 20)],
          Text(subject.toUpperCase(), style: context.type.sectionHeader),
          const SizedBox(height: 20),
          ContentRenderer(
            text: stem,
            style: context.type.emphasized.copyWith(
              fontSize: figure == null ? 21 : 19,
              height: 1.35,
              letterSpacing: figure == null ? -.252 : -.228,
            ),
          ),
          if (figure != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                key: const ValueKey('question-figure-frame'),
                color: context.colors.figureBackground,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Theme(
                  data: buildLightTheme(),
                  child: Material(
                    color: context.colors.figureBackground,
                    child: figure,
                  ),
                ),
              ),
            ),
          ],
          if (choices.isNotEmpty) const SizedBox(height: 20),
          for (var i = 0; i < choices.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            choices[i],
          ],
        ],
      );
}
