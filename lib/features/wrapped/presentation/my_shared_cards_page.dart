import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/wrapped/application/wrapped_providers.dart';
import 'package:cse_cet_reviewer/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lists the user's hosted Wrapped cards and lets them revoke a public link
/// (landing-page spec §5.2). Revoking falls the link back to the generic page.
class MySharedCardsPage extends ConsumerWidget {
  const MySharedCardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final asyncCards = ref.watch(sharedWrappedCardsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My shared cards')),
      body: asyncCards.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: const [FaintBars()],
        ),
        error: (_, __) => Center(
          child: Text(
            'Shared cards are unavailable.',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
        ),
        data: (cards) {
          if (cards.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                Text('No shared cards yet', style: styles.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  'Share a Wrapped card to create a public pantas.app link.',
                  style: styles.bodyMedium.copyWith(color: colors.inkMuted),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              for (final card in cards) _SharedCardRow(card: card),
            ],
          );
        },
      ),
    );
  }
}

class _SharedCardRow extends ConsumerWidget {
  const _SharedCardRow({required this.card});

  final HostedWrappedCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.ruleFaint,
            // ignore: avoid_redundant_argument_values
            width: AppDimensions.hairline,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title, style: styles.bodyMedium),
                const SizedBox(height: 1),
                Text(
                  'pantas.app/wrapped/${card.shareId}',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _revoke(ref),
            child: Text(
              'Revoke',
              style: styles.labelLarge.copyWith(color: colors.rust),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _revoke(WidgetRef ref) async {
    await ref.read(wrappedShareHostProvider).revoke(
          uid: card.userId,
          shareId: card.shareId,
        );
    await ref.read(userMetricsArtifactRepositoryProvider).setLocalRevoked(
          userId: card.userId,
          examId: card.examId,
          artifactId: card.artifactId,
        );
    ref.invalidate(sharedWrappedCardsProvider);
  }
}
