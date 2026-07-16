import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/confirmation_dialog.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PausePage extends StatelessWidget {
  const PausePage({
    required this.partName,
    required this.remaining,
    required this.answered,
    required this.total,
    required this.flagged,
    required this.onResume,
    required this.onDiscard,
    super.key,
  });

  final String partName;
  final Duration remaining;
  final int answered;
  final int total;
  final int flagged;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  void _confirmDiscard(BuildContext context) {
    showAppConfirmationDialog(
      context: context,
      title: 'Discard this paper?',
      body:
          'Your progress in this mock will be discarded. This paper will be deleted and does not use up a mock.',
      cancelLabel: 'Keep going',
      confirmLabel: 'Discard',
      isDestructive: true,
      onCancel: () {},
      onConfirm: onDiscard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paused.',
                  style: textStyles.displayMedium.copyWith(
                    fontFamily: 'SourceSerif4',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  partName,
                  style: textStyles.bodyRegular.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
                const SizedBox(height: 32),
                const SectionHeader(title: 'Time left'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formatRemaining(remaining),
                      style: textStyles.displayLarge.copyWith(
                        fontFamily: 'SourceSerif4',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: colors.ink,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'in this part',
                      style: textStyles.mathBody.copyWith(
                        fontFamily: 'SourceSerif4',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colors.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$answered of $total answered · $flagged flagged',
                  style: textStyles.bodyRegular.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The clock is stopped. It starts again when you resume.',
                  style: textStyles.bodyRegular.copyWith(
                    color: colors.ink,
                  ),
                ),
                const Spacer(),
                BoardButton(
                  label: 'Resume',
                  onPressed: onResume,
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => _confirmDiscard(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Text(
                        'Discard this paper',
                        style: textStyles.labelLarge.copyWith(
                          color: colors.rust,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
