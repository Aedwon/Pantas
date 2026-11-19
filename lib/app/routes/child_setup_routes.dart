// ignore_for_file: directives_ordering

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/onboarding/presentation/child/child_nickname_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/child_notice_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/parent_setup_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/parent_sign_in_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/under_thirteen_screen.dart';

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
            if (childId == null) throw StateError('No child to name.');
            await ref.read(childSetupGatewayProvider).setChildNickname(
                  childId: childId,
                  nickname: nickname,
                );
          },
          // TODO(T6): the device-state task continues onboarding (exam, date,
          // study days) as the child. Until then this returns to onboarding.
          onDone: () => context.go('/onboarding'),
        ),
      ),
    ];
