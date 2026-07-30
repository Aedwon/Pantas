import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_review_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockReviewPage extends ConsumerWidget {
  const MockReviewPage({
    required this.attemptId,
    required this.proIsActive,
    super.key,
  });

  final String attemptId;
  final bool proIsActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(mockReviewProvider(attemptId));
    final markedAsync = ref.watch(mockMarkedQuestionIdsProvider(attemptId));
    final handledAsync = ref.watch(mockOfferHandledProvider(attemptId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('All questions'),
      ),
      body: reviewAsync.when(
        data: (entries) {
          final markedIds = markedAsync.valueOrNull ?? const {};
          final offerHandled = handledAsync.valueOrNull ?? true;
          final showOffer = !offerHandled && markedIds.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ReviewList(
              entries: entries,
              proIsActive: proIsActive,
              grouped: true,
              onToggleFlag: (questionId) async {
                final repo = ref.read(questionFlagsRepositoryProvider);
                final currentlyFlagged = await repo.isFlagged(questionId);
                if (currentlyFlagged) {
                  await repo.unflag(questionId);
                } else {
                  await repo.flag(questionId);
                }
                ref.invalidate(mockReviewProvider(attemptId));
              },
              header: showOffer
                  ? _FlagOffer(
                      count: markedIds.length,
                      onKeep: () async {
                        final flagRepo =
                            ref.read(questionFlagsRepositoryProvider);
                        for (final qId in markedIds) {
                          await flagRepo.flag(qId);
                        }
                        final prefsRepo =
                            ref.read(appPreferencesRepositoryProvider);
                        await prefsRepo.setDeviceValue(
                          'mock_flag_offer_handled_$attemptId',
                          'true',
                        );
                        ref
                          ..invalidate(mockOfferHandledProvider(attemptId))
                          ..invalidate(mockReviewProvider(attemptId));
                      },
                      onDismiss: () async {
                        final prefsRepo =
                            ref.read(appPreferencesRepositoryProvider);
                        await prefsRepo.setDeviceValue(
                          'mock_flag_offer_handled_$attemptId',
                          'true',
                        );
                        ref.invalidate(mockOfferHandledProvider(attemptId));
                      },
                    )
                  : null,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _FlagOffer extends StatelessWidget {
  const _FlagOffer({
    required this.count,
    required this.onKeep,
    required this.onDismiss,
  });

  final int count;
  final VoidCallback onKeep;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.rule),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'You marked $count to come back to while the clock was '
            'running. Keep them to practice?',
            style: styles.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BoardButton(
                  label: 'Flag all $count',
                  onPressed: onKeep,
                  secondary: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BoardButton(
                  label: 'No thanks',
                  onPressed: onDismiss,
                  secondary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
