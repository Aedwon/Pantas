import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_controller.dart';
import 'package:pantas/features/review_prompt/data/review_prompt_store.dart';
import 'package:pantas/features/review_prompt/domain/app_review_gateway.dart';

class _RecordingGateway implements AppReviewGateway {
  _RecordingGateway({this.available = true});

  final bool available;
  int requests = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async => requests++;
}

void main() {
  final now = DateTime.utc(2026, 8, 11, 20);

  ReviewPromptController build(
    InMemoryReviewPromptStore store,
    _RecordingGateway gateway,
  ) {
    return ReviewPromptController(
      store: store,
      gateway: gateway,
      clock: () => now,
    );
  }

  test('asks after a session that went well', () async {
    final store = InMemoryReviewPromptStore();
    final gateway = _RecordingGateway();

    await build(store, gateway).maybeAsk(justFinishedWell: true);

    expect(gateway.requests, 1);
    expect((await store.read()).askedAt, now);
  });

  test('never asks after a session that went badly', () async {
    final store = InMemoryReviewPromptStore();
    final gateway = _RecordingGateway();

    await build(store, gateway).maybeAsk(justFinishedWell: false);

    expect(gateway.requests, 0);
    expect((await store.read()).askedAt, isNull);
  });

  test('never asks twice', () async {
    final store = InMemoryReviewPromptStore();
    final gateway = _RecordingGateway();
    final controller = build(store, gateway);

    await controller.maybeAsk(justFinishedWell: true);
    await controller.maybeAsk(justFinishedWell: true);

    expect(gateway.requests, 1);
  });

  test('never asks a student who has just seen the paywall', () async {
    final store = InMemoryReviewPromptStore();
    await store.recordPaywallSeen(now.subtract(const Duration(hours: 1)));
    final gateway = _RecordingGateway();

    await build(store, gateway).maybeAsk(justFinishedWell: true);

    expect(gateway.requests, 0);
  });

  test('asks again once the paywall is well behind them', () async {
    final store = InMemoryReviewPromptStore();
    await store.recordPaywallSeen(now.subtract(const Duration(days: 3)));
    final gateway = _RecordingGateway();

    await build(store, gateway).maybeAsk(justFinishedWell: true);

    expect(gateway.requests, 1);
  });

  test('records nothing when the device cannot show the popup', () async {
    final store = InMemoryReviewPromptStore();
    final gateway = _RecordingGateway(available: false);

    await build(store, gateway).maybeAsk(justFinishedWell: true);

    expect(gateway.requests, 0);
    // The one honest ask is still owed, so it must not be spent here.
    expect((await store.read()).askedAt, isNull);
  });
}
