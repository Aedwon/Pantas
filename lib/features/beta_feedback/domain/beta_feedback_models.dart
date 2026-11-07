import 'dart:typed_data';

import 'package:meta/meta.dart';

/// The tester's reward progress, as `getBetaReward` returns it.
@immutable
class BetaReward {
  const BetaReward({
    required this.days,
    required this.betaDays,
    required this.surveyOpensAt,
    required this.surveyClosesAt,
    required this.surveySubmitted,
    required this.eligible,
    required this.activationDeadline,
    this.activatedAt,
    this.rewardStartsAt,
    this.rewardEndsAt,
  });

  /// Counted Philippine dates, `YYYY-MM-DD`.
  final List<String> days;

  /// The seven beta dates, Nov 9 to 15, `YYYY-MM-DD`.
  final List<String> betaDays;
  final DateTime surveyOpensAt;
  final DateTime surveyClosesAt;
  final bool surveySubmitted;

  /// 5 days, a sent survey and the deadline not passed.
  final bool eligible;
  final DateTime activationDeadline;
  final DateTime? activatedAt;
  final DateTime? rewardStartsAt;
  final DateTime? rewardEndsAt;

  bool get activated => activatedAt != null;
  bool surveyOpen(DateTime now) =>
      !now.isBefore(surveyOpensAt) && now.isBefore(surveyClosesAt);
}

@immutable
class SentAttachment {
  const SentAttachment({required this.path, required this.contentType});
  final String path;
  final String contentType;
}

/// One row of `users/{uid}/betaFeedback`, newest first in lists.
@immutable
class SentFeedback {
  const SentFeedback({
    required this.id,
    required this.text,
    required this.createdAt,
    this.attachments = const [],
  });
  final String id;
  final String text;
  final DateTime createdAt;
  final List<SentAttachment> attachments;
}

/// An image the tester picked, dropped or pasted, before it is uploaded.
@immutable
class PickedImage {
  const PickedImage({
    required this.bytes,
    required this.contentType,
    this.name = '',
  });
  final Uint8List bytes;

  /// `image/png`, `image/jpeg` or `image/webp`.
  final String contentType;
  final String name;

  static const maxBytes = 5 * 1024 * 1024;
  static const types = {'image/png', 'image/jpeg', 'image/webp'};
}

/// Why a picked file was refused before upload.
enum PickedImageProblem { tooLarge, wrongType }

/// Null when [image] can be sent.
PickedImageProblem? problemWith(PickedImage image) {
  if (!PickedImage.types.contains(image.contentType)) {
    return PickedImageProblem.wrongType;
  }
  if (image.bytes.length > PickedImage.maxBytes) {
    return PickedImageProblem.tooLarge;
  }
  return null;
}

/// Where screenshots come from: the picker everywhere, and on web also files
/// dropped on or pasted into the page.
abstract interface class BetaImageSource {
  /// Opens the system picker. Up to [max] images; empty when canceled.
  Future<List<PickedImage>> pick({required int max});

  /// Web: images dropped or pasted anywhere on the page while listened to.
  /// Elsewhere it never emits.
  Stream<List<PickedImage>> dropsAndPastes();
}

enum SurveyUsage { everyDay, mostDays, fewDays, once }

enum SurveyContinue { yes, maybe, no }

/// The seven answers `submitBetaSurvey` takes.
@immutable
class SurveyAnswers {
  const SurveyAnswers({
    required this.usage,
    required this.ease,
    required this.usefulness,
    required this.keepUsing,
    required this.recommend,
    required this.improve,
    this.other = '',
  });
  final SurveyUsage usage;

  /// 1 to 5.
  final int ease;

  /// 1 to 5.
  final int usefulness;
  final SurveyContinue keepUsing;

  /// 0 to 10.
  final int recommend;
  final String improve;
  final String other;
}

/// What `activateBetaReward` returns.
@immutable
class BetaRewardActivation {
  const BetaRewardActivation({required this.startsAt, required this.endsAt});
  final DateTime startsAt;
  final DateTime endsAt;
}

enum BetaDayKind { plan, restDay }

/// A callable error the screens show differently from a network failure.
enum BetaFeedbackFailure {
  /// `failed-precondition`: the survey is not open, or a reward condition
  /// is unmet.
  notAllowed,

  /// `already-exists`: the survey was already sent.
  alreadyDone,

  /// Anything else, including no connection.
  other,
}

class BetaFeedbackException implements Exception {
  const BetaFeedbackException(this.failure, [this.message = '']);
  final BetaFeedbackFailure failure;
  final String message;
  @override
  String toString() => 'BetaFeedbackException($failure, $message)';
}

/// The server and storage seam for the Feedback (Beta) page.
abstract interface class BetaFeedbackApi {
  Future<BetaReward> reward();

  /// Newest first. Emits again when a new row arrives.
  Stream<List<SentFeedback>> sent();

  /// A download URL for one of the tester's own attachments.
  Future<String> imageUrl(String path);

  /// Uploads [images] to `betaFeedback/{uid}/{feedbackId}/{i}` and then calls
  /// `sendBetaFeedback`. A retry with the same [feedbackId] is safe.
  Future<SentFeedback> send({
    required String feedbackId,
    required String text,
    required List<PickedImage> images,
  });

  Future<void> submitSurvey(SurveyAnswers answers);

  Future<BetaRewardActivation> activate();

  Future<void> recordDay(BetaDayKind kind);
}
