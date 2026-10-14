import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';

Future<void> showLessonContentsSheet(
  BuildContext context, {
  required ReaderContext reader,
  void Function(String lessonId)? onSelectLesson,
}) async {
  final colors = context.colors;
  final maxHeight = MediaQuery.of(context).size.height * 0.74;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: colors.ink.withValues(alpha: 0.34),
    isScrollControlled: true,
    builder: (sheetContext) {
      final sheetColors = sheetContext.colors;
      return Material(
        color: sheetColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: sheetColors.rule),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  reader.topicName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: sheetColors.ink,
                  ),
                ),
              ),
              Divider(height: 1, color: sheetColors.ruleFaint),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: reader.topicLessons.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: sheetColors.ruleFaint),
                  itemBuilder: (context, index) {
                    final item = reader.topicLessons[index];
                    final isCurrent = item.id == reader.lesson.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w400,
                          color: sheetColors.ink,
                        ),
                      ),
                      trailing: isCurrent
                          ? Text(
                              'reading',
                              style: TextStyle(
                                fontSize: 12,
                                color: sheetColors.inkMuted,
                              ),
                            )
                          : (item.isRead
                              ? Text(
                                  '✓',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: sheetColors.board,
                                  ),
                                )
                              : null),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        if (onSelectLesson != null) {
                          onSelectLesson(item.id);
                        } else {
                          context.go('/lesson/${item.id}?from=study');
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

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
      loading: () => loadingFor(value),
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
