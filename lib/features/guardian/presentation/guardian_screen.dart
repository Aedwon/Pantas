import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

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
            style: wide
                ? t
                    .style(34, weight: FontWeight.w700, height: 1.15)
                    .copyWith(letterSpacing: -.748)
                : context.type.pageTitle,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: 8),
          Text(
            detail!,
            textAlign: TextAlign.center,
            style: wide
                ? t.style(17, height: 1.45, color: t.colors.secondaryLabel)
                : context.type.body.copyWith(
                    color: context.colors.secondaryLabel,
                    height: 1.4,
                  ),
          ),
        ],
        if (children.isNotEmpty) ...[
          const SizedBox(height: 24),
          ...children,
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 28),
          for (final (i, action) in actions.indexed) ...[
            if (i > 0) const SizedBox(height: 4),
            // Wide web buttons hug their label; center them under the text.
            if (wide) Center(child: action) else action,
          ],
        ],
      ],
    );
    if (wide) {
      return Material(
        color: t.colors.background,
        child: Column(
          children: [
            // The same bar as the onboarding steps: the boards set the logo 28
            // px in, and the bar's own 20 px leaves it 10 px short.
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: WebTopBar(
                leading: PantasLogo(size: 28),
                title: Text(
                  'Pantas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 120),
                  child: SizedBox(width: 460, child: column),
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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
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
