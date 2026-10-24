import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
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
  final messenger = ScaffoldMessenger.of(context);
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
      messenger.showSnackBar(
        const SnackBar(content: Text('No questions are ready right now.')),
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
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not prepare this quiz.')),
    );
  }
}
