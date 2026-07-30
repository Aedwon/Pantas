import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/tendencies_provider.dart';
import 'package:flutter/material.dart';

class TendencyCardView extends StatelessWidget {
  const TendencyCardView({
    required this.card,
    required this.isPro,
    super.key,
  });

  final TendencyCard card;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    final hasFigures = card.figures != null;

    Widget body;
    if (!isPro) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.heading,
            style: styles.labelSmall.copyWith(color: colors.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      card.leftLabel,
                      style: styles.bodySmall.copyWith(color: colors.inkMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: SizedBox(
                        width: 48,
                        child: FaintBars(widthFactors: [1.0]),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      card.rightLabel,
                      style: styles.bodySmall.copyWith(color: colors.inkMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: SizedBox(
                        width: 48,
                        child: FaintBars(widthFactors: [1.0]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    } else if (!hasFigures) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.heading,
            style: styles.labelSmall.copyWith(color: colors.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  card.leftLabel,
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  card.rightLabel,
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Not enough data yet',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            card.unlockAction,
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.heading,
            style: styles.labelSmall.copyWith(color: colors.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      card.leftLabel,
                      style: styles.bodySmall.copyWith(color: colors.inkMuted),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      card.figures!.left,
                      style: styles.headlineMedium.copyWith(color: colors.ink),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      card.rightLabel,
                      style: styles.bodySmall.copyWith(color: colors.inkMuted),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      card.figures!.right,
                      style: styles.headlineMedium.copyWith(color: colors.ink),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (card.sentence != null) ...[
            const SizedBox(height: 4),
            Text(
              card.sentence!,
              style: styles.bodySmall.copyWith(color: colors.ink),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }

    return SizedBox(
      height: 112,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: body,
        ),
      ),
    );
  }
}
