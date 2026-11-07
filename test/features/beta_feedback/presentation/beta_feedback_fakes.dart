import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';

/// Nov 9 to 15, as the server returns them.
const betaDays = [
  '2026-11-09',
  '2026-11-10',
  '2026-11-11',
  '2026-11-12',
  '2026-11-13',
  '2026-11-14',
  '2026-11-15',
];

/// The instant of a Philippine wall-clock time (UTC+8, no daylight time).
DateTime ph(
  int month,
  int day, [
  int hour = 12,
  int minute = 0,
  int year = 2026,
]) =>
    DateTime.utc(year, month, day, hour, minute)
        .subtract(const Duration(hours: 8));

BetaReward fakeReward({
  List<String> days = const ['2026-11-09', '2026-11-10', '2026-11-11'],
  bool surveySubmitted = false,
  bool eligible = false,
  DateTime? activatedAt,
  DateTime? rewardStartsAt,
  DateTime? rewardEndsAt,
}) =>
    BetaReward(
      days: days,
      betaDays: betaDays,
      surveyOpensAt: ph(11, 15, 0),
      surveyClosesAt: ph(11, 23, 0),
      surveySubmitted: surveySubmitted,
      eligible: eligible,
      activationDeadline: ph(1, 1, 0, 0, 2028),
      activatedAt: activatedAt,
      rewardStartsAt: rewardStartsAt,
      rewardEndsAt: rewardEndsAt,
    );

SentFeedback fakeSent(
  String id,
  String text,
  DateTime at, {
  int images = 0,
}) =>
    SentFeedback(
      id: id,
      text: text,
      createdAt: at,
      attachments: [
        for (var i = 0; i < images; i++)
          SentAttachment(
            path: 'betaFeedback/u/$id/$i',
            contentType: 'image/png',
          ),
      ],
    );

PickedImage fakeImage({
  String type = 'image/png',
  int size = 8,
  String name = 'shot.png',
}) =>
    PickedImage(bytes: Uint8List(size), contentType: type, name: name);

class FakeBetaFeedbackApi implements BetaFeedbackApi {
  FakeBetaFeedbackApi({
    BetaReward? reward,
    List<SentFeedback> sent = const [],
    this.rewardGate,
  })  : rewardValue = reward ?? fakeReward(),
        _sentList = sent;

  BetaReward rewardValue;
  Completer<void>? rewardGate;
  List<SentFeedback> _sentList;
  final _changes = StreamController<List<SentFeedback>>.broadcast();

  final sends = <({String id, String text, List<PickedImage> images})>[];
  Completer<SentFeedback>? sendGate;
  Exception? sendError;
  final surveys = <SurveyAnswers>[];
  Completer<void>? surveyGate;
  Exception? surveyError;
  int activations = 0;
  Completer<BetaRewardActivation>? activateGate;
  Exception? activateError;

  @override
  Future<BetaReward> reward() async {
    final gate = rewardGate;
    if (gate != null) await gate.future;
    return rewardValue;
  }

  @override
  Stream<List<SentFeedback>> sent() async* {
    yield _sentList;
    yield* _changes.stream;
  }

  void emitSent(List<SentFeedback> list) {
    _sentList = list;
    _changes.add(list);
  }

  @override
  Future<String> imageUrl(String path) async => 'https://example.test/$path';

  @override
  Future<SentFeedback> send({
    required String feedbackId,
    required String text,
    required List<PickedImage> images,
  }) async {
    sends.add((id: feedbackId, text: text, images: images));
    final gate = sendGate;
    if (gate != null) return gate.future;
    final error = sendError;
    if (error != null) throw error;
    return SentFeedback(
      id: feedbackId,
      text: text,
      createdAt: ph(11, 12, 21, 41),
      attachments: [
        for (var i = 0; i < images.length; i++)
          SentAttachment(
            path: 'betaFeedback/u/$feedbackId/$i',
            contentType: images[i].contentType,
          ),
      ],
    );
  }

  @override
  Future<void> submitSurvey(SurveyAnswers answers) async {
    surveys.add(answers);
    final gate = surveyGate;
    if (gate != null) await gate.future;
    final error = surveyError;
    if (error != null) throw error;
  }

  @override
  Future<BetaRewardActivation> activate() async {
    activations++;
    final gate = activateGate;
    if (gate != null) return gate.future;
    final error = activateError;
    if (error != null) throw error;
    return BetaRewardActivation(
      startsAt: ph(11, 20),
      endsAt: ph(11, 20, 12, 0, 2027),
    );
  }

  @override
  Future<void> recordDay(BetaDayKind kind) async {}
}

class FakeBetaImageSource implements BetaImageSource {
  List<PickedImage> next = const [];
  final picks = <int>[];
  final _drops = StreamController<List<PickedImage>>.broadcast();

  @override
  Future<List<PickedImage>> pick({required int max}) async {
    picks.add(max);
    return next.take(max).toList();
  }

  @override
  Stream<List<PickedImage>> dropsAndPastes() => _drops.stream;

  void drop(List<PickedImage> images) => _drops.add(images);
}

/// The overrides every Feedback test needs. [now] is the beta clock.
List<Override> betaOverrides({
  required FakeBetaFeedbackApi api,
  required DateTime now,
  FakeBetaImageSource? images,
  bool tester = true,
}) =>
    [
      betaAccessProvider.overrideWith(
        (ref) async => tester ? BetaAccess.open : BetaAccess.denied,
      ),
      betaFeedbackApiProvider.overrideWithValue(api),
      betaImageSourceProvider
          .overrideWithValue(images ?? FakeBetaImageSource()),
      betaFeedbackClockProvider.overrideWithValue(() => now),
    ];
