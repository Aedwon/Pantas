import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

enum WorkStepState { pending, active, done }

@immutable
class WorkStep {
  const WorkStep({required this.label, required this.state, this.detail});
  final String label;
  final WorkStepState state;
  final String? detail;
}

// L_Restore's decorative pending dot.

class StepsScreen extends StatelessWidget {
  const StepsScreen({
    required this.title,
    required this.steps,
    this.subtitle,
    this.buttonLabel,
    this.onContinue,
    super.key,
  });
  final String title;
  final List<WorkStep> steps;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onContinue;
  Widget mark(BuildContext context, int index) {
    final c = context.colors;
    return switch (steps[index].state) {
      WorkStepState.pending => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: c.pendingMark,
            shape: BoxShape.circle,
          ),
        ),
      WorkStepState.active => SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: c.accent,
            value: MediaQuery.disableAnimationsOf(context) ? 1 : null,
          ),
        ),
      WorkStepState.done => PantasEffects.pop(
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) => child!,
          child: Container(
            key: ValueKey('step-done-$index'),
            width: 22,
            height: 22,
            decoration:
                BoxDecoration(color: c.accentFill, shape: BoxShape.circle),
            child: Icon(
              PantasIcons.check,
              size: 12,
              color: c.onAccent,
            ),
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      rows.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            border: i < steps.length - 1
                ? Border(
                    bottom: BorderSide(
                      color: context.colors.separator,
                      width: .5,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 24,
                child: Center(child: mark(context, i)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(steps[i].label, style: context.type.body),
                    if (steps[i].detail != null)
                      Text(steps[i].detail!, style: context.type.footnote),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (context.wideWeb) {
      final t = context.webTokens;
      return Scaffold(
        backgroundColor: t.colors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: t.h2),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: t.style(
                        17,
                        height: 1.45,
                        color: t.colors.secondaryLabel,
                      ),
                    ),
                  ],
                  if (rows.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    WebCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: rows,
                      ),
                    ),
                  ],
                  if (buttonLabel != null) ...[
                    const SizedBox(height: 20),
                    WebButton(label: buttonLabel!, onPressed: onContinue),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: context.colors.background,
      bottomNavigationBar: buttonLabel == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                child: PantasButton(
                  label: buttonLabel!,
                  onPressed: onContinue,
                ),
              ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 96, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.type.sectionHero
                    .copyWith(fontSize: 26, letterSpacing: -.312),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: context.type.subhead.copyWith(
                    color: context.colors.secondaryLabel,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              GroupedSection(children: rows),
            ],
          ),
        ),
      ),
    );
  }
}
