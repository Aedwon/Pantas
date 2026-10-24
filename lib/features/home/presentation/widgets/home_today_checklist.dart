import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/domain/home_today_view.dart';

export 'package:pantas/features/home/domain/home_today_lesson.dart';

/// Pure presentation. Counts, permission to advance, and membership come from
/// the stored plan and its completion facts, never from this widget.
class HomeTodayChecklist extends StatelessWidget {
  const HomeTodayChecklist({
    required this.lessons,
    required this.reviewsDone,
    required this.reviewsTotal,
    required this.newDone,
    required this.newTotal,
    required this.canAdvance,
    required this.isMockDay,
    required this.onLesson,
    required this.onLessons,
    required this.onReviews,
    required this.onNew,
    required this.onAdvance,
    required this.onMock,
    this.onPlan,
    this.mockSubtitle,
    this.mockDuration,
    this.doneNote,
    this.examShortName = '',
    this.originalSummary,
    this.reviewSubtitle = 'Questions due today',
    this.advancing = false,
    super.key,
  });
  final List<HomeTodayLesson> lessons;
  final int reviewsDone;
  final int reviewsTotal;
  final int newDone;
  final int newTotal;
  final bool canAdvance;
  final bool isMockDay;
  final ValueChanged<HomeTodayLesson> onLesson;
  final VoidCallback onLessons;
  final VoidCallback onReviews;
  final VoidCallback onNew;
  final VoidCallback? onPlan;
  final VoidCallback onAdvance;
  final VoidCallback onMock;
  final String? mockSubtitle;
  final String? mockDuration;

  /// The closing line when the day is finished and nothing can advance.
  final HomeDoneNote? doneNote;
  final String examShortName;
  final String? originalSummary;
  final String reviewSubtitle;
  final bool advancing;

  @override
  Widget build(BuildContext context) {
    final advanced = lessons.any((l) => l.advanced);
    final visible =
        advanced ? lessons.where((l) => l.advanced).toList() : lessons;
    final next = visible.firstWhereOrNull((l) => !l.read);
    final collapsed = visible.length >= 4;
    final resumed = (next?.fraction ?? 0) > 0;
    final done = visible.where((l) => l.read).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeTodayHeader(onPlan: onPlan),
        GroupedSection(
          children: [
            if (advanced) ...[
              ListRow(
                title: "Today's done",
                subtitle: originalSummary,
                leading: const CheckMark(),
                variant: ListRowVariant.value,
                divider: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('FROM TOMORROW', style: context.type.sectionHeader),
              ),
            ],
            if (isMockDay)
              ListRow(
                title: 'Mock exam',
                subtitle: mockSubtitle,
                value: mockDuration,
                valueStyle: context.type.subhead
                    .copyWith(color: context.colors.secondaryLabel),
                leading: const ProgressRing(fraction: 0),
                onTap: onMock,
                divider: true,
              ),
            if (collapsed) ...[
              if (next != null) lessonRow(context, next, upNext: true),
              ListRow(
                title: 'Lessons',
                subtitle: '${visible.length} today',
                value: '$done of ${visible.length} read',
                leading: ProgressRing(fraction: done / visible.length),
                onTap: onLessons,
                divider: true,
              ),
            ] else
              for (final lesson in visible) lessonRow(context, lesson),
            if (reviewsTotal > 0)
              TodayQuestionRow(
                title: 'Reviews',
                subtitle: reviewSubtitle,
                done: reviewsDone,
                total: reviewsTotal,
                onTap: onReviews,
              ),
            if (newTotal > 0)
              TodayQuestionRow(
                title: 'New questions',
                subtitle: advanced && visible.length == 1
                    ? 'From ${visible.single.title}'
                    : "From today's lessons",
                done: newDone,
                total: newTotal,
                onTap: onNew,
                divider: false,
              ),
            if (isMockDay || next != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: PantasButton(
                  label: isMockDay
                      ? 'Start Mock Exam'
                      : resumed
                          ? 'Resume Lesson'
                          : 'Continue Lesson',
                  onPressed: isMockDay ? onMock : () => onLesson(next!),
                ),
              ),
            if (canAdvance)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "That's all for today.",
                      style: context.type.emphasized,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      advanced
                          ? 'Want to keep going? '
                              "The next day's lesson and its new "
                              'questions move to today. '
                              'Stop whenever you like.'
                          : 'Want to keep going? '
                              "Tomorrow's lesson and its new "
                              'questions move to today. '
                              'Stop whenever you like.',
                      style: context.type.footnote.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    PantasButton(
                      label: 'I Want to Advance',
                      busy: advancing,
                      variant: PantasButtonVariant.secondary,
                      onPressed: onAdvance,
                    ),
                  ],
                ),
              )
            else if (doneNote != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "That's all for today.",
                      style: context.type.emphasized,
                    ),
                    if (_doneDetail != null)
                      Text(
                        _doneDetail!,
                        style: context.type.footnote.copyWith(height: 1.4),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  String? get _doneDetail => switch (doneNote) {
        HomeDoneNote.reviewWeek => 'This last week is reviews only, so '
            "there's nothing new to bring forward.",
        HomeDoneNote.lastDay => '$examShortName is tomorrow. '
            'Rest well tonight.',
        HomeDoneNote.plain || null => null,
      };

  Widget lessonRow(
    BuildContext context,
    HomeTodayLesson lesson, {
    bool upNext = false,
  }) =>
      ListRow(
        title: lesson.title,
        subtitle: upNext ? 'Up next · ${lesson.subject}' : lesson.subject,
        value: lesson.read
            ? 'Read'
            : (lesson.fraction ?? 0) > 0
                ? 'Resume'
                : '${lesson.minutes} min',
        valueStyle:
            context.type.subhead.copyWith(color: context.colors.secondaryLabel),
        titleColor: lesson.read ? context.colors.secondaryLabel : null,
        leading: lesson.read
            ? const CheckMark()
            : ProgressRing(
                fraction: lesson.fraction ?? 0,
                emptyStrokeWidth: 2,
                emptyTrackColor: context.colors.separator,
              ),
        onTap: () => onLesson(lesson),
        divider: true,
      );
}

/// The TODAY label and, once the plan page exists, its link.
class HomeTodayHeader extends StatelessWidget {
  const HomeTodayHeader({this.onPlan, super.key});
  final VoidCallback? onPlan;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('TODAY', style: context.type.sectionHeader),
            if (onPlan != null)
              TextButton(
                onPressed: onPlan,
                child: Text(
                  'View full plan',
                  style: context.type.subhead
                      .copyWith(color: context.colors.accent),
                ),
              )
            else
              const SizedBox(height: 44),
          ],
        ),
      );
}
