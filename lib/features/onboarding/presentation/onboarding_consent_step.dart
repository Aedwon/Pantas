import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/ink_checkbox.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

class OnboardingConsentStep extends ConsumerStatefulWidget {
  const OnboardingConsentStep({
    required this.onCompleted,
    super.key,
  });

  final VoidCallback onCompleted;

  @override
  ConsumerState<OnboardingConsentStep> createState() =>
      _OnboardingConsentStepState();
}

class _OnboardingConsentStepState extends ConsumerState<OnboardingConsentStep> {
  bool _acceptedTerms = false;
  bool _acceptedUsage = false;
  bool _saving = false;

  Future<void> _onContinue() async {
    if (!_acceptedTerms || _saving) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.recordPolicyAcceptance();
      await repo.updateHelpImproveApp(enabled: _acceptedUsage);
      ref
        ..invalidate(settingsRepositoryProvider)
        ..invalidate(userSettingsProvider);
      widget.onCompleted();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text('Terms & Privacy', style: styles.displaySmall),
                    const SizedBox(height: 10),
                    Text(
                      'Please review and accept our terms to continue.',
                      style: styles.bodyLarge.copyWith(color: colors.inkMuted),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkCheckbox.binary(
                          isSelected: _acceptedTerms,
                          onTap: () =>
                              setState(() => _acceptedTerms = !_acceptedTerms),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(
                              () => _acceptedTerms = !_acceptedTerms,
                            ),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'I agree to the ',
                                  style: styles.bodyMedium,
                                ),
                                GestureDetector(
                                  onTap: () => context.push('/legal/terms'),
                                  child: Text(
                                    'Terms of Service',
                                    style: styles.bodyMedium.copyWith(
                                      color: colors.board,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text(' and ', style: styles.bodyMedium),
                                GestureDetector(
                                  onTap: () => context.push('/legal/privacy'),
                                  child: Text(
                                    'Privacy Policy',
                                    style: styles.bodyMedium.copyWith(
                                      color: colors.board,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text('.', style: styles.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkCheckbox.binary(
                          isSelected: _acceptedUsage,
                          onTap: () =>
                              setState(() => _acceptedUsage = !_acceptedUsage),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(
                              () => _acceptedUsage = !_acceptedUsage,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Help improve Pantas by sharing anonymous '
                                  'usage data',
                                  style: styles.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sends anonymous data about how the app is '
                                  'used, '
                                  'including which questions get answered '
                                  'correctly. Never your name, and never '
                                  'anything you type.',
                                  style: styles.bodySmall
                                      .copyWith(color: colors.inkMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    BoardButton(
                      label: 'Continue',
                      onPressed:
                          (!_acceptedTerms || _saving) ? null : _onContinue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
