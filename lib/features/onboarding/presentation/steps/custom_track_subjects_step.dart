import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

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
    this.existingTrackId,
    this.onCreated,
    super.key,
  });
  final String name;

  /// A track this onboarding already created. Returning here from the date
  /// step reuses it instead of creating a second one.
  final String? existingTrackId;

  /// Told the new track's id as soon as it exists, so the caller can pass it
  /// back as [existingTrackId] if the student returns.
  final ValueChanged<String>? onCreated;
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
  Future<String> _createOrReuse(
    CustomTrackRepository repo,
    Map<String, Set<TopicId>> subjects,
    Set<TopicId> included,
  ) async {
    final existing = widget.existingTrackId ?? _createdId;
    if (existing == null) {
      final id = await repo.create(
        name: widget.name.trim(),
        includedTopicIds: included,
      );
      widget.onCreated?.call(id);
      return id;
    }
    // Back from the date step lands here with the track already saved. Update
    // it so the student's last choice wins. Topics outside every subject stay
    // excluded, as create left them.
    await repo.rename(examId: existing, name: widget.name.trim());
    await repo.setExcluded(
      examId: existing,
      topicIds: (await repo.excludedTopicIds(existing))
          .union({for (final topics in subjects.values) ...topics}).difference(
        included,
      ),
    );
    return existing;
  }

  Future<void> _save(Map<String, Set<TopicId>> subjects) async {
    if (_creating || _selected.isEmpty) return;
    final generation = _generation;
    final repo = ref.read(customTrackRepositoryProvider);
    final prefs = ref.read(appPreferencesRepositoryProvider);
    final telemetry = ref.read(telemetryProvider);
    setState(() {
      _creating = true;
      _failed = false;
    });
    try {
      final included = {
        for (final name in _selected) ...subjects[name] ?? <TopicId>{},
      };
      final id = await _createOrReuse(repo, subjects, included);
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
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(corpusSubjectsWithTopicsProvider);
    return OnboardingWebPage(
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
      bottom: OnboardingActions(
        children: [
          if (_failed) saveFailureLine(() => _save(subjects.requireValue)),
          OnboardingButton(
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
          data: (map) => context.wideWeb
              ? LayoutBuilder(
                  builder: (context, constraints) => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final name in map.keys)
                        SizedBox(
                          width: (constraints.maxWidth - 10) / 2,
                          child: WebCard(
                            radius: 14,
                            child: Material(
                              color: Colors.transparent,
                              child: CheckboxListTile(
                                contentPadding:
                                    const EdgeInsets.only(left: 8, right: 16),
                                // The 40px control centers a 24px painted box.
                                // Its 8px inset plus the 6px gap gives 14px.
                                checkboxScaleFactor: 24 / Checkbox.width,
                                horizontalTitleGap: 6,
                                minLeadingWidth: 0,
                                title: Text(
                                  name,
                                  style: context.webTokens.style(16),
                                ),
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    7 * Checkbox.width / 24,
                                  ),
                                ),
                                side: BorderSide(
                                  color:
                                      context.webTokens.colors.controlOutline,
                                  width: 1.5 * Checkbox.width / 24,
                                ),
                                value: _selected.contains(name),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: _creating
                                    ? null
                                    : (_) => setState(() {
                                          if (!_selected.add(name)) {
                                            _selected.remove(name);
                                          }
                                        }),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : GroupedSection(
                  children: [
                    for (final name in map.keys)
                      ListRow.checkbox(
                        title: name,
                        selected: _selected.contains(name),
                        onTap: _creating
                            ? null
                            : () => setState(() {
                                  if (!_selected.add(name)) {
                                    _selected.remove(name);
                                  }
                                }),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
