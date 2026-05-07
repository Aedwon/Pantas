# Plan 1 — Foundation & Ops Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Lay a green-field Flutter codebase, three managed-service projects (Firebase, Sanity, RevenueCat), CI/CD pipeline, and the long-pole operational items (NPC registration, store accounts, pentest booking) so all downstream plans can begin without blockers.

**Architecture:** Single-package Flutter app with strict `lib/core/` + `lib/features/` layering enforced by a custom Dart import-check script run in CI. Three build flavors (dev, staging, prod) wired through Android `build.gradle` product flavors and iOS xcconfig + schemes. Firebase project pair (dev + prod) in `asia-southeast1`. GitHub Actions for PR/main CI; Codemagic config committed for release signing (activated in Plan 8). All security tooling (gitleaks, Semgrep, osv-scanner) wired into CI from day one — no debt accrued.

**Tech Stack (locked from spec §2):** Flutter 3.27+, Dart, Riverpod 2.x, go_router, Drift, Freezed, dio, very_good_analysis. Firebase (Auth/Firestore/Functions/App Check/Crashlytics/Analytics/Remote Config/FCM/Hosting). Sanity. RevenueCat. GitHub Actions. Codemagic.

**Out of scope for this plan:** FSRS engine logic, sync engine logic, content schema definition, feature module UIs, Cloud Function business logic. Those land in Plans 2-6. This plan only scaffolds, configures, and unblocks.

**Constraints from project memory:**
- **No Claude/AI/Anthropic attribution** in any artifact (commits, code comments, README, contributor lists, PR descriptions). Verified at task 33.
- **PH-market context:** Bandwidth-constrained, peso pricing, prepaid culture. Drives offline-first defaults — but most of that lands in Plan 2.
- **Exam-agnostic architecture:** No exam IDs hardcoded anywhere in scaffolding. All exam config flows from content.

**Placeholders requiring user confirmation before Task 6:**
- **App bundle ID base:** `com.aedwon.csecetreviewer` (reverse-DNS of `aedwon.com`, owned by Aerol). Dev: `.dev` suffix, staging: `.staging` suffix, prod: bare.
- **Display name:** "CSE/CET Reviewer" (final marketing name TBD).
- **Package name:** `cse_cet_reviewer`.

---

## File Map

Files this plan creates or modifies (exact paths from project root `/Users/aedwon/Documents/Dev Projects/CSE:CET Reviewer App/`):

```
.gitignore
.gitleaks.toml
.github/workflows/ci.yml
.github/workflows/main.yml
.github/workflows/release.yml
.husky/pre-commit                  (or .git/hooks/pre-commit symlink)
analysis_options.yaml
codemagic.yaml
firebase.json
firestore.rules
firestore.indexes.json
.firebaserc
pubspec.yaml
README.md
LICENSE
docs/PRIVACY.md                    (v0 draft for legal review)
docs/TERMS.md                      (v0 draft for legal review)
docs/OPERATIONS.md                 (status tracker for Day-1 procedural items)
android/app/build.gradle           (Flutter-generated, then edited for flavors)
android/app/src/main/AndroidManifest.xml
ios/Runner/Info.plist              (Flutter-generated, then edited)
ios/Runner.xcodeproj/...           (flavors via schemes — manual Xcode step documented)
ios/Flutter/Dev.xcconfig
ios/Flutter/Staging.xcconfig
ios/Flutter/Prod.xcconfig
lib/main.dart                      (delegates to flavor-specific main)
lib/main_dev.dart
lib/main_staging.dart
lib/main_prod.dart
lib/app/app.dart
lib/app/bootstrap.dart
lib/app/router.dart
lib/app/theme.dart
lib/app/flavor.dart
lib/core/error/app_exception.dart
lib/core/error/result.dart
lib/core/error/error.dart           (barrel export)
test/app/app_boot_test.dart
test/core/error/result_test.dart
tool/check_layering.dart
tool/check_no_ai_attribution.dart
```

Files **NOT** created in this plan (deferred to later plans):
- `lib/core/fsrs/`, `lib/core/sync/`, `lib/core/storage/`, `lib/core/auth/` etc. — Plan 2.
- `lib/features/**` — Plans 5, 6.
- `functions/` (Cloud Functions) — Plan 3-4.
- `sanity/` (Sanity Studio) — Plan 4.

---

## Phase A — Day 1 Procedural (start in parallel, non-code)

These four tasks are long-pole external dependencies. Start them on day one of Plan 1; do not wait for code work to finish. Each one is tracked in `docs/OPERATIONS.md` (created in Task 32).

### Task 1: File NPC (National Privacy Commission) registration

**Files:**
- Track: `docs/OPERATIONS.md` (created in Task 32; for now, record outcome in a scratch note to merge in)

**Why this is task 1:** The spec §10.1 marks NPC registration as a 4-8 week long pole. No paid PH app collecting PII can launch without it. RA 10173 (PH Data Privacy Act 2012) penalties are personal-liability-bearing for the DPO.

- [ ] **Step 1: Open the NPC online registration portal**

Visit: `https://register.privacy.gov.ph/`

- [ ] **Step 2: Determine your registration category**

You are likely a **Personal Information Controller (PIC)** because the app determines purposes and means of processing personal data (display names, learning history, payment info via RevenueCat). Confirm by reading the NPC's PIC/PIP definitions on the portal.

- [ ] **Step 3: Prepare required information**

Capture this in a scratch note:
- Legal entity name (sole proprietor, partnership, or corporation — for v1 likely sole proprietor under your name)
- DTI/SEC registration number (if business-registered) — sole proprietors need DTI Business Name Registration first if not yet done
- Registered business address
- DPO designation: **you (Aerol Balayon)** for v1
- DPO email: a dedicated address, e.g. `dpo@aedwon.com` or `aerol.balayon+dpo@gmail.com` if no domain yet
- Description of data processing systems: "Mobile reviewer app collecting display name, learning attempts, and entitlement state. Payment processing via RevenueCat (PCI-DSS-compliant third party). Storage in Firebase Firestore (`asia-southeast1`)."
- Records of Processing Activities (ROPA) draft

- [ ] **Step 4: Submit registration**

Complete the portal forms with the prepared information.

- [ ] **Step 5: Capture confirmation**

Save the NPC reference number, submission timestamp, and any acknowledgment email to a local secure note. You will reference this in `docs/PRIVACY.md` and OPERATIONS.md.

- [ ] **Step 6: Calendar follow-up**

Set a reminder for **2026-05-21** (week 3) to check NPC status. Set another for **2026-06-04** (week 5) and **2026-06-18** (week 7). NPC processing takes 4-8 weeks; if not approved by 2026-06-25, the launch slips per spec §10.2.

- [ ] **Step 7: No commit**

This task produces no git artifact yet; status is recorded later in `docs/OPERATIONS.md` (Task 32).

---

### Task 2: Apple Developer Program enrollment

**Files:** none (procedural)

- [ ] **Step 1: Visit `https://developer.apple.com/programs/enroll/`**

- [ ] **Step 2: Sign in with the Apple ID you intend to use as the developer account**

This Apple ID becomes the team owner. Use one with a strong unique password and 2FA already enabled. Do not use a personal-only Apple ID if you plan to accept revenue payouts to a business account later — switching is hard.

- [ ] **Step 3: Choose entity type**

- **Individual** ($99/yr): faster approval (often hours-to-days). Apps publish under your legal name. Sufficient for v1.
- **Organization** ($99/yr): publishes under a business name. Requires DUNS number (free but takes 1-5 business days to issue if you don't have one).

For June launch with no existing DUNS, choose Individual. You can transfer to Organization later (App Store supports app transfers).

- [ ] **Step 4: Complete enrollment**

Pay the $99 USD annual fee with a credit card. Apple may require ID verification — have your government ID ready.

- [ ] **Step 5: Capture team ID**

Once enrolled, find your Team ID at `https://developer.apple.com/account/#MembershipDetailsView`. Record it; you will need it for code signing in Task 27 and bundle ID setup in Task 6.

- [ ] **Step 6: Enable App Store Connect access**

Visit `https://appstoreconnect.apple.com/`. The same Apple ID auto-grants access. Capture the URL bookmark.

- [ ] **Step 7: Calendar follow-up**

If approval is not instant, expect 24-48 hours. Set a follow-up for **2026-05-09**.

---

### Task 3: Google Play Console account

**Files:** none (procedural)

- [ ] **Step 1: Visit `https://play.google.com/console/signup`**

- [ ] **Step 2: Pay one-time $25 USD registration fee**

Use the Google account you intend to be the developer account owner. As with Apple, use a strong unique password + 2FA, ideally on a hardware key (per spec §8 "Operational security: Firebase admin access on hardware security keys").

- [ ] **Step 3: Choose account type**

- **Personal:** publishes under your name.
- **Organization:** requires a DUNS number, more verification.

For June launch, **Personal** is fine.

- [ ] **Step 4: Identity verification**

Google now requires government ID + verified phone for new accounts. Allow 24-48 hours; sometimes requires resubmission. Address verification can take an additional 1-3 days.

- [ ] **Step 5: Capture developer account info**

After approval, capture:
- Developer name (as shown on Play)
- Account ID
- API access status (you'll enable this in Plan 8 for Codemagic uploads)

- [ ] **Step 6: Calendar follow-up**

Set follow-ups for **2026-05-10** and **2026-05-14**. If verification has not completed by 2026-05-21, escalate via Play Console support.

---

### Task 4: Engage external pentester for Week 6 (June 11-17)

**Files:** none (procedural)

**Why now:** Per spec §10.1 / §10.3 pentest is non-negotiable and good firms book out 4-6 weeks ahead. Booking on Day 1 secures a Week 6 slot.

- [ ] **Step 1: Shortlist 3 PH-based security firms**

Recommended starting list (verify currency yourself; confirm scope/insurance/methodology):
- Secuna (Manila) — bug-bounty-style + scoped engagements
- Pandora Security Labs — application security
- Sec Consult Philippines (or local equivalent)

Open-call alternative: post a scoped RFP to `bugcrowd.com/programs` for a managed engagement.

- [ ] **Step 2: Prepare scope statement**

Draft a one-page statement matching spec §7.5:
```
Engagement: Mobile (iOS + Android) and backend security assessment for
[App Name] — a Flutter mobile reviewer app with Firebase backend.
Methodology: OWASP MASVS L1+L2, OWASP Top 10 Mobile, Firebase Security
  Rules review, Cloud Functions review.
Scope:
  • Authentication flow (Anonymous, Apple, Google) including anon→named
    migration
  • Firebase Security Rules (per-user scoping, server-only fields)
  • Cloud Functions (RevenueCat webhook, entitlement claim writes)
  • In-app purchase flow + entitlement enforcement
  • Local data storage (SQLCipher key handling, Keychain/Keystore use)
  • App Check enforcement
  • Data classification handling per design doc §3.4
Out of scope: Sanity CMS infrastructure (managed by vendor); RevenueCat
  internals; iOS/Android OS vulnerabilities.
Duration: 5 business days (compressed) to 10 business days (full).
Window: 2026-06-11 to 2026-06-17.
Deliverable: Findings report with CVSS scores, reproduction steps, and
  remediation guidance. Critical/High issues blocking launch.
Budget: ₱30,000-₱60,000 (per design doc §7.5).
NDA required before scope details shared beyond this summary.
```

- [ ] **Step 3: Send RFP to all three firms**

Email template:
```
Subject: Pentest engagement request for week of June 11, 2026

Hi <firm>,

I'm preparing to soft-launch a Flutter mobile app (CSE/CET exam reviewer
for the PH market) on June 28, 2026, and I'd like to engage your team
for a security assessment in the week of June 11-17.

Attached is my one-page scope. Could you reply with:
  1. Availability for that window
  2. Indicative pricing for 5-day vs 10-day engagement
  3. Sample anonymized report
  4. NDA we'd need before deeper scope discussion

Thanks,
Aerol Balayon
aerol.balayon@gmail.com
```

- [ ] **Step 4: Set up evaluation calendar**

Set a 2-day evaluation window: **2026-05-08 to 2026-05-09**. Pick the firm by 2026-05-10 and sign by 2026-05-12.

- [ ] **Step 5: Calendar follow-up**

Set reminders for **2026-05-09** (responses received), **2026-05-10** (decision), **2026-05-12** (contract signed).

---

## Phase B — Codebase Scaffold

### Task 5: Initialize git repository and commit this plan

**Files:**
- Create: `.gitignore`

- [ ] **Step 1: Verify git is installed**

Run from project root:
```bash
git --version
```
Expected: `git version 2.x` or higher.

- [ ] **Step 2: Initialize repo**

```bash
cd "/Users/aedwon/Documents/Dev Projects/CSE:CET Reviewer App"
git init
git branch -M main
```
Expected: `Initialized empty Git repository...` and `main` becomes default branch.

- [ ] **Step 3: Create `.gitignore` with Flutter + Firebase + macOS defaults**

Write `/Users/aedwon/Documents/Dev Projects/CSE:CET Reviewer App/.gitignore`:
```gitignore
# macOS
.DS_Store

# IDE
.idea/
.vscode/
*.iml
*.swp

# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
android/.gradle/
android/captures/
android/local.properties
android/app/release/
**/Generated.xcconfig
**/flutter_export_environment.sh

# Codegen output (regenerated each build — do NOT commit)
**/*.g.dart
**/*.freezed.dart
**/*.gr.dart
**/*.config.dart

# Firebase
google-services.json
GoogleService-Info.plist
firebase_app_id_file.json
.firebase/

# Secrets
*.keystore
*.jks
*.p8
*.p12
*.mobileprovision
key.properties
fastlane/.env*
.env
.env.*

# Coverage
coverage/
*.lcov

# OS junk
Thumbs.db
ehthumbs.db
```

- [ ] **Step 4: Stage existing docs and the design spec**

```bash
git add .gitignore docs/superpowers/specs/ docs/superpowers/plans/
git status
```
Expected: shows `.gitignore`, the spec MD, and this plan MD as staged.

- [ ] **Step 5: First commit**

```bash
git commit -m "chore: initialize repo with design spec and foundation plan"
```
Expected: one commit on main. **Do not include any AI/Claude/Co-Authored-By trailer** (project memory rule).

- [ ] **Step 6: Verify no AI attribution in commit**

```bash
git log -1 --format="%B"
```
Expected: only the subject line above; no trailers.

---

### Task 6: Flutter project scaffold with flavors

**Files (created by `flutter create`, then modified):**
- Create: `pubspec.yaml`, `lib/main.dart`, `android/`, `ios/`, `test/widget_test.dart` (will be deleted in Task 14)
- Create: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`
- Modify: `android/app/build.gradle` (flavors)
- Create: `ios/Flutter/Dev.xcconfig`, `ios/Flutter/Staging.xcconfig`, `ios/Flutter/Prod.xcconfig`

- [ ] **Step 1: Confirm Flutter version**

```bash
flutter --version
```
Expected: `Flutter 3.27.0` or later, channel `stable`. If older, run `flutter upgrade` first.

- [ ] **Step 2: Confirm bundle ID base with user**

The plan placeholder is `com.aedwon.csecetreviewer`. If a different reverse-DNS is preferred, substitute below. Lowercase only, no hyphens (some store tooling rejects hyphens).

- [ ] **Step 3: Run `flutter create` in the existing project root**

```bash
cd "/Users/aedwon/Documents/Dev Projects/CSE:CET Reviewer App"
flutter create \
  --project-name cse_cet_reviewer \
  --org com.aedwon \
  --platforms=android,ios \
  --description "Gamified Philippine exam reviewer with spaced repetition." \
  .
```
Expected: Creates `lib/`, `android/`, `ios/`, `pubspec.yaml`, etc. The colon in the parent dir name is fine because Flutter operates on the current dir, not the absolute path.

- [ ] **Step 4: Replace `lib/main.dart` with a dispatcher**

Overwrite `lib/main.dart`:
```dart
// Default entry — defaults to dev. CI runs flavor-specific entries.
import 'main_dev.dart' as dev;

void main() => dev.main();
```

- [ ] **Step 5: Create flavor entrypoints**

Create `lib/main_dev.dart`:
```dart
import 'package:flutter/widgets.dart';
import 'app/bootstrap.dart';
import 'app/flavor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(Flavor.dev);
}
```

Create `lib/main_staging.dart`:
```dart
import 'package:flutter/widgets.dart';
import 'app/bootstrap.dart';
import 'app/flavor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(Flavor.staging);
}
```

Create `lib/main_prod.dart`:
```dart
import 'package:flutter/widgets.dart';
import 'app/bootstrap.dart';
import 'app/flavor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(Flavor.prod);
}
```

- [ ] **Step 6: Configure Android product flavors**

Open `android/app/build.gradle` and find the `android { ... }` block. Add inside it:
```groovy
    flavorDimensions "default"
    productFlavors {
        dev {
            dimension "default"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "CSE/CET Reviewer Dev"
        }
        staging {
            dimension "default"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "CSE/CET Reviewer Staging"
        }
        prod {
            dimension "default"
            resValue "string", "app_name", "CSE/CET Reviewer"
        }
    }
```

In the same `android { ... }` block, ensure `defaultConfig` does **not** also define `app_name` (`resValue`). Remove any duplicate `app_name` declaration.

In `android/app/src/main/AndroidManifest.xml`, change `android:label="cse_cet_reviewer"` (Flutter default) to `android:label="@string/app_name"`.

- [ ] **Step 7: Configure iOS xcconfigs**

Create `ios/Flutter/Dev.xcconfig`:
```
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_dev.dart
PRODUCT_BUNDLE_IDENTIFIER=com.aedwon.csecetreviewer.dev
DISPLAY_NAME=CSE/CET Reviewer Dev
```

Create `ios/Flutter/Staging.xcconfig`:
```
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_staging.dart
PRODUCT_BUNDLE_IDENTIFIER=com.aedwon.csecetreviewer.staging
DISPLAY_NAME=CSE/CET Reviewer Staging
```

Create `ios/Flutter/Prod.xcconfig`:
```
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_prod.dart
PRODUCT_BUNDLE_IDENTIFIER=com.aedwon.csecetreviewer
DISPLAY_NAME=CSE/CET Reviewer
```

- [ ] **Step 8: Create iOS schemes manually in Xcode**

Open `ios/Runner.xcworkspace` in Xcode → Product → Scheme → Manage Schemes → duplicate "Runner" three times → rename to `Runner-Dev`, `Runner-Staging`, `Runner-Prod`. For each, edit Build Configurations to point to the corresponding xcconfig (Project → Runner → Info → Configurations: add `Debug-Dev`, `Release-Dev`, `Profile-Dev` etc., each based on the matching xcconfig). This is documented because it cannot be scripted easily and must be redone if `ios/` is regenerated.

Document in `docs/OPERATIONS.md` (Task 32) that this manual step was completed.

- [ ] **Step 9: Smoke test dev flavor on Android**

```bash
flutter run --flavor dev -t lib/main_dev.dart
```
Expected: Default Flutter counter app launches (we replace it in Task 11). Bundle ID on device should be `com.aedwon.csecetreviewer.dev`. Stop the run with `q`.

- [ ] **Step 10: Commit**

```bash
git add pubspec.yaml lib/ android/ ios/ test/
git commit -m "feat: scaffold Flutter project with dev/staging/prod flavors"
```
Expected: commit succeeds.

---

### Task 7: Lock pubspec.yaml dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Replace generated `pubspec.yaml`**

Overwrite `pubspec.yaml` (preserve `name: cse_cet_reviewer` and adjust as below):
```yaml
name: cse_cet_reviewer
description: Gamified Philippine exam reviewer with spaced repetition.
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: '>=3.27.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State management & routing
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.0.0

  # Models / serialization
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Networking
  dio: ^5.7.0

  # Local persistence (used in Plan 2 — declared here to lock versions)
  drift: ^2.20.0
  sqlite3_flutter_libs: ^0.5.24
  sqlcipher_flutter_libs: ^0.6.4
  path_provider: ^2.1.4
  path: ^1.9.0

  # Firebase (initialized here; deeper integration in Plans 2-4)
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_analytics: ^11.3.3
  firebase_crashlytics: ^4.1.3
  firebase_remote_config: ^5.1.3
  firebase_messaging: ^15.1.3
  firebase_app_check: ^0.3.1+5
  cloud_functions: ^5.1.3

  # Auth providers
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.2

  # IAP via RevenueCat
  purchases_flutter: ^8.0.0

  # Secure storage (Keychain / Keystore)
  flutter_secure_storage: ^9.2.2

  # Util
  collection: ^1.19.0
  meta: ^1.15.0
  intl: ^0.20.0
  uuid: ^4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  # Lint
  very_good_analysis: ^6.0.0

  # Codegen
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.3
  drift_dev: ^2.20.0

  # Testing
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
  generate: true   # enables ARB-driven l10n in Plan 2+
```

- [ ] **Step 2: Resolve dependencies**

```bash
flutter pub get
```
Expected: `Got dependencies!` — note any version-resolution warnings (some packages may have transitive conflicts; if so, document and pin in a follow-up step).

- [ ] **Step 3: Verify no critical CVEs**

```bash
flutter pub outdated --mode=null-safety
```
Expected: a table of dependencies. We are not yet running osv-scanner (that lands in Task 26); this step is just a sanity check.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: lock dependencies for v1 stack"
```

---

### Task 8: Folder layout

**Files:**
- Create: directory tree under `lib/`
- Create: barrel files for stable boundaries

- [ ] **Step 1: Create `lib/` skeleton directories**

```bash
mkdir -p \
  lib/app \
  lib/core/auth \
  lib/core/sync \
  lib/core/content \
  lib/core/storage \
  lib/core/network \
  lib/core/telemetry \
  lib/core/entitlement \
  lib/core/fsrs \
  lib/core/error \
  lib/core/l10n \
  lib/features/onboarding/data \
  lib/features/onboarding/domain \
  lib/features/onboarding/presentation \
  lib/features/home/data \
  lib/features/home/domain \
  lib/features/home/presentation \
  lib/features/quiz/data \
  lib/features/quiz/domain \
  lib/features/quiz/presentation \
  lib/features/lesson/data \
  lib/features/lesson/domain \
  lib/features/lesson/presentation \
  lib/features/review/data \
  lib/features/review/domain \
  lib/features/review/presentation \
  lib/features/mock_exam/data \
  lib/features/mock_exam/domain \
  lib/features/mock_exam/presentation \
  lib/features/progress/data \
  lib/features/progress/domain \
  lib/features/progress/presentation \
  lib/features/paywall/data \
  lib/features/paywall/domain \
  lib/features/paywall/presentation \
  lib/features/settings/data \
  lib/features/settings/domain \
  lib/features/settings/presentation \
  lib/features/auth_flow/data \
  lib/features/auth_flow/domain \
  lib/features/auth_flow/presentation \
  lib/features/notifications/data \
  lib/features/notifications/domain \
  lib/features/notifications/presentation \
  lib/features/legal/data \
  lib/features/legal/domain \
  lib/features/legal/presentation \
  test/app \
  test/core/error \
  tool
```

Empty package directories will be filled in later plans.

- [ ] **Step 2: Add `.gitkeep` to empty directories**

Empty directories aren't tracked by git. Touch a `.gitkeep` in every leaf:
```bash
find lib/core lib/features -type d -empty -exec touch {}/.gitkeep \;
```
Expected: no output. Verify with `find lib -name .gitkeep | wc -l` — expect a non-zero count.

- [ ] **Step 3: Commit**

```bash
git add lib/ test/ tool/
git commit -m "chore: scaffold core/ and feature/ folder layout"
```

---

### Task 9: Strict analysis options

**Files:**
- Modify: `analysis_options.yaml` (Flutter creates a default; we replace it)

- [ ] **Step 1: Overwrite `analysis_options.yaml`**

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    invalid_annotation_target: ignore
    todo: ignore
    fixme: warning
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.config.dart"
    - "build/**"
    - "ios/**"
    - "android/**"

linter:
  rules:
    public_member_api_docs: false   # too noisy at scaffold stage; revisit after Plan 5
    avoid_print: true
    prefer_const_constructors: true
    sort_pub_dependencies: false    # pubspec is grouped by purpose, not alphabetized
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze
```
Expected: zero errors, zero warnings. The Flutter-generated counter app might trigger `prefer_const_constructors` on `MyApp` — if so, fix immediately (it gets replaced in Task 11 anyway, but we keep CI clean).

- [ ] **Step 3: Commit**

```bash
git add analysis_options.yaml
git commit -m "feat: enforce strict lint baseline (very_good_analysis + strict mode)"
```

---

### Task 10: Custom layering check Dart script

**Files:**
- Create: `tool/check_layering.dart`
- Create: `tool/check_no_ai_attribution.dart`

**Why a script, not an analyzer plugin:** `dart_code_metrics` is in flux; `custom_lint` adds heavy build-time cost. A 100-line Dart script is sufficient and trivially debuggable. CI runs it; pre-commit can too.

- [ ] **Step 1: Create `tool/check_layering.dart`**

```dart
// Enforces architectural import rules from spec §5.2.
//
// Rules:
//   R1: lib/core/** must NOT import from lib/features/**
//   R2: lib/features/X/** must NOT import from lib/features/Y/** (X != Y)
//   R3: lib/**/domain/** must NOT import flutter, firebase_*, drift, dio,
//       sqlite3_*, sqlcipher_*, path_provider, flutter_secure_storage,
//       google_sign_in, sign_in_with_apple, purchases_flutter,
//       cloud_firestore, firebase_auth, cloud_functions
//
// Exit code: 0 if clean, 1 if any violation (lists all violations first).
import 'dart:io';

const _domainForbiddenPackages = <String>{
  'flutter',
  'flutter_localizations',
  'flutter_riverpod',
  'riverpod_annotation',
  'go_router',
  'firebase_core',
  'firebase_auth',
  'cloud_firestore',
  'firebase_analytics',
  'firebase_crashlytics',
  'firebase_remote_config',
  'firebase_messaging',
  'firebase_app_check',
  'cloud_functions',
  'drift',
  'drift_dev',
  'sqlite3_flutter_libs',
  'sqlcipher_flutter_libs',
  'path_provider',
  'dio',
  'flutter_secure_storage',
  'google_sign_in',
  'sign_in_with_apple',
  'purchases_flutter',
};

final _importRegex = RegExp(
  r'''^\s*import\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

void main(List<String> args) {
  final violations = <String>[];
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('lib/ not found; run from project root.');
    exit(2);
  }

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.g.dart') ||
        entity.path.endsWith('.freezed.dart') ||
        entity.path.endsWith('.config.dart')) {
      continue;
    }

    final relPath = entity.path.replaceAll(r'\', '/');
    final src = entity.readAsStringSync();
    final imports = _importRegex
        .allMatches(src)
        .map((m) => m.group(1)!)
        .toList(growable: false);

    final inCore = relPath.startsWith('lib/core/');
    final inFeatures = relPath.startsWith('lib/features/');
    final inDomain = relPath.contains('/domain/');
    final featurePrefix = inFeatures ? _featureName(relPath) : null;

    for (final imp in imports) {
      // R1: core must not import features
      if (inCore && imp.contains('package:cse_cet_reviewer/features/')) {
        violations.add('R1 $relPath imports $imp');
      }

      // R2: features must not cross-import
      if (inFeatures &&
          imp.startsWith('package:cse_cet_reviewer/features/')) {
        final importedFeature = _featureFromImport(imp);
        if (importedFeature != null && importedFeature != featurePrefix) {
          violations.add('R2 $relPath imports $imp');
        }
      }

      // R3: domain must be pure Dart
      if (inDomain) {
        final pkg = _packageOf(imp);
        if (pkg != null && _domainForbiddenPackages.contains(pkg)) {
          violations.add('R3 $relPath imports $imp');
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('check_layering: OK');
    exit(0);
  }
  stderr.writeln('check_layering: ${violations.length} violation(s)');
  for (final v in violations) {
    stderr.writeln('  $v');
  }
  exit(1);
}

String? _featureName(String relPath) {
  final m = RegExp(r'^lib/features/([^/]+)/').firstMatch(relPath);
  return m?.group(1);
}

String? _featureFromImport(String imp) {
  final m = RegExp(r'^package:cse_cet_reviewer/features/([^/]+)/')
      .firstMatch(imp);
  return m?.group(1);
}

String? _packageOf(String imp) {
  final m = RegExp(r'^package:([^/]+)/').firstMatch(imp);
  return m?.group(1);
}
```

- [ ] **Step 2: Create `tool/check_no_ai_attribution.dart`**

```dart
// Enforces project memory rule: no AI/Claude/Anthropic attribution
// anywhere in the project. Scans tracked files for forbidden phrases.
//
// Forbidden patterns (case-insensitive substring match):
//   - "claude"
//   - "anthropic"
//   - "co-authored-by: claude"
//   - "generated with claude"
//   - "co-authored-by: ai"
//
// Exit code: 0 if clean, 1 if any match.
//
// Note: scans only files under git tracking, so user notes outside the
// repo are not affected.
import 'dart:io';

const _forbidden = <String>[
  'claude',
  'anthropic',
  'co-authored-by: ai',
  'generated with claude',
  'generated by claude',
];

const _excludePaths = <String>[
  'tool/check_no_ai_attribution.dart', // this file mentions the patterns
  '.git/',
  'docs/superpowers/specs/2026-05-07-cse-cet-reviewer-app-design.md', // ref §13
  'docs/superpowers/plans/',                                          // ref this plan
];

void main(List<String> args) async {
  final result = await Process.run('git', ['ls-files']);
  if (result.exitCode != 0) {
    stderr.writeln('git ls-files failed: ${result.stderr}');
    exit(2);
  }

  final files = (result.stdout as String).split('\n').where((s) => s.isNotEmpty);
  final hits = <String>[];

  for (final f in files) {
    if (_excludePaths.any(f.startsWith)) continue;
    final file = File(f);
    if (!file.existsSync()) continue;
    String contents;
    try {
      contents = file.readAsStringSync();
    } on FileSystemException {
      continue; // binary or unreadable
    }
    final lower = contents.toLowerCase();
    for (final pat in _forbidden) {
      if (lower.contains(pat)) {
        hits.add('$f contains "$pat"');
      }
    }
  }

  if (hits.isEmpty) {
    stdout.writeln('check_no_ai_attribution: OK');
    exit(0);
  }
  stderr.writeln('check_no_ai_attribution: ${hits.length} hit(s)');
  for (final h in hits) {
    stderr.writeln('  $h');
  }
  exit(1);
}
```

- [ ] **Step 3: Run both scripts to verify they pass on the empty scaffold**

```bash
dart run tool/check_layering.dart
dart run tool/check_no_ai_attribution.dart
```
Expected: both print `OK` and exit 0.

- [ ] **Step 4: Commit**

```bash
git add tool/
git commit -m "feat: add layering check and AI-attribution check scripts"
```

---

### Task 11: Sealed AppException hierarchy + Result type

**Files:**
- Create: `lib/core/error/app_exception.dart`
- Create: `lib/core/error/result.dart`
- Create: `lib/core/error/error.dart` (barrel)
- Create: `test/core/error/result_test.dart`

**Why TDD here:** This is `core/`; while `core/error/` is not in the TDD-mandatory list (only `core/fsrs/` and `core/sync/` are per spec §7.3), the `Result` type is small enough that test-first is strictly cheaper. Demonstrates the testing pattern other plans will follow.

- [ ] **Step 1: Write the failing test for `Result`**

Create `test/core/error/result_test.dart`:
```dart
import 'package:cse_cet_reviewer/core/error/error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok holds value and reports isOk', () {
      const r = Ok<int, AppException>(42);
      expect(r.isOk, isTrue);
      expect(r.isErr, isFalse);
      expect(r.unwrap(), 42);
    });

    test('Err holds AppException and reports isErr', () {
      final ex = NetworkException(code: 'net/timeout');
      final r = Err<int, AppException>(ex);
      expect(r.isOk, isFalse);
      expect(r.isErr, isTrue);
      expect(r.unwrapErr(), ex);
    });

    test('unwrap on Err throws', () {
      final r = Err<int, AppException>(NetworkException(code: 'x'));
      expect(r.unwrap, throwsStateError);
    });

    test('unwrapErr on Ok throws', () {
      const r = Ok<int, AppException>(1);
      expect(r.unwrapErr, throwsStateError);
    });

    test('map transforms Ok values, leaves Err unchanged', () {
      const ok = Ok<int, AppException>(2);
      final mapped = ok.map((v) => v * 10);
      expect(mapped.unwrap(), 20);

      final err = Err<int, AppException>(NetworkException(code: 'x'));
      final mappedErr = err.map((v) => v * 10);
      expect(mappedErr.isErr, isTrue);
    });
  });

  group('AppException subclasses', () {
    test('NetworkException carries code and optional technical', () {
      final ex = NetworkException(
        code: 'net/timeout',
        technical: 'DioException at line 42',
      );
      expect(ex.code, 'net/timeout');
      expect(ex.technical, 'DioException at line 42');
      expect(ex, isA<AppException>());
    });

    test('exhaustive switch compiles', () {
      AppException ex = NetworkException(code: 'x');
      final label = switch (ex) {
        NetworkException() => 'network',
        AuthException() => 'auth',
        EntitlementException() => 'entitlement',
        SyncException() => 'sync',
        StorageException() => 'storage',
        ContentException() => 'content',
        ValidationException() => 'validation',
        IntegrityException() => 'integrity',
      };
      expect(label, 'network');
    });
  });
}
```

- [ ] **Step 2: Run test, expect compile failure (types not defined)**

```bash
flutter test test/core/error/result_test.dart
```
Expected: failure with import errors and undefined symbols `Ok`, `Err`, `Result`, `NetworkException`, etc. This is the failing test.

- [ ] **Step 3: Implement `app_exception.dart`**

Create `lib/core/error/app_exception.dart`:
```dart
sealed class AppException implements Exception {
  AppException({
    required this.code,
    this.technical,
    this.cause,
    this.stack,
  });

  final String code;
  final String? technical;
  final Object? cause;
  final StackTrace? stack;

  @override
  String toString() => '$runtimeType($code)';
}

final class NetworkException extends AppException {
  NetworkException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class AuthException extends AppException {
  AuthException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class EntitlementException extends AppException {
  EntitlementException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class SyncException extends AppException {
  SyncException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class StorageException extends AppException {
  StorageException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class ContentException extends AppException {
  ContentException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class ValidationException extends AppException {
  ValidationException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class IntegrityException extends AppException {
  IntegrityException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}
```

- [ ] **Step 4: Implement `result.dart`**

Create `lib/core/error/result.dart`:
```dart
sealed class Result<T, E> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  T unwrap() => switch (this) {
        Ok<T, E>(:final value) => value,
        Err<T, E>() => throw StateError('unwrap on Err'),
      };

  E unwrapErr() => switch (this) {
        Err<T, E>(:final error) => error,
        Ok<T, E>() => throw StateError('unwrapErr on Ok'),
      };

  Result<U, E> map<U>(U Function(T) f) => switch (this) {
        Ok<T, E>(:final value) => Ok<U, E>(f(value)),
        Err<T, E>(:final error) => Err<U, E>(error),
      };

  Result<T, F> mapErr<F>(F Function(E) f) => switch (this) {
        Ok<T, E>(:final value) => Ok<T, F>(value),
        Err<T, E>(:final error) => Err<T, F>(f(error)),
      };
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
```

- [ ] **Step 5: Implement barrel `error.dart`**

Create `lib/core/error/error.dart`:
```dart
export 'app_exception.dart';
export 'result.dart';
```

- [ ] **Step 6: Re-run tests**

```bash
flutter test test/core/error/result_test.dart
```
Expected: all tests pass.

- [ ] **Step 7: Run full analyzer**

```bash
flutter analyze
```
Expected: zero errors, zero warnings.

- [ ] **Step 8: Run layering check**

```bash
dart run tool/check_layering.dart
```
Expected: `OK`.

- [ ] **Step 9: Commit**

```bash
git add lib/core/error/ test/core/error/
git commit -m "feat(core/error): sealed AppException + Result types with tests"
```

---

### Task 12: App bootstrap, theme, flavor enum

**Files:**
- Create: `lib/app/flavor.dart`
- Create: `lib/app/theme.dart`
- Create: `lib/app/bootstrap.dart`
- Create: `lib/app/app.dart`

- [ ] **Step 1: Create `lib/app/flavor.dart`**

```dart
enum Flavor { dev, staging, prod }

extension FlavorX on Flavor {
  String get displayName => switch (this) {
        Flavor.dev => 'CSE/CET Reviewer Dev',
        Flavor.staging => 'CSE/CET Reviewer Staging',
        Flavor.prod => 'CSE/CET Reviewer',
      };
}
```

- [ ] **Step 2: Create `lib/app/theme.dart`**

Minimal theme; richer brand work lands in Plan 5.
```dart
import 'package:flutter/material.dart';

ThemeData appLightTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6BFF)),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

ThemeData appDarkTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1F6BFF),
        brightness: Brightness.dark,
      ),
    );
```

- [ ] **Step 3: Create `lib/app/app.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flavor.dart';
import 'theme.dart';

class App extends ConsumerWidget {
  const App({required this.flavor, super.key});

  final Flavor flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: flavor.displayName,
      theme: appLightTheme(),
      darkTheme: appDarkTheme(),
      home: _PlaceholderHome(flavor: flavor),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome({required this.flavor});

  final Flavor flavor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(flavor.displayName)),
      body: Center(child: Text('Foundation OK — ${flavor.name}')),
    );
  }
}
```

The `_PlaceholderHome` exists only so manual smoke tests work. It will be replaced by the router skeleton in Task 13.

- [ ] **Step 4: Create `lib/app/bootstrap.dart`**

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'flavor.dart';

Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization wires in at Task 17.
  // Crashlytics zone wrapping wires in at Plan 2.

  runApp(
    ProviderScope(
      child: App(flavor: flavor),
    ),
  );
}
```

- [ ] **Step 5: Run analyzer**

```bash
flutter analyze
```
Expected: zero issues.

- [ ] **Step 6: Run all tests**

```bash
flutter test
```
Expected: previous tests still pass; default `test/widget_test.dart` from `flutter create` may now fail because `MyApp` no longer exists. **Delete** `test/widget_test.dart`:
```bash
rm test/widget_test.dart
```

- [ ] **Step 7: Manual smoke test (optional but recommended)**

```bash
flutter run --flavor dev -t lib/main_dev.dart
```
Expected: app launches, AppBar reads "CSE/CET Reviewer Dev", body reads "Foundation OK — dev". Stop with `q`.

- [ ] **Step 8: Commit**

```bash
git add lib/app/ test/widget_test.dart
git commit -m "feat(app): bootstrap with flavor-aware theme and placeholder home"
```

---

### Task 13: go_router skeleton

**Files:**
- Create: `lib/app/router.dart`
- Modify: `lib/app/app.dart`

- [ ] **Step 1: Create `lib/app/router.dart`**

Mirrors spec §5.4. Routes are placeholders (real screens land in Plans 5-6); the skeleton proves wiring works.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const _Stub('Home'),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const _Stub('Onboarding'),
      ),
      GoRoute(
        path: '/quiz',
        builder: (_, __) => const _Stub('Quiz'),
      ),
      GoRoute(
        path: '/lesson',
        builder: (_, __) => const _Stub('Lesson'),
      ),
      GoRoute(
        path: '/review',
        builder: (_, __) => const _Stub('Review'),
      ),
      GoRoute(
        path: '/mock-exam',
        builder: (_, __) => const _Stub('Mock Exam'),
      ),
      GoRoute(
        path: '/progress',
        builder: (_, __) => const _Stub('Progress'),
      ),
      GoRoute(
        path: '/paywall',
        builder: (_, __) => const _Stub('Paywall'),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const _Stub('Settings'),
      ),
      GoRoute(
        path: '/legal/:doc',
        builder: (_, state) => _Stub('Legal: ${state.pathParameters['doc']}'),
      ),
    ],
  );
});

class _Stub extends StatelessWidget {
  const _Stub(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text('$label — placeholder')),
    );
  }
}
```

- [ ] **Step 2: Update `lib/app/app.dart` to use the router**

Replace the file with:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flavor.dart';
import 'router.dart';
import 'theme.dart';

class App extends ConsumerWidget {
  const App({required this.flavor, super.key});

  final Flavor flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: flavor.displayName,
      theme: appLightTheme(),
      darkTheme: appDarkTheme(),
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze
```
Expected: zero issues.

- [ ] **Step 4: Run tests**

```bash
flutter test
```
Expected: error tests still pass; no new tests yet.

- [ ] **Step 5: Manual smoke test (optional)**

```bash
flutter run --flavor dev -t lib/main_dev.dart
```
Expected: app launches, "Home — placeholder" visible. Verify deep-link via:
```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define=initial_route=/quiz
```
(Initial-route wiring will be plumbed in Plan 5; this manual test is just a sanity check that the router skeleton compiles.)

- [ ] **Step 6: Commit**

```bash
git add lib/app/router.dart lib/app/app.dart
git commit -m "feat(app): go_router skeleton with placeholder route stubs"
```

---

### Task 14: First widget test (sanity boot)

**Files:**
- Create: `test/app/app_boot_test.dart`

- [ ] **Step 1: Write the test**

```dart
import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and renders the home stub', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App(flavor: Flavor.dev)),
    );
    await tester.pumpAndSettle();

    // Home stub is the initial route.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Home — placeholder'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test**

```bash
flutter test test/app/app_boot_test.dart
```
Expected: 1 test, passes.

- [ ] **Step 3: Run full test suite + analyzer + layering**

```bash
flutter analyze && flutter test && dart run tool/check_layering.dart && dart run tool/check_no_ai_attribution.dart
```
Expected: all green.

- [ ] **Step 4: Commit**

```bash
git add test/app/
git commit -m "test(app): widget test verifies app boots and routes to home stub"
```

---

## Phase C — Managed Services

### Task 15: Firebase projects (dev + prod) in `asia-southeast1`

**Files:** none yet (Firebase config files generated by `flutterfire configure` in Task 16)

**Why two projects:** Industry-standard separation. Dev project for daily work + emulator; prod project locked down. Staging shares dev project for cost.

- [ ] **Step 1: Visit Firebase Console**

`https://console.firebase.google.com/`. Sign in with the Google account that owns Play Console (Task 3) — keeping these aligned simplifies later App Check + Play Integrity setup.

- [ ] **Step 2: Create dev project**

- Project name: `cse-cet-reviewer-dev`
- Disable Google Analytics for dev (avoids polluting prod metrics)
- After creation, set default GCP region: **`asia-southeast1` (Singapore)** when prompted at Firestore creation.

- [ ] **Step 3: Create prod project**

- Project name: `cse-cet-reviewer-prod`
- **Enable Google Analytics** (link new GA property — required for App Check device metrics + Crashlytics)
- Set default GCP region: **`asia-southeast1`**

- [ ] **Step 4: Enable required services in BOTH projects**

For each project, in the console enable:
- **Authentication** → enable providers: Apple, Google, Anonymous (others stay disabled)
- **Firestore Database** → start in `asia-southeast1`, mode: **production** (rules will be tightened in Task 18)
- **Storage** (defer Cloud Storage for v2 — leave disabled)
- **Functions** → upgrade to **Blaze plan** (pay-as-you-go required for outbound HTTP — RevenueCat webhooks). Set up budget alert at $10/mo.
- **Cloud Messaging (FCM)**
- **Remote Config**
- **Crashlytics**
- **Analytics** (prod only; dev keeps disabled)
- **App Check** → register new app providers later in Plan 4
- **Hosting** (used for privacy/ToS pages; configure in Task 18)

- [ ] **Step 5: Capture project IDs**

Record the project IDs and project numbers in a scratch note (added to OPERATIONS.md in Task 32):
```
Dev:  cse-cet-reviewer-dev   (project number: ...)
Prod: cse-cet-reviewer-prod  (project number: ...)
Region: asia-southeast1
```

- [ ] **Step 6: Set up Firebase CLI access**

```bash
npm install -g firebase-tools
firebase login
firebase projects:list
```
Expected: lists both projects.

- [ ] **Step 7: No commit**

This step produces no in-repo artifacts. Configuration files come from Task 16.

---

### Task 16: `flutterfire configure` for both flavors

**Files:**
- Create: `lib/firebase_options_dev.dart`
- Create: `lib/firebase_options_prod.dart`
- Create/modify: `android/app/google-services.json` (per flavor — placed in flavor-specific source set)
- Create/modify: `ios/Runner/GoogleService-Info-*.plist` (per flavor)
- Create: `.firebaserc`
- Create: `firebase.json`

- [ ] **Step 1: Install FlutterFire CLI**

```bash
dart pub global activate flutterfire_cli
```
Expected: installs `flutterfire` to `~/.pub-cache/bin`. Ensure that path is on `$PATH`:
```bash
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

- [ ] **Step 2: Configure for dev**

```bash
cd "/Users/aedwon/Documents/Dev Projects/CSE:CET Reviewer App"
flutterfire configure \
  --project=cse-cet-reviewer-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.aedwon.csecetreviewer.dev \
  --android-package-name=com.aedwon.csecetreviewer.dev \
  --platforms=ios,android \
  --yes
```
Expected: generates `lib/firebase_options_dev.dart`, `ios/Runner/GoogleService-Info.plist`, `android/app/google-services.json`. Move iOS file to flavor-specific path:
```bash
mkdir -p ios/config/dev
mv ios/Runner/GoogleService-Info.plist ios/config/dev/GoogleService-Info.plist
mkdir -p android/app/src/dev
mv android/app/google-services.json android/app/src/dev/google-services.json
```

- [ ] **Step 3: Configure for prod**

```bash
flutterfire configure \
  --project=cse-cet-reviewer-prod \
  --out=lib/firebase_options_prod.dart \
  --ios-bundle-id=com.aedwon.csecetreviewer \
  --android-package-name=com.aedwon.csecetreviewer \
  --platforms=ios,android \
  --yes
```
Expected: regenerates iOS and Android files at default paths. Move them:
```bash
mkdir -p ios/config/prod
mv ios/Runner/GoogleService-Info.plist ios/config/prod/GoogleService-Info.plist
mkdir -p android/app/src/prod
mv android/app/google-services.json android/app/src/prod/google-services.json
```

- [ ] **Step 4: Wire iOS config copy step**

Open `ios/Runner.xcodeproj` in Xcode → Runner target → Build Phases → "+" → New Run Script Phase. Name it "Copy GoogleService-Info.plist" and place it BEFORE "Compile Sources". Script:
```bash
case "${CONFIGURATION}" in
  *Dev*) PLIST=Dev ;;
  *Staging*) PLIST=Staging ;;
  *) PLIST=Prod ;;
esac
cp "${SRCROOT}/config/${PLIST,,}/GoogleService-Info.plist" \
   "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
```

(Document this as a manual Xcode step in `docs/OPERATIONS.md`.)

- [ ] **Step 5: Verify Android flavor source sets**

`android/app/src/dev/google-services.json` and `android/app/src/prod/google-services.json` will be picked up automatically by the `com.google.gms.google-services` plugin per flavor. No build.gradle change needed beyond Task 6 flavor declaration.

You'll need a `staging/` source set later — for now, copy dev's:
```bash
mkdir -p android/app/src/staging
cp android/app/src/dev/google-services.json android/app/src/staging/google-services.json
```
(Staging shares dev project per Task 15 rationale.)

- [ ] **Step 6: Add Firebase config repo files**

Create `.firebaserc`:
```json
{
  "projects": {
    "default": "cse-cet-reviewer-dev",
    "dev": "cse-cet-reviewer-dev",
    "prod": "cse-cet-reviewer-prod"
  }
}
```

Create `firebase.json` (placeholders — fleshed out in Task 18 and Plans 3-4):
```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "hosting": {
    "public": "public",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
  },
  "emulators": {
    "auth": { "port": 9099 },
    "firestore": { "port": 8080 },
    "functions": { "port": 5001 },
    "hosting": { "port": 5000 },
    "ui": { "enabled": true, "port": 4000 }
  }
}
```

- [ ] **Step 7: Verify `.gitignore` actually ignores Firebase config files**

The `.gitignore` from Task 5 already covers `google-services.json` and `GoogleService-Info.plist` at the **default** Flutter paths. The flavor-specific paths under `android/app/src/<flavor>/` and `ios/config/<flavor>/` are NOT covered. Decide:

- **Option A (recommended for v1):** Commit the Firebase configs. They contain only public client identifiers; security comes from Firestore Rules + App Check, not config secrecy. Faster onboarding for any future contributor.
- **Option B:** Add to `.gitignore` and store separately (1Password/Vault). Required if any future contributor must not have prod access.

Choose Option A. Update `.gitignore` to remove the now-incorrect default paths and explicitly note the decision:
```gitignore
# Firebase: We commit flavor-specific configs at android/app/src/<flavor>/ and
# ios/config/<flavor>/. These contain only public client identifiers; security
# is enforced by Firestore Rules + App Check.
# Do NOT remove this comment — see plan 1 task 16 for rationale.
```
(Replace the earlier `google-services.json` / `GoogleService-Info.plist` lines with the comment above.)

- [ ] **Step 8: Commit**

```bash
git add .firebaserc firebase.json \
  lib/firebase_options_dev.dart lib/firebase_options_prod.dart \
  android/app/src/dev/google-services.json \
  android/app/src/prod/google-services.json \
  android/app/src/staging/google-services.json \
  ios/config/ \
  .gitignore
git commit -m "feat: wire Firebase dev+prod projects via flutterfire (region asia-southeast1)"
```

---

### Task 17: Initialize Firebase in app bootstrap

**Files:**
- Modify: `lib/app/bootstrap.dart`
- Modify: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`

- [ ] **Step 1: Update `bootstrap.dart` to accept Firebase options**

```dart
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'flavor.dart';

Future<void> bootstrap(
  Flavor flavor, {
  required FirebaseOptions firebaseOptions,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: firebaseOptions);

  // Crashlytics zone wrapping + App Check activation land in Plan 2 / Plan 4.

  runApp(
    ProviderScope(
      child: App(flavor: flavor),
    ),
  );
}
```

- [ ] **Step 2: Update `main_dev.dart`**

```dart
import 'package:flutter/widgets.dart';

import 'app/bootstrap.dart';
import 'app/flavor.dart';
import 'firebase_options_dev.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(
    Flavor.dev,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
```

- [ ] **Step 3: Update `main_staging.dart`**

Staging uses dev Firebase project (per Task 15 cost rationale):
```dart
import 'package:flutter/widgets.dart';

import 'app/bootstrap.dart';
import 'app/flavor.dart';
import 'firebase_options_dev.dart';   // shares dev project

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(
    Flavor.staging,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
```

- [ ] **Step 4: Update `main_prod.dart`**

```dart
import 'package:flutter/widgets.dart';

import 'app/bootstrap.dart';
import 'app/flavor.dart';
import 'firebase_options_prod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(
    Flavor.prod,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
```

- [ ] **Step 5: Verify analyzer**

```bash
flutter analyze
```
Expected: zero issues.

- [ ] **Step 6: Update widget test to pass Firebase options stub**

The widget test in Task 14 calls `App(flavor: Flavor.dev)` directly, NOT `bootstrap`, so it does not need Firebase. No change required. Verify:
```bash
flutter test
```
Expected: passes.

- [ ] **Step 7: Smoke test on device**

```bash
flutter run --flavor dev -t lib/main_dev.dart
```
Expected: app launches and connects to Firebase. Open Firebase Console → Authentication → Users — should be empty but Firebase initialized successfully (no errors in `flutter logs`).

- [ ] **Step 8: Commit**

```bash
git add lib/app/bootstrap.dart lib/main_dev.dart lib/main_staging.dart lib/main_prod.dart
git commit -m "feat(app): initialize Firebase in bootstrap with per-flavor options"
```

---

### Task 18: Firestore rules + indexes placeholders + emulator config

**Files:**
- Create: `firestore.rules`
- Create: `firestore.indexes.json`
- Create: `public/index.html` (for Hosting placeholder)

- [ ] **Step 1: Write conservative starter `firestore.rules`**

Real rules (per spec §3.2) ship in Plan 7. For now, **deny all** so nothing accidentally writes plaintext data:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

- [ ] **Step 2: Empty `firestore.indexes.json`**

```json
{
  "indexes": [],
  "fieldOverrides": []
}
```

- [ ] **Step 3: Public placeholder for Hosting**

Create `public/index.html`:
```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>CSE/CET Reviewer</title>
  </head>
  <body>
    <h1>CSE/CET Reviewer</h1>
    <p>Privacy Policy and Terms will be hosted here. See in-app links for the live versions.</p>
  </body>
</html>
```

(In Plan 4, this becomes the Sanity-rendered legal documents target.)

- [ ] **Step 4: Deploy to dev project as smoke test**

```bash
firebase use dev
firebase deploy --only firestore:rules,firestore:indexes,hosting
```
Expected: succeeds. Hosting URL printed.

Try a Firestore read from the console — should be denied. Good.

- [ ] **Step 5: Commit**

```bash
git add firestore.rules firestore.indexes.json public/
git commit -m "feat(firestore): deny-all starter rules + empty indexes + hosting placeholder"
```

---

### Task 19: Sanity workspace + 2FA + roles

**Files:** none in repo for this task; Sanity Studio scaffold lands in Plan 4.

- [ ] **Step 1: Create Sanity account / log in**

`https://www.sanity.io/`. Use the same email tied to other vendor accounts for consistency.

- [ ] **Step 2: Enforce 2FA on personal account**

Account Settings → Security → enable 2FA via authenticator app or hardware key. **Required** by spec §3.1 / §8 ("Sanity 2FA mandatory"). Do this **before** creating the project.

- [ ] **Step 3: Create project**

- Project name: `CSE/CET Reviewer`
- Plan: Free tier sufficient for v1 (3 user seats; upgrade if you add reviewers)

Capture:
- Project ID: `<sanity_project_id>`
- Dataset: create `production` (defer `staging` until Plan 4)

- [ ] **Step 4: Enable 2FA enforcement at organization level**

Project Settings → Security → require 2FA for all members. Toggle on.

- [ ] **Step 5: Define role placeholders**

Sanity built-in roles to use in Plan 4:
- **administrator** (you only)
- **editor** — drafts only (will need custom role; Sanity calls this `Contributor`)
- **viewer** — for any future support staff

For now, you are sole administrator. Document in OPERATIONS.md to add real reviewers/publishers in Plan 4.

- [ ] **Step 6: Generate read-only API token (placeholder)**

Project Settings → API → Tokens → Add API Token:
- Name: `app-read-token-dev`
- Permissions: Viewer
- Capture the token to a secure location (1Password). **Never commit this.**

A Cloud Function proxy (Plan 4) holds the prod-equivalent token; the app never has it.

- [ ] **Step 7: No commit**

Procedural only. Reference info recorded in OPERATIONS.md (Task 32).

---

### Task 20: RevenueCat dashboard project + entitlement + product placeholders

**Files:** none yet (RevenueCat SDK init lands in Plan 3)

- [ ] **Step 1: Create RevenueCat account**

`https://app.revenuecat.com/`. Use the same email cluster.

- [ ] **Step 2: Enforce 2FA**

Settings → Security → enable 2FA. Same standard as Sanity.

- [ ] **Step 3: Create project**

Project name: `CSE/CET Reviewer`. Capture API keys (one per platform):
- iOS public key (`appl_*`)
- Android public key (`goog_*`)

These are public keys safe to embed in the app. Save them to a secure note for use in Plan 3.

- [ ] **Step 4: Define entitlement**

Entitlements → New entitlement:
- Identifier: `pro`
- Display name: "Pro Access"

This is what the JWT custom claim mirrors per spec §4.3.

- [ ] **Step 5: Define product placeholders (per spec §1.3)**

Products → New product (one per SKU). Real product IDs will be bound to App Store Connect / Play Console products, which can only be created after Apple Developer + Play Console accounts approve. For now, register intent in RevenueCat with these identifiers (which should match the IDs you'll use in Apple/Google):

```
cse_cet_pro_monthly       (Subscription, $1.75 ≈ ₱99/mo)
cse_cet_pro_yearly        (Subscription, $8.99 ≈ ₱499/yr, 7-day intro trial)
cse_cet_pro_lifetime      (Non-consumable, $26.99 ≈ ₱1,499 one-time)
```

(Pricing from spec §1.3. Convert PHP→USD for App Store tier matching at the time of Plan 8 store-product creation; the App Store and Play Store determine actual local pricing automatically.)

- [ ] **Step 6: Set up webhook endpoint placeholder**

Settings → Webhooks → Add webhook:
- URL: `https://placeholder.invalid/revenuecat-webhook` (real Cloud Function URL replaces this in Plan 3)
- Authorization header: generate a long random secret (32+ bytes, e.g. `openssl rand -hex 32`) and store in a secure note. The Cloud Function will validate this header.

- [ ] **Step 7: No commit**

Vendor config only. Reference info → OPERATIONS.md.

---

## Phase D — CI/CD

### Task 21: gitleaks pre-commit hook + config

**Files:**
- Create: `.gitleaks.toml`
- Create: `.git/hooks/pre-commit` (local hook; not committed)
- Create: `tool/install_hooks.sh` (committed installer for any contributor)

- [ ] **Step 1: Install gitleaks locally**

```bash
brew install gitleaks
gitleaks version
```
Expected: prints version (8.x).

- [ ] **Step 2: Create `.gitleaks.toml`**

Use the default ruleset and add Firebase / Sanity / RevenueCat-specific patterns.

```toml
title = "gitleaks config — CSE/CET Reviewer"

[extend]
useDefault = true

[[rules]]
id = "firebase-private-key"
description = "Firebase service account private key"
regex = '''-----BEGIN PRIVATE KEY-----[\s\S]+?-----END PRIVATE KEY-----'''

[[rules]]
id = "sanity-write-token"
description = "Sanity write/admin token (sk*)"
regex = '''\bsk[a-zA-Z0-9]{40,}\b'''

[[rules]]
id = "revenuecat-secret-key"
description = "RevenueCat secret key (sk_*)"
regex = '''\bsk_[a-zA-Z0-9]{32,}\b'''

[[rules]]
id = "android-keystore-password"
description = "Android keystore password reference"
regex = '''(?i)(keyAlias|keyPassword|storePassword)\s*=\s*['"][^'"]{4,}['"]'''

[allowlist]
description = "Allow placeholder strings used in this plan"
paths = [
  '''docs/superpowers/plans/.*\.md''',
  '''docs/superpowers/specs/.*\.md''',
]
```

- [ ] **Step 3: Create installer at `tool/install_hooks.sh`**

```bash
#!/usr/bin/env bash
# Installs git pre-commit hooks for this repo.
# Run from repo root: ./tool/install_hooks.sh
set -euo pipefail

HOOK_PATH=".git/hooks/pre-commit"
mkdir -p "$(dirname "$HOOK_PATH")"

cat > "$HOOK_PATH" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail

# 1. gitleaks scan staged changes only
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks protect --staged --redact --config=.gitleaks.toml
else
  echo "WARNING: gitleaks not installed; skipping secret scan"
  echo "  install: brew install gitleaks"
fi

# 2. AI-attribution check
dart run tool/check_no_ai_attribution.dart

# 3. Layering check
dart run tool/check_layering.dart

# 4. Format check (just-changed Dart files)
CHANGED=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' || true)
if [ -n "$CHANGED" ]; then
  dart format --output=none --set-exit-if-changed $CHANGED
fi
HOOK

chmod +x "$HOOK_PATH"
echo "pre-commit hook installed at $HOOK_PATH"
```

- [ ] **Step 4: Run installer**

```bash
chmod +x tool/install_hooks.sh
./tool/install_hooks.sh
```
Expected: prints "pre-commit hook installed".

- [ ] **Step 5: Smoke-test the hook**

```bash
# Should pass on a clean tree:
git commit --allow-empty -m "chore: smoke test pre-commit hook"
```
Expected: hook runs, all checks pass, commit succeeds.

- [ ] **Step 6: Negative test — try to commit a fake secret**

```bash
echo 'const bad = "sk_thisisfake0123456789abcdef0123456789ab";' > /tmp/leak.dart
cp /tmp/leak.dart lib/leak_test.dart
git add lib/leak_test.dart
git commit -m "test: should be blocked"
```
Expected: gitleaks blocks the commit. Then clean up:
```bash
git restore --staged lib/leak_test.dart
rm lib/leak_test.dart
```

- [ ] **Step 7: Commit**

```bash
git add .gitleaks.toml tool/install_hooks.sh
git commit -m "feat: gitleaks config + pre-commit hook installer"
```

---

### Task 22: GitHub Actions CI on PR

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Author the workflow**

```yaml
name: CI (PR)

on:
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '3.27.x'

      - name: pub get
        run: flutter pub get

      - name: dart format check
        run: dart format --output=none --set-exit-if-changed .

      - name: dart analyze
        run: flutter analyze

      - name: Layering check
        run: dart run tool/check_layering.dart

      - name: AI-attribution check
        run: dart run tool/check_no_ai_attribution.dart

      - name: Unit + widget tests
        run: flutter test --coverage

      - name: Coverage gate (overall ≥ 70%)
        run: |
          # Compute line coverage from coverage/lcov.info; fail if < 70%
          # The actual coverage gates by module land in Plan 7; this is the
          # minimum-viable gate so foundational PRs stay tested.
          if [ ! -f coverage/lcov.info ]; then
            echo "no coverage produced"; exit 1
          fi
          covered=$(grep -h '^DA:' coverage/lcov.info | awk -F, '$2 != "0" {c++} END {print c+0}')
          total=$(grep -hc '^DA:' coverage/lcov.info)
          if [ "$total" -eq 0 ]; then
            echo "no DA lines in lcov"; exit 1
          fi
          pct=$(awk -v c="$covered" -v t="$total" 'BEGIN { printf "%.1f", (c/t)*100 }')
          echo "Coverage: $pct%"
          awk -v p="$pct" 'BEGIN { exit !(p+0 >= 70.0) }' || {
            echo "coverage $pct% < 70%"; exit 1
          }

      - name: gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          config-path: .gitleaks.toml
```

- [ ] **Step 2: Push to a test branch and open PR**

```bash
git checkout -b chore/ci-bringup
git add .github/workflows/ci.yml
git commit -m "ci: PR workflow with lint, layering, tests, secrets, coverage gate"
git push -u origin chore/ci-bringup
gh pr create --title "ci: bring up PR workflow" --body "Initial CI pipeline."
```

(Note: requires GitHub remote configured. If not yet, defer push until Task 28; just commit locally for now.)

- [ ] **Step 3: Verify on GitHub (when remote ready)**

Open the PR, watch CI run. Expected: all jobs green within ~5 min. If coverage gate fails because too few tests exist yet, adjust `>= 70.0` to `>= 0.0` temporarily and revisit at end of Plan 2 — but only with explicit acknowledgment in OPERATIONS.md.

- [ ] **Step 4: If CI green, merge**

If green, merge to main. If not, fix in branch.

---

### Task 23: GitHub Actions CI on `main`

**Files:**
- Create: `.github/workflows/main.yml`

- [ ] **Step 1: Author workflow**

Runs the PR pipeline plus integration tests + build artifacts.

```yaml
name: CI (main)

on:
  push:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '3.27.x'

      - run: flutter pub get
      - run: flutter analyze
      - run: dart run tool/check_layering.dart
      - run: dart run tool/check_no_ai_attribution.dart
      - run: flutter test --coverage

      - name: Build dev APK (debug, unsigned)
        run: flutter build apk --debug --flavor dev -t lib/main_dev.dart

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-dev-debug
          path: build/app/outputs/flutter-apk/app-dev-debug.apk
          retention-days: 14

  integration:
    runs-on: macos-13
    timeout-minutes: 30
    needs: ci
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '3.27.x'
      - run: flutter pub get

      - name: Set up iOS simulator
        run: |
          xcrun simctl list devices
          xcrun simctl boot "iPhone 15" || true

      - name: Run integration tests
        run: |
          # Plan 1 has no integration tests yet; they land in Plan 2+.
          # Workflow scaffolded so the slot exists.
          if ls integration_test/*_test.dart 2>/dev/null; then
            flutter test integration_test
          else
            echo "no integration tests yet — skipping"
          fi
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/main.yml
git commit -m "ci: main-branch workflow with integration suite + artifact upload"
```

---

### Task 24: GitHub Actions CI on release tags

**Files:**
- Create: `.github/workflows/release.yml`

- [ ] **Step 1: Author workflow (placeholder, signing in Plan 8)**

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '3.27.x'
      - run: flutter pub get
      - name: Build Android App Bundle (prod, unsigned)
        run: flutter build appbundle --release --flavor prod -t lib/main_prod.dart
      - uses: actions/upload-artifact@v4
        with:
          name: app-prod-release-aab-${{ github.ref_name }}
          path: build/app/outputs/bundle/prodRelease/app-prod-release.aab
          retention-days: 90

  build-ios:
    runs-on: macos-13
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '3.27.x'
      - run: flutter pub get
      - name: Build iOS archive (prod, unsigned)
        run: flutter build ipa --release --flavor prod -t lib/main_prod.dart --no-codesign
      - uses: actions/upload-artifact@v4
        with:
          name: app-prod-release-ipa-${{ github.ref_name }}
          path: build/ios/archive/Runner.xcarchive
          retention-days: 90
```

Signing credentials, store uploads, and TestFlight/Play Internal pipelines are added in Plan 8. This workflow exists so a tag push produces unsigned artifacts for inspection from day one.

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/release.yml
git commit -m "ci: release tag workflow producing unsigned prod artifacts"
```

---

### Task 25: Semgrep SAST in CI

**Files:**
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 1: Append Semgrep job to PR workflow**

Add to `.github/workflows/ci.yml` after the existing `ci` job:
```yaml
  sast:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/owasp-top-ten
            p/security-audit
            p/dart
            p/flutter
            p/secrets
```

(`p/dart` and `p/flutter` are Semgrep registry rule packs.)

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add Semgrep SAST (OWASP Top 10 + Dart + Flutter rule packs)"
```

---

### Task 26: osv-scanner in CI

**Files:**
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 1: Append osv-scanner job**

Add to `.github/workflows/ci.yml`:
```yaml
  osv:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: google/osv-scanner-action/osv-scanner-action@v1
        with:
          scan-args: |-
            --recursive
            --skip-git
            ./
```

By default this fails on any vulnerability. Spec §7.5 says "blocking on Critical/High CVE". Add severity filter via the OSV CLI config — for v1, accept the default (block on all) since dependencies are tightly locked. If too noisy in practice, add a `osv-scanner.toml` config to ignore specific CVEs with documented justification.

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add osv-scanner dependency vulnerability scan"
```

---

### Task 27: Codemagic config for release builds

**Files:**
- Create: `codemagic.yaml`

**Why Codemagic, not Fastlane:** Codemagic has stronger Flutter affinity, free 500 minutes/mo for FOSS or low-traffic apps, no local Mac requirement. Fastlane stays an option if Codemagic limits hit; both can coexist.

- [ ] **Step 1: Create `codemagic.yaml` with placeholders**

```yaml
workflows:
  ios-release:
    name: iOS Release (TestFlight)
    instance_type: mac_mini_m2
    max_build_duration: 60
    environment:
      flutter: stable
      xcode: 15.4
      cocoapods: default
      vars:
        # Wire these in Codemagic UI in Plan 8:
        # APP_STORE_CONNECT_ISSUER_ID
        # APP_STORE_CONNECT_KEY_IDENTIFIER
        # APP_STORE_CONNECT_PRIVATE_KEY
        # CERTIFICATE_PRIVATE_KEY
        BUNDLE_ID: "com.aedwon.csecetreviewer"
    triggering:
      events:
        - tag
      tag_patterns:
        - pattern: 'v*'
          include: true
    scripts:
      - name: pub get
        script: flutter pub get
      - name: Build iOS (prod)
        script: flutter build ipa --release --flavor prod -t lib/main_prod.dart --export-options-plist=/Users/builder/export_options.plist
    artifacts:
      - build/ios/ipa/*.ipa
    publishing:
      app_store_connect:
        # Activated in Plan 8.
        # api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        # key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        # issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: false  # flip to true in Plan 8

  android-release:
    name: Android Release (Play Internal)
    instance_type: linux_x2
    max_build_duration: 60
    environment:
      flutter: stable
      vars:
        # Wire in Plan 8:
        # CM_KEYSTORE
        # CM_KEYSTORE_PASSWORD
        # CM_KEY_ALIAS
        # CM_KEY_PASSWORD
        # GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        PACKAGE_NAME: "com.aedwon.csecetreviewer"
    triggering:
      events:
        - tag
      tag_patterns:
        - pattern: 'v*'
          include: true
    scripts:
      - name: pub get
        script: flutter pub get
      - name: Build Android App Bundle (prod)
        script: flutter build appbundle --release --flavor prod -t lib/main_prod.dart
    artifacts:
      - build/app/outputs/bundle/prodRelease/*.aab
    publishing:
      google_play:
        # Activated in Plan 8.
        # credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        # track: internal
        # submit_as_draft: true
```

- [ ] **Step 2: Commit**

```bash
git add codemagic.yaml
git commit -m "ci: codemagic.yaml scaffold for iOS+Android release pipelines"
```

---

### Task 28: Branch protection on `main`

**Files:** none (procedural)

- [ ] **Step 1: Create GitHub remote (if not yet)**

```bash
gh repo create cse-cet-reviewer --private --source=. --remote=origin
git push -u origin main
```
Expected: repo created on GitHub, main pushed.

- [ ] **Step 2: Apply branch protection**

```bash
gh api -X PUT repos/<your-username>/cse-cet-reviewer/branches/main/protection \
  -f required_status_checks.strict=true \
  -F 'required_status_checks.contexts[]=ci' \
  -F 'required_status_checks.contexts[]=sast' \
  -F 'required_status_checks.contexts[]=osv' \
  -F enforce_admins=true \
  -F required_pull_request_reviews.required_approving_review_count=1 \
  -F restrictions=null
```

Replace `<your-username>` with the actual user. (For solo development, you can self-approve; the requirement still catches you reviewing your own diffs before merge.)

- [ ] **Step 3: Verify settings in GitHub UI**

Navigate to repo → Settings → Branches. Confirm:
- "Require a pull request before merging" — on
- "Require status checks to pass" — on, with `ci`, `sast`, `osv` selected
- "Do not allow bypassing the above settings" — on

- [ ] **Step 4: Capture screenshot for OPERATIONS.md**

Save a screenshot for compliance audit trail.

---

## Phase E — Legal & Docs

### Task 29: Privacy Policy v0 draft

**Files:**
- Create: `docs/PRIVACY.md`

**Note:** This is a v0 draft for legal review. The legal-review-approved version replaces it before public soft launch. Designate this as draft in the file header.

- [ ] **Step 1: Write `docs/PRIVACY.md`**

```markdown
# Privacy Policy — DRAFT v0

**Status:** DRAFT, not yet legally reviewed. Not for publication.
**Last updated:** [auto-update at publication]
**Effective date:** [TBD — pre-soft-launch]
**Legal entity:** [Aerol Balayon, sole proprietor — confirm pending DTI registration]
**DPO:** Aerol Balayon · dpo@aedwon.com
**NPC reference:** [insert post-Task 1 confirmation]

## 1. Scope

This Privacy Policy describes how the CSE/CET Reviewer mobile application ("the App", "we", "our") collects, uses, and protects personal data. It applies to use of the App on iOS and Android.

## 2. Data we collect

| Category | Examples | Source | Purpose |
|---|---|---|---|
| Account identifiers | Display name, email (only when you sign in with Apple or Google) | You | Account sync, support |
| Usage data | Quiz attempts, lesson completions, FSRS review state, streak history | App use | Personalize learning, surface progress |
| Device information | Device model, OS version, app version, language preference | Device | Compatibility, support |
| Crash and performance data | Crash logs, performance metrics (anonymized; no question content, no answers) | App runtime | Stability |
| Purchase data | Subscription tier, transaction status (we do NOT see your payment details) | Apple / Google / RevenueCat | Entitlement |

We do **not** collect: precise location, contacts, photos, microphone audio, advertising identifiers (we do not run ads in v1).

## 3. Anonymous mode

You may use the App without signing in. While anonymous, your data is stored on your device and a temporary anonymous identifier with our backend (Firebase). If you sign in later, we migrate your anonymous data to your account.

## 4. Where data is stored

- **On your device:** encrypted at rest using SQLCipher (AES-256). Key stored in iOS Keychain or Android Keystore (hardware-backed where available).
- **In our backend:** Firebase Firestore in the `asia-southeast1` (Singapore) region. Encrypted at rest by Google Cloud Platform.
- **Payment processor:** RevenueCat handles transaction details. We never see your card.

## 5. Sharing

We share data only with:
- **Google Firebase (Google LLC)** — hosting, authentication, crash reporting (no PII in crash reports)
- **Sanity (Sanity.io Inc.)** — content management; **no user PII** is sent to Sanity
- **RevenueCat (RevenueCat Inc.)** — purchase processing
- **Apple, Google** — payment processing per their store rules

We do not sell your data. We do not use your data for advertising.

## 6. Your rights under RA 10173

You have the right to:
- **Access** your data — use Settings → "Export my data" to receive a JSON file by email
- **Correct** inaccurate data — edit in Settings or contact our DPO
- **Withdraw consent** and **delete** your account — Settings → "Delete my account" (irreversible; takes effect within 30 days)
- **Object** to processing — contact our DPO
- **Lodge a complaint** with the National Privacy Commission (`https://privacy.gov.ph`)

## 7. Data retention

- **Active account data:** retained while your account exists.
- **Deleted account:** purged from active systems within 30 days. Backups age out within 90 days.
- **Attempts older than 18 months:** archived to Google BigQuery (within `asia-southeast1`); aggregate trend data retained in your active account.
- **Crash logs:** 90 days.

## 8. Children

The App is not directed to children under 13. We use a birth-year age gate at onboarding. If we learn we've collected data from a child under 13, we delete it.

## 9. Security

- TLS for all network traffic.
- Firebase App Check on every backend call.
- Firebase Security Rules with 100% test coverage.
- SQLCipher local encryption.
- Annual external penetration testing.
- 72-hour breach notification per RA 10173 to NPC and affected users.

## 10. Changes

Material changes will be notified in-app at least 30 days before taking effect.

## 11. Contact

DPO: Aerol Balayon · dpo@aedwon.com
NPC: complaints@privacy.gov.ph

---

**Disclaimer:** This is a v0 draft for legal review. Final wording and any required additions (e.g., notice of automated decision-making for FSRS, App Tracking Transparency on iOS, specific Apple/Google privacy nutrition labels) must be reviewed by a Philippine data privacy lawyer before publication.
```

- [ ] **Step 2: Commit**

```bash
git add docs/PRIVACY.md
git commit -m "docs: privacy policy v0 draft (pending legal review)"
```

---

### Task 30: Terms of Service v0 draft

**Files:**
- Create: `docs/TERMS.md`

- [ ] **Step 1: Write `docs/TERMS.md`**

```markdown
# Terms of Service — DRAFT v0

**Status:** DRAFT, not yet legally reviewed. Not for publication.
**Last updated:** [auto-update at publication]
**Effective date:** [TBD — pre-soft-launch]
**Legal entity:** [Aerol Balayon, sole proprietor]

## 1. Agreement

By installing or using the CSE/CET Reviewer mobile application ("App"), you agree to these Terms.

## 2. Eligibility

You must be 13 or older. If you are under 18, you confirm a parent or guardian has consented.

## 3. Subscriptions and lifetime purchase

The App offers three Pro tiers: monthly (₱99), yearly (₱499 with 7-day free trial), and lifetime (₱1,499). All purchases are processed by Apple or Google subject to their billing terms.

- **Monthly and yearly subscriptions** auto-renew unless canceled at least 24 hours before period end. Cancel via Apple Subscriptions or Google Play Subscriptions.
- **Free trial** (yearly only): canceling before day 7 incurs no charge. After day 7, the yearly fee is charged.
- **Lifetime purchase** is one-time. Lifetime entitlement persists for the life of the App on the platform of purchase, subject to App availability and continued service operation. We reserve the right to discontinue the App with 90 days' notice; in that case, lifetime purchasers within the prior 12 months receive a pro-rated refund.

## 4. Refunds

Refunds are governed by Apple's and Google's policies. We will support legitimate refund requests through their channels. We do not separately process refunds outside their billing systems.

## 5. License

We grant you a limited, non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial study. You may not:
- Copy, scrape, or redistribute question content
- Reverse-engineer the App except as permitted by law
- Use the App to develop a competing service
- Share account credentials

Question content remains our property (or our licensors').

## 6. User content

The App does not solicit user-generated content in v1. If you flag a question as incorrect, we may use that flag to improve content; we treat flag content per the Privacy Policy.

## 7. Acceptable use

Do not:
- Reverse-engineer the App
- Attempt to circumvent purchase / entitlement systems
- Submit fraudulent attempts or scripted automation
- Use the App for purposes other than personal study

We may suspend accounts engaged in the above.

## 8. Disclaimers

The App is provided "as is". We do not guarantee passing any particular exam. Exam content reflects publicly available study materials and our editorial judgment as of the publication date and may not match every edition of every exam.

## 9. Limitation of liability

To the maximum extent permitted by Philippine law, our liability for any claim is limited to the amount you paid for the App in the prior 12 months.

## 10. Termination

We may terminate access for violations of these Terms. You may stop using the App and delete your account at any time via Settings → Delete my account.

## 11. Governing law

These Terms are governed by the laws of the Republic of the Philippines. Disputes are resolved in the courts of [Province TBD].

## 12. Changes

We will notify material changes in-app at least 30 days before they take effect.

## 13. Contact

aerol.balayon@gmail.com (general support)
dpo@aedwon.com (privacy)

---

**Disclaimer:** v0 draft for legal review.
```

- [ ] **Step 2: Commit**

```bash
git add docs/TERMS.md
git commit -m "docs: terms of service v0 draft (pending legal review)"
```

---

### Task 31: README + LICENSE

**Files:**
- Create: `README.md`
- Create: `LICENSE`

- [ ] **Step 1: Write `README.md`**

Crucial: **no AI/Claude/Anthropic attribution anywhere.** Project memory rule.

```markdown
# CSE/CET Reviewer

A gamified, learning-focused Flutter mobile reviewer for Philippine exam preparation. Launch scope: Civil Service Examination (Professional level) and UPCAT.

## Status

Pre-launch. Soft launch target: 2026-06-28.

## Architecture

See `docs/superpowers/specs/2026-05-07-cse-cet-reviewer-app-design.md` for the design document. Implementation plans live in `docs/superpowers/plans/`.

## Tech stack

- Flutter (3.27+) with Riverpod 2.x and go_router
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
\`\`\`bash
flutter run --flavor dev -t lib/main_dev.dart
\`\`\`

## Repository layout

\`\`\`
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
\`\`\`

## Pre-commit

Install hooks once after cloning:
\`\`\`bash
./tool/install_hooks.sh
\`\`\`

This installs gitleaks scanning, AI-attribution check, layering check, and Dart format check.

## CI/CD

- Pull requests: lint, analyze, layering, tests, gitleaks, Semgrep, osv-scanner
- Main: above + integration tests + dev APK artifact
- Release tags (`v*`): unsigned prod artifacts; signed builds via Codemagic

## License

Proprietary. See `LICENSE`.
```

- [ ] **Step 2: Choose license**

For a paid commercial app, **proprietary** is the default. Write `LICENSE`:

```
Copyright (c) 2026 Aerol Balayon

All rights reserved.

This source code and the corresponding application binary are proprietary
and confidential. No license is granted to use, copy, modify, merge,
publish, distribute, sublicense, or sell copies of this software, or any
portion of it, except as expressly authorized in writing by the
copyright holder.

Unauthorized reproduction or distribution may result in civil and
criminal penalties under applicable law.
```

If you intend to open-source any portion later (e.g., the FSRS Dart port), document that decision and add an OSS license then.

- [ ] **Step 3: Commit**

```bash
git add README.md LICENSE
git commit -m "docs: README + proprietary LICENSE"
```

---

### Task 32: OPERATIONS.md status tracker

**Files:**
- Create: `docs/OPERATIONS.md`

- [ ] **Step 1: Write the tracker**

Pulls together all the procedural Day-1 items from Phase A and the manual config notes from Tasks 6, 16, 19, 20, 28.

```markdown
# Operations status tracker

Tracks long-pole external dependencies and one-time manual configuration. Owner: Aerol Balayon.

Last updated: 2026-05-07

## Day-1 procedural items (Phase A of Plan 1)

| # | Item | Status | Started | Expected complete | Notes |
|---|---|---|---|---|---|
| 1 | NPC registration filed | [ ] | 2026-05-07 | 2026-06-25 (latest) | Reference number: TBD; follow-ups 2026-05-21, 2026-06-04, 2026-06-18 |
| 2 | Apple Developer Program | [ ] | 2026-05-07 | 2026-05-09 | Team ID: TBD |
| 3 | Google Play Console | [ ] | 2026-05-07 | 2026-05-10 | Account ID: TBD |
| 4 | Pentester engaged for week 6 | [ ] | 2026-05-07 | 2026-05-12 (signed) | Vendor: TBD; window: 2026-06-11 to 2026-06-17 |

## Vendor reference info

### Firebase

- Dev project: `cse-cet-reviewer-dev` (number: TBD)
- Prod project: `cse-cet-reviewer-prod` (number: TBD)
- Region: `asia-southeast1` (Singapore)
- Blaze plan enabled on both, $10/mo budget alert configured
- Hosting placeholder URLs:
  - Dev:  https://cse-cet-reviewer-dev.web.app
  - Prod: https://cse-cet-reviewer-prod.web.app

### Sanity

- Project ID: TBD
- Datasets: `production` (dev plan also uses this for v0; isolated `staging` ds added in Plan 4)
- 2FA enforced at org level: [ ] confirm
- API token (read-only, dev): stored in 1Password under "CSE/CET Reviewer — Sanity Dev"

### RevenueCat

- Project: CSE/CET Reviewer
- Entitlement: `pro`
- Products: `cse_cet_pro_monthly`, `cse_cet_pro_yearly`, `cse_cet_pro_lifetime`
- Webhook secret: stored in 1Password under "CSE/CET Reviewer — RevenueCat Webhook"

### Apple Developer

- Team ID: TBD
- Bundle IDs:
  - Dev: `com.aedwon.csecetreviewer.dev`
  - Staging: `com.aedwon.csecetreviewer.staging`
  - Prod: `com.aedwon.csecetreviewer`

### Google Play

- Developer account: TBD

## Manual configuration steps

These cannot be scripted in this repo and must be redone if the relevant config is regenerated.

- [ ] iOS Xcode schemes created (`Runner-Dev`, `Runner-Staging`, `Runner-Prod`) with xcconfigs from `ios/Flutter/{Dev,Staging,Prod}.xcconfig` — Plan 1 Task 6 step 8
- [ ] iOS "Copy GoogleService-Info.plist" run-script phase added to Runner target — Plan 1 Task 16 step 4
- [ ] Sanity 2FA enforcement at org level enabled — Plan 1 Task 19 step 4
- [ ] GitHub branch protection on `main` — Plan 1 Task 28 step 2

## Codemagic / signing (activated in Plan 8)

- [ ] iOS App Store Connect API key uploaded
- [ ] iOS distribution certificate uploaded
- [ ] Android upload keystore generated and uploaded
- [ ] Google Play service account credentials uploaded

## Compliance checklist

- [ ] NPC registration confirmation received and recorded
- [ ] Privacy Policy reviewed by PH data privacy lawyer
- [ ] Terms of Service reviewed by PH lawyer
- [ ] App Store privacy nutrition labels filled (Plan 8)
- [ ] Google Play data safety form filled (Plan 8)
- [ ] DTI Business Name Registration confirmed (if operating under business name)

## Pentest

- [ ] Engagement signed
- [ ] NDA signed
- [ ] Scope finalized
- [ ] Engagement window: 2026-06-11 to 2026-06-17
- [ ] Findings report delivered
- [ ] Critical / High remediations done
```

- [ ] **Step 2: Commit**

```bash
git add docs/OPERATIONS.md
git commit -m "docs: OPERATIONS.md tracker for Day-1 procedural items and manual config"
```

---

## Phase F — Verification Gate

### Task 33: Final smoke test + tag `v0.0.1-foundation`

**Files:** none modified; this is a verification gate.

- [ ] **Step 1: Run the full local check suite**

```bash
flutter pub get && \
flutter analyze && \
flutter test --coverage && \
dart format --output=none --set-exit-if-changed . && \
dart run tool/check_layering.dart && \
dart run tool/check_no_ai_attribution.dart && \
gitleaks detect --source . --config=.gitleaks.toml --redact
```
Expected: every step exits 0.

- [ ] **Step 2: Manual flavor smoke (dev)**

```bash
flutter run --flavor dev -t lib/main_dev.dart
```
Expected: app launches with title "CSE/CET Reviewer Dev", placeholder route renders, Firebase initializes (no errors in console). Stop with `q`.

- [ ] **Step 3: Manual flavor smoke (prod)**

```bash
flutter run --flavor prod -t lib/main_prod.dart
```
Expected: app launches with title "CSE/CET Reviewer", uses prod Firebase project (verify in Firebase Console → Realtime Activity if available).

- [ ] **Step 4: Verify CI green (if remote pushed)**

If branch protection + remote are wired (Task 28), confirm:
- Latest push to main shows CI green for: `ci`, `sast`, `osv`
- Coverage gate ≥ 70% (or temporarily relaxed in OPERATIONS.md with explicit note)

- [ ] **Step 5: Confirm Day-1 procedural items have been kicked off**

Open `docs/OPERATIONS.md`. Confirm:
- NPC registration filed (Task 1)
- Apple Developer enrollment paid + submitted (Task 2)
- Google Play Console enrollment paid + submitted (Task 3)
- Pentester RFP sent to ≥ 3 firms (Task 4)

If any are not yet started, **do not tag**. Pause and start them now.

- [ ] **Step 6: Tag the foundation**

```bash
git tag -a v0.0.1-foundation -m "Foundation: scaffolding, services bootstrapped, CI green, Day-1 ops in flight"
git push origin v0.0.1-foundation
```
Expected: tag pushed; `release.yml` workflow runs and produces unsigned artifacts.

- [ ] **Step 7: Update Plan 1 status in OPERATIONS.md**

Add to the top of `docs/OPERATIONS.md`:
```markdown
## Plan completion log

- **Plan 1 (Foundation & Ops)** — completed 2026-05-XX, tagged `v0.0.1-foundation`
```

Commit:
```bash
git add docs/OPERATIONS.md
git commit -m "docs(ops): mark plan 1 complete"
git push
```

---

## Self-Review

### Spec coverage

| Spec section | Plan task(s) | Coverage |
|---|---|---|
| §2 Tech stack | Task 7 (`pubspec.yaml`) | All deps locked |
| §2 Region asia-southeast1 | Task 15, 18 | Firebase projects + rules in region |
| §3.1 Sanity (workspace + roles + 2FA) | Task 19 | Workspace + 2FA done; schema definition deferred to Plan 4 (called out in plan) |
| §3.2 Firestore (region, deny-by-default until rules ready) | Task 18 | Deny-all starter rules; full rules in Plan 7 (called out) |
| §3.3 Drift schema | (deferred — Plan 2) | Acknowledged in "Out of scope" section at top |
| §3.4 FSRS state | (deferred — Plan 2) | Acknowledged |
| §5.1 Folder layout | Task 8 | Mirrors spec exactly |
| §5.2 Layering rules (lint-enforced) | Task 10 | Custom Dart script enforcing R1, R2, R3 |
| §5.3 Module specs | (deferred — Plans 5, 6) | Out of scope; folder placeholders only |
| §5.4 Routing | Task 13 | Skeleton matching spec routes |
| §5.5 Remote Config | (deferred — Plan 2 init, Plan 5 use) | Service enabled in Task 15 |
| §6 Error handling taxonomy | Task 11 | Sealed AppException hierarchy + Result type |
| §7.5 Security testing (gitleaks, Semgrep, osv-scanner) | Tasks 21, 25, 26 | All wired into CI from day one |
| §7.5 Pentest engagement | Task 4 | Booked Day 1 |
| §7.8 CI structure | Tasks 22, 23, 24 | PR + main + release workflows match spec |
| §8 App binary obfuscation | (Plan 8 — release builds) | Out of scope; release workflow exists |
| §8 SQLCipher | (Plan 2) | Dependency declared in Task 7 |
| §8 RA 10173 / NPC | Task 1, 29, 30, 32 | NPC filed, privacy + ToS drafted, DPO designated |
| §10.1 Week 1 timeline | Phase A | All Day-1 procedural items have explicit tasks |
| §13 Branding (no AI attribution) | Task 10 (`check_no_ai_attribution.dart`), Task 31 (README) | Enforced in CI + pre-commit |

### Placeholder scan

Searched the plan for "TBD", "TODO", "fill in", "implement later", "appropriate error handling":
- `TBD` appears in `docs/PRIVACY.md`, `docs/TERMS.md`, and `docs/OPERATIONS.md` — these are intentional, marked as draft/tracker items requiring user-supplied data (NPC reference, team IDs, etc.). Not a plan failure.
- No "TODO", "implement later", or vague-handling language in any task.

### Type consistency

- `AppException` subclasses used consistently across Tasks 10 (no use yet — script only) and 11 (definition).
- `Result<T, E>` API is consistent: `unwrap()`, `unwrapErr()`, `map()`, `mapErr()`, `isOk`, `isErr`. No mismatches.
- `Flavor` enum (`dev`, `staging`, `prod`) consistent across `lib/app/flavor.dart` (Task 12), all three `main_*.dart` files (Tasks 6, 17), and `App` widget (Tasks 12, 13).
- Bundle ID convention (`com.aedwon.csecetreviewer[.dev|.staging]`) consistent across Tasks 6, 16, 27.
- Project IDs (`cse-cet-reviewer-dev`, `cse-cet-reviewer-prod`) consistent across Tasks 15, 16, 18, 32.

### Scope check

This plan covers Week 1 of the 8-week launch timeline (spec §10.1). It produces a working scaffold, three configured managed-service projects, CI/CD baseline, draft legal docs, and kicks off the Day-1 procedural long-poles. Plans 2-8 build on this; nothing in Plan 1 prevents any subsequent plan from starting.

---

## Execution Handoff

**Plan complete and saved to `docs/superpowers/plans/2026-05-07-plan-01-foundation-and-ops.md`. Two execution options:**

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using `superpowers:executing-plans`, batch execution with checkpoints.

**Caveat for both:** Tasks 1-4 (Phase A) require browser interaction with NPC, Apple, Google, and pentest vendors. The agent cannot complete those steps autonomously — those are for you to do, while the agent handles the code work in parallel.

**Which approach?**
