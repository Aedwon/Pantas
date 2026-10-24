import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/exam_selection_row.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
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
                        final publish = await ref.read(
                          studySettingsCaptureProvider,
                        )(examId: exam.id);
                        await publish.apply(
                          () => ref
                              .read(appPreferencesRepositoryProvider)
                              .setSelectedExamId(exam.id),
                        );
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

Future<void> _routeSettledAfterPop(BuildContext context) async {
  final route = ModalRoute.of(context);
  if (route == null) return;

  // TransitionRoute.completed resolves only after the pop transition has
  // finished and the route's overlay entries have been removed. Waiting on
  // animation status alone is too early and can let GoRouter refresh while
  // the outgoing Change exam page is still mounted.
  await route.completed;
}
