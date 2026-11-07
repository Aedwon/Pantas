import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:pantas/app/build_info.dart';
import 'package:pantas/features/beta_feedback/data/beta_user_agent_stub.dart'
    if (dart.library.js_interop) 'package:pantas/features/beta_feedback/data/beta_user_agent_web.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';

/// One document of `users/{uid}/betaFeedback`, as stored.
@immutable
class BetaSentRow {
  const BetaSentRow(this.id, this.data);
  final String id;
  final Map<String, Object?> data;
}

/// Writes one object to Storage. Returns when the bytes are stored.
typedef BetaUpload = Future<void> Function(
  String path,
  Uint8List bytes,
  String contentType,
);

/// The tester's feedback documents, newest first, as the owner reads them.
typedef BetaSentReader = Stream<List<BetaSentRow>> Function(String uid);

typedef BetaImageUrl = Future<String> Function(String path);

/// A client-made id for one feedback, 20 letters and digits. A retry of the
/// same feedback reuses its id, so the server stores it once.
String newBetaFeedbackId([Random? random]) {
  const alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final source = random ?? Random.secure();
  return String.fromCharCodes([
    for (var i = 0; i < 20; i++)
      alphabet.codeUnitAt(source.nextInt(alphabet.length)),
  ]);
}

/// The Feedback (Beta) server and storage seam, over Firebase.
class FirebaseBetaFeedbackApi implements BetaFeedbackApi {
  FirebaseBetaFeedbackApi({
    required String? Function() uid,
    required String? Function() examId,
    WebCallable callable = callFirebaseFunction,
    BetaUpload upload = _firebaseUpload,
    BetaSentReader readSent = _firestoreSent,
    BetaImageUrl downloadUrl = _firebaseDownloadUrl,
    String Function() userAgent = betaUserAgent,
    String Function() appVersion = _buildLabel,
  })  : _uid = uid,
        _examId = examId,
        _callable = callable,
        _upload = upload,
        _readSent = readSent,
        _downloadUrl = downloadUrl,
        _userAgent = userAgent,
        _appVersion = appVersion;

  final String? Function() _uid;
  final String? Function() _examId;
  final WebCallable _callable;
  final BetaUpload _upload;
  final BetaSentReader _readSent;
  final BetaImageUrl _downloadUrl;
  final String Function() _userAgent;
  final String Function() _appVersion;

  static const _userAgentMax = 300;
  static const _appVersionMax = 40;

  @override
  Future<BetaReward> reward() => _guard(() async {
        final reply = await _callable('getBetaReward', const {});
        return _parseReward(_map(reply));
      });

  @override
  Stream<List<SentFeedback>> sent() {
    final uid = _uid();
    if (uid == null) return Stream.value(const []);
    return _readSent(uid).map(
      (rows) => [
        for (final row in rows)
          if (_parseSent(row) case final SentFeedback item) item,
      ],
    );
  }

  @override
  Future<String> imageUrl(String path) => _guard(() => _downloadUrl(path));

  @override
  Future<SentFeedback> send({
    required String feedbackId,
    required String text,
    required List<PickedImage> images,
  }) =>
      _guard(() async {
        final uid = _uid();
        if (uid == null) {
          throw const BetaFeedbackException(
            BetaFeedbackFailure.other,
            'Sign in first.',
          );
        }
        final attachments = [
          for (var i = 0; i < images.length; i++)
            SentAttachment(
              path: 'betaFeedback/$uid/$feedbackId/$i',
              contentType: images[i].contentType,
            ),
        ];
        await Future.wait([
          for (var i = 0; i < images.length; i++)
            _upload(
              attachments[i].path,
              images[i].bytes,
              images[i].contentType,
            ),
        ]);
        final trimmed = text.trim();
        final examId = _examId();
        final reply = _map(
          await _callable('sendBetaFeedback', {
            'feedbackId': feedbackId,
            'text': trimmed,
            'attachments': [
              for (final a in attachments)
                {'path': a.path, 'contentType': a.contentType},
            ],
            'userAgent': _cut(_userAgent(), _userAgentMax),
            'appVersion': _cut(_appVersion(), _appVersionMax),
            if (examId != null) 'examId': examId,
          }),
        );
        return SentFeedback(
          id: feedbackId,
          text: trimmed,
          createdAt: _date(reply['createdAt']),
          attachments: attachments,
        );
      });

  @override
  Future<void> submitSurvey(SurveyAnswers answers) => _guard(() async {
        final other = answers.other.trim();
        await _callable('submitBetaSurvey', {
          'answers': {
            'usage': switch (answers.usage) {
              SurveyUsage.everyDay => 'every_day',
              SurveyUsage.mostDays => 'most_days',
              SurveyUsage.fewDays => 'few_days',
              SurveyUsage.once => 'once',
            },
            'ease': answers.ease,
            'usefulness': answers.usefulness,
            'continue': switch (answers.keepUsing) {
              SurveyContinue.yes => 'yes',
              SurveyContinue.maybe => 'maybe',
              SurveyContinue.no => 'no',
            },
            'recommend': answers.recommend,
            'improve': answers.improve,
            if (other.isNotEmpty) 'other': other,
          },
        });
      });

  @override
  Future<BetaRewardActivation> activate() => _guard(() async {
        final reply = _map(await _callable('activateBetaReward', const {}));
        return BetaRewardActivation(
          startsAt: _date(reply['startsAt']),
          endsAt: _date(reply['endsAt']),
        );
      });

  @override
  Future<void> recordDay(BetaDayKind kind) => _guard(() async {
        await _callable('recordBetaDay', {
          'kind': switch (kind) {
            BetaDayKind.plan => 'plan',
            BetaDayKind.restDay => 'restDay',
          },
        });
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
        'already-exists' => BetaFeedbackFailure.alreadyDone,
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

/// Null for a row with no usable date, which cannot be placed in the list.
SentFeedback? _parseSent(BetaSentRow row) {
  final created = row.data['createdAt'];
  if (created is! num) return null;
  final text = row.data['text'];
  final attachments = row.data['attachments'];
  return SentFeedback(
    id: row.id,
    text: text is String ? text : '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(created.toInt()),
    attachments: [
      if (attachments is List)
        for (final a in attachments)
          if (a is Map && a['path'] is String && a['contentType'] is String)
            SentAttachment(
              path: a['path']! as String,
              contentType: a['contentType']! as String,
            ),
    ],
  );
}

String _cut(String value, int max) =>
    value.length <= max ? value : value.substring(0, max);

String _buildLabel() => 'build $kBuildNumber';

/// The rules allow a create and no update, so a retry must not write an object
/// that an earlier try already stored. The same size and type means the same
/// image, because a retry reuses the same draft.
Future<void> _firebaseUpload(
  String path,
  Uint8List bytes,
  String contentType,
) async {
  final ref = FirebaseStorage.instance.ref(path);
  try {
    final stored = await ref.getMetadata();
    if (stored.size == bytes.length && stored.contentType == contentType) {
      return;
    }
  } on FirebaseException catch (e) {
    if (e.code != 'object-not-found') rethrow;
  }
  await ref.putData(bytes, SettableMetadata(contentType: contentType));
}

Future<String> _firebaseDownloadUrl(String path) =>
    FirebaseStorage.instance.ref(path).getDownloadURL();

Stream<List<BetaSentRow>> _firestoreSent(String uid) =>
    FirebaseFirestore.instance
        .collection('users/$uid/betaFeedback')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs) BetaSentRow(doc.id, doc.data()),
          ],
        );
