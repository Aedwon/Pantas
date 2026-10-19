# C10 roadmap and Progress-insight portability (read-only)

Ref: origin/integration/new-design-r1 (5e6cda45). Policy read from GitHub main (AGENTS.md, WORKFLOW.md). Package name: pantas (pubspec.yaml).

## 1. Computation files (lib/, line counts)

Roadmap engine (lib/features/roadmap/domain/):
- build_roadmap.dart 160
- sitting_planner.dart 159
- topic_order.dart 116
- planning_window.dart 145
- roadmap_inputs.dart 249
- roadmap.dart 241
- roadmap_diff.dart 111
- day_selection.dart 152
- day_snapshot.dart 321
- mock_day.dart 66
- week_preview.dart 62

Insight math (lib/features/metrics/domain/):
- tendency_confidence.dart 331
- signal_outputs.dart 217
- metric_signal.dart 21, metrics_thresholds.dart 15, metrics_window.dart 23, signal_key.dart 19

Insight providers (lib/features/home/application/, lib/features/progress/application/): tendencies_provider.dart 283, how_you_work_provider.dart 457, miss_causes_provider.dart 205, up_next_provider.dart 134, performance/performance_provider.dart 454, performance/topic_accuracy_provider.dart 92, lib/features/progress/application/pace_provider.dart 162.

Signal computations: lib/features/metrics/signals/*.dart (12 files, about 900 lines total, UNCONFIRMED exact sum).

## 2. Import closures

Roadmap engine (11 entry files): 21 files, 2,204 lines.
- Non-pure imports: none from Flutter, Riverpod, drift, dart:io or platform.
- Non-SDK packages (pure Dart): package:collection at sitting_planner.dart:1, roadmap.dart:1, roadmap_diff.dart:1, roadmap_inputs.dart:1, day_snapshot.dart:2. package:meta at planning_window.dart:2, roadmap.dart:2, roadmap_inputs.dart:2, day_snapshot.dart:4, study_days.dart:1, exam_date.dart:1. package:freezed_annotation at core/storage/domain/question.dart:2, choice.dart:1.

Metrics domain math (tendency_confidence, signal_outputs, metric_signal, metrics_window, signal_key, metrics_thresholds): 6 files, 626 lines. No non-pure imports.

Insight providers and signals: 274 files, 24,405 lines when seeded from the providers. Non-pure imports are widespread:
- flutter_riverpod: every provider file (tendencies_provider.dart:4, how_you_work_provider.dart:4, pace_provider.dart:2, roadmap_providers.dart:1, and others).
- package:flutter/foundation.dart: tendencies_provider.dart:2, how_you_work_provider.dart:2, pace_provider.dart:1, performance_provider.dart:4.
- drift and app DB: metrics/signals/*.dart import drift and package:pantas/core/storage/data/app_database.dart (for example consistency_signal.dart:1-2, coverage_breadth_signal.dart:2, mock_stamina_signal.dart:1-3). performance_provider.dart:2,7. miss_causes_provider.dart:2.
- roadmap_inputs_reader.dart:1-2 (drift, Riverpod). It is outside the roadmap engine closure.

## 3. Entry points and inputs

- BuildRoadmap.call(RoadmapInputs inputs) returns Roadmap (build_roadmap.dart:14).
- SittingPlanner.next({...}) returns List<QuestionId> (sitting_planner.dart:13). Full named parameters UNCONFIRMED.
- RoadmapInputs constructor at roadmap_inputs.dart:155. Carries topics, lessons, questions, reviews, topic scores, mock facts, assessmentCompleted and prerequisites. Full field list UNCONFIRMED.
- Exam date and study days: core/storage/domain/exam_date.dart and core/time/study_days.dart (pure).
- Source of inputs today: RoadmapInputsReader (lib/features/roadmap/application/roadmap_inputs_reader.dart:32-81) reads through Riverpod and drift. Repos: lib/features/roadmap/data/roadmap_day_repository.dart, roadmap_change_log_repository.dart (drift).
- Insight entry: TendencyCard / readSignal<T>(SignalKey) in tendencies_provider.dart:51 calls metricsSignalProvider (Riverpod). Signals read attempts through drift (metrics/signals/*). Pure statistics: StatisticalTestResult.twoProportion and welch (tendency_confidence.dart:43, 60).

## 4. Existing server or shared code

- functions/src: no roadmap or tendency logic (grep for roadmap, tendenc, insight found none).
- tools/: only the historical_v1.json content match ("central tendency" statistics text). No roadmap engine in tools/.
- packages/ folder: absent on the ref. lib/core/domain: absent. The pure roadmap code sits in lib/features/roadmap/domain.
- Tests for the pure logic exist under test/features/roadmap/domain/ and test/features/metrics/domain/tendency_confidence_test.dart.

## 5. web/roadmap-engine-r1

Latest 5 commits: 1f79d880 Keep tendency claims consistent with the evidence being tested; 1bbda9ac Keep tendency claims tied to the strength of measured evidence; 3b90fb7a Pin the reminder clock in tests and follow the practicing spelling; ef078930 fix: tie student profiles and tendency copy to measured data; 18871bb0 Let a skipped mock still land on the day before the exam.
Merged: yes. git merge-base --is-ancestor returns true, so the branch is an ancestor of origin/integration/new-design-r1.
