import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/data_table.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/motion/view_swap.dart';
// ds-raw: sort menu with its own list, shape and shadow
import 'package:pantas/core/ui/raw_controls.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_hover.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/presentation/widgets/home_columns.dart';

/// PF_* presentation. Filtering and stored ordering stay with PerformancePage.
const double _switcherWidth =
    PantasSpace.s56 * 6 + PantasSpace.s40 + PantasSpace.s8;
const double _subjectMenuWidth =
    PantasSpace.s56 * 4 + PantasSpace.s40 + PantasSpace.s8;
const double _sortMenuWidth = PantasSpace.s56 * 4 + PantasSpace.s8;

/// The accuracy bar column of the Performance table (board PF_*).
// ds-board: the Performance board draws the bar 160 wide beside its percent
const double _barColumn = PantasSpace.s40 * 4;

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
    final accuracy = widget.data.accuracy;
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
        skipTraversal: true,
        child: Scaffold(
          backgroundColor: t.colors.bgPage,
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
                    const SizedBox(height: PantasSpace.s24),
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
                                        const ProMark(),
                                        if (widget.data.lessonLevelAvailable)
                                          const ProMark(),
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
                                    width: _subjectMenuWidth,
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
                                    width: _sortMenuWidth,
                                    onSelected: widget.onSort,
                                  ),
                              ];
                              // The row needs the switcher at its full width
                              // beside the menus; the Free "Pro" tags do not
                              // fit a squeezed segment.
                              final switcherWidth = _switcherWidth *
                                  MediaQuery.textScalerOf(context).scale(1);
                              final rowNeeds = switcherWidth +
                                  menus.fold<double>(
                                    0,
                                    (sum, menu) => sum + PantasSpace.s10,
                                  ) +
                                  (widget.level > 0 && !gated
                                      ? _subjectMenuWidth
                                      : PantasSpace.s0) +
                                  (!gated ? _sortMenuWidth : PantasSpace.s0);
                              if (constraints.maxWidth >= rowNeeds) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: PantasSpace.s10,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: switcherWidth,
                                            ),
                                            child: switcher,
                                          ),
                                        ),
                                      ),
                                    ),
                                    for (var i = 0; i < menus.length; i++) ...[
                                      if (i > 0)
                                        const SizedBox(width: PantasSpace.s10),
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
                                    width: constraints.maxWidth
                                        .clamp(0, switcherWidth),
                                    child: switcher,
                                  ),
                                  ...menus,
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: PantasSpace.s16),
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
                                  _table(context),
                                ],
                              ),
                            ),
                          if (!widget.pro) ...[
                            const SizedBox(height: PantasSpace.s20),
                            WebCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: PantasSpace.s24,
                                vertical: PantasSpace.s24,
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
                                        const SizedBox(width: PantasSpace.s18),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Go deeper with Pro',
                                                style: PantasType.webButtonLg
                                                    .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: t.colors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: PantasSpace.s2,
                                              ),
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
                                        const SizedBox(width: PantasSpace.s18),
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
                      right: accuracy == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding:
                                  const EdgeInsets.only(top: PantasSpace.s56),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const WebText(
                                    'Overall',
                                    kind: WebTextKind.eyebrow,
                                  ),
                                  WebCard(
                                    padding: const EdgeInsets.fromLTRB(
                                      PantasSpace.s20,
                                      PantasSpace.s28,
                                      PantasSpace.s20,
                                      PantasSpace.s24,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: PantasSize.gaugeW,
                                        child: MediaQuery(
                                          data: MediaQuery.of(
                                            context,
                                          ).copyWith(
                                            disableAnimations: true,
                                          ),
                                          child: HalfRingGauge(
                                            web: true,
                                            fraction: accuracy,
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

  /// The Columns primary and secondary pair: the list column beside the
  /// Overall column, stacked when the content is too narrow for both.
  Widget _split({required Widget left, required Widget right}) => LayoutBuilder(
        builder: (context, c) {
          if (HomeColumns.stacks(c.maxWidth)) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                left,
                const SizedBox(height: HomeColumns.gap),
                right,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: HomeColumns.primaryWidth(c.maxWidth),
                child: left,
              ),
              const SizedBox(width: HomeColumns.gap),
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

  /// The rows of the current view on the system DataTable. A Pro subject row
  /// opens its topics in place, right under it; a topic or lesson row opens its
  /// panel; a Free subject row leads to Pro. Accuracy is always a measured
  /// value: a row with no answers is not listed.
  Widget _table(BuildContext context) => LayoutBuilder(
        builder: (context, box) => _tableFor(context, box.maxWidth),
      );

  Widget _tableFor(BuildContext context, double width) {
    final t = context.webTokens;
    final level = widget.level;
    final rows = widget.rows;
    // The bar is 80 wide on a row 600 or less wide, 160 otherwise.
    final barWidth = width > 600 ? _barColumn : _barColumn / 2;
    final topics = <int, List<PerformanceRow>>{
      if (level == 0)
        for (var i = 0; i < rows.length; i++) i: _topicsFor(rows[i].id),
    };
    PantasTableCell none() =>
        const PantasTableCell.widget(SizedBox.shrink(), width: PantasSize.icon);
    PantasTableCell chevron(PerformanceRow row, {required bool topic}) {
      if (!widget.pro && level == 0 && !topic) return none();
      if (level == 0 && !topic) {
        return PantasTableCell.widget(
          AnimatedRotation(
            turns: _expanded.contains(row.id) ? .5 : 0,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : PantasDurations.medium1,
            curve: PantasCurves.move,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: PantasSpace.s16,
              color: t.colors.iconChevron,
            ),
          ),
          width: PantasSpace.s16,
        );
      }
      return const PantasTableCell.widget(WebChevron(), width: PantasSpace.s16);
    }

    List<Object?> cells(PerformanceRow row, {bool topic = false}) {
      final expanded = level == 0 && !topic && _expanded.contains(row.id);
      final sub =
          level == 0 ? (topic ? null : _topicCount(row.id)) : row.subtext;
      return [
        PantasTableCell.text(
          row.title,
          bold: expanded,
          indent: topic ? PantasSpace.s20 : 0,
          subtitle: sub,
        ),
        if (level > 0 || topic) '${row.answered} answered' else '',
        PantasTableCell.widget(
          SizedBox(
            width: barWidth,
            child: AccuracyBar.topicRows(accuracy: row.accuracy!),
          ),
          width: barWidth,
        ),
        '${(row.accuracy! * 100).round()}%',
        chevron(row, topic: topic),
      ];
    }

    final columns = [
      PantasTableColumn(['Subject', 'Topic', 'Lesson'][level]),
      const PantasTableColumn('Answered', numeric: true),
      const PantasTableColumn(''),
      const PantasTableColumn('Accuracy', numeric: true),
      const PantasTableColumn(''),
    ];
    final selected = rows.indexWhere((r) => r.id == _openTopic);
    (int, int)? selectedChild;
    for (final entry in topics.entries) {
      final k = entry.value.indexWhere((r) => r.id == _openTopic);
      if (k >= 0 && _expanded.contains(rows[entry.key].id)) {
        selectedChild = (entry.key, k);
      }
    }
    return KeyedSubtree(
      key: const ValueKey('performance-table'),
      child: PantasDataTable(
        columns: columns,
        rows: [for (final row in rows) cells(row)],
        childRows: {
          for (final e in topics.entries)
            e.key: [for (final r in e.value) cells(r, topic: true)],
        },
        expandedRows: {
          for (var i = 0; i < rows.length; i++)
            if (level == 0 && _expanded.contains(rows[i].id)) i,
        },
        selectedRow: selected < 0 ? null : selected,
        selectedChild: selectedChild,
        onChildTap: (i, k) => _open(topics[i]![k].id),
        onRowTap: (i) {
          final row = rows[i];
          if (level == 0 && widget.pro) {
            setState(
              () => _expanded.contains(row.id)
                  ? _expanded.remove(row.id)
                  : _expanded.add(row.id),
            );
          } else if (level == 0) {
            widget.onLevel(1);
          } else if (level == 1) {
            _open(row.id);
          } else {
            widget.onLesson?.call(row.id);
          }
        },
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
    // The button names itself, so a tooltip would only repeat its text. The
    // hover and focus tint follows the rounded pill, and the keyboard ring
    // replaces the focus tint (3K-5).
    return WebKeyboardRing(
      borderRadius: BorderRadius.circular(PantasRadius.md),
      child: Theme(
        data: Theme.of(context).copyWith(focusColor: Colors.transparent),
        child: _popup<T>(
          context,
          label: label,
          values: values,
          selected: selected,
          onSelected: onSelected,
          width: width,
        ),
      ),
    );
  }

  Widget _popup<T>(
    BuildContext context, {
    required String label,
    required Map<T, String> values,
    required T selected,
    required ValueChanged<T> onSelected,
    required double width,
  }) {
    final t = context.webTokens;
    return PopupMenuButton<(T,)>(
      tooltip: '',
      borderRadius: BorderRadius.circular(PantasRadius.md),
      color: t.colors.surfaceCard,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 10),
      menuPadding: const EdgeInsets.all(PantasSpace.s6),
      constraints: BoxConstraints.tightFor(width: width),
      // Board (PF_Sort): a clear edge and a soft shadow, so the menu stands
      // off the white list card in light mode too.
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PantasRadius.lg),
        side: BorderSide(color: t.colors.divider),
      ),
      shadowColor: context.shadows.popover.first.color,
      surfaceTintColor: Colors.transparent,
      initialValue: (selected,),
      onSelected: (value) => onSelected(value.$1),
      itemBuilder: (_) => [
        _KeyboardMenuList<T>(values: values, selected: selected),
      ],
      // The pill's own fill is opaque, so the popup's ink would paint under
      // it. The fill takes the row hover tint itself (5Q-10).
      child: WebHover(
        builder: (context, hovered) => Container(
          height: 38,
          padding: const EdgeInsets.only(
            left: PantasSpace.s14,
            right: PantasSpace.s12,
          ),
          decoration: BoxDecoration(
            color: hovered ? t.rowHover : t.colors.surfaceCard,
            borderRadius: BorderRadius.circular(PantasRadius.md),
            border: Border.all(color: t.colors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: PantasType.webLink.copyWith(color: t.colors.textPrimary),
              ),
              const SizedBox(width: PantasSpace.s8),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: t.colors.textPrimary,
              ),
            ],
          ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: PantasSpace.s10,
                      ),
                      decoration: BoxDecoration(
                        color: i == _highlight ? t.colors.fill : null,
                        borderRadius: BorderRadius.circular(PantasRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.values[keys[i]]!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: PantasType.webBody
                                  .copyWith(color: t.colors.textPrimary),
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
          const SizedBox(height: PantasSpace.s6),
          const WebText('Your performance', kind: WebTextKind.h1),
          if (description) ...[
            const SizedBox(height: PantasSpace.s6),
            const WebText(
              "Accuracy across everything you've answered.",
              kind: WebTextKind.lead,
            ),
          ],
        ],
      );
}
