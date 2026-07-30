import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/exam_selection_row.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          const SettingsBar(title: 'Change exam'),
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
                        Navigator.of(context).pop();

                        if (carryableCount > 0 && context.mounted) {
                          final countThem = await showCarryOverPrompt(
                            context: context,
                            examShortName: exam.shortName,
                            carryableCount: carryableCount,
                          );
                          if (countThem != null) {
                            await ref
                                .read(settingsActionsProvider)
                                .setCarryOverProgress(enabled: countThem);
                          }
                        }
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
