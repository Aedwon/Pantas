import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ruled_panel.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/progress/application/miss_causes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WhyYouMissSection extends ConsumerWidget {
  const WhyYouMissSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final causesAsync = ref.watch(missCausesProvider);
    final entitlement = ref.watch(entitlementProvider).valueOrNull;

    return causesAsync.when(
      data: (causes) {
        if (causes == null || causes.total == 0) {
          return const SizedBox.shrink();
        }

        final proIsActive = entitlement?.proIsActive ?? false;

        return RuledPanel(
          heading: 'Why you miss questions',
          child: proIsActive
              ? _buildProContent(context, causes)
              : _buildFreeContent(context),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildProContent(BuildContext context, MissCauses causes) {
    final styles = context.textStyles;
    final colors = context.colors;

    final sentence = _interpretingSentence(causes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Centred as a block, not each line on its own.
        //
        // Flush left they sat against the panel's edge with a long ragged gap
        // to the right of each label. Centring them one by one would have
        // been worse: the labels are different lengths, so the numerals would
        // no longer line up under each other. `IntrinsicWidth` sizes the
        // group to its widest line and centres that, which keeps the numeral
        // column and the labels aligned inside it.
        Center(
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CauseLine(
                  count: causes.hadItRightBefore,
                  label: 'had it right before',
                ),
                _CauseLine(
                  count: causes.neverSeenIt,
                  label: 'never seen it',
                ),
                _CauseLine(
                  count: causes.answeredTooFast,
                  label: 'answered too fast',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sentence,
          style: styles.bodyMedium.copyWith(color: colors.ink),
        ),
        if (causes.selfNotedMisreads > 0) ...[
          const SizedBox(height: 10),
          Text(
            'You noted ${causes.selfNotedMisreads} '
            '${causes.selfNotedMisreads == 1 ? 'misread' : 'misreads'} '
            'yourself.',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      ],
    );
  }

  String _interpretingSentence(MissCauses causes) {
    final right = causes.hadItRightBefore;
    final never = causes.neverSeenIt;
    final fast = causes.answeredTooFast;

    if (right >= never && right >= fast) {
      return 'You mostly know this material already. What is missing is a '
          'second pass, not a first one.';
    } else if (never >= fast) {
      return 'Most of these are questions you have not met before. This is '
          'new ground, not lost ground.';
    } else {
      return 'Most of these went by quickly. Slowing down on the ones you '
          'are unsure of would cost you very little time.';
    }
  }

  Widget _buildFreeContent(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaintBars(widthFactors: [0.5]),
                  const SizedBox(height: 4),
                  Text(
                    'had it right before',
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaintBars(widthFactors: [0.5]),
                  const SizedBox(height: 4),
                  Text(
                    'never seen it',
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaintBars(widthFactors: [0.5]),
                  const SizedBox(height: 4),
                  Text(
                    'answered too fast',
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'See why your wrong answers are wrong, derived from your own pace '
          'and attempt history.',
          style: styles.bodyMedium.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 12),
        // On the right margin, where the other section actions sit.
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.push('/paywall'),
            child: Text(
              'Unlock with Pro',
              style: styles.bodyMedium.copyWith(
                color: colors.board,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One miss cause: the count, then what it means.
///
/// The numeral sits in a fixed right-aligned column so a 3 and a 12 put
/// their labels in the same place. Tabular figures for the same reason.
class _CauseLine extends StatelessWidget {
  const _CauseLine({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        // Shrink wrapped so the group above can size to its widest line.
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: styles.displayLarge.copyWith(
                fontSize: 21,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Flexible, not plain: the row shrink wraps so the group can size
          // to its widest line, but on a narrow phone the label still has to
          // be allowed to wrap rather than overflow.
          Flexible(
            child: Text(
              label,
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
