import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/how_you_work_provider.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/presentation/tendencies_page.dart';
import 'package:pantas/features/home/presentation/widgets/web_record_layout.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

class TendenciesScreen extends ConsumerWidget {
  const TendenciesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final work = ref.watch(howYouWorkProvider);
    void back() => context.canPop() ? context.pop() : context.go('/home');
    if (work.unwrapPrevious().asData == null) {
      if (context.wideWeb) {
        return WebMyPage(
          title: 'Your tendencies',
          onBack: back,
          child: work.hasError
              ? WebMyFailure(
                  onRetry: () {
                    ref.invalidate(howYouWorkProvider);
                    final exam =
                        ref.read(activeExamFocusProvider).valueOrNull?.exam?.id;
                    if (exam != null) {
                      ref.invalidate(serverStudyInsightsProvider(exam));
                    }
                  },
                )
              : const WebMyLoading(),
        );
      }
      return PantasPage(
        title: 'Your tendencies',
        backLabel: 'Home',
        onBack: back,
        children: [
          if (work.hasError)
            errorFor('progress', () {
              ref.invalidate(howYouWorkProvider);
              final exam =
                  ref.read(activeExamFocusProvider).valueOrNull?.exam?.id;
              if (exam != null) {
                ref.invalidate(serverStudyInsightsProvider(exam));
              }
            })
          else
            loadingFor(const AsyncLoading<void>()),
        ],
      );
    }
    final pro = ref.watch(currentStudyCoverageProvider);
    return TendenciesPage(
      data: work.requireValue,
      pro: pro,
      paused: ref.watch(entitlementProvider).valueOrNull?.state ==
          EntitlementState.paused,
      onBack: back,
      onName: () => unawaited(context.push<void>('/settings/account')),
      onPro: () => unawaited(context.push<void>('/settings/pro')),
    );
  }
}
