import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

final _failed = ValueNotifier<bool>(false);
VoidCallback? _onRetry;
int _hosts = 0;

void _retry() {
  _failed.value = false;
  _onRetry?.call();
}

/// Debug preserves framework diagnostics. Release moves child failures to the
/// app root, where the approved full-screen state has bounded page constraints.
void installAppErrorRecovery({
  required VoidCallback onRetry,
  bool releaseMode = kReleaseMode,
}) {
  if (!releaseMode) return;
  _failed.value = false;
  _onRetry = onRetry;
  ErrorWidget.builder = (details) {
    if (_hosts > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hosts > 0) _failed.value = true;
      });
      // The broken child's constraints may be unbounded. Its root host presents
      // the state on the next frame; no error screen is laid out inside a row.
      return const SizedBox.shrink();
    }
    return MaterialApp(
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      home: StateView.fullScreen(error: details.exception, onRetry: _retry),
    );
  };
}

class AppErrorRecovery extends StatefulWidget {
  const AppErrorRecovery({required this.child, super.key});
  final Widget child;

  @override
  State<AppErrorRecovery> createState() => _AppErrorRecoveryState();
}

class _AppErrorRecoveryState extends State<AppErrorRecovery> {
  @override
  void initState() {
    super.initState();
    _hosts++;
  }

  @override
  void dispose() {
    _hosts--;
    if (_hosts == 0) _failed.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: _failed,
        builder: (context, failed, _) =>
            failed ? const StateView.fullScreen(onRetry: _retry) : widget.child,
      );
}
