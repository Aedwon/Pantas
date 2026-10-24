import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';

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
    this.onCompleted,
    this.onBack,
    super.key,
  });
  final String name;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;
  @override
  ConsumerState<CustomTrackSubjectsStep> createState() =>
      _CustomTrackSubjectsStepState();
}

class _CustomTrackSubjectsStepState
    extends ConsumerState<CustomTrackSubjectsStep> {
  final Set<String> _selected = {};
  bool _creating = false;
  bool _failed = false;
  String? _createdId;
  int _generation = 0;
  Future<void> _save(Map<String, Set<TopicId>> subjects) async {
    if (_creating || _selected.isEmpty) return;
    final generation = _generation;
    final repo = ref.read(customTrackRepositoryProvider);
    final prefs = ref.read(appPreferencesRepositoryProvider);
    setState(() {
      _creating = true;
      _failed = false;
    });
    try {
      final id = _createdId ??
          await repo.create(
            name: widget.name.trim(),
            includedTopicIds: {
              for (final name in _selected) ...subjects[name] ?? <TopicId>{},
            },
          );
      _createdId = id;
      if (!mounted || generation != _generation) return;
      await prefs.setCompletedOnboarding(value: false);
      await prefs.setSelectedExamId(id);
      if (!mounted || generation != _generation) return;
      ref
        ..invalidate(activeExamFocusProvider)
        ..invalidate(scopedTopicsProvider)
        ..invalidate(scopedSubjectsProvider);
      if (widget.onCompleted != null) {
        widget.onCompleted!();
      } else {
        context.go('/onboarding');
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(corpusSubjectsWithTopicsProvider);
    return PantasPage.onboarding(
      title: 'What does it cover?',
      detail: 'Tick the subjects your exam covers. '
          'You can choose exact topics later.',
      progress: 3,
      bodyGap: 24,
      onBack: () {
        if (_creating) return;
        _generation++;
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          Navigator.of(context).maybePop();
        }
      },
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_failed) saveFailureLine(() => _save(subjects.requireValue)),
          PantasButton(
            label: 'Continue',
            busy: _creating,
            onPressed: _creating || _selected.isEmpty || !subjects.hasValue
                ? null
                : () => _save(subjects.requireValue),
          ),
        ],
      ),
      children: [
        subjects.when(
          loading: () => loadingFor(subjects),
          error: (error, _) => errorFor(
            'subjects',
            () => ref.invalidate(corpusSubjectsWithTopicsProvider),
            error: error,
          ),
          data: (map) => GroupedSection(
            children: [
              for (final name in map.keys)
                ListRow.checkbox(
                  title: name,
                  selected: _selected.contains(name),
                  onTap: _creating
                      ? null
                      : () => setState(() {
                            if (!_selected.add(name)) _selected.remove(name);
                          }),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
