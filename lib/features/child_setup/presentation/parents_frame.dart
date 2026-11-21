import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Space between the blocks of a phone screen (`.phone-screen` gap, 24).
// ds-board: under-13 boards, `.phone-screen` gap between blocks
const double parentsGap = PantasSpace.s24;

/// Draws a [ParentsFrame] another way on wide web. The app passes one that
/// puts the page in the Settings pane, so these pages never import Settings.
typedef ParentsWideFrame = Widget Function(ParentsFrame frame);

/// The page of the guardian code gate and the For parents screens. A phone
/// draws the design system page (Back, large title, lead, body); wide web draws
/// the top bar over one centered column, as the other under-13 screens do. The
/// boards are drawn at 390 only, so the wide column is not a board.
class ParentsFrame extends StatelessWidget {
  const ParentsFrame({
    required this.title,
    required this.children,
    required this.onBack,
    this.lead,
    this.backLabel = 'Back',
    this.bottom,
    this.settingsStyle = false,
    this.wideFrame,
    super.key,
  });

  final String title;
  final String? lead;
  final List<Widget> children;
  final VoidCallback? onBack;
  final String backLabel;

  /// The pinned action under the page (phone) or at the end of the column.
  final Widget? bottom;

  /// A Settings page: the back row sits 4 in from the edge and the page
  /// scrolls as a whole, as the other Settings pages do.
  final bool settingsStyle;

  /// How wide web draws this page. Null draws the centered column.
  final ParentsWideFrame? wideFrame;

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) return wideFrame?.call(this) ?? _wide(context);
    if (settingsStyle) {
      return PantasPage(
        title: title,
        backLabel: backLabel,
        onBack: onBack,
        bottom: bottom,
        backPadding: const EdgeInsets.fromLTRB(
          PantasSpace.s4,
          PantasSpace.s0,
          PantasSpace.s16,
          PantasSpace.s0,
        ),
        children: [
          if (lead != null) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: PantasSpace.s4,
                right: PantasSpace.s4,
                top: PantasSpace.s4,
              ),
              child: Text(
                lead!,
                style: context.type.body
                    .copyWith(color: context.colors.textSecondary),
              ),
            ),
            const SizedBox(height: parentsGap),
          ],
          ...children,
        ],
      );
    }
    return PantasPage.onboarding(
      title: title,
      detail: lead,
      onBack: onBack,
      bottom: bottom,
      bodyGap: parentsGap,
      // The page the sign-in code boxes are drawn on: white in light, the
      // page gray in dark.
      surfaceBackground: Theme.of(context).brightness != Brightness.dark,
      children: children,
    );
  }

  Widget _wide(BuildContext context) {
    final t = context.webTokens;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark || settingsStyle ? t.colors.background : t.colors.surface,
      child: Column(
        children: [
          const OnboardingTopBar(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s40,
                  PantasSpace.s40,
                  PantasSpace.s40,
                  PantasSpace.s56,
                ),
                child: SizedBox(
                  width: PantasLayout.modalWide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: WebBackLink(
                          label: backLabel,
                          onPressed: onBack ?? () {},
                          nudge: false,
                        ),
                      ),
                      const SizedBox(height: PantasSpace.s28),
                      Semantics(
                        header: true,
                        liveRegion: true,
                        child: Text(title, style: t.h1),
                      ),
                      if (lead != null) ...[
                        const SizedBox(height: PantasSpace.s8),
                        Text(
                          lead!,
                          style: PantasType.webLead
                              .copyWith(color: t.colors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: PantasSpace.s28),
                      ...children,
                      if (bottom != null) ...[
                        const SizedBox(height: PantasSpace.s28),
                        Align(
                          alignment: Alignment.centerRight,
                          child: bottom,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A button of these screens. The phone draws the system button at the board's
/// size; wide web draws the web button.
class ParentsButton extends StatelessWidget {
  const ParentsButton({
    required this.label,
    required this.onPressed,
    this.text = false,
    this.busy = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  /// The small accent text button (`btn--tertiary btn--accent btn--sm`).
  final bool text;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      return WebButton(
        label: label,
        onPressed: onPressed,
        busy: busy,
        tall: !text,
        variant: text ? WebButtonVariant.tertiary : WebButtonVariant.primary,
      );
    }
    return PantasButton(
      label: label,
      onPressed: onPressed,
      busy: busy,
      variant:
          text ? PantasButtonVariant.tertiary : PantasButtonVariant.primary,
      height: text ? PantasSize.btn : null,
      fontSize: text ? PantasType.webLink.fontSize : null,
    );
  }
}

/// A refusal on these screens: a warning notice with a dismiss control and at
/// most one action (the same pattern as the child setup screens).
class ParentsNotice extends StatelessWidget {
  const ParentsNotice({
    required this.title,
    required this.onClose,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final VoidCallback onClose;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: NoticeStrip(
          title: title,
          tone: NoticeTone.warning,
          icon: PantasIcons.appError,
          expanded: actionLabel != null,
          primaryLabel: actionLabel,
          onPrimary: onAction,
          onClose: onClose,
        ),
      );
}
