import 'package:flutter/material.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

class MockResultsPage extends StatelessWidget {
  const MockResultsPage({
    required this.results,
    required this.proIsActive,
    this.examId,
    this.blueprintName = '',
    this.dateFormatted = '',
    this.forfeited = false,
    this.forfeitedPart,
    this.canReview = true,
    this.reviewUntil,
    this.proPaused = false,
    this.fromRecord = false,
    this.onReviewTap,
    this.onDone,
    this.onSeePro,
    this.onFullRecord,
    this.pastResults = const [],
    this.disableAnimations = false,
    super.key,
  });
  final MockResults results;
  final bool proIsActive;
  final String? examId;
  final String blueprintName;
  final String dateFormatted;
  final bool forfeited;
  final int? forfeitedPart;
  final bool canReview;
  final DateTime? reviewUntil;
  final bool proPaused;
  final bool fromRecord;
  final VoidCallback? onReviewTap;
  final VoidCallback? onDone;
  final VoidCallback? onSeePro;
  final VoidCallback? onFullRecord;
  final List<MockPastPoint> pastResults;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final wrong = results.sections.fold(0, (n, s) => n + (s.wrong ?? 0));
    final deduction = wrong / 4;
    final deductionLabel = deduction == deduction.roundToDouble()
        ? deduction.toStringAsFixed(0)
        : deduction.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
    final caption = examId == 'exam_upcat'
        ? '${results.scoreRaw} correct, minus $deductionLabel wrong'
        : '${results.scoreRaw} of ${results.scoreTotal} correct answers';
    final body = Scaffold(
      backgroundColor: context.colors.background,
      bottomNavigationBar: fromRecord
          ? null
          : SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 14, 16, 26),
              child: PantasButton(label: 'Done', onPressed: onDone),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: fromRecord
                  ? TextButton.icon(
                      onPressed: onDone,
                      icon: Icon(PantasIcons.back, size: 24),
                      label: Text(
                        'Your record',
                        style: context.type.body
                            .copyWith(color: context.colors.accent),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Close',
                      onPressed: onDone,
                      icon: Icon(
                        PantasIcons.close,
                        color: context.colors.secondaryLabel,
                        size: 22,
                      ),
                    ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              blueprintName,
                              style:
                                  context.type.pageTitle.copyWith(fontSize: 22),
                            ),
                            if (forfeited)
                              Text(
                                'Not finished',
                                style: context.type.footnote,
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFormatted,
                          style: context.type.subhead.copyWith(
                            color: context.colors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: HalfRingGauge.mock(
                      fraction: results.percent / 100,
                      label: caption,
                    ),
                  ),
                  if (forfeited && forfeitedPart != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'With strict mode enabled, you left the app during '
                        'Part $forfeitedPart, so the mock ended there. '
                        'Everything you answered before then is scored.',
                        style: context.type.subhead.copyWith(
                          color: context.colors.secondaryLabel,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  GroupedSection(
                    header: 'PERFORMANCE BREAKDOWN',
                    children: [
                      for (var i = 0; i < results.sections.length; i++)
                        _Breakdown(
                          section: results.sections[i],
                          divider: i < results.sections.length - 1,
                        ),
                    ],
                  ),
                  if (!forfeited && pastResults.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    GroupedSection(
                      header: 'VERSUS PAST RESULTS',
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                          child: MockPastChart(
                            points: pastResults,
                            currentPercent: results.percent,
                            currentLabel: fromRecord ? dateFormatted : 'Today',
                          ),
                        ),
                        if (onFullRecord != null)
                          ListRow(
                            title: 'See full record',
                            titleColor: context.colors.accent,
                            onTap: onFullRecord,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 22),
                  if (canReview) ...[
                    GroupedSection(
                      children: [
                        ListRow(
                          title: 'See all ${results.scoreTotal} questions',
                          onTap: onReviewTap,
                          subtitle:
                              fromRecord && !proIsActive && reviewUntil != null
                                  ? 'Open until '
                                      '${PantasDates.withWeekday(reviewUntil!)}'
                                  : null,
                        ),
                      ],
                    ),
                    if (!fromRecord && !proIsActive && reviewUntil != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
                        child: Text(
                          'On Free, you can go through these until your next '
                          'mock opens on '
                          '${PantasDates.withWeekday(reviewUntil!)}.',
                          style: context.type.footnote,
                        ),
                      ),
                  ] else if (proPaused)
                    const ProPausedLine()
                  else
                    GroupedSection(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Go through all ${results.scoreTotal} '
                                'questions '
                                'again with Pro.',
                                style: context.type.body,
                              ),
                              if (onSeePro != null) ...[
                                const SizedBox(height: 12),
                                PantasButton(
                                  label: 'See Pro',
                                  variant: PantasButtonVariant.secondary,
                                  onPressed: onSeePro,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return disableAnimations
        ? MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: body,
          )
        : body;
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.section, required this.divider});
  final SectionResult section;
  final bool divider;
  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    final values = Wrap(
      spacing: 14,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '${section.correct} / ${section.total}',
          style: context.type.subhead
              .copyWith(color: context.colors.secondaryLabel),
        ),
        Text(
          '${(section.accuracy * 100).round()}%',
          style: context.type.emphasized.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
    final title = Text(
      section.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.type.body,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(width: .5, color: context.colors.separator),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (large) ...[title, values] else
            Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: 10),
                values,
              ],
            ),
          const SizedBox(height: 9),
          AccuracyBar(accuracy: section.accuracy),
        ],
      ),
    );
  }
}

class MockPastPoint {
  const MockPastPoint({required this.percent, required this.label});
  final double percent;
  final String label;
}

class MockPastChart extends StatelessWidget {
  const MockPastChart({
    required this.points,
    required this.currentPercent,
    required this.currentLabel,
    super.key,
  });
  final List<MockPastPoint> points;
  final double currentPercent;
  final String currentLabel;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 132,
        child: CustomPaint(
          painter: _PastPainter(
            points: [
              ...points.skip(points.length > 2 ? points.length - 2 : 0),
              MockPastPoint(percent: currentPercent, label: currentLabel),
            ],
            label: context.colors.secondaryLabel,
            accent: context.colors.accent,
            previous: context.colors.tertiaryLabel,
            separator: context.colors.separator,
          ),
        ),
      );
}

class _PastPainter extends CustomPainter {
  _PastPainter({
    required this.points,
    required this.label,
    required this.accent,
    required this.previous,
    required this.separator,
  });
  final List<MockPastPoint> points;
  final Color label;
  final Color accent;
  final Color previous;
  final Color separator;
  void text(
    Canvas c,
    String value,
    Offset at, {
    Color? color,
    bool strong = false,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'Geist',
          fontSize: strong ? 12 : 11,
          fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
          color: color ?? label,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    p.paint(c, at - Offset(p.width / 2, 0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final all = points.map((p) => p.percent).toList();
    final min = (all.reduce((a, b) => a < b ? a : b) / 20).floor() * 20.0;
    final max = (all.reduce((a, b) => a > b ? a : b) / 20).ceil() * 20.0;
    final low = min == max ? min - 20 : min;
    final high = min == max ? max + 20 : max;
    for (var i = 0; i < 3; i++) {
      final y = 106 - i * 46.0;
      canvas.drawLine(
        Offset(34, y),
        Offset(size.width, y),
        Paint()..color = separator,
      );
      text(
        canvas,
        (low + (high - low) * i / 2).toStringAsFixed(0),
        Offset(15, y - 5),
      );
    }
    Offset? last;
    for (var i = 0; i < points.length; i++) {
      final x = 74 + (size.width - 98) * i / (points.length - 1);
      final y = 106 - (points[i].percent - low) / (high - low) * 92;
      final current = i == points.length - 1;
      final point = Offset(x, y);
      if (last != null) {
        canvas.drawLine(
          last,
          point,
          Paint()
            ..color = current ? accent : previous
            ..strokeWidth = current ? 2.5 : 2,
        );
      }
      canvas.drawCircle(
        point,
        current ? 7 : 5,
        Paint()..color = current ? accent : previous,
      );
      text(
        canvas,
        points[i].label,
        Offset(x, 116),
        color: current ? accent : label,
      );
      if (current) {
        text(
          canvas,
          '${points[i].percent.toStringAsFixed(1)}%',
          Offset(x, y - 23),
          color: accent,
          strong: true,
        );
      }
      last = point;
    }
  }

  @override
  bool shouldRepaint(_PastPainter old) => true;
}
