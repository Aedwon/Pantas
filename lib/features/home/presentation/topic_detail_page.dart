import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
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
    if (context.wideWeb) return _wide(context);
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

  Widget _wide(BuildContext context) {
    final t = context.webTokens;
    final percent = detail.answered == 0
        ? null
        : (detail.correct / detail.answered * 100).round();
    Widget stat(String value, String label) => Expanded(
          child: WebCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: t.style(26, weight: FontWeight.w700)),
                Text(label, style: t.sm),
              ],
            ),
          ),
        );
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): onBack},
      child: Focus(
        autofocus: true,
        child: Material(
          key: const ValueKey('web-performance-topic'),
          color: t.colors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 64,
                child: WebTopBar(
                  leading: const SizedBox.shrink(),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const WebKeyHint('Esc'),
                      IconButton(
                        tooltip: 'Close topic',
                        onPressed: onBack,
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.subject.toUpperCase(), style: t.eb),
                    const SizedBox(height: 4),
                    Text(detail.name, style: t.h2),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          if (detail.answered > 0) ...[
                            stat(
                              '$percent%',
                              'accuracy',
                            ),
                            const SizedBox(width: 10),
                          ],
                          stat('${detail.answered}', 'answered'),
                          const SizedBox(width: 10),
                          stat(
                            '${detail.lessonsRead} of ${detail.lessons.length}',
                            'lessons read',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const WebText(
                        'Lessons',
                        kind: WebTextKind.eyebrow,
                      ),
                      WebCard(
                        child: Column(
                          children: [
                            for (final lesson in detail.lessons)
                              WebRow(
                                title: lesson.title,
                                leading:
                                    _ReadMark(read: lesson.read, web: true),
                                titleStyle: t.style(
                                  17,
                                  weight: FontWeight.w500,
                                  color: lesson.read
                                      ? t.colors.secondaryLabel
                                      : t.colors.label,
                                ),
                                titleSuffix: lesson.today
                                    ? const _TodayTag(web: true)
                                    : null,
                                trailing: Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: t.colors.tertiaryLabel,
                                ),
                                divider: lesson != detail.lessons.last,
                                onPressed: () => onLesson(lesson.id),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(28, 18, 28, 22),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: t.colors.separator,
                      width: .5,
                    ),
                  ),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        'Practice is outside your plan. '
                        "It doesn't change today.",
                        style: t.sm,
                      ),
                    ),
                    WebButton(
                      label: 'Practice This Topic',
                      onPressed: onPractice,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
  const _ReadMark({required this.read, this.web = false});
  final bool read;
  final bool web;

  @override
  Widget build(BuildContext context) => Semantics(
        label: read ? 'Read' : 'Not read',
        child: ExcludeSemantics(
          child: SizedBox.square(
            dimension: web ? 26 : 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: read
                    ? web
                        ? context.webTokens.colors.accentFill
                        : context.colors.label
                    : null,
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
  const _TodayTag({this.web = false});
  final bool web;

  @override
  Widget build(BuildContext context) => Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              web ? context.webTokens.colors.accentTint : context.colors.fill,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          'Today',
          style: context.type.footnote.copyWith(
            color: web ? context.webTokens.tintText : null,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
