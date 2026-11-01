import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
    this.headerPadding = const EdgeInsets.only(top: 6),
    this.backPadding = const EdgeInsets.fromLTRB(8, 0, 16, 0),
    this.titlePadding = const EdgeInsets.fromLTRB(4, 0, 4, 20),
    this.hero,
    super.key,
  })  : contentBody = null,
        contentPadding = EdgeInsets.zero,
        settingsPicker = false,
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
        backPadding = const EdgeInsets.symmetric(horizontal: 16),
        titlePadding = const EdgeInsets.fromLTRB(4, 0, 4, 20),
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
        backPadding = const EdgeInsets.symmetric(horizontal: 16),
        titlePadding = const EdgeInsets.fromLTRB(4, 0, 4, 20),
        settingsPicker = true,
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
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16),
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
        backPadding = const EdgeInsets.symmetric(horizontal: 16),
        titlePadding = const EdgeInsets.fromLTRB(4, 0, 4, 20),
        settingsPicker = false,
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
        child: Text(title, style: titleStyle ?? context.type.largeTitle),
      );

  @override
  Widget build(BuildContext context) =>
      onboarding ? _onboardingPage(context) : _ordinaryPage(context);
  Widget _onboardingPage(BuildContext context) => Scaffold(
        backgroundColor: surfaceBackground
            ? context.colors.surface
            : context.colors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                // Boards: back label at y 21, progress bar at y 56.
                height: settingsPicker ? 44 : 56,
                child: Padding(
                  padding: settingsPicker
                      ? const EdgeInsets.fromLTRB(4, 6, 8, 0)
                      : const EdgeInsets.fromLTRB(8, 5, 8, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onBack,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PantasIcons.back,
                            size: 24,
                            color: context.colors.accent,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            backLabel!,
                            style: context.type.body
                                .copyWith(color: context.colors.accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (progress != null)
                Semantics(
                  label: 'Step $progress of 6',
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        for (var index = 0; index < 6; index++) ...[
                          if (index > 0) const SizedBox(width: 6),
                          Expanded(
                            child: DecoratedBox(
                              key: const ValueKey('onboarding-segment'),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                color: index < progress!
                                    ? context.colors.accentFill
                                    : context.colors.fill,
                              ),
                              child: const SizedBox(height: 4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding:
                        EdgeInsets.fromLTRB(16, settingsPicker ? 8 : 4, 16, 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: centerBody
                            ? (constraints.maxHeight - 36)
                                .clamp(0, double.infinity)
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Semantics(
                                header: true,
                                liveRegion: true,
                                child: Text(
                                  title,
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
                            const SizedBox(height: 7),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
                  child: bottom,
                ),
            ],
          ),
        ),
      );
  Widget _ordinaryPage(BuildContext context) => Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: bottom,
        body: SafeArea(
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
                          height: 44,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: heading(context),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          fixedTitle ? 0 : 2,
                          16,
                          bottomInset,
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
