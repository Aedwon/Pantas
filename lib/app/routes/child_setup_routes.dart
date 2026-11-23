// ignore_for_file: directives_ordering

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/parents_settings_frame.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';
import 'package:pantas/features/child_setup/presentation/for_parents_page.dart';
import 'package:pantas/features/child_setup/presentation/guardian_code_gate_page.dart';
import 'package:pantas/features/child_setup/presentation/parent_delete_link_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/child_nickname_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/child_notice_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/parent_setup_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/parent_sign_in_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/under_thirteen_screen.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// The parent-held child setup screens (under-13 boards 2, 2A, N2C, S7N).
/// They sit under `/onboarding/` so the router keeps a device that has not
/// passed the age gate on them, as it does for onboarding itself. The age step
/// sends a child under 13 to the guardian screen (board 1A).
List<RouteBase> childSetupRoutes(Ref ref) => [
      GoRoute(
        path: underThirteenPath,
        builder: (_, __) => const UnderThirteenScreen(),
      ),
      GoRoute(
        path: childSignInPath,
        builder: (_, __) => const ParentSignInScreen(),
      ),
      GoRoute(
        path: childEmailSignInPath,
        builder: (_, __) => const EmailSignInPage(returnTo: childSetupPath),
      ),
      GoRoute(
        path: childSetupPath,
        builder: (_, __) => const ParentSetupScreen(),
      ),
      GoRoute(
        path: childNoticePath,
        builder: (_, __) => const ChildNoticeScreen(),
      ),
      GoRoute(
        path: childNicknamePath,
        builder: (context, __) => ChildNicknameScreen(
          onSubmit: (nickname) async {
            final childId = ref.read(pendingChildIdProvider);
            final auth = ref.read(authRepositoryProvider);
            if (childId == null || auth.currentSession?.uid != childId) {
              throw StateError('No active child to name.');
            }
            final settings = ref.read(settingsRepositoryProvider);
            await ref.read(childSetupGatewayProvider).setChildNickname(
                  childId: childId,
                  nickname: nickname,
                );
            if (auth.currentSession?.uid != childId) {
              throw StateError('The child session changed.');
            }
            await settings.updateName(nickname);
          },
          onDone: () {
            ref.read(pendingChildIdProvider.notifier).state = null;
            context.go('/onboarding');
          },
        ),
      ),
      // The guardian code gate (board 8A). Pushed with its request; a reload
      // loses the request, so it returns to the For parents page.
      GoRoute(
        path: guardianGatePath,
        redirect: (_, state) =>
            state.extra is GuardianGateRequest ? null : forParentsPath,
        builder: (_, state) => GuardianCodeGatePage(
          request: state.extra! as GuardianGateRequest,
          wideFrame: parentsSettingsFrame,
        ),
      ),
      // The receipt email's delete link (spec B2 rule 6) and the parent
      // sign-in it may need. They sit outside onboarding and the router lets
      // them through on a device that has not finished it.
      GoRoute(
        path: parentDeletePath,
        redirect: (_, state) => _deleteChild(state) == null ? '/home' : null,
        builder: (_, state) =>
            ParentDeleteLinkScreen(childId: _deleteChild(state)!),
      ),
      GoRoute(
        path: parentDeleteSignInPath,
        redirect: (_, state) => _deleteChild(state) == null ? '/home' : null,
        builder: (context, state) {
          final child = _deleteChild(state)!;
          return ParentSignInScreen(
            onSignedIn: () => context.go(parentDeleteLocation(child)),
            onEmail: () => unawaited(
              context.push<void>(
                parentDeleteLocation(child, parentDeleteEmailPath),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: parentDeleteEmailPath,
        redirect: (_, state) => _deleteChild(state) == null ? '/home' : null,
        builder: (_, state) => EmailSignInPage(
          returnTo: parentDeleteLocation(_deleteChild(state)!),
        ),
      ),
    ];

String? _deleteChild(GoRouterState state) {
  final child = state.uri.queryParameters['child'];
  return child == null || child.isEmpty ? null : child;
}
