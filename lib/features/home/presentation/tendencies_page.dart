import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/how_you_work_provider.dart';
import 'package:pantas/features/home/presentation/widgets/web_tendencies_layout.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_templates.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';

class TendenciesPage extends StatelessWidget {
  const TendenciesPage({
    required this.data,
    required this.pro,
    required this.paused,
    required this.onBack,
    required this.onName,
    required this.onPro,
    super.key,
  });
  final HowYouWork data;
  final bool pro;
  final bool paused;
  final VoidCallback onBack;
  final VoidCallback onName;
  final VoidCallback onPro;

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      return WebTendenciesLayout(
        data: data,
        pro: pro,
        paused: paused,
        onBack: onBack,
        onName: onName,
        onPro: onPro,
      );
    }
    final clear = data.tendencies
        .where((t) => t.confidence == TendencyConfidence.clear)
        .toList();
    final pending = data.tendencies
        .where((t) => t.confidence != TendencyConfidence.clear)
        .toList();
    // One card holds the findings. The card's edge is the group's own, so a
    // finding is drawn without a surface of its own (4N-5).
    Widget group(String title, List<Tendency> cards) => GroupedSection(
          header: title,
          radius: PantasRadius.xl,
          children: [
            for (final (index, t) in cards.indexed)
              _Finding(
                tendency: t,
                covered: pro,
                topInset: index == 0 ? 20 : 0,
                bottomInset: index == cards.length - 1
                    ? 20
                    : _Finding.gapAfter(t, covered: pro),
              ),
          ],
        );
    return PantasPage(
      title: 'Your tendencies',
      backLabel: 'Home',
      onBack: onBack,
      bottomInset: 104,
      children: [
        _Profile(data: data, onName: onName),
        const SizedBox(height: PantasSpace.s24),
        if (!pro) ...[
          // YO_Free: a section label over the locked cards.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s0,
              PantasSpace.s16,
              PantasSpace.s8,
            ),
            child: Text(
              'YOUR TENDENCIES',
              style: context.type.sectionHeader,
            ),
          ),
          for (final t in data.tendencies) ...[
            _Finding(tendency: t, covered: false, standalone: true),
            const SizedBox(height: PantasSpace.s12),
          ],
          if (paused)
            const ProPausedLine()
          else ...[
            Text(
              'Unlock complete insights into your study habits, pacing, '
              'and working hours.',
              textAlign: TextAlign.center,
              style: context.type.body,
            ),
            const SizedBox(height: PantasSpace.s14),
            PantasButton(label: 'Unlock with Pro', onPressed: onPro),
          ],
        ] else ...[
          if (clear.isNotEmpty) ...[
            group('What we found', clear),
            const SizedBox(height: PantasSpace.s24),
          ],
          if (pending.isNotEmpty) ...[
            group('Needs more usage data', pending),
            const SizedBox(height: PantasSpace.s24),
          ],
          if (data.whenYouWork.isNotEmpty)
            GroupedSection(
              header: 'When you work',
              children: [
                for (var i = 0; i < data.whenYouWork.length; i++)
                  ListRow(
                    title: data.whenYouWork[i].title,
                    value: data.whenYouWork[i].meta,
                    variant: ListRowVariant.value,
                    divider: i < data.whenYouWork.length - 1,
                  ),
              ],
            ),
        ],
      ],
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.data, required this.onName});
  final HowYouWork data;
  final VoidCallback onName;
  @override
  Widget build(BuildContext context) {
    final glyph = switch (data.archetype) {
      'Levelheaded' => const IconData(0xe514, fontFamily: 'Phosphor'),
      'Deep Thinker' => const IconData(0xe2dc, fontFamily: 'Phosphor'),
      'Night Owl' => const IconData(0xe330, fontFamily: 'Phosphor'),
      'Early Bird' => const IconData(0xe5b6, fontFamily: 'Phosphor'),
      'Math Wizard' => const IconData(0xe31e, fontFamily: 'Phosphor'),
      'Wordsmith' => const IconData(0xe6ee, fontFamily: 'Phosphor'),
      'All-Rounder' => const IconData(0xe1c8, fontFamily: 'Phosphor'),
      'Scholar' => const IconData(0xe0e6, fontFamily: 'Phosphor'),
      'Strong Recall' => const IconData(0xe036, fontFamily: 'Phosphor'),
      'Thorough Reviewer' => const IconData(0xe0ea, fontFamily: 'Phosphor'),
      'Time Master' => const IconData(0xe492, fontFamily: 'Phosphor'),
      'Closer' => const IconData(0xea38, fontFamily: 'Phosphor'),
      _ => null,
    };
    final reduce = MediaQuery.disableAnimationsOf(context);
    // Until an archetype is earned the card says so, with a ghost question
    // mark where the archetype's glyph would stand (QA polish board,
    // option C).
    final empty = data.archetype == null;
    // The ghost slides in as the archetype glyph does.
    Widget slide(Widget child) => TweenAnimationBuilder<double>(
          tween: Tween(begin: reduce ? 1 : 0, end: 1),
          duration: PantasDurations.long3,
          curve: PantasCurves.house,
          builder: (_, value, child) => Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
          child: child,
        );
    return LayoutBuilder(
      builder: (context, constraints) {
        double measure(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: constraints.maxWidth - 40);
          return painter.height;
        }

        final c = context.colors;
        final heading = PantasType.phoneTitle1.copyWith(color: c.toastText);
        final line = context.type.body.copyWith(color: c.toastText);
        final identityHeight = archetypeCatalog
            .map(
              (a) =>
                  measure(a.label, heading) +
                  measure(archetypeIdentityLine(a.id), line),
            )
            .reduce(math.max);
        final height = empty
            ? 130.0
            : 40 +
                measure(data.name ?? 'Add your name', context.type.subhead) +
                14 +
                identityHeight;
        return Container(
          key: const ValueKey('tendencies-profile'),
          constraints: BoxConstraints(minHeight: height),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: c.toastBg,
            borderRadius: BorderRadius.circular(PantasRadius.r2xl),
          ),
          child: Stack(
            children: [
              if (empty)
                Positioned(
                  right: 2,
                  top: -8,
                  child: ExcludeSemantics(
                    child: slide(
                      Text(
                        '?',
                        key: const ValueKey('tendencies-ghost'),
                        style: PantasType.phoneDisplayL.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1,
                          leadingDistribution: TextLeadingDistribution.even,
                          color: c.toastText.withValues(
                            alpha: PantasOpacity.hover,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else if (glyph != null)
                Positioned(
                  right: -24,
                  top: 12,
                  child: slide(
                    SizedBox(
                      width: _ghostGlyph,
                      height: _ghostGlyph,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            glyph,
                            size: _ghostGlyph,
                            color: c.toastText.withValues(
                              alpha: PantasOpacity.hover,
                            ),
                          ),
                          if (data.archetype == 'Strong Recall' ||
                              data.archetype == 'Thorough Reviewer')
                            Icon(
                              PantasIcons.check,
                              size: PantasSpace.s56,
                              color: c.toastText.withValues(
                                alpha: PantasOpacity.hover,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(PantasSpace.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.name == null)
                      WebTextLink(
                        label: 'Add your name',
                        onPressed: onName,
                        arrow: false,
                      )
                    else
                      Text(
                        data.name!,
                        style: context.type.subhead.copyWith(
                          color: c.toastText,
                          height: empty ? 20 / 15 : null,
                        ),
                      ),
                    if (empty) ...[
                      const SizedBox(height: PantasSpace.s6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 270),
                        child: Text(
                          'Needs more usage data',
                          style: PantasType.phoneTitle1.copyWith(
                            letterSpacing: -.6,
                            height: 1.14,
                            color: c.toastText,
                          ),
                        ),
                      ),
                    ],
                    if (data.archetype != null) ...[
                      const SizedBox(height: PantasSpace.s6),
                      Text(
                        data.archetype!,
                        style:
                            PantasType.phoneTitle1.copyWith(color: c.toastText),
                      ),
                      const SizedBox(height: PantasSpace.s8),
                      Text(
                        data.archetypeLine ?? '',
                        style: context.type.body.copyWith(
                          color: c.toastText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The ghost glyph behind the profile card text.
final double _ghostGlyph = PantasType.phoneDisplayL.fontSize!;

class _Finding extends StatelessWidget {
  const _Finding({
    required this.tendency,
    required this.covered,
    this.topInset = 20,
    this.bottomInset = 20,
    this.standalone = false,
  });
  final Tendency tendency;
  final bool covered;

  /// Space above and below the finding inside its card. A finding that shares
  /// a card sets the gap to the next one in its own bottom inset.
  final double topInset;
  final double bottomInset;

  /// A locked finding is a card of its own, rounded like the Pro card.
  final bool standalone;

  /// Nothing measured yet: the heading and one line only, with a faint
  /// placeholder where the chart will go (board Tend, option C).
  static bool _empty(Tendency t, {required bool covered}) =>
      covered &&
      t.id != TendencyId.stamina &&
      t.confidence != TendencyConfidence.clear &&
      t.confidence != TendencyConfidence.forming &&
      (t.leftFigure == null || t.rightFigure == null);

  /// The board's two bars under "How long you answer".
  static bool _bars(Tendency t) =>
      t.id == TendencyId.howYouAnswer || t.id == TendencyId.howLongYouRemember;

  /// Space between this finding and the next, inside one card. The board
  /// leaves 40 px after the line placeholder and 30 after the two bars.
  static double gapAfter(Tendency t, {required bool covered}) =>
      _empty(t, covered: covered) && _bars(t) ? 30 : 40;

  @override
  Widget build(BuildContext context) {
    final t = tendency;
    final clear = covered && t.confidence == TendencyConfidence.clear;
    final missing = t.leftFigure == null || t.rightFigure == null;
    final empty = _empty(t, covered: covered);
    final caption = !covered
        ? '${t.leftLabel} vs. ${t.rightLabel}'
        : t.confidence == TendencyConfidence.forming
            ? 'No clear difference so far.'
            : missing
                ? 'Not enough data yet'
                : 'Too early to tell.';
    final header = Row(
      children: [
        Icon(
          switch (t.id) {
            TendencyId.underPressure => PantasIcons.timer,
            TendencyId.howYouAnswer => PantasIcons.timer,
            TendencyId.howYouStudy => PantasIcons.studyTab,
            TendencyId.howLongYouRemember =>
              const IconData(0xe036, fontFamily: 'Phosphor'),
            TendencyId.stamina => PantasIcons.answerStreak,
          },
          size: 17,
          color: context.colors.textSecondary,
        ),
        const SizedBox(width: PantasSpace.s8),
        Expanded(
          child: Text(
            t.heading.toUpperCase(),
            style: context.type.sectionHeader.copyWith(height: 18 / 13),
          ),
        ),
      ],
    );
    // A locked finding is a card of its own: the system Card, which draws its
    // dark edge over the content, so the content sits 20 from the outer edge.
    Widget frame(Widget child) => standalone
        ? WebCard(
            padding: EdgeInsets.fromLTRB(
              PantasSpace.s20,
              topInset,
              PantasSpace.s20,
              bottomInset,
            ),
            child: child,
          )
        : Padding(
            padding: EdgeInsets.fromLTRB(
              PantasSpace.s20,
              topInset,
              PantasSpace.s20,
              bottomInset,
            ),
            child: child,
          );
    if (empty) {
      // Board Tend: the heading, the line, and a faint placeholder 44 px
      // under the text for the line, 72 px for the two bars, nothing for
      // "How you study". The page's measured rhythm is 168 px from one
      // heading to the next after the line and 200 after the bars.
      final faint = context.colors.fill;
      Widget bar(double fraction, double height) => FractionallySizedBox(
            widthFactor: fraction,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: faint,
                borderRadius: BorderRadius.circular(height <= 4 ? 99 : 4),
              ),
              child: SizedBox(height: height, width: double.infinity),
            ),
          );
      return frame(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: PantasSpace.s10),
            Text(
              caption,
              style: PantasType.phoneTitle3.copyWith(
                height: 26 / 20,
                color: context.colors.textSecondary,
              ),
            ),
            if (t.unlockAction.isNotEmpty) ...[
              const SizedBox(height: PantasSpace.s6),
              Text(
                t.unlockAction,
                style: context.type.subhead.copyWith(
                  color: context.colors.textSecondary,
                  height: 20 / 15,
                ),
              ),
            ],
            if (t.id == TendencyId.underPressure) ...[
              const SizedBox(height: PantasSpace.s44),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
                child: bar(1, 4),
              ),
            ] else if (_bars(t)) ...[
              const SizedBox(height: PantasSpace.s56 + PantasSpace.s16),
              Align(
                alignment: Alignment.centerLeft,
                child: bar(.65, 14),
              ),
              const SizedBox(height: PantasSpace.s16),
              Align(
                alignment: Alignment.centerLeft,
                child: bar(.85, 14),
              ),
            ],
          ],
        ),
      );
    }
    return frame(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: PantasSpace.s10),
          Text(
            clear ? t.sentence ?? caption : caption,
            style: context.type.emphasized.copyWith(
              fontSize: covered ? 20 : 17,
              color: clear || !covered
                  ? context.colors.textPrimary
                  : context.colors.textSecondary,
            ),
          ),
          if (covered &&
              !clear &&
              missing &&
              t.confidence != TendencyConfidence.forming &&
              t.unlockAction.isNotEmpty) ...[
            const SizedBox(height: PantasSpace.s6),
            Text(
              t.unlockAction,
              style: context.type.subhead
                  .copyWith(color: context.colors.textSecondary),
            ),
          ],
          const SizedBox(height: PantasSpace.s18),
          if (clear && t.id == TendencyId.howYouStudy)
            Row(
              children: [
                _share(
                  context,
                  t.leftLabel,
                  t.leftFigure!,
                  PantasIcons.studyTab,
                  strong: _number(t.leftFigure) >= _number(t.rightFigure),
                ),
                _share(
                  context,
                  t.rightLabel,
                  t.rightFigure!,
                  PantasIcons.quizTab,
                  strong: _number(t.rightFigure) >= _number(t.leftFigure),
                ),
              ],
            )
          else if (clear && t.id == TendencyId.howLongYouRemember)
            Row(
              children: [
                _share(context, t.leftLabel, t.leftFigure!, null),
                _share(context, t.rightLabel, t.rightFigure!, null),
              ],
            )
          else if (!covered)
            ..._lockedChart(context, t)
          else ...[
            if (clear && t.id == TendencyId.stamina)
              Text('Accuracy in your mocks', style: context.type.footnote),
            if (clear)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${t.leftFigure} ${t.leftLabel}',
                      style: context.type.subhead,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${t.rightFigure} ${t.rightLabel}',
                      textAlign: TextAlign.right,
                      style: context.type.subhead.copyWith(
                        color: t.isLoss
                            ? context.colors.warningText
                            : context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: PantasSpace.s8),
            Semantics(
              label: clear
                  ? '${t.leftLabel}: ${t.leftFigure}. '
                      '${t.rightLabel}: ${t.rightFigure}.'
                  : '${t.leftLabel} compared with ${t.rightLabel}. '
                      'No finding yet.',
              child: SizedBox(
                height: (PantasSpace.s56 + PantasSpace.s16) *
                    math.max(
                      1,
                      MediaQuery.textScalerOf(context).scale(10) / 10,
                    ),
                width: double.infinity,
                child: Row(
                  children: [
                    if (clear && t.id == TendencyId.stamina)
                      Padding(
                        padding: const EdgeInsets.only(right: PantasSpace.s8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final tick in [
                              '80%',
                              '70%',
                              '60%',
                              '50%',
                              '40%',
                            ])
                              Text(
                                tick,
                                style: context.type.captionSmall,
                              ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin:
                              MediaQuery.disableAnimationsOf(context) ? 1 : 0,
                          end: 1,
                        ),
                        duration: PantasDurations.long3,
                        curve: PantasCurves.house,
                        builder: (_, value, __) => CustomPaint(
                          painter: _FindingPainter(
                            t,
                            value,
                            context.colors.fill,
                            context.colors.textPrimary,
                            context.colors.warningText,
                            clear: clear,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (clear && t.id == TendencyId.underPressure)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final tick in ['40%', '50%', '60%', '70%', '80%'])
                    Text(tick, style: context.type.footnote),
                ],
              ),
            if (t.id == TendencyId.stamina)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1H', style: context.type.footnote),
                  Text('2H', style: context.type.footnote),
                ],
              ),
            if (clear &&
                t.id == TendencyId.howYouAnswer &&
                t.isLoss &&
                t.gap != null)
              Text(
                '+${t.gap} on wrong answers',
                style: context.type.footnote
                    .copyWith(color: context.colors.warningText),
              ),
          ],
        ],
      ),
    );
  }

  /// The Free chart: the same labeled placeholder the wide page draws, so the
  /// two sides of each finding are named instead of left as blank gray bars.
  List<Widget> _lockedChart(BuildContext context, Tendency t) {
    final c = context.colors;
    final label = context.type.footnote;
    Widget bar(String name, double fraction) => Row(
          children: [
            SizedBox(
              width: PantasSpace.s56 + PantasSpace.s32,
              child: Text(name, style: label),
            ),
            const SizedBox(width: PantasSpace.s12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PantasRadius.full),
                child: SizedBox(
                  height: PantasSpace.s10,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: fraction,
                      child: ColoredBox(
                        color: c.fill,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
    Widget tile(String name) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PantasSpace.s14,
              vertical: PantasSpace.s12,
            ),
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(PantasRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u2013',
                  style: PantasType.webH2.copyWith(color: c.textSecondary),
                ),
                Text(name, style: label),
              ],
            ),
          ),
        );
    return switch (t.id) {
      TendencyId.underPressure || TendencyId.howYouAnswer => [
          bar(t.leftLabel, .6),
          const SizedBox(height: PantasSpace.s14),
          bar(t.rightLabel, .45),
        ],
      TendencyId.howYouStudy => [
          ClipRRect(
            borderRadius: BorderRadius.circular(PantasRadius.full),
            child: SizedBox(
              height: PantasSpace.s12,
              child: ColoredBox(color: c.fill, child: const SizedBox.expand()),
            ),
          ),
          const SizedBox(height: PantasSpace.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(t.leftLabel, style: label)),
              Flexible(
                child: Text(
                  t.rightLabel,
                  textAlign: TextAlign.right,
                  style: label,
                ),
              ),
            ],
          ),
        ],
      TendencyId.howLongYouRemember => [
          Row(
            children: [
              tile(t.leftLabel),
              const SizedBox(width: PantasSpace.s12),
              tile(t.rightLabel),
            ],
          ),
        ],
      TendencyId.stamina => [
          SizedBox(
            height: PantasSpace.s56,
            width: double.infinity,
            child: CustomPaint(
              painter: _FindingPainter(
                t,
                1,
                c.fill,
                c.textPrimary,
                c.warningText,
                clear: false,
              ),
            ),
          ),
          const SizedBox(height: PantasSpace.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(t.leftLabel, style: label)),
              Flexible(
                child: Text(
                  t.rightLabel,
                  textAlign: TextAlign.right,
                  style: label,
                ),
              ),
            ],
          ),
        ],
    };
  }

  Widget _share(
    BuildContext context,
    String label,
    String figure,
    IconData? icon, {
    bool strong = true,
  }) =>
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 24,
                color: strong
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
            const SizedBox(height: PantasSpace.s4),
            Text(
              figure,
              style: context.type.largeTitle.copyWith(
                fontSize: icon == null ? 34 : 24,
                color: strong
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
            ),
            Text(label, style: context.type.footnote),
          ],
        ),
      );

  double _number(String? value) =>
      double.tryParse((value ?? '').replaceAll('%', '')) ?? 0;
}

class _FindingPainter extends CustomPainter {
  _FindingPainter(
    this.t,
    this.fraction,
    this.faint,
    this.ink,
    this.loss, {
    required this.clear,
  });
  final Tendency t;
  final bool clear;
  final double fraction;
  final Color faint;
  final Color ink;
  final Color loss;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = faint
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final color = clear && t.isLoss
        ? loss
        : clear
            ? ink
            : faint;
    double number(String? text) =>
        double.tryParse((text ?? '').replaceAll(RegExp('[^0-9.]'), '')) ?? 0;
    final a = clear ? number(t.leftFigure) : 0;
    final b = clear ? number(t.rightFigure) : 0;
    if (t.id == TendencyId.underPressure) {
      canvas.drawLine(
        Offset(6, size.height / 2),
        Offset(size.width - 6, size.height / 2),
        paint,
      );
      if (clear) {
        final x1 =
            6 + (size.width - 12) * ((a - 40) / 40).clamp(0, 1) * fraction;
        final x2 =
            6 + (size.width - 12) * ((b - 40) / 40).clamp(0, 1) * fraction;
        if (t.isLoss) {
          canvas.drawLine(
            Offset(x1, size.height / 2),
            Offset(x2, size.height / 2),
            Paint()
              ..color = loss
              ..strokeWidth = 5
              ..strokeCap = StrokeCap.round,
          );
        }
        canvas
          ..drawCircle(
            Offset(
              6 + (size.width - 12) * ((a - 40) / 40).clamp(0, 1) * fraction,
              size.height / 2,
            ),
            6,
            Paint()..color = ink,
          )
          ..drawCircle(
            Offset(
              6 + (size.width - 12) * ((b - 40) / 40).clamp(0, 1) * fraction,
              size.height / 2,
            ),
            6,
            Paint()..color = color,
          );
      }
    } else if (t.id == TendencyId.stamina) {
      paint.strokeWidth = 1;
      canvas
        ..drawLine(const Offset(4, 0), Offset(4, size.height), paint)
        ..drawLine(
          Offset(4, size.height),
          Offset(size.width, size.height),
          paint,
        );
      final path = Path()
        ..moveTo(
          8,
          clear
              ? size.height * (1 - ((a - 40) / 40).clamp(0, 1))
              : size.height * .55,
        )
        ..lineTo(
          8 + (size.width - 16) * fraction,
          clear
              ? size.height *
                  (1 - ((a + (b - a) * fraction - 40) / 40).clamp(0, 1))
              : size.height * .5,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      final max = math.max(1.0, math.max(a, b));
      for (var i = 0; i < 2; i++) {
        final width = clear
            ? size.width * (i == 0 ? a : b) / max * fraction
            : size.width * (i == 0 ? .65 : .85);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, i * 30, width, 14),
            const Radius.circular(PantasRadius.xs),
          ),
          Paint()..color = clear ? ink : faint,
        );
        if (clear && i == 1 && t.isLoss && b > a) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                size.width * a / max * fraction,
                30,
                size.width * (b - a) / max * fraction,
                14,
              ),
              const Radius.circular(PantasRadius.xs),
            ),
            Paint()..color = loss,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FindingPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.fraction != fraction ||
      oldDelegate.clear != clear ||
      oldDelegate.ink != ink;
}
