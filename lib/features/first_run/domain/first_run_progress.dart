import 'dart:convert';

/// Where the learner is in the run. Stored with the pending flag so a reload
/// resumes the same step (plan ruling 8).
enum FirstRunStep { intro, lesson, question1, question2, question3, end }

extension FirstRunStepQuestion on FirstRunStep {
  /// 0 to 2 for a question step, otherwise null.
  int? get questionIndex => switch (this) {
        FirstRunStep.question1 => 0,
        FirstRunStep.question2 => 1,
        FirstRunStep.question3 => 2,
        _ => null,
      };

  static FirstRunStep forQuestion(int index) => FirstRunStep.values[2 + index];
}

/// The open run: whose it is, the step, the choice picked for each question
/// and which questions were checked. Device-only, never synced.
class FirstRunProgress {
  const FirstRunProgress({
    required this.uid,
    required this.examId,
    this.step = FirstRunStep.intro,
    this.picks = const {},
    this.checked = const {},
  });

  final String uid;
  final String examId;
  final FirstRunStep step;

  /// Question id to the choice id picked.
  final Map<String, String> picks;

  /// Question ids whose answer was checked (revealed).
  final Set<String> checked;

  FirstRunProgress copyWith({
    FirstRunStep? step,
    Map<String, String>? picks,
    Set<String>? checked,
  }) =>
      FirstRunProgress(
        uid: uid,
        examId: examId,
        step: step ?? this.step,
        picks: picks ?? this.picks,
        checked: checked ?? this.checked,
      );

  String encode() => jsonEncode({
        'uid': uid,
        'examId': examId,
        'step': step.name,
        'picks': picks,
        'checked': checked.toList(),
      });

  /// Null when [raw] is empty or damaged.
  static FirstRunProgress? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, Object?>) return null;
      final step = FirstRunStep.values.asNameMap()[map['step']];
      final uid = map['uid'];
      final examId = map['examId'];
      if (step == null || uid is! String || examId is! String) return null;
      return FirstRunProgress(
        uid: uid,
        examId: examId,
        step: step,
        picks: {
          for (final e in (map['picks']! as Map<String, Object?>).entries)
            e.key: e.value! as String,
        },
        checked: {
          for (final id in map['checked']! as List<Object?>) id! as String,
        },
      );
    } on Object {
      return null;
    }
  }
}
