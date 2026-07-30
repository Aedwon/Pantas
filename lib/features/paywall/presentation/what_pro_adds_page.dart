import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/presentation/pro_specimen_panel.dart';

/// Screen 1 of three. Makes the want. Shown to everyone.
///
/// This page reads no student data. That is deliberate and it is the whole
/// of the 4 August amendment: filling the specimen from the student's own
/// answers would hand over a real Pro insight in order to sell Pro.
class WhatProAddsPage extends StatelessWidget {
  const WhatProAddsPage({required this.onSeePlans, super.key});

  final VoidCallback onSeePlans;

  static const _adds = <(String, String)>[
    ('Explanation', 'to your wrong answers'),
    ('Reasons', 'you keep missing'),
    ('Your mastery', 'down to the lesson'),
    ('Unlimited', 'mock exams'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You'll understand yourself better with Pro.",
                style: styles.displaySmall.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'This is an example. Pro measures every figure from your '
                'own answers.',
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: 24),
              const ProSpecimenPanel(),
              const SizedBox(height: 26),
              Text('Pro also adds', style: styles.headlineSmall),
              Container(
                height: 1.6,
                color: colors.ink,
                margin: const EdgeInsets.only(top: 6),
              ),
              const SizedBox(height: 12),
              for (final (noun, rest) in _adds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A serif plus, not an icon: the plate says "adds",
                      // so the marker restates the verb.
                      Text(
                        '+',
                        style: styles.headlineSmall.copyWith(fontSize: 14),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: noun,
                                style:
                                    styles.headlineSmall.copyWith(fontSize: 14),
                              ),
                              TextSpan(
                                text: ' $rest',
                                style: styles.headlineSmall.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              BoardButton(label: 'See plans', onPressed: onSeePlans),
              const SizedBox(height: 9),
              Center(
                child: Text(
                  'From ₱29 a week. Cancel any time.',
                  style: styles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: colors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
