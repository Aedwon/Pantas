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
    final billingLine = widget.isAnonymous
        ? anonymousDeleteWarning(widget.entitlement)
        : deleteAccountBillingLine(widget.entitlement);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAnonymous ? 'Delete data' : 'Delete account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.isAnonymous ? 'Delete your data?' : 'Delete your account?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            widget.isAnonymous
                ? 'Your progress on this device will be permanently deleted. '
                    'Sign in first if you want to keep it.'
                : "You'll lose everything you've done in the app - your study "
                    'plan, quiz history, mock exam results, and progress.',
          ),
          if (billingLine != null) ...[
            const SizedBox(height: 16),
            Text(billingLine),
          ],
          const SizedBox(height: 16),
          const Text("You can't undo this."),
          const SizedBox(height: 24),
          if (_isDeleted) ...[
            const Text('Deletion request completed.'),
            const SizedBox(height: 16),
          ],
          if (_error != null) ...[
            Text(
              'We could not complete deletion. Try again or contact our DPO '
              'at ${widget.dpoEmail}.',
            ),
            const SizedBox(height: 16),
          ],
          OutlinedButton(
            onPressed:
                _isDeleting ? null : () => Navigator.of(context).maybePop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _isDeleting ? null : _delete,
            child: _isDeleting
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Deleting...'),
                    ],
                  )
                : Text(
                    _error != null
                        ? 'Try again'
                        : widget.isAnonymous
                            ? 'Yes, delete my data'
                            : 'Yes, delete my account',
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
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
      });
    }
  }
}
