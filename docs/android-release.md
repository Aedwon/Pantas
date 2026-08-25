# Android release

This document defines the production Android release path for Pantas. The canonical path is local, deterministic, signed, and non-publishing. Codemagic may run the same build contract when every external input has been provisioned, but it does not publish to Google Play.

## Repository prerequisites

The release repository must contain and retain these tracked settings:

- Flutter 3.41.9. Official stable tag: `3.41.9`. Framework ref: `00b0c91f06209d9e4a41f71b7a512d6eb3b9c694`. Release source: <https://docs.flutter.dev/install/archive> and <https://github.com/flutter/flutter/tree/3.41.9>.
- JDK 17.
- Gradle 8.14 through the standard tracked wrapper.
- Android Gradle Plugin 8.11.1.
- Kotlin 2.2.20.
- Flutter 3.41.9 supplies Android compile SDK 36 and target SDK 36. The final AAB must still be inspected numerically before Play upload.
- `android/gradlew`, `android/gradlew.bat`, `android/gradle/wrapper/gradle-wrapper.jar`, and `android/gradle/wrapper/gradle-wrapper.properties` are tracked release inputs.
- `.github/workflows/release.yml` is retired. GitHub Actions is not a release path.

The production flavor is `prod`, the application ID is `com.aedwon.pantas`, and the entrypoint is `lib/main_prod.dart`.

## External release inputs

These inputs are required for a real production build and are intentionally not stored in Git.

### Release version

Set both:

```bash
export RELEASE_VERSION_NAME='1.0.0'
export RELEASE_VERSION_CODE='1'
```

`RELEASE_VERSION_CODE` must be a positive integer. The canonical build passes it to Flutter as both `--build-number` and `--dart-define=BUILD_NUMBER=...`, so the Android `versionCode` and the runtime force-update build number cannot diverge inside this procedure.

### RevenueCat

Set the production Android public SDK key using the source contract exactly:

```bash
export REVENUECAT_ANDROID_API_KEY='...'
```

The release tooling does not accept the stale name `REVENUECAT_ANDROID_KEY`.

### Approved shipping content database

Place the externally approved database at:

```text
assets/seed/content.db
```

Then provide its complete approved SHA-256:

```bash
export APPROVED_CONTENT_DB_SHA256='64-lowercase-or-uppercase-hex-characters'
```

The release path never generates this database. Preflight hashes the actual file, compares the complete digest, and then checks that the digest begins with the tracked `contentSeedVersion` value from `lib/core/content/content_seed_version.dart`.

### Production Firebase Android config

Obtain the production `google-services.json` outside the repository. It must describe:

```text
Firebase project: pantas-prod
Android package: com.aedwon.pantas
```

Point the release procedure at that private file:

```bash
export PROD_FIREBASE_GOOGLE_SERVICES_JSON='/absolute/private/path/google-services.json'
```

Preflight validates the JSON before copying it to the ignored build location:

```text
android/app/src/prod/google-services.json
```

If the source is outside that location, the staged copy is removed when the release script exits. Routine release never runs `flutterfire configure`.

### Production upload signing

Never commit a keystore or passwords.

For local release, create ignored `android/key.properties` with these four properties:

```properties
storeFile=/absolute/private/path/pantas-upload.jks
storePassword=...
keyAlias=...
keyPassword=...
```

`storeFile` may also be a path relative to the `android/` directory. The production flavor uses only the `upload` signing configuration. There is no production debug-signing fallback.

Codemagic can provide all four secure inputs instead:

```text
CM_KEYSTORE_PATH
CM_KEYSTORE_PASSWORD
CM_KEY_ALIAS
CM_KEY_PASSWORD
```

If any Codemagic signing variable is set, all four are required. `CM_KEYSTORE_PATH` must point to the securely provisioned keystore file.

If no upload key exists yet, generate one only on a trusted local machine and keep at least two secure backups. A typical JDK 17 command is:

```bash
keytool -genkeypair -v \
  -keystore /absolute/private/path/pantas-upload.jks \
  -alias pantas-upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Do not put the keystore or its passwords in the repository, chat logs, CI logs, or shared notes.

## Local preflight

Run from an isolated worktree on the release branch.

First confirm repository and toolchain state:

```bash
git status --short
flutter --version
java -version
cd android && ./gradlew --version && cd ..
```

Expected release toolchain:

```text
Flutter 3.41.9
Flutter ref 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
JDK 17
Gradle 8.14
AGP 8.11.1
```

The canonical release script performs the strict preflight itself. It fails before `flutter build appbundle` when required release inputs are missing or invalid.

## Build

With every external input set and the approved private files present, run:

```bash
bash tools/release/android/release.sh
```

After preflight passes, the script performs normal Flutter build preparation:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

It then builds the production bundle with the equivalent of:

```bash
flutter build appbundle \
  --release \
  --flavor prod \
  --target lib/main_prod.dart \
  --build-name "$RELEASE_VERSION_NAME" \
  --build-number "$RELEASE_VERSION_CODE" \
  --dart-define=BUILD_NUMBER="$RELEASE_VERSION_CODE" \
  --dart-define=REVENUECAT_ANDROID_API_KEY="$REVENUECAT_ANDROID_API_KEY"
```

Expected bundle:

```text
build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

Resource shrinking is intentionally not enabled in this first internal-track wave. Normal Flutter release R8 behavior remains in place. No speculative ProGuard rules are added.

## Artifact verification

Do not treat a successful build as final Play readiness. Verify the exact AAB that will be uploaded.

At minimum record its digest:

```bash
shasum -a 256 build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

The final verifier must also inspect and record:

- production application ID;
- numeric min SDK, compile SDK, and target SDK, with target SDK at least 36;
- version name and version code;
- actual production signing certificate and upload-certificate SHA-256;
- `bundletool validate` result;
- final merged manifest, permissions, providers, and components;
- production Firebase configuration;
- native ABI inventory and 64-bit support;
- 16 KB native-page compatibility;
- resolved BillingClient version;
- R8 mapping evidence;
- native-symbol evidence where produced;
- final AAB SHA-256.

When R8 emits a mapping file, preserve:

```text
build/app/outputs/mapping/prodRelease/mapping.txt
```

Inspect native libraries from the built artifact before release. Preserve any symbol artifacts produced by the Flutter/Android build alongside the release evidence.

## Codemagic

`codemagic.yaml` pins Flutter 3.41.9 and JDK 17 for the Android release workflow. The Android workflow calls the same `tools/release/android/release.sh` procedure and has no Google Play publishing block.

Codemagic does not invent a content-delivery mechanism. A build is expected to fail until an approved `assets/seed/content.db`, its approved digest, the production Firebase JSON, RevenueCat key, version values, and signing inputs have been provisioned externally.

## Play Console / user actions

The release tooling intentionally stops at a verified local AAB. A human release owner must:

1. complete the final artifact-verification checklist above;
2. confirm the upload certificate matches the Play Console registration;
3. choose the intended Play track and release notes;
4. upload the already verified AAB in Play Console;
5. review Play Console warnings and resolved manifest/device compatibility information before rollout.

No Play upload is authorized by this repository tooling.

## Explicit non-actions

The Android release tooling never:

- regenerates shipping content;
- calls `tools/build_content_export/**`, `tools/build_content_seed/**`, or `tools/build_dev_seed/**`;
- runs `flutterfire configure`;
- publishes to Google Play;
- commits production Firebase credentials;
- commits keystores or passwords;
- prints signing passwords or private key data;
- silently uses debug signing for `prodRelease`;
- enables resource shrinking in this wave.
