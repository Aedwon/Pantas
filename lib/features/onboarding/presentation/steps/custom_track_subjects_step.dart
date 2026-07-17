import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/storage/track_scope.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_checkbox.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final corpusSubjectsWithTopicsProvider =
    FutureProvider<Map<String, Set<TopicId>>>((ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final exams = (await content.listExams()).where((e) => !e.isCustom);
  final map = <String, Set<TopicId>>{};
  for (final exam in exams) {
    for (final subject in exam.subjects) {
      final topics = await content.topicsBySubject(subject.id);
      map
          .putIfAbsent(subject.name, () => <TopicId>{})
          .addAll(topics.map((t) => t.id));
    }
  }
  return map;
});

class CustomTrackSubjectsStep extends ConsumerStatefulWidget {
  const CustomTrackSubjectsStep({
    required this.name,
    super.key,
  });

  final String name;

  @override
  ConsumerState<CustomTrackSubjectsStep> createState() =>
      _CustomTrackSubjectsStepState();
}

class _CustomTrackSubjectsStepState
    extends ConsumerState<CustomTrackSubjectsStep> {
  Set<String>? _tickedSubjectNames;
  bool _creating = false;

  Future<void> _onContinue(Map<String, Set<TopicId>> subjectMap) async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final tickedNames = _tickedSubjectNames ?? subjectMap.keys.toSet();
      final includedTopicIds = <TopicId>{};
      for (final name in tickedNames) {
        final topicIds = subjectMap[name];
        if (topicIds != null) {
          includedTopicIds.addAll(topicIds);
        }
      }

      final repo = ref.read(customTrackRepositoryProvider);
      final newExamId = await repo.create(
        name: widget.name,
        includedTopicIds: includedTopicIds,
      );

      await ref
          .read(appPreferencesRepositoryProvider)
          .setSelectedExamId(newExamId);
      ref
        ..invalidate(appPreferencesRepositoryProvider)
        ..invalidate(activeExamFocusProvider)
        ..invalidate(scopedTopicsProvider)
        ..invalidate(scopedSubjectsProvider);

      if (mounted) {
        GoRouter.maybeOf(context)?.go('/home');
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    final subjectsAsync = ref.watch(corpusSubjectsWithTopicsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'What does it cover?',
                style: styles.displaySmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Tick the subjects your exam covers. You can choose exact '
                'topics later in Settings.',
                style: styles.bodyMedium.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: subjectsAsync.when(
                  loading: () => const FaintBars(),
                  error: (_, __) => Center(
                    child: Text(
                      'Could not load subjects.',
                      style: styles.bodyMedium.copyWith(color: colors.inkMuted),
                    ),
                  ),
                  data: (subjectMap) {
                    _tickedSubjectNames ??= subjectMap.keys.toSet();
                    final names = subjectMap.keys.toList();
                    return ListView.builder(
                      itemCount: names.length,
                      itemBuilder: (context, i) {
                        final name = names[i];
                        final isTicked = _tickedSubjectNames!.contains(name);
                        void toggle() {
                          setState(() {
                            if (isTicked) {
                              _tickedSubjectNames!.remove(name);
                            } else {
                              _tickedSubjectNames!.add(name);
                            }
                          });
                        }

                        return InkWell(
                          onTap: toggle,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: colors.ruleFaint,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                InkCheckbox.binary(
                                  isSelected: isTicked,
                                  onTap: toggle,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(name, style: styles.bodyMedium),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              BoardButton(
                label: 'Continue',
                onPressed: _creating || subjectsAsync.value == null
                    ? null
                    : () => _onContinue(subjectsAsync.value!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
