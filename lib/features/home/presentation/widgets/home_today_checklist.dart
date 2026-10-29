import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
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
    this.web = kIsWeb,
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
  final bool web;
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
    if (isWideWebLayout(width: MediaQuery.sizeOf(context).width, web: web)) {
      return _wide(context);
    }
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

  Widget _wide(BuildContext context) {
    final t = context.webTokens;
    final advanced = lessons.any((l) => l.advanced);
    final visible =
        advanced ? lessons.where((l) => l.advanced).toList() : lessons;
    final next = visible.firstWhereOrNull((l) => !l.read);
    final collapsed = visible.length >= 4;
    final done = visible.where((l) => l.read).length;
    final start = isMockDay
        ? onMock
        : next != null
            ? () => onLesson(next)
            : reviewsDone < reviewsTotal
                ? onReviews
                : newDone < newTotal
                    ? onNew
                    : null;
    final label = isMockDay
        ? 'Start Mock Exam'
        : next != null
            ? (next.fraction ?? 0) > 0
                ? 'Resume Lesson'
                : 'Continue Lesson'
            : reviewsDone < reviewsTotal
                ? 'Start Reviews'
                : 'Start New Questions';
    Widget lesson(HomeTodayLesson l, {bool upNext = false}) => Tooltip(
          message: l.title,
          child: WebRow(
            title: l.title,
            subtitle: l.subject,
            titleColor: l.read ? t.colors.secondaryLabel : null,
            titleSuffix: !upNext
                ? null
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: t.colors.accentTint,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Up next',
                      style: t.style(
                        12,
                        weight: FontWeight.w600,
                        color: t.tintText,
                      ),
                    ),
                  ),
            value: l.read
                ? 'Read'
                : (l.fraction ?? 0) > 0
                    ? 'Resume'
                    : '${l.minutes} min',
            leading: l.read
                ? const CheckMark()
                : ProgressRing(fraction: l.fraction ?? 0, size: 26),
            onPressed: () => onLesson(l),
          ),
        );
    Widget questions(
      String title,
      String subtitle,
      int done,
      int total,
      VoidCallback open,
    ) =>
        WebRow(
          title: title,
          subtitle: subtitle,
          value: '$done of $total',
          leading: done == total
              ? const CheckMark()
              : ProgressRing(fraction: done / total, size: 26),
          onPressed: open,
        );
    return CallbackShortcuts(
      bindings: {
        if (start != null && !advancing)
          const SingleActivator(LogicalKeyboardKey.enter): start,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
              child: Row(
                children: [
                  Expanded(child: Text('TODAY', style: t.eb)),
                  if (onPlan != null)
                    WebTextLink(label: 'View full plan', onPressed: onPlan!),
                ],
              ),
            ),
            WebCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (advanced) ...[
                    WebRow(
                      title: "Today's done",
                      subtitle: originalSummary,
                      leading: const CheckMark(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                      child: Text('FROM TOMORROW', style: t.eb),
                    ),
                  ],
                  if (isMockDay)
                    WebRow(
                      title: 'Mock exam',
                      subtitle: mockSubtitle,
                      value: mockDuration,
                      leading: const ProgressRing(fraction: 0, size: 26),
                      onPressed: onMock,
                    ),
                  if (collapsed) ...[
                    if (next != null) lesson(next, upNext: true),
                    WebRow(
                      title: 'Lessons',
                      subtitle: '${visible.length} today',
                      value: '$done of ${visible.length} read',
                      leading: ProgressRing(
                        fraction: done / visible.length,
                        size: 26,
                      ),
                      onPressed: onLessons,
                    ),
                  ] else
                    for (final l in visible) lesson(l),
                  if (reviewsTotal > 0)
                    questions(
                      'Reviews',
                      reviewSubtitle,
                      reviewsDone,
                      reviewsTotal,
                      onReviews,
                    ),
                  if (newTotal > 0)
                    questions(
                      'New questions',
                      advanced && visible.length == 1
                          ? 'From ${visible.single.title}'
                          : "From today's lessons",
                      newDone,
                      newTotal,
                      onNew,
                    ),
                  if (start != null)
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                      decoration: BoxDecoration(
                        color:
                            t.dark ? t.colors.surface : const Color(0xFFFBFBFC),
                        border: Border(
                          top: BorderSide(
                            color: t.colors.separator,
                            width: .5,
                          ),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: WebButton(
                          label: label,
                          keyHint: 'Enter',
                          onPressed: start,
                          busy: advancing,
                        ),
                      ),
                    ),
                  if (canAdvance || doneNote != null)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("That's all for today.", style: t.h3),
                          const SizedBox(height: 6),
                          if (canAdvance) ...[
                            Text(
                              advanced
                                  ? "Want to keep going? The next day's lesson "
                                      'and its new questions move to today. '
                                      'Stop whenever you like.'
                                  : "Want to keep going? Tomorrow's lesson "
                                      'and its new questions move to today. '
                                      'Stop whenever you like.',
                              style: t.sub,
                            ),
                            const SizedBox(height: 14),
                            WebButton(
                              label: 'I Want to Advance',
                              variant: WebButtonVariant.secondary,
                              onPressed: onAdvance,
                              busy: advancing,
                            ),
                          ] else if (_doneDetail != null)
                            Text(_doneDetail!, style: t.sub),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
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
  const HomeTodayHeader({this.onPlan, this.web = kIsWeb, super.key});
  final bool web;
  final VoidCallback? onPlan;

  @override
  Widget build(BuildContext context) =>
      isWideWebLayout(width: MediaQuery.sizeOf(context).width, web: web)
          ? Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
              child: Row(
                children: [
                  Expanded(child: Text('TODAY', style: context.webTokens.eb)),
                  if (onPlan != null)
                    WebTextLink(label: 'View full plan', onPressed: onPlan!),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 8,
                bottom: onPlan == null ? 7 : 0,
              ),
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
                    ),
                ],
              ),
            );
}
