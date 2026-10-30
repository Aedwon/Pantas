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
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.chevron_left, size: 20),
                    label: Text(backLabel),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 40),
                      textStyle: context.webTokens.style(17),
                    ),
                  ),
                ),
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
    return PlanWebFrame(
      title: 'Your plan',
      onBack: page.onBack,
      subtitle: page.subtitle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 13,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WebText('Today', kind: WebTextKind.eyebrow),
                WebCard(
                  child: WebRow(
                    title: '${page.done} of ${page.total} done',
                    titleStyle: t.style(17, weight: FontWeight.w600),
                    subtitle: page.done == page.total
                        ? null
                        : 'Reviews and new questions left',
                    leading: ProgressRing(
                      fraction: page.total == 0 ? 0 : page.done / page.total,
                      size: 26,
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: t.colors.chevron,
                    ),
                    divider: false,
                    onPressed: page.onToday,
                  ),
                ),
                const SizedBox(height: 28),
                const WebText('Coming up', kind: WebTextKind.eyebrow),
                WebCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < nodes.length; i++)
                        WebRow(
                          title: nodes[i].title,
                          subtitle: nodes[i].subtitle,
                          value: nodes[i].date,
                          selected: selectedWeek != null &&
                              nodes[i].target == selectedWeek,
                          leading: Icon(
                            switch (nodes[i].kind) {
                              PlanNodeKind.week => Icons.circle_outlined,
                              PlanNodeKind.review => Icons.outlined_flag,
                              PlanNodeKind.mock => Icons.schedule,
                              PlanNodeKind.exam =>
                                Icons.calendar_today_outlined,
                            },
                            size: 26,
                            color: t.colors.secondaryLabel,
                          ),
                          trailing: nodes[i].kind == PlanNodeKind.week
                              ? Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: t.colors.chevron,
                                )
                              : null,
                          divider: i < nodes.length - 1,
                          onPressed: nodes[i].kind == PlanNodeKind.week &&
                                  nodes[i].target != null
                              ? () => page.onWeek(nodes[i].target!)
                              : null,
                        ),
                    ],
                  ),
                ),
                if (page.pro)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      'Later weeks show topics only.',
                      style: t.sm,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            flex: 10,
            child: pane ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WebText('History', kind: WebTextKind.eyebrow),
                    if (page.pro)
                      PlanWebHistory(
                        entries: page.history.take(5).toList(),
                        onMore: onHistory,
                        hasMore: onHistory != null,
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
        ],
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
    super.key,
  });
  final List<PlanHistoryEntry> entries;
  final bool hasMore;
  final bool loading;
  final VoidCallback? onMore;
  final Widget? error;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < entries.length; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: i < entries.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: t.colors.separator,
                              width: .5,
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
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (hasMore)
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
