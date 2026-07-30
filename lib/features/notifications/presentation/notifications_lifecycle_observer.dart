import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pantas/core/notifications/notification_service.dart';

typedef NotificationsPeriodicStarter = VoidCallback Function(
  Duration interval,
  VoidCallback callback,
);

class NotificationsLifecycleObserver extends WidgetsBindingObserver {
  NotificationsLifecycleObserver({
    required NotificationService service,
    DateTime Function()? now,
    NotificationsPeriodicStarter? startPeriodic,
  })  : _service = service,
        _now = now ?? DateTime.now,
        _startPeriodic = startPeriodic ?? _defaultStartPeriodic;

  final NotificationService _service;
  final DateTime Function() _now;
  final NotificationsPeriodicStarter _startPeriodic;

  DateTime? _currentForegroundDay;
  VoidCallback? _cancelDayBoundaryWatcher;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _currentForegroundDay = _dateOnly(_now());
        unawaited(_service.rescheduleForForeground());
        _cancelDayBoundaryWatcher ??= _startPeriodic(
          const Duration(minutes: 1),
          _checkForDayBoundary,
        );
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _cancelDayBoundaryWatcher?.call();
        _cancelDayBoundaryWatcher = null;
    }
  }

  void dispose() {
    _cancelDayBoundaryWatcher?.call();
    _cancelDayBoundaryWatcher = null;
  }

  void _checkForDayBoundary() {
    final today = _dateOnly(_now());
    if (_currentForegroundDay == today) return;
    _currentForegroundDay = today;
    unawaited(_service.rescheduleForForeground());
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static VoidCallback _defaultStartPeriodic(
    Duration interval,
    VoidCallback callback,
  ) {
    final timer = Timer.periodic(interval, (_) => callback());
    return timer.cancel;
  }
}
