import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_chart.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/score_breakdown_row.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_finale_motion.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/web_finale_tracks.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/web_mock_finale.dart';

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
    this.finaleClock,
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
  final Animation<double>? finaleClock;

  @override
  Widget build(BuildContext context) => finaleClock == null
      ? _build(context, null)
      : AnimatedBuilder(
          animation: finaleClock!,
          builder: (context, _) => _build(context, finaleClock!.value),
        );

  Widget _build(BuildContext context, double? time) {
    final wrong = results.sections.fold(0, (n, s) => n + (s.wrong ?? 0));
    final deduction = wrong / 4;
    final deductionLabel = deduction == deduction.roundToDouble()
        ? deduction.toStringAsFixed(0)
        : deduction.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
    final caption = examId == 'exam_upcat'
        ? '${results.scoreRaw} correct, minus $deductionLabel wrong'
        : '${results.scoreRaw} of ${results.scoreTotal} correct answers';
    if (context.wideWeb) return _wide(context, caption);
    final body = Scaffold(
      backgroundColor: context.colors.background,
      bottomNavigationBar: fromRecord
          ? null
          : _phase(
              time,
              576,
              SafeArea(
                top: false,
                minimum: EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s14,
                  PantasSpace.s16,
                  time == null ? PantasSpace.s28 : PantasSpace.s32,
                ),
                child: PantasButton(label: 'Done', onPressed: onDone),
              ),
            ),
      body: SafeArea(
        top: time == null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (time == null)
              Align(
                alignment: Alignment.centerLeft,
                child: fromRecord
                    ? Padding(
                        padding: const EdgeInsets.only(left: PantasSpace.s8),
                        child: WebBackLink(
                          label: 'Your record',
                          onPressed: onDone ?? () {},
                          nudge: false,
                        ),
                      )
                    // Board (MK_Results): the X sits at x 19, y 17, in #8E8E93.
                    : Padding(
                        padding: const EdgeInsets.only(
                          left: PantasSpace.s6,
                          top: PantasSpace.s4,
                        ),
                        child: PantasIconButton(
                          tooltip: 'Close',
                          glyph: PantasIcons.close,
                          onPressed: onDone,
                        ),
                      ),
              ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  time == null ? PantasSpace.s6 : PantasSpace.s56,
                  PantasSpace.s16,
                  PantasSpace.s24,
                ),
                children: [
                  _phase(
                    time,
                    562,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PantasSpace.s4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                blueprintName,
                                style: context.type.sectionHero,
                              ),
                              if (forfeited)
                                Text(
                                  'Not finished',
                                  style: context.type.footnote,
                                ),
                            ],
                          ),
                          SizedBox(
                            height:
                                time == null ? PantasSpace.s4 : PantasSpace.s2,
                          ),
                          Text(
                            dateFormatted,
                            style: context.type.subhead.copyWith(
                              color: context.colors.secondaryLabel,
                              height: time == null ? null : 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: time == null ? 22 : 10),
                  _gauge(context, time, caption),
                  if (forfeited && forfeitedPart != null) ...[
                    const SizedBox(height: PantasSpace.s12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PantasSpace.s4,
                      ),
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
                  const SizedBox(height: PantasSpace.s24),
                  _phase(
                    time,
                    567,
                    GroupedSection(
                      header: 'PERFORMANCE BREAKDOWN',
                      children: [
                        for (var i = 0; i < results.sections.length; i++)
                          _Breakdown(
                            section: results.sections[i],
                            animatedAccuracy: time == null
                                ? null
                                : results.sections[i].accuracy *
                                    cseFinaleInterval(
                                      time,
                                      6100 + i * 120,
                                      6850 + i * 120,
                                      PantasCurves.gauge,
                                    ),
                            divider: i < results.sections.length - 1,
                          ),
                      ],
                    ),
                  ),
                  if (!forfeited && pastResults.isNotEmpty) ...[
                    const SizedBox(height: PantasSpace.s24),
                    _phase(
                      time,
                      572,
                      GroupedSection(
                        header: 'VERSUS PAST RESULTS',
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              PantasSpace.s16,
                              PantasSpace.s14,
                              PantasSpace.s16,
                              PantasSpace.s6,
                            ),
                            child: mockPastChart(
                              pastResults,
                              time: time,
                              currentPercent: results.percent,
                              currentLabel:
                                  fromRecord ? dateFormatted : 'Today',
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
                    ),
                  ],
                  const SizedBox(height: PantasSpace.s24),
                  _phase(time, 573, _reviewControls(context)),
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

  Widget _wide(BuildContext context, String caption) {
    final t = context.webTokens;
    final time = finaleClock?.value;
    final arc = time == null
        ? 1.0
        : ((395.8 - sampleWebFinale('k-arc', time).value) / 270.7)
            .clamp(0.0, 1.0);
    final odometer = time == null
        ? 1.0
        : (sampleWebFinale('k-odo', time).offset.dy / -2944).clamp(0.0, 1.0);
    double? barAccuracy(int i) => time == null
        ? null
        : results.sections[i].accuracy *
            sampleWebFinale('k-bar${i.clamp(0, 3)}', time).value /
            100;
    final until =
        reviewUntil == null ? null : PantasDates.withWeekday(reviewUntil!);
    final total = results.scoreTotal;
    return CallbackShortcuts(
      bindings: {
        if (onDone != null)
          const SingleActivator(LogicalKeyboardKey.escape): onDone!,
      },
      child: Focus(
        onKeyEvent: onDone == null ? null : enterKeyHandler(onDone!),
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              if (fromRecord)
                // Board (MK_PastPro): the 64 px header every full-screen page
                // has, with the link's chevron 6 px into the padding.
                WebTopBar(
                  leading: Transform.translate(
                    offset: const Offset(-6, 0),
                    child: WebBackLink(
                      label: 'Your record',
                      onPressed: onDone ?? () {},
                      nudge: false,
                    ),
                  ),
                )
              else
                WebTopBar(
                  leading: PantasIconButton(
                    tooltip: 'Close',
                    glyph: PantasIcons.close,
                    onPressed: onDone,
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s40,
                    PantasSpace.s16,
                    PantasSpace.s40,
                    PantasSpace.s56,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          WebFinaleEffect(
                            milliseconds: time,
                            track: 'k-rh',
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 12,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            blueprintName,
                                            style: PantasType.phoneLargeTitle
                                                .copyWith(
                                              color: t.colors.textPrimary,
                                              height: 1.15,
                                            ),
                                          ),
                                          if (forfeited)
                                            Text(
                                              'Not finished',
                                              style: t.sm,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: PantasSpace.s4),
                                      Text(
                                        dateFormatted,
                                        style: PantasType.webLead.copyWith(
                                          color: t.colors.secondaryLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!fromRecord)
                                  WebFinaleEffect(
                                    milliseconds: time,
                                    track: 'k-rdone',
                                    child: WebButton(
                                      label: 'Done',
                                      large: true,
                                      keyHint: 'Enter',
                                      onPressed: onDone,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: PantasSpace.s28),
                          WebFinaleEffect(
                            milliseconds: time,
                            track: 'k-rsc',
                            child: WebCard(
                              key: const ValueKey('web-mock-score'),
                              radius: 20,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        PantasSpace.s24,
                                        PantasSpace.s40,
                                        PantasSpace.s24,
                                        PantasSpace.s32,
                                      ),
                                      child: Column(
                                        children: [
                                          MediaQuery(
                                            data: MediaQuery.of(
                                              context,
                                            ).copyWith(
                                              disableAnimations: true,
                                            ),
                                            child: HalfRingGauge.mock(
                                              web: true,
                                              trackOpacity: time == null
                                                  ? 1
                                                  : sampleWebFinale(
                                                      'k-track',
                                                      time,
                                                    ).opacity,
                                              glowOpacity: time == null
                                                  ? 0
                                                  : sampleWebFinale(
                                                      'k-rglow',
                                                      time,
                                                    ).opacity,
                                              glowScale: time == null
                                                  ? 1
                                                  : sampleWebFinale(
                                                      'k-rglow',
                                                      time,
                                                    ).sx,
                                              fraction:
                                                  results.percent / 100 * arc,
                                              odometerProgress: time == null
                                                  ? null
                                                  : odometer,
                                              displayedFraction:
                                                  results.percent /
                                                      100 *
                                                      odometer,
                                              numberOpacity: time == null
                                                  ? 1
                                                  : sampleWebFinale(
                                                      'k-rnum',
                                                      time,
                                                    ).opacity,
                                              labelOpacity: time == null
                                                  ? 1
                                                  : sampleWebFinale(
                                                      'k-rsub',
                                                      time,
                                                    ).opacity,
                                              label: caption,
                                            ),
                                          ),
                                          if (forfeited &&
                                              forfeitedPart != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: PantasSpace.s20,
                                              ),
                                              child: Text(
                                                'With strict mode enabled, '
                                                'you left the app '
                                                'during Part $forfeitedPart, '
                                                'so the mock ended '
                                                'there. Everything you '
                                                'answered '
                                                'before then is '
                                                'scored.',
                                                style: t.sub,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 13,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        PantasSpace.s32,
                                        PantasSpace.s14,
                                        PantasSpace.s32,
                                        PantasSpace.s20,
                                      ),
                                      child: WebFinaleEffect(
                                        milliseconds: time,
                                        track: 'k-rbk',
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (var i = 0;
                                                i < results.sections.length;
                                                i++)
                                              _Breakdown(
                                                section: results.sections[i],
                                                animatedAccuracy:
                                                    barAccuracy(i),
                                                divider: i <
                                                    results.sections.length - 1,
                                              ),
                                            const SizedBox(
                                              height: PantasSpace.s14,
                                            ),
                                            if (canReview)
                                              // The board puts the Free
                                              // note beside the link.
                                              Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                spacing: 16,
                                                runSpacing: 6,
                                                children: [
                                                  WebFinaleEffect(
                                                    milliseconds: time,
                                                    track: 'k-rall',
                                                    child: WebTextLink(
                                                      label:
                                                          'See all questions',
                                                      onPressed:
                                                          onReviewTap ?? () {},
                                                    ),
                                                  ),
                                                  if (!proIsActive &&
                                                      reviewUntil != null)
                                                    Text(
                                                      fromRecord
                                                          ? 'Open until '
                                                              '${until!}'
                                                          : 'Open until your '
                                                              'next mock on '
                                                              '${until!}',
                                                      style: t.sm,
                                                    ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!canReview) ...[
                            const SizedBox(height: PantasSpace.s28),
                            WebCard(
                              radius: 16,
                              padding: const EdgeInsets.symmetric(
                                horizontal: PantasSpace.s20,
                                vertical: PantasSpace.s18,
                              ),
                              child: proPaused
                                  ? const ProPausedLine()
                                  : Row(
                                      children: [
                                        Icon(
                                          Icons.auto_stories_outlined,
                                          color: t.colors.accent,
                                          size: 28,
                                        ),
                                        const SizedBox(width: PantasSpace.s16),
                                        Expanded(
                                          child: Text(
                                            'Go through all $total questions '
                                            'again with Pro.',
                                            style: PantasType.webBody.copyWith(
                                              color: t.colors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: PantasSpace.s16),
                                        WebButton(
                                          label: 'See Pro',
                                          variant: WebButtonVariant.secondary,
                                          onPressed: onSeePro,
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                          if (fromRecord && onFullRecord != null) ...[
                            const SizedBox(height: PantasSpace.s28),
                            WebCard(
                              radius: 20,
                              child: WebRow(
                                title: 'See full record',
                                titleStyle: PantasType.webBody
                                    .copyWith(color: t.colors.accent),
                                chevron: WebRowChevron.always,
                                onPressed: onFullRecord,
                                divider: false,
                              ),
                            ),
                          ] else if (!fromRecord &&
                              !forfeited &&
                              pastResults.isNotEmpty) ...[
                            const SizedBox(height: PantasSpace.s28),
                            WebFinaleEffect(
                              milliseconds: time,
                              track: 'k-rpast',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text('VERSUS PAST RESULTS', style: t.eb),
                                  const SizedBox(height: PantasSpace.s10),
                                  WebCard(
                                    radius: 20,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            PantasSpace.s20,
                                            PantasSpace.s20,
                                            PantasSpace.s20,
                                            PantasSpace.s8,
                                          ),
                                          child: mockPastChart(
                                            pastResults,
                                            time: time,
                                            web: true,
                                            currentPercent: results.percent,
                                            currentLabel: fromRecord
                                                ? dateFormatted
                                                : 'Today',
                                          ),
                                        ),
                                        if (onFullRecord != null)
                                          WebRow(
                                            title: 'See full record',
                                            titleColor: t.colors.accent,
                                            onPressed: onFullRecord,
                                            divider: false,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewControls(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canReview) ...[
            GroupedSection(
              children: [
                ListRow(
                  title: 'See all ${results.scoreTotal} questions',
                  onTap: onReviewTap,
                  subtitle: fromRecord && !proIsActive && reviewUntil != null
                      ? 'Open until '
                          '${PantasDates.withWeekday(reviewUntil!)}'
                      : null,
                ),
              ],
            ),
            if (!fromRecord && !proIsActive && reviewUntil != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s8,
                  PantasSpace.s16,
                  PantasSpace.s0,
                ),
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
                  padding: const EdgeInsets.all(PantasSpace.s16),
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
                        const SizedBox(height: PantasSpace.s12),
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
      );

  Widget _gauge(BuildContext context, double? time, String caption) {
    if (time == null) {
      return Center(
        child: HalfRingGauge.mock(
          fraction: results.percent / 100,
          label: caption,
        ),
      );
    }
    final shake =
        results.scoreRaw > 0 ? sampleCseFinaleEffect(537, time) : null;
    return _phase(
      time,
      538,
      Transform.translate(
        offset: Offset(shake?.x ?? 0, shake?.y ?? 0),
        child: Center(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: HalfRingGauge.mock(
              fraction: results.percent /
                  100 *
                  cseFinaleInterval(
                    time,
                    4563.0405,
                    5200.0025,
                    PantasCurves.gauge,
                  ),
              displayedFraction: results.percent /
                  100 *
                  cseFinaleInterval(
                    time,
                    5265.038,
                    5817.556,
                    PantasCurves.gauge,
                  ),
              numberOpacity: cseFinaleInterval(time, 5265.038, 5427.4565),
              labelOpacity: cseFinaleInterval(time, 5687.485, 5900),
              label: caption,
            ),
          ),
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({
    required this.section,
    required this.divider,
    this.animatedAccuracy,
  });
  final SectionResult section;
  final double? animatedAccuracy;
  final bool divider;
  @override
  Widget build(BuildContext context) => ScoreBreakdownRow(
        name: section.name,
        correct: section.correct,
        total: section.total,
        divider: divider,
        animatedAccuracy: animatedAccuracy,
      );
}

class MockPastPoint {
  const MockPastPoint({required this.percent, required this.label});
  final double percent;
  final String label;
}

/// The "Versus past results" chart: the page's earlier mocks and this one, on
/// the shared [PantasChart]. It draws the points the page has, no others; the
/// chart keeps the latest that fit and its table lists them all.
///
/// [time] is the finale clock in milliseconds, or null at rest (and with
/// reduced motion). The latest point then draws in and pops at the board
/// times: the phone's tracks 568 to 571 and the wide page's `k-t*` tracks.
Widget mockPastChart(
  List<MockPastPoint> past, {
  required double currentPercent,
  required String currentLabel,
  double? time,
  bool web = false,
}) {
  // Every value prints with one decimal, as this chart always did.
  PantasChartPoint point(String label, double percent) => PantasChartPoint(
        label: label,
        value: percent,
        valueText: '${percent.toStringAsFixed(1)}%',
      );
  final points = [
    for (final p in past) point(p.label, p.percent),
    point(currentLabel, currentPercent),
  ];
  return PantasChart(
    title: 'Past results',
    summary: mockPastSummary(points),
    points: points,
    unit: 'mocks',
    kind: PantasChartKind.line,
    emptyText: 'No results yet. Take a mock exam to see your trend.',
    entrance: time == null ? null : _pastEntrance(time, web: web),
  );
}

PantasChartEntrance _pastEntrance(double time, {required bool web}) {
  if (web) {
    final dot = sampleWebFinale('k-tdot', time);
    final value = sampleWebFinale('k-tval', time);
    return PantasChartEntrance(
      lineProgress: 1 - sampleWebFinale('k-tline', time).value / 340.1,
      dotScale: dot.sx,
      dotOpacity: dot.opacity,
      labelOpacity: sampleWebFinale('k-tday', time).opacity,
      valueOpacity: value.opacity,
      valueOffset: value.offset.dy,
    );
  }
  final dot = sampleCseFinaleEffect(568, time);
  final value = sampleCseFinaleEffect(571, time);
  return PantasChartEntrance(
    lineProgress: cseFinaleInterval(time, 8750.055, 9300, PantasCurves.draw),
    dotScale: dot.scaleX,
    dotOpacity: dot.opacity,
    labelOpacity: sampleCseFinaleEffect(569, time).opacity,
    valueOpacity: value.opacity,
    valueOffset: value.y,
  );
}

/// One sentence about the points, from their own values.
String mockPastSummary(List<PantasChartPoint> points) {
  if (points.length == 1) return 'One result so far.';
  final values = [for (final p in points) p.value!];
  final low = values.reduce(math.min);
  final high = values.reduce(math.max);
  String show(double v) => '${v.toStringAsFixed(1)}%';
  return 'Your last ${points.length} mocks ranged from ${show(low)} to '
      '${show(high)}. The latest is ${points.last.printed}.';
}

Widget _phase(double? time, int sourceTrack, Widget child) {
  if (time == null) return child;
  final frame = sampleCseFinaleEffect(sourceTrack, time);
  return IgnorePointer(
    ignoring: frame.opacity == 0,
    child: Opacity(
      opacity: frame.opacity,
      child: Transform.translate(
        offset: Offset(frame.x, frame.y),
        child: child,
      ),
    ),
  );
}
