import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';

/// Settings, Account, "I'm 18 now": the age step again, in re-check mode. It
/// pops with `true` once the account is set to adult, and with nothing when
/// the student goes back.
class AdultRecheckPage extends StatelessWidget {
  const AdultRecheckPage({super.key});

  static const _fallback = '/settings/account';

  @override
  Widget build(BuildContext context) => Scaffold(
        body: OnboardingAgeGateStep(
          recheck: true,
          onBack: () => leavePage(context, fallback: _fallback),
          onAgeGatePassed: () => leavePage(
            context,
            fallback: _fallback,
            result: true,
            respectPopScope: false,
          ),
        ),
      );
}
