import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/how_you_work_provider.dart';
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
    final clear = data.tendencies
        .where((t) => t.confidence == TendencyConfidence.clear)
        .toList();
    final pending = data.tendencies
        .where((t) => t.confidence != TendencyConfidence.clear)
        .toList();
    Widget group(String title, List<Tendency> cards) => GroupedSection(
          header: title,
          children: [
            for (final t in cards) _Finding(tendency: t, covered: pro),
          ],
        );
    return PantasPage(
      title: 'Your tendencies',
      backLabel: 'Home',
      onBack: onBack,
      bottomInset: 104,
      children: [
        _Profile(data: data, onName: onName),
        const SizedBox(height: 24),
        if (!pro) ...[
          for (final t in data.tendencies) ...[
            _Finding(tendency: t, covered: false),
            const SizedBox(height: 12),
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
            const SizedBox(height: 14),
            PantasButton(label: 'Unlock with Pro', onPressed: onPro),
          ],
        ] else ...[
          if (clear.isNotEmpty) ...[
            group('What we found', clear),
            const SizedBox(height: 24),
          ],
          if (pending.isNotEmpty) ...[
            group('Needs more usage data', pending),
            const SizedBox(height: 24),
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

        final heading =
            context.type.largeTitle.copyWith(fontSize: 30, color: Colors.white);
        final line = context.type.body.copyWith(color: const Color(0xffddddde));
        final identityHeight = archetypeCatalog
            .map(
              (a) =>
                  measure(a.label, heading) +
                  measure(archetypeIdentityLine(a.id), line),
            )
            .reduce(math.max);
        final height = 40 +
            measure(data.name ?? 'Add your name', context.type.subhead) +
            14 +
            identityHeight;
        return Container(
          key: const ValueKey('tendencies-profile'),
          constraints: BoxConstraints(minHeight: height),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: const Color(0xff1d1d1f),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Stack(
            children: [
              if (glyph != null)
                Positioned(
                  right: -24,
                  top: 12,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: reduce ? 1 : 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: PantasCurves.houseOut,
                    builder: (_, value, child) => Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: child,
                    ),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            glyph,
                            size: 150,
                            color: const Color(0xff3a3a3d),
                          ),
                          if (data.archetype == 'Strong Recall' ||
                              data.archetype == 'Thorough Reviewer')
                            Icon(
                              PantasIcons.check,
                              size: 52,
                              color: const Color(0xff3a3a3d),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.name == null)
                      TextButton(
                        onPressed: onName,
                        child: const Text('Add your name'),
                      )
                    else
                      Text(
                        data.name!,
                        style: context.type.subhead
                            .copyWith(color: const Color(0xffb6b6b7)),
                      ),
                    if (data.archetype != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        data.archetype!,
                        style: context.type.largeTitle
                            .copyWith(fontSize: 30, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.archetypeLine ?? '',
                        style: context.type.body
                            .copyWith(color: const Color(0xffddddde)),
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

class _Finding extends StatelessWidget {
  const _Finding({required this.tendency, required this.covered});
  final Tendency tendency;
  final bool covered;
  @override
  Widget build(BuildContext context) {
    final t = tendency;
    final clear = covered && t.confidence == TendencyConfidence.clear;
    final missing = t.leftFigure == null || t.rightFigure == null;
    final caption = !covered
        ? '${t.leftLabel} vs. ${t.rightLabel}'
        : t.confidence == TendencyConfidence.forming
            ? 'No clear difference so far.'
            : missing
                ? 'Not enough data yet'
                : 'Too early to tell.';
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                color: context.colors.secondaryLabel,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  t.heading.toUpperCase(),
                  style: context.type.sectionHeader,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            clear ? t.sentence ?? caption : caption,
            style: context.type.emphasized.copyWith(
              fontSize: covered ? 20 : 17,
              color: clear || !covered
                  ? context.colors.label
                  : context.colors.secondaryLabel,
            ),
          ),
          if (covered &&
              !clear &&
              missing &&
              t.confidence != TendencyConfidence.forming) ...[
            const SizedBox(height: 6),
            Text(
              t.unlockAction,
              style: context.type.subhead
                  .copyWith(color: context.colors.secondaryLabel),
            ),
          ],
          const SizedBox(height: 18),
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
                            : context.colors.label,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Semantics(
              label: clear
                  ? '${t.leftLabel}: ${t.leftFigure}. '
                      '${t.rightLabel}: ${t.rightFigure}.'
                  : '${t.leftLabel} compared with ${t.rightLabel}. '
                      'No finding yet.',
              child: SizedBox(
                height: 65 *
                    math.max(
                      1,
                      MediaQuery.textScalerOf(context).scale(10) / 10,
                    ),
                width: double.infinity,
                child: Row(
                  children: [
                    if (clear && t.id == TendencyId.stamina)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
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
                                style:
                                    context.type.footnote.copyWith(fontSize: 9),
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
                        duration: const Duration(milliseconds: 900),
                        curve: PantasCurves.houseOut,
                        builder: (_, value, __) => CustomPaint(
                          painter: _FindingPainter(
                            t,
                            value,
                            context.colors.fill,
                            context.colors.label,
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
                    ? context.colors.label
                    : context.colors.secondaryLabel,
              ),
            const SizedBox(height: 5),
            Text(
              figure,
              style: context.type.largeTitle.copyWith(
                fontSize: icon == null ? 34 : 24,
                color: strong
                    ? context.colors.label
                    : context.colors.secondaryLabel,
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
            const Radius.circular(4),
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
              const Radius.circular(4),
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
