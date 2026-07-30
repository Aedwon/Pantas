# Dependency audit, and the order to upgrade in

**11 August 2026.** Aedwon asked for everything to be brought up to date, prompted
by the FSRS version being wrong once before.

**FSRS is not wrong now.** The scheduler carries 21 weights, w0 through w20, the
same-day review formula and the review log table. **That is FSRS-6.** FSRS-4.5 has
17 weights. It was corrected on 9 August.

**But the audit found something worse than an old version**, in Group D below.

---

## The finding: the encryption package is deprecated, not just old

**`sqlcipher_flutter_libs` is end of life.** From 0.7.0 the package **does
nothing**: it is a no-op kept on pub so dependents can move off the old build
scripts.

**The replacement is not a swap.** From drift 2.32 and `sqlite3` 3.x, encryption is
done with SQLite3MultipleCiphers instead. **SQLCipher no longer has a
straightforward setup**, though existing SQLCipher databases can still be opened
through the new library.

**Why this is the dangerous one.** The user database on every device is encrypted
with the current stack. **Getting this wrong means an installed app cannot open its
own database**, and the data is not recoverable from the app. It is also entangled
with the drift and sqlite3 upgrades, so those cannot be treated as routine minors.

**This wants its own round with its own migration test**, proving a database
written by the old stack still opens under the new one. **It must not be bundled
into a general upgrade sweep.**

---

## Why "update everything" is staged rather than done at once

**Thirty-one direct dependencies are behind, and eleven of them by a major
version.** Doing them together produces a diff nobody can review and a red suite
with no way to tell which upgrade caused what.

**`very_good_analysis` 6 to 10 goes last for its own reason**: it changes the lint
rules for the whole repository, so it will light up hundreds of findings across
code the other upgrades are still touching.

---

## Group A: safe, mechanical, do together

No API change expected. One commit, one test run.

| Package | From | To |
|---|---|---|
| `dio` | 5.9.2 | 5.11.0 |
| `path_provider` | 2.1.5 | 2.1.6 |
| `uuid` | 4.5.3 | 4.6.0 |
| `json_annotation` + `json_serializable` | 4.9 / 6.9 | 4.12 / 6.14 |
| `build_runner` | 2.5.4 | 2.15.1 |
| `intl`, `meta` | patch | latest |

## Group B: one family at a time, each its own branch

Each is a real migration. **None of them blocks the beta**, because none is wired
to anything live yet.

| Package | From | To | Note |
|---|---|---|---|
| `firebase_*` and `cloud_*` | one major behind, all of them | latest | **Do before wiring Firebase, not after.** The adapters are empty today, so this is a bump and a test run |
| `google_sign_in` | 6.3 | 7.2 | A rewrite, not a bump: singleton, awaited `initialize`, authentication split from authorization, `serverClientId` on Android. Lands in one gateway adapter here |
| `purchases_flutter` | 8.11 | 10.8 | Same logic: before the products exist, not after, when real money is attached |
| `flutter_local_notifications` | 17.2 | 22.3 | **Five majors.** Expect the scheduling API to have moved |
| `flutter_secure_storage` | 9.2 | 11.0 | Holds the database key. Read its migration notes before bumping |
| `app_settings`, `sign_in_with_apple`, `timezone` | | | Small surface, low risk |

## Group C: central, and each deserves a quiet branch

| Package | From | To | Why it is its own round |
|---|---|---|---|
| `flutter_riverpod` + annotation + generator | 2.6 | 3.4 | Riverpod 3 is a large migration and every provider in the app is one |
| `go_router` | 14.8 | 17.5 | Three majors, and routing is where a mistake is invisible until a screen is opened |
| `freezed` + `freezed_annotation` | 2.5 | 3.2 | Codegen change across every model |

## Group D: the encryption stack, and it is not an upgrade

`drift` 2.28 to 2.34, `sqlite3` 2.9 to 3.5, and **removing
`sqlcipher_flutter_libs` in favour of SQLite3MultipleCiphers.**

**Done together or not at all**, and gated on a test that opens a database written
by the current stack. See the finding above.

## Group E: last

`very_good_analysis` 6 to 10, alone, after everything else has settled.

---

## The one-way thing that is not a package

**The Android `applicationId` and the iOS bundle id still carry the old name, and
they disagree with each other**: `com.aerol.csecet` on Android's application id,
`com.aedwon.cse_cet_reviewer` on Android's namespace, `com.aedwon.cseCetReviewer`
on iOS.

**These can never be changed once the app is published.** They are the store's
permanent key for the listing, its reviews and its subscribers.

**And the window is closing this week**, because creating the Play Console entry
for RevenueCat fixes the application id permanently. **This needs deciding before
that step, not after.**
