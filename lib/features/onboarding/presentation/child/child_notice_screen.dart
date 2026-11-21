import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/onboarding/presentation/child/child_nickname_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/child_step_frame.dart';

/// Board N2C: the short notice the child sees after the parent set the
/// account up and before the nickname step (legal draft, layer b).
///
/// The board has no Continue button. "Ask My Parent or Guardian" hands the
/// device to the parent for the nickname step, which speaks to the parent.
/// "Read More for Kids" opens the fuller page and comes back here.
class ChildNoticeScreen extends StatelessWidget {
  const ChildNoticeScreen({this.onAskParent, this.onReadMore, super.key});

  /// Defaults to the nickname step.
  final VoidCallback? onAskParent;

  /// Defaults to the child-friendly page of the Child Notice.
  final VoidCallback? onReadMore;

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: ChildStepFrame(
          title: ChildSetupCopy.noticeTitle,
          // The board's root screen starts 16 from the top, then the title.
          topPadding: 22,
          actions: [
            ChildStepButton(
              label: ChildSetupCopy.readMore,
              onPressed: onReadMore ??
                  () => GoRouter.maybeOf(context)
                      ?.push<void>('/legal/child-notice-kids'),
            ),
            ChildStepButton(
              kind: ChildStepButtonKind.neutral,
              label: ChildSetupCopy.askParent,
              onPressed: onAskParent ??
                  () => GoRouter.maybeOf(context)?.go(childNicknamePath),
            ),
          ],
          children: const [
            ChildStepText(ChildSetupCopy.noticeKeep),
            ChildStepText(ChildSetupCopy.noticeConsent),
            ChildStepText(ChildSetupCopy.noticeMore),
          ],
        ),
      );
}
