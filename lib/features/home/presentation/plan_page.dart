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
  });
  final PlanNodeKind kind;
  final String title;
  final String subtitle;
  final String? date;
  final String? target;
  final bool reviewOnly;
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
        child:
            Text(text, style: context.type.emphasized.copyWith(fontSize: 20)),
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
              for (var i = 0; i < widget.nodes.length; i++)
                _timelineRow(widget.nodes[i], i),
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

  Widget _timelineRow(PlanNode node, int index) {
    final start = 350 + index * 260;
    final icon = switch (node.kind) {
      PlanNodeKind.week => Icons.circle,
      PlanNodeKind.review => PantasIcons.studyTab,
      PlanNodeKind.mock => PantasIcons.timer,
      PlanNodeKind.exam => PantasIcons.exam,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          height: 76,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              if (index < widget.nodes.length - 1)
                Positioned(
                  top: 12,
                  bottom: -12,
                  child: _entry(
                    start + 120,
                    140,
                    Container(
                      width: node.reviewOnly ? 2 : 1.5,
                      color: node.reviewOnly
                          ? context.colors.label
                          : context.colors.separator,
                    ),
                    draw: true,
                    effectKey: ValueKey('plan-line-$index'),
                  ),
                ),
              Positioned(
                top: 14,
                child: _entry(
                  start,
                  node.kind == PlanNodeKind.exam ? 420 : 260,
                  node.kind == PlanNodeKind.week
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == 0
                                ? context.colors.accent
                                : Colors.transparent,
                            border: Border.all(
                              color: index == 0
                                  ? context.colors.accent
                                  : context.colors.secondaryLabel,
                              width: 1.5,
                            ),
                          ),
                        )
                      : node.kind == PlanNodeKind.exam
                          ? const PantasLogo(size: 28, monochrome: true)
                          : Icon(
                              icon,
                              size: 22,
                              color: context.colors.secondaryLabel,
                            ),
                  pop: true,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _entry(
            start + 40,
            300,
            ListRow(
              title: node.title,
              subtitle: node.subtitle,
              titleWidget: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    node.title,
                    style: node.kind == PlanNodeKind.exam
                        ? context.type.emphasized
                        : context.type.body,
                  ),
                  if (node.date != null)
                    Text(node.date!, style: context.type.footnote),
                ],
              ),
              minimumHeight: 76,
              contentPadding:
                  const EdgeInsets.only(right: 16, top: 10, bottom: 10),
              variant: node.kind == PlanNodeKind.week
                  ? ListRowVariant.navigation
                  : ListRowVariant.value,
              onTap: node.kind == PlanNodeKind.week && node.target != null
                  ? () => widget.onWeek(node.target!)
                  : null,
            ),
            x: -6,
          ),
        ),
      ],
    );
  }
}
