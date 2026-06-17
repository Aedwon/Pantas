import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';

typedef DeleteAccountCallback = Future<void> Function();

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({
    required this.isAnonymous,
    required this.entitlement,
    required this.dpoEmail,
    required this.onDelete,
    super.key,
  });

  final bool isAnonymous;
  final SettingsEntitlementSnapshot entitlement;
  final String dpoEmail;
  final DeleteAccountCallback onDelete;

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  var _isDeleting = false;
  var _isDeleted = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    final billingLine = widget.isAnonymous
        ? anonymousDeleteWarning(widget.entitlement)
        : deleteAccountBillingLine(widget.entitlement);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAnonymous ? 'Delete data' : 'Delete account'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text(
            widget.isAnonymous ? 'Delete your data?' : 'Delete your account?',
            style: styles.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            widget.isAnonymous
                ? 'Your progress on this device will be permanently deleted. '
                    'Sign in first if you want to keep it.'
                : "You'll lose everything you've done in the app - your study "
                    'plan, quiz history, mock exam results, and progress.',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          if (billingLine != null) ...[
            const SizedBox(height: 16),
            Text(
              billingLine,
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
          ],
          const SizedBox(height: 16),
          Text("You can't undo this.", style: styles.bodyMedium),
          const SizedBox(height: 24),
          if (_isDeleted) ...[
            Text('Deletion request completed.', style: styles.bodyMedium),
            const SizedBox(height: 16),
          ],
          if (_error != null) ...[
            Text(
              'We could not complete deletion. Try again or contact our DPO '
              'at ${widget.dpoEmail}.',
              style: styles.bodySmall.copyWith(color: colors.rust),
            ),
            const SizedBox(height: 16),
          ],
          BoardButton(
            label: 'Cancel',
            secondary: true,
            onPressed:
                _isDeleting ? null : () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 8),
          _RustButton(
            onPressed: _isDeleting ? null : _delete,
            child: _isDeleting
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onBoard,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Deleting...',
                        style:
                            styles.labelLarge.copyWith(color: colors.onBoard),
                      ),
                    ],
                  )
                : Text(
                    _error != null
                        ? 'Try again'
                        : widget.isAnonymous
                            ? 'Yes, delete my data'
                            : 'Yes, delete my account',
                    style: styles.labelLarge.copyWith(color: colors.onBoard),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete() async {
    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      await widget.onDelete();
      if (!mounted) return;
      setState(() => _isDeleted = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'delete_failed');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}

class _RustButton extends StatelessWidget {
  const _RustButton({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
      child: Container(
        constraints:
            const BoxConstraints(minHeight: AppDimensions.minTapTarget),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: enabled ? colors.rust : colors.rust.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
