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
                          : const ProgressRing(fraction: 0),
                      onTap: () => onLesson(lesson),
                      divider: true,
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
                            ),
                      variant: ListRowVariant.value,
                      divider: true,
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
                            ),
                      variant: ListRowVariant.value,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!past)
              Row(
                children: [
                  Expanded(child: Text(backLabel.toUpperCase(), style: t.eb)),
                  const WebKeyHint('Esc'),
                  IconButton(
                    onPressed: onBack,
                    tooltip: 'Close',
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
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
                    const WebRow(title: 'Rest day', divider: false)
                  else ...[
                    for (final lesson in lessons)
                      WebRow(
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
                            : const ProgressRing(fraction: 0, size: 26),
                        value: lesson.read ? 'Read' : null,
                        trailing: !past && !lesson.read
                            ? TextButton(
                                onPressed: () => onLesson(lesson),
                                child: const Text('Read'),
                              )
                            : null,
                      ),
                    if (!past || reviewsTotal > 0)
                      WebRow(
                        title: 'Reviews',
                        leading: ProgressRing(
                          fraction: past && reviewsTotal > 0
                              ? reviewsDone / reviewsTotal
                              : 0,
                          size: 26,
                        ),
                        subtitle: past
                            ? 'Questions due that day'
                            : 'Set that morning',
                        value: past ? '$reviewsDone of $reviewsTotal' : null,
                      ),
                    if (!past || newTotal > 0)
                      WebRow(
                        title: 'New questions',
                        leading: ProgressRing(
                          fraction:
                              past && newTotal > 0 ? newDone / newTotal : 0,
                          size: 26,
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
  });
  final DateTime date;
  final bool rest;
  final List<String> lessonTitles;
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
                    title: days[i].rest
                        ? 'Rest day'
                        : days[i].lessonTitles.join(', '),
                    leading: SizedBox(
                      width: 56,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEE', 'en_US').format(days[i].date),
                            style: context.type.emphasized,
                          ),
                          Text(
                            DateFormat('MMM d', 'en_US').format(days[i].date),
                            style: context.type.footnote,
                          ),
                        ],
                      ),
                    ),
                    titleColor:
                        days[i].rest ? context.colors.secondaryLabel : null,
                    trailingWidget: days[i].rest
                        ? Icon(
                            PantasIcons.restDay,
                            color: context.colors.secondaryLabel,
                          )
                        : null,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$title · Lessons by day'.toUpperCase(),
                    style: t.eb,
                  ),
                ),
                const WebKeyHint('Esc'),
                IconButton(
                  onPressed: onBack,
                  tooltip: 'Close',
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            WebCard(
              child: Column(
                children: [
                  for (var i = 0; i < days.length; i++)
                    WebRow(
                      wrapTitle: true,
                      title: days[i].rest
                          ? 'Rest day'
                          : days[i].lessonTitles.join(', '),
                      dimmed: days[i].rest,
                      divider: i < days.length - 1,
                      leading: SizedBox(
                        width: 34,
                        child: Column(
                          children: [
                            Text(
                              DateFormat('EEE', 'en_US').format(days[i].date),
                              style: t.sm.copyWith(fontSize: 11),
                            ),
                            Text(
                              '${days[i].date.day}',
                              style: t.style(17, weight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      trailing: days[i].rest
                          ? null
                          : Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: t.colors.chevron,
                            ),
                      onPressed:
                          days[i].rest ? null : () => onDay(days[i].date),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                    child: Row(
                      children: [
                        Expanded(child: Text(studyDaysLabel, style: t.sub)),
                        if (onChange != null)
                          TextButton(
                            onPressed: onChange,
                            child: const Text('Change'),
                          ),
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
