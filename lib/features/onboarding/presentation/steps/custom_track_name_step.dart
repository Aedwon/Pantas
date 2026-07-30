import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class CustomTrackNameStep extends StatefulWidget {
  const CustomTrackNameStep({super.key});

  @override
  State<CustomTrackNameStep> createState() => _CustomTrackNameStepState();
}

class _CustomTrackNameStepState extends State<CustomTrackNameStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    final text = _controller.text.trim();
    final isValid = text.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'What are you studying for?',
                style: styles.displaySmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Give it a name you\'ll recognize. "PUP CET", "Nursing board".',
                style: styles.bodyMedium.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Exam name',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors.ruleFaint),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors.board, width: 2),
                  ),
                ),
              ),
              const Spacer(),
              BoardButton(
                label: 'Continue',
                onPressed: isValid
                    ? () {
                        final encodedName = Uri.encodeComponent(text);
                        GoRouter.maybeOf(context)?.push(
                          '/onboarding/custom/subjects?name=$encodedName',
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
