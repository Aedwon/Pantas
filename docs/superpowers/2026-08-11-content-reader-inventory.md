# Content Reader Inventory (11 August 2026)

Walk of `ContentRepository`'s public methods to record every call site across the application.

## `listExams`
Returns: `Future<List<Exam>>`
Call sites:
- **Core Storage**: `examsProvider` in `storage.dart`
- **Settings**: `whats_included_page.dart`
- **Quiz**: `start_quick_quiz.dart`
- **Assessment**: `assessment_results_page.dart`
- **Onboarding**: `custom_track_subjects_step.dart`

## `topicsBySubject`
Returns: `Future<List<Topic>>`
Call sites:
- **Core Storage**: `topicsBySubjectProvider` in `storage.dart`, and recursive call in `content_repository.dart`
- **Settings**: `whats_included_page.dart`
- **Mock Exam**: `custom_blueprint_repository.dart`, `custom_blueprint.dart`, `custom_mock_setup_route.dart`, `custom_mock_setup_page.dart`
- **Quiz**: `start_quick_quiz.dart`, `practice_picker_providers.dart`
- **Lesson**: `study_map_providers.dart`, `build_study_map.dart`
- **Onboarding**: `custom_track_subjects_step.dart`

## `topicsByExam`
Returns: `Future<List<Topic>>`
Call sites:
- **Core Storage**: `topicsByExamProvider` in `storage.dart`, `assessment_question_selector.dart`
- **Quiz**: `start_today_session.dart`, `debrief_providers.dart`
- **Assessment**: `assessment_result_providers.dart`, `complete_assessment.dart`

## `questionsByTopic`
Returns: `Future<List<Question>>`
Call sites:
- **Core Storage**: `assessment_question_selector.dart`
- **Mock Exam**: `custom_mock_setup_route.dart`
- **Quiz**: `start_inline_lesson_quiz.dart`, `start_quick_quiz.dart`, `start_today_session.dart`, `start_drill.dart`, `start_practice.dart`, `practice_picker_providers.dart`, `today_providers.dart`

## `questionById`
Returns: `Future<Question?>`
Call sites:
- **Quiz**: `resume_session.dart`, `start_practice.dart`, `start_retake.dart`, `restart_session.dart`, `debrief_providers.dart`, `practice_row_providers.dart`

## `questionsByIds`
Returns: `Future<Map<QuestionId, Question>>`
Call sites:
- **Quiz**: `review_providers.dart`

## `lessonsByTopic`
Returns: `Future<List<Lesson>>`
Call sites:
- **Core Storage**: `lessonsByTopicProvider` in `storage.dart`
- **Home**: `up_next_provider.dart`
- **Quiz**: `practice_picker_providers.dart`
- **Lesson**: `get_topic_lessons.dart`, `build_study_map.dart`

## `lessonsByTopics`
Returns: `Future<Map<TopicId, List<Lesson>>>`
Call sites:
- **Core Storage**: `lessonsByTopicsProvider` in `storage.dart`
- **Lesson**: `study_map_providers.dart`

## `lessonById`
Returns: `Future<Lesson?>`
Call sites:
- **Core Storage**: `lessonByIdProvider` in `storage.dart`
- **Quiz**: `start_inline_lesson_quiz.dart`
- **Lesson**: `reader_providers.dart`, `lesson_search_providers.dart`, `study_map_providers.dart`, `get_lesson.dart`

## `searchLessonRows`
Returns: `Future<List<LessonRow>>`
Call sites:
- **Lesson**: `lesson_search_providers.dart`

## `topicById`
Returns: `Future<Topic?>`
Call sites:
- **Core Storage**: `topicByIdProvider` in `storage.dart`
- **Progress**: `performance_provider.dart`
- **Quiz**: `today_providers.dart`, `review_providers.dart`
- **Assessment**: `assessment_result.dart`, `complete_assessment.dart`

## `subjectById`
Returns: `Future<Subject?>`
Call sites:
- **Settings**: `whats_included_page.dart`
- **Quiz**: `review_providers.dart`

## `passageById`
Returns: `Future<Passage?>`
Call sites:
- **Core Storage**: `passageByIdProvider` in `storage.dart`
- **Quiz**: `quiz_page.dart`, `review_providers.dart`
