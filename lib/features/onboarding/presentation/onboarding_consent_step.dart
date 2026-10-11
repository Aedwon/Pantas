import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

class OnboardingConsentStep extends ConsumerStatefulWidget {
  const OnboardingConsentStep({
    required this.onCompleted,
    this.onBack,
    super.key,
  });
  final VoidCallback onCompleted;
  final VoidCallback? onBack;
  @override
  ConsumerState<OnboardingConsentStep> createState() =>
      _OnboardingConsentStepState();
}

class _OnboardingConsentStepState extends ConsumerState<OnboardingConsentStep> {
  bool _acceptedTerms = false;
  bool _acceptedUsage = false;
  bool _saving = false;
  bool _failed = false;

  Future<void> _continue() async {
    if (!_acceptedTerms || _saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      final repo = ref.read(settingsRepositoryProvider);
      // Acceptance is the resume marker. Write it only once both choices save.
      await repo.updateHelpImproveApp(enabled: _acceptedUsage);
      await repo.recordPolicyAcceptance();
      ref
        ..invalidate(settingsRepositoryProvider)
        ..invalidate(userSettingsProvider);
      if (mounted) widget.onCompleted();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        context.type.body.copyWith(fontSize: 16, letterSpacing: 0, height: 1.4);
    Widget plain(String text) =>
        ExcludeSemantics(child: Text(text, style: textStyle));
    Widget link(String text, String route) => TextButton(
          onPressed: () => context.push(route),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            text,
            style: textStyle.copyWith(color: context.colors.accent),
          ),
        );
    return PantasPage.onboarding(
      title: 'Terms and Privacy',
      detail: 'Please review and accept our terms to continue.',
      progress: 2,
      onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
      bottom: PantasButton(
        label: 'Continue',
        onPressed: !_acceptedTerms || _saving ? null : _continue,
        busy: _saving,
      ),
      children: [
        GroupedSection(
          children: [
            ListRow.checkbox(
              title: 'Help improve Pantas by sharing anonymous usage data',
              selected: _acceptedUsage,
              onTap: _saving
                  ? null
                  : () => setState(() => _acceptedUsage = !_acceptedUsage),
            ),
            ListRow.checkbox(
              title: 'I agree to the Terms of Service and Privacy Policy.',
              selected: _acceptedTerms,
              onTap: _saving
                  ? null
                  : () => setState(() => _acceptedTerms = !_acceptedTerms),
              content: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  plain('I agree to the '),
                  link('Terms of Service', '/legal/terms'),
                  plain(' and '),
                  link('Privacy Policy', '/legal/privacy'),
                  plain('.'),
                ],
              ),
            ),
          ],
        ),
        if (_failed) saveFailureLine(_continue),
      ],
    );
  }
}
