import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';

/// HP_ExamDay. Nothing new is planned. The optional warm-up is the actual
/// stored review membership, so every figure here is its real count.
class HomeExamDay extends StatelessWidget {
  const HomeExamDay({
    required this.examShortName,
    required this.reviewsTotal,
    required this.reviewsDone,
    required this.onRow,
    required this.onStart,
    this.onPlan,
    this.busy = false,
    this.web = kIsWeb,
    super.key,
  });
  final bool web;
  final String examShortName;
  final int reviewsTotal;
  final int reviewsDone;
  final VoidCallback onRow;
  final VoidCallback onStart;
  final VoidCallback? onPlan;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final hasWarmUp = reviewsTotal > 0;
    final detail = _examDayDetail(reviewsTotal);
    if (isWideWebLayout(width: MediaQuery.sizeOf(context).width, web: web)) {
      // The board sets the title above both columns (HomeExamDayIntro), so
      // this column holds only the warm-up card.
      if (!hasWarmUp) return const SizedBox.shrink();
      final t = context.webTokens;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeTodayHeader(onPlan: onPlan, web: web),
          WebCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WebRow(
                  boardMetrics: true,
                  title: 'Warm-up reviews',
                  subtitle: 'Optional',
                  value: '$reviewsDone of $reviewsTotal',
                  leading: SizedBox.square(
                    dimension: 26,
                    child: Center(
                      child: ProgressRing(
                        fraction: reviewsDone / reviewsTotal,
                        emptyStrokeWidth: 2,
                        emptyTrackColor: ProgressRing.phoneEmptyTrack(context),
                      ),
                    ),
                  ),
                  onPressed: onRow,
                ),
                // The board's footer band. Its time estimate is left out.
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s20,
                    PantasSpace.s16,
                    PantasSpace.s20,
                    PantasSpace.s18,
                  ),
                  decoration: BoxDecoration(
                    color: t.colors.surfaceInset,
                    border: Border(
                      top: BorderSide(
                        color: t.colors.divider,
                        width: webHairline(context),
                      ),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: WebButton(
                      label: 'Start Warm-up',
                      variant: WebButtonVariant.secondary,
                      onPressed: onStart,
                      busy: busy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Board (HP_ExamDay): the title and line sit in a white 18 px card.
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surfaceCard,
            borderRadius: BorderRadius.circular(PantasRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PantasSpace.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$examShortName is today.',
                  style: PantasType.phoneTitle3.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: PantasSpace.s10),
                Text(
                  detail,
                  style: context.type.subhead.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasWarmUp) ...[
          const SizedBox(height: PantasSpace.s16),
          HomeTodayHeader(onPlan: onPlan),
          GroupedSection(
            children: [
              TodayQuestionRow(
                title: 'Warm-up reviews',
                subtitle: 'Optional',
                done: reviewsDone,
                total: reviewsTotal,
                onTap: onRow,
                divider: false,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s14,
                  PantasSpace.s16,
                  PantasSpace.s16,
                ),
                child: PantasButton(
                  label: 'Start Warm-up',
                  busy: busy,
                  onPressed: onStart,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// The wide board's exam day title: the Pantas mark, a 26 px title and a
/// 17 px line, above both columns.
class HomeExamDayIntro extends StatelessWidget {
  const HomeExamDayIntro({
    required this.examShortName,
    required this.reviewsTotal,
    super.key,
  });
  final String examShortName;
  final int reviewsTotal;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s4,
        PantasSpace.s4,
        PantasSpace.s4,
        PantasSpace.s0,
      ),
      child: Row(
        children: [
          const PantasLogo(size: 56),
          const SizedBox(width: PantasSpace.s24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$examShortName is today.', style: t.h2),
                const SizedBox(height: PantasSpace.s4),
                Text(
                  _examDayDetail(reviewsTotal),
                  style: PantasType.webLead
                      .copyWith(height: 1.45, color: t.colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _examDayDetail(int reviewsTotal) => reviewsTotal > 0
    ? 'Nothing new today. If you want a warm-up, $reviewsTotal easy '
        '${reviewsTotal == 1 ? "review is" : "reviews are"} here.'
    : 'Nothing new today.';
