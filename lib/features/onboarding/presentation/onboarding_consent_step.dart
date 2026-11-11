import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/application/setup_acceptance.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

const _acceptanceTail = ', and to Pantas keeping my study records (answers, '
    'results and study times).';
const _acceptanceLabel = 'I agree to the Terms of Service and Privacy Policy'
    '$_acceptanceTail';

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

  /// Under 18 the student cannot turn sharing on, so the usage row is not
  /// offered.
  bool get _minor => ref.watch(ageGroupProvider).valueOrNull == 'minor';

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
  }

  /// Back from a later step returns here with what the student already
  /// accepted ticked, as the Year and Exam steps keep theirs (5S-9). A student
  /// who never accepted sees both boxes empty: nothing is ticked for them.
  Future<void> _restore() async {
    try {
      final settings =
          await ref.read(settingsRepositoryProvider).readUserSettings();
      if (!mounted || settings.acceptedTermsAt == null) return;
      // A tick made while this read was running is the student's, not ours.
      if (_acceptedTerms || _acceptedUsage) return;
      setState(() {
        _acceptedTerms = true;
        _acceptedUsage = settings.helpImproveApp;
      });
    } on Object catch (error, stack) {
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
    }
  }

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
      // Under 18, sharing stays off until the guardian allows it.
      final minor = ref.read(ageGroupProvider).valueOrNull == 'minor';
      await repo.updateHelpImproveApp(enabled: _acceptedUsage && !minor);
      await ref
          .read(appPreferencesRepositoryProvider)
          .setSetupAcceptanceVersion(SetupAcceptance.version);
      await repo.recordPolicyAcceptance();
      ref
        ..invalidate(settingsRepositoryProvider)
        ..invalidate(userSettingsProvider);
      // A named account is recorded now. An anonymous one is recorded when it
      // becomes named, or on the next start if this call fails.
      String? uid;
      try {
        uid = (await ref.read(currentUserProvider.future))?.uid;
      } on Object {
        // No account yet: the sync below records it once there is one.
      }
      unawaited(ref.read(setupAcceptanceRecorderProvider).recordIfNeeded(uid));
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
    bool wholeRow = false,
  }) {
    // Board OB_Terms: each consent row is 56 px tall and its hover fills the
    // row edge to edge. The card clips the outer corners.
    return CheckboxRow(
      interactiveContent: true,
      title: label,
      selected: value,
      onTap: _saving ? null : onChanged,
      content: child,
      minHeight: PantasSpace.s56,
      standardDensity: true,
      squareEdges: true,
      padding: const EdgeInsets.symmetric(
        horizontal: PantasSpace.s18,
        vertical: PantasSpace.s14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = PantasType.webBody.copyWith(
      color: context.colors.textPrimary,
    );
    final boardText = PantasType.phoneCallout.copyWith(
      color: context.colors.textPrimary,
    );
    Widget plain(String text) => ExcludeSemantics(
          child: Text(
            text,
            style: context.wideWeb ? textStyle : boardText,
          ),
        );
    Widget link(String text, String route) => WebTextLink(
          label: text,
          arrow: false,
          style: context.wideWeb ? textStyle : boardText,
          onPressed: () => context.push(route),
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
                  if (!_minor) ...[
                    _webConsentRow(
                      value: _acceptedUsage,
                      wholeRow: true,
                      label: 'Help improve Pantas by sharing usage data',
                      onChanged: () =>
                          setState(() => _acceptedUsage = !_acceptedUsage),
                      child: plain(
                        'Help improve Pantas by sharing usage data',
                      ),
                    ),
                    Divider(
                      height: PantasBorder.hairline,
                      thickness: PantasBorder.hairline,
                      color: context.webTokens.colors.separator,
                    ),
                  ],
                  _webConsentRow(
                    value: _acceptedTerms,
                    label: _acceptanceLabel,
                    onChanged: () =>
                        setState(() => _acceptedTerms = !_acceptedTerms),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        plain('I agree to the '),
                        link('Terms of Service', '/legal/terms'),
                        plain(' and '),
                        link('Privacy Policy', '/legal/privacy'),
                        plain(_acceptanceTail),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Board (O_Consent): 23.2 px lines, 13.5 px row padding, 14 px
          // between box and text, a half-point divider between the rows.
          GroupedSection(
            children: [
              if (!_minor) ...[
                CheckboxRow(
                  title: 'Help improve Pantas by sharing usage data',
                  selected: _acceptedUsage,
                  gap: PantasSpace.s14,
                  standardDensity: true,
                  onTap: _saving
                      ? null
                      : () => setState(() => _acceptedUsage = !_acceptedUsage),
                  content: Text(
                    'Help improve Pantas by sharing usage data',
                    style: boardText,
                  ),
                ),
                Divider(
                  height: PantasBorder.hairline,
                  thickness: PantasBorder.hairline,
                  color: context.colors.separator,
                ),
              ],
              CheckboxRow(
                title: _acceptanceLabel,
                selected: _acceptedTerms,
                gap: PantasSpace.s14,
                standardDensity: true,
                interactiveContent: true,
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
                    plain(_acceptanceTail),
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
