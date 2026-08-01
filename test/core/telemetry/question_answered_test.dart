import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/core/telemetry/gated_telemetry.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';

class _MockReviewRepo extends Mock implements ReviewStateRepository {}

class _FakeReviewState extends Fake implements ReviewState {}

class _RecordingTelemetry implements Telemetry {
  final loggedEvents = <(TelemetryEvent, Map<String, Object>?)>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    loggedEvents.add((event, properties));
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeReviewState());
  });

  const question = Question(
    id: 'q-biology-cell-structure-0001',
    version: 1,
    examIds: ['cse-pro'],
    topicId: 'biology',
    language: 'en',
    stem: 'What is the powerhouse of the cell?',
    choices: [
      Choice(
        id: 'c1',
        label: 'A',
        text: 'Nucleus',
        isCorrect: false,
      ),
      Choice(
        id: 'c2',
        label: 'B',
        text: 'Mitochondria',
        isCorrect: true,
      ),
      Choice(
        id: 'c3',
        label: 'C',
        text: 'Ribosome',
        isCorrect: false,
      ),
    ],
    explanation: 'Mitochondria generate ATP.',
  );

  group('question_answered event', () {
    test('questionAnswered wire name is question_answered', () {
      expect(TelemetryEvent.questionAnswered.name, 'question_answered');
    });

    test('assertPropertiesAllowed permits item analytics properties', () {
      expect(
        () => assertPropertiesAllowed({
          'question_id': 'q-biology-cell-structure-0001',
          'is_correct': true,
          'chosen_label': 'B',
          'origin': 'today_topic',
        }),
        returnsNormally,
      );
    });

    test('assertPropertiesAllowed rejects forbidden text properties', () {
      // Question stem or text
      expect(
        () => assertPropertiesAllowed({'stem': 'What is the powerhouse?'}),
        throwsA(isA<ArgumentError>()),
      );

      // Free text answer
      expect(
        () => assertPropertiesAllowed({'answer': 'Mitochondria'}),
        throwsA(isA<ArgumentError>()),
      );

      // Student name or email
      expect(
        () => assertPropertiesAllowed({'name': 'Jane Doe'}),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => assertPropertiesAllowed({'email': 'student@example.com'}),
        throwsA(isA<ArgumentError>()),
      );

      // Aggregate score, accuracy, streak, rank
      expect(
        () => assertPropertiesAllowed({'score': 95}),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => assertPropertiesAllowed({'accuracy': 0.85}),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => assertPropertiesAllowed({'streak': 7}),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => assertPropertiesAllowed({'rank': 1}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('nothing is emitted when consent is off', () async {
      final repo = _MockReviewRepo();
      when(() => repo.byQuestionId(any())).thenAnswer((_) async => null);
      when(() => repo.upsert(any())).thenAnswer((_) async {});

      final sink = _RecordingTelemetry();
      final gatedTelemetry = GatedTelemetry(sink, consent: false);

      final submitAnswer = SubmitAnswer(
        reviewRepo: repo,
        scheduler: const FsrsScheduler(),
        telemetry: gatedTelemetry,
      );

      await submitAnswer(
        question: question,
        chosenChoiceId: 'c2',
        responseMs: 1200,
        now: DateTime.utc(2026, 8, 11),
        origin: 'today_topic',
      );

      expect(sink.loggedEvents, isEmpty);
    });

    test('nothing is emitted when consent is null (unanswered)', () async {
      final repo = _MockReviewRepo();
      when(() => repo.byQuestionId(any())).thenAnswer((_) async => null);
      when(() => repo.upsert(any())).thenAnswer((_) async {});

      final sink = _RecordingTelemetry();
      final gatedTelemetry = GatedTelemetry(sink, consent: null);

      final submitAnswer = SubmitAnswer(
        reviewRepo: repo,
        scheduler: const FsrsScheduler(),
        telemetry: gatedTelemetry,
      );

      await submitAnswer(
        question: question,
        chosenChoiceId: 'c2',
        responseMs: 1200,
        now: DateTime.utc(2026, 8, 11),
        origin: 'today_topic',
      );

      expect(sink.loggedEvents, isEmpty);
    });

    test('fires once per answer with four properties when consent is on',
        () async {
      final repo = _MockReviewRepo();
      when(() => repo.byQuestionId(any())).thenAnswer((_) async => null);
      when(() => repo.upsert(any())).thenAnswer((_) async {});

      final sink = _RecordingTelemetry();
      final gatedTelemetry = GatedTelemetry(sink, consent: true);

      final submitAnswer = SubmitAnswer(
        reviewRepo: repo,
        scheduler: const FsrsScheduler(),
        telemetry: gatedTelemetry,
      );

      await submitAnswer(
        question: question,
        chosenChoiceId: 'c2',
        responseMs: 1200,
        now: DateTime.utc(2026, 8, 11),
        origin: 'today_topic',
      );

      expect(sink.loggedEvents, hasLength(1));
      final (event, props) = sink.loggedEvents.first;
      expect(event, TelemetryEvent.questionAnswered);
      expect(props, {
        'question_id': 'q-biology-cell-structure-0001',
        'is_correct': true,
        'chosen_label': 'B',
        'origin': 'today_topic',
      });
    });
  });
}
