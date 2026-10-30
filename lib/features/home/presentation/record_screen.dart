import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/home/presentation/record_page.dart';
import 'package:pantas/features/home/presentation/widgets/progress_skeletons.dart';
import 'package:pantas/features/home/presentation/widgets/web_record_layout.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';

/// W4g fills this slot after Your mocks. A missing contract draws no control.
final wrappedRecordRowProvider = Provider<Widget?>((ref) => null);

class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(recordProvider);
    final history = ref.watch(mockHistoryProvider);
    firstScreenReady(
      context,
      ref,
      ready: record.hasError ||
          history.hasError ||
          (!record.isLoading && !history.isLoading),
      path: '/record',
    );
    void back() => context.canPop() ? context.pop() : context.go('/home');
    if (record.unwrapPrevious().asData == null ||
        history.unwrapPrevious().asData == null) {
      if (context.wideWeb) {
        return WebMyPage(
          title: 'Your record',
          onBack: back,
          child: record.hasError || history.hasError
              ? WebMyFailure(
                  onRetry: () {
                    ref
                      ..invalidate(recordProvider)
                      ..invalidate(mockHistoryProvider);
                  },
                )
              : const WebMyLoading(record: true),
        );
      }
      return PantasPage(
        title: 'Your record',
        backLabel: 'Home',
        onBack: back,
        children: [
          if (record.hasError || history.hasError)
            errorFor('progress', () {
              ref
                ..invalidate(recordProvider)
                ..invalidate(mockHistoryProvider);
            })
          else
            const RecordSkeleton(),
        ],
      );
    }
    return RecordPage(
      record: record.requireValue,
      mocks: [
        for (final entry in history.requireValue)
          if (entry.attempt.submittedAt != null)
            RecordMockRow(
              id: entry.attempt.id,
              name: entry.attempt.blueprintName,
              date: entry.attempt.submittedAt!,
              percent: entry.results.percent.round(),
            ),
      ],
      onBack: back,
      onMock: (id) => unawaited(
        context.push<void>('/mock/results/${Uri.encodeComponent(id)}'),
      ),
      wrappedRow: context.wideWeb ? null : ref.watch(wrappedRecordRowProvider),
    );
  }
}
