import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
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
              padding:
                  EdgeInsets.only(top: topic ? PantasSpace.s0 : PantasSpace.s6),
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
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s20,
        PantasSpace.s8,
        PantasSpace.s20,
        PantasSpace.s32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The grabber is the PantasSheet's own; the list draws none.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s0,
              PantasSpace.s8,
              PantasSpace.s0,
              PantasSpace.s4,
            ),
            child: Text(
              title,
              style:
                  PantasType.phoneTitle3.copyWith(color: context.colors.label),
            ),
          ),
          const SizedBox(height: PantasSpace.s6),
          // The list takes the height the sheet has left and scrolls inside
          // it; the sheet itself does not scroll (`scrollable: false`), so
          // there is one scroll view and a drag always moves the list.
          if (topic)
            Flexible(
              child: Stack(
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
                              context.colors.surfaceModal.withValues(alpha: 0),
                              context.colors.surfaceModal,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(child: SingleChildScrollView(child: rows)),
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
      naturalValue: true,
      minimumHeight: 0,
      contentPadding: const EdgeInsets.symmetric(vertical: PantasSpace.s10),
      wrapTitle: MediaQuery.textScalerOf(context).scale(16) > 24,
      richTitle: TextSpan(
        text: lesson.title,
        style: PantasType.phoneCallout.copyWith(
          color:
              lesson.isRead && !current ? colors.secondaryLabel : colors.label,
        ),
      ),
      subtitle: item.topicName,
      leading: SizedBox(
        width: PantasSpace.s24,
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
              padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s8),
              decoration: BoxDecoration(
                color: colors.accentTint,
                borderRadius: BorderRadius.circular(PantasRadius.full),
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  'Reading',
                  style: PantasType.webTag.copyWith(color: colors.accent),
                ),
              ),
            )
          : lesson.isRead
              ? null
              : Text(
                  '${lesson.estimatedMinutes} min',
                  style: PantasType.webRowSub
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.secondaryLabel,
                      )
                      .tabular,
                ),
      onTap: () => onSelectLesson(lesson.id),
    );
  }
}
