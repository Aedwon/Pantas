import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The settings boards use a 16px card and notes outside its surface.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.children,
    this.header,
    this.footer,
    super.key,
  });

  final List<Widget> children;
  final String? header;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    if (!context.wideWeb) {
      return GroupedSection(header: header, footer: footer, children: children);
    }
    final t = context.webTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s0,
              PantasSpace.s16,
              PantasSpace.s8,
            ),
            child: Text(header!.toUpperCase(), style: t.eb),
          ),
        WebCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s8,
              PantasSpace.s16,
              PantasSpace.s0,
            ),
            child: Text(footer!, style: t.sm),
          ),
      ],
    );
  }
}
