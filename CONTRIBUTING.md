# Contributing

## Firebase setup

Spec 1 can run in a limited local mode without generated Firebase options. Real Firebase SDK initialization starts after the project owner creates the Firebase projects and runs FlutterFire configuration.

Run these from the repo root after `firebase login`:

```bash
flutterfire configure \
  --project=cse-cet-reviewer-dev \
  --out=lib/firebase_options_dev.dart \
  --android-package-name=com.aerol.csecet.dev

flutterfire configure \
  --project=cse-cet-reviewer-prod \
  --out=lib/firebase_options_prod.dart \
  --android-package-name=com.aerol.csecet
```

The generated Android files belong under:

- `android/app/src/dev/google-services.json`
- `android/app/src/prod/google-services.json`

Do not hand-write placeholder API keys. Commit only generated files from the real Firebase projects.

## App Check

Development builds use Firebase App Check debug provider. Run the dev flavor once:

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

Copy the generated App Check debug token from the console output, then register it in Firebase Console under the dev project App Check Android app. CI devices need their own named debug token.

Production Android builds use Play Integrity in the prod Firebase project. Enable Play Integrity only after the Play Console app exists and the prod package `com.aerol.csecet` is registered.
