import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_field.dart';

class CustomTrackNameStep extends StatefulWidget {
  const CustomTrackNameStep({
    this.onContinue,
    this.onBack,
    this.initialName = '',
    super.key,
  });
  final ValueChanged<String>? onContinue;
  final VoidCallback? onBack;
  final String initialName;
  @override
  State<CustomTrackNameStep> createState() => _CustomTrackNameStepState();
}

class _CustomTrackNameStepState extends State<CustomTrackNameStep> {
  late final _controller = TextEditingController(text: widget.initialName);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (widget.onContinue != null) {
      widget.onContinue!(text);
    } else {
      context.push(
        '/onboarding/custom/subjects?name=${Uri.encodeComponent(text)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) => PantasPage.onboarding(
        title: 'What are you studying for?',
        detail: "Give it a name you'll recognize.",
        progress: 3,
        bodyGap: 24,
        onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
        bottom: PantasButton(
          label: 'Continue',
          onPressed: _controller.text.trim().isEmpty ? null : _next,
        ),
        children: [
          OnboardingNameField(
            controller: _controller,
            label: 'Exam name',
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _next(),
          ),
        ],
      );
}
