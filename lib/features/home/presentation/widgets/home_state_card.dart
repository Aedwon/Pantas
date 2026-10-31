import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  /// The board card: padding 26 / 24 / 22, the 20 px title beside a 40 px
  /// icon for the quiet days, 22 px without one, and the line at 16 px.
  Widget _wideCard(BuildContext context) {
    final t = context.webTokens;
    final icon = switch (state) {
      HomeState.nothingDue || HomeState.reviewOnly => _wideIcon(
          t.dark ? t.colors.surface : const Color(0xFFE4F1EE),
          '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" '
          'stroke="#0B7A68" stroke-width="2.4" stroke-linecap="round" '
          'stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7"/></svg>',
        ),
      HomeState.dayOff => _wideIcon(
          t.dark ? t.colors.surface : const Color(0xFFF5F5F7),
          '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" '
          'stroke="#8A8A8E" stroke-width="1.8" stroke-linecap="round" '
          'stroke-linejoin="round"><path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 '
          '6.5 0 0 0 10.5 10.5z"/></svg>',
        ),
      _ => null,
    };
    final big = icon == null;
    final assessment = state == HomeState.assessment;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: t.style(big ? 22 : 20, weight: FontWeight.w700, height: 1.3),
        ),
        if (state != HomeState.nothingDue || hasExamDate) ...[
          const SizedBox(height: 6),
          Text(
            _detail,
            style: t.style(16, height: 1.45, color: t.colors.secondaryLabel),
          ),
        ],
        if (onPrimary != null && _action != null ||
            state == HomeState.passed && onSecondary != null) ...[
          SizedBox(height: assessment ? 20 : 18),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (onPrimary != null && _action != null)
                WebButton(
                  label: _action!,
                  keyHint: assessment ? 'Enter' : null,
                  large: assessment,
                  onPressed: onPrimary,
                  variant: assessment
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
    );
    final card = WebCard(
      padding: EdgeInsets.fromLTRB(24, 26, 24, assessment ? 24 : 22),
      child: icon == null
          ? body
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(width: 18),
                Expanded(child: body),
              ],
            ),
    );
    // The assessment board labels its card; the other quiet days are labeled
    // by the Today header above them.
    if (!assessment) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
          child: Text('TODAY', style: t.eb),
        ),
        card,
      ],
    );
  }

  Widget _wideIcon(Color fill, String svg) => Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        child: SvgPicture.string(svg, width: 20, height: 20),
      );

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
          child: _wideCard(context),
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
