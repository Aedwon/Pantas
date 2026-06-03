import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Standard screen shell: paper background, safe area, identity padding.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    required this.body,
    this.bottomNavigationBar,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    super.key,
  });

  final Widget body;
  final Widget? bottomNavigationBar;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(child: Padding(padding: padding, child: body)),
    );
  }
}
