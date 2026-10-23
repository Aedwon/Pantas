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
    this.count,
    this.lockedNote,
  });
  final String title;
  final List<GridQuestion> questions;
  final bool enabled;
  final String? count;
  final String? lockedNote;
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
    this.footer,
    this.helpText,
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
  final Widget? footer;
  final String? helpText;
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

    FontWeight numberWeight(GridQuestion question) => question.current
        ? FontWeight.w800
        : question.state == GridQuestionState.unreached
            ? FontWeight.w400
            : FontWeight.w600;

    String questionLabel(GridQuestion question) {
      final result = switch (question.state) {
        GridQuestionState.right => 'correct',
        GridQuestionState.wrong => 'wrong',
        GridQuestionState.answered => 'answered',
        GridQuestionState.unreached => 'not reached',
      };
      return 'Question ${question.number}'
          '${question.current ? ', current' : ''}, $result'
          '${question.flagged ? ', flagged' : ''}';
    }

    VoidCallback? actionFor(GridQuestion question, {required bool enabled}) {
      if (!enabled ||
          (!mock &&
              question.state == GridQuestionState.unreached &&
              !question.current)) {
        return null;
      }
      return () {
        onSelected(question.number);
        onDismiss();
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
                  color: c.controlOutline,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final titleStyle = context.type.emphasized
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w700);
                final summaryStyle =
                    context.type.subhead.copyWith(color: c.secondaryLabel);
                double width(String text, TextStyle style) {
                  final measure = TextPainter(
                    text: TextSpan(text: text, style: style),
                    textScaler: MediaQuery.textScalerOf(context),
                    textDirection: Directionality.of(context),
                  )..layout();
                  final result = measure.width;
                  measure.dispose();
                  return result;
                }

                final heading = Text(title, style: titleStyle);
                final detail = summary == null
                    ? null
                    : Text(summary!, style: summaryStyle);
                if (detail != null &&
                    width(title, titleStyle) + width(summary!, summaryStyle) >
                        constraints.maxWidth) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading,
                      const SizedBox(height: 6),
                      detail,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: heading),
                    if (detail != null) detail,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            for (var p = 0; p < parts.length; p++) ...[
              if (mock && parts[p].title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: parts[p].enabled ? 1 : .32,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            parts[p].title,
                            style: context.type.sectionHeader,
                          ),
                        ),
                        if (parts[p].count != null)
                          Text(
                            parts[p].count!,
                            style: context.type.footnote.copyWith(
                              color: c.secondaryLabel,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (!parts[p].enabled && parts[p].lockedNote != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    parts[p].lockedNote!,
                    style:
                        context.type.footnote.copyWith(color: c.secondaryLabel),
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
                        _CurrentQuestion(
                          current: question.current,
                          child: SizedBox(
                            width: constraints.maxWidth / columns,
                            child: Center(
                              child: Opacity(
                                opacity: parts[p].enabled ? 1 : .32,
                                child: SizedBox.square(
                                  dimension: diameter,
                                  child: Semantics(
                                    label: questionLabel(question),
                                    selected: question.current,
                                    button: true,
                                    enabled: actionFor(
                                          question,
                                          enabled: parts[p].enabled,
                                        ) !=
                                        null,
                                    onTap: actionFor(
                                      question,
                                      enabled: parts[p].enabled,
                                    ),
                                    child: ExcludeSemantics(
                                      child: Material(
                                        color: context.colors.transparent,
                                        child: InkWell(
                                          key: ValueKey(
                                            'grid-question-$p-'
                                            '${question.number}',
                                          ),
                                          onTap: actionFor(
                                            question,
                                            enabled: parts[p].enabled,
                                          ),
                                          customBorder: const CircleBorder(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: question.state ==
                                                      GridQuestionState.right
                                                  ? c.accentTint
                                                  : question.state ==
                                                          GridQuestionState
                                                              .wrong
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
                                                        : context
                                                            .colors.transparent,
                                                width:
                                                    question.current ? 2 : 1.5,
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
                                                    style: context.type.body
                                                        .copyWith(
                                                      fontWeight: numberWeight(
                                                        question,
                                                      ),
                                                      color:
                                                          numberColor(question),
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
              helpText ??
                  (mock
                      ? 'You can go back to any question in this part.'
                      : 'Tap an answered question to look back.'),
              textAlign: TextAlign.center,
              style: context.type.footnote.copyWith(color: c.secondaryLabel),
            ),
            if (footer != null) ...[
              const SizedBox(height: 16),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _CurrentQuestion extends StatefulWidget {
  const _CurrentQuestion({required this.current, required this.child});
  final bool current;
  final Widget child;
  @override
  State<_CurrentQuestion> createState() => _CurrentQuestionState();
}

class _CurrentQuestionState extends State<_CurrentQuestion> {
  @override
  void initState() {
    super.initState();
    if (widget.current) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Scrollable.ensureVisible(context, alignment: .5);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
