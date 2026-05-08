# CSE/CET Reviewer

A gamified, learning-focused Flutter mobile reviewer for Philippine exam preparation. Launch scope: Civil Service Examination (Professional level) and UPCAT.

## Status

Pre-launch. Soft launch target: 2026-06-28.

## Architecture

See `docs/superpowers/specs/2026-05-07-cse-cet-reviewer-app-design.md` for the design document. Implementation plans live in `docs/superpowers/plans/`.

## Tech stack

- Flutter (3.41+) with Riverpod 2.x and go_router
- Drift (SQLite) with SQLCipher for local encryption
- Firebase: Auth, Firestore, Functions, App Check, Crashlytics, Analytics, Remote Config, Cloud Messaging, Hosting (region: `asia-southeast1`)
- Sanity for content management
- RevenueCat for in-app purchase
- Test stack: `flutter_test`, `mocktail`, `integration_test`, `@firebase/rules-unit-testing`

## Build flavors

- `dev` — default for development; uses `cse-cet-reviewer-dev` Firebase project
- `staging` — used for closed beta; shares dev Firebase project
- `prod` — production; uses `cse-cet-reviewer-prod`

Run dev:
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

## Repository layout

```
lib/
  app/                  # bootstrap, routing, theme
  core/                 # auth, sync, content, storage, network, fsrs, ...
  features/             # onboarding, home, quiz, lesson, review, mock_exam, ...
docs/
  superpowers/specs/    # design documents
  superpowers/plans/    # implementation plans
  PRIVACY.md            # privacy policy (v0 draft)
  TERMS.md              # terms of service (v0 draft)
  OPERATIONS.md         # status of long-pole launch items
tool/                   # local checks (layering, AI-attribution scan)
```

## Pre-commit

Install hooks once after cloning:
```bash
./tool/install_hooks.sh
```

This installs gitleaks scanning, AI-attribution check, layering check, and Dart format check.

## CI/CD

- Pull requests: lint, analyze, layering, tests, gitleaks, Semgrep, osv-scanner
- Main: above + integration tests + dev APK artifact
- Release tags (`v*`): unsigned prod artifacts; signed builds via Codemagic

## License

Proprietary. See `LICENSE`.
