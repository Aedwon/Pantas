import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/view_swap.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/presentation/widgets/home_tap_area.dart';
import 'package:pantas/features/home/presentation/widgets/web_performance_layout.dart';

export 'package:pantas/features/home/application/performance/performance_view.dart'
    show PerformanceViewData;

class PerformancePage extends StatefulWidget {
  const PerformancePage({
    required this.data,
    required this.pro,
    required this.paused,
    required this.onTopic,
    required this.onPro,
    required this.onBack,
    this.initialLevel = 0,
    this.initialSort = SortCycleOrder.weakest,
    this.onOrderChanged,
    this.onLesson,
    this.openTopicId,
    super.key,
  });

  /// A topic whose panel is open from the start (wide web, opened by address).
  final String? openTopicId;
  final PerformanceViewData data;
  final bool pro;
  final bool paused;

  /// Opens a topic. On wide web the future it returns ends when the panel
  /// closes, so the topic's row can stay tinted while it is open.
  final FutureOr<void> Function(String) onTopic;
  final ValueChanged<String>? onLesson;
  final VoidCallback onPro;
  final VoidCallback onBack;
  final int initialLevel;
  final SortCycleOrder initialSort;
  final void Function(int level, SortCycleOrder sort, String? subjectId)?
      onOrderChanged;
  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

String _topicsLabel(int count) => '$count ${count == 1 ? "topic" : "topics"}';

class _PerformancePageState extends State<PerformancePage> {
  late int _level = widget.initialLevel;
  late SortCycleOrder _sort = widget.initialSort;
  String? _subject;
  bool _picker = false;
  void _publish() => widget.onOrderChanged?.call(_level, _sort, _subject);
  @override
  Widget build(BuildContext context) {
    final subjects = widget.data.subjects.where((r) => r.answered > 0).toList();
    final accuracy = widget.data.accuracy;
    final level = _level.clamp(0, widget.data.lessonLevelAvailable ? 2 : 1);
    // Free keeps the Subjects view. Topics and Lessons slide in but show one
    // invitation card instead of a list, and the sort button dims (DT_Free).
    final gated = !widget.pro && level != 0;
    final rows = (level == 0
            ? subjects
            : level == 1
                ? widget.data.topics
                : widget.data.lessons)
        .where(
          (r) =>
              r.answered > 0 &&
              (_subject == null ||
                  level == 0 ||
                  widget.data.parentSubjectIds[r.id] == _subject),
        )
        .toList()
      ..sort((a, b) {
        if (_sort == SortCycleOrder.alphabetical) {
          return a.title.compareTo(b.title);
        }
        final comparison = a.accuracy!.compareTo(b.accuracy!);
        return comparison == 0
            ? a.title.compareTo(b.title)
            : _sort == SortCycleOrder.weakest
                ? comparison
                : -comparison;
      });
    final order = switch (_sort) {
      SortCycleOrder.weakest => 'WEAKEST FIRST',
      SortCycleOrder.strongest => 'STRONGEST FIRST',
      SortCycleOrder.alphabetical => 'A TO Z'
    };
    if (context.wideWeb) {
      return WebPerformanceLayout(
        data: widget.data,
        rows: rows,
        level: level,
        sort: _sort,
        subject: _subject,
        pro: widget.pro,
        paused: widget.paused,
        onBack: widget.onBack,
        onTopic: widget.onTopic,
        openTopicId: widget.openTopicId,
        onLesson: widget.onLesson,
        onPro: widget.onPro,
        onLevel: (value) => setState(() {
          _level = value;
          _publish();
        }),
        onSort: (value) => setState(() {
          _sort = value;
          _publish();
        }),
        onSubject: (value) => setState(() {
          _subject = value;
          _publish();
        }),
      );
    }
    final accentHex = context.colors.accent
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2);
    final mutedHex = context.colors.textSecondary
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2);
    final page = PantasPage(
      title: 'Your performance',
      backLabel: 'Home',
      onBack: widget.onBack,
      bottomInset: 104,
      children: [
        if (accuracy != null) ...[
          // Boards (DT_Free, DT_TopicsA): the ring starts 4 px lower; the
          // switch is 6 px lower on the Pro Topics and Lessons views.
          Padding(
            padding: const EdgeInsets.only(top: PantasSpace.s4),
            child: HalfRingGauge(
              fraction: accuracy,
              label: 'Overall accuracy',
            ),
          ),
          SizedBox(height: widget.pro && level != 0 ? 22 : 16),
        ],
        // Board (DT_TopicsA): the sort square sits beside the switch, and the
        // label row under them holds the filter and the order.
        Row(
          children: [
            Expanded(
              child: SegmentedSwitch(
                labels: [
                  'Subjects',
                  'Topics',
                  if (widget.data.lessonLevelAvailable) 'Lessons',
                ],
                selected: level,
                onChanged: (level) => setState(() {
                  _level = level;
                  _publish();
                }),
              ),
            ),
            const SizedBox(width: PantasSpace.s8),
            SizedBox.square(
              dimension: 36,
              child: OverflowBox(
                maxWidth: 44,
                maxHeight: 44,
                child: Opacity(
                  opacity: gated ? .35 : 1,
                  child: IgnorePointer(
                    ignoring: gated,
                    child: SortCycleButton(
                      value: _sort,
                      onChanged: (sort) => setState(() {
                        _sort = sort;
                        _publish();
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: level == 0 ? 28 : 22),
        if (!gated)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s0,
              PantasSpace.s16,
              PantasSpace.s8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (level == 0)
                  Flexible(
                    child: Text(
                      '${subjects.length} SUBJECTS',
                      style: context.type.sectionHeader,
                    ),
                  )
                else
                  // The subject name gives way to the order label, which stays
                  // whole, so a long name ends in dots instead of running off
                  // the screen (2G-16).
                  Flexible(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.pro
                          ? () => setState(() => _picker = true)
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _subject == null
                                  ? 'ALL SUBJECTS'
                                  : subjects
                                      .firstWhere((r) => r.id == _subject)
                                      .title
                                      .toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.type.sectionHeader,
                            ),
                          ),
                          const SizedBox(width: PantasSpace.s4),
                          ExcludeSemantics(
                            child: SvgPicture.string(
                              '<svg viewBox="0 0 24 24" fill="none" '
                              'stroke="#$mutedHex" stroke-width="2.4" '
                              'stroke-linecap="round" stroke-linejoin="round"> '
                              '<path d="M8 9.5 12 5.5l4 4M8 14.5l4 4 4-4"/></svg>',
                              width: 13,
                              height: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: PantasSpace.s12),
                // Both labels give way at large text instead of overflowing.
                Flexible(
                  child: Text(
                    order,
                    textAlign: TextAlign.end,
                    style: context.type.sectionHeader,
                  ),
                ),
              ],
            ),
          ),
        if (!gated)
          ViewSwap(
            index: level,
            // A phone list is nearly the whole screen: slide only, no fade.
            fade: false,
            child: GroupedSection(
              children: [
                for (final (index, row) in rows.indexed)
                  _PerformanceRow(
                    title: row.title,
                    subtitle: level == 0
                        ? _topicsLabel(widget.data.subjectCounts[row.id] ?? 0)
                        : [
                            if (row.subtext != null) row.subtext!,
                            '${row.answered} answered',
                          ].join(' · '),
                    accuracy: row.accuracy!,
                    divider: index < rows.length - 1,
                    onTap: () => setState(() {
                      if (level == 0) {
                        _subject = row.id;
                        _level = 1;
                        _publish();
                      } else if (level == 1) {
                        widget.onTopic(row.id);
                      } else {
                        widget.onLesson?.call(row.id);
                      }
                    }),
                  ),
              ],
            ),
          ),
        if (gated) ...[
          // Board (DT_Free): the card starts 7 px higher, content centered
          // under a 26 px sparkle.
          const SizedBox(height: PantasSpace.s12),
          GroupedSection(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s18,
                  PantasSpace.s24,
                  PantasSpace.s18,
                  PantasSpace.s18,
                ),
                child: widget.paused
                    ? const ProPausedLine()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: ExcludeSemantics(
                              child: SvgPicture.string(
                                '<svg viewBox="0 0 24 24" fill="none" '
                                'stroke="#$accentHex" stroke-width="2" '
                                'stroke-linecap="round" '
                                'stroke-linejoin="round"><path d="M11 3.5 '
                                '12.6 8.4 17.5 10 12.6 11.6 11 16.5 9.4 '
                                '11.6 4.5 10l4.9-1.6z"/> <path d="M18 '
                                '15.5l.7 2 2 .7-2 .7-.7 2-.7-2-2-.7 2-.7z"/>'
                                ' </svg>',
                                width: 26,
                                height: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: PantasSpace.s12),
                          Text(
                            'Go deeper with Pro',
                            textAlign: TextAlign.center,
                            style: PantasType.phoneTitle3
                                .copyWith(color: context.colors.textPrimary),
                          ),
                          const SizedBox(height: PantasSpace.s8),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: Text(
                                'See your accuracy in every topic and lesson, '
                                'so you know exactly where to practice.',
                                textAlign: TextAlign.center,
                                style: context.type.subhead.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: PantasSpace.s18),
                          PantasButton(
                            label: 'Unlock with Pro',
                            onPressed: widget.onPro,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ],
    );
    return PantasSheet(
      page: page,
      label: 'Subjects',
      open: _picker,
      onDismiss: () => setState(() => _picker = false),
      readerContents: true,
      child: Padding(
        padding: const EdgeInsets.all(PantasSpace.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Subjects',
              style: PantasType.phoneTitle3
                  .copyWith(color: context.colors.textPrimary),
            ),
            ListRow(
              title: 'All subjects',
              onTap: () => setState(() {
                _subject = null;
                _picker = false;
                _publish();
              }),
            ),
            for (final row in subjects)
              ListRow(
                title: row.title,
                onTap: () => setState(() {
                  _subject = row.id;
                  _picker = false;
                  _publish();
                }),
              ),
          ],
        ),
      ),
    );
  }
}

/// Board (DT_TopicsA): 12/16 padding, the percent in 17 px semibold and a 5 px
/// bar 8 px under the title.
class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({
    required this.title,
    required this.subtitle,
    required this.accuracy,
    required this.divider,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final double accuracy;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MergeSemantics(
      child: HomeTapArea(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PantasSpace.s16,
            vertical: PantasSpace.s12,
          ),
          decoration: BoxDecoration(
            border: divider
                ? Border(bottom: BorderSide(color: c.divider, width: .5))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.body,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: PantasSpace.s2),
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.footnote,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: PantasSpace.s8),
                  Text(
                    '${(accuracy * 100).round()}%',
                    style: context.type.emphasized.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: PantasSpace.s8),
                  Icon(PantasIcons.next, size: 14, color: c.iconChevron),
                ],
              ),
              const SizedBox(height: PantasSpace.s8),
              AccuracyBar(accuracy: accuracy),
            ],
          ),
        ),
      ),
    );
  }
}
