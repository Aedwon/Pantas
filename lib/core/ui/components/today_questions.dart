import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
                emptyTrackColor: context.colors.separator,
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
    super.key,
  });
  final String title;
  final int done;
  final int total;
  final List<Widget> rows;
  final String startLabel;
  final VoidCallback? onStart;
  final bool busy;
  final Widget? failure;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: context.colors.controlOutline,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    title,
                    style: context.type.emphasized
                        .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
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
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: rows,
                  ),
                ),
              ),
              if (failure != null) failure!,
              if (onStart != null) ...[
                const SizedBox(height: 10),
                PantasButton(label: startLabel, onPressed: onStart, busy: busy),
              ],
            ],
          ),
        ),
      );
}
