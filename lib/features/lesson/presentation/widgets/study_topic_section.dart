import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';

class StudySubjectSection extends ConsumerWidget {
  const StudySubjectSection({
    required this.subject,
    required this.onToggleTopic,
    this.keyForTopic,
    this.ringDelay = Duration.zero,
    super.key,
  });
  final StudySubject subject;
  final void Function(TopicId) onToggleTopic;
  final GlobalKey Function(TopicId)? keyForTopic;
  final Duration ringDelay;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(openTopicProvider).valueOrNull;
    final today =
        ref.watch(studyTodayLessonIdsProvider).valueOrNull ?? const <String>{};
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GroupedSection(
        header: subject.name,
        children: [
          for (final topic in subject.topics) ...[
            Semantics(
              expanded: open == topic.id,
              child: ListRow(
                key: keyForTopic?.call(topic.id),
                title: topic.name,
                wrapTitle: true,
                titleColor:
                    topic.isComplete ? context.colors.secondaryLabel : null,
                leading: topic.isComplete
                    ? const CheckMark()
                    : ProgressRing.study(
                        fraction: topic.totalCount == 0
                            ? 0
                            : topic.readCount / topic.totalCount,
                        delay: ringDelay,
                      ),
                verticalPadding: 12,
                trailingWidget: AnimatedRotation(
                  turns: open == topic.id ? .25 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: PantasCurves.houseOut,
                  child: Icon(
                    PantasIcons.next,
                    size: 14,
                    color: context.colors.chevron,
                  ),
                ),
                onTap: () => onToggleTopic(topic.id),
              ),
            ),
            _TopicLessons(topic: topic, open: open == topic.id, today: today),
          ],
        ],
      ),
    );
  }
}

class _TopicLessons extends StatefulWidget {
  const _TopicLessons({
    required this.topic,
    required this.open,
    required this.today,
  });
  final StudyTopic topic;
  final bool open;
  final Set<String> today;
  @override
  State<_TopicLessons> createState() => _TopicLessonsState();
}

class _TopicLessonsState extends State<_TopicLessons> {
  bool _hasOpened = false;
  final _contentKey = GlobalKey();
  double _naturalHeight = 0;
  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final open = widget.open;
    final today = widget.today;
    _hasOpened = _hasOpened || open;
    if (!_hasOpened) return const SizedBox.shrink();
    final scale = MediaQuery.textScalerOf(context);
    // CSS max-height is a reveal cap, not a permanent limit on long topics.
    final fullHeight = topic.lessons.fold<double>(
      0,
      (sum, lesson) =>
          sum +
          24 +
          math.max(
            24,
            scale.scale(17) * 1.35 +
                (scale.scale(17) > 25.5 &&
                        (!lesson.isRead || today.contains(lesson.id))
                    ? math.max(
                        scale.scale(15) * 1.35,
                        scale.scale(12) * 1.35 + 6,
                      )
                    : 0),
          ),
    );
    final cap = math.max<double>(800, math.max(fullHeight, _naturalHeight));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final content =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (mounted && content != null && content.size.height > cap + .5) {
        setState(() => _naturalHeight = content.size.height);
      }
    });
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: open ? cap : 0),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 700),
      curve: PantasCurves.houseOut,
      builder: (context, value, child) => Offstage(
        offstage: value == 0,
        child: ClipRect(
          child: ExcludeFocus(
            excluding: value < cap,
            child: ExcludeSemantics(
              excluding: !open || value < cap,
              child: ConstrainedBox(
                key: ValueKey('topic-reveal-${topic.id}'),
                constraints: BoxConstraints(maxHeight: value),
                child: child,
              ),
            ),
          ),
        ),
      ),
      child: ColoredBox(
        color: context.colors.pickerBackground,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            key: _contentKey,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final lesson in topic.lessons)
                StudyLessonRow(
                  lesson: lesson,
                  isToday: today.contains(lesson.id),
                  onTap: () => context.push('/lesson/${lesson.id}?from=study'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudyLessonRow extends StatelessWidget {
  const StudyLessonRow({
    required this.lesson,
    required this.onTap,
    this.isToday = false,
    super.key,
  });
  final StudyLesson lesson;
  final VoidCallback onTap;
  final bool isToday;
  @override
  Widget build(BuildContext context) => ListRow(
        title: lesson.title,
        wrapTitle: true,
        titleColor: lesson.isRead ? context.colors.secondaryLabel : null,
        leading: SizedBox.square(
          dimension: 24,
          child: lesson.isRead
              ? Icon(PantasIcons.check, size: 18, color: context.colors.accent)
              : null,
        ),
        verticalPadding: 12,
        valueWidget: !lesson.isRead || isToday
            ? Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (isToday)
                    Container(
                      key: const ValueKey('study-today-tag'),
                      constraints: const BoxConstraints(minHeight: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: context.colors.fill,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Today',
                            style: context.type.captionStrong.copyWith(
                              fontSize: 12,
                              height: 1.35,
                              color: context.colors.onFillLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!lesson.isRead)
                    Text(
                      '${lesson.estimatedMinutes} min',
                      style: context.type.subhead.copyWith(
                        color: context.colors.secondaryLabel,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              )
            : null,
        trailingWidget:
            Icon(PantasIcons.next, size: 14, color: context.colors.chevron),
        onTap: onTap,
      );
}
