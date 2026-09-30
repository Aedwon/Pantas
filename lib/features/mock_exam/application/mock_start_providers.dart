import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/mock_exam/application/mock_answer_recorder.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/mock_exam_preferences.dart';
import 'package:pantas/features/mock_exam/data/mock_sampler.dart';
import 'package:pantas/features/mock_exam/domain/use_cases/compute_results.dart';
import 'package:pantas/features/mock_exam/domain/use_cases/discard_mock.dart';
import 'package:pantas/features/mock_exam/domain/use_cases/resume_mock.dart';
import 'package:pantas/features/mock_exam/domain/use_cases/start_mock.dart';
import 'package:pantas/features/mock_exam/domain/use_cases/submit_mock.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

final mockExamPreferencesProvider = Provider<MockExamPreferences>((ref) {
  return MockExamPreferences(ref.watch(appDatabaseProvider));
});

final startMockUseCaseProvider = Provider<StartMock>((ref) {
  return StartMock(
    repo: ref.watch(mockAttemptRepoProvider),
  );
});

final mockSamplerProvider = Provider<MockSampler>((ref) {
  return MockSampler();
});

final discardMockUseCaseProvider = Provider<DiscardMock>((ref) {
  return DiscardMock(repo: ref.watch(mockAttemptRepoProvider));
});

final resumeMockUseCaseProvider = Provider<ResumeMock>((ref) {
  return ResumeMock(repo: ref.watch(mockAttemptRepoProvider));
});

final submitMockUseCaseProvider = Provider<SubmitMock>((ref) {
  return SubmitMock(repo: ref.watch(mockAttemptRepoProvider));
});

final mockAnswerRecorderProvider = Provider<MockAnswerRecorder>((ref) {
  return MockAnswerRecorder(
    mocks: ref.watch(mockAttemptRepoProvider),
    attempts: ref.watch(attemptsRepositoryProvider),
    reviews: ref.watch(reviewStateRepositoryProvider),
    content: ref.watch(contentRepositoryProvider),
    scheduler: ref.watch(fsrsSchedulerProvider),
  );
});

final computeMockResultsUseCaseProvider = Provider<ComputeMockResults>((ref) {
  return ComputeMockResults();
});

class MockQuestionPools {
  const MockQuestionPools({
    required this.poolsByTopic,
    required this.passageSetsByTopic,
  });

  final Map<String, List<String>> poolsByTopic;
  final Map<String, Map<String, List<String>>> passageSetsByTopic;
}

final mockQuestionPoolsProvider =
    FutureProvider.family<MockQuestionPools, String>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final topics = await content.topicsByExam(examId);

  final poolsByTopic = <String, List<String>>{};
  final passageSetsByTopic = <String, Map<String, List<String>>>{};

  for (final topic in topics) {
    final questions = await content.questionsByTopic(topic.id);
    final qIds = <String>[];
    final pSets = <String, List<String>>{};

    for (final q in questions) {
      qIds.add(q.id);
      if (q.passageId != null) {
        pSets.putIfAbsent(q.passageId!, () => []).add(q.id);
      }
    }

    poolsByTopic[topic.id] = qIds;
    if (pSets.isNotEmpty) {
      passageSetsByTopic[topic.id] = pSets;
    }
  }

  return MockQuestionPools(
    poolsByTopic: poolsByTopic,
    passageSetsByTopic: passageSetsByTopic,
  );
});

class HydratedMockQuestion {
  const HydratedMockQuestion(this.question, this.passage);
  final Question question;
  final Passage? passage;
}

final hydratedMockQuestionProvider =
    FutureProvider.family<HydratedMockQuestion?, String>(
        (ref, questionId) async {
  final content = ref.watch(contentRepositoryProvider);
  final question = await content.questionById(questionId);
  if (question == null) return null;
  final passage = question.passageId != null
      ? await content.passageById(question.passageId!)
      : null;
  return HydratedMockQuestion(question, passage);
});
