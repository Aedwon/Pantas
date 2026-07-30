import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SharePrivacySelection {
  const SharePrivacySelection({
    required this.includeArchetype,
    required this.includeScore,
  });

  final bool includeArchetype;
  final bool includeScore;

  SharePrivacySelection copyWith({
    bool? includeArchetype,
    bool? includeScore,
  }) {
    return SharePrivacySelection(
      includeArchetype: includeArchetype ?? this.includeArchetype,
      includeScore: includeScore ?? this.includeScore,
    );
  }
}

class SharePrivacySheet extends StatelessWidget {
  const SharePrivacySheet({
    required this.selection,
    required this.onChanged,
    super.key,
  });

  final SharePrivacySelection selection;
  final ValueChanged<SharePrivacySelection> onChanged;

  /// Disclosure shown before publishing a card to a public link
  /// (landing-page spec §3.1, decision #2).
  static const String hostingDisclosure =
      'Sharing publishes this card to a pantas.app link anyone can view.';

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Include archetype'),
          value: selection.includeArchetype,
          onChanged: (value) => onChanged(
            selection.copyWith(includeArchetype: value),
          ),
        ),
        SwitchListTile(
          title: const Text('Include score'),
          value: selection.includeScore,
          onChanged: (value) =>
              onChanged(selection.copyWith(includeScore: value)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.public, size: 16, color: colors.inkMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hostingDisclosure,
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
