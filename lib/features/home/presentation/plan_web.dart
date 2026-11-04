import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';

/// The sidebar shell owns the outer padding and width.
class PlanWebFrame extends StatelessWidget {
  const PlanWebFrame({
    required this.title,
    required this.onBack,
    required this.child,
    this.backLabel = 'Home',
    this.subtitle,
    super.key,
  });
  final String title;
  final String backLabel;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget child;
  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): onBack},
        child: Focus(
          autofocus: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WebBackLink(label: backLabel, onPressed: onBack),
                const SizedBox(height: 6),
                WebText(title, kind: WebTextKind.h1),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  WebText(subtitle!, kind: WebTextKind.lead),
                ],
                const SizedBox(height: 26),
                child,
              ],
            ),
          ),
        ),
      );
}

/// The board's two columns: flex 1.3 from 460 px and flex 1 from 380 px, with
/// a 28 px gap. Free space is shared by the flex factors after the bases.
class PlanSplit extends StatelessWidget {
  const PlanSplit({
    required this.left,
    required this.right,
    this.stillLeft = false,
    super.key,
  });
  final Widget left;

  /// The list beside an open pane does not rise again.
  final bool stillLeft;
  final Widget right;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) {
          const gap = 28.0;
          final free = c.maxWidth - 460 - 380 - gap;
          // One shape at every width keeps the columns mounted on a resize,
          // so their entrances do not replay.
          final leftWidth = !c.hasBoundedWidth
              ? null
              : free < 0
                  ? (c.maxWidth - gap) * 13 / 23
                  : 460 + free * 1.3 / 2.3;
          final shownLeft = stillLeft ? PlanEntryStill(child: left) : left;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leftWidth == null)
                Expanded(flex: 13, child: shownLeft)
              else
                SizedBox(width: leftWidth, child: shownLeft),
              const SizedBox(width: gap),
              if (leftWidth == null)
                Expanded(flex: 10, child: right)
              else
                Expanded(child: right),
            ],
          );
        },
      );
}

/// The board's exam day glyph: a 26 by 28 calendar with the day and month.
class PlanExamCalendar extends StatelessWidget {
  const PlanExamCalendar({required this.day, super.key});
  final DateTime day;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return ExcludeSemantics(
      child: Container(
        width: 26,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: t.colors.label, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${day.day}',
              style: t.style(12, weight: FontWeight.w700, height: 1),
            ),
            Text(
              months[day.month - 1],
              style: t.style(
                7,
                weight: FontWeight.w700,
                color: t.colors.secondaryLabel,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanWebColumns extends StatelessWidget {
  const PlanWebColumns({
    required this.page,
    this.pane,
    this.selectedWeek,
    this.onHistory,
    super.key,
  });
  final PlanPage page;
  final Widget? pane;
  final String? selectedWeek;
  final VoidCallback? onHistory;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final nodes = page.pro
        ? page.nodes
        : page.nodes.where((n) => n.kind == PlanNodeKind.exam).toList();
    // The free gate shows a still list on the phone, so wide stays still too.
    final animate = page.pro;
    Widget rise(int i, Widget row) => animate
        ? PlanEntry(start: 350 + i * 260 + 40, duration: 300, x: -6, child: row)
        : row;
    Widget pop(int i, PlanNodeKind kind, Widget marker) => animate
        ? PlanEntry(
            start: 350 + i * 260,
            duration: kind == PlanNodeKind.exam ? 420 : 260,
            pop: true,
            child: marker,
          )
        : marker;
    final historyStart =
        nodes.isEmpty ? 350 : 350 + (nodes.length - 1) * 260 + 270;
    // The approved detail pane motion: it fades and rises 8 px beside the list.
    final shownPane = pane;
    final paneEntry = shownPane == null
        ? null
        : PlanEntry(
            key: ValueKey(shownPane.runtimeType),
            start: 0,
            duration: 240,
            y: 8,
            child: shownPane,
          );
    return PlanWebFrame(
      title: 'Your plan',
      onBack: page.onBack,
      subtitle: page.subtitle,
      child: PlanSplit(
        stillLeft: pane != null,
        left: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The phone page's delays and curves, so wide rises with it.
            PlanEntry(
              start: 0,
              duration: 450,
              y: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WebText('Today', kind: WebTextKind.eyebrow),
                  WebCard(
                    child: WebRow(
                      boardMetrics: true,
                      title: '${page.done} of ${page.total} done',
                      subtitle: page.done == page.total
                          ? null
                          : 'Reviews and new questions left',
                      leading: ProgressRing(
                        fraction: page.total == 0 ? 0 : page.done / page.total,
                        size: 26,
                        emptyTrackColor:
                            t.dark ? null : const Color(0xFFD1D1D6),
                      ),
                      trailing: const WebChevron(),
                      divider: false,
                      onPressed: page.onToday,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const PlanEntry(
              start: 100,
              duration: 450,
              y: 14,
              child: WebText('Coming up', kind: WebTextKind.eyebrow),
            ),
            WebCard(
              child: Column(
                children: [
                  for (var i = 0; i < nodes.length; i++)
                    rise(
                      i,
                      WebRow(
                        boardMetrics: true,
                        title: nodes[i].title,
                        titleStyle: nodes[i].kind == PlanNodeKind.exam
                            ? t.style(17, weight: FontWeight.w600, height: 1.3)
                            : null,
                        subtitle: nodes[i].subtitle,
                        value: nodes[i].date,
                        selected: selectedWeek != null &&
                            nodes[i].target == selectedWeek,
                        leading: pop(
                          i,
                          nodes[i].kind,
                          switch (nodes[i].kind) {
                            PlanNodeKind.exam when nodes[i].day != null =>
                              PlanExamCalendar(day: nodes[i].day!),
                            _ => Icon(
                                switch (nodes[i].kind) {
                                  PlanNodeKind.week => Icons.circle_outlined,
                                  PlanNodeKind.review => Icons.outlined_flag,
                                  PlanNodeKind.mock => Icons.schedule,
                                  PlanNodeKind.exam =>
                                    Icons.calendar_today_outlined,
                                },
                                size: 26,
                                color: nodes[i].kind == PlanNodeKind.week
                                    ? (t.dark
                                        ? t.colors.secondaryLabel
                                        : const Color(0xFFD1D1D6))
                                    : t.colors.secondaryLabel,
                              ),
                          },
                        ),
                        trailing: nodes[i].kind == PlanNodeKind.week
                            ? const WebChevron()
                            : null,
                        divider: i < nodes.length - 1,
                        onPressed: nodes[i].kind == PlanNodeKind.week &&
                                nodes[i].target != null
                            ? () => page.onWeek(nodes[i].target!)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            if (page.pro)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text('Later weeks show topics only.', style: t.sm),
              ),
          ],
        ),
        right: paneEntry ??
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (page.pro)
                  PlanEntry(
                    start: historyStart,
                    duration: 500,
                    y: 14,
                    child: const WebText('History', kind: WebTextKind.eyebrow),
                  )
                else
                  const WebText('History', kind: WebTextKind.eyebrow),
                if (page.pro)
                  PlanWebHistory(
                    entranceStart: historyStart + 200,
                    entries: page.history.take(5).toList(),
                    onMore: onHistory,
                    hasMore: onHistory != null,
                    moreInsideCard: true,
                  )
                else
                  WebCard(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'See every week up to your exam, '
                          'and every time your plan adjusts.',
                          style: t.style(17, height: 1.45),
                        ),
                        const SizedBox(height: 14),
                        if (page.paused)
                          const ProPausedLine()
                        else
                          Align(
                            alignment: Alignment.centerRight,
                            child: WebButton(
                              label: 'Unlock with Pro',
                              onPressed: page.onPro,
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

class PlanWebHistory extends StatelessWidget {
  const PlanWebHistory({
    required this.entries,
    this.hasMore = false,
    this.loading = false,
    this.onMore,
    this.error,
    this.moreInsideCard = false,
    this.entranceStart,
    super.key,
  });

  /// When set, the rows rise in one after another from this many
  /// milliseconds, like the phone's history.
  final int? entranceStart;

  /// Plan's card ends with a See more row (board `PL_Plan`); the full History
  /// page keeps the link below the card.
  final bool moreInsideCard;
  final List<PlanHistoryEntry> entries;
  final bool hasMore;
  final bool loading;
  final VoidCallback? onMore;
  final Widget? error;
  Widget _historyEntry(int i, Widget row) => entranceStart == null
      ? row
      : PlanEntry(
          start: entranceStart! + i * 80,
          duration: 500,
          y: 8,
          child: row,
        );
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final hairline = webHairline(context);
    final inside = moreInsideCard && hasMore;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < entries.length; i++)
                _historyEntry(
                  i,
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: i < entries.length - 1
                          ? Border(
                              bottom: BorderSide(
                                color: t.colors.separator,
                                width: hairline,
                              ),
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entries[i].date,
                          style: t.sm.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(entries[i].text, style: t.style(16, height: 1.45)),
                      ],
                    ),
                  ),
                ),
              if (inside)
                InkWell(
                  onTap: loading ? null : onMore,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: t.colors.separator,
                          width: hairline,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            loading ? 'Loading' : 'See more',
                            style: t.style(
                              16,
                              weight: FontWeight.w600,
                              color: t.colors.accent,
                            ),
                          ),
                        ),
                        const WebChevron(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!inside) const SizedBox(height: 18),
        if (inside)
          const SizedBox.shrink()
        else if (hasMore)
          Align(
            child: WebTextLink(
              label: loading ? 'Loading' : 'See more',
              onPressed: loading ? () {} : onMore ?? () {},
            ),
          )
        else
          Text("That's everything since you started.", style: t.sub),
        if (error != null) error!,
      ],
    );
  }
}

/// The board's `.ebr` header over a pane: an eyebrow (a link when [onLabel] is
/// set) and a 32 px close button that rises 8 px above the row.
class PlanPaneHeader extends StatelessWidget {
  const PlanPaneHeader({
    required this.label,
    required this.onClose,
    this.onLabel,
    super.key,
  });
  final String label;
  final VoidCallback onClose;
  final VoidCallback? onLabel;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final text = Text(
      onLabel == null ? label.toUpperCase() : label,
      style: onLabel == null ? t.eb : t.eb.copyWith(color: t.colors.accent),
    );
    return SizedBox(
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 4,
            bottom: 9,
            child: onLabel == null
                ? text
                : MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(onTap: onLabel, child: text),
                  ),
          ),
          Positioned(
            right: 0,
            top: -8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const WebKeyHint('Esc'),
                const SizedBox(width: 6),
                SizedBox.square(
                  dimension: 32,
                  child: IconButton(
                    onPressed: onClose,
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      foregroundColor: t.colors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
