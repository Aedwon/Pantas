import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app code never registers FCM tokens or message handlers', () {
    final offenders = <String>[];
    final forbidden = [
      'FirebaseMessaging.instance.getToken',
      '.getToken(',
      'subscribeToTopic',
      'onBackgroundMessage',
      'onMessage.listen',
      'onMessageOpenedApp.listen',
    ];

    for (final file in _dartFiles('lib')) {
      final source = file.readAsStringSync();
      if (forbidden.any(source.contains)) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });

  test('functions do not add notification sender or device token storage', () {
    final offenders = <String>[];
    final forbidden = RegExp(
      r'(sendMulticast|sendEachForMulticast|fcmToken|deviceTokens|/devices/)',
    );

    for (final file in _files('functions/src')) {
      final source = file.readAsStringSync();
      if (forbidden.hasMatch(source)) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });

  test('notifications implementation does not sync content database', () {
    final offenders = _dartFiles('lib/features/notifications')
        .where((file) => file.readAsStringSync().contains('ContentDatabase'))
        .map((file) => file.path)
        .toList();

    expect(offenders, isEmpty);
  });
}

Iterable<File> _dartFiles(String path) {
  return _files(path).where((file) => file.path.endsWith('.dart'));
}

Iterable<File> _files(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return const [];
  return dir.listSync(recursive: true).whereType<File>();
}
