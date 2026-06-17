# Pantas

A gamified, learning-focused Flutter mobile reviewer for Philippine exam preparation. Launch scope: Civil Service Examination (Professional level) and UPCAT, expanding to cover six major Philippine exams. 

Learn more and view your personalized Wrapped cards at [pantas.app](https://pantas.app).

## Status

Active development. Pre-launch (Android-first).

## Features

### Core learning engine
- **Spaced repetition:** Schedules review questions for long-term memory.
- **Quiz modes:** Includes quick review, weak spots, deep dive, and custom quizzes.
- **Assessment:** A baseline test to measure starting aptitude.
- **Study plans:** Daily tasks generated from the chosen exam and target date.
- **Lesson reader:** Native reader with math rendering, illustrations, and embedded questions.

### Mock exams
- **Blueprint sampling:** Mock exams pull from subject ratios and weights used in official tests.
- **Test UI:** OMR-style sheet views to mirror physical exams.
- **Session state:** Exams can be paused, resumed, and reviewed later.

### Analytics
- **Progress:** Panels showing trend charts, score impact, and weakness analysis.
- **Archetypes:** Classifies users into study personality types.
- **Wrapped:** Shareable 9:16 cards generated for streak milestones and post-mock recaps.
- **Habits:** Daily streaks and day-of-week heatmaps.

### Infrastructure
- **Offline support:** Local Drift (SQLite) database allows full use without a network connection.
- **Sync:** Firebase handles cross-device merging of local progress.
- **Content updates:** Lessons and questions fetch dynamically from Sanity CMS.
- **Compliance:** SQLCipher local encryption, age gating, and RA10173 data export and deletion workflows.
- **Notifications:** Local and push alerts for reminders and streak thresholds.

### Accounts and billing
- **Pro tier:** RevenueCat controls access to analytical insights and premium content. SKUs are weekly, monthly, yearly, and lifetime.
- **Onboarding:** Supports anonymous purchase. Defers Google and Apple sign-in.
- **Contextual paywall:** Recommends the subscription length that matches the user's exam date.

## Architecture

See `docs/superpowers/specs/` for the complete design history, starting with the original app design (`2026-05-07-cse-cet-reviewer-app-design.md`) and extending through recent feature specs (Home, Study, Quiz, and Progress tabs). Implementation plans live in `docs/superpowers/plans/`.

## Tech stack

- **Frontend**: Flutter (3.41+) with Riverpod 2.x and go_router
- **Local Persistence**: Drift (SQLite) with SQLCipher for local encryption
- **Backend & Sync**: Firebase (Auth, Firestore, Functions, App Check, Crashlytics, Analytics, Remote Config, Cloud Messaging, Hosting) in region `asia-southeast1`
- **Content Management**: Sanity
- **In-App Purchases**: RevenueCat
- **Spaced Repetition**: FSRS algorithm for efficient study scheduling
- **Test stack**: `flutter_test`, `mocktail`, `integration_test`, `@firebase/rules-unit-testing`

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
  future/               # future projections and roadmaps
  superpowers/
    specs/              # design documents
    plans/              # implementation plans
    decisions/          # decision logs
    mockups/            # visual design assets
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
