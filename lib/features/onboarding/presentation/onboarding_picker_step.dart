import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/exam_selection_row.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ink_table_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class OnboardingPickerStep extends ConsumerStatefulWidget {
  const OnboardingPickerStep({
    required this.onCompleted,
    super.key,
  });

  final VoidCallback onCompleted;

  @override
  ConsumerState<OnboardingPickerStep> createState() =>
      _OnboardingPickerStepState();
}

class _OnboardingPickerStepState extends ConsumerState<OnboardingPickerStep> {
  String? _selectedId;
  bool _saving = false;

  Future<void> _onContinue() async {
    final id = _selectedId;
    if (id == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(appPreferencesRepositoryProvider).setSelectedExamId(id);
      ref.invalidate(appPreferencesRepositoryProvider);
      unawaited(
        ref.read(telemetryProvider).log(TelemetryEvent.onboardingCompleted),
      );
      widget.onCompleted();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Couldn't save selection. Try again."),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _onContinue,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    final examsAsync = ref.watch(examListProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text('Choose your exam', style: styles.displaySmall),
            const SizedBox(height: 6),
            Text(
              'You can switch later in Settings.',
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 24),
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
                  final active = [
                    ...exams.where((e) => e.isActive && !e.isCustom),
                  ]..sort((a, b) => a.name.compareTo(b.name));
                  return Column(
                    children: [
                      Expanded(
                        child: active.isEmpty
                            ? Center(
                                child: Text(
                                  'No exams available right now.',
                                  style: styles.bodyMedium
                                      .copyWith(color: colors.inkMuted),
                                ),
                              )
                            : ListView.builder(
                                itemCount: active.length,
                                itemBuilder: (_, i) {
                                  final exam = active[i];
                                  return ExamSelectionRow(
                                    exam: exam,
                                    selected: _selectedId == exam.id,
                                    onTap: () =>
                                        setState(() => _selectedId = exam.id),
                                  );
                                },
                              ),
                      ),
                      Container(
                        height: 1,
                        color: colors.ruleFaint,
                      ),
                      InkTableRow(
                        title: "My exam isn't on this list",
                        chevron: InkRowChevron.link,
                        onTap: () => GoRouter.maybeOf(context)
                            ?.push('/onboarding/custom/name'),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            BoardButton(
              label: 'Continue',
              onPressed: (_selectedId == null || _saving) ? null : _onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
