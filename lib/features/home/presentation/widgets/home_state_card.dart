import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
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

  /// A role as the `RRGGBB` an inline SVG stroke takes.
  static String _hex(Color color) =>
      color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);

  /// The board card: a 20 px inset, the 20 px title beside a 40 px
  /// icon for the quiet days, 22 px without one, and the line at 16 px.
  Widget _wideCard(BuildContext context) {
    final t = context.webTokens;
    final icon = switch (state) {
      HomeState.nothingDue || HomeState.reviewOnly => _wideIcon(
          // The card is the surface color in dark, so the circle takes the
          // accent tint there or it would not show.
          t.colors.accentTint,
          '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" '
          'stroke="${_hex(t.colors.accent)}" stroke-width="2.4" '
          'stroke-linecap="round" '
          'stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7"/></svg>',
        ),
      HomeState.dayOff => _wideIcon(
          t.colors.fill,
          '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" '
          'stroke="${_hex(t.colors.textSecondary)}" stroke-width="1.8" '
          'stroke-linecap="round" '
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
          style: (big ? PantasType.webH3Lg : PantasType.webH3)
              .copyWith(color: t.colors.textPrimary),
        ),
        if (state != HomeState.nothingDue || hasExamDate) ...[
          const SizedBox(height: PantasSpace.s6),
          Text(
            _detail,
            style: PantasType.webBody
                .copyWith(height: 1.45, color: t.colors.textSecondary),
          ),
        ],
        if (onPrimary != null && _action != null ||
            state == HomeState.passed && onSecondary != null) ...[
          SizedBox(height: assessment ? 20 : 18),
          // P2 (Nov 7): a card's buttons sit at its right end, the main one
          // last, at the card size of 44 px.
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                if (state == HomeState.passed && onSecondary != null)
                  WebButton(
                    label: 'Switch Exams',
                    onPressed: onSecondary,
                    variant: WebButtonVariant.white,
                  ),
                if (onPrimary != null && _action != null)
                  WebButton(
                    label: _action!,
                    keyHint: assessment ? 'Enter' : null,
                    onPressed: onPrimary,
                    variant: assessment
                        ? WebButtonVariant.primary
                        : WebButtonVariant.secondary,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
    final card = WebCard(
      // Home cards share one 20 px inset (D183).
      padding: const EdgeInsets.all(PantasSpace.s20),
      child: icon == null
          ? body
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(width: PantasSpace.s18),
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
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s4,
            PantasSpace.s0,
            PantasSpace.s4,
            PantasSpace.s8,
          ),
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
            const SingleActivator(
              LogicalKeyboardKey.enter,
              includeRepeats: false,
            ): onPrimary!,
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
        color: context.colors.textSecondary,
        height: 1.4,
      ),
    );
    final action = onPrimary == null ? null : _action;
    if (state == HomeState.assessment || state == HomeState.noContent) {
      final assessment = state == HomeState.assessment;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceCard,
          borderRadius: BorderRadius.circular(PantasRadius.xl),
        ),
        child: Padding(
          padding: assessment
              ? const EdgeInsets.fromLTRB(
                  PantasSpace.s18,
                  PantasSpace.s20,
                  PantasSpace.s18,
                  PantasSpace.s18,
                )
              : const EdgeInsets.all(PantasSpace.s16),
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
                // Board (HE_BeforeAssessment): 8 px gap plus 8 px above the
                // button.
                SizedBox(height: assessment ? 16 : 10),
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
          padding: EdgeInsets.fromLTRB(
            PantasSpace.s16,
            PantasSpace.s16,
            PantasSpace.s16,
            action == null ? PantasSpace.s16 : PantasSpace.s4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_title, style: context.type.emphasized),
              if (state != HomeState.nothingDue || hasExamDate) ...[
                const SizedBox(height: PantasSpace.s6),
                detail,
              ],
            ],
          ),
        ),
        if (action != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s10,
              PantasSpace.s16,
              PantasSpace.s16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PantasButton(
                  label: action,
                  onPressed: onPrimary,
                  variant: PantasButtonVariant.secondary,
                ),
                if (state == HomeState.passed && onSecondary != null) ...[
                  const SizedBox(height: PantasSpace.s8),
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
