import 'package:flutter/material.dart';

class ButtonPair extends StatelessWidget {
  const ButtonPair({
    required this.primary,
    required this.secondary,
    this.stacked = false,
    this.gap = 10,
    super.key,
  });
  final Widget primary;
  final Widget secondary;
  final bool stacked;
  final double gap;
  @override
  Widget build(BuildContext context) =>
      stacked || MediaQuery.textScalerOf(context).scale(17) > 25.5
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [primary, SizedBox(height: gap), secondary],
            )
          : Row(
              children: [
                Expanded(child: secondary),
                SizedBox(width: gap),
                Expanded(child: primary),
              ],
            );
}
