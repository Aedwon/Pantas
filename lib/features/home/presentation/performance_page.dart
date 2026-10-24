import 'package:flutter/material.dart';
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
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';

export 'package:pantas/features/home/application/performance/performance_view.dart'
    show PerformanceViewData;

class PerformancePage extends StatefulWidget {
  const PerformancePage({
    required this.data,
    required this.pro,
    required this.paused,
    required this.onTopic,
    required this.onPractice,
    required this.onPro,
    required this.onBack,
    this.initialLevel = 0,
    this.initialSort = SortCycleOrder.weakest,
    this.onOrderChanged,
    this.onLesson,
    super.key,
  });
  final PerformanceViewData data;
  final bool pro;
  final bool paused;
  final ValueChanged<String> onTopic;
  final ValueChanged<String>? onLesson;
  final VoidCallback onPractice;
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
    final answered = subjects.fold(0, (sum, r) => sum + r.answered);
    final correct = subjects.fold(0, (sum, r) => sum + r.correct);
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
    final page = PantasPage(
      title: 'Your performance',
      backLabel: 'Home',
      onBack: widget.onBack,
      bottomInset: 104,
      children: [
        if (answered > 0) ...[
          HalfRingGauge(
            fraction: correct / answered,
            label: 'Overall accuracy',
          ),
          const SizedBox(height: 20),
        ],
        SegmentedSwitch(
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
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (gated)
              const SizedBox.shrink()
            else
              TextButton(
                onPressed: level == 0 || !widget.pro
                    ? null
                    : () => setState(() => _picker = true),
                child: Text(
                  level == 0
                      ? '${subjects.length} SUBJECTS'
                      : _subject == null
                          ? 'ALL SUBJECTS'
                          : subjects
                              .firstWhere((r) => r.id == _subject)
                              .title
                              .toUpperCase(),
                  style: context.type.sectionHeader,
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!gated) Text(order, style: context.type.sectionHeader),
                Opacity(
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
              ],
            ),
          ],
        ),
        if (!gated)
          GroupedSection(
            children: [
              for (final row in rows)
                Column(
                  children: [
                    ListRow(
                      title: row.title,
                      subtitle: level == 0
                          ? _topicsLabel(widget.data.subjectCounts[row.id] ?? 0)
                          : [
                              if (row.subtext != null) row.subtext!,
                              '${row.answered} answered',
                            ].join(' · '),
                      value: '${(row.accuracy! * 100).round()}%',
                      valueStyle: context.type.emphasized,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 13),
                      child: AccuracyBar.topicRows(accuracy: row.accuracy!),
                    ),
                  ],
                ),
            ],
          ),
        if (gated) ...[
          const SizedBox(height: 20),
          GroupedSection(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: widget.paused
                    ? const ProPausedLine()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Go deeper with Pro',
                            style: context.type.emphasized,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'See your accuracy in every topic and lesson, '
                            'so you know exactly where to practice.',
                            style: context.type.subhead.copyWith(
                              color: context.colors.secondaryLabel,
                            ),
                          ),
                          const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Subjects',
              style: context.type.emphasized.copyWith(fontSize: 20),
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
