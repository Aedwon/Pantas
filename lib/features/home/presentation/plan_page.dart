import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/presentation/plan_web.dart';

enum PlanNodeKind { week, review, mock, exam }

class PlanNode {
  const PlanNode({
    required this.kind,
    required this.title,
    required this.subtitle,
    this.date,
    this.target,
    this.reviewOnly = false,
    this.day,
  });
  final PlanNodeKind kind;
  final String title;
  final String subtitle;
  final String? date;
  final String? target;
  final bool reviewOnly;

  /// The calendar day of an exam node, for the wide web glyph.
  final DateTime? day;
}

class PlanHistoryEntry {
  const PlanHistoryEntry({
    required this.id,
    required this.date,
    required this.text,
  });
  final String id;
  final String date;
  final String text;
}

class PlanPage extends StatefulWidget {
  const PlanPage({
    required this.pro,
    required this.paused,
    required this.done,
    required this.total,
    required this.nodes,
    required this.history,
    required this.onBack,
    required this.onToday,
    required this.onWeek,
    required this.onPro,
    this.subtitle,
    this.webPane,
    this.selectedWeek,
    this.onHistory,
    this.initialShown = 5,
    this.loadingMore = false,
    this.paginationError,
    this.hasMore = false,
    this.onMore,
    super.key,
  });
  final Widget? webPane;
  final String? selectedWeek;
  final VoidCallback? onHistory;
  final bool pro;
  final bool paused;
  final int done;
  final int total;
  final List<PlanNode> nodes;
  final List<PlanHistoryEntry> history;
  final String? subtitle;
  final int initialShown;
  final bool loadingMore;
  final Widget? paginationError;
  final VoidCallback onBack;
  final VoidCallback onToday;
  final ValueChanged<String> onWeek;
  final VoidCallback onPro;
  final bool hasMore;
  final VoidCallback? onMore;
  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late int _shown;
  @override
  void initState() {
    super.initState();
    _shown = widget.initialShown;
  }

  final _expanded = <String>{};
  Widget _entry(
    int start,
    int duration,
    Widget child, {
    double x = 0,
    double y = 0,
    bool draw = false,
    bool pop = false,
    Key? effectKey,
  }) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: start + duration),
      curve: Interval(
        start / (start + duration),
        1,
        curve: draw
            ? PantasCurves.linear
            : pop
                ? PantasCurves.popB
                : PantasCurves.houseOut,
      ),
      child: child,
      builder: (_, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(x * (1 - value), y * (1 - value)),
          child: Transform.scale(
            key: effectKey,
            alignment: draw ? Alignment.topCenter : Alignment.center,
            scaleX: pop ? .3 + .7 * value : 1,
            scaleY: draw
                ? value
                : pop
                    ? .3 + .7 * value
                    : 1,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
        // Boards: 13 px gray caps, like the Today label.
        child: Text(text.toUpperCase(), style: context.type.sectionHeader),
      );
  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      return PlanWebColumns(
        page: widget,
        pane: widget.webPane,
        selectedWeek: widget.selectedWeek,
        onHistory: widget.onHistory,
      );
    }
    final last =
        widget.nodes.where((n) => n.kind == PlanNodeKind.exam).firstOrNull;
    final visible = widget.history.take(_shown).toList();
    final historyStart = widget.nodes.isEmpty
        ? 350
        : 350 + (widget.nodes.length - 1) * 260 + 270;
    return PantasPage(
      title: 'Your plan',
      backLabel: 'Home',
      onBack: widget.onBack,
      bottomInset: 104,
      // Board DP_PlanA: the subtitle sits 2 px under the title.
      titlePadding: EdgeInsets.fromLTRB(
        4,
        0,
        4,
        widget.subtitle != null ? 2 : 20,
      ),
      children: [
        if (widget.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 20),
            child: Text(
              widget.subtitle!,
              style: context.type.subhead
                  .copyWith(color: context.colors.secondaryLabel),
            ),
          ),
        _entry(
          0,
          450,
          GroupedSection(
            header: 'Today',
            children: [
              ListRow(
                title: '${widget.done} of ${widget.total} done',
                subtitle: widget.done == widget.total
                    ? null
                    : 'Reviews and new questions left',
                leading: ProgressRing(
                  fraction: widget.total == 0 ? 0 : widget.done / widget.total,
                  size: 36,
                ),
                variant: ListRowVariant.value,
              ),
            ],
          ),
          y: 14,
        ),
        const SizedBox(height: 24),
        _entry(100, 450, _heading('Coming up'), y: 14),
        if (widget.pro) ...[
          GroupedSection(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 16, 12),
                child: Column(
                  children: [
                    for (var i = 0; i < widget.nodes.length; i++)
                      _timelineRow(widget.nodes[i], i),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Later weeks show topics only.',
              style: context.type.footnote,
            ),
          ),
          const SizedBox(height: 24),
          _entry(historyStart, 500, _heading('History'), y: 14),
          GroupedSection(
            children: [
              for (var i = 0; i < visible.length; i++)
                _entry(
                  historyStart + 200 + i * 80,
                  500,
                  ListRow(
                    title: visible[i].text,
                    titleWidget: Text(
                      visible[i].text,
                      maxLines: _expanded.contains(visible[i].id) ? null : 1,
                      overflow: _expanded.contains(visible[i].id)
                          ? null
                          : TextOverflow.ellipsis,
                      style: context.type.subhead,
                    ),
                    leading: SizedBox(
                      width: 70,
                      child: Text(
                        visible[i].date,
                        style: context.type.footnote,
                      ),
                    ),
                    variant: ListRowVariant.value,
                    divider: i < visible.length - 1,
                    onTap: () => setState(
                      () => _expanded.contains(visible[i].id)
                          ? _expanded.remove(visible[i].id)
                          : _expanded.add(visible[i].id),
                    ),
                  ),
                  y: 8,
                ),
              if (_shown < widget.history.length || widget.hasMore)
                PantasButton(
                  label: 'See more',
                  variant: PantasButtonVariant.tertiary,
                  onPressed: widget.loadingMore
                      ? null
                      : () => setState(() {
                            _shown += 10;
                            if (_shown > widget.history.length) {
                              widget.onMore?.call();
                            }
                          }),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Text(
                    "That's everything since you started.",
                    textAlign: TextAlign.center,
                    style: context.type.footnote,
                  ),
                ),
            ],
          ),
          if (widget.paginationError != null) widget.paginationError!,
        ] else ...[
          GroupedSection(
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: context.colors.fill,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 12,
                              width: 130 + i * 20,
                              color: context.colors.fill,
                            ),
                            const SizedBox(height: 9),
                            Container(height: 9, color: context.colors.fill),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (last != null)
                ListRow(
                  title: last.title,
                  subtitle: last.date,
                  value: last.subtitle,
                  variant: ListRowVariant.value,
                ),
            ],
          ),
          const SizedBox(height: 24),
          _heading('History'),
          GroupedSection(
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(height: 10, color: context.colors.fill),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.paused)
            const ProPausedLine()
          else ...[
            Text(
              'See every week up to your exam, and every time your plan '
              'adjusts.',
              textAlign: TextAlign.center,
              style: context.type.subhead
                  .copyWith(color: context.colors.secondaryLabel),
            ),
            const SizedBox(height: 14),
            PantasButton(label: 'Unlock with Pro', onPressed: widget.onPro),
          ],
        ],
      ],
    );
  }

  /// DP_PlanA: 66 px rows, a 28 px marker column and a 2 or 3 px line from
  /// each marker down to the next one.
  Widget _timelineRow(PlanNode node, int index) {
    final start = 350 + index * 260;
    final c = context.colors;
    final last = index == widget.nodes.length - 1;
    final week = node.kind == PlanNodeKind.week;
    final marker = switch (node.kind) {
      PlanNodeKind.week => Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == 0 ? c.label : c.surface,
            border: index == 0 ? null : Border.all(color: c.chevron, width: 2),
            boxShadow: [BoxShadow(color: c.surface, spreadRadius: 3)],
          ),
        ),
      PlanNodeKind.exam => Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
          child: const PantasLogo(size: 28),
        ),
      _ => Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.surface,
            shape: BoxShape.circle,
            border: Border.all(color: c.label, width: 1.6),
          ),
          child: CustomPaint(
            size: const Size.square(14),
            painter: _TimelineGlyph(
              clock: node.kind == PlanNodeKind.mock,
              color: c.label,
            ),
          ),
        ),
    };
    final lineWidth = node.reviewOnly ? 3.0 : 2.0;
    final text = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      node.title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.body,
                    ),
                  ),
                  if (node.date != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      node.date!,
                      maxLines: 1,
                      softWrap: false,
                      style: context.type.footnote.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                node.subtitle,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: context.type.subhead.copyWith(color: c.secondaryLabel),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (week && node.target != null)
          Padding(
            padding: const EdgeInsets.only(top: 17),
            child: Icon(PantasIcons.next, size: 14, color: c.chevron),
          )
        else
          const SizedBox(width: 14),
      ],
    );
    final row = SizedBox(
      height: last ? 46 : 66,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!last)
            Positioned(
              left: node.reviewOnly ? 12.5 : 13,
              top: 12,
              child: _entry(
                start + 120,
                140,
                Container(
                  width: lineWidth,
                  height: 66,
                  color: node.reviewOnly ? const Color(0xFF8E8E93) : c.fill,
                ),
                draw: true,
                effectKey: ValueKey('plan-line-$index'),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                height: 24,
                child: OverflowBox(
                  maxWidth: 30,
                  maxHeight: 30,
                  child: Center(
                    child: _entry(
                      start,
                      node.kind == PlanNodeKind.exam ? 420 : 260,
                      marker,
                      pop: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _entry(start + 40, 300, text, x: -6)),
            ],
          ),
        ],
      ),
    );
    return week && node.target != null
        ? InkWell(onTap: () => widget.onWeek(node.target!), child: row)
        : row;
  }
}

/// The calendar and stopwatch glyphs from DP_PlanA (24 unit grid, 2.2 stroke).
class _TimelineGlyph extends CustomPainter {
  const _TimelineGlyph({required this.clock, required this.color});
  final bool clock;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    canvas.scale(unit);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (clock) {
      canvas
        ..drawCircle(const Offset(12, 13), 7.8, paint)
        ..drawPath(
          Path()
            ..moveTo(12, 9)
            ..relativeLineTo(0, 4.3)
            ..relativeLineTo(2.6, 1.6)
            ..moveTo(9.5, 2.8)
            ..relativeLineTo(5, 0),
          paint,
        );
    } else {
      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3.8, 5, 16.4, 15.2),
            const Radius.circular(3),
          ),
          paint,
        )
        ..drawPath(
          Path()
            ..moveTo(3.8, 9.8)
            ..relativeLineTo(16.4, 0)
            ..moveTo(8, 3)
            ..relativeLineTo(0, 4)
            ..moveTo(16, 3)
            ..relativeLineTo(0, 4),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_TimelineGlyph old) =>
      old.clock != clock || old.color != color;
}
