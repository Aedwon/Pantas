import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.subject,
    required this.stem,
    this.figure,
    this.passage,
    this.choices = const [],
    this.headerTrailing,
    this.showHeader = true,
    this.showSubject = true,
    super.key,
  });
  final String subject;

  /// False draws the card with no eyebrow and none of its space.
  final bool showSubject;
  final String stem;
  final Widget? figure;
  final Widget? passage;
  final List<Widget> choices;

  /// The question header's trailing slot (`page-head__trail`). On a phone
  /// narrower than 400 the quiz puts the flag here (D71).
  final Widget? headerTrailing;

  /// False when the page pins the subject row above its own scroll view.
  final bool showHeader;
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (passage != null) ...[
            passage!,
            const SizedBox(height: PantasSpace.s20),
          ],
          if (showHeader && showSubject) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    subject.toUpperCase(),
                    style: PantasType.phoneSectionHeader.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                if (headerTrailing != null) headerTrailing!,
              ],
            ),
            const SizedBox(height: PantasSpace.s8),
          ],
          ContentRenderer(
            text: stem,
            questionStem: true,
            style: PantasType.phoneQuestion.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          if (figure != null) ...[
            const SizedBox(height: PantasSpace.s20),
            ClipRRect(
              borderRadius: BorderRadius.circular(PantasRadius.lg),
              child: Container(
                key: const ValueKey('question-figure-frame'),
                color: context.colors.figureBg,
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s14,
                  PantasSpace.s14,
                  PantasSpace.s14,
                  PantasSpace.s10,
                ),
                child: Theme(
                  data: buildLightTheme(),
                  child: Material(
                    color: context.colors.figureBg,
                    child: figure,
                  ),
                ),
              ),
            ),
          ],
          if (choices.isNotEmpty) const SizedBox(height: PantasSpace.s20),
          for (var i = 0; i < choices.length; i++) ...[
            if (i > 0) const SizedBox(height: PantasSpace.s10),
            choices[i],
          ],
        ],
      );
}
