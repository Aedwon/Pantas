String subjectId(String subjectSlug) => 'subject-$subjectSlug';
String topicId(String topicSlug) => 'topic-$topicSlug';
String lessonId(String topicSlug, String lessonSlug) =>
    'lesson-$topicSlug-$lessonSlug';
String examId(String code) => 'exam-$code';
