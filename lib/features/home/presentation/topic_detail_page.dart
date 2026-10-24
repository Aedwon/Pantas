import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';

/// DT_Topic: a topic opened from Your performance. Figures are the measured
/// ones; with no answers the accuracy is simply absent.
class TopicDetailPage extends StatelessWidget {
  const TopicDetailPage({
    required this.detail,
    required this.onBack,
    required this.onLesson,
    required this.onPractice,
    super.key,
  });
  final TopicDetail detail;
  final VoidCallback onBack;
  final ValueChanged<String> onLesson;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final answered = detail.answered;
    return PantasPage(
      title: detail.name,
      backLabel: 'Your performance',
      onBack: onBack,
      titlePadding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
          child: Text(
            detail.subject,
            style: context.type.subhead
                .copyWith(color: context.colors.secondaryLabel),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (answered > 0) ...[
                  _Stat(
                    value: '${(detail.correct / answered * 100).round()}%',
                    label: 'accuracy',
                  ),
                  const SizedBox(height: 16),
                ],
                _Stat(value: '$answered', label: 'answered'),
                const SizedBox(height: 16),
                _Stat(
                  value: '${detail.lessonsRead} of ${detail.lessons.length}',
                  label: 'lessons read',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        GroupedSection(
          header: 'Lessons',
          children: [
            for (final lesson in detail.lessons)
              ListRow(
                title: lesson.title,
                leading: _ReadMark(read: lesson.read),
                valueWidget: lesson.today ? const _TodayTag() : null,
                onTap: () => onLesson(lesson.id),
                divider: lesson != detail.lessons.last,
              ),
          ],
        ),
        const SizedBox(height: 24),
        PantasButton(label: 'Practice This Topic', onPressed: onPractice),
        const SizedBox(height: 8),
        Text(
          "Practice is outside your plan. It doesn't change today.",
          textAlign: TextAlign.center,
          style: context.type.footnote,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.type.emphasized.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(label, style: context.type.footnote),
        ],
      );
}

class _ReadMark extends StatelessWidget {
  const _ReadMark({required this.read});
  final bool read;

  @override
  Widget build(BuildContext context) => Semantics(
        label: read ? 'Read' : 'Not read',
        child: ExcludeSemantics(
          child: SizedBox.square(
            dimension: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: read ? context.colors.label : null,
                border: read
                    ? null
                    : Border.all(color: context.colors.chevron, width: 1.6),
              ),
              child: read
                  ? Icon(
                      PantasIcons.check,
                      size: 14,
                      color: context.colors.surface,
                    )
                  : null,
            ),
          ),
        ),
      );
}

class _TodayTag extends StatelessWidget {
  const _TodayTag();

  @override
  Widget build(BuildContext context) => Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.fill,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          'Today',
          style: context.type.footnote.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
