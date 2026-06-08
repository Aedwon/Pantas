import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(title: title),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
