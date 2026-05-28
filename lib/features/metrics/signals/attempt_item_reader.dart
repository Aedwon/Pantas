import 'dart:convert';

class MetricAttemptItem {
  const MetricAttemptItem({
    required this.questionId,
    required this.questionVersion,
    required this.chosenChoiceId,
    required this.correctChoiceId,
    required this.responseMs,
  });

  final String questionId;
  final int questionVersion;
  final String chosenChoiceId;
  final String correctChoiceId;
  final int responseMs;

  bool get isCorrect => chosenChoiceId == correctChoiceId;
}

class AttemptItemReader {
  const AttemptItemReader();

  List<MetricAttemptItem> read(String itemsJson) {
    try {
      final decoded = jsonDecode(itemsJson);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded)
          if (item is Map<String, Object?>) _item(item),
      ];
    } on FormatException {
      return const [];
    }
  }

  MetricAttemptItem _item(Map<String, Object?> json) {
    return MetricAttemptItem(
      questionId: json['questionId']! as String,
      questionVersion: json['questionVersion']! as int,
      chosenChoiceId: json['chosenChoiceId']! as String,
      correctChoiceId: json['correctChoiceId']! as String,
      responseMs: json['responseMs']! as int,
    );
  }
}
