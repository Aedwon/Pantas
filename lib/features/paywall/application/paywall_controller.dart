import 'dart:async';

import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> _openManagementPage(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

class PaywallController {
  PaywallController(
    this._gateway, {
    Telemetry telemetry = const DisabledTelemetry(),
    Future<bool> Function(Uri)? openManagementPage,
  })  : _telemetry = telemetry,
        _openManagement = openManagementPage ?? _openManagementPage;

  final RevenueCatGateway _gateway;
  final Telemetry _telemetry;
  final Future<bool> Function(Uri) _openManagement;
  bool _operationInFlight = false;

  void logPaywallShown({String? trigger}) {
    unawaited(
      _telemetry.log(
        TelemetryEvent.paywallShown,
        properties: {'trigger': trigger ?? 'manual'},
      ),
    );
  }

  Future<PaywallCommandResult> purchase(PaywallPackage package) async {
    if (_operationInFlight) return _alreadyInProgress();
    _operationInFlight = true;
    unawaited(
      _telemetry.log(
        TelemetryEvent.purchaseStarted,
        properties: {'sku': package.sku.name},
      ),
    );

    try {
      final operation = await _gateway.purchase(package);
      final command = _commandResult(operation);
      if (operation.status == PaymentOperationStatus.success &&
          command.entitlement.proIsActive) {
        unawaited(_telemetry.log(TelemetryEvent.purchaseCompleted));
      } else if (operation.status != PaymentOperationStatus.userCancelled &&
          operation.status !=
              PaymentOperationStatus.operationAlreadyInProgress) {
        unawaited(
          _telemetry.log(
            TelemetryEvent.purchaseFailed,
            properties: {'reason': operation.status.name},
          ),
        );
      }
      return command;
    } catch (_) {
      unawaited(
        _telemetry.log(
          TelemetryEvent.purchaseFailed,
          properties: {'reason': PaymentOperationStatus.unknownFailure.name},
        ),
      );
      return _commandResult(
        const PaymentOperationResult.failure(
          status: PaymentOperationStatus.unknownFailure,
        ),
      );
    } finally {
      _operationInFlight = false;
    }
  }

  Future<PaywallCommandResult> restore() async {
    if (_operationInFlight) return _alreadyInProgress();
    _operationInFlight = true;
    try {
      return _commandResult(await _gateway.restorePurchases());
    } catch (_) {
      return _commandResult(
        const PaymentOperationResult.failure(
          status: PaymentOperationStatus.unknownFailure,
        ),
      );
    } finally {
      _operationInFlight = false;
    }
  }

  Future<PaywallCommandResult> purchasePass(
    PaywallPassPackage package, {
    required ExamCatalogEntry exam,
  }) async {
    if (_operationInFlight) return _alreadyInProgress();
    final gateway = _gateway;
    if (gateway is! RevenueCatPassGateway) {
      return _commandResult(
        const PaymentOperationResult.failure(
          status: PaymentOperationStatus.configurationFailure,
        ),
      );
    }
    _operationInFlight = true;
    try {
      return _commandResult(await gateway.purchasePass(package, exam: exam));
    } catch (_) {
      return _commandResult(
        const PaymentOperationResult.failure(
          status: PaymentOperationStatus.unknownFailure,
        ),
      );
    } finally {
      _operationInFlight = false;
    }
  }

  Future<PaywallCommandResult> manage() async {
    try {
      final opened = await _openManagement(
        Uri.https('play.google.com', '/store/account/subscriptions'),
      );
      return _commandResult(
        PaymentOperationResult.failure(
          status: opened
              ? PaymentOperationStatus.success
              : PaymentOperationStatus.storeFailure,
        ),
      );
    } catch (_) {
      return _commandResult(
        const PaymentOperationResult.failure(
          status: PaymentOperationStatus.storeFailure,
        ),
      );
    }
  }

  PaywallCommandResult _alreadyInProgress() {
    return PaywallCommandResult(
      status: PaymentOperationStatus.operationAlreadyInProgress,
      entitlement: _lastKnownEntitlement,
      errorMessage: 'A purchase or restore is already in progress.',
    );
  }

  PaywallCommandResult _commandResult(PaymentOperationResult operation) {
    return PaywallCommandResult(
      status: operation.status,
      entitlement: operation.confirmedEntitlement ?? _lastKnownEntitlement,
      errorMessage: _errorMessage(operation.status),
    );
  }

  Entitlement get _lastKnownEntitlement =>
      _gateway.cachedEntitlement ?? const Entitlement.free();

  String? _errorMessage(PaymentOperationStatus status) {
    return switch (status) {
      PaymentOperationStatus.success ||
      PaymentOperationStatus.noActiveSubscription ||
      PaymentOperationStatus.userCancelled =>
        null,
      PaymentOperationStatus.networkFailure =>
        "You need a connection to subscribe. Try again when you're "
            'back online.',
      PaymentOperationStatus.operationAlreadyInProgress =>
        'A purchase or restore is already in progress.',
      PaymentOperationStatus.storeFailure =>
        "Google Play couldn't complete this purchase. Try again.",
      PaymentOperationStatus.entitlementNotActive ||
      PaymentOperationStatus.revenueCatFailure ||
      PaymentOperationStatus.configurationFailure ||
      PaymentOperationStatus.developerFailure ||
      PaymentOperationStatus.unknownFailure =>
        "We couldn't confirm your subscription. Try again.",
    };
  }
}

class PaywallCommandResult {
  const PaywallCommandResult({
    required this.entitlement,
    this.status = PaymentOperationStatus.success,
    this.errorMessage,
  });

  final Entitlement entitlement;
  final PaymentOperationStatus status;
  final String? errorMessage;

  PaymentResult get result =>
      PaymentOperationResult.failure(status: status).result;
}
