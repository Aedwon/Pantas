import 'package:flutter/material.dart';

/// Tells its child whether the pointer is over it, and shows the pointer
/// cursor. For a control whose fill is its own opaque decoration: ink from an
/// `InkWell` paints on the page's material, under that fill, so the control
/// would show no hover at all (5Q-8, 5Q-10).
class WebHover extends StatefulWidget {
  const WebHover({required this.builder, super.key});

  // ignore: avoid_positional_boolean_parameters
  final Widget Function(BuildContext context, bool hovered) builder;

  @override
  State<WebHover> createState() => _WebHoverState();
}

class _WebHoverState extends State<WebHover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: widget.builder(context, _hovered),
      );
}
