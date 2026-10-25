import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';

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
    final styles = context.type;
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "I'll be your coach.",
                            style: styles.sectionHero,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Get one daily study reminder and a streak-save '
                            'warning when you still have work left today.',
                            style: styles.body
                                .copyWith(color: colors.secondaryLabel),
                          ),
                          const SizedBox(height: 32),
                          PantasButton(
                            label: 'Sounds good',
                            onPressed: _isSaving
                                ? null
                                : () => _continue(requestPermission: true),
                          ),
                          const SizedBox(height: 8),
                          PantasButton(
                            label: 'Not right now',
                            variant: PantasButtonVariant.tertiary,
                            onPressed: _isSaving
                                ? null
                                : () => _continue(requestPermission: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
