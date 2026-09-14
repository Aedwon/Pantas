import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/exam_selection_row.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';

class ExamChangeResult {
  const ExamChangeResult({
    required this.examShortName,
    required this.carryableCount,
    required this.routeSettled,
  });

  final String examShortName;
  final int carryableCount;
  final Future<void> routeSettled;
}

class ChangeExamPage extends ConsumerWidget {
  const ChangeExamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final styles = context.textStyles;
    final examsAsync = ref.watch(examListProvider);
    final focusAsync = ref.watch(activeExamFocusProvider);
    final activeExamId = focusAsync.valueOrNull?.exam?.id;

    return PageScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SettingsBar(title: 'Change exam', backLabel: 'Exam'),
          Expanded(
            child: examsAsync.when(
              loading: () => const FaintBars(),
              error: (_, __) => Center(
                child: Text(
                  'Could not load exams.',
                  style: styles.bodyMedium.copyWith(color: colors.inkMuted),
                ),
              ),
              data: (exams) {
                final activeExams = [...exams.where((e) => e.isActive)]
                  ..sort((a, b) => a.name.compareTo(b.name));
                if (activeExams.isEmpty) {
                  return Center(
                    child: Text(
                      'No exams available right now.',
                      style: styles.bodyMedium.copyWith(color: colors.inkMuted),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: activeExams.length,
                  itemBuilder: (builderContext, i) {
                    final exam = activeExams[i];
                    final selected = exam.id == activeExamId;
                    return ExamSelectionRow(
                      exam: exam,
                      selected: selected,
                      onTap: () async {
                        if (selected) return;
                        await ref
                            .read(appPreferencesRepositoryProvider)
                            .setSelectedExamId(exam.id);
                        ref
                          ..invalidate(appPreferencesRepositoryProvider)
                          ..invalidate(activeExamFocusProvider);

                        final carryableCount = await ref
                            .read(carryableCountProvider(exam.id).future);

                        if (!context.mounted) return;
                        final routeSettled = _routeSettledAfterPop(context);
                        Navigator.of(context).pop(
                          ExamChangeResult(
                            examShortName: exam.shortName,
                            carryableCount: carryableCount,
                            routeSettled: routeSettled,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _routeSettledAfterPop(BuildContext context) {
  final animation = ModalRoute.of(context)?.animation;
  if (animation == null || animation.status == AnimationStatus.dismissed) {
    return Future<void>.value();
  }

  final completer = Completer<void>();

  void onStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed) return;
    animation.removeStatusListener(onStatus);
    if (!completer.isCompleted) completer.complete();
  }

  animation.addStatusListener(onStatus);
  return completer.future;
}
