import 'package:flutter/material.dart';
import 'package:pantas/core/ui/web/web_components.dart';

/// The top of a page that opens from another: the back link, then the title
/// and an optional line under it.
///
/// One rule for every such page (Plan, Performance, History, the day page,
/// Your record, Tendencies), so the back link and the title stand at the same
/// y and x on all of them and the page does not jump when you move between
/// them (5Q-2).
class WebPageHeading extends StatelessWidget {
  const WebPageHeading({
    required this.title,
    required this.onBack,
    this.backLabel = 'Home',
    this.subtitle,
    super.key,
  });
  final String title;
  final String backLabel;
  final String? subtitle;
  final VoidCallback onBack;

  /// Back link to the title.
  static const double backToTitle = 6;

  /// Title (or its line) to the content.
  static const double toContent = 26;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WebBackLink(label: backLabel, onPressed: onBack),
          const SizedBox(height: backToTitle),
          WebText(title, kind: WebTextKind.h1),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            WebText(subtitle!, kind: WebTextKind.lead),
          ],
          const SizedBox(height: toContent),
        ],
      );
}
