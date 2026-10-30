import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';

class LessonContentsSheet extends ConsumerWidget {
  const LessonContentsSheet({
    required this.reader,
    required this.onSelectLesson,
    this.dayContext,
    super.key,
  });
  final ReaderContext reader;
  final LessonDayContext? dayContext;
  final void Function(String lessonId) onSelectLesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = dayContext;
    if (day == null) {
      return _contents(
        context,
        [
          for (final lesson in reader.topicLessons)
            (lesson: lesson, topicName: null),
        ],
        title: reader.topicName,
        topic: true,
      );
    }
    final value = ref.watch(studyMapProvider);
    return value.when(
      loading: () => const SkeletonGroups(
        groups: 1,
        rows: 5,
        rowHeight: 63,
        header: false,
      ),
      error: (error, _) => errorFor(
        'lessons',
        () => ref.invalidate(studyMapProvider),
        error: error,
      ),
      data: (map) {
        if (map == null) return chooseExamFallback(context);
        final byId = <String, ({StudyLesson lesson, String? topicName})>{
          for (final subject in map.subjects)
            for (final topic in subject.topics)
              for (final lesson in topic.lessons)
                lesson.id: (lesson: lesson, topicName: topic.name),
        };
        return _contents(
          context,
          [
            for (final id in day.lessonIds)
              if (byId[id] case final item?) item,
          ],
          title: PantasDates.relativeDay(day.date),
          topic: false,
        );
      },
    );
  }

  Widget _contents(
    BuildContext context,
    List<({StudyLesson lesson, String? topicName})> items, {
    required String title,
    required bool topic,
  }) {
    final rows = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < items.length; index++)
          if (index > 0)
            Padding(
              padding: EdgeInsets.only(top: topic ? 0 : 6),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: context.colors.separator,
                      width: .5,
                    ),
                  ),
                ),
                child: _row(context, items[index]),
              ),
            )
          else
            _row(context, items[index]),
      ],
    );
    return Padding(
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
                color: context.colors.pendingMark,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
            child: Text(
              title,
              style: context.type.sectionHero
                  .copyWith(fontSize: 20, letterSpacing: -.24),
            ),
          ),
          const SizedBox(height: 6),
          if (topic)
            Stack(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    key: const ValueKey('contents-topic-list'),
                    child: rows,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 56,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      key: const ValueKey('contents-fade'),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            context.colors.surface.withValues(alpha: 0),
                            context.colors.surface,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            rows,
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    ({StudyLesson lesson, String? topicName}) item,
  ) {
    final lesson = item.lesson;
    final current = lesson.id == reader.lesson.id;
    final colors = context.colors;
    return ListRow(
      key: ValueKey('contents-lesson-${lesson.id}'),
      title: lesson.title,
      variant: ListRowVariant.value,
      minimumHeight: 0,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      wrapTitle: MediaQuery.textScalerOf(context).scale(16) > 24,
      richTitle: TextSpan(
        text: lesson.title,
        style: context.type.body.copyWith(
          fontSize: 16,
          letterSpacing: 0,
          color:
              lesson.isRead && !current ? colors.secondaryLabel : colors.label,
        ),
      ),
      subtitle: item.topicName,
      leading: SizedBox(
        width: 24,
        child: lesson.isRead
            ? Semantics(
                label: 'Read',
                child: ExcludeSemantics(
                  child: Icon(
                    PantasIcons.check,
                    size: 18,
                    color: colors.accent,
                  ),
                ),
              )
            : null,
      ),
      valueWidget: current
          ? Container(
              constraints: const BoxConstraints(minHeight: 22),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colors.accentTint,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  'Reading',
                  style:
                      context.type.captionStrong.copyWith(color: colors.accent),
                ),
              ),
            )
          : lesson.isRead
              ? null
              : Text(
                  '${lesson.estimatedMinutes} min',
                  style: context.type.footnote
                      .copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.secondaryLabel,
                      )
                      .tabular,
                ),
      onTap: () => onSelectLesson(lesson.id),
    );
  }
}
