import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/data_row_tile.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ruled_panel.dart';
import 'package:pantas/core/ui/components/section_header.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/how_you_work_provider.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/progress/presentation/widgets/gap_comparison.dart';

class HowYouWorkPage extends ConsumerWidget {
  const HowYouWorkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final styles = context.textStyles;

    final howYouWorkAsync = ref.watch(howYouWorkProvider);
    final entitlement =
        ref.watch(entitlementProvider).valueOrNull ?? const Entitlement.free();
    final isPro = entitlement.proIsActive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How you work'),
      ),
      body: howYouWorkAsync.when(
        data: (work) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Panel
                RuledPanel(
                  heading: 'Your profile',
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      if (work.name != null)
                        Text(
                          work.name!,
                          style: styles.displaySmall.copyWith(
                            fontFamily: 'SourceSans3',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          ),
                          textAlign: TextAlign.center,
                        )
                      else
                        InkWell(
                          // The name row sits on the Settings home, not the
                          // account page, and Home's masthead sends the same
                          // invitation to the same place.
                          onTap: () => context.push('/settings'),
                          child: Text(
                            'Add your name',
                            style: styles.displaySmall.copyWith(
                              fontFamily: 'SourceSans3',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: colors.board,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (work.archetype != null)
                        Text(
                          work.archetype!,
                          style: styles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (work.archetypeLine != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          work.archetypeLine!,
                          style: styles.bodySmall.copyWith(
                            fontSize: 12,
                            color: colors.inkMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Five tendencies
                for (final tendency in work.tendencies) ...[
                  SectionHeader(title: tendency.heading),
                  GapComparison(
                    tendency: tendency,
                    isPro: isPro,
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. When you work (Pro only)
                if (isPro && work.whenYouWork.isNotEmpty) ...[
                  const SectionHeader(title: 'When you work'),
                  for (final row in work.whenYouWork)
                    DataRowTile(
                      title: row.title,
                      subtext: row.subtext,
                      primaryFigure: row.meta,
                    ),
                  const SizedBox(height: 16),
                ],

                // 4. Free teaser (sits after fifth tendency when not Pro)
                if (!isPro) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock complete insights into your study habits, '
                        'pacing, and working hours.',
                        style:
                            styles.bodySmall.copyWith(color: colors.inkMuted),
                      ),
                      const SizedBox(height: 12),
                      BoardButton(
                        label: 'Unlock with Pro',
                        onPressed: () => context.push('/paywall'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: FaintBars(),
        ),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Could not load your progress.',
            style: styles.bodyMedium.copyWith(color: colors.rust),
          ),
        ),
      ),
    );
  }
}
