import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The situations that replace the Today checklist (D-63, D-65).
enum HomeState { assessment, noContent, nothingDue, reviewOnly, dayOff, passed }

class HomeStateCard extends StatelessWidget {
  const HomeStateCard({
    required this.state,
    required this.examName,
    required this.examShortName,
    required this.onPrimary,
    this.onSecondary,
    this.examDateLabel,
    this.hasExamDate = true,
    this.web = kIsWeb,
    super.key,
  });
  final bool web;
  final HomeState state;
  final String examName;
  final String examShortName;

  /// Null hides the action: advance is never drawn disabled.
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final String? examDateLabel;
  final bool hasExamDate;

  String get _title => switch (state) {
        HomeState.assessment => 'First, a short assessment',
        HomeState.noContent => 'Lessons are on the way',
        HomeState.nothingDue || HomeState.reviewOnly => 'Nothing due today',
        HomeState.dayOff => 'Day off',
        HomeState.passed => 'Did you take $examShortName?',
      };

  String get _detail => switch (state) {
        HomeState.assessment => 'We check your strengths and weak spots '
            'first, so your plan is built around you.',
        HomeState.noContent =>
          "$examName lessons and questions aren't in Pantas yet, "
              "so there's no plan. You can switch exams in Settings.",
        HomeState.nothingDue => "You've covered everything in your plan.",
        HomeState.reviewOnly =>
          'These last days before $examShortName are reviews only, '
              'and none are due today.',
        HomeState.dayOff =>
          'Nothing is planned today, and your streak is safe. '
              "If you feel like it, the next study day's lesson "
              'can move to today.',
        HomeState.passed => examDateLabel == null
            ? "Tell us what's next."
            : 'Your $examShortName date was $examDateLabel. '
                "Tell us what's next.",
      };

  String? get _action => switch (state) {
        HomeState.assessment => 'Start Assessment',
        HomeState.noContent => 'Switch Exam',
        HomeState.nothingDue ||
        HomeState.reviewOnly =>
          'Practice Weakest Topics',
        HomeState.dayOff => 'I Want to Advance',
        HomeState.passed => 'Set a New Date',
      };

  @override
  Widget build(BuildContext context) {
    if (isWideWebLayout(width: MediaQuery.sizeOf(context).width, web: web)) {
      return CallbackShortcuts(
        bindings: {
          if (state == HomeState.assessment && onPrimary != null)
            const SingleActivator(LogicalKeyboardKey.enter): onPrimary!,
        },
        child: Focus(
          autofocus: state == HomeState.assessment,
          child: WebCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title, style: context.webTokens.h3),
                if (state != HomeState.nothingDue || hasExamDate) ...[
                  const SizedBox(height: 6),
                  Text(_detail, style: context.webTokens.sub),
                ],
                if (onPrimary != null && _action != null ||
                    state == HomeState.passed && onSecondary != null) ...[
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (onPrimary != null && _action != null)
                        WebButton(
                          label: _action!,
                          keyHint:
                              state == HomeState.assessment ? 'Enter' : null,
                          onPressed: onPrimary,
                          variant: state == HomeState.assessment
                              ? WebButtonVariant.primary
                              : WebButtonVariant.secondary,
                        ),
                      if (state == HomeState.passed && onSecondary != null)
                        WebButton(
                          label: 'Switch Exams',
                          onPressed: onSecondary,
                          variant: WebButtonVariant.white,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    final detail = Text(
      _detail,
      style: context.type.subhead.copyWith(
        color: context.colors.secondaryLabel,
        height: 1.4,
      ),
    );
    final action = onPrimary == null ? null : _action;
    if (state == HomeState.assessment || state == HomeState.noContent) {
      final assessment = state == HomeState.assessment;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: assessment
              ? const EdgeInsets.fromLTRB(18, 20, 18, 18)
              : const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _title,
                style: context.type.emphasized.copyWith(
                  fontSize: assessment ? 22 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: assessment ? 8 : 10),
              detail,
              if (action != null) ...[
                SizedBox(height: assessment ? 8 : 10),
                PantasButton(
                  label: action,
                  onPressed: onPrimary,
                  height: assessment ? 52 : 44,
                  fontSize: assessment ? 17 : 15,
                ),
              ],
            ],
          ),
        ),
      );
    }
    return GroupedSection(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, action == null ? 16 : 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_title, style: context.type.emphasized),
              if (state != HomeState.nothingDue || hasExamDate) ...[
                const SizedBox(height: 6),
                detail,
              ],
            ],
          ),
        ),
        if (action != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PantasButton(
                  label: action,
                  onPressed: onPrimary,
                  variant: PantasButtonVariant.secondary,
                ),
                if (state == HomeState.passed && onSecondary != null) ...[
                  const SizedBox(height: 8),
                  PantasButton(
                    label: 'Switch Exams',
                    onPressed: onSecondary,
                    variant: PantasButtonVariant.neutral,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
