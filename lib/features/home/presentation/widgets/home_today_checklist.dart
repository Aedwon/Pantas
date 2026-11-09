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
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
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
    required this.onStartReviews,
    required this.onStartNew,
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
    this.reviewsStarted = false,
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

  /// The main button's reviews and new-questions steps. They start the
  /// session directly. [onReviews] and [onNew] only open the row's panel.
  final VoidCallback onStartReviews;
  final VoidCallback onStartNew;
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

  /// A reviews session is already stored, so the button says Continue.
  final bool reviewsStarted;

  /// A start or an advance is running. The main button shows its busy state.
  final bool advancing;

  /// The one main button: the mock, then lessons, then reviews, then new
  /// questions. Null when nothing is left to start.
  ({String label, VoidCallback onPressed})? _main(HomeTodayLesson? next) {
    if (isMockDay) return (label: 'Start Mock Exam', onPressed: onMock);
    if (next != null) {
      return (
        label: (next.fraction ?? 0) > 0 ? 'Resume Lesson' : 'Continue Lesson',
        onPressed: () => onLesson(next),
      );
    }
    if (reviewsDone < reviewsTotal) {
      return (
        label: reviewsStarted ? 'Continue Reviews' : 'Start Reviews',
        onPressed: onStartReviews,
      );
    }
    if (newDone < newTotal) {
      return (label: 'Start New Questions', onPressed: onStartNew);
    }
    return null;
  }

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
    final done = visible.where((l) => l.read).length;
    final main = _main(next);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeTodayHeader(onPlan: onPlan),
        // Board (HE_AdvanceAgain): "Today's done" is its own card, then the
        // "From tomorrow" label over the card that holds the advanced rows.
        if (advanced) ...[
          GroupedSection(
            children: [
              ListRow(
                title: "Today's done",
                titleWidget: Text(
                  "Today's done",
                  style: context.type.emphasized,
                ),
                subtitle: originalSummary,
                leading: const CheckMark(),
                variant: ListRowVariant.value,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s20,
              PantasSpace.s16,
              PantasSpace.s8,
            ),
            child: Text('FROM TOMORROW', style: context.type.sectionHeader),
          ),
        ],
        GroupedSection(
          children: [
            if (isMockDay)
              ListRow(
                title: 'Mock exam',
                subtitle: mockSubtitle,
                value: mockDuration,
                valueStyle: context.type.subhead
                    .copyWith(color: context.colors.textSecondary),
                leading: const ProgressRing(fraction: 0),
                onTap: onMock,
                divider: true,
                naturalValue: true,
                dividerInset: 52,
                verticalPadding: 12,
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
                naturalValue: true,
                dividerInset: 52,
                verticalPadding: 12,
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
            if (main != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s14,
                  PantasSpace.s16,
                  PantasSpace.s16,
                ),
                child: PantasButton(
                  label: main.label,
                  busy: advancing,
                  onPressed: main.onPressed,
                ),
              ),
            if (canAdvance)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s4,
                  PantasSpace.s16,
                  PantasSpace.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "That's all for today.",
                      style: context.type.emphasized,
                    ),
                    const SizedBox(height: PantasSpace.s8),
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
                    const SizedBox(height: PantasSpace.s8),
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
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s14,
                  PantasSpace.s16,
                  PantasSpace.s16,
                ),
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
    final main = _main(next);
    final start = main?.onPressed;
    final label = main?.label ?? '';
    final footerCaption = _footerCaption(visible);
    // The board's ring is a 24 px circle in a 26 px box, 2 px empty stroke.
    Widget ring(double fraction) => SizedBox.square(
          dimension: 26,
          child: Center(
            child: fraction > 0
                ? ProgressRing(fraction: fraction, size: 25)
                : ProgressRing(
                    fraction: 0,
                    emptyStrokeWidth: 2,
                    emptyTrackColor: ProgressRing.phoneEmptyTrack(context),
                  ),
          ),
        );
    Widget check() =>
        const SizedBox.square(dimension: 26, child: Center(child: CheckMark()));
    Widget lesson(HomeTodayLesson l, {bool upNext = false}) => WebRow(
          // The full title shows only when the row cuts it (5Q-16).
          tooltipWhenCut: true,
          boardMetrics: true,
          chevron: upNext ? WebRowChevron.none : WebRowChevron.hover,
          title: l.title,
          subtitle: l.subject,
          titleColor: l.read ? t.colors.textSecondary : null,
          titleSuffix: !upNext
              ? null
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PantasSpace.s8,
                    vertical: PantasSpace.s2,
                  ),
                  decoration: BoxDecoration(
                    color: t.colors.accentTint,
                    borderRadius: BorderRadius.circular(PantasRadius.full),
                  ),
                  child: Text(
                    'Up next',
                    style: PantasType.webTag.copyWith(color: t.tintText),
                  ),
                ),
          value: l.read
              ? 'Read'
              : (l.fraction ?? 0) > 0
                  ? 'Resume'
                  : '${l.minutes} min',
          leading: l.read ? check() : ring(l.fraction ?? 0),
          onPressed: () => onLesson(l),
        );
    Widget questions(
      String title,
      String subtitle,
      int done,
      int total,
      VoidCallback open,
    ) =>
        WebRow(
          boardMetrics: true,
          chevron: collapsed ? WebRowChevron.always : WebRowChevron.hover,
          title: title,
          subtitle: subtitle,
          value: '$done of $total',
          leading: done == total ? check() : ring(done / total),
          onPressed: open,
        );
    return CallbackShortcuts(
      bindings: {
        if (start != null && !advancing)
          const SingleActivator(
            LogicalKeyboardKey.enter,
            includeRepeats: false,
          ): start,
      },
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s4,
                PantasSpace.s0,
                PantasSpace.s4,
                PantasSpace.s8,
              ),
              child: Row(
                children: [
                  Expanded(child: Text('TODAY', style: t.eb)),
                  if (onPlan != null)
                    // The board's label row is 19 px tall (link line box).
                    SizedBox(
                      height: PantasSpace.s20,
                      child: Center(
                        child: WebTextLink(
                          label: 'View full plan',
                          onPressed: onPlan,
                          arrow: false,
                        ),
                      ),
                    ),
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
                      padding: const EdgeInsets.fromLTRB(
                        PantasSpace.s20,
                        PantasSpace.s14,
                        PantasSpace.s20,
                        PantasSpace.s4,
                      ),
                      child: Text('FROM TOMORROW', style: t.eb),
                    ),
                  ],
                  if (isMockDay)
                    WebRow(
                      boardMetrics: true,
                      chevron: WebRowChevron.hover,
                      title: 'Mock exam',
                      subtitle: mockSubtitle,
                      value: mockDuration,
                      leading: ring(0),
                      onPressed: onMock,
                    ),
                  if (collapsed) ...[
                    if (next != null) lesson(next, upNext: true),
                    WebRow(
                      boardMetrics: true,
                      chevron: WebRowChevron.always,
                      title: 'Lessons',
                      subtitle: '${visible.length} today',
                      value: '$done of ${visible.length} read',
                      leading: ring(done / visible.length),
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
                      padding: const EdgeInsets.fromLTRB(
                        PantasSpace.s20,
                        PantasSpace.s16,
                        PantasSpace.s20,
                        PantasSpace.s18,
                      ),
                      decoration: BoxDecoration(
                        color: t.colors.surfaceInset,
                        border: Border(
                          top: BorderSide(
                            color: t.colors.divider,
                            width: webHairline(context),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(footerCaption ?? '', style: t.sub),
                          ),
                          const SizedBox(width: PantasSpace.s16),
                          WebButton(
                            label: label,
                            keyHint: 'Enter',
                            onPressed: start,
                            busy: advancing,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (canAdvance || doneNote != null) _wideDone(t),
          ],
        ),
      ),
    );
  }

  /// The closing block under the Today card: a 19 px title and the line, with
  /// the advance button at the right when the day can advance. The board sets
  /// it outside the card, 22 px below it, inset 4 px.
  Widget _wideDone(WebTokens t) {
    final advanced = lessons.any((l) => l.advanced);
    final detail = canAdvance
        ? advanced
            ? "Want to keep going? The next day's lesson "
                'and its new questions move to today. '
                'Stop whenever you like.'
            : "Want to keep going? Tomorrow's lesson "
                'and its new questions move to today. '
                'Stop whenever you like.'
        : _doneDetail;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s4,
        PantasSpace.s24,
        PantasSpace.s4,
        PantasSpace.s0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "That's all for today.",
                  style: PantasType.webH3.copyWith(color: t.colors.textPrimary),
                ),
                if (detail != null) ...[
                  const SizedBox(height: PantasSpace.s4),
                  Text(detail, style: t.sub),
                ],
              ],
            ),
          ),
          if (canAdvance) ...[
            const SizedBox(width: PantasSpace.s20),
            WebButton(
              label: 'I Want to Advance',
              variant: WebButtonVariant.secondary,
              onPressed: onAdvance,
              busy: advancing,
            ),
          ],
        ],
      ),
    );
  }

  /// The board's time estimate is left out: no measured or published
  /// figure gives today's minutes yet (AGENTS "Never invent a figure").
  /// Aedwon decides.
  String? _footerCaption(List<HomeTodayLesson> visible) =>
      isMockDay ? 'The mock comes first today' : null;

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
        // Board (HE_LongTitle): a long title and subject are cut, never
        // wrapped.
        truncateTitle: true,
        subtitleMaxLines: 1,
        value: lesson.read
            ? 'Read'
            : (lesson.fraction ?? 0) > 0
                ? 'Resume'
                : '${lesson.minutes} min',
        valueStyle:
            context.type.subhead.copyWith(color: context.colors.textSecondary),
        titleColor: lesson.read ? context.colors.textSecondary : null,
        leading: lesson.read
            ? const CheckMark()
            : ProgressRing(
                fraction: lesson.fraction ?? 0,
                emptyStrokeWidth: 2,
                emptyTrackColor: ProgressRing.phoneEmptyTrack(context),
              ),
        onTap: () => onLesson(lesson),
        divider: true,
        naturalValue: true,
        dividerInset: 52,
        verticalPadding: 12,
      );
}

/// The TODAY label and, once the plan page exists, its link.
class HomeTodayHeader extends StatelessWidget {
  const HomeTodayHeader({this.onPlan, this.web = kIsWeb, super.key});
  final bool web;
  final VoidCallback? onPlan;

  @override
  Widget build(BuildContext context) => isWideWebLayout(
        width: MediaQuery.sizeOf(context).width,
        web: web,
      )
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s4,
                PantasSpace.s0,
                PantasSpace.s4,
                PantasSpace.s8,
              ),
              child: Row(
                children: [
                  Expanded(child: Text('TODAY', style: context.webTokens.eb)),
                  if (onPlan != null)
                    // The board's label row is 19 px tall, with no arrow.
                    SizedBox(
                      height: PantasSpace.s20,
                      child: Center(
                        child: WebTextLink(
                          label: 'View full plan',
                          onPressed: onPlan,
                          arrow: false,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.only(
                left: PantasSpace.s16,
                right: PantasSpace.s4,
                // Boards: the link line sits 24 px under the card above and
                // 8 px over the Today card.
                top: onPlan == null ? PantasSpace.s0 : PantasSpace.s6,
                bottom: PantasSpace.s8,
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('TODAY', style: context.type.sectionHeader),
                  if (onPlan != null)
                    WebTextLink(
                      label: 'View full plan',
                      onPressed: onPlan,
                      arrow: false,
                    ),
                ],
              ),
            );
}
