import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/presentation/notification_tap_handler.dart';

class NotificationTapRouter extends StatefulWidget {
  const NotificationTapRouter({
    required this.gateway,
    required this.router,
    required this.child,
    required this.now,
    super.key,
  });

  final NotificationsGateway gateway;
  final GoRouter router;
  final Widget child;
  final DateTime Function() now;

  @override
  State<NotificationTapRouter> createState() => _NotificationTapRouterState();
}

class _NotificationTapRouterState extends State<NotificationTapRouter> {
  late NotificationTapHandler _handler;
  StreamSubscription<String?>? _subscription;

  @override
  void initState() {
    super.initState();
    _handler = const NotificationTapHandler();
    _subscription =
        widget.gateway.notificationTapPayloads.listen(_openPayloadRoute);
    unawaited(_openInitialPayload());
  }

  @override
  void didUpdateWidget(NotificationTapRouter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handler = const NotificationTapHandler();
    if (oldWidget.gateway == widget.gateway) return;
    unawaited(_subscription?.cancel());
    _subscription =
        widget.gateway.notificationTapPayloads.listen(_openPayloadRoute);
    unawaited(_openInitialPayload());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _openInitialPayload() async {
    final payload = await widget.gateway.initialNotificationTapPayload();
    if (!mounted || payload == null) return;
    _openPayloadRoute(payload);
  }

  void _openPayloadRoute(String? payload) {
    final target = _handler.targetFor(payload);
    if (target == '/settings/pro') {
      unawaited(widget.router.push<void>(target));
    } else {
      widget.router.go(target);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
