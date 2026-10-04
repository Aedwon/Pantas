# Pantas: everything that is left, 13 August 2026

> **Pricing superseded (4 October 2026).** Prices, plans, and products in this file are historical. The only current prices are in `docs/pricing.md`. Do not quote or implement a price from this file.

> **Updated 22 August 2026.** The continuation checkpoint below records the
> repository state after the August 17 and 21 work. It supersedes older counts
> and status claims in this file. The original handover remains below for its
> history.

**This is the handover document.** Aedwon's Claude subscription ends tomorrow, so
this exists to be read cold by him or by whoever picks the project up next.

**It supersedes `2026-08-02-work-checkpoint.md` and Part 0 of
`2026-08-04-execution-pipeline.md` as the list of what is left.** Those two stay
for their history and for how work gets dispatched.

**Everything here was checked against the repository today**, not copied from an
earlier list. Where an earlier document says something different, this one is
right and the older line is marked stale in place.

---

## Continuation checkpoint, 22 August 2026

### Current state

| | |
|---|---|
| Branch | Local `main` at `35685020`, six commits ahead of `origin/main`; checkpoint and routing documents remain uncommitted |
| Current gates | **2,316 tests pass.** Targeted analysis is clean. Full analysis has the same 106 pre-existing demo and mock issues as `origin/main`. Layering and attribution pass. Six pre-existing files fail the format check |
| Shipping seed | **2,361 questions, 161 lessons**, 26 topics, 32 passages, 7 exams, 1 UPCAT mock blueprint |
| Authored corpus | **2,369 questions.** Eight do not enter the shipping seed |
| Note B | **All six subjects complete. Zero wrong choices are missing Note B** |
| Lesson illustrations | **279 worklist rows, all `todo`.** `content/illustrations/` does not exist |

### Execution routing

Codex owns triage, design, integration and final verification. Use Gemini 3.7
Flash High for settled bulk implementation. Use Gemini 3.1 Pro High for settled
high-risk implementation and independent Flash verification. Ask Aedwon for the
remaining Gemini quota before each wave because `agy` cannot read it. Run two
independent Gemini implementors at a time by default. Drop to one for coupled
work or when less than roughly 25% remains.

The six local commits finish Mathematics Note B, repair 38 invalid or equivalent
wrong choices, add completeness coverage, rebuild both shipping seeds, and make
all seven exams stay active after future seed rebuilds. The seeds contain 2,361
questions, 161 lessons and 7,071 wrong-choice rationales.

### Worktrees and saved work

- `wt-m8` is merged, clean and even with local `main`.
- `wt-m7` is stale and unmerged. Its uncommitted basic-geometric-concepts draft
  overlaps Mathematics work now complete on `main`.
- `wt-s4` is 98 commits behind and its branch is merged. Its uncommitted edit
  rewrites the 42 rationales in characteristics of life, which is complete on
  `main`.
- `wt-m4` and `wt-noteb-rsn2` are merged and stale.
- `.claude/worktrees/nb-s3` is an unregistered leftover copy of cell biology.
  It overlaps work already on `main`.
- `track-a-salvage` is now merged and has no attached worktree. Two stashes
  remain, dated 11 and 18 August.

Do not delete or clean `wt-m7`, `wt-s4`, the unregistered `nb-s3` copy, or either
stash until their uncommitted contents have been reviewed.

### Recommended order

1. Decide whether to commit and push the checkpoint and routing documents.
2. Write an implementation plan for the approved lesson illustration reduction
   spec. Then work through the 279-item list.
3. Wire Firebase startup when Aedwon releases the reserved task.
4. Finish Android signing and internal-track setup.

---

## Part 1: Where the build actually is

| | |
|---|---|
| Branch | `main`, pushed, as of 13 August |
| Tests | **2,268 passing on the 13 August head** |
| Analyzer | clean on the 13 August head |
| `check_layering` | OK |
| `check_no_ai_attribution` | OK |
| Corpus in the seed | **2,216 questions, 161 lessons**, 26 topics, 32 passages, 7 exams, 1 mock blueprint, as of 13 August |
| Parked, not in the seed | **155 questions waiting on figures, as of the first 13 August count** |

**The app runs on the Android emulator and on a physical Android phone.** There is
no Apple developer account, so nothing iOS ships and nothing iOS needs doing.

### What landed in the last two days, so nobody redoes it

- **Dependencies:** `purchases_flutter` 8 to 10, freezed 3, `go_router` 17,
  `flutter_local_notifications` 17 to 22, the safe bumps, and the move off the
  dead `sqlcipher_flutter_libs` onto SQLite3MultipleCiphers.
- **Two unused code generators removed**, `riverpod_annotation` and
  `riverpod_generator`. Nothing ever used them and they blocked everything else.
- **Contact rows:** feedback opens the Facebook group, the DPO row opens mail,
  the old product's addresses are gone from the app.
- **The review popup** is in and asks at most once, after a good session, never
  within a day of the paywall.
- **`question_answered` telemetry**, one event at the single place an answer
  becomes an outcome.
- **Firebase, by Aedwon:** three projects, three Android apps, Analytics on prod,
  Remote Config on all three, Google and Anonymous sign-in, Firestore databases
  in Singapore, and the owner-scoped rules deployed to all three.
- **The Play service account** exists, is invited into Play Console and is Active.

---

## Part 2: The three things that block a release

Nothing else on this page matters until these are done.

### 2.1 Firebase is configured and not wired [Aedwon]

`firebaseConfigForFlavor` returns `null` for every flavor, and the two boot
adapter methods have empty bodies. **So the app boots with Firebase switched
off**: no sign-in, no sync, no crash reporting, no analytics, no force-update
gate, no App Check. All three options files exist and are correct.

Three edits, all in `lib/app/firebase_bootstrap.dart`:

1. Return the right options per flavor.
2. `Firebase.initializeApp(options: ...)` in `initialize`.
3. `FirebaseAppCheck.instance.activate(...)` in `activateAppCheck`.

**Aedwon reserved this for himself on 11 August and it is the only reason it is
not done.**

### 2.2 The Play developer account is not verified [Aedwon]

Identity verification and the device check are unfinished. **They block
production**, and possibly block creating the subscription products. Nothing done
so far needed them, and everything after this point does.

### 2.3 Nothing can be purchased until a build is on a track [both]

**Purchases fail with an unhelpful error for an app that has never been
uploaded**, and the error reads exactly like a credentials problem. Internal
testing is enough. **This needs an upload key and a signed bundle, and neither
exists yet.**

---

## Part 3: The money path, in order

The products are settled: `pantas_pro_weekly` ₱29, `pantas_pro_monthly` ₱99,
`pantas_pro_yearly` ₱799. **Three separate subscriptions, one per billing
period.** The same three strings are hardcoded in the RevenueCat gateway and a
product the app does not recognize is skipped silently, which shows up as an
empty paywall.

1. Create the three subscriptions in Play Console and activate them. [Aedwon]
2. License testers, under Setup, so purchases use test cards and renew on a fast
   clock. [Aedwon]
3. RevenueCat project, the `pro` entitlement, the three products attached to it,
   one offering holding all three. [Aedwon]
4. Upload the service account JSON to RevenueCat. [Aedwon]
5. Real-time developer notifications, then **send the test notification and
   confirm it arrives**. Without that, renewals and cancellations silently never
   reach RevenueCat and you find out in somebody's second month. [Aedwon]
6. The Android public SDK key reaches the app at build time. **Nothing passes it
   today**, so the live gateway configures with an empty key. [a model]
7. Test five flows, each a different code path: a fresh purchase, a renewal, a
   cancellation that stays active to period end, a refund, and a restore after
   reinstall. [Aedwon]

**Credentials can take 36 hours to become valid.** The clock started 12 August.

Full detail: `docs/revenuecat-setup.md`, corrected four times on 12 August.

---

## Part 4: Content, which is where the honest risk is

**Rewritten later on 13 August, after a QA pass. Read this version.**

### What that pass found, and it was not what the old reports said

**The six lesson blockers this audit carried since July are all already fixed.**
Every "underlined word" now says "in bold" and is bold, and both Mathematics
examples list their choices. The reports were stale, not the corpus. They are
marked resolved in place.

**The real finding was the tier boundary.** The answer reveal has two notes. Note
A is the explanation and both tiers see it. Note B sits on the choice the student
picked, appears only on a miss, and is the whole of what Pro adds there.

**No question in the corpus had a note B**, and the pipeline threw the field away
anyway. **A paying student saw exactly what a free one saw, on all 2,369
questions.** The code side is fixed and tested end to end. The content is being
written now, subject by subject.

**Eighteen questions were unanswerable on screen.** Fifteen error-identification
questions had choices that were literally the letters A to E, pointing at markers
inside the stem, and the app reshuffles choices and re-letters them. The row
labelled A could hold the text C. All eighteen now quote the words they mean.

**Twenty-three explanations named choices by letter**, which is wrong on screen
for the same reason and was also giving away note B for free. All fixed, and the
per-option material became the note B it should always have been.

### The answers themselves look sound

**Eighteen questions worked by hand, three from each subject, chosen by seed.**
All eighteen answer keys were correct. That is a sample, not a claim about 2,369,
and it is the only correctness evidence this project has.

### Note B, where it stands

**Completed 22 August.** `python3 tools/audit/note_b_todo.py` reports zero.
General Information, Reading Comprehension, Language Proficiency, Reasoning,
Mathematics and Science are complete. All wrong choices carry Note B.

**Measured rate:** a dispatched run does a mechanical subject in one window and
two files of hard material in the same time. **One note in twenty had a wrong
claim** in the run read line by line, so these are read before they merge.

### The rest of the content backlog

### The approval flag gates nothing

**1,259 questions carry `approved: true` and nothing reads it.** A question
reaches a student whether the flag is true, false or absent.

The recommendation on record is to make the seed skip unapproved questions, so
the review becomes a real gate. **That may empty some subjects**, which is the
point. Aedwon has not ruled on it.

### The correct answer is often the longest

**403 questions**, 17% of the corpus, where the correct choice is more than half
again longer than the longest distractor. A student can score by picking the
longest without reading. Reading Comprehension was fixed on 4 August by
lengthening distractors; **Science 193, Language 104, Reasoning 82 and
Mathematics 24 were not touched.**

`plans/2026-08-13-content-distractor-length.md` is written and Science is running
against it. **The rule is lengthen the distractors, never shorten the answer**,
and the risk it names out loud is a distractor lengthened into a second correct
answer.

### The parked figures, and what 13 August did to them

**155 became 64.** The pile was never 155 drawings: it was ten families of
about fifteen, plus a generator that tagged questions with a figure id whether
they needed one or not.

| | |
|---|---|
| **Drawn by the app** | Gears, springs, levers and pulleys, stability shapes, fluid vessels, shape rows. Six painters, 63 questions |
| **Never needed a figure** | 51 questions whose stems state everything: a ladder with its legs spread, a lever whose distances are in the sentence, a line through two named points. The tag alone kept them out |
| **Still parked** | 64. All but one are the four abstract puzzle families: figure series, matrices, paper folding, 3D rotation |

**Updated 22 August.** The authored corpus carries 2,369 questions and both
shipping assets carry 2,361. Eight authored questions remain outside the seed.
This checkpoint pass counted the gap but did not re-audit the eight questions.

`specs/2026-08-13-drawn-figures-design.md` has the argument and the rules a
painter follows. The order of work at the end of it is still right, and the
four families left are the four it warned would be hardest.

### The lesson illustrations, which are a different problem

`content/illustrations/` is empty. The 22 August worklist has 279 rows and every
one is still `todo`. The approved reduction spec assigns 189 to code painters,
56 to open educational assets, 23 to native Markdown or LaTeX, 8 to cuts, and 3
to founder-drawn assets. It has no implementation plan yet.

### One mock blueprint

`content/mock/upcat.yaml` exists and works. **The other six exams have no paper.**
Sectional timings are on record for UPCAT, USTET, NMAT and CSE; ACET, DCAT and
MSU-SASE were still being asked around for.

### Questions carry no lesson id

They carry a topic id only. Anything that wants lesson-level question data is
blocked until that tagging exists.

---

## Part 5: Code that is written and not reachable

- ~~**The mock results screen is built and mounted nowhere.**~~ **Closed by
  `44dfb1ad` on 21 August.** `/mock/results/:attemptId` now constructs it, and
  the mock panel opens that route for the last attempt.
- **`QuizResultsPage` has no caller.** It is routed and tested and nothing links
  to it. **Nothing in the app lists past attempts**, so a finished attempt cannot
  be opened again. Either past attempts get a list, which is a feature, or the
  page goes. **Aedwon's call, still open** (UI-066).
- **The study plan's providers throw.** `/plan` is hidden on purpose because of
  it. The forward-calendar plan is written and unexecuted.
- **Storage rules are written and undeployed**, because no Cloud Storage bucket
  exists yet. One command when it does.
- **App Check is registered nowhere and enforcement is off**, which is correct
  for now. Turning enforcement on before verified traffic appears locks out every
  install at once.

---

## Part 6: The unexecuted plans

**102 plans exist.** Most are built. These are the ones where the files they name
still do not exist, checked today:

| Plan | State |
|---|---|
| `2026-08-04-study-plan-forward-calendar` | Nothing built |
| `2026-08-02-exam-switching` | The carry-over prompt is missing |
| `2026-05-22-settings-account-plan` | 7 of 22 files missing, including the subscription page |
| `2026-05-21-study-plan-plan` | 4 of 20 missing |
| `2026-06-10-user-facing-metrics` | 4 of 58 missing |
| `2026-05-17-firebase-auth-plan` | 3 of 14 missing, all in the auth core |
| `2026-08-03-foundations-04-accessibility` | Never dispatched |
| `2026-08-11-telemetry-02` Task 3 | `element_tapped`, deliberately deferred |

**Some "missing" files are deliberate.** The lesson list page and the study topic
page were deleted by design, and several names in the older plans were renamed
rather than dropped. **Read the plan before assuming a gap is real**, which is
the standing rule and the source of most wasted rounds on this project.

---

## Part 7: Legal and store, none of it started

All Aedwon's, all outside the repository:

- NPC registration filed and the confirmation recorded.
- `PRIVACY.md` and `TERMS.md` reviewed by a Philippine data privacy lawyer. Both
  exist and neither has been read by one.
- Google Play data safety form.
- DTI business name registration, if trading under a business name.
- Store listing: title, descriptions, feature graphic, screenshots.
- App icon and splash in the Pantas identity.
- A pentest was scoped for June and never engaged.

---

## Part 8: Things that will bite, learned expensively

- **The encryption library is downloaded per checkout.** A failed GitHub download
  stops every tool that opens a database, and the error says "Running build hooks
  failed" with the cause buried ten lines down. CI has no warm copy to borrow.
- **Rebuilding the seed changes its digest** now that the SQLite library changed.
  A test pins the digest to the asset, so they must be committed together.
- **Three artifacts are gitignored and every fresh worktree needs them built**:
  the content database, the localizations and the drift output.
- **A dispatched run's report is not evidence.** Today one reported 23 failing
  tests as pre-existing when the version bump had caused them. Always run the
  gates yourself.
- **`context.push` outside the tab shell, never `context.go`.** `go` strands the
  student with no back arrow.
- **Two content paths exist.** The app ships `assets/seed/v1.json` into the user
  database; the Sanity stack writes `content.db`. Know which one you are looking
  at.
- ~~**25 git worktrees and 54 branches**~~ **Cleaned up 13 August.** **Updated
  22 August:** `wt-m8` is merged and clean. `wt-m7` is stale and overlaps the
  completed Mathematics work. `wt-s4` still has an uncommitted Science edit.
  An unregistered `nb-s3` directory and two stashes also remain. The
  continuation checkpoint gives the exact state.

---

## Part 9: Decisions still waiting on Aedwon

1. **The approval flag**: gate the seed on it, drop it, or leave it.
2. **Past attempts**: build a list, or delete the orphaned results page.
3. **Two numbers in the review popup**: 80% right counts as a good session, and a
   24 hour quiet period after the paywall. Both were chosen by me and neither has
   been ruled on.
4. **Sectional timings** for ACET, DCAT and MSU-SASE.
5. **The device check**: attempt history resolving, Progress showing rows, a
   custom track appearing after one is made, and **the encryption change opening
   the existing database with his data intact.** No test can claim any of them.

---

## Part 10: Deliberately not in v1

Recorded so nobody treats them as gaps: the dynamic templated quiz engine, the
science simulators, Wrapped reframed as achievements, iOS, Apple sign-in,
BigQuery export, A/B testing through Remote Config, in-app ticketing, Filipino
UI strings, and any lifetime purchase. **The lifetime product must never be
created**: a Play product ID cannot be deleted once used.
