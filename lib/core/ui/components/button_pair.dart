import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';

class ButtonPair extends StatelessWidget {
  const ButtonPair({
    required this.primary,
    required this.secondary,
    this.stacked = false,
    super.key,
  });
  final PantasButton primary;
  final PantasButton secondary;
  final bool stacked;
  @override
  Widget build(BuildContext context) =>
      stacked || MediaQuery.textScalerOf(context).scale(17) > 25.5
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [primary, const SizedBox(height: 10), secondary],
            )
          : Row(
              children: [
                Expanded(child: secondary),
                const SizedBox(width: 10),
                Expanded(child: primary),
              ],
            );
}
