import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DrillSubtopicBrowser extends ConsumerWidget {
  const DrillSubtopicBrowser({required this.examId, super.key});

  final ExamId examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsByExamProvider(examId));
    return Scaffold(
      appBar: AppBar(title: const Text('Drill a topic')),
      body: topicsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: const [FaintBars()],
        ),
        error: (error, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Text(
              'Something went wrong',
              style: context.textStyles.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              error.toString(),
              style: context.textStyles.bodySmall
                  .copyWith(color: context.colors.inkMuted),
            ),
            const SizedBox(height: 20),
            BoardButton(
              label: 'Try again',
              secondary: true,
              onPressed: () => ref.invalidate(topicsByExamProvider(examId)),
            ),
          ],
        ),
        data: (topics) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            for (final topic in topics)
              InkTableRow(
                title: topic.name,
                subtitle: 'General bucket',
                onTap: () => context.push(
                  '/quiz/drill/$examId?topicId=${topic.id}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
