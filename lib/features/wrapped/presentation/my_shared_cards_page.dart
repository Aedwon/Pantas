import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/wrapped/application/wrapped_providers.dart';
import 'package:pantas/features/wrapped/data/user_metrics_artifact_repository.dart';

/// Lists the user's hosted Wrapped cards and lets them revoke a public link
/// (landing-page spec §5.2). Revoking falls the link back to the generic page.
class MySharedCardsPage extends ConsumerWidget {
  const MySharedCardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.type;
    final colors = context.colors;
    final asyncCards = ref.watch(sharedWrappedCardsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My shared cards')),
      body: asyncCards.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s20,
            PantasSpace.s24,
            PantasSpace.s20,
            PantasSpace.s24,
          ),
          children: const [LoadingShapes()],
        ),
        error: (_, __) => Center(
          child: Text(
            'Shared cards are unavailable.',
            style: styles.subhead.copyWith(color: colors.secondaryLabel),
          ),
        ),
        data: (cards) {
          if (cards.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s20,
                PantasSpace.s24,
                PantasSpace.s20,
                PantasSpace.s24,
              ),
              children: [
                Text('No shared cards yet', style: styles.sectionHero),
                const SizedBox(height: PantasSpace.s6),
                Text(
                  'Share a Wrapped card to create a public pantas.study link.',
                  style: styles.subhead.copyWith(color: colors.secondaryLabel),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s20,
              PantasSpace.s24,
              PantasSpace.s20,
              PantasSpace.s24,
            ),
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
    final styles = context.type;
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: PantasSize.targetTouch),
      padding: const EdgeInsets.symmetric(vertical: PantasSpace.s8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.fill,
            width: PantasBorder.hairline,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title, style: styles.subhead),
                const SizedBox(height: PantasSpace.s2),
                Text(
                  'pantas.study/wrapped/${card.shareId}',
                  style: styles.subhead.copyWith(color: colors.secondaryLabel),
                ),
              ],
            ),
          ),
          const SizedBox(width: PantasSpace.s12),
          PantasButton(
            label: 'Revoke',
            onPressed: () => _revoke(ref),
            kind: PantasButtonKind.tertiary,
            tone: PantasButtonTone.critical,
            fullWidth: false,
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
