import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/compute_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePlanCard extends StatefulWidget {
  const HomePlanCard({
    required this.view,
    this.proIsActive = false,
    super.key,
  });

  final PlanView view;
  final bool proIsActive;

  @override
  State<HomePlanCard> createState() => _HomePlanCardState();
}

class _HomePlanCardState extends State<HomePlanCard> {
  bool _showProChip = false;
  bool _showProSeam = false;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's focus", style: textStyles.labelLarge),
          const SizedBox(height: 6),
          Text(widget.view.today.headline, style: textStyles.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '${widget.view.weeksToExam} weeks to exam · '
            '${_paceLabel(widget.view.paceStatus.name)}',
            style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'See plan',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go('/plan'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'See more',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    setState(() {
                      _showProChip = !widget.proIsActive;
                      _showProSeam = widget.proIsActive;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_showProChip) ...[
            const SizedBox(height: 12),
            ActionChip(
              label: const Text('Pro shows the full breakdown - Try Pro free'),
              avatar: const Icon(Icons.lock_open, size: 18),
              onPressed: () => context.go('/paywall?returnTo=/plan'),
            ),
          ],
          if (_showProSeam) ...[
            const SizedBox(height: 12),
            const Text('Subtopic depth ready'),
          ],
        ],
      ),
    );
  }

  static String _paceLabel(String value) {
    return switch (value) {
      'onPace' => 'On pace',
      'behind' => 'Behind',
      'ahead' => 'Ahead',
      _ => value,
    };
  }
}
