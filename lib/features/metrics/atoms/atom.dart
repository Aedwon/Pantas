enum AtomKey {
  timeOfDay,
  sessionShape,
  consistency,
  perQuestionSpeed,
  subjectAffinity,
  coverageBreadth,
  retentionShape,
}

abstract interface class Atom {
  AtomKey get key;

  Future<AtomChip?> select({required String examId});
}

class AtomChip {
  const AtomChip({
    required this.text,
    this.metric,
    this.proDepth,
  });

  final String text;
  final String? metric;
  final ProDepth? proDepth;
}

class ProDepth {
  const ProDepth({
    required this.label,
    required this.data,
  });

  final String label;
  final Object data;
}
