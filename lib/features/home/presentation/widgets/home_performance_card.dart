import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';

class HomePerformanceCard extends StatelessWidget {
  const HomePerformanceCard({
    required this.rows,
    required this.pro,
    required this.onOpen,
    this.overallCorrect,
    this.overallAnswered,
    super.key,
  });
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
