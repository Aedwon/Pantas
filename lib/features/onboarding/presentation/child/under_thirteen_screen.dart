import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/onboarding/presentation/child/child_step_frame.dart';

/// Where the age step sends a child under 13.
const String underThirteenPath = '/onboarding/child';

/// Board 1A: what a child under 13 sees. The device stays here, so there is no
/// Back. A parent or guardian takes it from the main button; the text button
/// opens what they agree to.
///
/// When the server reports child setup closed (Decision 9 item 9), the screen
/// stays, drops the guardian button and says Pantas is for ages 13 and up for
/// now.
class UnderThirteenScreen extends ConsumerWidget {
  const UnderThirteenScreen({this.onGuardian, this.onNotice, super.key});

  /// Defaults to the parent sign-in.
  final VoidCallback? onGuardian;

  /// Defaults to the Child Notice.
  final VoidCallback? onNotice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closed = ref.watch(childSetupClosedProvider);
    return PopScope(
      canPop: false,
      child: ChildStepFrame(
        centered: true,
        topPadding: PantasSpace.s8,
        actions: [
          if (!closed)
            ChildStepButton(
              label: ChildSetupCopy.underThirteenGuardian,
              onPressed: onGuardian ??
                  () => GoRouter.maybeOf(context)
                      ?.push<void>('/onboarding/child/sign-in'),
            ),
          ChildStepButton(
            kind: ChildStepButtonKind.text,
            label: ChildSetupCopy.underThirteenNotice,
            // TODO(T11): the Child Notice document ships with the legal task.
            onPressed: onNotice ??
                () => GoRouter.maybeOf(context)
                    ?.push<void>('/legal/child-notice'),
          ),
        ],
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s24),
            child: StateView.onboardingBlocked(
              message: closed
                  ? ChildSetupCopy.closedTitle
                  : ChildSetupCopy.underThirteenTitle,
              detail: closed ? null : ChildSetupCopy.underThirteenBody,
              icon: const ChildPeopleMark(),
            ),
          ),
        ],
      ),
    );
  }
}
