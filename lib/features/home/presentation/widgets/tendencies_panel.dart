import 'package:cse_cet_reviewer/core/ui/components/ruled_panel.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/home/application/tendencies_provider.dart';
import 'package:cse_cet_reviewer/features/home/presentation/widgets/tendency_card.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TendenciesPanel extends ConsumerStatefulWidget {
  const TendenciesPanel({super.key});

  @override
  ConsumerState<TendenciesPanel> createState() => _TendenciesPanelState();
}

class _TendenciesPanelState extends ConsumerState<TendenciesPanel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entitlement = ref.watch(entitlementProvider).valueOrNull;
    final isPro = entitlement?.proIsActive ?? false;

    final asyncCards = ref.watch(tendenciesProvider);

    final actionText = isPro ? 'See full details' : 'Unlock with Pro';
    final onAction =
        isPro ? () => context.go('/progress') : () => context.go('/paywall');

    return RuledPanel(
      heading: 'Your tendencies',
      action: actionText,
      onAction: onAction,
      child: asyncCards.when(
        loading: () => const SizedBox(height: 130),
        error: (_, __) => const SizedBox.shrink(),
        data: (cards) {
          if (cards.isEmpty) return const SizedBox.shrink();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 112,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: cards.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return TendencyCardView(
                      card: cards[index],
                      isPro: isPro,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    _TendencyDot(
                      isCurrent: i == _currentPage,
                      hasFigures: cards[i].figures != null,
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TendencyDot extends StatelessWidget {
  const _TendencyDot({
    required this.isCurrent,
    required this.hasFigures,
  });

  final bool isCurrent;
  final bool hasFigures;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isHollow = !hasFigures;

    return Container(
      key: ValueKey(isHollow ? 'tendency-dot-hollow' : 'tendency-dot-solid'),
      width: isCurrent ? 8 : 6,
      height: isCurrent ? 8 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isHollow
            ? Colors.transparent
            : (isCurrent ? colors.ink : colors.rule),
        border: isHollow
            ? Border.all(
                color: isCurrent ? colors.ink : colors.inkMuted,
                width: 1.2,
              )
            : null,
      ),
    );
  }
}
