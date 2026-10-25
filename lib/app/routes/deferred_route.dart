import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/state_view.dart';

/// Keeps route matching synchronous while its screen library loads.
class DeferredRoute extends StatefulWidget {
  const DeferredRoute({
    required this.loadLibrary,
    required this.builder,
    super.key,
  });

  final Future<void> Function() loadLibrary;
  final WidgetBuilder builder;

  @override
  State<DeferredRoute> createState() => _DeferredRouteState();
}

class _DeferredRouteState extends State<DeferredRoute> {
  late Future<void> _load = Future<void>.sync(widget.loadLibrary);

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            return widget.builder(context);
          }
          return Scaffold(
            body: snapshot.hasError
                ? StateView.fullScreen(
                    error: snapshot.error,
                    onRetry: () => setState(() {
                      _load = Future<void>.sync(widget.loadLibrary);
                    }),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: loadingFor(const AsyncLoading<void>()),
                  ),
          );
        },
      );
}
