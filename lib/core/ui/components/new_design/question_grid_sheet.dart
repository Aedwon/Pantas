import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

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
        return c.textPrimary;
      }
      return switch (question.state) {
        GridQuestionState.right =>
          Theme.of(context).brightness == Brightness.dark
              ? c.textPrimary
              : c.accentTintText,
        GridQuestionState.wrong => c.dangerText,
        GridQuestionState.unreached => c.textSecondary,
        GridQuestionState.answered => c.textPrimary,
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

    final pinned = mock && footer != null;
    final header = <Widget>[
      LayoutBuilder(
        builder: (context, constraints) {
          final titleStyle = PantasType.phoneTitle3.copyWith(
            color: c.textPrimary,
          );
          final summaryStyle = PantasType.phoneExplanation.copyWith(
            color: c.textSecondary,
          );
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
          final detail =
              summary == null ? null : Text(summary!, style: summaryStyle);
          if (detail != null &&
              width(title, titleStyle) + width(summary!, summaryStyle) >
                  constraints.maxWidth) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                const SizedBox(height: PantasSpace.s6),
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
      const SizedBox(height: PantasSpace.s16),
    ];
    final body = <Widget>[
      for (var p = 0; p < parts.length; p++) ...[
        if (mock && parts[p].title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: PantasSpace.s12),
            child: Opacity(
              opacity: parts[p].enabled ? 1 : PantasOpacity.disabled,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      parts[p].title,
                      style: PantasType.phoneSectionHeader.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                  if (parts[p].count != null)
                    Text(
                      parts[p].count!,
                      style: PantasType.phoneFootnoteStrong.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (!parts[p].enabled && parts[p].lockedNote != null)
          Padding(
            padding: const EdgeInsets.only(bottom: PantasSpace.s12),
            child: Text(
              parts[p].lockedNote!,
              style: PantasType.phoneFootnote.copyWith(color: c.textSecondary),
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = mock ? 6 : 5;
            final diameter = MediaQuery.textScalerOf(context).scale(17) > 25.5
                ? PantasSize.select
                : PantasSize.btnBar;
            return Wrap(
              runSpacing: PantasSpace.s12,
              children: [
                for (final question in parts[p].questions)
                  _CurrentQuestion(
                    current: question.current,
                    child: SizedBox(
                      width: constraints.maxWidth / columns,
                      child: Center(
                        child: Opacity(
                          opacity:
                              parts[p].enabled ? 1 : PantasOpacity.disabled,
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
                                  color: Colors.transparent,
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
                                                    GridQuestionState.wrong
                                                ? c.dangerTint
                                                : question.state ==
                                                        GridQuestionState
                                                            .answered
                                                    // The light gray is too
                                                    // close to the dark page.
                                                    ? c.divider
                                                    : null,
                                        border: Border.all(
                                          color: question.current
                                              ? c.textPrimary
                                              : question.state ==
                                                      GridQuestionState
                                                          .unreached
                                                  ? c.borderControl
                                                  : Colors.transparent,
                                          width: question.current
                                              ? PantasBorder.ringCurrent
                                              : PantasBorder.ringStrong,
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
                                              style:
                                                  PantasType.phoneBody.copyWith(
                                                fontWeight: numberWeight(
                                                  question,
                                                ),
                                                color: numberColor(question),
                                              ),
                                            ),
                                          ),
                                          if (question.flagged)
                                            Positioned(
                                              top: -PantasSpace.s4,
                                              right: -PantasSpace.s4,
                                              child: Container(
                                                width: PantasSpace.s18,
                                                height: PantasSpace.s18,
                                                decoration: BoxDecoration(
                                                  color: c.surfaceCard,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  PantasIcons.flag,
                                                  size: PantasSpace.s12,
                                                  color: c.textPrimary,
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
        const SizedBox(height: PantasSpace.s14),
      ],
      Text(
        helpText ??
            (mock
                ? 'You can go back to any question in this part.'
                : 'Tap an answered question to look back.'),
        textAlign: TextAlign.center,
        style: PantasType.phoneFootnote.copyWith(color: c.textSecondary),
      ),
    ];
    return PantasSheet(
      page: page,
      open: open,
      onDismiss: onDismiss,
      label: title,
      closeLabel: 'Close',
      // MK_Sheet: the mock sheet is 664 px under 180 px of the page.
      topInset: pinned ? 272 : (mock ? 180 : 0),
      scrollable: !pinned,
      child: Padding(
        // The sheet's Close button brings the bottom padding. A footer button
        // above it sits 8 apart, as stacked sheet actions do.
        padding: EdgeInsets.fromLTRB(
          PantasSpace.s20,
          PantasSpace.s8,
          PantasSpace.s20,
          footer == null ? PantasSpace.s16 : PantasSpace.s0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...header,
            if (pinned) ...[
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: body,
                  ),
                ),
              ),
              // The Close button below needs room at large text on a short
              // phone, so the gap tightens there and stays 16 otherwise.
              SizedBox(
                height:
                    MediaQuery.textScalerOf(context).scale(PantasSpace.s16) >
                            PantasSpace.s24
                        ? PantasSpace.s12
                        : PantasSpace.s16,
              ),
              footer!,
            ] else ...[
              ...body,
              if (footer != null) ...[
                const SizedBox(height: PantasSpace.s16),
                footer!,
              ],
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
