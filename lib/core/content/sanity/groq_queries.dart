abstract final class GroqQueries {
  static const examsFull = '''
*[_type == "exam" && language == "en"]{
  _id, _updatedAt, schemaVersion, code, name, shortName, language, ordering,
  "isActive": coalesce(isActive, true)
}
''';

  static const examsDelta = r'''
*[_type == "exam" && language == "en" && _updatedAt > $since]{
  _id, _updatedAt, schemaVersion, code, name, shortName, language, ordering,
  "isActive": coalesce(isActive, true)
}
''';

  static const subjectsFull = '''
*[_type == "subject"]{
  _id, _updatedAt, schemaVersion, exam, name, ordering,
  "isActive": coalesce(isActive, true)
}
''';

  static const subjectsDelta = r'''
*[_type == "subject" && _updatedAt > $since]{
  _id, _updatedAt, schemaVersion, exam, name, ordering,
  "isActive": coalesce(isActive, true)
}
''';

  static const topicsFull = '''
*[_type == "topic"]{
  _id, _updatedAt, schemaVersion, subject, name, ordering,
  "isActive": coalesce(isActive, true)
}
''';

  static const topicsDelta = r'''
*[_type == "topic" && _updatedAt > $since]{
  _id, _updatedAt, schemaVersion, subject, name, ordering,
  "isActive": coalesce(isActive, true)
}
''';

  static const questionsFull = '''
*[_type == "question" && language == "en"]{
  _id, _updatedAt, schemaVersion, topic, examIds, language, stem, explanation,
  version, choices, "isActive": coalesce(isActive, true)
}
''';

  static const questionsDelta = r'''
*[_type == "question" && language == "en" && _updatedAt > $since]{
  _id, _updatedAt, schemaVersion, topic, examIds, language, stem, explanation,
  version, choices, "isActive": coalesce(isActive, true)
}
''';

  static const lessonsFull = '''
*[_type == "lesson"]{
  _id, _updatedAt, schemaVersion, topic, title, summary, estimatedMinutes, body,
  "isActive": coalesce(isActive, true)
}
''';

  static const lessonsDelta = r'''
*[_type == "lesson" && _updatedAt > $since]{
  _id, _updatedAt, schemaVersion, topic, title, summary, estimatedMinutes, body,
  "isActive": coalesce(isActive, true)
}
''';

  static const mockBlueprintsFull = '''
*[_type == "mockBlueprint"]{
  _id, _updatedAt, schemaVersion, exam, name, durationMinutes, sections,
  "isActive": coalesce(isActive, true)
}
''';

  static const mockBlueprintsDelta = r'''
*[_type == "mockBlueprint" && _updatedAt > $since]{
  _id, _updatedAt, schemaVersion, exam, name, durationMinutes, sections,
  "isActive": coalesce(isActive, true)
}
''';

  static const mockExamsFull = '''
*[_type == "mockExam"]{
  _id, _updatedAt, schemaVersion, blueprint, name, publishedAt,
  "isActive": coalesce(isActive, true)
}
''';

  static const mockExamsDelta = r'''
*[_type == "mockExam" && _updatedAt > $since]{
  _id, _updatedAt, schemaVersion, blueprint, name, publishedAt,
  "isActive": coalesce(isActive, true)
}
''';

  static const diagnosticSetsFull = '''
*[_type == "diagnosticSet"]{
  _id, _updatedAt, schemaVersion, exam, name, questionIds,
  "isActive": coalesce(isActive, true)
}
''';

  static const diagnosticSetsDelta = r'''
*[_type == "diagnosticSet" && _updatedAt > $since]{
  _id, _updatedAt, schemaVersion, exam, name, questionIds,
  "isActive": coalesce(isActive, true)
}
''';

  static const fullByDoctype = {
    'exam': examsFull,
    'subject': subjectsFull,
    'topic': topicsFull,
    'question': questionsFull,
    'lesson': lessonsFull,
    'mockExam': mockExamsFull,
    'mockBlueprint': mockBlueprintsFull,
    'diagnosticSet': diagnosticSetsFull,
  };

  static const deltaByDoctype = {
    'exam': examsDelta,
    'subject': subjectsDelta,
    'topic': topicsDelta,
    'question': questionsDelta,
    'lesson': lessonsDelta,
    'mockExam': mockExamsDelta,
    'mockBlueprint': mockBlueprintsDelta,
    'diagnosticSet': diagnosticSetsDelta,
  };
}
