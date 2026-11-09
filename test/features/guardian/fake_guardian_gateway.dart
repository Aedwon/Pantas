import 'dart:async';

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

  GuardianManageView manage = const GuardianManageActive(sharingAllowed: false);
  Exception? manageFailure;
  Exception? sharingFailure;
  Exception? withdrawFailure;
  GuardianWithdrawal withdrawTo = GuardianWithdrawal.withdrawn;
  final sharingCalls = <({String token, bool allowed})>[];
  final withdrawCalls = <String>[];

  /// Completes the next sharing call when set, so a test can look at the page
  /// while the call is still out.
  Completer<void>? sharingGate;

  /// Returned by the next sharing call instead of the new value.
  GuardianManageView? sharingResult;

  @override
  Future<GuardianManageView> readManage(String token) async {
    if (manageFailure != null) throw manageFailure!;
    return manage;
  }

  @override
  Future<GuardianManageView> setSharing({
    required String token,
    required bool allowed,
  }) async {
    sharingCalls.add((token: token, allowed: allowed));
    await sharingGate?.future;
    if (sharingFailure != null) throw sharingFailure!;
    return manage =
        sharingResult ?? GuardianManageActive(sharingAllowed: allowed);
  }

  @override
  Future<GuardianWithdrawal> withdraw(String token) async {
    withdrawCalls.add(token);
    if (withdrawFailure != null) throw withdrawFailure!;
    return withdrawTo;
  }
}
