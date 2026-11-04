import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
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

/// The plan's staggered entrance: the phone page and the wide columns share
/// it so both rise, draw and pop on the same delays and curves.
/// Stops every [PlanEntry] under it. The plan beside an open pane is the plan
/// already on screen, so it does not rise again.
class PlanEntryStill extends InheritedWidget {
  const PlanEntryStill({required super.child, super.key});

  @override
  bool updateShouldNotify(PlanEntryStill oldWidget) => false;
}

class PlanEntry extends StatelessWidget {
  const PlanEntry({
    required this.start,
    required this.duration,
    required this.child,
    this.x = 0,
    this.y = 0,
    this.draw = false,
    this.pop = false,
    this.effectKey,
    super.key,
  });

  /// Milliseconds to wait before the motion begins.
  final int start;
  final int duration;
  final Widget child;
  final double x;
  final double y;
  final bool draw;
  final bool pop;
  final Key? effectKey;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context) ||
        context.dependOnInheritedWidgetOfExactType<PlanEntryStill>() != null) {
      return child;
    }
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
  }) =>
      PlanEntry(
        start: start,
        duration: duration,
        x: x,
        y: y,
        draw: draw,
        pop: pop,
        effectKey: effectKey,
        child: child,
      );

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
    final accentHex = context.colors.accent
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2);
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
              // Board (DP_PlanA): 14/16 padding, a 34 px dark ring, a 17 px
              // semibold title and the line 1 px under it.
              ListRow(
                title: '${widget.done} of ${widget.total} done',
                titleWidget: Text(
                  '${widget.done} of ${widget.total} done',
                  style:
                      context.type.body.copyWith(fontWeight: FontWeight.w600),
                ),
                footer: widget.done == widget.total
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          'Reviews and new questions left',
                          style: context.type.footnote,
                        ),
                      ),
                leading: _PlanDoneRing(
                  fraction: widget.total == 0 ? 0 : widget.done / widget.total,
                ),
                leadingGap: 14,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  _HistoryRow(
                    date: visible[i].date,
                    text: visible[i].text,
                    expanded: _expanded.contains(visible[i].id),
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
                // Board (DP_History): regular weight, 17 px, chevron after.
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(49),
                    foregroundColor: context.colors.accent,
                  ),
                  onPressed: widget.loadingMore
                      ? null
                      : () => setState(() {
                            _shown += 10;
                            if (_shown > widget.history.length) {
                              widget.onMore?.call();
                            }
                          }),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See more',
                        style: context.type.body.copyWith(
                          color: context.colors.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      RotatedBox(
                        quarterTurns: 1,
                        child: Icon(
                          PantasIcons.next,
                          size: 13,
                          color: context.colors.accent,
                        ),
                      ),
                    ],
                  ),
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
          // Board (DP_PlanFree): a gray placeholder timeline of eight rows and
          // the exam day, three gray history rows and one Pro card.
          GroupedSection(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 16, 12),
                child: Column(
                  children: [
                    for (final (index, row) in _freeRows.indexed)
                      _PlaceholderRow(
                        icon: index >= 6 ? (clock: index == 7) : null,
                        top: row.$1,
                        bottom: row.$2,
                      ),
                    if (last != null) _freeExamRow(last),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _heading('History'),
          GroupedSection(
            children: [
              for (final (index, row) in const [
                (56.0, 220.0),
                (56.0, 180.0),
                (56.0, 240.0),
              ].indexed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    border: index < 2
                        ? Border(
                            bottom: BorderSide(
                              color: context.colors.separator,
                              width: .5,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      _Bar(width: row.$1, height: 12),
                      const SizedBox(width: 12),
                      _Bar(width: row.$2, height: 12),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          if (widget.paused)
            const ProPausedLine()
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: ExcludeSemantics(
                            child: SvgPicture.string(
                              '<svg viewBox="0 0 24 24" fill="none" '
                              'stroke="#$accentHex" '
                              'stroke-width="2" stroke-linecap="round" '
                              'stroke-linejoin="round"><path d="M11 3.5 12.6 '
                              '8.4 17.5 10 12.6 11.6 11 16.5 9.4 11.6 4.5 10l '
                              '4.9-1.6z"/><path d="M18 15.5l.7 2 2 .7-2 .7-.7 '
                              '2-.7-2-2-.7 2-.7z"/></svg>',
                              width: 22,
                              height: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'See every week up to your exam, and every time '
                            'your plan adjusts.',
                            style: context.type.body.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    PantasButton(
                      label: 'Unlock with Pro',
                      onPressed: widget.onPro,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  static const _freeRows = <(double, double)>[
    (120, 220),
    (90, 180),
    (140, 240),
    (110, 200),
    (130, 160),
    (80, 120),
    (150, 200),
    (120, 140),
  ];

  /// DP_PlanFree: the exam day closes the gray timeline.
  Widget _freeExamRow(PlanNode node) {
    final c = context.colors;
    return SizedBox(
      height: 46,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            height: 24,
            child: OverflowBox(
              maxWidth: 30,
              maxHeight: 30,
              child: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: c.surface, shape: BoxShape.circle),
                  child: const PantasLogo(size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                        overflow: TextOverflow.ellipsis,
                        style: context.type.body,
                      ),
                    ),
                    if (node.date != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        node.date!,
                        maxLines: 1,
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
                  overflow: TextOverflow.ellipsis,
                  style: context.type.subhead.copyWith(color: c.secondaryLabel),
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
        ],
      ),
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

/// Board (DP_PlanA): a 34 px ring, 3.4 px round stroke, dark on a light track.
class _PlanDoneRing extends StatelessWidget {
  const _PlanDoneRing({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(
          size: const Size.square(34),
          painter: _PlanDoneRingPainter(
            fraction: fraction,
            track: context.colors.fill,
            fill: context.colors.label,
          ),
        ),
      );
}

class _PlanDoneRingPainter extends CustomPainter {
  const _PlanDoneRingPainter({
    required this.fraction,
    required this.track,
    required this.fill,
  });
  final double fraction;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const radius = 15.3;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint..color = track);
    if (fraction <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0, 1),
      false,
      paint..color = fill,
    );
  }

  @override
  bool shouldRepaint(_PlanDoneRingPainter old) =>
      old.fraction != fraction || old.track != track || old.fill != fill;
}

/// Board (DP_History): a 74 px date column, the text on one line and a small
/// down chevron that expands it.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.date,
    required this.text,
    required this.expanded,
    required this.divider,
    required this.onTap,
  });
  final String date;
  final String text;
  final bool expanded;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MergeSemantics(
      child: Semantics(
        expanded: expanded,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: divider
                  ? Border(bottom: BorderSide(color: c.separator, width: .5))
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 74,
                  child: Text(
                    date,
                    maxLines: 1,
                    style: context.type.subhead.copyWith(
                      fontWeight: FontWeight.w500,
                      color: c.secondaryLabel,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    maxLines: expanded ? null : 1,
                    overflow: expanded ? null : TextOverflow.ellipsis,
                    style: context.type.subhead.copyWith(color: c.label),
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: RotatedBox(
                    quarterTurns: expanded ? 3 : 1,
                    child: Icon(PantasIcons.next, size: 13, color: c.chevron),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.colors.fill,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
}

/// A gray timeline row of the Free plan. A set `icon` draws the calendar or
/// stopwatch ring with the thicker line, as on the board.
class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow({
    required this.top,
    required this.bottom,
    this.icon,
  });
  final double top;
  final double bottom;
  final ({bool clock})? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 66,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: icon != null ? 12.5 : 13,
            top: 12,
            child: Container(
              width: icon != null ? 3 : 2,
              height: 66,
              color: c.separator,
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
                    child: icon == null
                        ? Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: c.separator,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: c.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: c.separator,
                                width: 1.6,
                              ),
                            ),
                            child: CustomPaint(
                              size: const Size.square(14),
                              painter: _TimelineGlyph(
                                clock: icon!.clock,
                                color: c.chevron,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bar(width: top, height: 12),
                      const SizedBox(height: 8),
                      _Bar(width: bottom, height: 10),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 22),
            ],
          ),
        ],
      ),
    );
  }
}
