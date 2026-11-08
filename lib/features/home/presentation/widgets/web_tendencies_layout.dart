import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/how_you_work_provider.dart';
import 'package:pantas/features/home/presentation/widgets/web_record_layout.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';

class WebTendenciesLayout extends StatelessWidget {
  const WebTendenciesLayout({
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
  Widget build(BuildContext context) => WebMyPage(
        title: 'Your tendencies',
        onBack: onBack,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The board's hero sits 26 px under the title; the eyebrow pages
            // above get 2 px from their own label box.
            const SizedBox(height: PantasSpace.s2),
            WebTendencyProfile(data: data, onName: onName),
            const SizedBox(height: PantasSpace.s24),
            const WebText('What we found', kind: WebTextKind.eyebrow),
            for (var index = 0; index < data.tendencies.length; index += 2) ...[
              if (index > 0) const SizedBox(height: PantasSpace.s14),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: WebTendencyFinding(
                        tendency: data.tendencies[index],
                        pro: pro,
                      ),
                    ),
                    const SizedBox(width: PantasSpace.s14),
                    Expanded(
                      child: index + 1 < data.tendencies.length
                          ? WebTendencyFinding(
                              tendency: data.tendencies[index + 1],
                              pro: pro,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
            if (!pro) ...[
              const SizedBox(height: PantasSpace.s24),
              if (paused)
                const ProPausedLine()
              else
                WebCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PantasSpace.s24,
                    vertical: PantasSpace.s24,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.webTokens.colors.accentTint,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: context.webTokens.colors.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: PantasSpace.s18),
                      Expanded(
                        child: Text(
                          'Unlock complete insights into your study habits, '
                          'pacing, and working hours.',
                          style: context.webTokens.style(17, height: 1.45),
                        ),
                      ),
                      const SizedBox(width: PantasSpace.s18),
                      WebButton(label: 'Unlock with Pro', onPressed: onPro),
                    ],
                  ),
                ),
            ] else if (data.whenYouWork.isNotEmpty) ...[
              const SizedBox(height: PantasSpace.s24),
              const WebText('When you work', kind: WebTextKind.eyebrow),
              WebCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final row in data.whenYouWork)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PantasSpace.s24,
                            vertical: PantasSpace.s18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                row.meta,
                                style: context.webTokens
                                    .style(26, weight: FontWeight.w700),
                              ),
                              Text(row.title, style: context.webTokens.sm),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
}

/// The twelve MY_Profiles identities share the same web-sized card.
class WebTendencyProfile extends StatelessWidget {
  const WebTendencyProfile({
    required this.data,
    required this.onName,
    super.key,
  });
  final HowYouWork data;
  final VoidCallback onName;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    if (data.archetype == null) {
      return WebCard(
        key: const ValueKey('tendencies-profile'),
        padding: const EdgeInsets.all(PantasSpace.s24),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.disabledBackground,
              ),
              child: Text(
                '?',
                style: PantasType.webH2.copyWith(color: t.colors.textSecondary),
              ),
            ),
            const SizedBox(width: PantasSpace.s18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.name == null)
                    TextButton(
                      onPressed: onName,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 24),
                        foregroundColor: t.colors.accent,
                      ),
                      child: Text(
                        'Add your name',
                        style:
                            PantasType.webLink.copyWith(color: t.colors.accent),
                      ),
                    )
                  else
                    Text(data.name!, style: t.sub),
                  const SizedBox(height: PantasSpace.s4),
                  Text(
                    'Needs more usage data',
                    style: t.h3.copyWith(color: t.colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
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
      _ => PantasIcons.studyTab,
    };
    return Container(
      key: const ValueKey('tendencies-profile'),
      constraints: const BoxConstraints(minHeight: 148),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: t.colors.toastBg,
        borderRadius: BorderRadius.circular(PantasRadius.r2xl),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -4.5,
            // The phone's glyph slide: 20 px in from the right, 800 ms.
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: MediaQuery.disableAnimationsOf(context) ? 1 : 0,
                end: 1,
              ),
              duration: PantasDurations.long3,
              curve: PantasCurves.house,
              builder: (_, value, child) => Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: child,
              ),
              child: Transform.rotate(
                angle: -8 * math.pi / 180,
                child: Icon(
                  glyph,
                  size: PantasType.phoneDisplayL.fontSize,
                  color:
                      t.colors.toastText.withValues(alpha: PantasOpacity.hover),
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s28,
                PantasSpace.s24,
                PantasSpace.s56 * PantasSpace.s2,
                PantasSpace.s28,
              ),
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
                      style: PantasType.webNav.copyWith(
                        color: t.colors.toastText,
                      ),
                    ),
                  const SizedBox(height: PantasSpace.s6),
                  Text(
                    data.archetype!,
                    style: PantasType.phoneTitle1.copyWith(
                      height: 1.1,
                      color: t.colors.toastText,
                      letterSpacing: -.6,
                    ),
                  ),
                  if (data.archetypeLine != null) ...[
                    const SizedBox(height: PantasSpace.s6),
                    Text(
                      data.archetypeLine!,
                      style: PantasType.webLead.copyWith(
                        height: 1.4,
                        color: t.colors.toastText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// MY_Pictures: measured comparisons or neutral shapes.
class WebTendencyFinding extends StatelessWidget {
  const WebTendencyFinding({
    required this.tendency,
    required this.pro,
    super.key,
  });
  final Tendency tendency;
  final bool pro;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final a = tendency;
    final missing = a.leftFigure == null || a.rightFigure == null;
    final clear = pro && a.confidence == TendencyConfidence.clear && !missing;
    final forming = a.confidence == TendencyConfidence.forming;
    final caption = !pro
        ? '${a.leftLabel} vs. ${a.rightLabel}'
        : clear
            ? a.sentence ?? ''
            : forming
                ? 'No clear difference so far.'
                : missing
                    ? 'Not enough data yet'
                    : 'Too early to tell.';
    Widget pair(Widget left, Widget right) => Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: PantasSpace.s12),
            Expanded(child: right),
          ],
        );
    Widget number(String label, String? value) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PantasSpace.s14,
            vertical: PantasSpace.s12,
          ),
          decoration: BoxDecoration(
            color: t.colors.bgPage,
            borderRadius: BorderRadius.circular(PantasRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clear ? value! : '–',
                style: PantasType.webH2.copyWith(
                  color: clear ? t.colors.textPrimary : t.colors.textSecondary,
                ),
              ),
              Text(label, style: t.sm),
            ],
          ),
        );
    double value(String? text) =>
        double.tryParse((text ?? '').replaceAll(RegExp('[^0-9.]'), '')) ?? 0;
    Widget bar(String label, String? figure, double fraction, Color color) =>
        Row(
          children: [
            SizedBox(
              width: PantasSpace.s56 + PantasSpace.s32 + PantasSpace.s4,
              child: Text(label, style: t.sm),
            ),
            const SizedBox(width: PantasSpace.s12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PantasRadius.full),
                child: SizedBox(
                  height: PantasSpace.s10,
                  child: ColoredBox(
                    color: t.disabledBackground,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      // The phone's chart draw: 900 ms from empty to the value.
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin:
                              MediaQuery.disableAnimationsOf(context) ? 1 : 0,
                          end: 1,
                        ),
                        duration: PantasDurations.long3,
                        curve: PantasCurves.house,
                        builder: (_, grow, child) => FractionallySizedBox(
                          widthFactor: fraction.clamp(0, 1) * grow,
                          child: child,
                        ),
                        child: ColoredBox(
                          color: color,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: PantasSpace.s12),
            SizedBox(
              width: PantasSpace.s40,
              child: Text(
                clear ? figure! : '',
                textAlign: TextAlign.right,
                style:
                    PantasType.webTitleSm.copyWith(color: t.colors.textPrimary),
              ),
            ),
          ],
        );
    final content = <Widget>[];
    switch (a.id) {
      case TendencyId.underPressure:
      case TendencyId.howYouAnswer:
        if (!pro || clear) {
          final pressure = a.id == TendencyId.underPressure;
          final maximum =
              math.max(60, math.max(value(a.leftFigure), value(a.rightFigure)));
          double fraction(String? figure) =>
              pressure ? value(figure) / 100 : value(figure) / maximum;
          content.addAll([
            bar(
              a.leftLabel,
              a.leftFigure,
              clear ? fraction(a.leftFigure) : .6,
              clear ? t.colors.accent : t.colors.divider,
            ),
            const SizedBox(height: PantasSpace.s14),
            bar(
              a.rightLabel,
              a.rightFigure,
              clear ? fraction(a.rightFigure) : .45,
              clear ? t.colors.accent.withValues(alpha: .55) : t.colors.divider,
            ),
          ]);
          if (clear && pressure) {
            content.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasLayout.reserveTabbar,
                  PantasSpace.s14,
                  PantasSpace.s44 + PantasSpace.s8,
                  PantasSpace.s0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final tick in ['0%', '50%', '100%'])
                      Text(tick, style: t.sm),
                  ],
                ),
              ),
            );
          }
          if (clear && !pressure && a.isLoss && a.gap != null) {
            content.add(
              Padding(
                padding: const EdgeInsets.only(top: PantasSpace.s14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PantasSpace.s8,
                      vertical: PantasSpace.s2,
                    ),
                    decoration: BoxDecoration(
                      color: t.colors.accentTint,
                      borderRadius: BorderRadius.circular(PantasRadius.full),
                    ),
                    child: Text(
                      '+${a.gap} on wrong answers',
                      style: PantasType.webTag.copyWith(color: t.tintText),
                    ),
                  ),
                ),
              ),
            );
          }
        } else if (a.id == TendencyId.howYouAnswer) {
          content
              .add(pair(number(a.leftLabel, null), number(a.rightLabel, null)));
        }
      case TendencyId.howYouStudy:
        final share = clear ? value(a.leftFigure) / 100 : .5;
        content.addAll([
          ClipRRect(
            borderRadius: BorderRadius.circular(PantasRadius.full),
            child: SizedBox(
              height: PantasSpace.s12,
              // The phone's chart draw: 900 ms from empty to the value.
              child: TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: MediaQuery.disableAnimationsOf(context) ? 1 : 0,
                  end: 1,
                ),
                duration: PantasDurations.long3,
                curve: PantasCurves.house,
                builder: (_, grow, child) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(widthFactor: grow, child: child),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: math.max(1, (share * 1000).round()),
                      child: ColoredBox(
                        color: clear ? t.colors.accent : t.strongDivider,
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const SizedBox(width: PantasSpace.s2),
                    Expanded(
                      flex: math.max(1, ((1 - share) * 1000).round()),
                      child: ColoredBox(
                        color: clear
                            ? t.colors.accent.withValues(alpha: .35)
                            : t.colors.divider,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: PantasSpace.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${a.leftLabel}${clear ? ' · ${a.leftFigure}' : ''}',
                style: t.sm,
              ),
              Text(
                '${a.rightLabel}${clear ? ' · ${a.rightFigure}' : ''}',
                style: t.sm,
              ),
            ],
          ),
        ]);
      case TendencyId.howLongYouRemember:
        content.add(
          pair(
            number(a.leftLabel, a.leftFigure),
            number(a.rightLabel, a.rightFigure),
          ),
        );
      case TendencyId.stamina:
        content.addAll([
          if (clear) ...[
            Text('Accuracy in your mocks', style: t.sm),
            const SizedBox(height: PantasSpace.s8),
          ],
          SizedBox(
            height: PantasSpace.s56 + PantasSpace.s24,
            width: double.infinity,
            child: CustomPaint(
              painter: _StaminaLine(
                left: clear ? value(a.leftFigure) : null,
                right: clear ? value(a.rightFigure) : null,
                color: clear ? t.colors.accent : t.strongDivider,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(a.leftLabel, style: t.sm),
              Text(a.rightLabel, style: t.sm),
            ],
          ),
          if (pro && forming)
            Padding(
              padding: const EdgeInsets.only(top: PantasSpace.s14),
              child: Text('Needs more usage data', style: t.sm),
            ),
        ]);
    }
    return WebCard(
      padding: const EdgeInsets.symmetric(
        horizontal: PantasSpace.s24,
        vertical: PantasSpace.s20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            a.heading.toUpperCase(),
            style:
                t.sm.copyWith(fontWeight: FontWeight.w600, letterSpacing: .26),
          ),
          const SizedBox(height: PantasSpace.s14),
          Text(
            caption,
            style: PantasType.webBody.copyWith(
              height: 1.45,
              color: clear ? t.colors.textPrimary : t.colors.textSecondary,
            ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: PantasSpace.s14),
            ...content,
          ],
          if (pro &&
              !clear &&
              !forming &&
              missing &&
              a.unlockAction.isNotEmpty) ...[
            const SizedBox(height: PantasSpace.s14),
            Text(
              a.unlockAction,
              style: PantasType.webTitleSm.copyWith(color: t.colors.accent),
            ),
          ],
        ],
      ),
    );
  }
}

class _StaminaLine extends CustomPainter {
  const _StaminaLine({
    required this.left,
    required this.right,
    required this.color,
  });
  final double? left;
  final double? right;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    double y(double? value) => value == null
        ? size.height / 2
        : size.height * (1 - value.clamp(0, 100) / 100);
    canvas.drawLine(
      Offset(6, y(left)),
      Offset(size.width - 6, y(right)),
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_StaminaLine oldDelegate) =>
      oldDelegate.left != left ||
      oldDelegate.right != right ||
      oldDelegate.color != color;
}
