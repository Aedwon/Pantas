import 'dart:convert';

import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/choice_order.dart';
import 'package:pantas/core/storage/domain/question.dart';

/// Rendered variants for a single problem type in index order.
class VariantDocument {
  VariantDocument.fromJson(Map<String, Object?> data)
      : id = data['id']! as String,
        _variants = [
          for (final raw in data['variants']! as List<Object?>)
            (raw! as Map).cast<String, Object?>(),
        ];

  final String id;
  final List<Map<String, Object?>> _variants;

  List<String> get ruleKeysByIndex => [
        for (final variant in _variants) variant['ruleKey']! as String,
      ];
}

/// Builds the display question for an index pinned when the item was served.
Question? resolveVariant(
  Question typeRow,
  VariantDocument? document,
  int variantIndex,
) {
  if (document == null ||
      document.id != typeRow.id ||
      variantIndex < 0 ||
      variantIndex >= document._variants.length) {
    return null;
  }
  final variant = document._variants[variantIndex];
  final stem = variant['stem'];
  final explanation = variant['explanation'];
  final rawChoices = variant['choices'];
  if (variant['variantIndex'] != variantIndex ||
      stem is! String ||
      stem.trim().isEmpty ||
      explanation is! String ||
      rawChoices is! List<Object?> ||
      rawChoices.length < 2) {
    return null;
  }
  final choices = <Choice>[];
  for (final raw in rawChoices) {
    if (raw is! Map || raw['text'] is! String) return null;
    final label = String.fromCharCode(65 + choices.length);
    final figure = raw['figure'];
    choices.add(
      Choice(
        id: '${typeRow.id}_${label.toLowerCase()}',
        label: label,
        text: raw['text'] as String,
        isCorrect: raw['correct'] == true,
        rationale: raw['rationale'] as String?,
        figureJson: figure == null ? null : jsonEncode(figure),
      ),
    );
  }
  if (choices.where((choice) => choice.isCorrect).length != 1) return null;
  final figureSpec = variant['figureSpec'];
  return typeRow.copyWith(
    stem: stem,
    explanation: explanation,
    figureSpecJson: figureSpec == null ? null : jsonEncode(figureSpec),
    choices: orderChoicesFor(typeRow.id, choices, variantIndex: variantIndex),
  );
}
