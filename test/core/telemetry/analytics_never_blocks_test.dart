// Nov 22 2026, prod: "Could not save your progress" on every question whose
// id is longer than 64 characters. SubmitAnswer logged question_answered
// before saving, the property check threw on the long id, and the answer was
// never saved (261 of 4,429 prod questions). These tests hold the two rules
// that stop it returning: analytics never throws into a caller and never
// makes one wait, and an answer is saved whatever analytics does.
import 'dart:async';

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

/// The SDK seam as it behaved in prod: it applies the property check, so a
/// long id throws.
class _CheckingSink implements Telemetry {
  final logged = <(TelemetryEvent, Map<String, Object>?)>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    if (properties != null) assertPropertiesAllowed(properties);
    logged.add((event, properties));
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}

/// An SDK that fails, or never answers.
class _BrokenSink implements Telemetry {
  _BrokenSink({required this.hang});

  final bool hang;

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) {
    if (hang) return Completer<void>().future;
    throw StateError('analytics SDK failed');
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) {
    if (hang) return Completer<void>().future;
    throw StateError('crash SDK failed');
  }

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}

/// 65 characters, one past the old limit, shaped like the prod id
/// `q-data-interpretation-rates-ratios-and-percentages-in-context-0001` (66).
const _id65 =
    'q-data-interpretation-rates-ratios-and-percentages-in-contex-0001';

Question _question(String id) => Question(
      id: id,
      version: 1,
      examIds: const ['cse-pro'],
      topicId: 'data-interpretation',
      language: 'en',
      stem: 'What was the percentage increase?',
      choices: const [
        Choice(id: 'c1', label: 'A', text: '20%', isCorrect: false),
        Choice(id: 'c2', label: 'B', text: '25%', isCorrect: true),
      ],
      explanation: 'It rose by 10 on 40.',
    );

void main() {
  setUpAll(() => registerFallbackValue(_FakeReviewState()));

  test('the 65-character fixture is 65 characters', () {
    expect(_id65.length, 65);
  });

  group('an answer is saved whatever analytics does', () {
    late _MockReviewRepo repo;

    setUp(() {
      repo = _MockReviewRepo();
      when(() => repo.byQuestionId(any())).thenAnswer((_) async => null);
      when(() => repo.upsert(any())).thenAnswer((_) async {});
    });

    Future<void> answer(Telemetry telemetry, String id) => SubmitAnswer(
          reviewRepo: repo,
          scheduler: const FsrsScheduler(),
          telemetry: telemetry,
        ).call(
          question: _question(id),
          chosenChoiceId: 'c2',
          responseMs: 4000,
          now: DateTime.utc(2026, 11, 22, 8, 49),
          origin: 'practice',
        );

    test('a 65-character question id through the real gate', () async {
      final sink = _CheckingSink();
      await answer(GatedTelemetry(sink, consent: true), _id65);
      await pumpEventQueue();

      verify(() => repo.upsert(any())).called(1);
      expect(sink.logged.single.$2!['question_id'], _id65);
    });

    test('an analytics seam that throws, called directly', () async {
      await answer(_BrokenSink(hang: false), _id65);
      verify(() => repo.upsert(any())).called(1);
    });

    test('an analytics seam that never answers, called directly', () async {
      await answer(_BrokenSink(hang: true), 'q-short-0001')
          .timeout(const Duration(seconds: 1));
      verify(() => repo.upsert(any())).called(1);
    });

    test('analytics is sent only after the answer is saved', () async {
      final order = <String>[];
      when(() => repo.upsert(any())).thenAnswer((_) async {
        order.add('saved');
      });
      final sink = _OrderSink(order);
      await answer(sink, 'q-short-0001');
      await pumpEventQueue();

      expect(order, ['saved', 'logged']);
    });
  });

  group('the gate never throws into a caller and never makes it wait', () {
    test('an SDK that throws', () async {
      final gated = GatedTelemetry(_BrokenSink(hang: false), consent: true);
      await gated.log(TelemetryEvent.questionAnswered);
      await gated.recordError(StateError('x'), StackTrace.current);
      await pumpEventQueue();
    });

    test('an SDK that never answers', () async {
      final gated = GatedTelemetry(_BrokenSink(hang: true), consent: true);
      await gated
          .log(TelemetryEvent.questionAnswered)
          .timeout(const Duration(seconds: 1));
    });

    test('a property past the limit is dropped and the event still goes',
        () async {
      final sink = _CheckingSink();
      final gated = GatedTelemetry(sink, consent: true);
      await gated.log(
        TelemetryEvent.questionAnswered,
        properties: {
          'question_id': 'q-${'x' * 120}',
          'is_correct': true,
          'stem': 'free text is still never sent',
        },
      );
      await pumpEventQueue();

      expect(sink.logged.single.$2, {'is_correct': true});
    });
  });

  group('the identifier limit is the analytics limit', () {
    test('100 characters is allowed', () {
      expect(
        () => assertPropertiesAllowed({'question_id': 'q' * 100}),
        returnsNormally,
      );
    });

    test('101 characters is refused', () {
      expect(
        () => assertPropertiesAllowed({'question_id': 'q' * 101}),
        throwsArgumentError,
      );
    });

    test('allowedProperties keeps the good and drops the bad', () {
      final dropped = <String>[];
      expect(
        allowedProperties(
          {'question_id': _id65, 'origin': 'has spaces', 'count': 3},
          onDropped: dropped.add,
        ),
        {'question_id': _id65, 'count': 3},
      );
      expect(dropped, ['origin']);
    });
  });
}

class _OrderSink extends _CheckingSink {
  _OrderSink(this.order);

  final List<String> order;

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    order.add('logged');
  }
}
