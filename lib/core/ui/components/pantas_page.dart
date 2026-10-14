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
    this.backIconSize = 20,
    this.backIconGap = 0,
    this.headerPadding = EdgeInsets.zero,
    this.backPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.titlePadding = const EdgeInsets.fromLTRB(4, 0, 4, 20),
    super.key,
  });
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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: bottom,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (backLabel != null || headerTrailing != null)
                Padding(
                  padding: headerPadding,
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
                                    tapTargetSize: fixedTitle
                                        ? MaterialTapTargetSize.shrinkWrap
                                        : null,
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
                                          style: context.type.body.copyWith(
                                            color: context.colors.accent,
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
                    children: [if (!fixedTitle) heading(context), ...children],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
