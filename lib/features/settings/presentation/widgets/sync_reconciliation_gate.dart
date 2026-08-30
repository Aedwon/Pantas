import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/l10n/app_localizations.dart';

class SyncReconciliationGate extends ConsumerWidget {
  const SyncReconciliationGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStatus = ref.watch(syncStatusProvider);
    final status =
        asyncStatus.valueOrNull ?? ref.watch(syncRuntimeProvider).currentStatus;
    if (status is! SyncReconciliationRequired) return child;

    final strings = AppLocalizations.of(context)!;
    final runtime = ref.watch(syncRuntimeProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        const ModalBarrier(dismissible: false, color: Colors.black54),
        Center(
          child: AlertDialog(
            title: Text(strings.syncReconciliationTitle),
            content: Text(strings.syncReconciliationBody),
            actions: [
              OutlinedButton(
                style:
                    const ButtonStyle(splashFactory: InkRipple.splashFactory),
                onPressed: () {
                  unawaited(
                    runtime.chooseReconciliation(
                      SyncReconciliationChoice.keepMyAccount,
                    ),
                  );
                },
                child: Text(strings.syncKeepMyAccount),
              ),
              FilledButton(
                style:
                    const ButtonStyle(splashFactory: InkRipple.splashFactory),
                onPressed: () {
                  unawaited(
                    runtime.chooseReconciliation(
                      SyncReconciliationChoice.keepThisDevice,
                    ),
                  );
                },
                child: Text(strings.syncKeepThisDevice),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
