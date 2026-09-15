# iOS Physical QA Enablement Decision Log

**Date:** 2026-09-15  
**Status:** Approved by Aedwon  
**Exact planning baseline:** `web/e09-security-performance-verification-r1@5de8df1936be1fc6a40e100fb4624fe89a3516c0`  
**Implementation branch:** `web/ios-physical-qa-enablement-r1`

This log records the decision to add a bounded iPhone development and QA lane without turning the current Android release program into an iOS/App Store release program.

## 2026-09-15 - Scope selection

Three options were presented:

1. **Minimal** — pair/sign one physical iPhone and obtain one smoke launch. Roughly 4-5 acceptance checks. Lowest setup cost, but it would not establish flavor parity, Firebase connectivity, protected-storage behavior, or practical repeated QA.
2. **Balanced** — create a usable dev/staging iPhone QA lane: proper schemes and bundle IDs, inspect/connect iOS Firebase registrations, physical debugging, Keychain/encrypted-SQLite verification, and VM-service Pro switching. Roughly 8-12 acceptance checks. This adds meaningful cross-platform QA while avoiding App Store-release work.
3. **Hardened** — Balanced plus all-flavor/service/recovery validation and broader iOS release hardening. Highest coverage, but it becomes a separate iOS-readiness program and would distract from E09/E10 Android closure.

**Recommendation presented:** option 2.

**Aedwon's response, verbatim:** "2"

### Decision

Adopt **Option 2, Balanced**.

The purpose is to make a physical iPhone useful for development and regression testing now. It is not authorization to prepare or ship an App Store build.

## Relationship to E09/E10

The Android release program remains authoritative.

- E09 still requires the specified physical lower-end Android security/performance evidence.
- iPhone evidence is supplementary and does not satisfy any Android-only E09 acceptance target.
- E10 remains blocked until E09 closes on its unchanged accepted Android candidate.
- The iOS QA setup is isolated on `web/ios-physical-qa-enablement-r1`. It must not be merged into the active E09 candidate merely to make iPhone testing available.
- If iPhone testing finds a shared product defect, repair it on the appropriate dedicated product branch rooted from the current E09 candidate. Reintegrating a shared-source fix requires the normal affected E09 evidence to be rerun.
- A later decision to merge the iOS platform-enablement work into the release candidate changes source identity and must be handled as a deliberate release-stage transition, not an incidental QA change.

## Frozen Balanced scope

The accepted scope is:

- finish current Xcode first-run, command-line-tool, license, and iOS-platform setup;
- pair one physical iPhone, enable Developer Mode, and configure local development signing;
- use an Apple Personal Team for local physical-device QA unless Aedwon later enrolls in the paid program;
- add proper shared Xcode **dev** and **staging** schemes with their own build configurations;
- use `com.aedwon.pantas.dev` and `com.aedwon.pantas.staging` so both QA builds can coexist on the phone;
- keep the existing production/Runner path outside the required Balanced acceptance surface;
- raise the iOS QA deployment target to the minimum required by the resolved current Firebase/FlutterFire stack when implementation proves it. Current Firebase Flutter documentation requires iOS 15 or later, while the repository still says iOS 13;
- inspect Firebase first and reuse matching iOS app registrations where they already exist; do not create duplicates;
- configure the dev and staging generated Firebase options for iOS while preserving their existing Android options;
- make Firebase bootstrap choose the current platform instead of hard-coding Android;
- use the App Check debug provider for the dev QA build and keep any debug token private;
- treat staging backend/App Check proof as conditional on valid staging attestation/configuration. Local staging UI/content QA does not depend on completing production-grade DeviceCheck setup;
- verify local user/content storage on the physical iPhone, including Keychain-backed secure-storage behavior, protected content open/reopen, and ordinary unkeyed SQLite rejection where the development container can be inspected;
- observe uninstall/reinstall Keychain behavior instead of assuming that iOS deletes secure-storage items with the app;
- use the existing `tools/pro` VM-service override path through its `VM_SERVICE_URI` input. Do not add an iOS-specific entitlement switch unless the existing generic VM-service path actually fails;
- run a bounded physical smoke/regression matrix and record text evidence. Aedwon performs the visual check.

## Firebase boundary

This lane is not a full iOS service-porting program.

Required Firebase proof for Balanced scope is limited to Firebase Core initialization and a narrow dev smoke of the already-used app runtime, such as anonymous Auth/Firestore connectivity when available.

Explicitly outside this decision:

- Google Sign-In iOS production setup;
- Sign in with Apple rollout;
- production DeviceCheck/App Attest provisioning;
- APNs keys;
- Firebase Cloud Messaging push validation;
- iOS RevenueCat products or purchase lifecycle;
- TestFlight;
- App Store Connect;
- App Store privacy labels;
- App Store signing/distribution certificates;
- production iOS release acceptance.

Those are separate future decisions.

## Protected-content boundary

The accepted protected package must not be regenerated for this QA lane.

- Reuse the exact accepted `content.db`, manifest, and detached signature already required by E09.
- Use only the bootstrap key for authorized app testing.
- Do not load or expose the signing seed for an ordinary iPhone build.
- Do not log secret values or place them in Xcode project files, schemes, committed xcconfig files, shell history, or screenshots.
- A different protected-package identity is not accepted merely because it contains the same logical corpus.

## Personal-Team operational note

A free Apple Personal Team is acceptable for local QA. Its provisioning is temporary and must be renewed periodically. Exact Apple account limits are operational facts that may change, not permanent Pantas product policy.

The Balanced lane therefore optimizes for repeatable local device testing, not long-lived distribution.

## Cost / consequence

This choice adds a small parallel platform-enablement branch and some native project configuration. It does **not** move the Android release gate, does not authorize App Store work, and does not justify broad cross-platform refactoring.

The main expected payoff is earlier detection of platform-specific storage, lifecycle, routing, rendering, and Firebase/bootstrap defects while E09 is still being closed.
