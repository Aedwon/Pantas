import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/page_title.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

/// Space between the blocks of a phone screen (`.phone-screen` gap, 24).
// ds-board: under-13 boards, `.phone-screen` gap between blocks
const double childStepGap = PantasSpace.s24;

/// A phone page with no Back row, for the under-13 boards that have none: the
/// guardian screen, the short child notice and the nickname step. The title,
/// the body and the pinned action stack follow `PantasPage.onboarding`, so the
/// spacing is the one the other onboarding boards use. Wide web draws the
/// top bar over one centered column, as the guardian screens do.
class ChildStepFrame extends StatelessWidget {
  const ChildStepFrame({
    required this.children,
    this.title,
    this.actions = const [],
    this.centered = false,
    this.topPadding = PantasSpace.s8 + PantasSpace.s6,
    super.key,
  });

  /// The large title, or null for a screen whose title is part of the body.
  final String? title;
  final List<Widget> children;

  /// Pinned at the bottom, top to bottom (the main action first on a phone).
  final List<Widget> actions;

  /// Centers the body in the space above the actions (board 1A).
  final bool centered;

  /// Phone only: space above the title.
  final double topPadding;

  List<Widget> _spaced(List<Widget> items) => [
        for (final (i, item) in items.indexed) ...[
          if (i > 0) const SizedBox(height: childStepGap),
          item,
        ],
      ];

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) return _wide(context);
    final body = [
      if (title != null) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
          child: Semantics(
            header: true,
            liveRegion: true,
            child: PantasTitle(
              title!,
              narrowRule: false,
              style: context.type.pageTitle,
            ),
          ),
        ),
        if (children.isNotEmpty) const SizedBox(height: childStepGap),
      ],
      ..._spaced(children),
    ];
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    PantasSpace.s16,
                    topPadding,
                    PantasSpace.s16,
                    PantasSpace.s32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: centered
                          ? (constraints.maxHeight - topPadding - 36)
                              .clamp(0, double.infinity)
                          : 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: centered
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: body,
                    ),
                  ),
                ),
              ),
            ),
            if (actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s20,
                  PantasSpace.s12,
                  PantasSpace.s20,
                  PantasSpace.s32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, action) in actions.indexed) ...[
                      if (i > 0) const SizedBox(height: PantasSpace.s8),
                      action,
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _wide(BuildContext context) {
    final t = context.webTokens;
    return Material(
      color: t.colors.background,
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
                  width: PantasLayout.modal,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (title != null) ...[
                        Semantics(
                          header: true,
                          liveRegion: true,
                          child: Text(title!, style: t.h1),
                        ),
                        if (children.isNotEmpty)
                          const SizedBox(height: PantasSpace.s28),
                      ],
                      ..._spaced(children),
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: PantasSpace.s28),
                        for (final (i, action) in actions.indexed) ...[
                          if (i > 0) const SizedBox(height: PantasSpace.s8),
                          Center(child: action),
                        ],
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

/// How a [ChildStepButton] looks: the main action, the neutral one, or the
/// small accent text button (`btn--text-phone-sm`).
enum ChildStepButtonKind { primary, neutral, text }

/// One action of a child setup screen. The phone draws the system button at
/// the board's size; wide web draws the onboarding button.
class ChildStepButton extends StatelessWidget {
  const ChildStepButton({
    required this.label,
    required this.onPressed,
    this.kind = ChildStepButtonKind.primary,
    this.busy = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final ChildStepButtonKind kind;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final variant = switch (kind) {
      ChildStepButtonKind.primary => PantasButtonVariant.primary,
      ChildStepButtonKind.neutral => PantasButtonVariant.neutral,
      ChildStepButtonKind.text => PantasButtonVariant.tertiary,
    };
    if (context.wideWeb) {
      return OnboardingButton(
        label: label,
        onPressed: onPressed,
        busy: busy,
        variant: variant,
      );
    }
    return PantasButton(
      label: label,
      variant: variant,
      onPressed: onPressed,
      busy: busy,
      height: kind == ChildStepButtonKind.text ? PantasSize.btn : null,
      fontSize:
          kind == ChildStepButtonKind.text ? PantasType.webLink.fontSize : null,
    );
  }
}

/// A paragraph of a child setup screen: `phone-body` in the secondary color.
class ChildStepText extends StatelessWidget {
  const ChildStepText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      final t = context.webTokens;
      return Text(
        text,
        style: PantasType.webLead.copyWith(color: t.colors.textSecondary),
      );
    }
    // 4 in from the gutter, level with the title (the page's own detail line
    // does the same).
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
      child: Text(
        text,
        style: context.type.body.copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}

/// The refusal notice of the setup boards (2A "email already used"): a
/// warning notice with a dismiss control and at most one action.
class ChildStepNotice extends StatelessWidget {
  const ChildStepNotice({
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

/// The two-people mark of board 1A: a 40 px stroked glyph in `icon-muted`.
class ChildPeopleMark extends StatelessWidget {
  const ChildPeopleMark({super.key});

  // The board's own 24 px drawing, stroked in the current color.
  static const _svg = '<svg xmlns="http://www.w3.org/2000/svg" '
      'viewBox="0 0 24 24" fill="none" stroke="currentColor" '
      'stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"> '
      '<circle cx="9" cy="8" r="3.2"/> '
      '<path d="M3.5 19c.6-3.2 2.8-4.8 5.5-4.8s4.9 1.6 5.5 4.8"/> '
      '<circle cx="17" cy="9.5" r="2.4"/> '
      '<path d="M16.5 14.4c2.3 0 3.6 1.3 4.2 3.6"/> </svg>';

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SvgPicture.string(
          _svg,
          width: PantasSpace.s40,
          height: PantasSpace.s40,
          theme: SvgTheme(currentColor: context.colors.iconMuted),
        ),
      );
}
