import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';
import 'package:pantas/features/child_setup/presentation/for_parents_page.dart';
import 'package:pantas/features/child_setup/presentation/parents_frame.dart';

/// Where the receipt email's delete link opens. The server writes
/// `${origin}/parents/delete?child=<childUid>` (spec B2 rule 6).
const String parentDeletePath = '/parents/delete';

/// The parent's sign-in for that link, and its email step.
const String parentDeleteSignInPath = '/parents/delete/sign-in';
const String parentDeleteEmailPath = '/parents/delete/sign-in/email';

/// The link's address for [childId], with the child in the query.
String parentDeleteLocation(String childId, [String path = parentDeletePath]) =>
    Uri(path: path, queryParameters: {'child': childId}).toString();

/// The receipt link's page. It decides where the link leads, once the sign-in
/// is known:
/// - the device's session is that child: the For parents page with the Delete
///   confirm shown;
/// - no named sign-in: the parent sign-in screen, then back here;
/// - the parent's own session: the same Delete confirm for that child, with
///   the nickname the server returns;
/// - a session that does not hold that child: "This link is for another
///   account."
/// Holder details are fetched each time and never stored (rule 4d).
class ParentDeleteLinkScreen extends ConsumerStatefulWidget {
  const ParentDeleteLinkScreen({
    required this.childId,
    this.onChildSession,
    this.onSignIn,
    this.onUseAnotherEmail,
    super.key,
  });

  final String childId;

  /// Defaults to opening the For parents page with the Delete confirm.
  final VoidCallback? onChildSession;

  /// Defaults to the parent sign-in screen.
  final VoidCallback? onSignIn;

  /// Defaults to signing out and returning to the parent sign-in screen.
  final Future<void> Function()? onUseAnotherEmail;

  @override
  ConsumerState<ParentDeleteLinkScreen> createState() =>
      _ParentDeleteLinkScreenState();
}

class _ParentDeleteLinkScreenState
    extends ConsumerState<ParentDeleteLinkScreen> {
  bool _notHeld = false;
  bool _dismissed = false;
  bool _routed = false;

  void _once(VoidCallback go) {
    if (_routed) return;
    _routed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) go();
    });
  }

  void _toChildSession() {
    final custom = widget.onChildSession;
    if (custom != null) return custom();
    unawaited(
      GoRouter.maybeOf(context)?.pushReplacement<void>(
        forParentsPath,
        extra: const ForParentsLaunch(confirm: ParentsAction.delete),
      ),
    );
  }

  void _toSignIn() {
    final custom = widget.onSignIn;
    if (custom != null) return custom();
    unawaited(
      GoRouter.maybeOf(context)?.pushReplacement<void>(
        parentDeleteLocation(widget.childId, parentDeleteSignInPath),
      ),
    );
  }

  Future<void> _useAnotherEmail() async {
    final custom = widget.onUseAnotherEmail;
    if (custom != null) return custom();
    await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    _routed = false;
    GoRouter.maybeOf(context)?.go(
      parentDeleteLocation(widget.childId, parentDeleteSignInPath),
    );
  }

  void _home() => GoRouter.maybeOf(context)?.go('/home');

  Widget _otherAccount() => ParentsFrame(
        title: ParentsCopy.title,
        onBack: _home,
        children: [
          if (!_dismissed)
            ParentsNotice(
              title: ParentsCopy.otherAccount,
              actionLabel: 'Use Another Email',
              onAction: () => unawaited(_useAnotherEmail()),
              onClose: () => setState(() => _dismissed = true),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider).valueOrNull;
    switch (state) {
      case SignedInAuthState(:final user):
        if (user.uid == widget.childId) {
          _once(_toChildSession);
          return const SizedBox.shrink();
        }
        // Another child's session cannot close this child.
        if (user.email.isEmpty || _notHeld) return _otherAccount();
        return ForParentsPage(
          childId: widget.childId,
          holderSession: true,
          confirmOnOpen: ParentsAction.delete,
          onBack: _home,
          onNotHeld: () => setState(() => _notHeld = true),
        );
      case AnonymousAuthState() || SignedOutAuthState():
        _once(_toSignIn);
        return const SizedBox.shrink();
      case _:
        return const SizedBox.shrink();
    }
  }
}
