# Pantas: everything that is left, 13 August 2026

**This is the handover document.** Aedwon's Claude subscription ends tomorrow, so
this exists to be read cold by him or by whoever picks the project up next.

**It supersedes `2026-08-02-work-checkpoint.md` and Part 0 of
`2026-08-04-execution-pipeline.md` as the list of what is left.** Those two stay
for their history and for how work gets dispatched.

**Everything here was checked against the repository today**, not copied from an
earlier list. Where an earlier document says something different, this one is
right and the older line is marked stale in place.

---

## Part 1: Where the build actually is

| | |
|---|---|
| Branch | `main`, pushed, 1,371 commits |
| Tests | **2,268 passing** |
| Analyzer | clean |
| `check_layering` | OK |
| `check_no_ai_attribution` | OK |
| Corpus in the seed | **2,216 questions, 161 lessons**, 26 topics, 32 passages, 7 exams, 1 mock blueprint |
| Parked, not in the seed | **155 questions waiting on figures** |

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

| Subject | Questions | With note B |
|---|---|---|
| General Information | 156 | **all** |
| Reading Comprehension | 192 | **all** |
| Language Proficiency | 319 | in progress |
| Reasoning | 244 | 90 |
| Mathematics | 713 | 69 |
| Science | 777 | 0 |

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

### 155 questions are parked on pictures that do not exist

`content/illustrations/` is empty. The workflow is decided: hand-made in Canva,
PowerPoint or Illustrator, never AI-generated, then through the Illustration
Studio. **Nobody has drawn one.**

### One mock blueprint

`content/mock/upcat.yaml` exists and works. **The other six exams have no paper.**
Sectional timings are on record for UPCAT, USTET, NMAT and CSE; ACET, DCAT and
MSU-SASE were still being asked around for.

### Questions carry no lesson id

They carry a topic id only. Anything that wants lesson-level question data is
blocked until that tagging exists.

---

## Part 5: Code that is written and not reachable

- **The mock results screen is built and mounted nowhere.** Nothing constructs
  it, so the review popup has no place to fire after a mock.
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
- ~~**25 git worktrees and 54 branches**~~ **Cleaned up 13 August.** 26 merged
  worktrees removed and 57 merged branches deleted. What is left is `main`, the
  worktrees of whatever is running, and **`track-a-salvage`**, which is not
  merged and dates from 10 August. It carries a custom-track storage migration
  and its own test. **Nobody has decided whether the content work that merged on
  11 August superseded it.** That decision is still open.

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
