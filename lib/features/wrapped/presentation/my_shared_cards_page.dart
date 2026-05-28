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
    final asyncCards = ref.watch(sharedWrappedCardsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My shared cards')),
      body: asyncCards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Shared cards are unavailable.')),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'You have no shared cards. Share a Wrapped card to create a '
                  'public pantas.app link.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final card = cards[index];
              return Card(
                child: ListTile(
                  title: Text(card.title),
                  subtitle: Text('pantas.app/wrapped/${card.shareId}'),
                  trailing: TextButton(
                    onPressed: () => _revoke(ref, card),
                    child: const Text('Revoke'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _revoke(WidgetRef ref, HostedWrappedCard card) async {
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
