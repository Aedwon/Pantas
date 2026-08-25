import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _manifestPath = 'android/app/src/main/AndroidManifest.xml';
const _backupRulesPath = 'android/app/src/main/res/xml/backup_rules.xml';
const _dataExtractionRulesPath =
    'android/app/src/main/res/xml/data_extraction_rules.xml';

const _privateDataDomains = <String>[
  'root',
  'file',
  'database',
  'sharedpref',
  'external',
  'device_root',
  'device_file',
  'device_database',
  'device_sharedpref',
];

void main() {
  late String manifest;

  setUpAll(() {
    manifest = File(_manifestPath).readAsStringSync();
  });

  test('main manifest owns required Android release permissions', () {
    for (final permission in <String>[
      'android.permission.INTERNET',
      'android.permission.POST_NOTIFICATIONS',
      'android.permission.RECEIVE_BOOT_COMPLETED',
      'android.permission.SCHEDULE_EXACT_ALARM',
    ]) {
      expect(
        _hasPermission(manifest, permission),
        isTrue,
        reason: 'Expected $permission in $_manifestPath',
      );
    }

    expect(
      _hasPermission(manifest, 'android.permission.USE_EXACT_ALARM'),
      isFalse,
    );
  });

  test('scheduled notification receivers exist and are not exported', () {
    for (final receiver in <String>[
      'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
      'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
    ]) {
      final tag = _receiverTag(manifest, receiver);
      expect(tag, contains('android:exported="false"'));
    }
  });

  test('boot receiver listens for documented reschedule actions', () {
    final block = _receiverBlock(
      manifest,
      'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
    );

    for (final action in <String>[
      'android.intent.action.BOOT_COMPLETED',
      'android.intent.action.MY_PACKAGE_REPLACED',
      'android.intent.action.QUICKBOOT_POWERON',
      'com.htc.intent.action.QUICKBOOT_POWERON',
    ]) {
      expect(block, contains('android:name="$action"'));
    }
  });

  test('Android OS backup and data extraction are explicitly disabled', () {
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });

  test('legacy backup rules exclude all app-private data domains', () {
    final source = File(_backupRulesPath).readAsStringSync();
    expect(source, contains('<full-backup-content>'));
    _expectAllDomainsExcluded(source);
  });

  test('Android 12+ rules exclude private state from backup and transfer', () {
    final source = File(_dataExtractionRulesPath).readAsStringSync();
    expect(source, contains('<data-extraction-rules>'));

    final cloudBackup = _elementBlock(source, 'cloud-backup');
    final deviceTransfer = _elementBlock(source, 'device-transfer');
    _expectAllDomainsExcluded(cloudBackup);
    _expectAllDomainsExcluded(deviceTransfer);
  });

  test('main manifest does not opt into permissive network security', () {
    expect(manifest, isNot(contains('android:usesCleartextTraffic="true"')));
    expect(manifest, isNot(contains('android:networkSecurityConfig=')));
  });
}

bool _hasPermission(String manifest, String permission) {
  return RegExp(
    '<uses-permission\\s+android:name="${RegExp.escape(permission)}"\\s*/?>',
  ).hasMatch(manifest);
}

String _receiverTag(String manifest, String receiverName) {
  final match = RegExp(
    '<receiver\\b[^>]*android:name="${RegExp.escape(receiverName)}"[^>]*>',
  ).firstMatch(manifest);
  expect(match, isNotNull, reason: 'Missing receiver $receiverName');
  return match!.group(0)!;
}

String _receiverBlock(String manifest, String receiverName) {
  final match = RegExp(
    '<receiver\\b[^>]*android:name="${RegExp.escape(receiverName)}"[^>]*>'
    '[\\s\\S]*?'</n    '</receiver>',
  ).firstMatch(manifest);
  expect(match, isNotNull, reason: 'Missing receiver block $receiverName');
  return match!.group(0)!;
}

String _elementBlock(String source, String elementName) {
  final match = RegExp(
    '<${RegExp.escape(elementName)}\\b[^>]*>[\\s\\S]*?</${RegExp.escape(elementName)}>',
  ).firstMatch(source);
  expect(match, isNotNull, reason: 'Missing <$elementName> block');
  return match!.group(0)!;
}

void _expectAllDomainsExcluded(String source) {
  for (final domain in _privateDataDomains) {
    expect(
      RegExp(
        '<exclude\\s+domain="$domain"\\s+path="\\."\\s*/>',
      ).hasMatch(source),
      isTrue,
      reason: 'Expected domain $domain to be excluded',
    );
  }
}
