import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/features/onboarding/application/setup_acceptance.dart';

/// Stands in front of the Terms step. A named account whose own record covers
/// the current wording skips Terms. Anyone else, and any failure, sees Terms.
/// The existing loading state shows while the record is read, so Terms never
/// flashes before a skip.
class OnboardingTermsGate extends ConsumerStatefulWidget {
  const OnboardingTermsGate({
    required this.check,
    required this.terms,
    required this.onSkipped,
    required this.onShowTerms,
    super.key,
  });

  /// False once a check this visit ended with Terms on screen.
  final bool check;

  /// The Terms step, shown when the student has to accept.
  final Widget terms;

  /// The record covered Terms and the acceptance is restored on this device.
  final VoidCallback onSkipped;

  /// The check ended with Terms to show, so it is not run again this visit.
  final VoidCallback onShowTerms;

  @override
  ConsumerState<OnboardingTermsGate> createState() =>
      _OnboardingTermsGateState();
}

class _OnboardingTermsGateState extends ConsumerState<OnboardingTermsGate> {
  late bool _checking;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authStateProvider).valueOrNull;
    _checking = widget.check && auth is SignedInAuthState;
    if (_checking) unawaited(_check((auth! as SignedInAuthState).user.uid));
  }

  Future<void> _check(String uid) async {
    final skipped = await ref.read(termsSkipProvider)(uid);
    if (!mounted) return;
    if (skipped) {
      widget.onSkipped();
      return;
    }
    widget.onShowTerms();
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) =>
      _checking ? loadingFor(const AsyncLoading<void>()) : widget.terms;
}
