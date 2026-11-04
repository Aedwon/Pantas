import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/pantas_durations.dart';
import 'package:pantas/core/ui/motion/view_swap.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
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
    this.openTopicId,
    super.key,
  });

  /// A topic whose panel is already open when the page is built, as when its
  /// address is opened directly.
  final String? openTopicId;
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

  /// Opens a topic's panel. A returned future ends when the panel closes, and
  /// the topic's row stays tinted until then (board PF_Topic).
  final FutureOr<void> Function(String) onTopic;
  final ValueChanged<String>? onLesson;
  final VoidCallback onPro;
  final VoidCallback onBack;
  @override
  State<WebPerformanceLayout> createState() => _WebPerformanceLayoutState();
}

class _WebPerformanceLayoutState extends State<WebPerformanceLayout> {
  final _expanded = <String>{};
  late String? _openTopic = widget.openTopicId;

  /// Opens the panel and tints the row while it is open.
  void _open(String id) {
    final panel = widget.onTopic(id);
    if (panel is! Future<void>) return;
    setState(() => _openTopic = id);
    unawaited(
      panel.whenComplete(() {
        if (mounted && _openTopic == id) setState(() => _openTopic = null);
      }),
    );
  }

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
            // The shell ends at the window bottom, so rows scroll to the edge
            // and the page's own margin sits after the last one.
            padding: EdgeInsets.only(bottom: context.webPageBottomInset),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WebPerformanceHeader(onBack: widget.onBack),
                    const SizedBox(height: 26),
                    _split(
                      left: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final switcher = WebSegmentedControl(
                                accentLabels: true,
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
                                        if (widget.data.lessonLevelAvailable)
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
                                    width: 272,
                                    onSelected: widget.onSubject,
                                  ),
                                if (!gated)
                                  _menu<SortCycleOrder>(
                                    context,
                                    label: _sortLabel,
                                    values: const {
                                      SortCycleOrder.weakest: 'Weakest first',
                                      SortCycleOrder.strongest:
                                          'Strongest first',
                                      SortCycleOrder.alphabetical: 'A to Z',
                                    },
                                    selected: widget.sort,
                                    width: 232,
                                    onSelected: widget.onSort,
                                  ),
                              ];
                              if (constraints.maxWidth >= 600) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 384,
                                            ),
                                            child: switcher,
                                          ),
                                        ),
                                      ),
                                    ),
                                    for (var i = 0; i < menus.length; i++) ...[
                                      if (i > 0) const SizedBox(width: 10),
                                      menus[i],
                                    ],
                                  ],
                                );
                              }
                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  SizedBox(
                                    width: constraints.maxWidth.clamp(0, 380),
                                    child: switcher,
                                  ),
                                  ...menus,
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          if (!gated)
                            ViewSwap(
                              index: widget.level,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
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
                                            // No hairline under the card's last
                                            // row, unless its topics follow.
                                            divider: row != widget.rows.last ||
                                                (widget.level == 0 &&
                                                    _expanded.contains(row.id)),
                                            subtitle: widget.level == 0
                                                ? _topicCount(row.id)
                                                : row.subtext,
                                            expanded: widget.level == 0 &&
                                                _expanded.contains(row.id),
                                            onPressed: () {
                                              if (widget.level == 0 &&
                                                  widget.pro) {
                                                setState(
                                                  () => _expanded
                                                          .contains(row.id)
                                                      ? _expanded.remove(row.id)
                                                      : _expanded.add(row.id),
                                                );
                                              } else if (widget.level == 0) {
                                                widget.onLevel(1);
                                              } else if (widget.level == 1) {
                                                _open(row.id);
                                              } else {
                                                widget.onLesson?.call(row.id);
                                              }
                                            },
                                          ),
                                          if (widget.level == 0)
                                            _topics(
                                              context,
                                              row,
                                              last: row == widget.rows.last,
                                            ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                      right: answered <= 0
                          ? const SizedBox.shrink()
                          : Padding(
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The board's list column (flex 1.45 from 480 px) beside the Overall column
  /// (flex 1 from 300 px), 28 px apart.
  Widget _split({required Widget left, required Widget right}) => LayoutBuilder(
        builder: (context, c) {
          const gap = 28.0;
          final free = c.maxWidth - 480 - 300 - gap;
          if (free < 0) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 145, child: left),
                const SizedBox(width: gap),
                Expanded(flex: 100, child: right),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 480 + free * 1.45 / 2.45, child: left),
              const SizedBox(width: gap),
              Expanded(child: right),
            ],
          );
        },
      );

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

  /// A subject's topics, sliding open and shut in 240 ms.
  Widget _topics(
    BuildContext context,
    PerformanceRow row, {
    required bool last,
  }) {
    final t = context.webTokens;
    final shown = _expanded.contains(row.id)
        ? _topicsFor(row.id)
        : const <PerformanceRow>[];
    // Full width, so only the height animates as topics come and go.
    final topics = SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          for (final topic in shown)
            ColoredBox(
              color: t.dark ? t.rowHover : const Color(0xFFFBFBFC),
              child: _row(
                context,
                topic,
                indent: true,
                divider: !(last && topic == shown.last),
                onPressed: () => _open(topic.id),
              ),
            ),
        ],
      ),
    );
    return KeyedSubtree(
      key: ValueKey('subject-topics-${row.id}'),
      // A zero-length AnimatedSize re-enters its own layout, so reduced
      // motion skips it.
      child: MediaQuery.disableAnimationsOf(context)
          ? topics
          : AnimatedSize(
              duration: PantasDurations.base,
              curve: PantasCurves.shared,
              alignment: Alignment.topCenter,
              child: topics,
            ),
    );
  }

  Widget _row(
    BuildContext context,
    PerformanceRow row, {
    required VoidCallback onPressed,
    String? subtitle,
    bool indent = false,
    bool expanded = false,
    bool divider = true,
  }) {
    final t = context.webTokens;
    // The board indents a topic row 40 px left and keeps 20 px right.
    return Padding(
      padding: EdgeInsets.only(left: indent ? 20 : 0),
      child: LayoutBuilder(
        builder: (context, constraints) => WebRow(
          boardMetrics: !indent,
          divider: divider,
          title: row.title,
          // A long topic or lesson name wraps instead of ending in dots; the
          // bar column keeps one width so the bars still line up (2G-12).
          wrapTitle: true,
          // The row whose panel is open keeps its tint under the scrim.
          selected: row.id == _openTopic,
          compact: indent,
          subtitle: subtitle,
          titleStyle: t.style(
            indent ? 16 : 17,
            height: indent ? null : 1.3,
            weight: expanded ? FontWeight.w600 : FontWeight.w400,
          ),
          onPressed: onPressed,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.level > 0 || indent) ...[
                SizedBox(
                  width: 96,
                  child: Text(
                    '${row.answered} answered',
                    textAlign: TextAlign.right,
                    style: t.sub,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              SizedBox(
                width: constraints.maxWidth > 600 ? 160 : 80,
                child: AccuracyBar.topicRows(accuracy: row.accuracy!),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 44,
                child: Text(
                  '${(row.accuracy! * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: t.style(16, weight: FontWeight.w600),
                ),
              ),
              // The board's Free rows end at the percent: a tap leads to Pro.
              if (widget.pro || widget.level > 0 || indent)
                const SizedBox(width: 12),
              if (!widget.pro && widget.level == 0 && !indent)
                const SizedBox.shrink()
              else if (widget.level == 0 && !indent)
                AnimatedRotation(
                  turns: expanded ? .5 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : PantasDurations.base,
                  curve: PantasCurves.shared,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: t.colors.chevron,
                  ),
                )
              else
                const WebChevron(),
            ],
          ),
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
    required double width,
  }) {
    final t = context.webTokens;
    // Wrap nullable values so All subjects is selectable.
    return PopupMenuButton<(T,)>(
      tooltip: label,
      color: t.colors.surface,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 10),
      menuPadding: const EdgeInsets.all(6),
      constraints: BoxConstraints.tightFor(width: width),
      // Board (PF_Sort): a clear edge and a soft shadow, so the menu stands
      // off the white list card in light mode too.
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: t.colors.separator),
      ),
      shadowColor: Colors.black.withValues(alpha: .16),
      surfaceTintColor: Colors.transparent,
      initialValue: (selected,),
      onSelected: (value) => onSelected(value.$1),
      itemBuilder: (_) => [
        _KeyboardMenuList<T>(values: values, selected: selected),
      ],
      child: Container(
        height: 38,
        padding: const EdgeInsets.only(left: 14, right: 12),
        decoration: BoxDecoration(
          color: t.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.colors.separator),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: t.style(15, weight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: t.colors.label,
            ),
          ],
        ),
      ),
    );
  }
}

/// The rows of a sort or filter menu, with their own keyboard handling.
///
/// Flutter on the web maps the arrow keys to page scrolling, not to moving
/// between menu items, and maps Enter to buttons only. A stock popup menu
/// therefore ignores ArrowDown and Enter in a browser. This list keeps one
/// highlighted row: Arrow keys, Home and End move it, Enter or Space picks it,
/// and the mouse moves it as the pointer passes. Esc closes the menu as usual.
class _KeyboardMenuList<T> extends PopupMenuEntry<(T,)> {
  const _KeyboardMenuList({required this.values, required this.selected});
  final Map<T, String> values;
  final T selected;
  static const double rowHeight = 41;

  @override
  double get height => values.length * rowHeight;

  @override
  bool represents((T,)? value) => value != null && value.$1 == selected;

  @override
  State<_KeyboardMenuList<T>> createState() => _KeyboardMenuListState<T>();
}

class _KeyboardMenuListState<T> extends State<_KeyboardMenuList<T>> {
  late int _highlight = math.max(
    0,
    widget.values.keys.toList().indexOf(widget.selected),
  );

  void _move(int to) {
    final last = widget.values.length - 1;
    setState(() => _highlight = to.clamp(0, last));
  }

  void _pick(int index) =>
      Navigator.pop(context, (widget.values.keys.elementAt(index),));

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final keys = widget.values.keys.toList();
    final last = keys.length - 1;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _move(_highlight + 1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _move(_highlight - 1),
        const SingleActivator(LogicalKeyboardKey.home): () => _move(0),
        const SingleActivator(LogicalKeyboardKey.end): () => _move(last),
        const SingleActivator(
          LogicalKeyboardKey.enter,
          includeRepeats: false,
        ): () => _pick(_highlight),
        const SingleActivator(
          LogicalKeyboardKey.numpadEnter,
          includeRepeats: false,
        ): () => _pick(_highlight),
        const SingleActivator(LogicalKeyboardKey.space): () =>
            _pick(_highlight),
      },
      child: Focus(
        autofocus: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < keys.length; i++)
              Semantics(
                button: true,
                selected: keys[i] == widget.selected,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _highlight = i),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _pick(i),
                    child: Container(
                      height: _KeyboardMenuList.rowHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: i == _highlight
                            ? (t.dark ? t.colors.fill : const Color(0xFFF2F2F5))
                            : null,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.values[keys[i]]!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.style(16),
                            ),
                          ),
                          if (keys[i] == widget.selected)
                            Icon(
                              Icons.check,
                              size: 18,
                              color: t.colors.accent,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
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
          WebBackLink(label: 'Home', onPressed: onBack),
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
