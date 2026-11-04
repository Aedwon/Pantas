# Custom exams on web: server support. Design spec and implementation plan

**Date:** 4 November 2026
**Status:** Approved by Aedwon on 4 November, with the choices in 1.3. Revised the same day for by-part clocks. Server window in progress on `web/custom-exam-r1`.
**Decision that started it (Aedwon, verbatim):** "also, C for the custom exam. it should have been available from the start"
**Policy revision read:** `origin/main` d5869662c (`AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`, `docs/workflow/orchestrator.md`).
**Code read at:** `web/visual-check-fixes-r1` dceca3948 (same commit as `web/staging-candidate-r1`).
**Content read at:** `origin/content/cse-rewrite-r1` 7032eec5, built into catalog documents with the real uploader into a scratch folder. Hosted Firestore was not read: this Mac has no Google application-default login.
**Amends:** `docs/superpowers/specs/2026-08-02-custom-exam-track-design.md` for web only. Its behavior rules stay.
**Investigation checked:** `custom-exam-options.md` in the same folder. Corrections are in Part 1.4.

---

# Part 1. Plain-language section for Aedwon

## 1.1 What this delivers

A student types their own exam, ticks subjects, and everything works on web the same way it works for CSE:

- Home, Plan, Today, Quiz, the mock, Record and Performance all load from the server.
- The track stays after a reload, in another browser, and on a phone.
- The student can move between a listed exam and their own track, in both directions, from Settings.
- The mock uses the student's own numbers, with the same Free cooldown as a listed exam on that platform.
- The picker never offers a subject with no questions.

Web stays server-authoritative. No figure is computed in the browser.

## 1.2 The rules this keeps from the 2 August spec

- Free and uncapped. A custom track has no Pro gate on studying.
- Narrowing filters and never deletes.
- A request larger than the ticked subjects hold is refused at setup, with the link to Settings.
- The mock has no readiness verdict.
- The name typed is the student's. Nothing asks them to submit it.

One fact you should know: the 2 August text says 14 days. Web's listed exams wait 30 days. "Same as a listed exam" therefore means 30 on web and 14 on the phone until those two are aligned. The cooldown counts mocks across all of a student's exams, so making a new track does not reset it.

## 1.3 Choices Aedwon made (4 November)

Recorded with his exact words in `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`.

| Choice | Decision | What it means |
|---|---|---|
| 1. Content | 1A, whole corpus | 6 subjects, 3,406 questions, including about 2,060 questions and 100 lessons that have not had the CSE audit. Verbal Ability, which has no question on web, is not offered |
| 2. Pro | 2A, always Free | Every student on a custom track gets Free depth. The Pro page says the track is free. Switching a paying student to a custom track warns them first. No paid access can come out of a custom track |
| 3. "Timed separately" | 3B, build by-part clocks on the server | See below. This replaces the default in the first draft of this document |
| 4. Beta | Hide the row until ready | "My exam isn't on this list" is hidden on web for the beta until this ships |
| 5. Complexity | Balanced plus by-part clocks | About 10 working days |

**How by-part clocks behave.** They apply only when a student's own paper has two or more parts and "timed separately" is on. Listed exams and one-clock papers do not change.

- Each part has its own limit, from the minutes the student set. One part runs at a time.
- When a part's time ends, the server closes it and moves to the next. A closed part never reopens, and its answers can no longer change.
- The questions of a later part cannot be answered yet. The server keeps only answers for the part that is running.
- The last part's time ending finishes the paper, scored on what the server holds.
- Without Strict mode, the student may pause, and may end a part early. The between-parts screen waits for the student, with the clock stopped. This matches the phone.
- With Strict mode, there is no pause and no ending a part early.
- The app can never add time. The server alone decides when a part started and ended. It ignores any time the browser reports.

**The Strict break, approved by Aedwon on 5 November: option A, 60 seconds.** The phone stops the clock at the between-parts screen with no limit. It relies on the phone noticing when the student leaves the app. The server cannot see that. A Strict student could sit on that screen and rest or look things up for as long as they like.

| Option | Behavior | Cost |
|---|---|---|
| A. Strict break of 60 seconds (approved, built) | The next part starts by itself after 60 seconds. Without Strict mode, the wait has no limit | Differs from the phone. 60 is our choice, not a published figure. It is one number to change |
| B. No limit | Same as the phone | A Strict student can rest or look things up between parts for as long as they like |
| C. No break | The next part's clock starts when the last one ends | The student loses a few seconds to the between-parts screen on each part |

## 1.4 Where the investigation was wrong or incomplete

Wrong:

1. **"Web ships CSE only" and "web value is low."** The approved upload root holds all 170 sets and 8 exam catalogs. Only the listed-exam picker is limited. The web custom picker offers 7 subjects today, and one of them, Verbal Ability, has no question on web. A student who ticks only that gets nothing. Hosted content still needs one read to confirm.
2. **Using the older content reader for the mock.** The older reader names topics `topic_cse_pro_algebra`. The client sends catalog names, `topic_upcat_algebra`. Feeding one into the other gives empty pools. Custom content must use the catalog reader everywhere.
3. **Topic id mismatch as the main risk, and having the client send included topics.** The catalog has one shared set of 26 topic ids, so there is nothing to tie-break on the server. The existing "excluded" list works.
4. **Failed sessions as "telemetry noise".** A refused session is marked rejected on that browser forever. Sessions already refused would never reach the server after this fix without a specific change, which this plan makes.
5. **Size.** About 12 server files and 20 client files, not 9 and 4 to 6.

Missed:

6. **A reload loses the track on web.** The web content database lives in memory and the custom exam row is written only when the track is made. After a reload the app cannot find the exam and sends the student back to onboarding. Found by reading the code. The first client task proves it with a failing test.
7. **No way in from Settings, and no way back.** "My exam isn't listed" in Settings goes to an onboarding address, and the router sends finished students to Home. The picker never lists a track the student already made.
8. **Free students do not sync.** Sync requires Pro. So a phone track reaches web only if the server holds it, which this design adds.
9. **A mock with overlapping parts breaks results.** Two named parts can draw the same question, and the results reader then fails with "Saved mock results are not available". The sampler also runs short without saying so when a topic is small. Both violate the refuse-at-setup rule, and the server paper builder now prevents both.
10. **A student who switched from CSE to custom before this ships stays stuck** unless the server sends them through the existing recovery path. It now does.

Correct as written: the eight rejecting call sites, the 14 and 30 day split, `getMockResults` working by mock id, `coversExam` returning false, Option B's seam objection.

## 1.5 Delivery

- Balanced plus by-part clocks: about 10 working days of worker and review time, 75 hours, sequential where noted.
- Earliest staging: about 13 November, if preview approvals come by 7 November. The beta starts 9 November with the row hidden.
- Outside-facing steps wait for your explicit approval: each deploy to staging or production.

## 1.6 How it will be judged complete

- A new student on web, wide and phone, makes a track, reaches Home, reloads, studies, sets up and takes a mock, sees results, review and Record.
- That student opens a second browser, finds the track, and sees the same plan and mock.
- CSE students see no change in any response field or in any test.
- One student cannot read or change another student's track, proved by test.
- No request from the browser can add time to a by-part paper, or change a closed part's answers, proved by test.
- All required checks pass, and the Astra audit findings are resolved.
- You accept the screens.

---

# Part 2. Agent section

## 2.1 Verified baseline

Facts below were read in code or computed from the real content. "By reading" means not run.

**Content, from `catalogItems` on the approved root:**

| Fact | Value |
|---|---|
| Catalog documents | `index` plus `exam_cse_pro`, `exam_cse_sub`, `exam_upcat`, `exam_acet`, `exam_dlsucet`, `exam_ustet`, `exam_dost_sei`, `exam_pupcet` |
| Total size | 1.13 MB of JSON across 9 documents, largest 230 KB, no parts |
| Union | 170 sets, 3,406 unique questions, no duplicate ids, 170 lessons, every set's lesson present |
| Lessons live in | `exam_upcat` (130) and `exam_cse_pro` (40) only |
| Topic ids | 26 in `index`, all `topic_upcat_*` except `topic_cse_vocab` |
| Subject ids | `subj_upcat_*` plus `subj_cse_verbal`, each owned by one exam |
| Empty on web | `subj_cse_verbal` ("Verbal Ability") and `topic_cse_vocab`: no set in any catalog. Native has 2 demo questions from `historical_v1.json` |
| By subject | Science 1,023, Mathematics 920, General Information 463, Language Proficiency 400, Reasoning 340, Reading Comprehension 260 |
| CSE-tagged only | 67 sets, 1,343 questions: General Information 463, Language Proficiency 400, Mathematics 240, Reasoning 240 |
| Smallest topics | verbal logic 20, clerical 40, data interpretation 40, peace and human rights 40 |
| All-passage topics | text types 100, comprehension skills 160 |

**Two topic id systems exist on the server, and only one is usable here:**

- `loadExamContent` (`_examContent.ts:29`) builds `topic_<exam>_<slug>` from `content/questions/items`. It serves `build`, `ingestSession` and `assemblePaper`. Listed mock blueprints use these ids (`content/mock/cse-pro.yaml`).
- `loadStudyContent` (`_examContent.ts:95`) reads catalogs and uses `topic_upcat_*`. It serves `studyContext`, insights, diagnosis, carry count and settings validation.
- The client's content database holds the catalog ids. A custom track therefore uses `loadStudyContent` semantics everywhere and never `loadExamContent`.

**Ownership today:** every server path is `users/{uid}/server/...`, chosen from `auth.uid`. `assertStudyOwner` compares `expectedUid` with the token. Rules deny all client access to `users/{uid}/server/**` (`firestore.rules:158`).

**Web client facts:**

- The content database is in memory and rebuilt at each start (`content_database_memory_web.dart`, `web/README.md`).
- `CustomTrackRepository` projects the exam row at create, rename, scope change, and on a retry marker only. `_recoverProjection` runs `retryPendingProjections`, which reads markers. After a reload no marker exists, so `listExams` has no custom row and `activeExamFocusProvider` returns `needsSelection`. The router then redirects to `/onboarding` (by reading).
- `examPickerCatalogProvider` reads `content/exams/catalog.json` only, so custom tracks never appear in the picker.
- `/onboarding/custom/name` is under `/onboarding/`, and `router.dart` sends `passed && complete && atOnboarding` to `/home`. The Settings picker's custom row calls `context.push('/onboarding/custom/name')` (by reading).
- `CustomTrackRepository.create` excludes every row of `contentTopics` not included, so its excluded list contains `topic_cse_vocab` when that subject is not ticked.
- `StudyObservations._send` writes `rejected` under `home_sent_<uid>_<token>_<id>` for permanent codes including `invalid-argument`, then never retries.
- Sync needs a live `pro` claim (`canWriteSyncRow`, `canReadSyncRow`). `selected_exam_id` is an account pref carried in the sync generation. Free accounts have no cross-device path today.
- `StudyRequest.read` recovers only on the exact message `Set your exam first.` (`study_api.dart:73`).
- `serverMockAvailabilityProvider` throws on any status outside `in-progress`, `cooldown`, `available`, `no-blueprint`. A new status would break cached clients, so none is added.
- `StudyApi.request` requires a non-empty `examId`.

**Sampler facts (`mock_sampler.dart`):**

- It allocates by topic weights, default equal. A small topic gives fewer than its share and nothing refills it.
- `PassageSetFiller.fillGeneric` skips a set that does not fit, so all-passage topics can fall short.
- It does not remove a question already used by another section. `summary` in `mockReader.ts` then throws `Saved mock results are not available.` on repeated ids, and `checkPaperAnswers` refuses them.
- `MAX_ANSWERS` and `ServerMockPaper.maxAnswers` are 300. The wheel ceiling is 240 per row, so a breakdown can sum above 300.

## 2.2 Identity, validation and ownership

**New file `functions/src/_customTrack.ts`** holds:

```ts
export const CUSTOM_EXAM_ID = /^exam_custom_[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
export const isCustomExamId = (id: unknown): id is string => typeof id === 'string' && CUSTOM_EXAM_ID.test(id);
export const isStudyExamId = (id: unknown): id is string =>
  typeof id === 'string' && (examCatalog.some(e => e.id === id) || CUSTOM_EXAM_ID.test(id));
export const customTrackRef = (db, uid, examId) => db.doc(`users/${uid}/server/customTracks/items/${examId}`);
export const MAX_CUSTOM_TRACKS = 50;
```

The regex matches what `CustomTrackRepository.create` makes (`exam_custom_${uuid.v4()}`). Bare `exam_custom` and malformed ids stay `Unknown exam.`.

**The eight checks change as follows.** Each keeps its error text for anything that fails the new test.

| Site | Change |
|---|---|
| `roadmap.ts:58` `checkSettings` | `isStudyExamId` |
| `roadmap.ts:226` `studyCaller` | `isStudyExamId` |
| `studyInsights.ts:56` | `isStudyExamId` |
| `mockReader.ts:24` `exam()` | `isStudyExamId` |
| `mock.ts:130` `beginMock` | `isStudyExamId` |
| `ingestSession.ts:35` | `isStudyExamId` |
| `sessionDiagnosis.ts:27` | `isStudyExamId` |
| `carryableCount.ts:26` | `isStudyExamId` |

`mockAccess.ts:25`, `studyInsights.ts:37`, `content.ts:97`, `betaPro.ts:30`, `webPlans.ts` stay as they are. A custom id has no catalog entry, so `coversExam` returns false, `actualTrial` returns null, and `setBetaPro` refuses.

**Ownership rule.** Format acceptance grants nothing. All state is read and written under `auth.uid`, so another student's id resolves to nothing in the caller's tree.

| Situation | Result |
|---|---|
| B calls `getRoadmap` with A's id, B has no settings | `failed-precondition`, `Set your exam first.`. No read of A's tree happens |
| B calls `setExamSettings` with A's id | Creates a document under B only. A's data is untouched. B gains nothing, because every reader is scoped to B |
| B calls `getMockAvailability` with A's id | `no-blueprint` from B's own tree |
| B calls `getCustomTracks` | Only B's rows. There is no uid or path parameter |
| `expectedUid` differs from the token | `Your account changed. Open this screen again.` |

**Track document.** `users/{uid}/server/customTracks/items/{examId}`, same shape of path as `server/mocks/items`:

```ts
type CustomTrack = {
  examId: string;
  name: string | null;              // trimmed, cut to 80 characters, never a refusal
  excludedTopicIds: string[];       // snapshot, so another device can restore it
  excludedLessonIds: string[];
  blueprint: null | {
    sectionsJson: string;           // as the client stores it, minus any topicWeights
    totalQuestions: number;
    totalMinutes: number;
    sectionsTimedSeparately: boolean;
    updatedAt: number;              // client's own saved time, newest wins
  };
  createdAt: number;
  updatedAt: number;
};
```

`users/{uid}/server/settings` keeps its shape. `settings.examId` may now be a custom id. While a custom track is active, its `excludedTopicIds` in `settings` are authoritative. The track holds the same copy for restore.

**Write path: `setExamSettings`, one transaction.** No separate create call. The existing recovery and publish paths all reach this function, so tracks appear wherever settings do.

1. `checkSettings` accepts the id. A new `checkCustomBlock(body.customTrack)` runs only when `isCustomExamId(examId)`.
2. Block shape: `{name?: string, blueprint?: {...}}`. An absent block is allowed, because a cached client from before this change recovers through this path. `assertStudyOwner` is required for custom ids.
3. In the transaction, read the track. If absent, count `customTracks/items` with `limit(MAX_CUSTOM_TRACKS + 1)` and refuse `resource-exhausted` at the cap.
4. Load corpus content (2.3). Unknown excluded topic and lesson ids are dropped, not refused, because a phone's local topic list may hold ids the catalog does not. If no topic with questions remains: `Choose at least one known topic.`
5. Write `settings` with the cleaned lists and the track. `name` is overwritten only when sent. `blueprint` is replaced only when sent and when `blueprint.updatedAt` is not older than the stored one. Absent never clears, so a device without the blueprint cannot wipe it.

**Blueprint validation (`checkCustomBlueprint`), shape only:**

| Field | Rule |
|---|---|
| `sectionsJson` | String up to 64,000 bytes, parses to a list of 1 to 20 sections |
| Section `id` | Unique, `^section_(all\|\d{1,3})$` |
| Section `name` | Non-empty string, up to 80 characters |
| Section `questionCount` | Integer 1 to 300 |
| Section `suggestedMinutes` | Integer 1 to 720 |
| Section `topicIds` | Array of 1 to 64 strings, each matching `ID_PATTERN` |
| Section `topicWeights` | Removed if sent. The server sets its own at assembly |
| `totalQuestions` | Equals the sum, 1 to 300 |
| `totalMinutes` | Integer 1 to 720 |
| `sectionsTimedSeparately` | Boolean. When true: at least 2 sections, and `totalMinutes` equals the sum of `suggestedMinutes` |
| `updatedAt` | Safe integer, not more than a day ahead of server time |

Failure: `invalid-argument`, `Bad mock setup.`. Whether the ticked subjects can supply the paper is not checked at save, so a later narrowing in What's Included can never be refused. Fit is enforced at setup on the client and at start on the server (2.7).

**New read, `getCustomTracks`** in `functions/src/customTracks.ts`:

- Input `{expectedUid}`. Named and anonymous accounts, App Check, 600 per hour.
- Returns `{activeExamId: string | null, tracks: CustomTrack[]}`, at most 50, newest first.
- `StudyApi` gains `requestAccount(name, expectedUid, payload)`, since `request` demands an exam id.

**New write, `deleteCustomTrack`** in the same file:

- Input `{expectedUid, examId}`. Deletes the track document. Idempotent.
- Refuses `failed-precondition` when `settings.examId === examId`.
- Keeps answers, reviews and mocks. Narrowing and removal never purge study data, and they are account-level.
- Called from `_discardCustomTrack` in `onboarding_page.dart` only. That path keeps any track with study data. There is no student-facing delete today, and this spec adds none.

Both are exported from `index.ts`. Neither is replay protected, so `REPLAY_PROTECTED` and `callable_options.dart` are unchanged. `instance-caps.test.mjs` covers them through the default cap.

## 2.3 Content: the corpus union

**`loadStudyContent` gains a custom branch.** It stays one function, so ordering, reference checks and error codes stay shared.

```ts
const custom = isCustomExamId(examId);
const selected = custom
  ? (await Promise.all(indexCatalogs.map(withParts))).flat()   // index required
  : await withParts(examId);
const allSets = dedupeById(selected.flatMap(d => d.sets ?? []));
const sets = allSets.filter(s => {
  if (!Array.isArray(s.exams)) throw contentUnavailable(...);
  return custom ? inCustomCorpus(s) : s.exams.includes(examId);
});
```

**Union rules:**

- The catalogs are exactly `index.catalogs`. A missing listed catalog is `unavailable`, never a partial corpus.
- A set appears in the catalog of each exam it is tagged for, so sets are deduped by set id. Two different sets holding one question id stay `Duplicate authored question identities.`.
- `inCustomCorpus` returns true (choice 1A). It stays one small function in `_customTrack.ts`, so a later narrowing has one place to change.
- `requestedTopics` comes from the sets, so `topic_cse_vocab` is not in `content.topics`. Subjects with no sets do not appear.
- `revision` is the sorted version list of every document read, so any content upload refreshes a custom snapshot, the same as a listed exam.
- Reads: 9 documents today inside the transaction, about 1.1 MB parsed. Listed exams read 2 or 3. No instance cache is added on the transaction path, to keep the revision honest. `ingestSession`, `assemblePaper` and `carryableCount` are not transactional readers of content, and they use a 5-minute cache keyed `corpus`, the same as `loadExamContent`.
- Simplicity note for the code comment: no corpus-level content document. If `index.catalogs` grows past about 20, build one in `catalogItems`.

**Scope helper.** `applyScope(content, excludedTopicIds, excludedLessonIds)` is extracted from `studyContext:285-290` and used by roadmap, diagnosis, insights (custom only), carry count (custom only), and the paper builder.

**Topic ids.** Client and server read the same `index` and catalog documents, so ids match by construction.

- Legacy `topic_<exam>_<slug>` ids are never produced for a custom id.
- `computeRoadmap` skips `build` for custom ids, since `loadExamContent` would mint `topic_custom_<uuid>_*`.
- `functions/test/custom-corpus.test.mjs` proves this against the real tree. `test/core/content/remote/server_catalog_contract_test.dart` proves it from the Dart side.
- `corpusTopics` keeps its name collapse for native. On the real data all 26 keys are unique, so no id is dropped.

**The subject picker.** `corpusSubjectsWithTopicsProvider` in `custom_track_subjects_step.dart` and `corpusTopics` in `track_scope.dart`:

- Count with `activeQuestionCountsByTopics`. Drop a topic with zero questions. Drop a subject with no topics left.
- Result on web: Mathematics, Science, Language Proficiency, Reading Comprehension, Reasoning, General Information. Verbal Ability is gone. Native still shows it while the demo rows exist.
- An empty map (catalog not loaded, or the daily limit hit) shows the existing `errorFor('subjects', ...)` state with Try Again, not an empty list.
- The custom name step gains `maxLength: 60`, so names fit the app's short-name slots. The server cut at 80 protects against older data.

**Daily limits.** Unchanged. 300 content ids a day holds all 170 sets. A student who reads many lessons and then starts a large mock can reach the limit mid-paper. That failure is the existing one, listed in 2.11.

## 2.4 Plan, advance, day and week

All four go through `studyCaller` and `studyContext`. Changes are confined to `roadmap.ts`:

| Location | Change |
|---|---|
| `studyContext:271-274` | If `isCustomExamId(examId)` and the settings are missing, or name another exam while no track document exists for this id: throw `Set your exam first.`. This is what recovers a student who switched from CSE to custom before this shipped. If a track exists and settings name another exam, keep `Your exam changed. Open this screen again.` |
| `studyContext:282` | Read `customTrackRef` instead of `content/mocks/items/<id>` for custom ids |
| `studyContext:318` | `examHasMock` is `track.blueprint != null` for custom |
| `studyContext:322` | Digest gains `customBlueprint: <blueprint.updatedAt>` for custom ids only, so a new setup updates the plan's mock day. Listed digests stay byte-identical |
| `publicToday:396` | `mockDurationMinutes` from `blueprint.totalMinutes` for custom |
| `computeRoadmap:157` | For a custom id, skip `build` and the legacy `server/roadmap` write. Call `readStudyRoadmap` and `readStudyInsights`, then return null |
| `saveExamSettings:182` | Custom block and corpus validation from 2.2 |

The transaction reads the corpus, totals, reads, reviews and mocks as it does now. `comingUp` and `history` stay absent, because `context.pro` is false. `readStudyDay` refuses future days for Free and `readStudyWeek` locks them, unchanged. `advanceStudyRoadmap` needs no change: `requestRef`, revision checks and `saveStudyState` key on the exam id.

`studyDays` rows keep `examId:day` ids. A track's plan history survives a switch away and back. The existing indexes on `items (examId, day)` and `items (examId, occurredAt)` serve custom ids.

## 2.5 Insights, performance and tendencies

`studyInsights.ts`:

- `settings.exists && settings.examId !== examId` stays. For a custom id, a missing settings document throws `Set your exam first.` so the client recovers. A listed exam keeps its current tolerance.
- `content` is `applyScope(corpus, settings.excludedTopicIds, settings.excludedLessonIds)` for custom only. A custom corpus is every subject in the app, so a carried CSE answer would otherwise appear under a subject the student never ticked. This delivers the 2 August rule that ticked subjects filter what Progress counts. Listed exams stay unfiltered so their figures do not move.
- `sourceRevision` adds the excluded lists for custom only, so listed cache keys are unchanged.
- `pro` is false, so tendencies, `whenYouWork`, topics, lessons and topic details stay out of the response. `trialEndsAt` is null. The client coverage providers already resolve this to Free without a loading trap once the read succeeds.
- A mock is never carried, unchanged. `own` sessions always count, and an unknown question in an own session has no topic, handled as it is now.

No client change. `webPerformanceViewProvider`, `webTopicDetailProvider`, `how_you_work_provider`, `tendencies_screen` render existing Free states. `webTopicDetailProvider` already refuses without coverage, as for Free listed students.

`sessionDiagnosis.ts`: only the id check changes, and `loadStudyContent` is reached through the custom branch. Free returns `tracedCount`.

## 2.6 Sessions and observations

**`ingestSession.ts`:**

- Well-formed custom id: accepted without a track document. A flush can arrive before settings on a new device, and refusing would write a permanent rejection on the client. The session stays under the caller's uid.
- Replace `loadExamContent` with `loadCorpusIds(db, now)` for custom ids (cached, 2.3).
- A custom session keeps only answers whose question is in the corpus, then applies the same replay comparison to the filtered list. If nothing remains, it returns `{sessionId, stored: false}` with no write. Reason: a phone's bundle can hold ids the catalog lacks, such as the two demo questions, and listed strictness would lose the entire session.
- An answer is dropped only against a fresh read: if the cached corpus lacks a question, the corpus is read again first. A replay compares the stored answers with the sent answers for the stored question ids, so a later content change cannot refuse an honest replay. Added after the audit.
- Two copies of one set that differ in topic, lesson or questions give `unavailable`, so a read during an upload is retried, never mixed. Added after the audit.
- Scope is not applied. A session finished before narrowing must still count, and narrowing filters and never deletes.
- Listed exams keep `Question is outside this exam.`.
- `computeRoadmap` afterward is the custom branch from 2.4.

**`study_delivery.dart`:**

- Remove line 103's `target.startsWith('exam_custom_')`.
- `readStudySettingsPayload` adds, when the id is custom: `customTrack: {name, blueprint?}`. Both are read by new methods on `CustomTrackRepository` (`name(examId)`, `blueprintPayload(examId)`), which read `customTrackMetaLocal` and `customBlueprintsLocal` from `AppDatabase`. This avoids a `features/home` import of `features/mock_exam`.
- Effect on phones: a phone with a custom track now publishes settings and sessions, like a listed exam. That is the only way a Free phone student's track reaches web. Native plans, mocks and depth stay local.

**`study_observations.dart`:** the delivery id for a custom attempt becomes `custom_session_${attempt.id}`. This retries every custom session that was previously marked `rejected`, exactly once more. The server dedupes by session id, so a resend cannot double count. No migration, no schema change. Lesson read delivery is unchanged.

**`study_snapshot_reader` and `web_study_seam`:** no change. The two `kIsWebStudy` sites keep working because the server now answers.

## 2.7 The custom mock

**Storage.** `blueprint` in the track document (2.2). The client sends it through `customTrack` in the settings payload.

**Saving on the client.** `custom_mock_setup_route.dart` `onSave` wraps the local save in `studySettingsCaptureProvider`'s `apply`. `StudySettingsPublication` gains a `settled` future so that this one caller can await delivery. On web:

- Success: invalidate `serverMockAvailabilityProvider(examId)` and `mockSetupQuestionCountProvider(examId)`, then leave the page.
- Failure: the page stays, Save reactivates, with the existing line `Could not save. Please try again.`. The local row is kept, and a later publish carries it.

On native the call is fire-and-forget, as for other settings.

**Fit on the client.** `CustomMockSetupData` gains `availableBySubject`. The Save rule becomes: total within `availableQuestions`, and each subject section within its subject's count. A new total limit of 300 applies. Each uses the existing CM_Ceiling treatment: the number stays in red, Tick More Subjects opens Settings, and Save waits. Copy for the 300 line and the per-section line goes in the preview.

**Paper assembly on the server.** `assemblePaper` branches on `isCustomExamId` to a new `assembleCustomPaper(db, uid, examId, now, seed)` in `mock.ts`:

```
track = read customTrackRef; no blueprint -> 'This exam has no mock yet.'
content = applyScope(loadCorpusStudyContent(), settings or track exclusions)
pools = questions by catalog topic; passages by topic and passage id
order = sections sorted narrowest first (subject sections before all-topic sections)
used = {}
for each section in order:
  topics = section.topicIds intersect scoped topics with unused questions
  available = unused questions in those topics
  if available < section.questionCount: throw notEnough
  weights = {topic: unused count / available}      // allocation can never exceed a pool
  sampled = core().sampleMock({sectionsJson: [section with weights],
              poolsByTopic: unused pools, passageSetsByTopic: unused passage sets,
              recentlySampledQuestionIds: last two papers, seed: (seed + i) % 2**32})
  top up to questionCount from unused questions in those topics, free-standing first,
    in sha256(seed + id) order; partial passage sets only when nothing else is left
  used += sampled
paper.sections = back in the student's order, expectedQuestionCount = sum
limitMs = totalMinutes * 60000                     // one clock
parts   = partClock(sections, timedSeparately)     // by-part clocks, below
```

The proportional weights guarantee no topic is asked for more than it holds. Sorted order makes the check exact for this family of sections, since subject sections do not overlap each other and an all-topic section contains them. `notEnough` is the existing `failed-precondition`, `There are not enough questions for this mock yet.`. No change to the compiled Dart core, so `pantas_core.js` and its closure hash stay as they are.

Known limit, recorded here: the phone's local `MockSampler` keeps both faults for custom breakdowns. Phones are not publicly released. Fix with the native mock work, not here.

**Availability, `serveMockAvailability`:**

- Read `customTrackRef` in place of `content/mocks/items/<id>` for custom. `blueprint` absent gives `no-blueprint`. Cooldown and `in-progress` are computed as now, over all of the student's mocks.
- `includeSetup` calls `assemblePaper` with seed 0. Failure is `failed-precondition`, which the client already maps to `ServerMockNotOpen.noBlueprint`.
- No new status value.

**Cooldown.** `beginMock:152-157` and `serveMockAvailability:96` run unchanged. `coversExam` is false for a custom id, so `FREE_MOCK_WINDOW_MS` applies, counted across every exam the student has. A student cannot farm by making tracks. `quiz_routes.dart` `freeIntervalDays: web ? 30 : 14` already prints it right.

**`startMock`.** Named account, App Check replay protection, 30 per hour, paper pinned, single open mock, unchanged. The row gains `examName: track.name` for custom only, so a renamed or removed track still reads correctly in Record. `view` returns it.

**Results, review, Record:**

- `summary` in `mockReader.ts` adds `examName` when present. Results, history and review logic need no other change, since they work by mock id and on the pinned paper. Review after 30 days follows `canReview` for Free.
- `updateMockReview` stays Pro only, so it refuses on a custom paper under choice 2A.
- `server_mock_results.dart` parses the optional `examName`.
- `serverMockHistoryEntry` (`mock_results_providers.dart:239`) falls through to `row.examId` today, which would print `exam_custom_<uuid>` in Record. Custom ids use `examName ?? 'Mock exam'`.
- `server_mock_route.dart:404` title: `'$examName simulation'` for custom, matching `MockCard`'s `'${shortName} simulation'`.
- The results finale stays CSE only (`mock_results_route.dart:194`). Custom gets the plain results, as other listed exams do.

**Quiz panel, `quiz_routes.dart`:**

| Server status | Local summary | Panel |
|---|---|---|
| `no-blueprint` | none | `customUnset`, Set One Up |
| `no-blueprint` | present | Publishes settings once to repair, then re-reads. Until then `customReady` with Change Setup, since a failed publish should not look like lost work |
| `available` | none (restored browser, restore not yet run) | `customReady` after restore. If restore also fails, `customUnset` |
| `available` | present | `customReady` |
| `cooldown` | any | `waiting`, shows date |
| `in-progress` | any | `inProgress`, resumes by mock id |

`onTake` on a custom track goes to `/quiz/mock/setup?examId=`, as now. If `serverMockSetupCountProvider` throws `ServerMockNotOpen.noBlueprint` while a local blueprint exists, `mock_setup_route.dart` opens `/quiz/mock/custom-setup` instead of `Mock paper not ready`. That page shows the CM_Ceiling state when the student has narrowed.

**By-part clocks (choice 3B).**

Applies when `blueprint.sectionsTimedSeparately === true` and the paper has at least 2 sections. Otherwise the mock is one clock, exactly as today. A listed exam never has by-part clocks, whatever its blueprint says. Its row and every response stay byte-identical.

*Stored.* The mock row gains `parts`, pinned at start. Nothing in it ever comes from the client, and a later blueprint edit does not touch an open mock.

```ts
parts: {
  limitsMs: number[];          // one per paper section, suggestedMinutes * 60000, in paper order
  index: number;               // the part running, or the part waiting to start
  startedAt: number | null;    // server time this part's clock started. Null while waiting
  waitingSince: number | null; // server time the previous part closed. Null while running
  endedEarly: boolean;         // the student closed the previous part
  usedMs: number[];            // time used in each closed part
}
```

`row.limitMs` is the sum of `limitsMs`. `row.startedAt` stays the paper's start. `row.pausedAt` and `row.pausedMs` belong to the running part and go back to null and 0 when a part closes.

*Returned.* `MockView` gains one block, on these rows only:

```ts
parts: {
  index: number;
  limitsMs: number[];
  remainingMs: number;         // left in this part. The full limit while waiting
  waiting: boolean;            // show the between-parts screen
  endedEarly: boolean;
  startsInMs: number | null;   // Strict and waiting: time until the server starts the part. Otherwise null
}
```

Top-level `remainingMs` is `parts.remainingMs` plus the limits of every later part, so `remainingMs <= limitMs` still holds for a cached client that does not read `parts`. Everything `PartTransitionPage` needs comes from this block and the paper: `partNames` from `paper.sections`, `nextPartIndex` from `index`, `answeredQuestions` from section `index - 1` and `answers`, `endedEarly` from the block. `PausePage` and `MockSessionPage` take `partLength` from `limitsMs[index]` and `remainingInPart` from `remainingMs`.

*Settling.* A pure function, `settleParts(row, now)`, in new file `functions/src/_mockParts.ts`, runs inside every transaction that reads or changes a by-part row, before anything else. It repeats until nothing changes:

1. Waiting and Strict, and `now >= waitingSince + STRICT_BREAK_MS`: the part starts at exactly `waitingSince + STRICT_BREAK_MS`. `STRICT_BREAK_MS` is 60,000 (option A in 1.3).
2. Waiting and not Strict: stop. The clock is stopped, the same as a pause.
3. Running: used time is `now - startedAt`, less `pausedMs` and any open pause when not Strict. A paused part never times out.
4. Used time below the limit: stop.
5. Used time at the limit: the part closes at exactly `startedAt + pausedMs + limit`. `usedMs` gets the limit. If a later part exists, it starts waiting from that moment, with `endedEarly` false. If this was the last part, the paper is finished.

A paper that a settle finishes is submitted at the closing moment with `endedBy: 'time-out'`, on the answers the server holds, through `recordMockAnswers`, the same as a Strict time-out today. This covers non-Strict too: the server decides, because the browser cannot be trusted to end a by-part paper. `endIfTimedOut` applies this for by-part rows. For rows without `parts`, its code path does not change. A later read, save or submit gets the existing replies for a finished mock.

*Clock reads.* Inside each `controlMock` and `submitMock` transaction on a by-part row, the server reads its clock again and uses the largest of that reading, `startedAt`, `waitingSince` and `pausedAt`. A request that waited cannot stamp a moment before the clock's last event. A settle that finishes the paper inside `controlMock` commits the submission, then returns the existing `This mock is already finished.`. `startPart` and `endPart` read the row first, so a row without `parts` gets `Unknown action.` with no other effect. Added after the audit.

*Answers.* Every save and submit on a by-part row keeps only the running part's answers from the client:

- A closed part keeps the stored answers. The client's values are dropped without an error, because a save sent just before the close is normal.
- A later part's answers are dropped. A later part has no answers until it opens.
- While waiting, no part is running, so all sent answers are dropped.
- `checkPaperAnswers` still refuses an id not on the paper.

An answer that reaches the server after its part closed is lost. There is no grace period, because one would add time. This matches a Strict time-out today. The client narrows the gap in C4 by sending a pending save at once when under 3 seconds remain in the part.

*Actions on `controlMock`.* Two are added. On a row without `parts`, both fail with `invalid-argument`, `Unknown action.`, the same reply as today.

| Action | Rule |
|---|---|
| `startPart` | Allowed in Strict. While waiting: the clock starts at server `now`. Otherwise it changes nothing and returns the view, so a repeated call can never restart a clock |
| `endPart` | Refused in Strict, with the existing message. Closes the running part at server `now`, `usedMs` gets the used time, `endedEarly` true, the next part starts waiting. Refused on the last part with `failed-precondition`: the client submits instead. Refused while waiting: nothing is running |
| `pause` | While waiting: changes nothing. Otherwise as today |
| `resume` | As today, on the running part's `pausedMs` |
| `discard` | As today. It clears the answers, restarts the paper's clock, and puts `parts` back to part 0, running, with `usedMs` empty |
| `save` | As today, with the answer rule above |

*Submission.* `recordMock` keeps its checks. For a by-part row it stores merged answers by the rule above, and `durationMs` is the server's own count: the sum of `usedMs` plus the running part's used time. The client's `durationMs` is still validated and then ignored. A submission before the last part is allowed in both modes, since it only gives time away. `submittedAt` is server `now`. `summary`, results, history and review read the row as they do today. Absent answers count as blank, which they already do.

*What the client can never do,* each with a test: extend a part by repeating `startPart`, by pausing in Strict, by sending a large or small `durationMs`, by sending `answeredAt`, by saving after the close, by starting again, or by a different `strict` flag on a second `startMock`. Leaving the between-parts screen unanswered in Strict does not stop the clock past the break. Non-Strict has unlimited pauses and a discard that clears answers, as listed exams do. Those two stay as they are: Strict is the simulation, and a student who pauses gives that up.

*Setup.* `WebCustomMockSetup` keeps `onTiming` and the row on web. `MockSetupPage` shows the parts as it does on the phone.

*Results.* The response shape does not change apart from `examName`.

## 2.8 Pro, Free and the Pro page (choice 2A)

**Server.** No entitlement code changes.

**Pro page, `pro_page.dart`.** When the active exam is custom and there is no `targetExam`, `activeProCatalogEntryProvider` is null, `packages` and `passes` are empty and no buy button draws (by reading). Replace the offers block with one state:

- Line drafted for the preview: "PUP CET is free, with no limits. Pro plans come with a listed exam."
- A secondary action to `/settings/exam/change`.
- If the student holds coverage for another exam, the existing "what you own" rows stay.

Upsell rows on Plan and Home keep linking here. Whether to hide them on a custom track is a preview question.

**Switching a paying student to a custom track.** `ChangeExamPage.onPicked` and the new custom Settings path compute `from` and `to` from the catalog, and `to` is null for a custom target, so the existing warning is skipped. Add: if `entitlement.proIsActive` and the target is custom, show the existing `CenteredDialog` pattern. Draft: "On PUP CET you'll be on Free. Your plan stays with your account. Switch back any time." Copy goes in the preview.

**Beta.** `setBetaPro` stays CSE only. The beta Pro row hides for a custom exam, since the server refuses it. Confirm the row's condition in C5.

## 2.9 Carry-over and changing exams

**`getCarryableCount` for a custom target.**

- Counts answered questions in the corpus, minus the target track's exclusions when the track exists, else the whole corpus.
- It remains read-only and does not require the target to be the current exam.
- It needs no ownership check beyond the caller's own totals.

**Listed to custom, from Settings.** New routes in `settings_routes_native.dart`, deferred like the others in `settings_routes.dart`: `/settings/exam/custom/name` and `/settings/exam/custom/subjects`.

- They reuse `CustomTrackNameStep` and `CustomTrackSubjectsStep`, with these differences:
  - `onContinue` and `onCompleted` callbacks.
  - No `setCompletedOnboarding(false)` (new `fromSettings` flag on the step).
  - Then the same `saveTarget`, `publish.apply`, carry prompt and `ExamChangeResult` sequence as `ChangeExamPage`.
- The exam date and study days carry over, as in a listed switch. Settings holds both.
- The picker's `_custom()` pushes the Settings route when `mode == settings`.
- The onboarding routes keep their behavior.
- Board: wide steps reuse `OB_CustomName` and `OB_CustomCover`. Whether the progress bar hides from Settings is in the preview.

**Custom to listed.** The existing path works. `from` is null, so no pass warning. `setExamSettings` replaces `settings`. The track document stays. `getCarryableCount(listed)` runs and the prompt appears if the count is above zero.

**Back to a track, or to a second custom track.** "Your exams" section at the top of the picker, onboarding and Settings modes, in both layouts:

- Source: local `customTrackMetaLocal` rows, merged with `getCustomTracks` on web.
- Selecting a server-only row first restores it (2.10).
- Selecting uses the normal save path.
- A failed server read shows local rows only and records telemetry.
- The current track is marked as selected.

Carry-over semantics are unchanged. The choice filters figures only. The plan and due dates ignore it. Reviews are per question, so they follow the student into a custom track.

## 2.10 Phone to web, second browser, reload

| Case | Today | After |
|---|---|---|
| Reload on web | Track lost, back to onboarding (by reading) | `_startWebContent` in `bootstrap.dart` calls new `CustomTrackRepository.reprojectAll()` after `contentMirror.start()`. Every `customTrackMetaLocal` row is upserted into the in-memory `contentExams`. It runs before `settleGatesBeforeFirstPage` |
| New browser, any tier | Not possible | Onboarding reaches the picker. "Your exams" lists server tracks. Selecting restores and continues |
| Browser database wiped after a read failure | Same as a new browser | Same restore |
| Phone made, Free | No path | Phone on the new build publishes. Web picker lists it |
| Phone made, Pro, sync on | Sync pulls track and selected exam | Works, with the reload fix. If the server has no settings yet, `recover` publishes the local payload |
| Phone made, older build | Phone never publishes | Web lists nothing for Free. Pro sync still restores local rows, and `recover` publishes them |
| Two devices on different exams | `Your exam changed. Open this screen again.` on the stale one | Unchanged, same as listed. Try Again shows the same error until the student picks. Record as a known limit |

**`CustomTrackRepository.restoreFromServer(CustomTrackRow row)`:**

- Writes meta, scope rows, the lesson pref and the blueprint row in one recorded batch, then projects.
- If a local row exists, local wins. It runs only for ids absent locally.
- It uses the sync recorder, so a Pro account's tombstones and pushes stay consistent.

A fresh browser's first `getCustomTracks` happens when the picker opens, and only when `studyUsesServer` is true. Phones read local rows.

## 2.11 Failures a student can hit

| # | Failure | Cause | What the student sees | Owner |
|---|---|---|---|---|
| 1 | Catalog not loaded at subject step | Offline, limit | `errorFor('subjects')` with Try Again | Client |
| 2 | Create fails locally | Browser storage | Existing `saveFailureLine` above Continue | Client |
| 3 | Publish fails after onboarding | Offline | Nothing at once. Home's read retries through `beforeRead` and `recover`. If still offline, cached read or `Could not load your plan.` with Try Again | Client |
| 4 | `Set your exam first.` | Settings missing or stale from before this ship | Silent recovery by `recover`, then Home | Server, client |
| 5 | `Your exam changed.` | Two devices on different exams | `Could not load your plan.` with Try Again. Known limit | Existing |
| 6 | `unavailable` | Catalog missing or malformed | `Could not load your plan.` or `errorFor('mock')` with Try Again. A cached read stays on screen | Existing |
| 7 | All topics excluded | Client bug or a phone with only Verbal Ability | `Choose at least one known topic.`, shown as `Could not save. Please try again.` on What's Included. On a phone it reaches telemetry only | Server |
| 8 | 51st track | Abuse only | `Could not load your plan.`, telemetry shows `resource-exhausted` | Server |
| 9 | Rate limits | 600 per hour study, 30 per hour mock start | Existing messages | Existing |
| 10 | Over the limit at setup | Asked for more than ticked subjects hold | CM_Ceiling: number in red, Tick More Subjects, Save waits | Client |
| 11 | Over the limit after narrowing | Blueprint saved, subjects narrowed | Take opens setup in the CM_Ceiling state | Client |
| 12 | Server refuses a paper the client allowed | Content version race | `Mock paper not ready` with Back | Existing |
| 13 | Cooldown | Any mock inside 30 days | Panel `waiting`, `MockNotOpenView` with the date | Existing |
| 14 | No blueprint | Not set up | `customUnset`, Set One Up | Existing |
| 15 | Setup save publish fails | Offline | Stays on page, `Could not save. Please try again.` | Client |
| 16 | Anonymous account starts a mock | `assertNamedUser` | Existing sign-in state, same as listed | Existing |
| 17 | Open mock from a previous exam | Switched mid-mock | Panel `inProgress`, resumes the pinned paper with its own name | Existing |
| 18 | Daily content limit mid-paper | 300 ids | Existing limit message on the question that cannot load | Existing |
| 19 | `getCustomTracks` fails | Offline | Picker shows local rows, plus the "My exam isn't on this list" row | Client |
| 20 | `deleteCustomTrack` fails | Offline | Nothing. Backing out still works, telemetry only. An unused row stays until account deletion | Client |
| 21 | Session refused by old client or rollback | Rollback window | Nothing visible. Permanent rejection on that browser. See 2.14 | Deploy |
| 22 | Reload during anything | `reprojectAll` fails | Back to onboarding picker, with the track listed in "Your exams" | Client |
| 23 | Reading a track removed by sync on another device | Pro sync tombstone | `needsSelection`, goes to picker, as for a removed exam | Existing |
| 24 | Answer saved after its part closed | Save reached the server late | The answer is not kept. The screen adopts the server's answers when the part changes | Server, client |
| 25 | Strict student leaves the between-parts screen unanswered | Break ran out | The next part is already running when the next read comes back | Server, client |
| 26 | Browser offline when a part ends | Network | The server closes the part on time. The student sees the next state when the read succeeds. Saved answers count | Server, client |

## 2.12 Existing data

- **Server:** no custom track documents exist. Nothing to migrate.
- **Listed students:** no field changes. `digest`, `sourceRevision`, settings shape and every response stay byte-identical. A regression test pins this for one fixture.
- **Browsers with a custom track, sessions marked rejected:** retried once through the new key (2.6).
- **Browsers with a custom track, no server settings:** first Home read recovers.
- **Browsers that switched CSE to custom:** first Home read recovers, through the rule in 2.4. Server `settings` then becomes the custom id, which is the student's real choice.
- **Local custom blueprint:** goes up on the first publish, or on the panel's repair.
- **Phones:** first publish after updating sends the track and any unsent custom sessions. Up to 200 sessions a day, by the existing limit.
- **Drift schema:** no change. `schemaVersion` stays. No new tables.
- **Firestore rules:** no change. `users/{uid}/server/**` already denies clients.
- **Firestore indexes:** no change. The `items` indexes on `examId` cover custom ids. `customTracks/items` needs only a plain read.
- **Content:** no upload, if the hosted root is the approved one. Preflight checks this.

## 2.13 Deletion and account cleanup

- `deleteAccount`: `db.recursiveDelete(userRef)` already covers `server/customTracks/items/*`, with the same parent shape as `server/mocks/items`.
- `cleanupOrphanAnons`: same recursive delete. Its `onlyDisposableData` check does not name tracks, so an old anonymous account's track goes with it, which is right.
- **Local wipe gap, to fix in C1.** `LocalStateWiper.wipeAll` clears `trackScopeLocal` and `customBlueprintsLocal` but not `customTrackMetaLocal`. Today that row is close to invisible. With `reprojectAll` and "Your exams", the next account on a shared browser would see the previous student's track name. `wipeAll` must delete `customTrackMetaLocal`, and `local_study_reset.dart` likewise. Test: sign out, sign in as another account, no track row and no exam row.
- `cleanupSyncData` is untouched. It handles tombstones in the sync collections, not this path.
- `exportData` is a stub that sends students to the Data Protection Officer. The manual export must include `server/customTracks`. Add it to the DPO note in `docs/`, if one lists paths.
- Privacy: the track name is free text and may be personal. It stays under the account, is never logged by these functions (no `console.error` with the name), and is not aggregated. A founder view of names is a later decision. The stored field makes it possible.

## 2.14 Deploy needs and what is hard to reverse

**Order. Each hosted step needs Aedwon's explicit approval.**

1. **Read hosted content.** With an approved login, read `content/catalog/items/index` on `pantas-staging`: `catalogs` should list 8 exams. If it lists fewer, the union is smaller than the picker promises, so stop and report. If the hosted set is smaller, upload from the approved root first.
2. **Functions to staging:** `firebase deploy --only functions --project pantas-staging`, the whole set, since every study function shares the module. New: `getCustomTracks`, `deleteCustomTrack`.
3. **Server smoke on staging,** with a test account and a script calling the callables with a generated uuid: settings, roadmap, insights, ingest, availability, start, submit, results, delete. Test accounts only.
4. **Hosting to staging:** the release build per `web/README.md`.
5. **Aedwon's visual acceptance** on staging.
6. **Production,** same order, functions before hosting, at least one full day after staging passes. Production needs its own approval.

**Why functions first:** a new client against an old server gets `invalid-argument` from `ingestSession`, and the client writes `rejected` permanently. A cached old client against a new server is safe: `recover` sends settings without a block, which the server accepts.

**Hard to reverse:**

| Item | Why | Handling |
|---|---|---|
| `rejected` receipts in browsers | Written once, never retried | Keep functions ahead of hosting. If functions roll back while a new client is live, sessions finished in that window are lost to the server unless the key changes again. **Roll back hosting first, then functions.** If it happens, bump the key to `custom_session_v2_` |
| Answers, totals and reviews from custom sessions | Merged into the account's running totals, which cannot be split per exam | Accepted. Old function code tolerates them: they are question-level and only count where a question is in scope |
| A submitted custom mock | Starts the 30-day cooldown across all exams | Accepted, same as listed. Refunding one is a manual edit |
| `settings.examId` set to a custom id | An older function version refuses it, so the student sees errors until the rollback ends | Rollback order above, and a student can switch exam in Settings |
| Track names stored | New personal text on the server | Goes with the account. Removing the feature means a sweep across accounts |
| An open by-part mock during a functions rollback | Older code ignores `parts` and runs one clock on `limitMs`, the sum | Accepted. No data is lost. The row stays readable |
| New topics added to the catalog later | An excluded list means new topics join every custom track | Accepted, as on native. Can be unticked. Note it when the CET content lands |

Nothing here needs a destructive migration, and every new server path is additive.

## 2.15 Every Function and client path, with its test

**Functions.** Emulator suites run under `npm test` in `functions`.

| Function | Change | Test |
|---|---|---|
| `setExamSettings` | Custom id, block, cap, drop-unknown, newest blueprint wins | New `custom-track.emulator.mjs`: create, update, absent block, cap at 50, malformed id refused, bare `exam_custom` refused, old blueprint ignored, absent blueprint never clears, all-excluded refused |
| `getRoadmap` | Corpus, scope, blueprint, recovery message | Same suite plus `study-roadmap.emulator.mjs`: custom Free response has no `comingUp` or `history`, CSE to custom gives `Set your exam first.`, listed response unchanged by snapshot |
| `advanceRoadmap` | Through `studyContext` | `study-roadmap.emulator.mjs`: advance and replay on a custom id |
| `getRoadmapDay`, `getRoadmapWeek` | Through `studyContext` | `study-roadmap.emulator.mjs`: future locked, past readable, custom id |
| `getStudyInsights` | Scope filter, recovery, cache key | `custom-track.emulator.mjs`, `carry-over-figures.emulator.mjs`: carried answer counts only in ticked subjects, carry off excludes, narrowing hides and re-ticking restores, Free depth only |
| `getSessionDiagnosis` | Id check | `session-diagnosis.emulator.mjs`: custom Free returns `tracedCount` only |
| `getCarryableCount` | Corpus, exclusions | `carryable-count.emulator.mjs`: no track, track with exclusions, unknown format refused |
| `ingestSession` | Union, filter, no track needed | `study-observations.emulator.mjs`: stored, replay not doubled, unknown id dropped, empty after filter stores nothing, listed strictness kept |
| `recordLessonRead` | Rebuild branch | `study-observations.emulator.mjs`: lesson read with custom settings stores and does not throw |
| `getMockAvailability` | Track blueprint, setup preview | `mock-reader.emulator.mjs`: no blueprint, available, cooldown across exams, setup count, refusal when short |
| `startMock` | Custom paper, `examName` | `mock-paper.emulator.mjs`: exact count, no repeated question across overlapping sections, small topic fills through weights, passage topic tops up, narrowest first, refusal, reuse of open mock, Free cooldown from a CSE mock |
| `getMockPaper`, `controlMock`, `submitMock` | By-part clocks | `mock-parts.test.mjs` on the pure rules, no emulator: every settle step, chained time-outs, exact closing moments, paused parts, break limit, answer merging. `mock-parts.emulator.mjs`: full run in both modes through results, every abuse case in 2.7, no `parts` on listed or one-clock rows. `mock-paper.emulator.mjs`: full custom one-clock run through submit with pinned paper |
| `getMockResults`, `getMockHistory` | `examName` | `mock-reader.emulator.mjs`: results valid on a custom paper, name survives rename, review window |
| `updateMockReview` | None | `mock-reviews.emulator.mjs`: refused on custom under 2A |
| `getCustomTracks` | New | `custom-track.emulator.mjs`: own rows only, `expectedUid` mismatch, limit |
| `deleteCustomTrack` | New | `custom-track.emulator.mjs`: deletes, idempotent, refuses active, study data kept |
| `getContent` | None | `content-access.emulator.mjs`: a custom student's Free read of a set, unchanged |
| `deleteAccount` | None | Extend `public-id.emulator.mjs` or a new case in `custom-track.emulator.mjs` that exercises `recursiveDelete` over the path |
| Security | Cross-account | `custom-track.emulator.mjs`: B cannot read or change A's track, plan, mocks or sessions by any callable |
| Rules | None | `l1-rules.rules.mjs`: add `users/${OWNER}/server/customTracks/items/x` to the denied list |
| Union | New | `custom-corpus.test.mjs` on the real tree: 170 sets, unique ids, every set topic in `index`, `topic_cse_vocab` absent |
| Static | Exports | `instance-caps.test.mjs`, `app-check.test.mjs`, `static.test.mjs`: pass with new exports |

**Client.** New tests fail first, then pass.

| Path | File | Test |
|---|---|---|
| Delivery guard | `study_delivery.dart` | `test/features/home/application/study_delivery_custom_test.dart`: custom publishes with block, native and web |
| Rejected retry | `study_observations.dart` | `test/features/home/data/study_observations_test.dart`: old rejected key does not block, new key used once |
| Reload | `custom_track_repository.dart`, `bootstrap.dart` | `custom_track_repository_test.dart`, `test/app/bootstrap_recovery_test.dart`: memory database reprojected, focus keeps the exam, router stays on `/home` |
| Picker subjects | `custom_track_subjects_step.dart`, `track_scope.dart` | `custom_track_steps_test.dart`: zero-question subject hidden, empty map shows error. `server_catalog_contract_test.dart`: every offered topic has questions on the server union |
| Onboarding | `onboarding_page.dart` | `onboarding_custom_to_home_test.dart`, `onboarding_custom_back_test.dart`: Home reads succeed against a fake server, backing out calls delete |
| Your exams | `exam_picker_screen.dart` | `exam_picker_screen_test.dart`, `web_onboarding_states_test.dart`: rows, restore, read failure, wide and phone |
| Restore | `custom_track_repository.dart`, `study_api.dart` | `custom_track_repository_test.dart`: restore writes all rows, local wins |
| Settings path | `settings_routes_native.dart`, `settings_routes.dart`, `exam_picker_screen.dart` | `test/app/router_settings_test.dart`, `deferred_settings_routes_test.dart`: reaches the steps while complete, returns to Settings, `completedOnboarding` stays true |
| Switch warning | `settings_routes_native.dart` | Same test files: paying student warned, Free not |
| Carry | `carry_over_providers.dart` | No code change. Existing tests pass with a custom target |
| Setup save | `custom_mock_setup_route.dart`, `custom_mock_setup_page.dart`, `web_custom_mock_setup.dart` | `custom_mock_setup_page_test.dart`, `web_custom_mock_setup_test.dart`: awaits publish on web, failure line, per-section ceiling, 300 line, timing row present on web |
| Panel | `quiz_routes.dart`, `mock_panel_providers.dart` | `web_custom_quiz_states_test.dart`, `test/app/router_mock_panel_test.dart`: table in 2.7 |
| Setup route | `mock_setup_route.dart` | `test/features/mock_exam/...`: short paper opens custom setup |
| Paper title | `server_mock_route.dart` | `server_mock_route_test.dart`: custom title |
| By-part paper | `server_mock_paper.dart`, `server_mock_session.dart`, `server_mock_api.dart`, `server_mock_route.dart` | `server_mock_session_test.dart`, `server_mock_route_test.dart`: decodes `parts`, listed papers decode as before, transition screen on waiting, `startPart`, `endPart`, grid bound to the running part, closed-part answers adopted from the server, Strict start by itself, pause shows part clock, last part submits, cached paper without `parts` stays one block |
| Record, results | `mock_results_providers.dart`, `server_mock_results.dart`, `record_provider.dart` | `record_provider_test.dart`: no raw id printed |
| Pro page | `pro_page.dart` | `test/features/settings/presentation/pro_page_custom_test.dart`: custom state, owned rows stay |
| Scope | `whats_included_page.dart` | `whats_included_page_test.dart`: publishes block, zero-question topic hidden |
| Listed regression | All | Full `flutter test` |

**Browser end-to-end, local emulators.** `tools/local/run_web_local.py`, the CSE root.

- Add sample student `customFresh` to `tools/local/seed_student.mjs` and `local_sample_students.dart`.
- Run at 1440x900 and at 390x844, with a scripted browser against the local profile build, as on the November 4 direct-load check.
- This is automated functional evidence. Aedwon keeps visual acceptance, and no screenshot is judged by an agent.

Path:

1. Sign in with a new named account. Onboarding to the picker. "My exam isn't on this list".
2. Name "PUP CET". Subjects: Verbal Ability absent. Tick Mathematics and Science. Date, study days, name, Home.
3. Home loads with the track name and countdown. Plan, week and day load. Future days locked.
4. Reload at `/home`: stays on Home, same plan.
5. Take the assessment. Result shows. `ingestSession` stored.
6. Today session. Answer. Plan updates. Advance if offered.
7. Performance shows Mathematics and Science only.
8. Quiz: panel `customUnset`. Set up 40 questions, 45 minutes. Save. Panel `customReady`.
9. Ask for a section above the subject's count: red, Save waits, Tick More Subjects opens What's Included. Return.
10. Add two overlapping named parts, timed separately, 1 minute each. Start. Paper has no repeated question. Answer in part one, let its time end. The between-parts screen shows. Start part two, end it, submit. Results, review, Record shows "PUP CET".
11. Panel `waiting` with the 30-day date. A second start is refused.
12. Narrow in What's Included so the setup no longer fits. Take opens the ceiling state.
13. Open a second browser profile with the same account. Onboarding picker shows "PUP CET" under Your exams. Select. Home and panel match.
14. Settings: change to CSE Professional. Carry prompt. Home loads CSE. Then Settings: pick PUP CET under Your exams. Home loads the same track.
15. Settings: "My exam isn't on this list", make a second track, reach Settings again.
16. Pro page on a custom track shows the free state.
17. Delete the account. Emulator shows no `users/<uid>` tree.

Pass: every step reached, no console error, no `Unknown exam.` in the function logs.

**Full check set (hosted Actions on the branch):** `flutter test`, `flutter analyze`, `dart format`, `dart run tool/check_layering.dart`, `dart run tool/check_no_ai_attribution.dart`, `npm test` in `functions`, web release build.

## 2.16 File ownership

**Two streams are in flight on the same client branch: the QA sweep and the lesson reader redesign.** This plan takes its own worktree and branch, `web/custom-exam-r1`, cut from `web/visual-check-fixes-r1` at the moment T0 starts.

| Area | Owner while this runs |
|---|---|
| `functions/src/**`, `functions/test/**` | This plan only. No other stream touches them today, so server tasks can start at once |
| `lib/features/lesson/**`, `lib/core/content/remote/lesson_markdown.dart`, lesson tests | Reader redesign. This plan does not touch them |
| `lib/core/content/remote/content_mirror.dart` | Neither edits it unless the reader must. This plan does not |
| Files below | This plan during its client window. QA sweep holds off or hands the finding to the lead |

**Files this plan edits on the client:**

- `lib/features/home/application/study_delivery.dart`, `lib/features/home/data/study_observations.dart`, `lib/features/home/data/study_api.dart`
- `lib/core/storage/track_scope.dart`, `lib/core/storage/data/repos/custom_track_repository.dart`, new `lib/core/storage/custom_corpus.dart`
- `lib/core/sync/local_state_wiper.dart`, `lib/core/dev/local_study_reset.dart`
- `lib/app/bootstrap.dart`, `lib/app/routes/settings_routes.dart`, `lib/app/routes/settings_routes_native.dart`, `lib/app/routes/settings_routes_web.dart` if the deferred list needs it, `lib/app/routes/quiz_routes.dart`
- `lib/features/onboarding/presentation/exam_picker_screen.dart`, `onboarding_page.dart`, `steps/custom_track_name_step.dart`, `steps/custom_track_subjects_step.dart`
- `lib/features/mock_exam/application/mock_panel_providers.dart`, `mock_results_providers.dart`
- `lib/features/mock_exam/domain/server_mock_results.dart`, `server_mock_paper.dart`
- `lib/features/mock_exam/application/server_mock_session.dart`, `lib/features/mock_exam/data/server_mock_api.dart`
- `lib/features/mock_exam/presentation/pages/custom_mock_setup_route.dart`, `custom_mock_setup_page.dart`, `web_custom_mock_setup.dart`, `mock_setup_route.dart`, `mock_setup_page.dart`, `server_mock_route.dart`
- `lib/features/settings/presentation/pages/pro_page.dart`, `whats_included_page.dart`
- `tools/local/seed_student.mjs`, `lib/core/dev/local_sample_students.dart`

**Rules:**

1. Server tasks run in parallel with both streams, because the file sets do not meet.
2. Before the client window opens, the lead merges the current `web/visual-check-fixes-r1` into `web/custom-exam-r1` and tells both streams which files are held. The window is about 2.5 working days.
3. If the QA sweep has a finding in a held file, it records the finding in `docs/ui-audit.md` and leaves the fix to the lead's merge order. It does not edit the file.
4. Client tasks keep diffs small: no reformatting, no renames.
5. At the end of the window the lead merges `web/custom-exam-r1` into `web/visual-check-fixes-r1`, runs the full check set, then `web/staging-candidate-r1`. `lib/app/router.dart` is not edited.
6. Generated files stay uncommitted.
7. Every worker reads `SUBAGENTS.md` and works in its own worktree. Workers do not merge.

## 2.17 Previews required before the client window

Per the visual companion rule. The lead builds them from the real code, wide and phone. Approved previews are then binding 1:1.

1. "Your exams" rows in the picker, onboarding and Settings.
2. Pro page, custom state, with and without owned coverage.
3. Whether Free upsell rows stay on a custom track.
4. Setup on web with the timing row, and `MockSetupPage` for a by-part paper.
5. Red line for 300 and for a section above its subject.
6. Switch warning for a paying student.
7. Custom steps opened from Settings: progress bar or none.
8. By-part paper on web: part clock and part name in the header, grid limited to the running part, between-parts screen wide and phone, Strict between-parts screen when the break runs out, pause screen with the part clock.

All new strings follow `AGENTS.md`, and the 2 August rule: no string leads with what Pantas cannot do.

---

# Part 3. Implementation plan

**Worker model:** Sonnet 5.5 medium for implementation. Haiku 5.5 for bulk test runs. Lead (Opus 5.5) reviews every task against the file table and owns merges.
**Branch:** `web/custom-exam-r1`. Integration target: `web/visual-check-fixes-r1`, then `web/staging-candidate-r1`.
**Global constraints:** tests first per `SUBAGENTS.md`. No Dart core rebuild. No Drift schema change. No rules or index change. No listed-exam response change. Stop on any ambiguity. No commit attribution. Web `flutter analyze` clean. No `console` logging of track names.
**Hours** are worker plus review for balanced scope plus by-part clocks.

| Task | Who | Hours | Depends on |
|---|---|---|---|
| T0 Choices, previews, records, preflight | Lead | 3 | Aedwon's answers |
| S1 Identity, block validation, corpus loader | Sonnet | 3 | T0 choice 1 |
| S2 Settings, registry, roadmap, track reads | Sonnet | 6 | S1 |
| S3 Ingest, insights, diagnosis, carry count | Sonnet | 3 | S2 |
| S4 Mock paper, availability, start, results | Sonnet | 6 | S2 |
| S5 By-part clocks on the server | Sonnet | 12 | S4 |
| A1 Audit of the server | Codex Sol at high effort, read-only | 2 | S1 to S5 |
| A2 Fix audit findings | Sonnet, lead rules | 2 | A1 |
| C1 Delivery, receipts, reload, restore base | Sonnet | 3 | A2, window open |
| C2 Subject picker and corpus topics | Sonnet | 2 | C1 |
| C3 Your exams, Settings path, switch warning | Sonnet | 6 | C1, previews 1, 6, 7 |
| C4 Mock client | Sonnet | 5 | C1, previews 4, 5 |
| C6 By-part paper client | Sonnet | 12 | C4, preview 8 |
| C5 Pro page and beta row | Sonnet | 3 | previews 2, 3 |
| E1 Full checks and browser path | Sonnet, Haiku | 4 | C2 to C5 |
| R1 Merge and records | Lead | 1 | E1 |
| D1 Staging deploy and smoke | Lead, on approval | 2 | R1, Aedwon's approval |
| Total | | 75, not counting Aedwon's time on previews and visual acceptance | |

Parallel: S3 and S4 after S2. C2, C3, C4, C5 after C1 in separate worktrees, except that C3 and C5 both touch Settings routes, so run C3 first. Elapsed about 10 working days at one lead, about 7 at best.

## T0. Choices, previews, records, preflight (Lead, 3h)

1. Record the founder's decision and each answer, verbatim, in `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md` on main with `[skip ci]`. This document, with its plan, is `docs/superpowers/specs/2026-11-04-custom-exams-on-web-design.md`.
2. Read hosted `content/catalog/items/index`, if login is available. Otherwise add it to Aedwon's list.
3. Create the worktree and branch from `web/visual-check-fixes-r1`. Record the SHA.
4. Build previews from 2.17 with a Sonnet subagent. Aedwon approves.
5. Decide the beta gate per choice 4 and write the date on the status line.

Done when: choices recorded, branch exists, previews approved or scheduled.

## S1. Identity, validation, corpus (Sonnet, 3h)

**Files:** new `functions/src/_customTrack.ts`. `functions/src/_examContent.ts`. New `functions/test/custom-corpus.test.mjs`. Additions to `functions/test/endpoints.behavior.test.mjs`.

1. Tests: regex accepts a v4 uuid form, refuses bare, uppercase and v1 forms. `checkCustomBlueprint` table from 2.2. Union test on the real tree counts from 2.1. Run against `tools/upload_content --out-dir` documents, seeded into the emulator or read through a fake db.
2. Implement `isCustomExamId`, `isStudyExamId`, `customTrackRef`, `checkCustomBlock`, `checkCustomBlueprint`, `inCustomCorpus`.
3. Add the custom branch to `loadStudyContent` with dedupe. Extract `applyScope`. Add `loadCorpusCached(db, now)` with the existing TTL, cleared by `clearExamContentCache`.

**Stop if:** dedupe would change a listed exam's result. A snapshot test of `exam_cse_pro` content must pass unchanged.

**Check:** `npm run build && node --test test/custom-corpus.test.mjs test/endpoints.behavior.test.mjs`.

## S2. Settings, registry, roadmap (Sonnet, 6h)

**Files:** `functions/src/roadmap.ts`, new `functions/src/customTracks.ts`, `functions/src/index.ts`, `functions/test/study-roadmap.emulator.mjs`, new `functions/test/custom-track.emulator.mjs`, `functions/test/l1-rules.rules.mjs`, `functions/test/server-pro.emulator.mjs` only if a fixture needs the corpus.

1. Tests from the 2.15 table for `setExamSettings`, `getRoadmap`, `advanceRoadmap`, day, week, `getCustomTracks`, `deleteCustomTrack`, cross-account.
2. Implement per 2.2 and 2.4.
3. Add a listed regression fixture: full `getRoadmap` JSON for one CSE student, compared to the JSON before the change. Save it from the base commit before editing.

**Check:** `firebase emulators:exec --only auth,firestore,storage --project demo-pantas-test "node --test --test-concurrency=1 test/custom-track.emulator.mjs test/study-roadmap.emulator.mjs test/roadmap.emulator.mjs test/l1-rules.rules.mjs"`.

## S3. Observations and readers (Sonnet, 3h)

**Files:** `functions/src/ingestSession.ts`, `studyInsights.ts`, `sessionDiagnosis.ts`, `carryableCount.ts`. Tests: `study-observations.emulator.mjs`, `carry-over-figures.emulator.mjs`, `session-diagnosis.emulator.mjs`, `carryable-count.emulator.mjs`, `custom-track.emulator.mjs`.

Implement per 2.5, 2.6, 2.9. Insights' listed `sourceRevision` must stay the same string. Test that.

**Check:** the named suites through `emulators:exec`, plus `node --test test/study-insights-core.test.mjs`.

## S4. Mock (Sonnet, 6h)

**Files:** `functions/src/mock.ts`, `functions/src/mockReader.ts`. Tests: `mock-paper.emulator.mjs`, `mock-reader.emulator.mjs`, `mock-reviews.emulator.mjs`.

1. Write the paper tests first, using real topic sizes: verbal logic 20, all-passage comprehension skills 160, two overlapping all-topic parts.
2. Implement `assembleCustomPaper` per 2.7. No Dart change.
3. Add `examName` to the mock row, `view`, and `summary`, for custom only.
4. Availability reads the track. Setup preview uses the custom assembly. No new status.

**Stop if:** the sampler cannot honor fractional weights over reduced pools. Report it. Do not edit the compiled core.

**Check:** the named suites.

## S5. By-part clocks on the server (Sonnet, 12h)

**Files:** new `functions/src/_mockParts.ts`, `functions/src/mock.ts`, `functions/src/mockReader.ts` if a reader needs it. New tests `functions/test/mock-parts.test.mjs`, `functions/test/mock-parts.emulator.mjs`. Additions to `functions/test/mock-paper.emulator.mjs` for a listed key-by-key regression.

1. Pure rules first, with tests that fail: `settleParts`, `partsView`, `mergePartAnswers`, used time. No Firestore in that file.
2. Wire into `beginMock`, `readMock`, `changeMock`, `recordMock` and `endIfTimedOut`, per 2.7. Every by-part transaction settles on the row it read, then acts on the settled row.
3. Listed and one-clock rows take the existing code path. A test pins the exact key list of `view` and the exact error for the new actions.
4. Abuse cases from 2.7, each with a test.

**Stop if:** the compiled core or the mock results reader needs a change.

**Check:** `node --test test/mock-parts.test.mjs`, then the named suites, then full `npm test` for all of S1 to S5 on hosted Actions.

## A1. Adversarial audit (Codex GPT 6.1 Sol at high effort, read-only, 2h)

Aedwon changed the auditor from Astra to Sol on 5 November. Small prompts by server area, one at a time, so a limit cannot restart a large run. Run through `codex-pick exec --skip-git-repo-check` in a read-only sandbox, on the `web/custom-exam-r1` diff from base. High-stakes because it changes server data contracts.

Prompt scope:

- Can any caller read or change another account's track, plan, sessions or mocks, by any callable, id form or `expectedUid` value?
- Can a custom id reach `coversExam` as true, reach Pro fields, or bypass the mock cooldown through multiple tracks?
- Can any input produce a paper with repeated questions, a short paper without refusal, or a result the reader refuses?
- Can any client request add time to a by-part paper, reopen a closed part, change a closed part's answers, answer a later part early, or leave a Strict paper running past its limits and breaks? Can concurrent requests do so?
- Does a settle ever close a part at the wrong moment, including across pauses, chained time-outs and discard?
- Can a custom session corrupt `answerTotals`, or double count on replay, or lose answers on a filtered replay?
- Do any listed-exam responses, digests or cache keys change?
- Can transaction size, the corpus read or a crafted `sectionsJson` exhaust memory or time?
- Are all track fields bounded and non-logged?
- Does deploy order hold if hosting and functions are out of step in each direction?

Output: findings by severity with file and line, no fixes. Astra never edits. If quota is exhausted (`codex-pick` exit 75), report the reset time to Aedwon and hold the client window. Do not substitute.

## A2. Findings (Sonnet with lead rulings, 2h)

Lead rules on each finding. Sonnet fixes with a test for each. Any entitlement-touching finding goes to the lead and to Aedwon. Rerun the relevant suites.

## C1. Delivery, receipts, reload, restore base (Sonnet, 3h)

**Files:** `study_delivery.dart`, `study_observations.dart`, `study_api.dart`, `custom_track_repository.dart`, `bootstrap.dart`, `local_state_wiper.dart`, `local_study_reset.dart`. Tests in 2.15, plus `test/core/sync/local_state_wiper_test.dart` or the existing wipe test.

1. Failing test first: reload loses the exam on web. Keep the test if it proves the reading right. If the reading was wrong, report and adjust.
2. Failing test: a wipe leaves a `customTrackMetaLocal` row. Delete it in `wipeAll` and the local reset, before `reprojectAll` lands.
3. Remove the guard. Add the payload block. Change the receipt key.
4. Add `reprojectAll`, `name`, `blueprintPayload`, `restoreFromServer`, `requestAccount`.

**Stop if:** layering check objects to a read path. Keep reads in `CustomTrackRepository` on `AppDatabase`.

**Check:** the named tests, `dart run tool/check_layering.dart`, `flutter analyze`.

## C2. Picker and corpus topics (Sonnet, 2h)

**Files:** `custom_track_subjects_step.dart`, `custom_track_name_step.dart`, `track_scope.dart`, new `custom_corpus.dart`, `whats_included_page.dart`, `onboarding_page.dart` (delete on discard). Tests: `custom_track_steps_test.dart`, `whats_included_page_test.dart`, `server_catalog_contract_test.dart`, `onboarding_custom_back_test.dart`, `onboarding_custom_to_home_test.dart`.

The contract test builds the catalog from the real tree and asserts each offered topic has at least one question.

## C3. Your exams, Settings path, switch warning (Sonnet, 6h)

**Files:** `exam_picker_screen.dart`, `settings_routes.dart`, `settings_routes_native.dart`, `settings_routes_web.dart` if needed, `custom_track_subjects_step.dart` (`fromSettings`). Tests: `exam_picker_screen_test.dart`, `web_onboarding_states_test.dart`, `router_settings_test.dart`, `deferred_settings_routes_test.dart`.

1. Failing test first: Settings row while complete does not reach the name step.
2. Build to the approved previews 1:1.
3. `router.dart` is not touched. New routes are outside `/onboarding/`.
4. Reuse the same save and carry sequence as `ChangeExamPage`. Do not write a second copy: extract one private helper in that file.

## C4. Mock client (Sonnet, 5h)

**Files:** `custom_mock_setup_route.dart`, `custom_mock_setup_page.dart`, `web_custom_mock_setup.dart`, `mock_setup_route.dart`, `mock_setup_page.dart`, `quiz_routes.dart`, `mock_panel_providers.dart`, `server_mock_route.dart`, `server_mock_results.dart`, `server_mock_paper.dart`, `mock_results_providers.dart`, plus `study_delivery.dart` (`settled`). Tests in 2.15.

Panel table from 2.7 is the acceptance list. Repair publish runs at most once per provider lifetime.

## C5. Pro page and beta row (Sonnet, 3h)

**Files:** `pro_page.dart`, the beta row's page. Test: new `pro_page_custom_test.dart`. Existing `pro_page_*` tests stay green.

Follow preview 2.

## C6. By-part paper client (Sonnet, 12h)

**Files:** `server_mock_paper.dart`, `server_mock_session.dart`, `server_mock_api.dart`, `server_mock_route.dart`. Tests in 2.15. No change to `mock_session_page.dart`, `part_transition_page.dart` or `pause_page.dart`, unless preview 8 needs one.

1. Parse the optional `parts` block. A paper without it runs one block, as now.
2. Add `startPart` and `endPart` to the session's ordered queue.
3. Show `PartTransitionPage` while waiting, and bind `canGoPrevious`, `canGoNext`, `onGoTo`, `partPosition` and `oneBlock: false` to the running part.
4. At zero on the part clock, read the server. Never close a part locally. On a part change, adopt the server's answers for closed parts.
5. In a Strict break, read the server when `startsInMs` runs out.
6. Send a pending save at once when under 3 seconds remain in the part.

Follow preview 8 1:1.

## E1. Full checks and browser path (Sonnet, Haiku, 4h)

1. Add `customFresh` sample student and seed.
2. Run the path in 2.15 at both sizes. Report each step with pass or fail and the function log summary. No screenshots.
3. Haiku runs the full check set on hosted Actions on the branch. Sonnet fixes failures. A pre-existing failure is reported, not silently passed.

## R1. Merge and records (Lead, 1h)

1. Merge the current `web/visual-check-fixes-r1` in. Rerun build_runner if anything schema-related arrived.
2. Merge `web/custom-exam-r1` into `web/visual-check-fixes-r1`, then `web/staging-candidate-r1`. Verify remote SHAs.
3. Update the launch log and the SSOT status with what ran and what did not.

## D1. Staging deploy and smoke (Lead, 2h, on approval)

Steps 1 to 5 of 2.14. Production is a separate approval. If the beta gate date passes before this is green, apply choice 4.

---

## Limits and known gaps recorded

- Phone sampler keeps the short paper and repeat faults for custom breakdowns.
- Two devices on different exams stay as they are, same as listed.
- Web and phone cooldowns differ, 30 and 14 days. This predates this work.
- The phone's between-parts wait in Strict has no limit. The server's has 60 seconds. Phones are not publicly released, so this is left for the native mock work.
- An answer that reaches the server after its part closed is lost, with no grace period.
- Scope has no time stamp, so a browser holding an old list can widen a track that another browser narrowed, the same as a listed exam's settings. Nothing is lost, and the student can untick again.
- Sections that overlap only in part, which the setup screen cannot make, can be refused when an order exists that would fill them. They never repeat a question or come up short.
- No student-facing delete for a custom track.
- No founder view of track names.
- Promoting a custom track to a real exam stays deferred, per the 2 August spec.
- Hosted content and deployed functions were not read. T0 and D1 cover it.
- The reload, Settings path and Pro page findings are by reading. C1, C3 and C5 prove each with a failing test first.
