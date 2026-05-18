import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
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
    final theme = Theme.of(context);
    final examsAsync = ref.watch(examListProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Choose your exam',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'You can switch later in More.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: examsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Could not load exams.')),
                data: (exams) {
                  final active = [...exams.where((e) => e.isActive)]
                    ..sort((a, b) => a.name.compareTo(b.name));
                  if (active.isEmpty) {
                    return const Center(
                      child: Text('No exams available right now.'),
                    );
                  }
                  return ListView.separated(
                    itemCount: active.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final exam = active[i];
                      return _ExamCard(
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
            FilledButton(
              onPressed: (_selectedId == null || _saving) ? null : _onContinue,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.exam,
    required this.selected,
    required this.onTap,
  });

  final Exam exam;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                exam.code,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                exam.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
