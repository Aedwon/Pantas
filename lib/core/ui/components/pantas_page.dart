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
    super.key,
  })  : onboarding = false,
        progress = null,
        detail = null,
        bodyGap = 28,
        centerBody = false,
        surfaceBackground = false;
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
    super.key,
  })  : onboarding = true,
        backLabel = 'Back';
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
  @override
  Widget build(BuildContext context) => onboarding
      ? _onboardingPage(context)
      : Scaffold(
          backgroundColor: context.colors.background,
          bottomNavigationBar: bottom,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (backLabel != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onBack,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PantasIcons.back,
                            size: 20,
                            color: context.colors.accent,
                          ),
                          Text(
                            backLabel!,
                            style: context.type.body
                                .copyWith(color: context.colors.accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
                          child: Text(title, style: context.type.largeTitle),
                        ),
                        ...children,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  Widget _onboardingPage(BuildContext context) => Scaffold(
        backgroundColor: surfaceBackground
            ? context.colors.surface
            : context.colors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 52,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
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
                            'Back',
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
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
                                child:
                                    Text(title, style: context.type.pageTitle),
                              ),
                            ),
                          if (detail != null) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                detail!,
                                style: context.type.body.copyWith(
                                  color: context.colors.secondaryLabel,
                                  height: 1.4,
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
}
