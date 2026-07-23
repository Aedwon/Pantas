# Content Reader Inventory, 11 August 2026

This is the inventory of readers of `ContentRepository` prior to switching to `ContentDatabase`.

## `listExams()`
- Feature: Assessment / Storage
- Callers: `assessment_results_page.dart`

## `topicsBySubject(SubjectId)`
- Feature: Quiz / Storage
- Callers: `storage.dart`

## `topicsByExam(ExamId)`
- Feature: Assessment / Quiz
- Callers: `assessment_result_providers.dart`

## `questionsByTopic(TopicId)`
- Feature: Quiz / Assessment
- Callers: `assessment_question_selector.dart`, various quiz use cases

## `questionById(QuestionId)`
- Feature: Quiz
- Callers: quiz use cases

## `questionsByIds(Iterable<QuestionId>)`
- Feature: Quiz Debrief / Review
- Callers: `debrief_providers.dart`, `review_providers.dart`

## `lessonsByTopic(TopicId)`
- Feature: Lesson
- Callers: `storage.dart`

## `lessonsByTopics(List<TopicId>)`
- Feature: Study Map
- Callers: `storage.dart`

## `lessonById(LessonId)`
- Feature: Study Map / Lesson
- Callers: `study_map_providers.dart`

## `searchLessonRows(...)`
- Feature: Lesson Search
- Callers: `lesson_search_providers.dart`

## `topicById(TopicId)`
- Feature: Quiz Today / Quiz
- Callers: `today_providers.dart`

## `subjectById(SubjectId)`
- Feature: Storage
- Callers: `storage.dart`

## `passageById(PassageId)`
- Feature: Storage / Quiz
- Callers: `storage.dart`
