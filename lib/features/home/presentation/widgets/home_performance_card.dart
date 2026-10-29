import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
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
          const SizedBox(height: 9),
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
                                      width: .5,
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
                                      style: context.webTokens.style(16),
                                    ),
                                  ),
                                  Text(
                                    '${(row.accuracy! * 100).round()}%',
                                    style: context.webTokens
                                        .style(16, weight: FontWeight.w600),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: WebTextLink(
                          label: 'See all topics and lessons',
                          onPressed: onOpen,
                        ),
                      ),
                      if (!pro)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: context.webTokens.colors.accentTint,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'PRO',
                            style: context.webTokens.style(
                              11,
                              weight: FontWeight.w700,
                              color: context.webTokens.tintText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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
          trailingWidget: pro ? null : const ProTag(),
          onTap: onOpen,
        ),
      ],
    );
  }
}
