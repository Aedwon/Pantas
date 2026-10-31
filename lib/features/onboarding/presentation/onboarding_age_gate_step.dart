import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
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
  late final _yearController = TextEditingController(text: '$_selectedYear');
  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _changeYear(int delta) {
    setState(() {
      _selectedYear = (_selectedYear + delta)
          .clamp(widget.currentYear - 100, widget.currentYear);
      _yearController.text = '$_selectedYear';
    });
  }

  bool _blocked = false;
  bool _returning = false;
  bool _saving = false;
  bool _failed = false;

  bool get _validYear {
    final year = int.tryParse(_yearController.text);
    return year != null &&
        year >= widget.currentYear - 100 &&
        year <= widget.currentYear;
  }

  Future<void> _continue() async {
    if (_saving || (context.wideWeb && !_validYear)) return;
    if (_selectedYear > widget.currentYear - 13) {
      setState(() => _blocked = true);
      return;
    }
    final telemetry = ref.read(telemetryProvider);
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
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final back = widget.onBack ?? () => Navigator.of(context).maybePop();
    if (context.wideWeb && _blocked) {
      final t = context.webTokens;
      return Material(
        color: t.colors.background,
        child: Column(
          children: [
            const WebTopBar(
              leading: PantasLogo(size: 28),
              title: Text(
                'Pantas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              // Board: 40 top, 120 bottom, so the block sits above center.
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 40, 40, 120),
                child: Center(
                  child: SizedBox(
                    width: 460,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.string(
                          '<svg viewBox="0 0 24 24" fill="none" '
                          'stroke="currentColor" stroke-width="1.5" '
                          'stroke-linecap="round" stroke-linejoin="round"> '
                          '<rect x="5" y="10.5" width="14" height="10" '
                          'rx="2"/> '
                          '<path d="M8 10.5V7.5a4 4 0 0 1 8 0v3"/></svg>',
                          width: 44,
                          height: 44,
                          colorFilter: ColorFilter.mode(
                            t.colors.tertiaryLabel,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          "Pantas isn't available yet",
                          textAlign: TextAlign.center,
                          style: t
                              .style(
                                34,
                                weight: FontWeight.w700,
                                height: 1.15,
                              )
                              .copyWith(letterSpacing: -.748),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sorry, this app isn't available for users under 13.",
                          textAlign: TextAlign.center,
                          style: t.style(
                            17,
                            height: 1.45,
                            color: t.colors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextButton(
                          onPressed: () => setState(() => _blocked = false),
                          style: ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize:
                                const WidgetStatePropertyAll(Size(0, 46)),
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 22),
                            ),
                            backgroundColor: WidgetStateProperty.resolveWith(
                              (s) => s.contains(WidgetState.hovered)
                                  ? t.secondaryHover
                                  : t.colors.accentTint,
                            ),
                            foregroundColor: WidgetStatePropertyAll(t.tintText),
                            overlayColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            textStyle: WidgetStatePropertyAll(
                              t.style(16, weight: FontWeight.w600),
                            ),
                          ),
                          child: const Text('Try a Different Year'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_blocked) {
      final page = OnboardingWebPage(
        title: '',
        onBack: back,
        centerBody: true,
        surfaceBackground: true,
        bottom: OnboardingButton(
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
    final page = OnboardingWebPage(
      title: 'When were you born?',
      detail: 'We only ask this once and never keep it.',
      progress: 1,
      onBack: back,
      bottom: OnboardingButton(
        label: 'Continue',
        onPressed:
            _saving || (context.wideWeb && !_validYear) ? null : _continue,
        busy: _saving,
      ),
      children: [
        if (context.wideWeb) ...[
          Text('YEAR', style: context.webTokens.eb),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 240,
              height: 64,
              child: OnboardingShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                      _changeYear(1),
                  const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                      _changeYear(-1),
                },
                child: TextField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: context.webTokens.style(28, weight: FontWeight.w600),
                  onChanged: (text) => setState(
                    () => _selectedYear =
                        int.tryParse(text) ?? widget.currentYear,
                  ),
                  onSubmitted: (_) {
                    if (int.tryParse(_yearController.text) != null) {
                      _continue();
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.webTokens.colors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.webTokens.colors.accent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.webTokens.colors.accent,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.webTokens.colors.accent,
                        width: 2,
                      ),
                    ),
                    suffixIcon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: 'Next year',
                            onPressed: () => _changeYear(1),
                            icon: const Icon(
                              Icons.keyboard_arrow_up,
                              size: 14,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: 'Earlier year',
                            onPressed: () => _changeYear(-1),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Type it, or use ↑ and ↓.', style: context.webTokens.sm),
        ] else
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
