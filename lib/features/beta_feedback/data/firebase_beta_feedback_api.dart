import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';

/// The earned-reward server seam, over Firebase.
class FirebaseBetaFeedbackApi implements BetaFeedbackApi {
  FirebaseBetaFeedbackApi({WebCallable callable = callFirebaseFunction})
      : _callable = callable;

  final WebCallable _callable;

  @override
  Future<BetaReward> reward() => _guard(() async {
        final reply = await _callable('getBetaReward', const {});
        return _parseReward(_map(reply));
      });

  @override
  Future<BetaRewardActivation> activate() => _guard(() async {
        final reply = _map(await _callable('activateBetaReward', const {}));
        return BetaRewardActivation(
          startsAt: _date(reply['startsAt']),
          endsAt: _date(reply['endsAt']),
        );
      });
}

/// Runs [body] and turns any failure into a [BetaFeedbackException] the
/// screens can tell apart.
Future<T> _guard<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on BetaFeedbackException {
    rethrow;
  } on FirebaseFunctionsException catch (e) {
    throw BetaFeedbackException(
      switch (e.code) {
        'failed-precondition' => BetaFeedbackFailure.notAllowed,
        _ => BetaFeedbackFailure.other,
      },
      e.message ?? e.code,
    );
  } on Object catch (e) {
    throw BetaFeedbackException(BetaFeedbackFailure.other, '$e');
  }
}

BetaFeedbackException _malformed(String what) =>
    BetaFeedbackException(BetaFeedbackFailure.other, 'Malformed $what.');

Map<Object?, Object?> _map(Object? reply) {
  if (reply is Map) return reply;
  throw _malformed('reply');
}

DateTime _date(Object? milliseconds) {
  if (milliseconds is num) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds.toInt());
  }
  throw _malformed('date');
}

DateTime? _optionalDate(Object? milliseconds) =>
    milliseconds == null ? null : _date(milliseconds);

List<String> _strings(Object? value) {
  if (value is List && value.every((e) => e is String)) {
    return List<String>.from(value);
  }
  throw _malformed('list');
}

BetaReward _parseReward(Map<Object?, Object?> reply) {
  final survey = reply['surveySubmitted'];
  final eligible = reply['eligible'];
  if (survey is! bool || eligible is! bool) throw _malformed('reward');
  return BetaReward(
    days: _strings(reply['days']),
    betaDays: _strings(reply['betaDays']),
    surveyOpensAt: _date(reply['surveyOpensAt']),
    surveyClosesAt: _date(reply['surveyClosesAt']),
    surveySubmitted: survey,
    eligible: eligible,
    activationDeadline: _date(reply['activationDeadline']),
    activatedAt: _optionalDate(reply['activatedAt']),
    rewardStartsAt: _optionalDate(reply['rewardStartsAt']),
    rewardEndsAt: _optionalDate(reply['rewardEndsAt']),
  );
}
