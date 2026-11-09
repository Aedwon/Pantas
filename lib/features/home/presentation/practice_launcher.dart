import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';

/// Practice This Topic and Practice Weakest Topics. Optional, outside the
/// plan, and never counted toward the streak. The prepared session is passed
/// to the Today route unchanged. Failures use the approved lines.
Future<void> startTopicPractice(
  BuildContext context,
  WidgetRef ref, {
  required String examId,
  String? topicId,
  Future<bool> Function()? isCurrent,
}) async {
  final router = GoRouter.of(context);
  final telemetry = ref.read(telemetryProvider);
  try {
    if (isCurrent != null && !await isCurrent()) return;
    final prepared = await ref.read(todayQuizPreparerProvider).prepare(
          QuizPreparationRequest(
            userId: quizLocalUserId,
            examId: examId,
            topicId: topicId,
          ),
        );
    if (isCurrent != null && !await isCurrent()) return;
    if (!context.mounted) return;
    if (prepared.plan.isEmpty) {
      showHomeToast(
        context,
        ref.read(contentLimitReachedProvider)
            ? contentLimitMessage
            : 'No questions are ready right now.',
      );
      return;
    }
    unawaited(
      router.push(
        topicId == null
            ? '/quiz/today/$examId'
            : '/quiz/today/$examId?topicId=$topicId',
        extra: prepared,
      ),
    );
  } on Object catch (error, stack) {
    unawaited(telemetry.recordError(error, stack));
    if (!context.mounted) return;
    showHomeToast(context, 'Could not prepare this quiz.');
  }
}

/// Shows [message] as the design system Toast: `toast-bg`, `toast-text`,
/// `radius-lg`, one at a time.
void showHomeToast(BuildContext context, String message) {
  final colors = context.colors;
  ScaffoldMessenger.of(context) // ds-raw: toast host lookup
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        backgroundColor: colors.toastBg, // ds-raw: no shared toast host
        content: Text(
          message,
          style: (context.wideWeb
                  ? PantasType.webRowValue
                  : PantasType.phoneSubhead)
              .copyWith(color: colors.toastText),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PantasRadius.lg),
        ),
      ),
    );
}
