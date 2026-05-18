import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingAgeGateStep extends ConsumerStatefulWidget {
  const OnboardingAgeGateStep({
    required this.onAgeGatePassed,
    required this.currentYear,
    super.key,
  });

  final VoidCallback onAgeGatePassed;
  final int currentYear;

  @override
  ConsumerState<OnboardingAgeGateStep> createState() =>
      _OnboardingAgeGateStepState();
}

class _OnboardingAgeGateStepState extends ConsumerState<OnboardingAgeGateStep> {
  static const _minAge = 13;
  late final int _minYear = widget.currentYear - 100;
  late final int _maxYear = widget.currentYear;
  late final int _defaultYear = widget.currentYear - 18;
  late int _selectedYear = _defaultYear;
  bool _yearSelected = false;
  bool _blocked = false;
  bool _saving = false;

  Future<void> _onContinue() async {
    final cutoff = widget.currentYear - _minAge;
    if (_selectedYear > cutoff) {
      setState(() => _blocked = true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(appPreferencesRepositoryProvider).setPassedAgeGate(true);
      ref.invalidate(appPreferencesRepositoryProvider);
      widget.onAgeGatePassed();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_blocked) return _buildBlocked(context);
    return _buildInput(context);
  }

  Widget _buildInput(BuildContext context) {
    final theme = Theme.of(context);
    final years = List<int>.generate(
      _maxYear - _minYear + 1,
      (i) => _minYear + i,
    );
    final initialIndex = years.indexOf(_defaultYear);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Quick check',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'When were you born?',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController:
                    FixedExtentScrollController(initialItem: initialIndex),
                onSelectedItemChanged: (i) => setState(() {
                  _selectedYear = years[i];
                  _yearSelected = true;
                }),
                children: [for (final y in years) Center(child: Text('$y'))],
              ),
            ),
            FilledButton(
              onPressed: (_saving || !_yearSelected) ? null : _onContinue,
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

  Widget _buildBlocked(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sorry, this app isn't available for users under 13.",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() => _blocked = false),
              child: const Text('Try a different year'),
            ),
          ],
        ),
      ),
    );
  }
}
