import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

class OnboardingNameStep extends ConsumerStatefulWidget {
  const OnboardingNameStep({
    required this.onCompleted,
    super.key,
  });

  final VoidCallback onCompleted;

  @override
  ConsumerState<OnboardingNameStep> createState() => _OnboardingNameStepState();
}

class _OnboardingNameStepState extends ConsumerState<OnboardingNameStep> {
  final TextEditingController _controller = TextEditingController();
  bool _saving = false;

  String get _trimmedText => _controller.text.trim();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDone() async {
    if (_trimmedText.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(settingsRepositoryProvider).updateName(_trimmedText);
      await ref
          .read(appPreferencesRepositoryProvider)
          .setCompletedOnboarding(value: true);
      ref.invalidate(appPreferencesRepositoryProvider);
      widget.onCompleted();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onSkip() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(appPreferencesRepositoryProvider)
          .setCompletedOnboarding(value: true);
      ref.invalidate(appPreferencesRepositoryProvider);
      widget.onCompleted();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    final underlineBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: colors.rule,
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text('What should we call you?', style: styles.displaySmall),
            const SizedBox(height: 10),
            Text(
              "We'll use this to greet you across the app. A nickname is fine.",
              style: styles.bodyLarge.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.words,
              maxLength: 40,
              style: styles.bodyLarge,
              decoration: InputDecoration(
                border: underlineBorder,
                enabledBorder: underlineBorder,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: colors.ink,
                  ),
                ),
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const Spacer(),
            BoardButton(
              label: 'Done',
              onPressed: (_trimmedText.isEmpty || _saving) ? null : _onDone,
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _saving ? null : _onSkip,
              child: Text(
                'Skip',
                textAlign: TextAlign.center,
                style: styles.bodyMedium.copyWith(color: colors.board),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
