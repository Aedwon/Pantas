import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';
import 'package:pantas/features/beta_feedback/presentation/reward_card.dart';

/// The page the Home reward notice opens: the reward card, where an earned
/// year of Pro is turned on. A tester with no earned reward has nothing here
/// and goes back to Home.
class RewardPage extends ConsumerWidget {
  const RewardPage({required this.frame, super.key});
  final FeedbackFrame frame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(betaAccessProvider);
    final reward = ref.watch(betaRewardProvider);
    final now = ref.watch(betaFeedbackClockProvider)();
    final data = reward.valueOrNull;

    final Widget body;
    if (data != null && (data.eligible || data.activated)) {
      body = RewardCard(reward: data, now: now);
    } else if (reward.isLoading || access.isLoading) {
      body = const _RewardSkeleton();
    } else if (reward.hasError) {
      body = _RewardError(onRetry: () => ref.invalidate(betaRewardProvider));
    } else {
      // Loaded, and no reward to turn on.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/home');
      });
      body = const SizedBox.shrink();
    }

    return frame(
      title: 'Beta reward',
      backLabel: 'Home',
      onBack: () => leavePage(context, fallback: '/home'),
      children: [body],
    );
  }
}

/// The reward card while the status loads.
class _RewardSkeleton extends StatelessWidget {
  const _RewardSkeleton();

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

class _RewardError extends StatelessWidget {
  const _RewardError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FbCard(
        padding: const EdgeInsets.all(PantasSpace.s16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Could not load your reward.',
                style: context.fbSub,
              ),
            ),
            PantasButton(
              label: 'Try Again',
              onPressed: onRetry,
              kind: PantasButtonKind.tertiary,
              tone: PantasButtonTone.accent,
              fullWidth: false,
            ),
          ],
        ),
      );
}
