import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/data/custom_subject_tiers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/card_footer.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/selectable_tile.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

/// The subjects a custom exam can draw on, each with the topics that hold a
/// question. A topic with none is left out, and so is a subject with no topic
/// left, so the student is never offered something that cannot be studied. An
/// empty result is an error: the catalog has not loaded, so the step shows
/// Try Again instead of an empty list.
final corpusSubjectsWithTopicsProvider =
    FutureProvider<Map<String, Set<TopicId>>>((ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final exams = (await content.listExams()).where((e) => !e.isCustom);
  final bySubject = <String, Set<TopicId>>{};
  for (final exam in exams) {
    for (final subject in exam.subjects) {
      final topics = await content.topicsBySubject(subject.id);
      bySubject
          .putIfAbsent(subject.name, () => <TopicId>{})
          .addAll(topics.map((t) => t.id));
    }
  }
  final counts = await content.activeQuestionCountsByTopics({
    for (final topics in bySubject.values) ...topics,
  });
  final map = <String, Set<TopicId>>{};
  for (final entry in bySubject.entries) {
    final held = {
      for (final id in entry.value)
        if ((counts[id] ?? 0) > 0) id,
    };
    if (held.isNotEmpty) map[entry.key] = held;
  }
  if (map.isEmpty) throw StateError('No subject holds a question.');
  return map;
});

class CustomTrackSubjectsStep extends ConsumerStatefulWidget {
  const CustomTrackSubjectsStep({
    required this.name,
    this.onCompleted,
    this.onBack,
    this.existingTrackId,
    this.onCreated,
    this.fromSettings = false,
    super.key,
  });
  final String name;

  /// Opened from Settings, where onboarding is already complete. The step
  /// makes the track and says it is done, and leaves everything else to
  /// Settings: onboarding stays complete, and the exam is changed by the same
  /// save that changes it for a listed exam.
  final bool fromSettings;

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
      if (!widget.fromSettings) {
        await prefs.setCompletedOnboarding(value: false);
        await prefs.setSelectedExamId(id);
      }
      if (!mounted || generation != _generation) return;
      // The exam list was read before this track existed. Without a fresh
      // read, the focus finds no chosen exam and the router never lets the
      // student leave onboarding.
      ref
        ..invalidate(examListProvider)
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

  void _toggle(String name) => setState(() {
        if (!_selected.add(name)) _selected.remove(name);
      });

  /// The subject's second line: its topic count, and its tier when that is
  /// above Student ("4 topics · Civil Service-level").
  String _sub(Set<TopicId> topics, CustomSubjectTiers? tiers) {
    final count = '${topics.length} ${topics.length == 1 ? 'topic' : 'topics'}';
    final tier = tiers?.tierOf(topics);
    if (tier == null || tier == PriceTier.student) return count;
    return '$count · ${CustomSubjectTiers.levelLabel(tier)}';
  }

  /// The card footer's line. It names the tier once a subject is ticked and
  /// the table has loaded.
  String _tierLine(
    Map<String, Set<TopicId>> subjects,
    CustomSubjectTiers? tiers,
  ) {
    const free = 'Studying is free.';
    if (tiers == null || _selected.isEmpty) return free;
    final tier = tiers.tierOf({
      for (final name in _selected) ...subjects[name] ?? <TopicId>{},
    });
    return '$free For Pro, this is a '
        '${CustomSubjectTiers.levelLabel(tier)} exam.';
  }

  Widget _continue(
    Map<String, Set<TopicId>> subjects,
    VoidCallback? onPressed,
  ) {
    if (context.wideWeb) {
      return WebButton(
        label: 'Continue',
        busy: _creating,
        onPressed: onPressed,
      );
    }
    return PantasButton(
      label: 'Continue',
      busy: _creating,
      onPressed: onPressed,
      fullWidth: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(corpusSubjectsWithTopicsProvider);
    final tiers = ref.watch(customSubjectTiersProvider).valueOrNull;
    firstScreenReady(context, ref, ready: !subjects.isLoading);
    final canContinue = !_creating && _selected.isNotEmpty && subjects.hasValue;
    void next() => _save(subjects.requireValue);
    return OnboardingWebPage(
      title: 'What does it cover?',
      detail: 'Tick the subjects your exam covers. '
          'You can choose exact topics later.',
      progress: 3,
      bodyGap: PantasSpace.s24,
      onEnter: canContinue ? next : null,
      // The card footer holds Continue once the subjects have loaded. Until
      // then, or when they fail, it stays here, disabled.
      bottom: subjects.hasValue
          ? null
          : const OnboardingActions(
              children: [OnboardingButton(label: 'Continue')],
            ),
      onBack: () {
        if (_creating) return;
        _generation++;
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          Navigator.of(context).maybePop();
        }
      },
      children: [
        if (_failed) saveFailureLine(next),
        subjects.when(
          loading: () =>
              const SkeletonGroups(groups: 1, rows: 6, header: false),
          error: (error, _) => errorFor(
            'subjects',
            () => ref.invalidate(corpusSubjectsWithTopicsProvider),
            error: error,
          ),
          data: (map) => WebCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(PantasSpace.s20),
                  child: SelectableTileGrid(
                    children: [
                      for (final entry in map.entries)
                        SelectableTile(
                          key: ValueKey('subject-tile-${entry.key}'),
                          name: entry.key,
                          sub: _sub(entry.value, tiers),
                          selected: _selected.contains(entry.key),
                          onTap: _creating ? null : () => _toggle(entry.key),
                        ),
                    ],
                  ),
                ),
                CardFooter(
                  caption: _tierLine(map, tiers),
                  action: _continue(map, canContinue ? next : null),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
