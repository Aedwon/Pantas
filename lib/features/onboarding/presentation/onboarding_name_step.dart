import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_field.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

class OnboardingNameStep extends ConsumerStatefulWidget {
  const OnboardingNameStep({required this.onCompleted, this.onBack, super.key});
  final VoidCallback onCompleted;
  final VoidCallback? onBack;
  @override
  ConsumerState<OnboardingNameStep> createState() => _OnboardingNameStepState();
}

class _OnboardingNameStepState extends ConsumerState<OnboardingNameStep> {
  final _controller = TextEditingController();
  bool _saving = false;
  bool _failed = false;
  bool _loadFailed = false;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final telemetry = ref.read(telemetryProvider);
    if (_loadFailed) setState(() => _loadFailed = false);
    try {
      final settings =
          await ref.read(settingsRepositoryProvider).readUserSettings();
      if (mounted && _controller.text.isEmpty && settings.name != null) {
        setState(() => _controller.text = settings.name!);
      }
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _saving) return;
    final generation = _generation;
    final telemetry = ref.read(telemetryProvider);
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await ref.read(settingsRepositoryProvider).updateName(text);
      if (mounted && generation == _generation) widget.onCompleted();
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => OnboardingWebPage(
        title: 'What should we call you?',
        detail:
            "We'll use this to greet you across the app. A nickname is fine.",
        progress: 6,
        onBack: () {
          _generation++;
          widget.onBack?.call();
        },
        bottom: OnboardingActions(
          children: [
            if (_failed) saveFailureLine(_save),
            OnboardingButton(
              label: 'Done',
              busy: _saving,
              onPressed:
                  _saving || _loadFailed || _controller.text.trim().isEmpty
                      ? null
                      : _save,
            ),
          ],
        ),
        children: [
          if (_loadFailed)
            errorFor('name', _restore)
          else
            OnboardingNameField(
              controller: _controller,
              label: 'Name',
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
            ),
        ],
      );
}
