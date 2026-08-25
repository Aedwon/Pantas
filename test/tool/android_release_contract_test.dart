import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String readRepositoryFile(String path) => File(path).readAsStringSync();

void main() {
  group('Android production release contract', () {
    test('prod release cannot silently use debug signing', () {
      final gradle = readRepositoryFile('android/app/build.gradle.kts');

      expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
      expect(gradle, contains('create("upload")'));
      expect(gradle,
          contains('signingConfig = signingConfigs.getByName("upload")'));
      expect(gradle, contains('Production release signing is required.'));
      expect(gradle, contains('CM_KEYSTORE_PATH'));
      expect(gradle, contains('CM_KEYSTORE_PASSWORD'));
      expect(gradle, contains('CM_KEY_ALIAS'));
      expect(gradle, contains('CM_KEY_PASSWORD'));
      expect(gradle, contains('rootProject.file("key.properties")'));
    });

    test('standard Gradle wrapper is tracked and pinned to 8.14', () {
      final wrapperProperties = readRepositoryFile(
        'android/gradle/wrapper/gradle-wrapper.properties',
      );
      final androidGitignore = readRepositoryFile('android/.gitignore');

      expect(wrapperProperties, contains('gradle-8.14-all.zip'));
      expect(File('android/gradlew').existsSync(), isTrue);
      expect(File('android/gradlew.bat').existsSync(), isTrue);
      expect(
        File('android/gradle/wrapper/gradle-wrapper.jar').existsSync(),
        isTrue,
      );
      expect(androidGitignore, isNot(contains('\n/gradlew\n')));
      expect(androidGitignore, isNot(contains('\n/gradlew.bat\n')));
      expect(androidGitignore, isNot(contains('gradle-wrapper.jar\n')));
    });

    test('release tooling requires the stable external input contract', () {
      final release = readRepositoryFile('tools/release/android/release.sh');

      for (final variable in <String>[
        'RELEASE_VERSION_NAME',
        'RELEASE_VERSION_CODE',
        'REVENUECAT_ANDROID_API_KEY',
        'APPROVED_CONTENT_DB_SHA256',
        'PROD_FIREBASE_GOOGLE_SERVICES_JSON',
      ]) {
        expect(release, contains('require_env $variable'));
      }
      expect(release, isNot(contains('REVENUECAT_ANDROID_KEY')));
      expect(release, contains('assets/seed/content.db'));
      expect(
        release,
        contains('lib/core/content/content_seed_version.dart'),
      );
    });

    test('release code is synchronized with runtime BUILD_NUMBER', () {
      final release = readRepositoryFile('tools/release/android/release.sh');

      expect(
        release,
        contains('--build-number "\$RELEASE_VERSION_CODE"'),
      );
      expect(
        release,
        contains('--dart-define=BUILD_NUMBER="\$RELEASE_VERSION_CODE"'),
      );
      expect(
        release,
        contains('--build-name "\$RELEASE_VERSION_NAME"'),
      );
    });

    test('canonical AAB command uses prod and the production entrypoint', () {
      final release = readRepositoryFile('tools/release/android/release.sh');

      expect(release, contains('flutter build appbundle'));
      expect(release, contains('--release'));
      expect(release, contains('--flavor prod'));
      expect(release, contains('--target lib/main_prod.dart'));
      expect(
        release,
        contains(
          '--dart-define=REVENUECAT_ANDROID_API_KEY="\$REVENUECAT_ANDROID_API_KEY"',
        ),
      );
    });

    test('normal Flutter code generation runs without content generation', () {
      final release = readRepositoryFile('tools/release/android/release.sh');

      expect(release, contains('flutter pub get --enforce-lockfile'));
      expect(
        release.split(Platform.lineTerminator),
        isNot(contains('flutter pub get')),
      );
      expect(
        release,
        contains('dart run build_runner build --delete-conflicting-outputs'),
      );
      expect(release, contains('flutter gen-l10n'));
      expect(release, isNot(contains('tools/build_content_export')));
      expect(release, isNot(contains('tools/build_content_seed')));
      expect(release, isNot(contains('tools/build_dev_seed')));
    });

    test('production Firebase config is validated and staged safely', () {
      final release = readRepositoryFile('tools/release/android/release.sh');

      expect(release, contains('pantas-prod'));
      expect(release, contains('com.aedwon.pantas'));
      expect(
        release,
        contains('android/app/src/prod/google-services.json'),
      );
      expect(release, contains('project_info'));
      expect(release, contains('android_client_info'));
      expect(release, contains('cleanup_private_inputs'));
      expect(release, isNot(contains('flutterfire configure')));
    });

    test('release toolchain is pinned to Flutter 3.41.9 and JDK 17', () {
      final release = readRepositoryFile('tools/release/android/release.sh');
      final codemagic = readRepositoryFile('codemagic.yaml');
      final settings = readRepositoryFile('android/settings.gradle.kts');

      expect(release, contains('EXPECTED_FLUTTER_VERSION="3.41.9"'));
      expect(
        release,
        contains(
          'EXPECTED_FLUTTER_REF="00b0c91f06209d9e4a41f71b7a512d6eb3b9c694"',
        ),
      );
      expect(release, contains('EXPECTED_GRADLE_VERSION="8.14"'));
      expect(release, contains('EXPECTED_AGP_VERSION="8.11.1"'));
      expect(codemagic, contains('flutter: 3.41.9'));
      expect(codemagic, contains('java: 17'));
      expect(
        settings,
        contains('id("com.android.application") version "8.11.1"'),
      );
    });

    test('Codemagic is non-publishing and uses the production identity', () {
      final codemagic = readRepositoryFile('codemagic.yaml');

      expect(codemagic, contains('PACKAGE_NAME: "com.aedwon.pantas"'));
      expect(codemagic, isNot(contains('com.aedwon.csecetreviewer')));
      expect(
        codemagic,
        contains('bash tools/release/android/release.sh'),
      );
      expect(codemagic, isNot(contains('google_play:')));
    });

    test('GitHub tag release workflow is retired', () {
      expect(File('.github/workflows/release.yml').existsSync(), isFalse);
    });

    test('release tooling has no Play publishing or resource-shrinking path',
        () {
      final release = readRepositoryFile('tools/release/android/release.sh');
      final gradle = readRepositoryFile('android/app/build.gradle.kts');

      expect(release, isNot(contains('google_play')));
      expect(release, isNot(contains('fastlane')));
      expect(release, isNot(contains('playPublisher')));
      expect(gradle, isNot(contains('shrinkResources')));
      expect(gradle, isNot(contains('isShrinkResources')));
    });
  });
}
