import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
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
    final detail = hasWarmUp
        ? 'Nothing new today. If you want a warm-up, $reviewsTotal easy '
            '${reviewsTotal == 1 ? "review is" : "reviews are"} here.'
        : 'Nothing new today.';
    if (isWideWebLayout(width: MediaQuery.sizeOf(context).width, web: web)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$examShortName is today.', style: context.webTokens.h3),
          const SizedBox(height: 4),
          Text(detail, style: context.webTokens.sub),
          if (hasWarmUp) ...[
            const SizedBox(height: 22),
            HomeTodayHeader(onPlan: onPlan, web: web),
            WebCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WebRow(
                    title: 'Warm-up reviews',
                    subtitle: 'Optional',
                    value: '$reviewsDone of $reviewsTotal',
                    onPressed: onRow,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: WebButton(
                        label: 'Start Warm-up',
                        onPressed: onStart,
                        busy: busy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
