import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';

void main() {
  test('shortcut hints name Cmd on a Mac or iPad and Ctrl elsewhere', () {
    for (final platform in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = platform;
      final apple =
          platform == TargetPlatform.macOS || platform == TargetPlatform.iOS;
      expect(commandKeyLabel, apple ? 'Cmd' : 'Ctrl', reason: '$platform');
    }
    debugDefaultTargetPlatformOverride = null;
  });
}
