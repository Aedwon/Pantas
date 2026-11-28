import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// Home and Quiz use the same measured Today row.
class TodayQuestionRow extends StatelessWidget {
  const TodayQuestionRow({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.total,
    required this.onTap,
    this.fillDelay = const Duration(milliseconds: 500),
    this.divider = true,
    super.key,
  });
  final String title;
  final String subtitle;
  final int done;
  final int total;
  final VoidCallback onTap;
  final Duration fillDelay;
  final bool divider;
  @override
  Widget build(BuildContext context) => ListRow(
        title: title,
        subtitle: subtitle,
        value: '$done of $total',
        onTap: onTap,
        divider: divider,
        naturalValue: true,
        dividerInset: 52,
        verticalPadding: PantasSpace.s12,
        titleColor:
            total > 0 && done == total ? context.colors.secondaryLabel : null,
        valueStyle: context.type.subhead.copyWith(
          fontWeight: FontWeight.w500,
          color: context.colors.secondaryLabel,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        leading: total > 0 && done == total
            ? const CheckMark()
            : ProgressRing(
                fraction: total == 0 ? 0 : done / total,
                emptyStrokeWidth: 2,
                emptyTrackColor: ProgressRing.phoneEmptyTrack(context),
                // ds-board: ProgressRing README sets no fill time; as built
                fillDuration: const Duration(milliseconds: 700),
                fillDelay: fillDelay,
              ),
      );
}

/// Shared sheet contents with measured figures supplied by the caller.
class TodayQuestionsSheet extends StatelessWidget {
  const TodayQuestionsSheet({
    required this.title,
    required this.done,
    required this.total,
    required this.rows,
    required this.startLabel,
    this.onStart,
    this.busy = false,
    this.failure,
    this.onDiscard,
    this.discarding = false,
    this.blocked = false,
    this.showCount = true,
    super.key,
  });

  /// The "N of M" beside the title. The Reviews sheet leaves it out: each
  /// session row has its own count (his words, Nov 25: "1 of 11 is
  /// redundant, maybe remove the overall so only the rows have one").
  final bool showCount;
  final String title;
  final int done;
  final int total;
  final List<Widget> rows;
  final String startLabel;
  final VoidCallback? onStart;
  final bool busy;
  final Widget? failure;

  /// This sheet's own session is paused: [startLabel] is Resume and Discard
  /// sits under it (board A, his pick Nov 25).
  final VoidCallback? onDiscard;
  final bool discarding;

  /// Another quiz is paused: the line and a dimmed Start, nothing else.
  final bool blocked;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height),
        child: Padding(
          // The boards pad the sheet's bottom 34 and end on the Start button.
          padding: EdgeInsets.fromLTRB(
            PantasSpace.s20,
            PantasSpace.s0,
            PantasSpace.s20,
            PantasSheet.bottomRest(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The grabber is the PantasSheet's own; this draws none.
              const SizedBox(height: PantasSpace.s10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: PantasSpace.s12,
                runSpacing: PantasSpace.s4,
                children: [
                  Text(
                    title,
                    style: PantasType.phoneTitle3
                        .copyWith(color: context.colors.textPrimary),
                  ),
                  if (showCount)
                    Text(
                      '$done of $total',
                      style: context.type.subhead.copyWith(
                        color: context.colors.secondaryLabel,
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: PantasSpace.s10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: rows,
                  ),
                ),
              ),
              if (failure != null) failure!,
              if (blocked) ...[
                const SizedBox(height: PantasSpace.s10),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    pausedQuizBlockLine,
                    textAlign: TextAlign.center,
                    style: PantasType.phoneExplanation
                        .copyWith(color: context.colors.textSecondary),
                  ),
                ),
              ],
              if (onStart != null || blocked) ...[
                const SizedBox(height: PantasSpace.s10),
                PantasButton(
                  label: startLabel,
                  onPressed: blocked ? null : onStart,
                  busy: busy,
                ),
              ],
              if (onDiscard != null) ...[
                // Board A (P_Sheet): the 20 px line sits 16 below Resume and
                // 16 above the end. The line button adds 4 above its text, so
                // 12 here makes 16.
                const SizedBox(height: PantasSpace.s12),
                Center(
                  child: PantasButton(
                    label: 'Discard this session',
                    kind: PantasButtonKind.tertiary,
                    tone: PantasButtonTone.accent,
                    size: PantasButtonSize.textPhoneSm,
                    onPressed: discarding ? null : onDiscard,
                  ),
                ),
                const SizedBox(height: PantasSpace.s16),
              ],
            ],
          ),
        ),
      );
}

/// The line a questions sheet shows while another quiz is paused (board A,
/// "another quiz is paused"). Starting never discards a paused quiz.
const pausedQuizBlockLine = 'Finish or discard your paused quiz first.';

/// A questions row's count: the total, or "1 of 11" once it has begun.
String questionRowCount(int done, int total) =>
    done > 0 && done < total ? '$done of $total' : '$total';
