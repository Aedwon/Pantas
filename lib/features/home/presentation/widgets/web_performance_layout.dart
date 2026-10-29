import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';

/// PF_* presentation. Filtering and stored ordering stay with PerformancePage.
class WebPerformanceLayout extends StatefulWidget {
  const WebPerformanceLayout({
    required this.data,
    required this.rows,
    required this.level,
    required this.sort,
    required this.subject,
    required this.pro,
    required this.paused,
    required this.onLevel,
    required this.onSort,
    required this.onSubject,
    required this.onTopic,
    required this.onLesson,
    required this.onPro,
    required this.onBack,
    super.key,
  });
  final PerformanceViewData data;
  final List<PerformanceRow> rows;
  final int level;
  final SortCycleOrder sort;
  final String? subject;
  final bool pro;
  final bool paused;
  final ValueChanged<int> onLevel;
  final ValueChanged<SortCycleOrder> onSort;
  final ValueChanged<String?> onSubject;
  final ValueChanged<String> onTopic;
  final ValueChanged<String>? onLesson;
  final VoidCallback onPro;
  final VoidCallback onBack;
  @override
  State<WebPerformanceLayout> createState() => _WebPerformanceLayoutState();
}

class _WebPerformanceLayoutState extends State<WebPerformanceLayout> {
  final _expanded = <String>{};
  String get _sortLabel => switch (widget.sort) {
        SortCycleOrder.weakest => 'Weakest first',
        SortCycleOrder.strongest => 'Strongest first',
        SortCycleOrder.alphabetical => 'A to Z'
      };
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final subjects = widget.data.subjects.where((r) => r.answered > 0).toList();
    final answered = widget.data.overallAnswered ??
        subjects.fold<int>(0, (n, r) => n + r.answered);
    final correct = widget.data.overallCorrect ??
        subjects.fold<int>(0, (n, r) => n + r.correct);
    final gated = !widget.pro && widget.level > 0;
    final subjectNames = {for (final s in subjects) s.id: s.title};
    final scope = subjectNames[widget.subject];
    final kind = ['subjects', 'topics', 'lessons'][widget.level];
    final scopeLabel = scope != null && widget.level > 0 ? ' · $scope' : '';
    final heading = '${widget.rows.length} $kind$scopeLabel · $_sortLabel';
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onBack,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: t.colors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(44, 28, 44, 64),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WebPerformanceHeader(onBack: widget.onBack),
                    const SizedBox(height: 28),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 145,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final switcher = WebSegmentedControl(
                                    labels: [
                                      'Subjects',
                                      'Topics',
                                      if (widget.data.lessonLevelAvailable)
                                        'Lessons',
                                    ],
                                    suffixes: widget.pro
                                        ? null
                                        : [
                                            null,
                                            const ProTag(),
                                            if (widget
                                                .data.lessonLevelAvailable)
                                              const ProTag(),
                                          ],
                                    selected: widget.level,
                                    onChanged: widget.onLevel,
                                  );
                                  final menus = <Widget>[
                                    if (widget.level > 0 && !gated)
                                      _menu<String?>(
                                        context,
                                        label: scope ?? 'All subjects',
                                        values: {
                                          null: 'All subjects',
                                          ...subjectNames,
                                        },
                                        selected: widget.subject,
                                        onSelected: widget.onSubject,
                                      ),
                                    if (!gated)
                                      _menu<SortCycleOrder>(
                                        context,
                                        label: _sortLabel,
                                        values: const {
                                          SortCycleOrder.weakest:
                                              'Weakest first',
                                          SortCycleOrder.strongest:
                                              'Strongest first',
                                          SortCycleOrder.alphabetical: 'A to Z',
                                        },
                                        selected: widget.sort,
                                        onSelected: widget.onSort,
                                      ),
                                  ];
                                  if (constraints.maxWidth >= 600) {
                                    return Row(
                                      children: [
                                        Expanded(child: switcher),
                                        for (final menu in menus) ...[
                                          const SizedBox(width: 10),
                                          menu,
                                        ],
                                      ],
                                    );
                                  }
                                  return Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      SizedBox(
                                        width:
                                            constraints.maxWidth.clamp(0, 380),
                                        child: switcher,
                                      ),
                                      ...menus,
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              if (!gated) ...[
                                WebText(
                                  heading,
                                  kind: WebTextKind.eyebrow,
                                ),
                                WebCard(
                                  child: Column(
                                    children: [
                                      for (final row in widget.rows) ...[
                                        _row(
                                          context,
                                          row,
                                          subtitle: widget.level == 0
                                              ? _topicCount(row.id)
                                              : row.subtext,
                                          expanded: widget.level == 0 &&
                                              _expanded.contains(row.id),
                                          onPressed: () {
                                            if (widget.level == 0 &&
                                                widget.pro) {
                                              setState(
                                                () => _expanded.contains(row.id)
                                                    ? _expanded.remove(row.id)
                                                    : _expanded.add(row.id),
                                              );
                                            } else if (widget.level == 0) {
                                              widget.onLevel(1);
                                            } else if (widget.level == 1) {
                                              widget.onTopic(row.id);
                                            } else {
                                              widget.onLesson?.call(row.id);
                                            }
                                          },
                                        ),
                                        if (widget.level == 0 &&
                                            _expanded.contains(row.id))
                                          for (final topic
                                              in _topicsFor(row.id))
                                            ColoredBox(
                                              color: t.rowHover,
                                              child: _row(
                                                context,
                                                topic,
                                                indent: true,
                                                onPressed: () => widget.onTopic(
                                                  topic.id,
                                                ),
                                              ),
                                            ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              if (!widget.pro) ...[
                                const SizedBox(height: 20),
                                WebCard(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 22,
                                  ),
                                  child: widget.paused
                                      ? const ProPausedLine()
                                      : Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: t.colors.accentTint,
                                              ),
                                              child: Icon(
                                                Icons.lock_outline_rounded,
                                                size: 22,
                                                color: t.colors.accent,
                                              ),
                                            ),
                                            const SizedBox(width: 18),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Go deeper with Pro',
                                                    style: t.style(
                                                      17,
                                                      weight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'See your accuracy in '
                                                    'every topic and lesson, '
                                                    'so you know exactly '
                                                    'where to practice.',
                                                    style: t.sub,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 18),
                                            WebButton(
                                              label: 'Unlock with Pro',
                                              onPressed: widget.onPro,
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 28),
                        if (answered > 0)
                          Expanded(
                            flex: 100,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 54),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const WebText(
                                    'Overall',
                                    kind: WebTextKind.eyebrow,
                                  ),
                                  WebCard(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      28,
                                      20,
                                      24,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 224,
                                        child: MediaQuery(
                                          data: MediaQuery.of(
                                            context,
                                          ).copyWith(
                                            disableAnimations: true,
                                          ),
                                          child: HalfRingGauge(
                                            web: true,
                                            fraction: correct / answered,
                                            label: 'Overall accuracy',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _topicCount(String id) {
    final count = widget.data.subjectCounts[id] ?? 0;
    return '$count ${count == 1 ? 'topic' : 'topics'}';
  }

  List<PerformanceRow> _topicsFor(String id) => widget.data.topics
      .where((r) => r.answered > 0 && widget.data.parentSubjectIds[r.id] == id)
      .toList()
    ..sort(_compare);
  int _compare(PerformanceRow a, PerformanceRow b) {
    if (widget.sort == SortCycleOrder.alphabetical) {
      return a.title.compareTo(b.title);
    }
    final n = a.accuracy!.compareTo(b.accuracy!);
    return n == 0
        ? a.title.compareTo(b.title)
        : widget.sort == SortCycleOrder.weakest
            ? n
            : -n;
  }

  Widget _row(
    BuildContext context,
    PerformanceRow row, {
    required VoidCallback onPressed,
    String? subtitle,
    bool indent = false,
    bool expanded = false,
  }) {
    final t = context.webTokens;
    return LayoutBuilder(
      builder: (context, constraints) => WebRow(
        title: row.title,
        compact: indent,
        subtitle: subtitle,
        horizontalPadding: indent ? 40 : 20,
        titleStyle: t.style(indent ? 16 : 17),
        onPressed: onPressed,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.level > 0 || indent) ...[
              Text('${row.answered} answered', style: t.sm),
              const SizedBox(width: 16),
            ],
            SizedBox(
              width: constraints.maxWidth > 600 ? 160 : 80,
              child: AccuracyBar.topicRows(accuracy: row.accuracy!),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 44,
              child: Text(
                '${(row.accuracy! * 100).round()}%',
                textAlign: TextAlign.right,
                style: t.style(16, weight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              widget.level == 0 && !indent
                  ? expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down
                  : Icons.chevron_right,
              size: 16,
              color: t.colors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menu<T>(
    BuildContext context, {
    required String label,
    required Map<T, String> values,
    required T selected,
    required ValueChanged<T> onSelected,
  }) {
    final t = context.webTokens;
    // Wrap nullable values so All subjects is selectable.
    return PopupMenuButton<(T,)>(
      tooltip: label,
      color: t.colors.surface,
      initialValue: (selected,),
      onSelected: (value) => onSelected(value.$1),
      itemBuilder: (_) => [
        for (final e in values.entries)
          PopupMenuItem(
            value: (e.key,),
            child: Row(
              children: [
                Expanded(child: Text(e.value, style: t.style(15))),
                if (e.key == selected)
                  Icon(Icons.check, size: 18, color: t.colors.accent),
              ],
            ),
          ),
      ],
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: t.colors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: t.style(15, weight: FontWeight.w500)),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: t.colors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class WebPerformanceHeader extends StatelessWidget {
  const WebPerformanceHeader({
    required this.onBack,
    this.description = true,
    super.key,
  });
  final VoidCallback onBack;
  final bool description;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left, size: 20),
            label: const Text('Home'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 28),
              foregroundColor: context.webTokens.colors.accent,
            ),
          ),
          const SizedBox(height: 6),
          const WebText('Your performance', kind: WebTextKind.h1),
          if (description) ...[
            const SizedBox(height: 6),
            const WebText(
              "Accuracy across everything you've answered.",
              kind: WebTextKind.lead,
            ),
          ],
        ],
      );
}
