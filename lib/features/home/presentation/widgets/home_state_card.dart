import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum HomeState {
  assessment,
  noContent,
  nothingDue,
  reviewOnly,
  dayOff,
  finishedReviewWeek,
  lastDay,
  passed
}

class HomeStateCard extends StatelessWidget {
  const HomeStateCard({
    required this.state,
    required this.examName,
    required this.examShortName,
    required this.onPrimary,
    this.onSecondary,
    this.examDateLabel,
    super.key,
  });
  final HomeState state;
  final String examName;
  final String examShortName;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final String? examDateLabel;
  @override
  Widget build(BuildContext context) {
    final title = switch (state) {
      HomeState.assessment => 'First, a short assessment',
      HomeState.noContent => 'Lessons are on the way',
      HomeState.nothingDue || HomeState.reviewOnly => 'Nothing due today',
      HomeState.dayOff => 'Day off',
      HomeState.finishedReviewWeek ||
      HomeState.lastDay =>
        "That's all for today.",
      HomeState.passed => 'Did you take $examShortName?',
    };
    final detail = switch (state) {
      HomeState.assessment => 'We check your strengths and weak spots first, '
          'so your plan is built around you.',
      HomeState.noContent =>
        "$examName lessons and questions aren't in Pantas yet, "
            "so there's no plan. You can switch exams in Settings.",
      HomeState.nothingDue => "You've covered everything in your plan.",
      HomeState.reviewOnly =>
        'These last days before $examShortName are reviews only, '
            'and none are due today.',
      HomeState.dayOff => 'Nothing is planned today, and your streak is safe. '
          "If you feel like it, the next study day's lesson "
          'can move to today.',
      HomeState.finishedReviewWeek =>
        "This last week is reviews only, so there's "
            'nothing new to bring forward.',
      HomeState.lastDay => '$examShortName is tomorrow. Rest well tonight.',
      HomeState.passed => examDateLabel == null
          ? "Tell us what's next."
          : "Your $examShortName date was $examDateLabel. Tell us what's next.",
    };
    final action = switch (state) {
      HomeState.assessment => 'Start Assessment',
      HomeState.noContent => 'Switch Exam',
      HomeState.nothingDue || HomeState.reviewOnly => 'Practice Weakest Topics',
      HomeState.dayOff => 'I Want to Advance',
      HomeState.passed => 'Set a New Date',
      _ => null,
    };
    return GroupedSection(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state == HomeState.dayOff) ...[
                Icon(
                  PantasIcons.restDay,
                  color: context.colors.secondaryLabel,
                  size: 28,
                ),
                const SizedBox(height: 12),
              ],
              Text(title, style: context.type.emphasized),
              const SizedBox(height: 6),
              Text(
                detail,
                style: context.type.subhead.copyWith(
                  color: context.colors.secondaryLabel,
                  height: 1.4,
                ),
              ),
              if (action != null && onPrimary != null) ...[
                const SizedBox(height: 16),
                PantasButton(
                  label: action,
                  onPressed: onPrimary,
                  variant: state == HomeState.assessment
                      ? PantasButtonVariant.primary
                      : PantasButtonVariant.secondary,
                ),
              ],
              if (state == HomeState.passed && onSecondary != null) ...[
                const SizedBox(height: 8),
                PantasButton(
                  label: 'Switch Exams',
                  onPressed: onSecondary,
                  variant: PantasButtonVariant.tertiary,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
