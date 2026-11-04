import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/presentation/plan_web.dart';

class PlanDayPage extends StatelessWidget {
  const PlanDayPage({
    required this.date,
    required this.past,
    required this.rest,
    required this.lessons,
    required this.reviewsDone,
    required this.reviewsTotal,
    required this.newDone,
    required this.newTotal,
    required this.onBack,
    required this.onLesson,
    this.backLabel = 'Your plan',
    super.key,
  });
  final DateTime date;
  final bool past;
  final bool rest;
  final List<HomeTodayLesson> lessons;
  final int reviewsDone;
  final int reviewsTotal;
  final int newDone;
  final int newTotal;
  final VoidCallback onBack;
  final ValueChanged<HomeTodayLesson> onLesson;
  final String backLabel;
  @override
  Widget build(BuildContext context) => context.wideWeb
      ? _wide(context)
      : PantasPage(
          title: DateFormat('EEEE, MMM d', 'en_US').format(date),
          backLabel: backLabel,
          onBack: onBack,
          bottomInset: 104,
          children: [
            GroupedSection(
              header: 'Planned',
              children: [
                if (rest)
                  ListRow(
                    title: 'Rest day',
                    icon: PantasIcons.restDay,
                    iconColor: context.colors.secondaryLabel,
                    variant: ListRowVariant.value,
                  )
                else ...[
                  for (final lesson in lessons)
                    ListRow(
                      title: lesson.title,
                      subtitle: lesson.subject,
                      value: lesson.read ? 'Read' : null,
                      leading: lesson.read
                          ? const CheckMark()
                          : ProgressRing(
                              fraction: 0,
                              emptyStrokeWidth: 2,
                              emptyTrackColor:
                                  ProgressRing.phoneEmptyTrack(context),
                            ),
                      titleColor:
                          lesson.read ? context.colors.secondaryLabel : null,
                      onTap: () => onLesson(lesson),
                      divider: true,
                      naturalValue: true,
                      dividerInset: 52,
                      contentPadding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
                      subtitleGap: 2,
                      valueStyle: context.type.subhead
                          .copyWith(color: context.colors.secondaryLabel),
                    ),
                  if (!past || reviewsTotal > 0)
                    ListRow(
                      title: 'Reviews',
                      subtitle:
                          past ? 'Questions due that day' : 'Set that morning',
                      value: past ? '$reviewsDone of $reviewsTotal' : null,
                      leading: past && reviewsDone == reviewsTotal
                          ? const CheckMark()
                          : ProgressRing(
                              fraction: past && reviewsTotal > 0
                                  ? reviewsDone / reviewsTotal
                                  : 0,
                              emptyStrokeWidth: 2,
                              emptyTrackColor:
                                  ProgressRing.phoneEmptyTrack(context),
                            ),
                      titleColor: past && reviewsDone == reviewsTotal
                          ? context.colors.secondaryLabel
                          : null,
                      variant: ListRowVariant.value,
                      divider: true,
                      naturalValue: true,
                      dividerInset: 52,
                      contentPadding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
                      subtitleGap: 2,
                      valueStyle: context.type.subhead
                          .copyWith(color: context.colors.secondaryLabel),
                    ),
                  if (!past || newTotal > 0)
                    ListRow(
                      title: 'New questions',
                      subtitle: past
                          ? "From that day's lessons"
                          : "From this day's lessons",
                      value: past ? '$newDone of $newTotal' : null,
                      leading: past && newDone == newTotal
                          ? const CheckMark()
                          : ProgressRing(
                              fraction:
                                  past && newTotal > 0 ? newDone / newTotal : 0,
                              emptyStrokeWidth: 2,
                              emptyTrackColor:
                                  ProgressRing.phoneEmptyTrack(context),
                            ),
                      titleColor: past && newDone == newTotal
                          ? context.colors.secondaryLabel
                          : null,
                      variant: ListRowVariant.value,
                      naturalValue: true,
                      dividerInset: 52,
                      contentPadding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
                      subtitleGap: 2,
                      valueStyle: context.type.subhead
                          .copyWith(color: context.colors.secondaryLabel),
                    ),
                ],
              ],
            ),
            if (!past && !rest)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
                child: Text(
                  'Reviews and new questions are counted that morning.',
                  style: context.type.footnote,
                ),
              ),
          ],
        );
  Widget _wide(BuildContext context) {
    final t = context.webTokens;
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): onBack},
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!past)
              PlanPaneHeader(
                label: backLabel,
                onClose: onBack,
                onLabel: onBack,
              ),
            WebCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('EEEE, MMM d', 'en_US').format(date),
                            style: t.h3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: t.disabledBackground,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            'PLANNED',
                            style: t.sm.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (rest)
                    const WebRow(
                      boardMetrics: true,
                      title: 'Rest day',
                      divider: false,
                    )
                  else ...[
                    for (final lesson in lessons)
                      WebRow(
                        boardMetrics: true,
                        title: lesson.title,
                        subtitle: lesson.subject,
                        titleColor:
                            lesson.read ? t.colors.secondaryLabel : null,
                        leading: lesson.read
                            ? Icon(
                                Icons.check_circle,
                                color: t.colors.accent,
                                size: 26,
                              )
                            : ProgressRing(
                                fraction: 0,
                                size: 26,
                                emptyTrackColor:
                                    t.dark ? null : const Color(0xFFD1D1D6),
                              ),
                        value: lesson.read ? 'Read' : null,
                        trailing: !past && !lesson.read
                            ? WebTextAction(
                                label: 'Read',
                                height: 34,
                                onPressed: () => onLesson(lesson),
                              )
                            : null,
                      ),
                    if (!past || reviewsTotal > 0)
                      WebRow(
                        boardMetrics: true,
                        title: 'Reviews',
                        leading: ProgressRing(
                          fraction: past && reviewsTotal > 0
                              ? reviewsDone / reviewsTotal
                              : 0,
                          size: 26,
                          emptyTrackColor:
                              t.dark ? null : const Color(0xFFD1D1D6),
                        ),
                        subtitle: past
                            ? 'Questions due that day'
                            : 'Set that morning',
                        value: past ? '$reviewsDone of $reviewsTotal' : null,
                      ),
                    if (!past || newTotal > 0)
                      WebRow(
                        boardMetrics: true,
                        title: 'New questions',
                        leading: ProgressRing(
                          fraction:
                              past && newTotal > 0 ? newDone / newTotal : 0,
                          size: 26,
                          emptyTrackColor:
                              t.dark ? null : const Color(0xFFD1D1D6),
                        ),
                        subtitle: past
                            ? "From that day's lessons"
                            : "From this day's lessons",
                        value: past ? '$newDone of $newTotal' : null,
                        divider: false,
                      ),
                  ],
                ],
              ),
            ),
            if (!past && !rest)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'Reviews and new questions are counted that morning. '
                  'You can read a lesson early; it counts toward its day.',
                  style: t.sm,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PlanWeekDay {
  const PlanWeekDay({
    required this.date,
    required this.rest,
    required this.lessonTitles,
    this.mock = false,
  });
  final DateTime date;
  final bool rest;
  final List<String> lessonTitles;
  final bool mock;

  /// What the row says. After new material stops a day has no lessons, only
  /// reviews, and the mock day is named, so no row is ever blank.
  String get label => rest
      ? 'Rest day'
      : lessonTitles.isNotEmpty
          ? lessonTitles.join(', ')
          : mock
              ? 'Mock exam'
              : 'Reviews only';
}

class PlanWeekPage extends StatelessWidget {
  const PlanWeekPage({
    required this.title,
    required this.days,
    required this.studyDaysLabel,
    required this.onBack,
    required this.onDay,
    this.onChange,
    super.key,
  });
  final String title;
  final List<PlanWeekDay> days;
  final String studyDaysLabel;
  final VoidCallback onBack;
  final ValueChanged<DateTime> onDay;
  final VoidCallback? onChange;
  @override
  Widget build(BuildContext context) => context.wideWeb
      ? _wide(context)
      : PantasPage(
          title: title,
          backLabel: 'Your plan',
          onBack: onBack,
          bottomInset: 104,
          children: [
            GroupedSection(
              header: 'Lessons by day',
              children: [
                for (var i = 0; i < days.length; i++)
                  ListRow(
                    title: days[i].label,
                    // Board (DP_Week): 15 px names and titles, the title
                    // column starts at 108, rest days are gray with a small
                    // moon before the words and no chevron.
                    titleWidget: Row(
                      children: [
                        if (days[i].rest) ...[
                          Icon(
                            PantasIcons.restDay,
                            size: 13,
                            color: context.colors.tertiaryLabel,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            days[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.subhead.copyWith(
                              color: days[i].rest
                                  ? context.colors.secondaryLabel
                                  : context.colors.label,
                            ),
                          ),
                        ),
                      ],
                    ),
                    verticalPadding: 12.25,
                    leading: SizedBox(
                      width: 64,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEE', 'en_US').format(days[i].date),
                            style: context.type.subheadStrong.copyWith(
                              color: days[i].rest
                                  ? context.colors.secondaryLabel
                                  : context.colors.label,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d', 'en_US').format(days[i].date),
                            style: context.type.footnote,
                          ),
                        ],
                      ),
                    ),
                    hideTrailing: days[i].rest,
                    divider: i < days.length - 1,
                    onTap: days[i].rest ? null : () => onDay(days[i].date),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(studyDaysLabel, style: context.type.footnote),
                  if (onChange != null)
                    TextButton(
                      onPressed: onChange,
                      child: const Text('Change'),
                    ),
                ],
              ),
            ),
          ],
        );
  Widget _wide(BuildContext context) {
    final t = context.webTokens;
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): onBack},
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlanPaneHeader(
              label: '$title · Lessons by day',
              onClose: onBack,
            ),
            WebCard(
              child: Column(
                children: [
                  for (var i = 0; i < days.length; i++)
                    WebRow(
                      boardMetrics: true,
                      title: days[i].label,
                      dimmed: days[i].rest,
                      divider: i < days.length - 1,
                      leading: SizedBox(
                        width: 34,
                        child: Column(
                          children: [
                            Text(
                              DateFormat('EEE', 'en_US').format(days[i].date),
                              style: t.sm.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                height: 14 / 11,
                              ),
                            ),
                            Text(
                              '${days[i].date.day}',
                              style: t.style(
                                17,
                                weight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: days[i].rest ? null : const WebChevron(),
                      onPressed:
                          days[i].rest ? null : () => onDay(days[i].date),
                    ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                    decoration: BoxDecoration(
                      color: t.dark ? null : const Color(0xFFFBFBFC),
                      border: Border(
                        top: BorderSide(
                          color: t.colors.separator,
                          width: webHairline(context),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(studyDaysLabel, style: t.sub)),
                        if (onChange != null)
                          WebTextAction(label: 'Change', onPressed: onChange!),
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
}
