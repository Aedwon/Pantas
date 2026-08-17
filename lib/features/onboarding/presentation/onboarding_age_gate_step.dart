import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
      final repo = ref.read(appPreferencesRepositoryProvider);
      await repo.setPassedAgeGate(value: true);
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
    final styles = context.textStyles;
    final colors = context.colors;
    final years = List<int>.generate(
      _maxYear - _minYear + 1,
      (i) => _minYear + i,
    );
    final initialIndex = years.indexOf(_defaultYear);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text('Quick check', style: styles.displaySmall),
            const SizedBox(height: 10),
            Text(
              'When were you born?',
              style: styles.bodyLarge.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: CupertinoPicker.builder(
                itemExtent: 32,
                scrollController:
                    FixedExtentScrollController(initialItem: initialIndex),
                onSelectedItemChanged: (i) => setState(() {
                  _selectedYear = years[i];
                  _yearSelected = true;
                }),
                childCount: years.length,
                itemBuilder: (context, i) => Center(child: Text('${years[i]}')),
              ),
            ),
            BoardButton(
              label: 'Continue',
              onPressed: (_saving || !_yearSelected) ? null : _onContinue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocked(BuildContext context) {
    final styles = context.textStyles;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sorry, this app isn't available for users under 13.",
              style: styles.headlineMedium,
            ),
            const SizedBox(height: 24),
            BoardButton(
              label: 'Try a different year',
              secondary: true,
              onPressed: () => setState(() => _blocked = false),
            ),
          ],
        ),
      ),
    );
  }
}
