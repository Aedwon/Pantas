import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/child_setup/application/child_account_closer.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';
import 'package:pantas/features/child_setup/presentation/guardian_code_gate_page.dart';
import 'package:pantas/features/child_setup/presentation/parents_frame.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// Where the For parents page opens, from the Settings row.
const String forParentsPath = '/settings/parents';

/// What the For parents route is opened with. [confirm] shows that confirm as
/// soon as the page has loaded (the receipt's delete link).
class ForParentsLaunch {
  const ForParentsLaunch({this.confirm});
  final ParentsAction? confirm;
}

/// Board ST4B2: the For parents page, and the four confirms over it (D4W, D4D,
/// D4LW, D4L). Every action asks for the guardian code first (board 8A) and
/// calls the server only with the proof it returns.
///
/// It serves the child's own session ([holderSession] false) and the parent's
/// own session opened by the receipt link ([holderSession] true).
class ForParentsPage extends ConsumerStatefulWidget {
  const ForParentsPage({
    this.childId,
    this.confirmOnOpen,
    this.holderSession = false,
    this.onBack,
    this.onOpenNotice,
    this.onOpenGate,
    this.onClosed,
    this.onNotHeld,
    super.key,
  });

  /// The child these actions apply to. Null is the child signed in on this
  /// device.
  final String? childId;

  /// A confirm to show once the page has loaded.
  final ParentsAction? confirmOnOpen;

  /// True when the parent's own sign-in opened this page.
  final bool holderSession;

  /// Defaults to going back, or to Home when there is nothing to go back to.
  final VoidCallback? onBack;

  /// Defaults to the Child Notice.
  final VoidCallback? onOpenNotice;

  /// Opens the code gate and returns the proof, or null if the parent backed
  /// out. Defaults to the gate route.
  final Future<String?> Function(GuardianGateRequest request)? onOpenGate;

  /// Runs once the account is closed and this device is cleared. Defaults to
  /// the start of onboarding, where Delete Account lands.
  final VoidCallback? onClosed;

  /// A parent's session that does not hold this child (holder sessions only).
  final VoidCallback? onNotHeld;

  @override
  ConsumerState<ForParentsPage> createState() => _ForParentsPageState();
}

class _ForParentsPageState extends ConsumerState<ForParentsPage> {
  late final TapGestureRecognizer _dpoTap = TapGestureRecognizer()
    ..onTap = _openDpoMail;
  late final Future<void> _loading;

  // Held in memory for this page only (rule 4d). Never cached across opens.
  List<LinkedChild>? _children;
  bool _busy = false;
  bool _dismissed = false;
  ParentsAction? _failed;

  @override
  void initState() {
    super.initState();
    _loading = _load();
  }

  @override
  void dispose() {
    _dpoTap.dispose();
    super.dispose();
  }

  String? get _childId =>
      widget.childId ??
      switch (ref.read(authStateProvider).valueOrNull) {
        SignedInAuthState(:final user) => user.uid,
        _ => null,
      };

  /// Asks the server for the parent's children when the page opens. A failure
  /// is not shown: the confirms then use the stricter last-child wording.
  Future<void> _load() async {
    try {
      final result = await ref.read(authRepositoryProvider).listChildren();
      if (!mounted) return;
      setState(() => _children = result.children);
      final id = _childId;
      if (widget.holderSession &&
          id != null &&
          !result.children.any((child) => child.uid == id)) {
        widget.onNotHeld?.call();
        return;
      }
    } on AuthGatewayException catch (error) {
      if (mounted &&
          widget.holderSession &&
          error.code == 'permission-denied') {
        widget.onNotHeld?.call();
        return;
      }
    } on Object {
      // The stricter wording covers it.
    }
    final open = widget.confirmOnOpen;
    if (open != null && mounted) await _ask(open);
  }

  /// This child's nickname from the server's list, or the one the child set up
  /// with on this device.
  String get _nickname {
    final id = _childId;
    final fromServer = _children
        ?.where((child) => child.uid == id)
        .map((child) => child.nickname)
        .firstOrNull;
    if (fromServer != null && fromServer.trim().isNotEmpty) return fromServer;
    final local = ref.read(userSettingsProvider).valueOrNull?.name;
    if (!widget.holderSession && local != null && local.trim().isNotEmpty) {
      return local;
    }
    return ParentsCopy.nicknameFallback;
  }

  /// Not the last child only when the server said so. A failed or empty list
  /// shows the stricter wording.
  bool get _lastChild => (_children?.length ?? 0) <= 1;

  void _openDpoMail() => unawaited(
        ref.read(dpoMailOpenerProvider)(GuardianGateCopy.dpoEmail),
      );

  void _back() {
    final custom = widget.onBack;
    if (custom != null) return custom();
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/home');
    }
  }

  void _openNotice() {
    final custom = widget.onOpenNotice;
    if (custom != null) return custom();
    unawaited(GoRouter.maybeOf(context)?.push<void>('/legal/child-notice'));
  }

  // ------------------------------------------------------------ data copy

  /// The export is not built, so the data protection officer answers. No code
  /// is asked: nothing is released in the app.
  Future<void> _showDataCopy() async {
    await showPantasDialog<void>(
      context: context,
      barrierColor: context.colors.scrim,
      builder: (dialogContext) {
        final link = TextStyle(
          color: dialogContext.colors.accent,
          fontWeight: FontWeight.w600,
        );
        return CenteredDialog(
          title: ParentsCopy.dataCopyTitle,
          message: '${ParentsCopy.dataCopyLead}${GuardianGateCopy.dpoEmail}'
              '${ParentsCopy.dataCopyTail}',
          messageSpan: TextSpan(
            children: [
              const TextSpan(text: ParentsCopy.dataCopyLead),
              TextSpan(
                text: GuardianGateCopy.dpoEmail,
                style: link,
                recognizer: _dpoTap,
                mouseCursor: SystemMouseCursors.click,
              ),
              const TextSpan(text: ParentsCopy.dataCopyTail),
            ],
          ),
          primaryLabel: ParentsCopy.gotIt,
          onConfirm: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  // ----------------------------------------------------- withdraw / delete

  Future<void> _ask(ParentsAction action) async {
    if (_busy) return;
    await _loading;
    if (!mounted) return;
    setState(() => _failed = null);
    final nickname = _nickname;
    final withdraw = action == ParentsAction.withdraw;
    final last = _lastChild ? ' ${ParentsCopy.lastChild}' : '';
    final confirmed = await showPantasDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: context.colors.scrim,
      builder: (dialogContext) => CenteredDialog(
        title: withdraw
            ? ParentsCopy.withdrawTitle(nickname)
            : ParentsCopy.deleteTitle,
        message:
            '${withdraw ? ParentsCopy.withdrawBody(nickname) : ParentsCopy.deleteBody}$last',
        primaryLabel:
            withdraw ? ParentsCopy.withdrawButton : ParentsCopy.deleteButton,
        secondaryLabel: ParentsCopy.cancel,
        destructive: true,
        onConfirm: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
      ),
    );
    if (confirmed != true || !mounted) return;
    await _confirmed(action, nickname);
  }

  Future<String?> _gate(GuardianGateRequest request) {
    final custom = widget.onOpenGate;
    if (custom != null) return custom(request);
    final router = GoRouter.maybeOf(context);
    if (router == null) return Future.value();
    return router.push<String>(guardianGatePath, extra: request);
  }

  Future<void> _confirmed(ParentsAction action, String nickname) async {
    final id = _childId;
    if (id == null) return;
    final withdraw = action == ParentsAction.withdraw;
    final proof = await _gate(
      GuardianGateRequest(
        action: withdraw ? GuardianAction.withdraw : GuardianAction.delete,
        childId: id,
        nickname: nickname,
        actionPhrase: withdraw
            ? GuardianGateCopy.withdrawalPhrase
            : GuardianGateCopy.deletionPhrase,
      ),
    );
    if (proof == null || !mounted) return;
    final router = GoRouter.maybeOf(context);
    setState(() {
      _busy = true;
      _dismissed = false;
    });
    try {
      final gateway = ref.read(childSetupGatewayProvider);
      if (withdraw) {
        await gateway.withdrawChild(childId: id, guardianProofId: proof);
      } else {
        await gateway.deleteChild(childId: id, guardianProofId: proof);
      }
      // The server has closed the account. Only now does the device change.
      await ref
          .read(childAccountCloserProvider)
          .finish(holderSession: widget.holderSession);
      final custom = widget.onClosed;
      if (custom != null) return custom();
      router?.go('/onboarding');
    } on Object {
      if (mounted) setState(() => _failed = action);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ------------------------------------------------------------------ view

  @override
  Widget build(BuildContext context) {
    final failed = _failed;
    return ParentsFrame(
      settingsStyle: true,
      title: ParentsCopy.title,
      lead: ParentsCopy.lead,
      backLabel: widget.holderSession ? 'Back' : ParentsCopy.backToSettings,
      onBack: _busy ? null : _back,
      children: [
        if (failed != null && !_dismissed) ...[
          ParentsNotice(
            title: ParentsCopy.closeFailed(failed),
            onClose: () => setState(() => _dismissed = true),
          ),
          const SizedBox(height: parentsGap),
        ],
        GroupedSection(
          children: [
            ListRow(
              title: ParentsCopy.readNotice,
              divider: true,
              onTap: _openNotice,
            ),
            ListRow(
              title: ParentsCopy.dataCopyRow,
              onTap: () => unawaited(_showDataCopy()),
            ),
          ],
        ),
        const SizedBox(height: parentsGap),
        GroupedSection(
          children: [
            ListRow(
              title: ParentsCopy.withdrawRow,
              subtitle: ParentsCopy.withdrawSub,
              variant: ListRowVariant.destructive,
              divider: true,
              onTap:
                  _busy ? null : () => unawaited(_ask(ParentsAction.withdraw)),
            ),
            ListRow(
              title: ParentsCopy.deleteRow,
              variant: ListRowVariant.destructive,
              onTap: _busy ? null : () => unawaited(_ask(ParentsAction.delete)),
            ),
          ],
        ),
        const SizedBox(height: PantasSpace.s24),
      ],
    );
  }
}
