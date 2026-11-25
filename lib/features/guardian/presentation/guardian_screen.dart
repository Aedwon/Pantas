import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/guardian/domain/guardian_copy.dart';

/// Wide web: space under the column, so it sits above the center (boards
/// G_*).
const double _bottomReserve = 120;

/// The full-screen frame for the guardian screens: no tab bar, no back link.
/// Phone uses the app's page type. Wide web uses the web onboarding frame, a
/// top bar over a centered column.
class GuardianScreen extends StatelessWidget {
  const GuardianScreen({
    required this.title,
    this.detail,
    this.children = const [],
    this.actions = const [],
    super.key,
  });
  final String title;
  final String? detail;

  /// Content between the text and the actions.
  final List<Widget> children;
  final List<Widget> actions;

  /// Wide web: two or more buttons, given main first as the phone stacks
  /// them, are one row at the column's right end, secondary first and main
  /// last, 8 apart (patterns.md, Button placement: "a stacked phone-style
  /// pair on a wide page (guardian confirm ...) becomes a right-aligned
  /// row"). A line before or after them (a save failure, a notice) stays
  /// centered.
  List<Widget> _wideActions() {
    final first = actions.indexWhere((a) => a is PantasButton);
    final last = actions.lastIndexWhere((a) => a is PantasButton);
    // A single action in this centered column stays centered (patterns.md,
    // centered layouts).
    if (first < 0 || first == last) {
      return [
        for (final (i, a) in actions.indexed) ...[
          if (i > 0) const SizedBox(height: PantasSpace.s4),
          Center(child: a),
        ],
      ];
    }
    return [
      for (final a in actions.sublist(0, first)) ...[
        Center(child: a),
        const SizedBox(height: PantasSpace.s4),
      ],
      Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: PantasSpace.s8,
        runSpacing: PantasSpace.s8,
        children: actions.sublist(first, last + 1).reversed.toList(),
      ),
      for (final a in actions.sublist(last + 1)) ...[
        const SizedBox(height: PantasSpace.s4),
        Center(child: a),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final t = context.webTokens;
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          liveRegion: true,
          child: BalancedText(
            title,
            textAlign: TextAlign.center,
            style: wide ? t.h1 : context.type.pageTitle,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: PantasSpace.s8),
          Text(
            detail!,
            textAlign: TextAlign.center,
            style: wide
                ? PantasType.webLead.copyWith(color: t.colors.textSecondary)
                : context.type.body.copyWith(
                    color: context.colors.textSecondary,
                  ),
          ),
        ],
        if (children.isNotEmpty) ...[
          const SizedBox(height: PantasSpace.s24),
          ...children,
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: PantasSpace.s28),
          if (wide)
            ..._wideActions()
          else
            for (final (i, action) in actions.indexed) ...[
              if (i > 0) const SizedBox(height: PantasSpace.s4),
              action,
            ],
        ],
      ],
    );
    if (wide) {
      return Material(
        color: t.colors.background,
        child: Column(
          children: [
            // The same bar as the onboarding steps.
            const OnboardingTopBar(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s40,
                    PantasSpace.s40,
                    PantasSpace.s40,
                    _bottomReserve,
                  ),
                  child: SizedBox(width: PantasLayout.modal, child: column),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s20,
              PantasSpace.s24,
              PantasSpace.s20,
              PantasSpace.s32,
            ),
            child: column,
          ),
        ),
      ),
    );
  }
}

/// A title that breaks into lines of similar length, so the last line is never
/// a single word left alone. It lays the text out at the full width, then finds
/// the narrowest width that keeps the same number of lines.
class BalancedText extends StatelessWidget {
  const BalancedText(
    this.text, {
    required this.style,
    this.textAlign,
    super.key,
  });
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final full = constraints.maxWidth;
        int lines(double width) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: direction,
            textScaler: scaler,
          )..layout(maxWidth: width);
          final count = painter.computeLineMetrics().length;
          painter.dispose();
          return count;
        }

        var width = full;
        if (full.isFinite && full > 0) {
          final target = lines(full);
          if (target > 1) {
            var low = 0.0;
            var high = full;
            for (var i = 0; i < 12; i++) {
              final mid = (low + high) / 2;
              if (lines(mid) <= target) {
                high = mid;
              } else {
                low = mid;
              }
            }
            width = high;
          }
        }
        return Center(
          child: SizedBox(
            width: width,
            child: Text(text, textAlign: textAlign, style: style),
          ),
        );
      },
    );
  }
}

/// The end state a closed student sees. The guardian's own page says
/// "Permission withdrawn" in the manage page instead.
class GuardianWithdrawnPage extends StatelessWidget {
  const GuardianWithdrawnPage({super.key});

  @override
  Widget build(BuildContext context) => const GuardianScreen(
        title: GuardianCopy.accountClosedTitle,
        detail: GuardianCopy.accountClosedDetail,
      );
}
