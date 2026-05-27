import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/features/notifications/application/notifications_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PermissionRationalePage extends ConsumerStatefulWidget {
  const PermissionRationalePage({super.key});

  @override
  ConsumerState<PermissionRationalePage> createState() =>
      _PermissionRationalePageState();
}

class _PermissionRationalePageState
    extends ConsumerState<PermissionRationalePage> {
  var _isSaving = false;

  Future<void> _continue({required bool requestPermission}) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    if (requestPermission) {
      await ref.read(notificationServiceProvider).requestPermission();
    }
    await ref.read(notificationRationaleRepositoryProvider).markShown();
    ref.invalidate(notificationRationaleShownProvider);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "I'll be your coach.",
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Get one daily study reminder and a streak-save warning '
                    'when you still have work left today.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isSaving
                        ? null
                        : () => _continue(requestPermission: true),
                    child: const Text('Sounds good'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => _continue(requestPermission: false),
                    child: const Text('Not right now'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
