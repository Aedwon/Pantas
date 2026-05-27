import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({
    required this.isAnonymous,
    required this.entitlement,
    super.key,
  });

  final bool isAnonymous;
  final SettingsEntitlementSnapshot entitlement;

  @override
  Widget build(BuildContext context) {
    final billingLine = isAnonymous
        ? anonymousDeleteWarning(entitlement)
        : deleteAccountBillingLine(entitlement);
    return Scaffold(
      appBar: AppBar(
        title: Text(isAnonymous ? 'Delete data' : 'Delete account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isAnonymous ? 'Delete your data?' : 'Delete your account?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            isAnonymous
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
          OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {},
            child: Text(
              isAnonymous ? 'Yes, delete my data' : 'Yes, delete my account',
            ),
          ),
        ],
      ),
    );
  }
}
