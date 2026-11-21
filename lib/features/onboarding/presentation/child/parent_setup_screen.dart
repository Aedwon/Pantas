import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/onboarding/presentation/child/child_step_frame.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

/// Where the child's short notice is shown, right after setup.
const String childNoticePath = '/onboarding/child/notice';

/// Where the parent signs in.
const String childSignInPath = '/onboarding/child/sign-in';

/// Board 2A: the parent or guardian gives two separate ticks, each in its own
/// card, and sets the account up. Neither tick is on at the start, and the
/// button stays off until both are. The server records the ticks; this screen
/// sends only the text versions it showed.
class ParentSetupScreen extends ConsumerStatefulWidget {
  const ParentSetupScreen({
    this.onBack,
    this.onSetUp,
    this.onUseAnotherEmail,
    this.onOpenTerms,
    this.onOpenChildNotice,
    super.key,
  });

  /// Defaults to the under-13 screen.
  final VoidCallback? onBack;

  /// Defaults to the short child notice.
  final VoidCallback? onSetUp;

  /// Defaults to signing out and returning to the parent sign-in.
  final Future<void> Function()? onUseAnotherEmail;

  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenChildNotice;

  @override
  ConsumerState<ParentSetupScreen> createState() => _ParentSetupScreenState();
}

class _ParentSetupScreenState extends ConsumerState<ParentSetupScreen> {
  bool _terms = false;
  bool _childData = false;
  bool _busy = false;
  ChildSetupFailure? _failure;
  bool _dismissed = false;

  /// The email holds an account that has progress, so a retry with the same
  /// email fails the same way. The button stays off until the email changes.
  bool get _emailRefused => _failure == ChildSetupFailure.emailHasAccount;

  bool get _ready => _terms && _childData && !_busy && !_emailRefused;

  Future<void> _setUp() async {
    if (!_ready) return;
    setState(() {
      _busy = true;
      _failure = null;
      _dismissed = false;
    });
    try {
      final result =
          await ref.read(childSetupGatewayProvider).setupChildAccount();
      // The child's own session starts now; the parent's session ends there.
      await ref.read(childSessionStarterProvider).start(
            childUid: result.childUid,
            customToken: result.customToken,
          );
      if (!mounted) return;
      ref.read(pendingChildIdProvider.notifier).state = result.childUid;
      final custom = widget.onSetUp;
      if (custom != null) return custom();
      GoRouter.maybeOf(context)?.go(childNoticePath);
    } on ChildSetupException catch (error) {
      if (!mounted) return;
      if (error.failure == ChildSetupFailure.childAccountsClosed) {
        // Decision 9 item 9: the device stays on the under-13 screen.
        ref.read(childSetupClosedProvider.notifier).state = true;
        _backToUnderThirteen();
        return;
      }
      setState(() => _failure = error.failure);
    } on Object {
      if (mounted) setState(() => _failure = ChildSetupFailure.other);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _backToUnderThirteen() {
    final custom = widget.onBack;
    if (custom != null) return custom();
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/onboarding');
    }
  }

  Future<void> _useAnotherEmail() async {
    final custom = widget.onUseAnotherEmail;
    if (custom != null) return custom();
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) GoRouter.maybeOf(context)?.go(childSignInPath);
  }

  void _open(String path, VoidCallback? custom) {
    if (custom != null) return custom();
    unawaited(GoRouter.maybeOf(context)?.push<void>(path));
  }

  /// One tick's text with its link set inside the sentence.
  Widget _label(String lead, String link, String tail, VoidCallback open) {
    final style = PantasType.webRowTitleSettings.copyWith(
      color: context.colors.textPrimary,
    );
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: lead),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: WebTextLink(
              label: link,
              arrow: false,
              style: style,
              onPressed: open,
            ),
          ),
          TextSpan(text: tail),
        ],
      ),
    );
  }

  Widget _tick({
    required String name,
    required bool value,
    required String lead,
    required String link,
    required String tail,
    required VoidCallback open,
    required VoidCallback onChanged,
  }) =>
      Semantics(
        container: true,
        label: name,
        child: GroupedSection(
          children: [
            CheckboxRow(
              title: '$lead$link$tail',
              selected: value,
              interactiveContent: true,
              alignTop: true,
              standardDensity: true,
              padding: const EdgeInsets.all(PantasSpace.s20),
              onTap: _busy ? null : onChanged,
              content: _label(lead, link, tail, open),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final failure = _failure;
    return OnboardingWebPage(
      title: ChildSetupCopy.setupTitle,
      detail: ChildSetupCopy.setupLead,
      onBack: _backToUnderThirteen,
      bodyGap: childStepGap,
      bottom: OnboardingButton(
        label: ChildSetupCopy.setUpAccount,
        busy: _busy,
        onPressed: _ready ? () => unawaited(_setUp()) : null,
      ),
      children: [
        if (failure != null && !_dismissed) ...[
          ChildStepNotice(
            title: failure.message,
            onClose: () => setState(() => _dismissed = true),
            actionLabel: switch (failure) {
              ChildSetupFailure.emailHasAccount =>
                ChildSetupCopy.useAnotherEmail,
              ChildSetupFailure.namedSignInRequired =>
                ChildSetupCopy.signInAgain,
              _ => null,
            },
            onAction: () => unawaited(_useAnotherEmail()),
          ),
          const SizedBox(height: childStepGap),
        ],
        _tick(
          name: 'Terms',
          value: _terms,
          lead: ChildSetupCopy.tick1Lead,
          link: ChildSetupCopy.tick1Link,
          tail: ChildSetupCopy.tick1Tail,
          open: () => _open('/legal/terms', widget.onOpenTerms),
          onChanged: () => setState(() => _terms = !_terms),
        ),
        const SizedBox(height: PantasSpace.s12),
        _tick(
          name: 'Child data',
          value: _childData,
          lead: ChildSetupCopy.tick2Lead,
          link: ChildSetupCopy.tick2Link,
          tail: ChildSetupCopy.tick2Tail,
          open: () => _open('/legal/child-notice', widget.onOpenChildNotice),
          onChanged: () => setState(() => _childData = !_childData),
        ),
      ],
    );
  }
}
