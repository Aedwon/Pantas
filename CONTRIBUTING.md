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

## Content authoring discipline

Sanity content is immutable-by-id for learner-facing meaning. If a question's correct answer, topic, exam coverage, or core meaning changes, retire the existing document with `isActive: false` and publish a replacement document with a new `_id`.

Small typo fixes are allowed in place when they do not change correctness. Past attempts and spaced-repetition state are tied to content IDs, so changing meaning in place can corrupt a learner's history.

Every Sanity doctype used by the app carries an integer `schemaVersion`. Bump `schemaVersion` whenever a document contract changes, then update `lib/core/content/sanity/schema_versions.dart` in the same implementation. The app rejects mismatched docs and keeps the cached row.

Use stable Sanity `_id` values for seeded launch content. Existing pre-launch user-data may reference those IDs, so preserve IDs when moving content from `assets/seed/v1.json` into Sanity.
