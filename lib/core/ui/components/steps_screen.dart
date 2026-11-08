import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
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

/// Phone: the title starts this far down the page (board L_Restore).
const double _phoneTitleTop = 96;

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
  Widget mark(BuildContext context, int index, {bool loadingRestore = false}) {
    final c = context.colors;
    return switch (steps[index].state) {
      WorkStepState.pending => Container(
          width: PantasSpace.s8,
          height: PantasSpace.s8,
          decoration: BoxDecoration(
            color: c.pendingMark,
            shape: BoxShape.circle,
          ),
        ),
      WorkStepState.active => SizedBox.square(
          dimension: loadingRestore ? PantasSpace.s16 : PantasSpace.s18,
          child: CircularProgressIndicator(
            strokeWidth: PantasBorder.ringSelected,
            color: c.accent,
            value: MediaQuery.disableAnimationsOf(context) ? 1 : null,
          ),
        ),
      WorkStepState.done => PantasEffects.pop(
          duration: PantasDurations.drawerClose,
          builder: (context, value, child) => child!,
          child: Container(
            key: ValueKey('step-done-$index'),
            width: loadingRestore ? PantasSize.task : PantasSpace.s24,
            height: loadingRestore ? PantasSize.task : PantasSpace.s24,
            decoration:
                BoxDecoration(color: c.accentFill, shape: BoxShape.circle),
            child: Icon(
              PantasIcons.check,
              size: PantasSpace.s12,
              color: c.onAccent,
            ),
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final loadingRestore = context.wideWeb &&
        title == 'Restoring your progress' &&
        steps.any((step) => step.state != WorkStepState.done);
    final rows = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      rows.add(
        Container(
          padding: context.wideWeb
              ? const EdgeInsets.symmetric(vertical: PantasSpace.s12)
              : const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s16,
                  vertical: PantasSpace.s12,
                ),
          decoration: BoxDecoration(
            border: i < steps.length - 1
                ? Border(
                    bottom: BorderSide(
                      color: context.colors.separator,
                      width: PantasBorder.hairline,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: PantasSpace.s24,
                child: Center(child: mark(context, i)),
              ),
              const SizedBox(width: PantasSpace.s14),
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
      if (loadingRestore) {
        return Scaffold(
          backgroundColor: t.colors.background,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(PantasSpace.s40),
              child: SizedBox(
                width: PantasLayout.modalWide,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: t.h2),
                    if (subtitle != null) ...[
                      const SizedBox(height: PantasSpace.s4),
                      Text(
                        subtitle!,
                        style: PantasType.webLead
                            .copyWith(color: t.colors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: PantasSpace.s20),
                    WebCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < steps.length; i++)
                            WebRow(
                              title: steps[i].label,
                              subtitle: steps[i].detail,
                              leading: SizedBox.square(
                                dimension: PantasSize.task,
                                child: Center(
                                  child: mark(context, i, loadingRestore: true),
                                ),
                              ),
                              compact: true,
                              divider: i < steps.length - 1,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: t.colors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(PantasSpace.s40),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: PantasLayout.modalWide),
              child: WebCard(
                padding: const EdgeInsets.all(PantasSpace.s32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: t.h2),
                    if (subtitle != null) ...[
                      const SizedBox(height: PantasSpace.s4),
                      Text(
                        subtitle!,
                        style: PantasType.webLead
                            .copyWith(color: t.colors.textSecondary),
                      ),
                    ],
                    if (rows.isNotEmpty) ...[
                      const SizedBox(height: PantasSpace.s24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: rows,
                      ),
                    ],
                    if (buttonLabel != null) ...[
                      const SizedBox(height: PantasSpace.s24),
                      CallbackShortcuts(
                        bindings: {
                          if (onContinue != null)
                            const SingleActivator(
                              LogicalKeyboardKey.enter,
                              includeRepeats: false,
                            ): onContinue!,
                        },
                        child: Focus(
                          autofocus: true,
                          child: Row(
                            children: [
                              if (steps.isNotEmpty &&
                                  steps.every(
                                    (s) => s.state == WorkStepState.done,
                                  ))
                                Expanded(
                                  child: Text(
                                    'Everything is back.',
                                    style: PantasType.webTitleSm
                                        .copyWith(color: t.colors.textPrimary),
                                  ),
                                )
                              else
                                const Spacer(),
                              WebButton(
                                label: buttonLabel!,
                                onPressed: onContinue,
                                keyHint: 'Enter',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s14,
                  PantasSpace.s16,
                  PantasSpace.s28,
                ),
                child: PantasButton(
                  label: buttonLabel!,
                  onPressed: onContinue,
                ),
              ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s16,
            _phoneTitleTop,
            PantasSpace.s16,
            PantasSpace.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.type.pageTitle,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: PantasSpace.s8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: context.type.subhead
                      .copyWith(color: context.colors.textSecondary),
                ),
              ],
              const SizedBox(height: PantasSpace.s20),
              GroupedSection(children: rows),
            ],
          ),
        ),
      ),
    );
  }
}
