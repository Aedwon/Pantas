import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';

class FakeGuardianGateway implements GuardianGateway {
  GuardianStatus current = const GuardianStatus(
    status: GuardianConsentStatus.none,
  );
  Exception? failure;
  final sent = <({String name, String email, String? student})>[];

  @override
  Future<GuardianStatus> status() async {
    if (failure != null) throw failure!;
    return current;
  }

  @override
  Future<GuardianStatus> sendLink({
    required String guardianName,
    required String guardianEmail,
    String? studentName,
  }) async {
    if (failure != null) throw failure!;
    sent.add((name: guardianName, email: guardianEmail, student: studentName));
    return current = GuardianStatus(
      status: GuardianConsentStatus.pending,
      maskedEmail: maskEmail(guardianEmail),
      expiresAt: DateTime.utc(2026, 11, 9),
    );
  }

  GuardianLinkView link = const GuardianLinkClosed(
    GuardianLinkClosedReason.unknown,
  );
  GuardianAnswer answerTo = GuardianAnswer.confirmed;
  final answers = <({String token, bool confirm, bool agreed})>[];

  @override
  Future<GuardianLinkView> readLink(String token) async {
    if (failure != null) throw failure!;
    return link;
  }

  @override
  Future<GuardianAnswer> answer({
    required String token,
    required bool confirm,
    required bool agreed,
  }) async {
    if (failure != null) throw failure!;
    answers.add((token: token, confirm: confirm, agreed: agreed));
    return answerTo;
  }
}
