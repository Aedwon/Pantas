import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/components/settings_group.dart';
import 'package:pantas/core/ui/components/settings_value_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:url_launcher/url_launcher.dart';

const _googlePlaySubscriptionsPath = '/store/account/subscriptions';
const _productionPackageName = 'com.aedwon.pantas';

typedef SubscriptionManagementLauncher = Future<bool> Function(Uri uri);

Future<bool> launchGooglePlaySubscriptionManagement(Uri uri) {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Uri googlePlaySubscriptionManagementUri(Entitlement entitlement) {
  final rawProductId = entitlement.productId;
  final canLinkDirectly = entitlement.proIsActive &&
      !entitlement.isUnknownPlan &&
      rawProductId != null &&
      rawProductId.isNotEmpty;
  if (!canLinkDirectly) {
    return Uri.https('play.google.com', _googlePlaySubscriptionsPath);
  }

  final productId = rawProductId.split(':').first;
  return Uri.https('play.google.com', _googlePlaySubscriptionsPath, {
    'sku': productId,
    'package': _productionPackageName,
  });
}

class ProPage extends ConsumerStatefulWidget {
  const ProPage({
    this.subscriptionLauncher = launchGooglePlaySubscriptionManagement,
    super.key,
  });

  final SubscriptionManagementLauncher subscriptionLauncher;

  @override
  ConsumerState<ProPage> createState() => _ProPageState();
}

class _ProPageState extends ConsumerState<ProPage> {
  bool _restorePending = false;
  bool _managePending = false;
  String? _feedback;

  @override
  Widget build(BuildContext context) {
    final entitlement =
        ref.watch(entitlementProvider).valueOrNull ?? const Entitlement.free();
    final planName = _planName(entitlement);
    final expiresAt = entitlement.expiresAt;
    final dateValue =
        expiresAt == null ? null : DateFormat.yMMMd().format(expiresAt);
    final dateLabel = dateValue == null ? null : _dateLabel(entitlement);

    return PageScaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SettingsBar(title: 'Pro', backLabel: 'Settings'),
          SettingsGroup(
            title: 'Current plan',
            isFirst: true,
            children: [
              SettingsValueRow(title: 'Plan', value: planName),
              if (dateValue != null && dateLabel != null)
                SettingsValueRow(title: dateLabel, value: dateValue),
            ],
          ),
          const SettingsGroup(
            title: 'Plans',
            children: [
              SettingsValueRow(title: 'Weekly', value: '₱29 / week'),
              SettingsValueRow(title: 'Monthly', value: '₱99 / month'),
              SettingsValueRow(
                title: 'Yearly',
                value: '₱799 / year (7-day free trial)',
              ),
            ],
          ),
          SettingsGroup(
            title: 'Manage',
            children: [
              if (!entitlement.proIsActive)
                SettingsValueRow(
                  title: 'Try Pro',
                  showChevron: true,
                  onTap:
                      _restorePending ? null : () => context.push('/paywall'),
                ),
              Semantics(
                button: true,
                enabled: !_managePending,
                label: _managePending
                    ? 'Opening Google Play'
                    : 'Manage in Google Play',
                child: SettingsValueRow(
                  title: _managePending
                      ? 'Opening Google Play...'
                      : 'Manage in Google Play',
                  showChevron: true,
                  onTap: _managePending
                      ? null
                      : () => _openGooglePlay(entitlement),
                ),
              ),
              Semantics(
                button: true,
                enabled: !_restorePending,
                liveRegion: _restorePending,
                label: _restorePending
                    ? 'Restore in progress'
                    : 'Restore purchases',
                child: SettingsValueRow(
                  title: _restorePending ? 'Restoring...' : 'Restore purchases',
                  onTap: _restorePending ? null : _restore,
                ),
              ),
              if (_feedback != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 6, 14, 6),
                  child: Text(
                    _feedback!,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.inkMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _planName(Entitlement entitlement) {
    if (!entitlement.proIsActive) return 'Free';
    if (entitlement.isUnknownPlan) {
      return entitlement.isTrial ? 'Pro trial' : 'Pro';
    }

    final knownPlan = switch (entitlement.plan) {
      EntitlementPlan.weekly => 'Weekly',
      EntitlementPlan.monthly => 'Monthly',
      EntitlementPlan.yearly => 'Yearly',
      EntitlementPlan.free => 'Pro',
    };
    return entitlement.isTrial ? '$knownPlan trial' : knownPlan;
  }

  String _dateLabel(Entitlement entitlement) {
    if (entitlement.isTrial) {
      return entitlement.willRenew ? 'Charges' : 'Ends';
    }
    return entitlement.willRenew ? 'Renews' : 'Ends';
  }

  Future<void> _restore() async {
    if (_restorePending) return;
    setState(() {
      _restorePending = true;
      _feedback = null;
    });

    final result = await ref.read(paywallControllerProvider).restore();
    if (!mounted) return;
    setState(() {
      _restorePending = false;
      _feedback = _restoreFeedback(
        result.status,
        result.entitlement.proIsActive,
      );
    });
  }

  String? _restoreFeedback(PaymentOperationStatus status, bool proIsActive) {
    if (status == PaymentOperationStatus.success && proIsActive) {
      return 'Pro restored.';
    }
    return switch (status) {
      PaymentOperationStatus.success ||
      PaymentOperationStatus.entitlementNotActive =>
        "We found a purchase, but Pro couldn't be confirmed yet. "
            'Try again in a moment.',
      PaymentOperationStatus.noActiveSubscription =>
        "We couldn't find an active Pro subscription on this Google Play "
            'account.',
      PaymentOperationStatus.userCancelled ||
      PaymentOperationStatus.operationAlreadyInProgress =>
        null,
      PaymentOperationStatus.networkFailure =>
        'You need a connection to restore purchases. Try again when '
            "you're back online.",
      PaymentOperationStatus.storeFailure =>
        "Google Play couldn't check your purchases right now. Try again.",
      PaymentOperationStatus.revenueCatFailure ||
      PaymentOperationStatus.configurationFailure ||
      PaymentOperationStatus.developerFailure ||
      PaymentOperationStatus.unknownFailure =>
        "Restore purchases isn't available right now. Try again later.",
    };
  }

  Future<void> _openGooglePlay(Entitlement entitlement) async {
    if (_managePending) return;
    setState(() {
      _managePending = true;
      _feedback = null;
    });

    var opened = false;
    try {
      opened = await widget.subscriptionLauncher(
        googlePlaySubscriptionManagementUri(entitlement),
      );
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    setState(() {
      _managePending = false;
      if (!opened) {
        _feedback = "We couldn't open Google Play. You can manage your "
            'subscription in the Google Play app.';
      }
    });
  }
}
