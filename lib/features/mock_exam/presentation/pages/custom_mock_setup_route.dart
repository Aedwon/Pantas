import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';

final customBlueprintRepositoryProvider = Provider<CustomBlueprintRepository>(
  (ref) => CustomBlueprintRepository(ref.watch(appDatabaseProvider)),
);

/// What the setup screen needs, read from the student's own track.
final customMockSetupDataProvider =
    FutureProvider<CustomMockSetupData?>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final exam = focus.exam;
  if (exam == null) return null;

  final topics = await ref.watch(scopedTopicsProvider(exam.id).future);
  final subjects = await ref.watch(scopedSubjectsProvider(exam.id).future);
  final content = ref.watch(contentRepositoryProvider);

  final topicsBySubject = <SubjectId, List<Topic>>{};
  for (final topic in topics) {
    (topicsBySubject[topic.subjectId] ??= []).add(topic);
  }

  // Counted from the scoped topics, so it follows the track rather than
  // the whole corpus.
  var available = 0;
  for (final topic in topics) {
    available += (await content.questionsByTopic(topic.id)).length;
  }

  return CustomMockSetupData(
    examId: exam.id,
    subjects: subjects,
    topicsBySubject: topicsBySubject,
    availableQuestions: available,
  );
});

class CustomMockSetupRoute extends ConsumerWidget {
  const CustomMockSetupRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(customMockSetupDataProvider).valueOrNull;
    if (data == null) {
      return const Scaffold(body: Center(child: FaintBars()));
    }

    return CustomMockSetupPage(
      data: data,
      onSave: (blueprint) async {
        await ref.read(customBlueprintRepositoryProvider).save(
              blueprint,
              topicsBySubject: {
                for (final entry in data.topicsBySubject.entries)
                  entry.key: [for (final topic in entry.value) topic.id],
              },
              now: DateTime.now(),
            );
        if (context.mounted) context.pop();
      },
    );
  }
}
