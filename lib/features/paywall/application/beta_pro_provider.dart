import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';

class BetaProState {
  const BetaProState({required this.until, required this.enabled});
  final DateTime until;
  final bool enabled;
}

final betaProCallableProvider =
    Provider<WebCallable>((ref) => callFirebaseFunction);

/// Only the owner's server reply can expose the switch. The timer removes it
/// at the cutoff even if Settings stays open throughout the end of the beta.
final betaProProvider = StreamProvider.autoDispose<BetaProState?>((ref) {
  var disposed = false;
  Timer? timer;
  final expired = Completer<void>();
  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    if (!expired.isCompleted) expired.complete();
  });
  final callable = ref.watch(betaProCallableProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  final focus = ref.watch(activeExamFocusProvider.future);
  Stream<BetaProState?> load() async* {
    final examId = (await focus).exam?.id;
    if (disposed) return;
    if (examId == null) {
      yield null;
      return;
    }
    final reply = await callable('getWebEntitlement', {'uid': user.uid});
    if (disposed) return;
    if (reply is! Map || reply['betaProUntil'] is! num) {
      yield null;
      return;
    }
    final until = DateTime.fromMillisecondsSinceEpoch(
      (reply['betaProUntil']! as num).toInt(),
      isUtc: true,
    );
    final now = DateTime.now();
    final delay = until.difference(now);
    if (delay <= Duration.zero) {
      yield null;
      return;
    }
    final rows = reply['grants'];
    final enabled = rows is List &&
        rows.whereType<Map<Object?, Object?>>().any(
              (row) =>
                  row['source'] == 'beta' &&
                  row['examId'] == examId &&
                  row['state'] == 'active' &&
                  row['startsAt'] is num &&
                  row['endsAt'] is num &&
                  (row['startsAt']! as num) <= now.millisecondsSinceEpoch &&
                  (row['endsAt']! as num) > now.millisecondsSinceEpoch,
            );
    timer = Timer(delay, expired.complete);
    yield BetaProState(until: until, enabled: enabled);
    await expired.future;
    if (disposed) return;
    yield null;
    if (!disposed &&
        ref.read(currentUserProvider).valueOrNull?.uid == user.uid) {
      await ref.read(revenueCatGatewayProvider).restorePurchases();
    }
  }

  return load();
});

final setBetaProProvider =
    Provider<Future<void> Function({required bool enabled})>((ref) {
  return ({required enabled}) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) throw StateError('Sign in first.');
    final examId = (await ref.read(activeExamFocusProvider.future)).exam?.id;
    if (examId == null) throw StateError('Choose an exam first.');
    if (ref.read(currentUserProvider).valueOrNull?.uid != user.uid) return;
    await ref.read(betaProCallableProvider)('setBetaPro', {
      'enabled': enabled,
      'examId': examId,
      'uid': user.uid,
    });
    if (ref.read(currentUserProvider).valueOrNull?.uid != user.uid) return;
    // This refresh copies the claim token and reads the confirmed grant ledger.
    await ref.read(revenueCatGatewayProvider).restorePurchases();
    ref.invalidate(betaProProvider);
  };
});
