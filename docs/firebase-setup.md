# Firebase setup for Pantas

**Everything that has to exist in the Firebase console, and everything that has to be run
locally, before Firebase-backed features can work in a shipping build.**

Written 10 August 2026. Runtime wiring status corrected 28 August 2026.

---

## Read this first

Firebase Core, App Check, Remote Config, telemetry, Authentication adapters and the Auth callable
Functions client are now wired in `lib/`. Firebase startup is deliberately fail-open: if Core
initialization is unavailable, the app keeps a signed-out Auth surface and local-only study
features remain usable.

That code does **not** prove any Firebase or Google Console setting has been enabled. The project,
app registrations, provider settings, OAuth clients, downloaded configuration and deployed
backend resources still have to match the shipping flavor. Treat this document as a setup
checklist, not as evidence of current console state.

**Console names move.** Google regroups the left navigation every so often, and the same
feature has lived under Build, Release and Monitor, Run, and Security in different years. This
document names **what to configure** and gives the current group where it is stable. If a name
here does not match what you see, use the console's search box at the top: it finds features by
name and is faster than hunting the tree.

---

## 0. Runtime package baseline and billing guardrails

The Auth runtime is written for `firebase_auth` 6.x, `google_sign_in` 7.2.x and
`cloud_functions` 6.x. Google Sign-In 7 uses the singleton API, requires an awaited
`initialize()` exactly once, and separates authentication from authorization. Pantas uses only
the authentication ID token for Firebase Auth; it does not request an access-token authorization
path for ordinary sign-in.

The app does not hard-code an Android `serverClientId`. Each shipping flavor instead needs a Web
OAuth client represented in that flavor's `google-services.json` as an `oauth_client` entry with
`client_type: 3`; the Android Google Sign-In plugin uses that configuration to resolve the server
client ID.

**Also set a Blaze budget alert on the day you enable billing.** It caps nothing, because
Firebase has no spending cap, but it decides whether you notice a runaway query in an hour or
in a month.

Scale, cost and the account boundary are worked through in
`docs/superpowers/2026-08-11-data-at-scale-and-the-account-boundary.md`.

---

## 1. The projects

**Three projects, one per flavor.** They must be separate projects, not one project with three
apps, because Remote Config, App Check enforcement and Crashlytics alerting are per project and
you do not want a dev experiment turning on the force update gate for paying students.

| Flavor | Suggested project name | Project ID |
|---|---|---|
| dev | Pantas Dev | `pantas-dev` |
| staging | Pantas Staging | `pantas-staging` |
| prod | Pantas | `pantas-prod` |

**Create each one** from the console home with **Add project**. During creation:

- **Google Analytics: enable it on prod.** Dev and staging can skip it; you will not read those
  numbers and it keeps the noise out. Enabling later is possible, so this is not a one-way door.
- If you enable Analytics, you will be asked to pick or create a **Google Analytics account**.
  One account is enough for all three.
- **Set the project's default location** when prompted, or when you first open Firestore.
  Pick **asia-southeast1 (Singapore)**, the closest region to the Philippines.
  **This cannot be changed afterwards** without creating a new project.

---

## 2. Register the apps

Each project needs the platforms registered. `flutterfire configure` (Section 9) can create
these for you, which is the recommended path, but you need to know the identifiers either way.

### Android application IDs, from `android/app/build.gradle.kts`

**Changed 11 August**, before any store entry existed, and permanent from the
first submission.

| Flavor | Application ID |
|---|---|
| dev | `com.aedwon.pantas.dev` |
| staging | `com.aedwon.pantas.dev.staging` |
| prod | `com.aedwon.pantas` |

### iOS bundle ID, from `ios/Runner.xcodeproj`

`com.aedwon.pantas`, matching Android. **They used to disagree**: Android's
application id said `aerol` while the namespace and iOS said `aedwon`, so the two
platforms would have shipped under different identities.

**A gap worth knowing about:** the Android flavors have three distinct application IDs and iOS
has **one bundle ID for all three flavors**. If you want a dev build and a prod build installed
side by side on the same iPhone, the iOS project needs per-configuration bundle IDs first. On
Android this already works.

### The SHA fingerprints, Android only

Google sign in and App Check's Play Integrity both need the signing certificate fingerprints
registered on the Android app, under **Project settings > General > Your apps > Android app >
Add fingerprint**.

- **SHA-1 and SHA-256 of your debug keystore**, for dev and staging.
- **SHA-1 and SHA-256 of the upload key and the Play app signing key**, for prod. The Play app
  signing key's fingerprint comes from the Play Console, under **Test and release > Setup > App
  signing**. Registering only your upload key is the most common reason Google sign in works in
  debug and fails in production.

```bash
# debug keystore fingerprints
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

---

## 3. Authentication

For **every shipping Firebase project**, enable the providers required by the current runtime
under **Authentication > Sign-in method**:

| Provider | Needed for |
|---|---|
| **Anonymous** | Local-first startup identity and fail-open account lifecycle |
| **Google** | `google_sign_in`, the current named-account sign in |
| **Apple** | Future iOS social sign in; configure when that flow is implemented and required for release |

This repository does not establish whether those providers are already enabled in the console.
Verify each project separately before shipping it.

### Google OAuth requirements per flavor

Each shipping flavor needs all of the following to agree:

- The Android package name from Section 2.
- The correct SHA-1 and SHA-256 fingerprints for the build/signing path.
- A Google support email on the Firebase Google provider.
- A **Web OAuth 2.0 client** associated with that Firebase/Google Cloud project.
- That Web client present in the flavor-specific `google-services.json` under `oauth_client`
  with **`client_type: 3`**.

Do this separately for dev, staging and prod. Do not reuse a Web OAuth client from another
Firebase project just because the package names are similar. Pantas intentionally calls
`GoogleSignIn.instance.initialize()` without a hard-coded `serverClientId`, so a missing
`client_type: 3` entry can surface on Android as a server-client-ID configuration failure.

**Authorized domains**: the defaults are fine for the current Android flow. Nothing in this app
uses a browser-based sign-in flow today.

### Apple, when iOS sign in is implemented

Apple sign in needs, from your Apple Developer account:

- A **Services ID**
- An **Apple Team ID**
- A **Key ID** and the **private key** for a Sign in with Apple key

Apple sign in cannot be finished without a paid Apple Developer membership. It is not part of
the current Android Auth runtime.

---

## 4. Cloud Firestore

**Create the database** under **Firestore Database > Create database**.

- **Production mode**, not test mode. Test mode opens the database to the world for 30 days,
  and this app stores a student's own progress.
- Location: the same **asia-southeast1** chosen above.

### What the app writes

Every synced row is under the signed in user, and the paths are exactly these:

```
users/{uid}/quiz_attempts
users/{uid}/assessments
users/{uid}/fsrs_cards
users/{uid}/lesson_progress
users/{uid}/question_flags
users/{uid}/lesson_bookmarks
```

One collection is not under a user, because it is deliberately public to anyone holding the
link:

```
wrapped_shares/{shareId}
```

The Auth sign-in callable also ensures the named-account root document at `users/{uid}` exists.
It writes only initial account-root metadata such as `createdAt`; Auth does not write study
progress or Pro state. Anonymous Free and named Free study progress remain local-only. Sync
eligibility belongs to the separate Sync runtime and is limited to named Pro accounts.

### Rules

A student may read and write only their own subtree. Shares are readable by anyone with the id
and writable only by their owner.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    match /wrapped_shares/{shareId} {
      allow read: if true;
      allow create: if request.auth != null
                    && request.resource.data.ownerUid == request.auth.uid;
      allow update, delete: if request.auth != null
                            && resource.data.ownerUid == request.auth.uid;
    }
  }
}
```

**Publish these before the first real sign in**, not after.

---

## 5. Cloud Storage

**Set it up** under **Storage > Get started**, same location, production mode.

The only thing the app uploads is the **image for a shared Wrapped card**, written to
`wrapped/{uid}/{shareId}.png`. Rules mirror the Firestore ones: public read, and a student may
only write inside their own folder.

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /wrapped/{uid}/{file} {
      allow read: if true;
      allow write, delete: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

**The record beside it** in Firestore carries `ownerUid`, `storagePath`, `archetypeId`,
`createdAt` and `revoked`, which is what the rules in Section 4 are written against.

**Cloud Storage now asks for a billing account (Blaze plan) on new projects.** The free tier
still covers a small app, but the card has to be on file. If you do not want that yet, the
Wrapped sharing feature is the only thing that breaks.

---

## 6. Remote Config

**Two parameters, and the names must match exactly.** The app reads these and nothing else.

| Parameter key | Type | Default | What it does |
|---|---|---|---|
| `minimum_supported_build` | Number | `0` | Any build below this is stopped at the update screen. **0 blocks nobody**, which is the safe value to publish first |
| `service_message` | String | *(empty)* | One line shown on Home. Empty means there is nothing to say |

**Publish the defaults immediately**, even though they do nothing. A parameter that does not
exist and one set to 0 behave identically in the app, but the first leaves you unable to react
in an emergency without also learning the Remote Config UI under pressure.

**How the app reads them:** once, at launch, with a short timeout, falling back to the values
above if the fetch fails or times out. It does **not** watch for changes live. A gate that
appears while a student is halfway through a three hour mock is worse than one that appears at
the next launch.

**When you do raise `minimum_supported_build`**, remember the number it is compared against is
passed at build time:

```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart \
  --dart-define=BUILD_NUMBER=42
```

If that define is missing the app reports build 1, and every install will think it is out of
date the moment you set a minimum above 1. **Put the define in the release script before you
ever touch this parameter.**

---

## 7. App Check

Find it under **App Check** in the left navigation. It has lived under both the Build and the
Security groups; the console search box finds it either way.

**Register each app** with its provider:

| Platform | Provider | Notes |
|---|---|---|
| Android | **Play Integrity** | Needs the SHA-256 fingerprints from Section 2 and the app present in the Play Console |
| iOS | **App Attest** | Needs the App ID configured in your Apple Developer account |

The app already chooses the provider by flavor: **debug for dev and staging, Play Integrity for
prod.** So dev builds need the **debug provider** registered instead: run the app once, copy
the debug token it prints to the console log, then add it under the app's **Manage debug
tokens**.

**Do not turn on enforcement immediately.** Register the providers, leave enforcement off, and
watch the metrics page for a few days until you can see verified requests arriving. Enforcing
first is how you lock out every existing install at once.

---

## 8. The rest

### Crashlytics

Nothing to configure in the console beyond opening **Crashlytics** and letting it wait for its
first report. The work is local:

- The Crashlytics Gradle plugin is added by `flutterfire configure` on Android.
- **iOS needs the dSYM upload build phase**, or every crash arrives unreadable.
- Crash reports do not appear until the app **crashes once and is then relaunched**. Force a
  test crash rather than assuming it is broken.
- Automatic Crashlytics collection stays disabled. Do not enable it at runtime. When persisted
  consent is true, the app sends the unsent batch manually. When consent is false or unanswered,
  it deletes the unsent batch. A new opt-in deletes the batch before anything can be sent.
- Flutter Crashlytics can check whether an unsent batch exists, then send or delete the whole
  batch. It does not expose report timestamps, consent provenance, or per-report selection.
  Native fatal reports can therefore wait until the next launch before delivery.

### Analytics

Enabled at project creation on prod. The app logs its own named events and **gates all of them
behind consent**, which is unanswered by default under RA 10173: a student who has not agreed
sends nothing.

**Three things that are not obvious**, added 11 August:

- **A custom event parameter is invisible in reports until you register it** as a custom
  definition, under **Analytics > Custom definitions > Create custom dimension**, using the
  parameter's exact name. The event itself arrives either way, so this fails silently: you will
  see the event count and not the breakdown, and conclude the code is wrong.
- **Enabling Analytics on prod only means telemetry cannot be tested in dev.** Either accept
  that events are only ever seen in production, or enable Analytics on the dev project too. If
  you do, use **DebugView** to watch events arrive in real time, which needs
  `adb shell setprop debug.firebase.analytics.app com.aedwon.pantas.dev` on the device.
- **Firebase Analytics caps distinct event names at 500 per project**, and names cannot be
  deleted once used. The app's events are an enum, so the cap is nowhere near, but a future
  event whose name embeds an id would burn through it.

### Adding telemetry later, which needs no console work

Telemetry resolves through an interface with a no-op implementation and a Firebase
implementation. The chooser uses the live Firebase instances when they exist and the no-op
surface when Firebase is unavailable. Consent remains a separate gate.

A new event is one line: a case on the telemetry event enum with its snake_case wire name. Keep
the comment grouping, which is written as the question the event answers rather than the feature
it sits in, because that is what makes an unused event obvious later. Register any new parameter
as a custom dimension per the note above.

Crash reporting needs nothing per call site. Flutter throw sites are funnelled into the shared
reporter and remain consent-gated.

### Cloud Messaging

**Only needed when notifications ship.** For iOS it needs an **APNs authentication key** (`.p8`)
uploaded under **Project settings > Cloud Messaging > Apple app configuration**. Android needs
nothing beyond the registered app.

### Cloud Functions

The app now has an Auth callable client for these functions in exactly
`asia-southeast1`:

- `recordSignInEvent`
- `deleteAccount`
- `exportData`

`recordSignInEvent` and `deleteAccount` are part of the account lifecycle. The export callable
remains backend-compatible but self-service export is **not activated in Settings**; privacy
access requests continue through the DPO path documented in `docs/PRIVACY.md`.

Deploying Functions and enabling any required billing/App Check enforcement are separate
operator actions. This repository state does not prove they have been deployed.

---

## 9. What to run locally, in order

```bash
# once per machine
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli

# once per flavor, from the repo root
flutterfire configure \
  --project=pantas-dev-090126 \
  --out=lib/firebase_options_dev.dart \
  --platforms=android \
  --android-package-name=com.aedwon.pantas.dev

flutterfire configure \
  --project=pantas-staging \
  --out=lib/firebase_options_staging.dart \
  --platforms=android \
  --android-package-name=com.aedwon.pantas.dev.staging

flutterfire configure \
  --project=pantas-prod \
  --out=lib/firebase_options_prod.dart \
  --platforms=android \
  --android-package-name=com.aedwon.pantas
```

**The dev project is `pantas-dev-090126`, not `pantas-dev`.** Project IDs are global and
somebody else holds that one. Created 12 August 2026.

**Android only, and `--platforms=android` says so.** There is no Apple developer account, so the
iOS bundle argument that used to be here only produced prompts about a platform nothing can
ship to.

`flutterfire configure` creates or updates the selected Firebase app configuration, writes the
options file and adds required platform integration where supported. Review the resulting diff
and generated files rather than assuming every console/platform setting was completed.

### The `google-services.json` flavor trap

`flutterfire configure` writes `android/app/google-services.json`; running it again for another
project replaces that file. Pantas needs one file per Android flavor in the flavor source folder:

```bash
mkdir -p android/app/src/staging
mv android/app/google-services.json android/app/src/prod/google-services.json

flutterfire configure --project=pantas-dev-090126 \
  --out=lib/firebase_options_dev.dart --platforms=android \
  --android-package-name=com.aedwon.pantas.dev
mv android/app/google-services.json android/app/src/dev/google-services.json

flutterfire configure --project=pantas-staging \
  --out=lib/firebase_options_staging.dart --platforms=android \
  --android-package-name=com.aedwon.pantas.dev.staging
mv android/app/google-services.json android/app/src/staging/google-services.json
```

After each configure run, inspect that flavor's file and verify both the expected Android client
and the Web OAuth `oauth_client` with **`client_type: 3`** are present. If that Web client is
missing, create/configure it in the matching Firebase/Google Cloud project and re-download the
file rather than hard-coding a client ID in Dart.

`google-services.json` is gitignored, so these files do not reach the repository. CI needs them
supplied securely before it can build Firebase-enabled releases.

### Runtime wiring status

The code side of Firebase bootstrap is already wired:

1. `firebaseConfigForFlavor` in `lib/app/firebase_bootstrap.dart` selects the generated options
   for dev, staging or prod.
2. `FirebaseSdkBootAdapter.initialize` calls `Firebase.initializeApp(options: ...)`.
3. App Check activation is owned by `lib/core/platform/app_check.dart` and selects the configured
   provider by flavor.
4. `lib/app/auth_bootstrap.dart` installs Firebase Auth, Google Sign-In and callable Functions
   adapters only when Core initialized successfully. It otherwise installs a stable unavailable
   Auth repository and leaves local app surfaces usable.
5. When Firebase is configured and no cached Auth user exists, startup attempts anonymous sign-in
   best-effort. A failed anonymous sign-in does not prevent `runApp()`.

Do not interpret those code facts as confirmation that any provider, OAuth client, App Check
registration, ruleset or Function has been enabled or deployed in the console.

**Do not commit generated project configuration merely because this checklist mentions it.**
Follow the repository's existing generated-file and secret-handling rules.

---

## 10. The order I would do it in

**Android only.** There is no Apple developer account, so skip Apple sign-in, App Attest and the
APNs key entirely. They are not blockers for the current Android release.

**Link the BigQuery export on the day you create the project.** It is free in the sandbox and
**it is not retroactive**: analytics data from before you link it can never be imported, and the
Firebase console alone cannot answer questions of your own shape. This is the cheapest thing
here to get right and the most expensive to get wrong.

**Backup is Pro only**, decided 11 August, so study-progress Sync is eligible only for students
who are both signed in and Pro. Authentication itself does not upload or reconcile study
progress. Anonymous Free and named Free stay local-only.

1. Create or verify the Firebase project for the flavor you are preparing.
2. Enable **Anonymous** and **Google** Authentication, register the correct fingerprints, and
   verify the flavor's Web OAuth client / `client_type: 3` entry.
3. Create Firestore with the approved rules before relying on named-account roots or Sync.
4. Configure Remote Config with both parameters at their safe defaults.
5. Configure Crashlytics and force one consent-controlled test crash when release verification
   reaches that stage.
6. Register App Check but do not enforce until verified traffic is visible.
7. Storage, only when Wrapped sharing matters.
8. Messaging, only when notifications ship.

**Not Firebase, and often confused with it:** the paywall runs on RevenueCat with products
defined in the Play Console. That has its own document, `docs/revenuecat-setup.md`, including
the Google Cloud service account that has to be invited into Play Console before RevenueCat can
see a subscription.

A student can subscribe without ever signing in, because entitlement comes from the store and
the device rather than from an account. The paywall does not wait on Firebase Auth.

---

## Sources

- [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup)
- [App Check default providers, Flutter](https://firebase.google.com/docs/app-check/flutter/default-providers)
- [Firebase Remote Config](https://firebase.google.com/docs/remote-config)
- [Learn about locations for products and resources](https://firebase.google.com/docs/projects/locations)
