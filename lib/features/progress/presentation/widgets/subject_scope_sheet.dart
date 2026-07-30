import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/ink_sheet.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// What the sheet returns. Null is never returned for a choice: the sheet
/// returning nothing at all means dismissed, and dismissed leaves the
/// filter alone while choosing All clears it.
@immutable
class SubjectScopeChoice {
  const SubjectScopeChoice(this.subjectId);

  /// Null means all subjects.
  final String? subjectId;
}

/// The subject list, over the wash the rest of the app already uses.
///
/// Inline expansion was rejected: it jumps the table about 130px on open
/// and moves the rows being read.
Future<SubjectScopeChoice?> showSubjectScopeSheet(
  BuildContext context, {
  required List<({String id, String name, int rowCount})> subjects,
  required String? selectedId,
  String allLabel = 'All topics',
  String heading = 'Show which topics',
}) {
  return showInkSheet<SubjectScopeChoice>(
    context: context,
    builder: (sheetContext) => SubjectScopeSheet(
      subjects: subjects,
      selectedId: selectedId,
      allLabel: allLabel,
      heading: heading,
    ),
  );
}

class SubjectScopeSheet extends StatelessWidget {
  const SubjectScopeSheet({
    required this.subjects,
    required this.selectedId,
    required this.allLabel,
    required this.heading,
    super.key,
  });

  final List<({String id, String name, int rowCount})> subjects;
  final String? selectedId;
  final String allLabel;
  final String heading;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(heading, style: styles.headlineSmall),
        const SizedBox(height: 12),
        _ScopeRow(
          label: allLabel,
          isSelected: selectedId == null,
          onTap: () => Navigator.of(context).pop(
            const SubjectScopeChoice(null),
          ),
        ),
        for (final subject in subjects)
          _ScopeRow(
            label: subject.name,
            count: subject.rowCount,
            isSelected: selectedId == subject.id,
            onTap: () => Navigator.of(context).pop(
              SubjectScopeChoice(subject.id),
            ),
          ),
      ],
    );
  }
}

class _ScopeRow extends StatelessWidget {
  const _ScopeRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.ruleFaint,
              // ignore: avoid_redundant_argument_values
              width: AppDimensions.hairline,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: styles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (count != null)
              Text(
                '$count',
                style: styles.bodySmall.copyWith(
                  color: colors.inkMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
