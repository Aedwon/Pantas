import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';

class FakeGuardianGateway implements GuardianGateway {
  GuardianStatus current = const GuardianStatus(
    status: GuardianConsentStatus.none,
  );
  Exception? failure;
  final sent = <({String name, String email, String? ageCheckNoticeVersion})>[];
  Exception? adultFailure;
  int adultCalls = 0;

  @override
  Future<GuardianStatus> status() async {
    if (failure != null) throw failure!;
    return current;
  }

  @override
  Future<GuardianStatus> sendLink({
    required String guardianName,
    required String guardianEmail,
    String? ageCheckNoticeVersion,
  }) async {
    if (failure != null) throw failure!;
    sent.add(
      (
        name: guardianName,
        email: guardianEmail,
        ageCheckNoticeVersion: ageCheckNoticeVersion,
      ),
    );
    return current = GuardianStatus(
      status: GuardianConsentStatus.pending,
      maskedEmail: maskEmail(guardianEmail),
      expiresAt: DateTime.utc(2026, 11, 9),
    );
  }

  @override
  Future<void> markAdult() async {
    adultCalls++;
    if (adultFailure != null) throw adultFailure!;
  }

  GuardianLinkView link = const GuardianLinkClosed(
    GuardianLinkClosedReason.unknown,
  );
  GuardianAnswer answerTo = GuardianAnswer.confirmed;
  String? manageTokenTo = 'manage-token';
  final answers = <({
    String token,
    bool confirm,
    bool agreed,
    bool allowSharing,
  })>[];

  @override
  Future<GuardianLinkView> readLink(String token) async {
    if (failure != null) throw failure!;
    return link;
  }

  @override
  Future<GuardianAnswerResult> answer({
    required String token,
    required bool confirm,
    required bool agreed,
    required bool allowSharing,
  }) async {
    if (failure != null) throw failure!;
    answers.add(
      (
        token: token,
        confirm: confirm,
        agreed: agreed,
        allowSharing: allowSharing,
      ),
    );
    return GuardianAnswerResult(
      answerTo,
      manageToken: answerTo == GuardianAnswer.confirmed ? manageTokenTo : null,
    );
  }
}
