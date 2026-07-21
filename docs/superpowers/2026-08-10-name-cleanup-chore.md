# Chore: retire "CSE/CET Reviewer" as the app's name

**Raised by Aedwon, 10 August 2026.** The app is called **Pantas**. The old
working name survives in the package name, the bundle identifiers, the display
name and a long tail of documentation.

**His instruction, verbatim:** *"the app folders and routes and other things
still call it CSE/CET Reviewer which was an old name when it should be Pantas
only. there are other naming like cse_cet or something so can you add that as a
sort of chore to clean up? do carefully check and not just simply change that
because for its specific context a combo like that might not apply to this
situation"*

**He is right to warn about it, and the survey below proves the warning.** A
blanket find-and-replace on `cse`, `cet` or `CSE/CET` would corrupt real content
and orphan real user data. This document sorts every site into what is safe,
what is one-way, and what must never be touched.

---

## Tier 0: never touch. These are not the old app name.

**CSE and CET are the actual exams.** The app is a reviewer *for* them, so the
letters appear throughout as subject matter rather than as branding.

- **Exam identifiers in the seed and the database**: `exam_cse_pro` and
  `exam_cse_sub` are the Civil Service Examination, Professional and
  Subprofessional. **They key the user's own attempt history.** Renaming them
  silently detaches every stored attempt from its exam.
- **Lesson content.** "Civil Service" appears throughout General Information,
  including the constitutional articles on the Civil Service Commission. This is
  prose about the Philippine government, not a product name.
- **Question text and explanations**, for the same reason.

**Rule for the implementor: a match is only in scope if it names the
application. If it names an exam, a topic or a government body, leave it.**

## Tier 1: safe, mechanical, and the bulk of the work

- **The Dart package name.** `pubspec.yaml` says `name: cse_cet_reviewer`, and
  every import in the repository begins `package:cse_cet_reviewer/`. Renaming it
  to `pantas` is a single find-and-replace over that exact prefix plus the one
  pubspec line. **It is large but it is unambiguous**, and the analyzer catches
  any miss immediately.
  - **`tool/check_layering.dart` hardcodes the prefix in four regexes.** It will
    pass vacuously if the package renames and the tool does not.
- **Documentation and the plan archive.** Cosmetic, no risk.

## Tier 2: one-way, and the window is open only until launch

- **Android `applicationId`**: `com.aerol.csecet`, `.dev`, `.dev.staging`.
- **Android `namespace`**: `com.aedwon.cse_cet_reviewer`.
- **iOS `PRODUCT_BUNDLE_IDENTIFIER`**: `com.aedwon.cseCetReviewer`.

**Three problems here, not one.**

1. They carry the old name.
2. **They disagree with each other.** Android's application id uses `aerol`,
   Android's namespace and iOS both use `aedwon`, and the two platforms would
   ship under different identities.
3. **An application id and a bundle id can never be changed once the app is
   published.** They are the store's permanent key for the listing, its reviews
   and its subscribers.

**So this must happen before the first store submission or never.** It also
means redoing the Firebase apps, the RevenueCat app entries and the signing
setup, none of which exist yet. **Doing it now is cheap. Doing it after launch
is impossible.**

Downstream references live in `codemagic.yaml`, `CONTRIBUTING.md`,
`docs/OPERATIONS.md`, the two onboarding `.command` scripts and
`test/tool/firebase_config_layout_test.dart`.

## Tier 3: user-visible, and trivially safe right now

- `lib/app/flavor.dart` prints **"CSE/CET Reviewer"**, plus Dev and Staging
  variants. This is the name on screen.
- iOS `Info.plist`: `CFBundleDisplayName` is **"Cse Cet Reviewer"** and
  `CFBundleName` is **"cse_cet_reviewer"**. The display name is what sits under
  the icon on the home screen.
- Android's manifest points at `@string/app_name`, and **no `strings.xml` was
  found**, so where the Android label resolves from needs checking before this
  is planned.
- `pubspec.yaml`'s description says "Gamified Philippine exam reviewer", which
  never named the app but predates the current positioning.

**These are safe today because nothing is installed from a store.** A dev build
renaming itself just reinstalls.

---

## Sequencing, when it gets planned

**Tier 3 first**, on its own, because it is what he sees on the emulator and it
carries no risk. **Tier 2 next and before any store work**, since the window
closes at first submission. **Tier 1 last**, because it is the noisiest diff in
the repository's history and should not be tangled with anything that needs
review.

**Not started.** No plan written.
