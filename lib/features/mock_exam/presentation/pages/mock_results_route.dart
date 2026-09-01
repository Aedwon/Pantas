import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';

class MockResultsRoute extends ConsumerWidget {
  const MockResultsRoute({
    required this.attemptId,
    super.key,
  });

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attemptFuture =
        ref.watch(mockAttemptRepoProvider).findById(attemptId);
    final proIsActive =
        ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false;

    return FutureBuilder<MockAttempt?>(
      future: attemptFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: FaintBars()));
        }

        final attempt = snapshot.data;
        if (attempt == null) {
          return const Scaffold(body: Center(child: Text('Attempt not found')));
        }

        MockResults? results;
        if (attempt.sectionResultsJson != null) {
          final decoded =
              jsonDecode(attempt.sectionResultsJson!) as Map<String, dynamic>;
          final sectionsJson = decoded['sections'] as List<dynamic>? ?? [];
          final topWeakJson = decoded['topWeak'] as List<dynamic>? ?? [];

          final sections = sectionsJson.map((s) {
            final map = s as Map<String, dynamic>;
            return SectionResult(
              sectionId: map['sectionId'] as String,
              name: map['name'] as String,
              correct: map['correct'] as int,
              total: map['total'] as int,
              retiredCount: map['retiredCount'] as int,
              timeSeconds: map['timeSeconds'] as int,
            );
          }).toList();

          final topWeak = topWeakJson.map((w) {
            final map = w as Map<String, dynamic>;
            return WeakTopic(
              topicId: map['topicId'] as String,
              correct: map['correct'] as int,
              total: map['total'] as int,
            );
          }).toList();

          results = MockResults(
            scoreRaw: attempt.scoreRaw ?? 0,
            scoreTotal: attempt.scoreTotal ?? 0,
            percent: attempt.scoreTotal == 0
                ? 0
                : (attempt.scoreRaw ?? 0) / attempt.scoreTotal!,
            sections: sections,
            topWeak: topWeak,
            totalTimeSeconds: attempt.elapsedSeconds,
            wasStrict: attempt.strictMode,
          );
        }

        if (results == null) {
          return const Scaffold(
            body: Center(child: Text('Results not available')),
          );
        }

        return MockResultsPage(
          results: results,
          proIsActive: proIsActive,
          blueprintName: attempt.blueprintName,
          dateFormatted: _formatDate(attempt.startedAt),
          forfeited: attempt.status == MockAttemptStatus.forfeited,
          onReviewTap: () {
            context.push('/mock/review/$attemptId');
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
