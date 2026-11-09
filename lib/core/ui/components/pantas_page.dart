import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/page_title.dart';
import 'package:pantas/core/ui/components/tab_bar_visibility.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// Below this window height an onboarding page puts its actions at the end of
/// the content instead of pinning them (see [PantasPage.pinBottom]).
const double _shortWindow = 520;

class PantasPage extends StatelessWidget {
  const PantasPage({
    required this.title,
    required this.children,
    this.backLabel,
    this.onBack,
    this.bottom,
    this.bottomInset = 24,
    this.titleStyle,
    this.headerTrailing,
    this.fixedTitle = false,
    this.backIconSize = 24,
    this.backIconGap = 2,
    this.headerPadding = const EdgeInsets.only(top: PantasSpace.s6),
    this.backPadding = const EdgeInsets.fromLTRB(
      PantasSpace.s8,
      PantasSpace.s0,
      PantasSpace.s16,
      PantasSpace.s0,
    ),
    this.titlePadding = const EdgeInsets.fromLTRB(
      PantasSpace.s4,
      PantasSpace.s0,
      PantasSpace.s4,
      PantasSpace.s20,
    ),
    this.hero,
    super.key,
  })  : contentBody = null,
        contentPadding = EdgeInsets.zero,
        settingsPicker = false,
        pinBottom = false,
        topPadding = 4,
        onboarding = false,
        progress = null,
        detail = null,
        bodyGap = 28,
        centerBody = false,
        surfaceBackground = false,
        detailLineHeight = 1.4;
  const PantasPage.onboarding({
    required this.title,
    required this.children,
    required this.onBack,
    this.progress,
    this.detail,
    this.bottom,
    this.bodyGap = 28,
    this.centerBody = false,
    this.surfaceBackground = false,
    this.detailLineHeight = 1.4,
    this.topPadding = 4,
    this.pinBottom = false,
    super.key,
  })  : contentBody = null,
        hero = null,
        contentPadding = EdgeInsets.zero,
        bottomInset = 24,
        titleStyle = null,
        headerTrailing = null,
        fixedTitle = false,
        backIconSize = 20,
        backIconGap = 0,
        headerPadding = EdgeInsets.zero,
        backPadding = const EdgeInsets.symmetric(horizontal: PantasSpace.s16),
        titlePadding = const EdgeInsets.fromLTRB(
          PantasSpace.s4,
          PantasSpace.s0,
          PantasSpace.s4,
          PantasSpace.s20,
        ),
        settingsPicker = false,
        onboarding = true,
        backLabel = 'Back';
  const PantasPage.settingsPicker({
    required this.onBack,
    required this.children,
    super.key,
  })  : contentBody = null,
        hero = null,
        contentPadding = EdgeInsets.zero,
        bottomInset = 24,
        titleStyle = null,
        headerTrailing = null,
        fixedTitle = false,
        backIconSize = 20,
        backIconGap = 0,
        headerPadding = EdgeInsets.zero,
        backPadding = const EdgeInsets.symmetric(horizontal: PantasSpace.s16),
        titlePadding = const EdgeInsets.fromLTRB(
          PantasSpace.s4,
          PantasSpace.s0,
          PantasSpace.s4,
          PantasSpace.s20,
        ),
        settingsPicker = true,
        pinBottom = false,
        topPadding = 4,
        onboarding = true,
        title = 'Exam',
        backLabel = 'Your exam',
        bottom = null,
        progress = null,
        detail = null,
        bodyGap = 22,
        centerBody = false,
        surfaceBackground = false,
        detailLineHeight = 1.4;

  /// Keeps a screen-owned scrolling body, such as the Study search and map.
  const PantasPage.content({
    required Widget body,
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: PantasSpace.s16),
    this.bottom,
    super.key,
  })  : contentBody = body,
        hero = null,
        contentPadding = padding,
        title = '',
        children = const [],
        backLabel = null,
        onBack = null,
        bottomInset = 24,
        titleStyle = null,
        headerTrailing = null,
        fixedTitle = false,
        backIconSize = 20,
        backIconGap = 0,
        headerPadding = EdgeInsets.zero,
        backPadding = const EdgeInsets.symmetric(horizontal: PantasSpace.s16),
        titlePadding = const EdgeInsets.fromLTRB(
          PantasSpace.s4,
          PantasSpace.s0,
          PantasSpace.s4,
          PantasSpace.s20,
        ),
        settingsPicker = false,
        pinBottom = false,
        topPadding = 4,
        onboarding = false,
        progress = null,
        detail = null,
        bodyGap = 28,
        centerBody = false,
        surfaceBackground = false,
        detailLineHeight = 1.4;
  final Widget? contentBody;

  /// Replaces the large title with a board hero card (Settings subpages).
  final Widget? hero;
  final EdgeInsets contentPadding;
  final double detailLineHeight;
  final bool settingsPicker;

  /// Onboarding only: space between the progress bar and the title.
  final double topPadding;

  /// Onboarding only: keep the bottom actions fixed even on a short window. On
  /// a short window (a phone on its side, a page at 200% zoom) the actions
  /// otherwise move to the end of the scrolling content, so the content gets
  /// the height they took. A long list that needs its button in reach keeps it
  /// pinned.
  final bool pinBottom;
  final bool onboarding;
  final int? progress;
  final String? detail;
  final double bodyGap;
  final bool centerBody;
  final bool surfaceBackground;
  final String title;
  final List<Widget> children;
  final String? backLabel;
  final VoidCallback? onBack;
  final Widget? bottom;
  final double bottomInset;
  final TextStyle? titleStyle;
  final Widget? headerTrailing;
  final bool fixedTitle;
  final double backIconSize;
  final double backIconGap;
  final EdgeInsets headerPadding;
  final EdgeInsets backPadding;
  final EdgeInsets titlePadding;

  Widget heading(BuildContext context) => Padding(
        padding: titlePadding,
        child: PantasTitle(
          title,
          style: titleStyle ?? context.type.largeTitle,
          narrowRule: titleStyle == null,
        ),
      );

  @override
  Widget build(BuildContext context) =>
      onboarding ? _onboardingPage(context) : _ordinaryPage(context);
  Widget _onboardingPage(BuildContext context) {
    // Inside the onboarding frame, Back and the progress bar already stay on
    // screen, so this builds only the part that changes with the step.
    final host = settingsPicker ? null : OnboardingFrameScope.hostOf(context);
    final inlineBottom = bottom != null &&
        !pinBottom &&
        MediaQuery.sizeOf(context).height < _shortWindow;
    final body = [
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              PantasSpace.s16,
              settingsPicker ? PantasSpace.s8 : topPadding,
              PantasSpace.s16,
              PantasSpace.s32,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: centerBody
                    ? (constraints.maxHeight - 36).clamp(0, double.infinity)
                    : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: centerBody
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PantasSpace.s4,
                      ),
                      child: Semantics(
                        header: true,
                        liveRegion: true,
                        child: PantasTitle(
                          title,
                          narrowRule: false,
                          style: settingsPicker
                              ? context.type.pageTitleCompact
                                  .copyWith(height: 1.2)
                              : context.type.pageTitle,
                        ),
                      ),
                    ),
                  if (detail != null) ...[
                    // Boards: subtitle 3 px lower than the old
                    // layout, with the title 4 px lower.
                    const SizedBox(height: PantasSpace.s6),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PantasSpace.s4,
                      ),
                      child: Text(
                        detail!,
                        style: context.type.body.copyWith(
                          color: context.colors.secondaryLabel,
                          height: detailLineHeight,
                        ),
                      ),
                    ),
                  ],
                  if (title.isNotEmpty || detail != null)
                    SizedBox(height: bodyGap),
                  ...children,
                  if (inlineBottom)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        PantasSpace.s4,
                        PantasSpace.s24,
                        PantasSpace.s4,
                        PantasSpace.s2,
                      ),
                      child: bottom,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      if (bottom != null && !inlineBottom)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s20,
            PantasSpace.s12,
            PantasSpace.s20,
            PantasSpace.s32,
          ),
          child: bottom,
        ),
    ];
    if (host != null) {
      return OnboardingFrameClaim(
        host: host,
        spec: OnboardingFrameSpec(
          progress: progress,
          surfaceBackground: surfaceBackground,
        ),
        onBack: onBack,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: body,
        ),
      );
    }
    return Scaffold(
      backgroundColor: surfaceBackground
          ? context.colors.surface
          : context.colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OnboardingBackBar(
              onBack: onBack,
              label: backLabel!,
              compact: settingsPicker,
            ),
            if (progress != null) OnboardingProgressBar(progress: progress!),
            ...body,
          ],
        ),
      ),
    );
  }

  Widget _ordinaryPage(BuildContext context) => Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: bottom,
        body: SafeArea(
          // Under the floating tab bar the bottom padding is room for the
          // content to scroll through, not an inset to stay out of.
          bottom: !FloatingTabBarScope.of(context),
          child: contentBody != null
              ? Padding(padding: contentPadding, child: contentBody)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (backLabel != null || headerTrailing != null)
                      Padding(
                        padding: headerPadding,
                        // Boards: a 44 px back row under 6 px of padding,
                        // whatever the platform's button density.
                        child: SizedBox(
                          height: PantasSize.targetTouch,
                          child: Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: backLabel == null
                                      ? const SizedBox.shrink()
                                      : TextButton(
                                          onPressed: onBack,
                                          style: TextButton.styleFrom(
                                            minimumSize: const Size(44, 44),
                                            // Back link A: a rounded
                                            // rectangle, never a pill.
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                PantasRadius.back,
                                              ),
                                            ),
                                            padding: backPadding,
                                            visualDensity:
                                                VisualDensity.standard,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                PantasIcons.back,
                                                size: backIconSize,
                                                color: context.colors.accent,
                                              ),
                                              if (backIconGap > 0)
                                                SizedBox(width: backIconGap),
                                              Flexible(
                                                child: Text(
                                                  backLabel!,
                                                  style: context.type.body
                                                      .copyWith(
                                                    color:
                                                        context.colors.accent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                              if (headerTrailing != null) headerTrailing!,
                            ],
                          ),
                        ),
                      ),
                    if (fixedTitle)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PantasSpace.s16,
                        ),
                        child: heading(context),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          PantasSpace.s16,
                          fixedTitle ? PantasSpace.s0 : PantasSpace.s2,
                          PantasSpace.s16,
                          FloatingTabBarScope.clearance(
                            context,
                            minimum: bottomInset,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!fixedTitle) hero ?? heading(context),
                            ...children,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      );
}
