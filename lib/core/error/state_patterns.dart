import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Mount only while loading, so each new load starts its own 300ms delay.
Widget loadingFor<T>(AsyncValue<T> value) =>
    value.isLoading ? const LoadingShapes() : const SizedBox.shrink();

Widget errorFor(
  String what,
  VoidCallback onRetry, {
  Object? error,
  String? message,
  Widget? icon,
  bool boardLayout = false,
}) =>
    StateView(
      message: message ?? 'Could not load your $what.',
      icon: icon,
      boardLayout: boardLayout,
      onRetry: onRetry,
      error: error,
    );

Widget saveFailureLine(VoidCallback onRetry) => Builder(
      builder: (context) => Semantics(
        liveRegion: true,
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              'Could not save your progress.',
              style: context.type.subhead
                  .copyWith(color: context.colors.secondaryLabel),
            ),
            PantasButton(
              label: 'Try Again',
              variant: PantasButtonVariant.tertiary,
              onPressed: onRetry,
              height: 44,
              fontSize: 15,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );

Widget chooseExamFallback(BuildContext context) => StateView(
      message: 'Choose your exam',
      detail: 'Pick the exam you are reviewing for.',
      actionLabel: 'Choose Exam',
      primaryAction: true,
      icon: Icon(PantasIcons.studyTab),
      onRetry: () => context.push('/settings/exam/change'),
    );

Widget assessmentNotReady() => Builder(
      builder: (context) => StateView(
        message: "Assessment isn't ready yet",
        detail: "We're still adding questions for this exam. "
            'You can use the rest of Pantas for now.',
        actionLabel: 'Back to Quiz',
        primaryAction: true,
        icon: Icon(PantasIcons.quizTab),
        onRetry: () => context.go('/quiz'),
      ),
    );
