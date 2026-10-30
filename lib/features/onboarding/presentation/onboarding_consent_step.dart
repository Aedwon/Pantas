import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
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
    final telemetry = ref.read(telemetryProvider);
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
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _webConsentRow({
    required bool value,
    required String label,
    required VoidCallback onChanged,
    required Widget child,
  }) {
    final t = context.webTokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Semantics(
            label: label,
            checked: value,
            child: SizedBox.square(
              dimension: 24,
              child: TextButton(
                key: ValueKey(label),
                onPressed: _saving ? null : onChanged,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor:
                      value ? t.colors.accentFill : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                    side: value
                        ? BorderSide.none
                        : BorderSide(
                            color: t.colors.controlOutline,
                            width: 1.5,
                          ),
                  ),
                ),
                child: value
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: child),
        ],
      ),
    );
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
    return OnboardingWebPage(
      title: 'Terms and Privacy',
      detail: 'Please review and accept our terms to continue.',
      progress: 2,
      onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
      bottom: OnboardingButton(
        label: 'Continue',
        onPressed: !_acceptedTerms || _saving ? null : _continue,
        busy: _saving,
      ),
      children: [
        if (context.wideWeb)
          WebCard(
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  _webConsentRow(
                    value: _acceptedUsage,
                    label:
                        'Help improve Pantas by sharing anonymous usage data',
                    onChanged: () =>
                        setState(() => _acceptedUsage = !_acceptedUsage),
                    child: plain(
                      'Help improve Pantas by sharing anonymous usage data',
                    ),
                  ),
                  Divider(
                    height: .5,
                    thickness: .5,
                    color: context.webTokens.colors.separator,
                  ),
                  _webConsentRow(
                    value: _acceptedTerms,
                    label: 'I agree to the Terms of Service and Privacy Policy',
                    onChanged: () =>
                        setState(() => _acceptedTerms = !_acceptedTerms),
                    child: Wrap(
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
            ),
          )
        else
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
