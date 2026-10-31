import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
                        emptyTrackColor:
                            t.dark ? null : const Color(0xFFD1D1D6),
                      ),
                    ),
                  ),
                  onPressed: onRow,
                ),
                // The board's footer band. Its time estimate is left out.
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  decoration: BoxDecoration(
                    color: t.dark ? t.colors.surface : const Color(0xFFFBFBFC),
                    border: Border(
                      top: BorderSide(
                        color: t.colors.separator,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$examShortName is today.',
                style: context.type.emphasized.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: context.type.subhead.copyWith(
                  color: context.colors.secondaryLabel,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (hasWarmUp) ...[
          const SizedBox(height: 22),
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          const PantasLogo(size: 56),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$examShortName is today.', style: t.h2),
                const SizedBox(height: 4),
                Text(
                  _examDayDetail(reviewsTotal),
                  style: t.style(
                    17,
                    height: 1.45,
                    color: t.colors.secondaryLabel,
                  ),
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
