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

**Two things checked after writing that, and both lower the risk.**

**One: there is no longer any data to preserve.** The database file was renamed to
`pantas.db` on 11 August, so the only install in existence starts from an empty
database anyway. **The migration test I said this needed was for keeping existing
data, and there is none.** What remains is making encryption work under the new
library, not migrating anything into it.

**Two: the opener fails closed, loudly.** After setting the key it runs
`PRAGMA cipher_version` and throws `StateError('SQLCipher not loaded')` when the
cipher is absent. **So a botched upgrade crashes at launch rather than silently
writing an unencrypted database**, which was the failure I had assumed and should
have checked before writing it down.

**What is still true:** the upgrade cannot be done incrementally. Bumping
`sqlcipher_flutter_libs` to 0.7.0 alone makes the loader a no-op, the guard fires
and the app will not start. **The package removal, the drift bump, the sqlite3 bump
and the move to SQLite3MultipleCiphers are one change or none.**

**Revised: this is now dispatchable**, and its verification is that the app opens
an encrypted database and the guard still fires when the cipher is missing.

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

## The order above is wrong, found 11 August by dispatching it

**The encryption group cannot go next.** A Pro run stopped on Task 1 when
`flutter pub get` refused to resolve, and the chain behind it is four packages
deep. Each link was read from pub's own failure, not guessed:

1. `drift_dev` 2.34 needs `build` 3 or newer. `freezed` 2 pins `build` to 2.
2. `freezed` 3 needs `freezed_annotation` 3. `purchases_flutter` 8 forbids it.
3. `purchases_flutter` 10 clears that. Then `build_runner` 2.15 needs `build` 4,
   and `riverpod_generator` 2 pins it to 2.

**So the real order is `purchases_flutter`, then `freezed` 3, then Riverpod 3,
and the encryption group last.** That is close to the reverse of what this
document said. Group C was written as "central, deserves a quiet branch", which
read as "later". It is a prerequisite.

**The last link is unverified.** The probe was stopped before Riverpod 3 was
tried, so the chain is known to be at least that long and may be longer.

## Group D: the encryption stack, one change or none

`drift` 2.28 to 2.34, `sqlite3` 2.9 to 3.5, and **removing
`sqlcipher_flutter_libs` in favour of SQLite3MultipleCiphers.**

**Not incremental.** Bumping the EOL package alone makes the loader a no-op and the
opener's guard stops the app at launch. See the finding above for why this is now
lower risk than it first looked.

## Group E: last

`very_good_analysis` 6 to 10, alone, after everything else has settled.

---

## The one-way thing that was not a package: settled

**Done 11 August, hours after this was written and before any store entry existed.**
All three identifiers are now `com.aedwon.pantas`. They had disagreed with each
other, so the two platforms would have shipped under different identities.

Recorded in `2026-08-10-name-cleanup-chore.md`.
