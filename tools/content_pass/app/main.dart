import 'package:flutter/material.dart';

import 'api.dart';
import 'chrome.dart';
import 'databases.dart';
import 'review_controller.dart';

/// Entry point of the Content Pass viewer.
///
/// Built with `flutter build web -t tools/content_pass/app/main.dart`. The
/// local server serves this page, the manifest, the notes and the content
/// database. No sign-in, no Firebase and no other network.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // A Material app supplies the localizations, overlay and text-field
  // support the reviewer chrome needs. Real screens run in their own app.
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _Loader(),
    ),
  );
}

class _Loader extends StatefulWidget {
  const _Loader();

  @override
  State<_Loader> createState() => _LoaderState();
}

class _LoaderState extends State<_Loader> {
  final _api = ContentPassApi();
  ReviewController? _controller;
  ReviewDatabases? _databases;
  String _message = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _error = null);
    try {
      while (true) {
        final state = await _api.state();
        final phase = state['phase'];
        if (phase == 'ready') break;
        final message = '${state['message'] ?? ''}';
        if (phase == 'error') {
          setState(() => _error = message);
          return;
        }
        setState(() => _message = message);
        await Future<void>.delayed(const Duration(milliseconds: 700));
      }
      setState(() => _message = 'Opening the content');
      final databases = await ReviewDatabases.open(await _api.contentDb());
      final controller = ReviewController(api: _api, databases: databases);
      await controller.load(query: Uri.base.queryParameters);
      setState(() {
        _databases = databases;
        _controller = controller;
      });
    } on Object catch (e) {
      setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final databases = _databases;
    if (controller != null && databases != null) {
      return ReviewShell(
        controller: controller,
        databases: databases,
        api: _api,
      );
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFFF4F4F2),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error == null ? 'Loading content' : "Can't load the content",
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 15,
                  color: Color(0xFF1D1D1B),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error ?? _message,
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  color: Color(0xFF74746F),
                  decoration: TextDecoration.none,
                ),
              ),
              if (_error != null)
                TextButton(onPressed: _start, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}
