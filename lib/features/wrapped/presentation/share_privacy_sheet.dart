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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
      ],
    );
  }
}
