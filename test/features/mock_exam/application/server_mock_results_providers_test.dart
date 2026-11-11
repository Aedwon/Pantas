import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_review_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/mock_availability.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

import '../data/server_mock_results_test.dart' as fixture;

class _Content extends Mock implements ContentRepository {}

void main() {
  final actor = StateProvider<String?>((ref) => 'a');
  ProviderContainer container(
    ServerMockApi api, {
    List<Override> extra = const [],
  }) =>
      ProviderContainer(
        overrides: [
          mockUsesServerProvider.overrideWithValue(true),
          serverMockIdentityProvider.overrideWith((ref) => ref.watch(actor)),
          serverMockActorProvider.overrideWith((ref) => () => ref.read(actor)),
          serverMockApiProvider.overrideWithValue(api),
          entitlementProvider
              .overrideWith((ref) => Stream.value(const Entitlement.free())),
          ...extra,
        ],
      );
  test('result adapter reads server without a local attempt database',
      () async {
    final c =
        container(ServerMockApi((_, __) async => fixture.result(open: false)));
    addTearDown(c.dispose);
    final entry = await c.read(mockResultsProvider('MockResult000001').future);
    expect(entry!.attempt.userId, 'a');
    expect(entry.results.percent, 50);
    final access =
        await c.read(mockReviewAccessProvider('MockResult000001').future);
    expect(access.canReview, false);
  });
  test('late result from original account cannot publish after account change',
      () async {
    final first = Completer<Object?>();
    var calls = 0;
    final c = container(
      ServerMockApi((_, __) async {
        calls++;
        return calls == 1 ? first.future : fixture.result(open: false);
      }),
    );
    addTearDown(c.dispose);
    final subscription =
        c.listen(serverMockResultProvider('MockResult000001'), (_, __) {});
    addTearDown(subscription.close);
    await Future<void>.delayed(Duration.zero);
    c.read(actor.notifier).state = 'b';
    await Future<void>.delayed(Duration.zero);
    first.complete(fixture.result(pro: true));
    await Future<void>.delayed(Duration.zero);
    final out =
        await c.read(serverMockResultProvider('MockResult000001').future);
    expect(out.proCovered, false);
    expect(out.notes, isEmpty);
    expect(calls, greaterThan(1));
  });
  test('history follows all pages and rejects repeated server cursors',
      () async {
    var calls = 0;
    final c = container(
      ServerMockApi((name, data) async {
        expect(name, 'getMockHistory');
        calls++;
        return {
          'items': [fixture.result(open: false)],
          'next': {'submittedAt': 2000, 'mockId': 'MockResult000001'},
        };
      }),
    );
    addTearDown(c.dispose);
    await c.read(entitlementProvider.future);
    await expectLater(
      c.read(serverMockHistoryProvider.future),
      throwsA(anything),
    );
    expect(calls, 2);
  });
  test('web availability uses exact server eligibility without local attempts',
      () async {
    final c = container(
      ServerMockApi((name, data) async {
        expect(name, 'getMockAvailability');
        return {
          'examId': 'exam_cse_pro',
          'serverNow': 2000,
          'status': 'cooldown',
          'proCovered': false,
          'nextEligibleAt': 8000,
          'lastMockId': null,
        };
      }),
    );
    addTearDown(c.dispose);
    await c.read(entitlementProvider.future);
    final out = await c.read(
      mockAvailabilityProvider(
        const MockAvailabilityRequest(
          userId: 'local',
          examId: 'exam_cse_pro',
        ),
      ).future,
    );
    expect(out.state, MockAvailabilityState.cooldown);
    expect(out.cooldownRemaining, const Duration(seconds: 6));
  });
  test('account change cancels the remaining history page requests', () async {
    final first = Completer<Object?>();
    var calls = 0;
    final c = container(
      ServerMockApi((_, __) async {
        calls++;
        if (calls == 1) return first.future;
        return {'items': <Object?>[], 'next': null};
      }),
    );
    addTearDown(c.dispose);
    await c.read(entitlementProvider.future);
    final subscription = c.listen(serverMockHistoryProvider, (_, __) {});
    addTearDown(subscription.close);
    await Future<void>.delayed(Duration.zero);
    c.read(actor.notifier).state = 'b';
    await Future<void>.delayed(Duration.zero);
    first.complete({
      'items': [fixture.result(open: false)],
      'next': {'submittedAt': 2000, 'mockId': 'MockResult000001'},
    });
    await Future<void>.delayed(Duration.zero);
    await c.read(serverMockHistoryProvider.future);
    expect(calls, 2);
  });

  test('web setup count comes from the server preview without local sampling',
      () async {
    final c = container(
      ServerMockApi((name, data) async {
        expect(name, 'getMockAvailability');
        expect(data, {'examId': 'exam_cse_pro', 'includeSetup': true});
        return {
          'examId': 'exam_cse_pro',
          'status': 'available',
          'setup': {'questionCount': 145, 'expectedQuestionCount': 155},
        };
      }),
    );
    addTearDown(c.dispose);
    await c.read(entitlementProvider.future);
    expect(
      await c.read(mockSetupQuestionCountProvider('exam_cse_pro').future),
      145,
    );
  });
  test(
      'web review hydrates original paper order, choices, '
      'marks and paid reasons', () async {
    final content = _Content();
    when(() => content.questionsByIds(any())).thenAnswer(
      (_) async => {
        for (final id in ['a', 'b'])
          id: Question(
            id: id,
            version: 1,
            examIds: const ['exam_cse_pro'],
            topicId: 'topic',
            language: 'en',
            stem: 'Question $id',
            explanation: 'Explanation',
            choices: const [
              Choice(id: 'a', label: 'A', text: 'Correct', isCorrect: true),
              Choice(id: 'b', label: 'B', text: 'Other', isCorrect: false),
            ],
          ),
      },
    );
    final c = container(
      ServerMockApi((_, __) async => fixture.result(pro: true)),
      extra: [
        contentRepositoryProvider.overrideWithValue(content),
        mockMarkedQuestionIdsProvider.overrideWith((ref, id) async => {'b'}),
      ],
    );
    addTearDown(c.dispose);
    await c.read(entitlementProvider.future);
    final entries = await c.read(mockReviewProvider('MockResult000001').future);
    expect(entries.map((e) => e.question.id), ['a', 'b']);
    expect(entries.first.chosenChoiceId, 'a');
    expect(entries.last.isFlagged, true);
    final notes =
        await c.read(mockReviewAnswersProvider('MockResult000001').future);
    expect(notes['a']!.selectedIndex, 0);
    expect(notes['a']!.missReason, MissReason.misread);
    expect(notes['a']!.reasonNote, 'Read carefully');
  });
  testWidgets(
      'fresh Free result and cooldown timers refresh '
      'in browser-safe segments', (tester) async {
    final serverNow = DateTime.now().millisecondsSinceEpoch;
    var elapsed = Duration.zero;
    var resultCalls = 0;
    var availabilityCalls = 0;
    final c = container(
      ServerMockApi((name, data) async {
        if (name == 'getMockResults') {
          resultCalls++;
          return fixture.result()
            ..addAll({
              'serverNow': serverNow + elapsed.inMilliseconds,
              'reviewUntil':
                  serverNow + const Duration(days: 30).inMilliseconds,
            });
        }
        availabilityCalls++;
        return {
          'examId': 'exam_cse_pro',
          'serverNow': serverNow + elapsed.inMilliseconds,
          'status': 'cooldown',
          'proCovered': false,
          'lastMockId': null,
          'nextEligibleAt': serverNow + const Duration(days: 30).inMilliseconds,
        };
      }),
      extra: [serverMockElapsedProvider.overrideWithValue(() => elapsed)],
    );
    addTearDown(c.dispose);
    await c.read(entitlementProvider.future);
    final resultSub =
        c.listen(serverMockResultProvider('MockResult000001'), (_, __) {});
    final availabilitySub = c.listen(
      mockAvailabilityProvider(
        const MockAvailabilityRequest(
          userId: 'local',
          examId: 'exam_cse_pro',
        ),
      ),
      (_, __) {},
    );
    addTearDown(resultSub.close);
    addTearDown(availabilitySub.close);
    await tester.pump();
    elapsed = const Duration(days: 25);
    await tester.pump(elapsed);
    await tester.pump();
    expect(resultCalls, 2);
    expect(availabilityCalls, 2);
    resultSub.close();
    availabilitySub.close();
    c.dispose();
  });
  testWidgets(
      'review expiry uses server time '
      'despite a fast device wall clock', (tester) async {
    final serverNow = DateTime.now()
        .subtract(const Duration(hours: 2))
        .millisecondsSinceEpoch;
    var elapsed = Duration.zero;
    var calls = 0;
    final c = container(
      ServerMockApi((_, __) async {
        calls++;
        return fixture.result(open: elapsed < const Duration(hours: 1))
          ..addAll({
            'serverNow': serverNow + elapsed.inMilliseconds,
            'reviewUntil': serverNow + const Duration(hours: 1).inMilliseconds,
          });
      }),
      extra: [serverMockElapsedProvider.overrideWithValue(() => elapsed)],
    );
    addTearDown(c.dispose);
    await c.read(entitlementProvider.future);
    final sub =
        c.listen(serverMockResultProvider('MockResult000001'), (_, __) {});
    addTearDown(sub.close);
    await tester.pump();
    elapsed = const Duration(hours: 1);
    await tester.pump(elapsed);
    await tester.pump();
    expect(calls, 2);
    expect(
      c
          .read(serverMockResultProvider('MockResult000001'))
          .requireValue
          .canReview,
      false,
    );
    sub.close();
    c.dispose();
  });
  test(
      'missing hydrated original questions fails recoverably '
      'instead of shortening review', () async {
    final content = _Content();
    when(() => content.questionsByIds(any()))
        .thenAnswer((_) async => <String, Question>{});
    final c = container(
      ServerMockApi((_, __) async => fixture.result()),
      extra: [
        contentRepositoryProvider.overrideWithValue(content),
        mockMarkedQuestionIdsProvider
            .overrideWith((ref, id) async => <String>{}),
      ],
    );
    addTearDown(c.dispose);
    await c.read(entitlementProvider.future);
    await expectLater(
      c.read(mockReviewProvider('MockResult000001').future),
      throwsA(isA<FormatException>()),
    );
  });

  testWidgets('server access transition removes paid notes after Pro lapses',
      (tester) async {
    final serverNow = DateTime.now().millisecondsSinceEpoch;
    var elapsed = Duration.zero;
    final c = container(
      ServerMockApi((_, __) async {
        final paid = elapsed < const Duration(hours: 1);
        return fixture.result(open: paid, pro: paid)
          ..addAll({
            'serverNow': serverNow + elapsed.inMilliseconds,
            'reviewUntil': serverNow - const Duration(days: 1).inMilliseconds,
            'accessRecheckAt': paid
                ? serverNow + const Duration(hours: 1).inMilliseconds
                : null,
          });
      }),
      extra: [serverMockElapsedProvider.overrideWithValue(() => elapsed)],
    );
    addTearDown(c.dispose);
    await c.read(entitlementProvider.future);
    final sub =
        c.listen(serverMockResultProvider('MockResult000001'), (_, __) {});
    addTearDown(sub.close);
    await tester.pump();
    expect(
      c.read(serverMockResultProvider('MockResult000001')).requireValue.notes,
      isNotEmpty,
    );
    elapsed = const Duration(hours: 1);
    await tester.pump(elapsed);
    await tester.pump();
    final out =
        c.read(serverMockResultProvider('MockResult000001')).requireValue;
    expect(out.proCovered, false);
    expect(out.canReview, false);
    expect(out.notes, isEmpty);
    sub.close();
    c.dispose();
  });
}
