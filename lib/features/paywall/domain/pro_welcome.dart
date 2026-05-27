import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';

class ProWelcomeState {
  const ProWelcomeState._();

  static bool shouldShow({
    required Entitlement previous,
    required Entitlement current,
    required bool alreadyWelcomed,
  }) {
    return !alreadyWelcomed && !previous.proIsActive && current.proIsActive;
  }
}
