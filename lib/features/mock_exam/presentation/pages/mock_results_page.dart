import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
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
                minimum:
                    EdgeInsets.fromLTRB(16, 14, 16, time == null ? 26 : 30),
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
                padding: EdgeInsets.fromLTRB(16, time == null ? 8 : 50, 16, 24),
                children: [
                  _phase(
                    time,
                    562,
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
                                style: context.type.pageTitle.copyWith(
                                  fontSize: 22,
                                  height: time == null ? null : 1.35,
                                ),
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
                              fontSize: time == null ? null : 15,
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
                                      const Cubic(.2, .8, .25, 1),
                                    ),
                            divider: i < results.sections.length - 1,
                          ),
                      ],
                    ),
                  ),
                  if (!forfeited && pastResults.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    _phase(
                      time,
                      572,
                      GroupedSection(
                        header: 'VERSUS PAST RESULTS',
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                            child: MockPastChart(
                              points: pastResults,
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
                  const SizedBox(height: 22),
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
          const SingleActivator(LogicalKeyboardKey.enter): onDone!,
        if (onDone != null)
          const SingleActivator(LogicalKeyboardKey.escape): onDone!,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              WebTopBar(
                leading: fromRecord
                    ? TextButton.icon(
                        onPressed: onDone,
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Your record'),
                      )
                    : IconButton(
                        tooltip: 'Close',
                        onPressed: onDone,
                        icon: const Icon(Icons.close, size: 22),
                      ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(40, 16, 40, 56),
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
                                            style: t.style(
                                              34,
                                              weight: FontWeight.w700,
                                              height: 1.15,
                                              spacing: -.748,
                                            ),
                                          ),
                                          if (forfeited)
                                            Text(
                                              'Not finished',
                                              style: t.sm,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFormatted,
                                        style: t.style(
                                          17,
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
                          const SizedBox(height: 28),
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
                                        24,
                                        36,
                                        24,
                                        30,
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
                                                top: 20,
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
                                        30,
                                        14,
                                        30,
                                        20,
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
                                              height: 14,
                                            ),
                                            if (canReview) ...[
                                              WebFinaleEffect(
                                                milliseconds: time,
                                                track: 'k-rall',
                                                child: WebTextLink(
                                                  label: 'See all questions',
                                                  onPressed:
                                                      onReviewTap ?? () {},
                                                ),
                                              ),
                                              if (!proIsActive &&
                                                  reviewUntil != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 6,
                                                  ),
                                                  child: Text(
                                                    fromRecord
                                                        ? 'Open until '
                                                            '${until!}'
                                                        : 'On Free, you can go '
                                                            'through these '
                                                            'until your next '
                                                            'mock '
                                                            'opens on '
                                                            '${until!}.',
                                                    style: t.sm,
                                                  ),
                                                ),
                                            ],
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
                            const SizedBox(height: 28),
                            WebCard(
                              radius: 16,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
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
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            'Go through all $total questions '
                                            'again with Pro.',
                                            style: t.style(16),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        WebButton(
                                          label: 'See Pro',
                                          variant: WebButtonVariant.secondary,
                                          onPressed: onSeePro,
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                          if (!forfeited && pastResults.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            WebFinaleEffect(
                              milliseconds: time,
                              track: 'k-rpast',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text('VERSUS PAST RESULTS', style: t.eb),
                                  const SizedBox(height: 9),
                                  WebCard(
                                    radius: 20,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            20,
                                            20,
                                            20,
                                            8,
                                          ),
                                          child: MockPastChart(
                                            points: pastResults,
                                            time: time,
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
                    const Cubic(.12, .75, .25, 1),
                  ),
              displayedFraction: results.percent /
                  100 *
                  cseFinaleInterval(
                    time,
                    5265.038,
                    5817.556,
                    const Cubic(.2, .8, .25, 1),
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
      padding: context.wideWeb
          ? const EdgeInsets.symmetric(vertical: 15)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
          if (animatedAccuracy == null)
            AccuracyBar(accuracy: section.accuracy)
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Container(
                height: 5,
                color: context.colors.fill,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: animatedAccuracy!.clamp(0, 1),
                  child: ColoredBox(
                    color: context.colors.accuracyTint(section.accuracy),
                    child: const SizedBox(height: 5),
                  ),
                ),
              ),
            ),
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
    this.time,
    super.key,
  });
  final List<MockPastPoint> points;
  final double currentPercent;
  final String currentLabel;
  final double? time;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 132,
        width: context.wideWeb ? double.infinity : null,
        child: CustomPaint(
          painter: _PastPainter(
            time: time,
            web: context.wideWeb,
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
    this.time,
    this.web = false,
  });
  final List<MockPastPoint> points;
  final Color label;
  final Color accent;
  final Color previous;
  final Color separator;
  final double? time;
  final bool web;
  void text(
    Canvas c,
    String value,
    Offset at, {
    Color? color,
    bool strong = false,
    bool rightAligned = false,
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
    p.paint(c, at - Offset(rightAligned ? p.width : p.width / 2, 0));
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
          current && time != null
              ? Offset.lerp(
                  last,
                  point,
                  web
                      ? 1 - sampleWebFinale('k-tline', time!).value / 340.1
                      : cseFinaleInterval(
                          time!,
                          8750.055,
                          9300,
                          const Cubic(.5, 0, .3, 1),
                        ),
                )!
              : point,
          Paint()
            ..color = current ? accent : previous
            ..strokeWidth = current ? 2.5 : 2,
        );
      }
      final webPop = web && current && time != null
          ? sampleWebFinale('k-tdot', time!)
          : null;
      final pop = !web && current && time != null
          ? sampleCseFinaleEffect(568, time!)
          : null;
      canvas.drawCircle(
        point,
        (current ? 7 : 5) * (webPop?.sx ?? pop?.scaleX ?? 1),
        Paint()
          ..color = (current ? accent : previous)
              .withValues(alpha: webPop?.opacity ?? pop?.opacity ?? 1),
      );
      text(
        canvas,
        points[i].label,
        Offset(x, 116),
        color: (current ? accent : label).withValues(
          alpha: time == null || !current
              ? 1
              : web
                  ? sampleWebFinale('k-tday', time!).opacity
                  : sampleCseFinaleEffect(569, time!).opacity,
        ),
      );
      if (current) {
        text(
          canvas,
          '${points[i].percent.toStringAsFixed(1)}%',
          Offset(
            x,
            y -
                23 +
                (time == null
                    ? 0
                    : web
                        ? sampleWebFinale('k-tval', time!).offset.dy
                        : sampleCseFinaleEffect(571, time!).y),
          ),
          color: accent.withValues(
            alpha: time == null
                ? 1
                : web
                    ? sampleWebFinale('k-tval', time!).opacity
                    : sampleCseFinaleEffect(571, time!).opacity,
          ),
          strong: true,
          rightAligned: time != null,
        );
      }
      last = point;
    }
  }

  @override
  bool shouldRepaint(_PastPainter old) => true;
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
