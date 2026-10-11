import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';

class OnboardingAgeGateStep extends ConsumerStatefulWidget {
  const OnboardingAgeGateStep({
    required this.onAgeGatePassed,
    required this.currentYear,
    this.onBack,
    super.key,
  });
  final VoidCallback onAgeGatePassed;
  final VoidCallback? onBack;
  final int currentYear;
  @override
  ConsumerState<OnboardingAgeGateStep> createState() =>
      _OnboardingAgeGateStepState();
}

class _OnboardingAgeGateStepState extends ConsumerState<OnboardingAgeGateStep> {
  late final List<int> _years =
      List.generate(101, (i) => widget.currentYear - 100 + i);
  late int _selectedYear = widget.currentYear - 14;
  bool _blocked = false;
  bool _returning = false;
  bool _saving = false;
  bool _failed = false;

  Future<void> _continue() async {
    if (_saving) return;
    if (_selectedYear > widget.currentYear - 13) {
      setState(() => _blocked = true);
      return;
    }
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await ref
          .read(appPreferencesRepositoryProvider)
          .setPassedAgeGate(value: true);
      ref.invalidate(appPreferencesRepositoryProvider);
      if (mounted) widget.onAgeGatePassed();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final back = widget.onBack ?? () => Navigator.of(context).maybePop();
    if (_blocked) {
      final page = PantasPage.onboarding(
        title: '',
        onBack: back,
        centerBody: true,
        surfaceBackground: true,
        bottom: PantasButton(
          label: 'Try a Different Year',
          onPressed: () => setState(() {
            _blocked = false;
            _returning = true;
          }),
        ),
        children: const [
          StateView.onboardingBlocked(
            message: "Pantas isn't available yet",
            detail: "Sorry, this app isn't available for users under 13.",
            icon: OnboardingLogo(size: 72),
          ),
        ],
      );
      return PantasEffects.fade(
        duration: const Duration(milliseconds: 300),
        builder: (_, progress, child) => IgnorePointer(
          ignoring: progress == 0,
          child: ExcludeFocus(excluding: progress == 0, child: child!),
        ),
        child: page,
      );
    }
    final page = PantasPage.onboarding(
      title: 'When were you born?',
      detail: 'We only ask this once and never keep it.',
      progress: 1,
      onBack: back,
      bottom: PantasButton(
        label: 'Continue',
        onPressed: _saving ? null : _continue,
        busy: _saving,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ValueWheel.birthYear(
            values: [for (final year in _years) '$year'],
            selectedIndex: _years.indexOf(_selectedYear),
            label: 'Birth year',
            onSelected: (index) =>
                setState(() => _selectedYear = _years[index]),
          ),
        ),
        if (_failed) saveFailureLine(_continue),
      ],
    );
    return _returning
        ? KeyedSubtree(
            key: const ValueKey('age-return-motion'),
            child: PantasEffects.push(
              duration: const Duration(milliseconds: 380),
              builder: (_, progress, child) => IgnorePointer(
                ignoring: progress == 0,
                child: ExcludeFocus(excluding: progress == 0, child: child!),
              ),
              child: page,
            ),
          )
        : page;
  }
}
