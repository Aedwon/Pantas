import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
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
      titlePadding: const EdgeInsets.fromLTRB(
        PantasSpace.s4,
        PantasSpace.s0,
        PantasSpace.s4,
        PantasSpace.s2,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s4,
            PantasSpace.s0,
            PantasSpace.s4,
            PantasSpace.s20,
          ),
          child: Text(
            detail.subject,
            style: context.type.subhead
                .copyWith(color: context.colors.textSecondary),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surfaceCard,
            borderRadius: BorderRadius.circular(PantasRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PantasSpace.s16,
              vertical: PantasSpace.s16,
            ),
            // Board (DT_Topic): the three figures sit side by side, 114 px
            // apart.
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (answered > 0)
                  SizedBox(
                    width: PantasSpace.s56 * 2,
                    child: _Stat(
                      value: '${(detail.correct / answered * 100).round()}%',
                      label: 'accuracy',
                    ),
                  ),
                SizedBox(
                  width: PantasSpace.s56 * 2,
                  child: _Stat(value: '$answered', label: 'answered'),
                ),
                Expanded(
                  child: _Stat(
                    value: '${detail.lessonsRead} of ${detail.lessons.length}',
                    label: 'lessons read',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PantasSpace.s24),
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
                dividerInset: 52,
                verticalPadding: 13,
              ),
          ],
        ),
        const SizedBox(height: PantasSpace.s24),
        PantasButton(label: 'Practice This Topic', onPressed: onPractice),
        const SizedBox(height: PantasSpace.s8),
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
            padding: const EdgeInsets.symmetric(
              horizontal: PantasSpace.s16,
              vertical: PantasSpace.s14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: PantasType.webH2.copyWith(color: t.colors.textPrimary),
                ),
                Text(label, style: t.sm),
              ],
            ),
          ),
        );
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): onBack},
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: Material(
          key: const ValueKey('web-performance-topic'),
          color: t.colors.bgPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: PantasSpace.s56 + PantasSpace.s8,
                child: WebTopBar(
                  leading: const SizedBox.shrink(),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const WebKeyHint('Esc'),
                      PantasIconButton(
                        tooltip: 'Close topic',
                        onPressed: onBack,
                        glyph: PantasIcons.close,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s28,
                  PantasSpace.s0,
                  PantasSpace.s28,
                  PantasSpace.s24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.subject.toUpperCase(), style: t.eb),
                    const SizedBox(height: PantasSpace.s4),
                    Text(detail.name, style: t.h2),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: PantasSpace.s28),
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
                            const SizedBox(width: PantasSpace.s10),
                          ],
                          stat('${detail.answered}', 'answered'),
                          const SizedBox(width: PantasSpace.s10),
                          stat(
                            '${detail.lessonsRead} of ${detail.lessons.length}',
                            'lessons read',
                          ),
                        ],
                      ),
                      const SizedBox(height: PantasSpace.s24),
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
                                titleStyle: PantasType.webLead.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: lesson.read
                                      ? t.colors.textSecondary
                                      : t.colors.textPrimary,
                                ),
                                titleSuffix: lesson.today
                                    ? const _TodayTag(web: true)
                                    : null,
                                trailing: Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: t.colors.textSecondary,
                                ),
                                divider: lesson != detail.lessons.last,
                                onPressed: () => onLesson(lesson.id),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: PantasSpace.s24),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s28,
                  PantasSpace.s18,
                  PantasSpace.s28,
                  PantasSpace.s24,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: t.colors.divider,
                      width: .5,
                    ),
                  ),
                ),
                // P2 (Nov 7): the note at the left, the button at the right
                // end, as the Today card's footer does. When both do not fit
                // (large text), the button goes under the note, still right.
                child: OverflowBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  spacing: 16,
                  overflowSpacing: 12,
                  overflowAlignment: OverflowBarAlignment.end,
                  children: [
                    SizedBox(
                      width: PantasSpace.s56 * 3 + PantasSpace.s32,
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
            style: PantasType.phoneTitle2.copyWith(
              color: context.colors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: PantasSpace.s2),
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
                        : context.colors.textPrimary
                    : null,
                border: read
                    ? null
                    : Border.all(color: context.colors.iconChevron, width: 1.6),
              ),
              child: read
                  ? Icon(
                      PantasIcons.check,
                      size: 14,
                      color: context.colors.surfaceCard,
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
        padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              web ? context.webTokens.colors.accentTint : context.colors.fill,
          borderRadius: BorderRadius.circular(PantasRadius.full),
        ),
        child: Text(
          'Today',
          style: context.type.caption.copyWith(
            color: web ? context.webTokens.tintText : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
