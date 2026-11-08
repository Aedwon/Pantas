import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/compose_card.dart';
import 'package:pantas/features/beta_feedback/presentation/days_card.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';
import 'package:pantas/features/beta_feedback/presentation/reward_card.dart';
import 'package:pantas/features/beta_feedback/presentation/sent_list.dart';

export 'package:pantas/features/beta_feedback/presentation/compose_card.dart'
    show addImageKey, removeKey;

/// The Feedback (Beta) page: days, the feedback box and what was sent.
class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({required this.frame, super.key});
  final FeedbackFrame frame;

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  SentFeedback? _justSent;

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final reward = ref.watch(betaRewardProvider);
    final now = ref.watch(betaFeedbackClockProvider)();
    var sent = ref.watch(sentFeedbackProvider).valueOrNull ?? const [];
    final extra = _justSent;
    if (extra != null && !sent.any((s) => s.id == extra.id)) {
      sent = [extra, ...sent];
    }
    final data = reward.valueOrNull;

    final Widget top;
    if (data != null && (data.eligible || data.activated)) {
      // The reward replaces the top days card; the days move below it.
      top = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RewardCard(reward: data, now: now),
          const SizedBox(height: PantasSpace.s24),
          DaysCard(reward: data, now: now, condensed: true),
        ],
      );
    } else if (data != null) {
      top = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DaysCard(reward: data, now: now),
          const FbFootnote(
            'Count 5 days from Nov 9 to 15 and send the exit survey to '
            'earn 1 year of Pro.',
          ),
        ],
      );
    } else if (reward.hasError) {
      top = _DaysError(onRetry: () => ref.invalidate(betaRewardProvider));
    } else {
      top = const _DaysSkeleton();
    }

    return widget.frame(
      title: 'Feedback',
      beta: true,
      backLabel: 'Settings',
      onBack: () => leavePage(context, fallback: '/settings'),
      children: [
        top,
        SizedBox(height: wide ? 24 : 24),
        const FbSectionHeader('SEND FEEDBACK'),
        FeedbackCompose(onSent: (s) => setState(() => _justSent = s)),
        SentSection(items: sent),
      ],
    );
  }
}

/// The days card while the days load. No count is drawn: none is known.
class _DaysSkeleton extends StatelessWidget {
  const _DaysSkeleton();

  @override
  Widget build(BuildContext context) => const FbCard(
        child: SkeletonPulse(
          child: Padding(
            padding: EdgeInsets.all(PantasSpace.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 120, height: 24),
                SizedBox(height: PantasSpace.s8),
                SkeletonBlock(width: 240, height: 15),
                SizedBox(height: PantasSpace.s20),
                SkeletonBlock(width: double.infinity, height: 56),
              ],
            ),
          ),
        ),
      );
}

class _DaysError extends StatelessWidget {
  const _DaysError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FbCard(
        padding: const EdgeInsets.all(PantasSpace.s16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Could not load your days.',
                style: context.fbSub,
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      );
}
