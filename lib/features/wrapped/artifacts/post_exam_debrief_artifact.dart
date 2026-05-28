class PostExamDebriefArtifact {
  const PostExamDebriefArtifact();

  String get id => 'post_exam_debrief';

  bool shouldFire({
    required DateTime localDate,
    required DateTime examDate,
    required bool alreadyFired,
  }) {
    if (alreadyFired) return false;
    final triggerDate = DateTime(
      examDate.year,
      examDate.month,
      examDate.day + 1,
    );
    return DateTime(localDate.year, localDate.month, localDate.day) ==
        triggerDate;
  }
}
