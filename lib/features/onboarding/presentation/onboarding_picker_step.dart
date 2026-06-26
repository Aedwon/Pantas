import 'dart:async';

import 'package:cse_cet_reviewer/app/telemetry_providers.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/telemetry/telemetry.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                  final active = [...exams.where((e) => e.isActive)]
                    ..sort((a, b) => a.name.compareTo(b.name));
                  if (active.isEmpty) {
                    return Center(
                      child: Text(
                        'No exams available right now.',
                        style:
                            styles.bodyMedium.copyWith(color: colors.inkMuted),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: active.length,
                    itemBuilder: (_, i) {
                      final exam = active[i];
                      return _ExamRow(
                        exam: exam,
                        selected: _selectedId == exam.id,
                        onTap: () => setState(() => _selectedId = exam.id),
                      );
                    },
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

class _ExamRow extends StatelessWidget {
  const _ExamRow({
    required this.exam,
    required this.selected,
    required this.onTap,
  });

  final Exam exam;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: selected
            ? BoxDecoration(
                color: colors.boardTint,
                border: Border.all(color: colors.board),
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
              )
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.ruleFaint,
                    // ignore: avoid_redundant_argument_values
                    width: AppDimensions.hairline,
                  ),
                ),
              ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(
                exam.code,
                style: styles.headlineSmall.copyWith(
                  color: selected ? colors.board : colors.inkMuted,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                exam.name,
                style: styles.bodyMedium.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
