import 'package:flutter/material.dart';

class ProWelcomeBanner extends StatelessWidget {
  const ProWelcomeBanner({
    required this.onDismiss,
    required this.onPlanTap,
    super.key,
  });

  final VoidCallback onDismiss;
  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF0FDF4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "You're in.",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              "Pro adjusts your plan based on what you actually struggle with. Let's get to it.",
            ),
            TextButton(
              onPressed: onPlanTap,
              child: const Text("Take me to today's plan"),
            ),
          ],
        ),
      ),
    );
  }
}
