import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
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
            WebTendencyProfile(data: data, onName: onName),
            const SizedBox(height: 26),
            const WebText('What we found', kind: WebTextKind.eyebrow),
            for (var index = 0; index < data.tendencies.length; index += 2) ...[
              if (index > 0) const SizedBox(height: 14),
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
                    const SizedBox(width: 14),
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
              const SizedBox(height: 26),
              if (paused)
                const ProPausedLine()
              else
                WebCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: context.webTokens.colors.accent,
                        size: 22,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          'Unlock complete insights into your study habits, '
                          'pacing, and working hours.',
                          style: context.webTokens.style(17, height: 1.45),
                        ),
                      ),
                      const SizedBox(width: 18),
                      WebButton(label: 'Unlock with Pro', onPressed: onPro),
                    ],
                  ),
                ),
            ] else if (data.whenYouWork.isNotEmpty) ...[
              const SizedBox(height: 26),
              const WebText('When you work', kind: WebTextKind.eyebrow),
              WebCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final row in data.whenYouWork)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 18,
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
        padding: const EdgeInsets.all(24),
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
                style: t.style(26, color: t.colors.tertiaryLabel),
              ),
            ),
            const SizedBox(width: 18),
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
                        style: t.style(
                          15,
                          weight: FontWeight.w600,
                          color: t.colors.accent,
                        ),
                      ),
                    )
                  else
                    Text(data.name!, style: t.sub),
                  const SizedBox(height: 4),
                  Text(
                    'Needs more usage data',
                    style: t.h3.copyWith(color: t.colors.tertiaryLabel),
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
        color: const Color(0xff1d1d1f),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Positioned(
            right: -34,
            child: Transform.rotate(
              angle: -8 * math.pi / 180,
              child: Icon(glyph, size: 150, color: const Color(0xff3a3a3d)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 26, 124, 28),
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
                    style: t.style(
                      15,
                      weight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: .6),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  data.archetype!,
                  style: t
                      .style(
                        30,
                        weight: FontWeight.w700,
                        height: 1.1,
                        color: Colors.white,
                      )
                      .copyWith(letterSpacing: -.6),
                ),
                if (data.archetypeLine != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    data.archetypeLine!,
                    style: t.style(
                      17,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: .78),
                    ),
                  ),
                ],
              ],
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
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
    Widget number(String label, String? value) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: t.colors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clear ? value! : '–',
                style: t.style(
                  26,
                  weight: FontWeight.w700,
                  color: clear ? t.colors.label : t.colors.tertiaryLabel,
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
            SizedBox(width: 92, child: Text(label, style: t.sm)),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 10,
                  child: ColoredBox(
                    color: t.disabledBackground,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: fraction.clamp(0, 1),
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
            const SizedBox(width: 12),
            SizedBox(
              width: 40,
              child: Text(
                clear ? figure! : '',
                textAlign: TextAlign.right,
                style: t.style(16, weight: FontWeight.w600),
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
              clear ? t.colors.accent : t.colors.separator,
            ),
            const SizedBox(height: 12),
            bar(
              a.rightLabel,
              a.rightFigure,
              clear ? fraction(a.rightFigure) : .45,
              clear
                  ? t.colors.accent.withValues(alpha: .55)
                  : t.colors.separator,
            ),
          ]);
          if (clear && pressure) {
            content.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(104, 12, 52, 0),
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
                padding: const EdgeInsets.only(top: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: t.colors.accentTint,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '+${a.gap} on wrong answers',
                      style: t.style(
                        12,
                        weight: FontWeight.w600,
                        color: t.tintText,
                      ),
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
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: math.max(1, (share * 1000).round()),
                    child: ColoredBox(
                      color: clear ? t.colors.accent : t.strongDivider,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: math.max(1, ((1 - share) * 1000).round()),
                    child: ColoredBox(
                      color: clear
                          ? t.colors.accent.withValues(alpha: .35)
                          : t.colors.separator,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
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
            const SizedBox(height: 8),
          ],
          SizedBox(
            height: 80,
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
              padding: const EdgeInsets.only(top: 14),
              child: Text('Needs more usage data', style: t.sm),
            ),
        ]);
    }
    return WebCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            a.heading.toUpperCase(),
            style:
                t.sm.copyWith(fontWeight: FontWeight.w600, letterSpacing: .26),
          ),
          const SizedBox(height: 14),
          Text(
            caption,
            style: t.style(
              16,
              height: 1.45,
              color: clear ? t.colors.label : t.colors.tertiaryLabel,
            ),
          ),
          if (content.isNotEmpty) ...[const SizedBox(height: 14), ...content],
          if (pro &&
              !clear &&
              !forming &&
              missing &&
              a.unlockAction.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              a.unlockAction,
              style: t.style(
                16,
                weight: FontWeight.w600,
                color: t.colors.accent,
              ),
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
