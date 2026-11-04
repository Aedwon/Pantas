import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';

class HomePerformanceCard extends StatelessWidget {
  const HomePerformanceCard({
    required this.rows,
    required this.pro,
    required this.onOpen,
    this.overallCorrect,
    this.overallAnswered,
    this.web = kIsWeb,
    super.key,
  });
  final bool web;
  final int? overallCorrect;
  final int? overallAnswered;
  final List<PerformanceRow> rows;
  final bool pro;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final measured = rows.where((r) => r.answered > 0).toList();
    final answered =
        overallAnswered ?? measured.fold<int>(0, (sum, r) => sum + r.answered);
    if (answered == 0) return const SizedBox.shrink();
    final correct =
        overallCorrect ?? measured.fold<int>(0, (sum, r) => sum + r.correct);
    if (isWideWebLayout(width: MediaQuery.sizeOf(context).width, web: web)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WebText('Your performance', kind: WebTextKind.eyebrow),
          WebCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
                  child: HalfRingGauge(
                    web: true,
                    fraction: correct / answered,
                    label: 'Overall accuracy',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                  child: Column(
                    children: [
                      for (final row in measured)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: row == measured.last
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                      color: context.webTokens.colors.separator,
                                      width: webHairline(context),
                                    ),
                                  ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      row.title,
                                      style: context.webTokens
                                          .style(16, height: 1.3),
                                    ),
                                  ),
                                  // A title that fills its line must still
                                  // leave a gap before the figure.
                                  const SizedBox(width: 12),
                                  Text(
                                    '${(row.accuracy! * 100).round()}%',
                                    style: context.webTokens.style(
                                      16,
                                      weight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 5,
                                child: AccuracyBar(accuracy: row.accuracy!),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Board: a full-width hairline, then one 51 px row with the
                // chevron. The PRO tag is on the Free plan only.
                Container(
                  height: webHairline(context),
                  color: context.webTokens.colors.separator,
                ),
                _SeeAllRow(pro: pro, onPressed: onOpen),
              ],
            ),
          ),
        ],
      );
    }
    return GroupedSection(
      header: 'Your performance',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: HalfRingGauge(
            fraction: correct / answered,
            label: 'Overall accuracy',
          ),
        ),
        for (final row in measured)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.colors.separator,
                  width: .5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(row.title, style: context.type.body)),
                    const SizedBox(width: 8),
                    Text(
                      '${(row.accuracy! * 100).round()}%',
                      style: context.type.emphasized,
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                AccuracyBar(accuracy: row.accuracy!),
              ],
            ),
          ),
        ListRow(
          title: 'See all topics and lessons',
          titleColor: context.colors.accent,
          // Board (HP_Free): the Pro pill follows the label and the chevron
          // stays at the right edge.
          titleWidget: pro
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'See all topics and lessons',
                        style: context.type.body
                            .copyWith(color: context.colors.accent),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _ProPill(),
                  ],
                ),
          onTap: onOpen,
        ),
      ],
    );
  }
}

class _SeeAllRow extends StatelessWidget {
  const _SeeAllRow({required this.pro, required this.onPressed});
  final bool pro;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        animationDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 150),
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 51)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered) || webKeyboardFocus(s)
              ? t.rowHover
              : Colors.transparent,
        ),
        side: WidgetStateProperty.resolveWith(
          (s) => webFocusRing(s, t.colors.accent),
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'See all topics and lessons',
              style: t.style(16, color: t.colors.label, height: 1.3),
            ),
          ),
          if (!pro) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: t.colors.accentTint,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'PRO',
                style: t.style(
                  11,
                  weight: FontWeight.w700,
                  color: t.tintText,
                  spacing: .22,
                ),
              ),
            ),
          ],
          const SizedBox(width: 12),
          const WebChevron(),
        ],
      ),
    );
  }
}

/// Board (HP_Free): 22 px tall pill, 12 px bold label.
class _ProPill extends StatelessWidget {
  const _ProPill();

  @override
  Widget build(BuildContext context) => Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.accentTint,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          'Pro',
          style: context.type.footnote.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: .24,
            height: 1.35,
            color: Theme.of(context).brightness == Brightness.dark
                ? context.colors.label
                : context.colors.accent,
          ),
        ),
      );
}
