import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// Keeps route matching synchronous while its screen library loads.
class DeferredRoute extends StatefulWidget {
  const DeferredRoute({
    required this.loadLibrary,
    required this.builder,
    this.cacheKey,
    super.key,
  });

  final Future<void> Function() loadLibrary;
  final WidgetBuilder builder;

  /// Names the library. Once a route with this key has loaded it, the next
  /// route with the same key builds its screen on its first frame. Without it
  /// every route shows one frame of loading, which would flash over a page
  /// that is meant to stay still (Settings on wide web).
  final Object? cacheKey;

  static final Set<Object> _loaded = {};

  @override
  State<DeferredRoute> createState() => _DeferredRouteState();
}

class _DeferredRouteState extends State<DeferredRoute> {
  late Future<void> _load = _start();

  Future<void> _start() async {
    await widget.loadLibrary();
    final key = widget.cacheKey;
    if (key != null) DeferredRoute._loaded.add(key);
  }

  bool get _alreadyLoaded =>
      widget.cacheKey != null &&
      DeferredRoute._loaded.contains(widget.cacheKey);

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _load,
        builder: (context, snapshot) {
          if (_alreadyLoaded ||
              (snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError)) {
            return widget.builder(context);
          }
          return FirstScreenReady(
            ready: snapshot.hasError,
            child: Scaffold(
              body: snapshot.hasError
                  ? StateView.fullScreen(
                      error: snapshot.error,
                      onRetry: () => setState(() {
                        _load = _start();
                      }),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(PantasSpace.s24),
                      child: loadingFor(const AsyncLoading<void>()),
                    ),
            ),
          );
        },
      );
}
