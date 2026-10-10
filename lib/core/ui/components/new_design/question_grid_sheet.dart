import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum GridQuestionState { right, wrong, answered, unreached }

@immutable
class GridQuestion {
  const GridQuestion({
    required this.number,
    required this.state,
    this.current = false,
    this.flagged = false,
  });
  final int number;
  final GridQuestionState state;
  final bool current;
  final bool flagged;
}

@immutable
class QuestionGridPart {
  const QuestionGridPart({
    required this.title,
    required this.questions,
    this.enabled = true,
  });
  final String title;
  final List<GridQuestion> questions;
  final bool enabled;
}

class QuestionGridSheet extends StatelessWidget {
  const QuestionGridSheet({
    required this.page,
    required this.open,
    required this.onDismiss,
    required this.parts,
    required this.onSelected,
    this.mock = false,
    this.title = 'Questions',
    this.summary,
    super.key,
  });
  final Widget page;
  final bool open;
  final VoidCallback onDismiss;
  final List<QuestionGridPart> parts;
  final ValueChanged<int> onSelected;
  final bool mock;
  final String title;
  final String? summary;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color numberColor(GridQuestion question) {
      if (question.current && question.state == GridQuestionState.unreached) {
        return c.label;
      }
      return switch (question.state) {
        GridQuestionState.right =>
          Theme.of(context).brightness == Brightness.dark ? c.label : c.accent,
        GridQuestionState.wrong => c.wrongText,
        GridQuestionState.unreached => c.secondaryLabel,
        GridQuestionState.answered => c.label,
      };
    }

    return PantasSheet(
      page: page,
      open: open,
      onDismiss: onDismiss,
      label: title,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: c.chevron,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.type.emphasized.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (summary != null)
                  Text(
                    summary!,
                    style:
                        context.type.subhead.copyWith(color: c.secondaryLabel),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            for (var p = 0; p < parts.length; p++) ...[
              if (mock)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: parts[p].enabled ? 1 : .5,
                    child: Text(
                      parts[p].title,
                      style: context.type.sectionHeader,
                    ),
                  ),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = mock ? 6 : 5;
                  final diameter =
                      MediaQuery.textScalerOf(context).scale(17) > 25.5
                          ? 56.0
                          : 46.0;
                  return Wrap(
                    runSpacing: 12,
                    children: [
                      for (final question in parts[p].questions)
                        SizedBox(
                          width: constraints.maxWidth / columns,
                          child: Center(
                            child: Opacity(
                              opacity: parts[p].enabled ? 1 : .5,
                              child: SizedBox.square(
                                dimension: diameter,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    key: ValueKey(
                                      'grid-question-$p-${question.number}',
                                    ),
                                    onTap: parts[p].enabled &&
                                            (mock ||
                                                question.state !=
                                                    GridQuestionState
                                                        .unreached ||
                                                question.current)
                                        ? () {
                                            onSelected(
                                              question.number,
                                            );
                                            onDismiss();
                                          }
                                        : null,
                                    customBorder: const CircleBorder(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: question.state ==
                                                GridQuestionState.right
                                            ? c.accentTint
                                            : question.state ==
                                                    GridQuestionState.wrong
                                                ? c.wrongTint
                                                : question.state ==
                                                        GridQuestionState
                                                            .answered
                                                    ? c.fill
                                                    : null,
                                        border: Border.all(
                                          color: question.current
                                              ? c.label
                                              : question.state ==
                                                      GridQuestionState
                                                          .unreached
                                                  ? c.separator
                                                  : Colors.transparent,
                                          width: question.current ? 2 : 1.5,
                                        ),
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              '${question.number}',
                                              maxLines: 1,
                                              style: context.type.body.copyWith(
                                                fontWeight: question.current
                                                    ? FontWeight.w800
                                                    : question.state ==
                                                            GridQuestionState
                                                                .unreached
                                                        ? FontWeight.w400
                                                        : FontWeight.w600,
                                                color: numberColor(question),
                                              ),
                                            ),
                                          ),
                                          if (question.flagged)
                                            Positioned(
                                              top: -4,
                                              right: -4,
                                              child: Container(
                                                width: 18,
                                                height: 18,
                                                decoration: BoxDecoration(
                                                  color: c.surface,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  PantasIcons.flag,
                                                  size: 12,
                                                  color: c.label,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
            ],
            Text(
              mock
                  ? 'You can go back to any question in this part.'
                  : 'Tap an answered question to look back.',
              textAlign: TextAlign.center,
              style: context.type.footnote,
            ),
          ],
        ),
      ),
    );
  }
}
