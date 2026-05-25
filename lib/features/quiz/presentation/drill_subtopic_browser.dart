import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (topics) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: topics.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final topic = topics[index];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.name, style: context.textStyles.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    'General bucket',
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Start drill',
                    onPressed: () => context.go(
                      '/quiz/drill/$examId?topicId=${topic.id}',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
