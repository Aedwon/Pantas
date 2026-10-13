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
    super.key,
  });
  final String title;
  final List<Widget> children;
  final String? backLabel;
  final VoidCallback? onBack;
  final Widget? bottom;
  final double bottomInset;
  @override
  Widget build(BuildContext context) => Scaffold(
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
                  padding: EdgeInsets.fromLTRB(16, 2, 16, bottomInset),
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
}
