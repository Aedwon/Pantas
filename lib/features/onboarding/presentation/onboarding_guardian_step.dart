import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_field.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

/// Asks a student under 18 for a parent or guardian's contact and sends them
/// the link. Also serves Change Email from the Waiting screen.
class OnboardingGuardianStep extends ConsumerStatefulWidget {
  const OnboardingGuardianStep({required this.onSent, this.onBack, super.key});
  final VoidCallback onSent;
  final VoidCallback? onBack;
  @override
  ConsumerState<OnboardingGuardianStep> createState() =>
      _OnboardingGuardianStepState();
}

class _OnboardingGuardianStepState
    extends ConsumerState<OnboardingGuardianStep> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  bool _sending = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
  }

  /// Change Email starts from what the student typed before.
  Future<void> _restore() async {
    try {
      final contact =
          await ref.read(appPreferencesRepositoryProvider).guardianContact();
      if (contact == null || !mounted) return;
      if (_name.text.isEmpty && _email.text.isEmpty) {
        setState(() {
          _name.text = contact.name;
          _email.text = contact.email;
        });
      }
    } on Object catch (error, stack) {
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _ready =>
      _name.text.trim().isNotEmpty && looksLikeEmail(_email.text);

  Future<void> _send() async {
    if (_sending || !_ready) return;
    final telemetry = ref.read(telemetryProvider);
    setState(() {
      _sending = true;
      _failed = false;
    });
    try {
      await ref.read(guardianControllerProvider).sendLink(
            guardianName: _name.text,
            guardianEmail: _email.text,
          );
      if (mounted) widget.onSent();
    } on Object catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => OnboardingWebPage(
        title: 'A parent or guardian needs to agree first',
        detail:
            "You're under 18. We'll email them a link to review and confirm.",
        progress: 1,
        onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
        bottom: OnboardingActions(
          children: [
            if (_failed) saveFailureLine(_send),
            OnboardingButton(
              label: 'Send Link',
              busy: _sending,
              onPressed: _sending || !_ready ? null : _send,
            ),
          ],
        ),
        children: [
          OnboardingNameField(
            controller: _name,
            label: "Parent or guardian's name",
            // Wide web draws the label above the field, so the placeholder
            // gives an example instead of repeating it.
            hint: context.wideWeb ? 'Full name' : null,
            restingBorder: true,
            autofillHints: const [AutofillHints.name],
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          OnboardingNameField(
            controller: _email,
            label: "Parent or guardian's email",
            hint: context.wideWeb ? 'name@example.com' : null,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            maxLength: 254,
            restingBorder: true,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _send(),
          ),
        ],
      );
}
