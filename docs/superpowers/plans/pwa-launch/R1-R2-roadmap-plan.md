# Implementation plan: roadmap R1 (prerequisite-aware recommendations) and R2 launch part (debrief diagnosis data)

Status: lead-reviewed October 29 (rulings in section 12). Drafted by Sonnet 5.5 from the spec and code. Policy read from `origin/main` 57981351.
Complexity: balanced (Aedwon, Oct 29: "okay proceed as in the spec"). No cap on how far Free users advance.
Spec: `docs/superpowers/specs/2026-10-26-prerequisite-roadmap-design.md`. Decisions: launch log entries "2026-10-26 Roadmap
dependencies" to "2026-10-29 Roadmap R1 and R2 approved as specified". Ruling: `plans/pwa-launch/C1-C10-ruling.md` (C10).
Code read on `web/staging-candidate-r1` f176a763. Content read on `content/cse-rewrite-r1` (via git archive to scratchpad, nothing edited).

## 1. What the code says (evidence)

### 1.1 Per-lesson data the engine needs, and where it comes from

The engine today has no per-lesson mastery. `RoadmapInputs` (`lib/features/roadmap/domain/roadmap_inputs.dart`) carries only
topic scores (`RoadmapTopicScore`, correct/answered per topic), `RoadmapLesson.readAt`, `RoadmapQuestion.lessonId`,
`seenQuestionIds`, `dueReviews` (due questions only) and a topic-level `prerequisites` map. `BuildRoadmap.call` never sees
who got which question wrong.

| Need | Device (native, `RoadmapInputsReader.inputs`) | Server (`studyContext` in `functions/src/roadmap.ts`) |
|---|---|---|
| Lesson read (`unseen`) | `lessonProgressLocal.readAt` already mapped to `RoadmapLesson.readAt` | `server/lessonReads/items` already mapped to `readAt` |
| Question to lesson | `RoadmapQuestion.lessonId` from `selectionRowsByTopics` | `loadStudyContent` question `lessonId` (catalog set `lesson`) |
| Answers per lesson | NEW. Reader's `_scores` already loops every completed `attemptsLocal` row through `AttemptItemReader`; extend that loop to also keep per-question answered count | `answerTotals` row `answered`/`correct` per question (`_answerTotals.ts` `TotalsRow`), already read as one doc |
| Recent accuracy | NEW. Last 3 outcomes per question, attempts ordered by `completedAt` | NEW. `answerTotals` version 3: per question `recent` (last 3 outcomes, as one small integer) |
| Recall | NEW. Today the reader calls `scheduler.retrievability(state, now)` only for due reviews. Compute it for every in-scope state from `allStates()` | NEW. `studyContext` already reads the whole `server/reviews/items` collection but keeps only due states. Pass every in-scope state to `core().dueReviews` (it already returns retrievability for every state given) and filter "due" in TS |
| Chosen wrong choice | `AttemptItem.chosenChoiceId` inside `attemptsLocal.itemsJson` (also sent by `studySessionPayload` as `chosen`) | stored answers keep `chosen` (`_answers.ts`, `ingestSession.ts`); totals v3 keeps the last wrong choice letter per question (`lw`) |

Stored answer form of a choice: `<questionId>_<label lowercase>`, label by authored position A to F (`question_set_mapper.dart`,
`build_content_export.dart` `_key`). Display order is shuffled separately (`orderChoicesFor`), so the id is stable.

### 1.2 "Recent" (rule 1), proposed definition (lead to confirm, see Q3)

- Per question, `recent` = its last 3 outcomes, oldest to newest.
- Lesson `answered` = sum of all-time answers over the lesson's questions. Lesson `recentAccuracy` = correct / total over the pooled `recent` outcomes.
- Lesson `recall` = mean retrievability over the lesson's questions that have a review state. Null if none. FSRS is read only.
- State: `unseen` = not read and zero answers. `learning` = read or answered, under 5 answers. `weak` = 5 or more answers and `min(recentAccuracy, recall ?? 1) < 0.70`. Otherwise `solid`.
- Constants live in one file (`mastery_thresholds.dart`): threshold 0.70, minimum answers 5, window 3.
- Server order limit: the window follows ingest order, not finish order. A session retried late lands last. Name this limit in a code comment.

### 1.3 Rule 4: how attribution gets the chosen wrong choice

- On device: `AttemptItem.chosenChoiceId`. On server: `users/{uid}/server/answers/items/{sessionId}.answers[].chosen`.
- For the plan (no session scan): totals v3 stores `lw` per question, the letter of the last wrong choice, only while the latest outcome is wrong. At read time `gapTags[<qid>_<lw>]` gives the prerequisite.
- For the debrief: `getSessionDiagnosis` reads the one stored session doc and applies the same function.
- A miss is "traced to P" only when P is currently `unseen` or `weak` (both paths: gap tag, or P is a weak or unseen required link of the missed question's lesson). Otherwise the gap is in the lesson itself (spec rule 4). So every traced miss has a plan fix.

### 1.4 Content export and uploader must carry

- Input files (content lead owns): `content/lesson-prerequisites.json` (90 source lessons, 64 links, 4 required), `content/question-gap-tags.json` (80 questions, 115 tags, keyed by choice text).
- `tools/build_content_export/build_content_export.dart` reads both, validates, and writes two new top-level arrays in the export JSON: `lessonLink` `{lesson, requires, strength}` and `gapTag` `{question, choice, prerequisite}`. `choice` is the stored answer form (`<qid>_<letter>`), mapped from the choice text at export time.
- Validation, exit 65 like the other export errors (all must be tested): bad shape or version; unknown lesson id on either side of a link; self link; duplicate link; strength not `required`/`helpful`; any cycle over all links (required and helpful); gap tag question unknown; tag text matches no choice; tag text matches two choices; tag on the correct choice; tag prerequisite not a link target of the question's own lesson (recommended, holds for all 115 tags today); tag lesson unknown. A tagged question held back for a pending figure is skipped and counted on stdout.
- Link targets outside the 90 (3 today: `functions-and-relations`, `biology-cellular-metabolism`, `thermodynamics`) must exist as lessons somewhere in the export (UPCAT lessons). The engine ignores links outside the student's scope.
- Uploader (`tools/upload_content/upload_content.mjs`, `functions/src/contentUpload.ts`):
  - Lesson links ride in the exam catalog lesson entries (`prerequisites: [{lesson, strength}]`, no reason text). Catalog is served to every tier and is structure only, so Free may have the link graph. About 5 KB, far under the 700 KB split.
  - Gap tags go to a NEW server-only document `content/gaps/items/tags` (kind `gaps`, payload `{<qid>: {<choiceId>: <lessonId>}}`, about 15 KB). `getContent` rejects any kind except lessons/questions/catalog and Firestore rules deny client reads of `content/**`, so it is never served. Gap tags are NOT put in the catalog or the free question payload.
  - `writeContent`'s version scan lists kinds explicitly; add `gaps`.
- Native: native stores no new schema (content DB schema change is the known `addColumn` package landmine). The export also writes a slim `assets/seed/lesson_links.json` (id to `[{lesson,strength}]`) for the native reader. Native gets no gap tags (native publishing is deferred; Free devices must not hold them).

### 1.5 Pro enforcement for roadmap data today

`studyContext` computes `pro = access.coversExam(examId)` from `mockCoverage` (server ledger, not the client). `publicToday` adds `comingUp` and `history` only when `context.pro`; Free gets Today only. `dayView` returns `locked` for Free future days. `advanceStudyRoadmap` has no tier check, so there is no Free cap. R2 follows this pattern: Pro detail is added server-side only when `pro`; `reasons` (the `because` data) are part of Today, so Free gets them.

## 2. Findings that need the lead (also in section 9)

1. UPCAT topic-link equivalence cannot pass on the real data. The file has source keys for the 90 CSE lessons only. Its 4 required links derive only `algebra -> arithmetic` (matches 1 of the 4 old links) and a new `statistics-and-probability -> arithmetic`. `trigonometry -> geometry`, `precalculus -> algebra` and `language-application -> grammar-and-structure` have no lesson links, so deleting `topic_prerequisites.dart` would regress UPCAT ordering.
2. Real bug on the staging lineage: `checkAnswers` rejects `chosen` longer than 64 characters. 80 questions (all Philippine Constitution, e.g. `q-philippine-constitution-amending-and-revising-the-constitution-0001`) have choice ids of 71 characters. A session containing one of them is rejected whole with "Bad chosen option", so those answers never reach the server. Fixed in task B1 (limit becomes `MAX_ID_LENGTH + 2`).
3. Content defect: `content/questions/mathematics/arithmetic-number-sense/ratio-and-proportion.yaml` line 355. The correct choice `'$2(8)\ne4(6)$'` was written with a real newline (`\n` became a line break). Node `yaml` (the uploader) rejects the whole file, so `upload_content` would refuse the run. Dart `yaml` (the export) was not run here. This file also holds tagged question `q-arithmetic-number-sense-ratio-and-proportion-0010`. Content lead must fix before T-A6 and B2 verification.
4. The session-finished screen has no "Next" card and no `because` line. The spec places the Pro row "inside the Next card". Code has only "Start Session N" and "Done". The card and the line are new UI.
5. Spec says `gapLesson` on rationales. Real data is the separate file keyed by choice text (already settled by the lead; plan follows the file).
6. The day plan is stored per day and rebuilt only when the digest changes (exam, date, scope, content, assessment, mocks, study days). Sessions do not change the digest. So rule 3 and 4 effects show in the next day's plan, or on "Advance" (which builds the next day from fresh data). See Q5.

## 3. Branches and order

Fewest branches that keep `integration/new-design-r1` free of server lineage: two.

- Branch A `roadmap/prerequisite-engine-r1`, cut from `integration/new-design-r1` (a3386e42). Holds everything under `lib/`, `test/`, and `tools/build_content_export`, `assets/seed/lesson_links.json`. All of it exists on integration (checked: roadmap, home server-mode client, session end screen, export tool). Merge A into `integration/new-design-r1` after lead review and checks.
- Branch B `web/roadmap-server-r1`, cut from `web/staging-candidate-r1` AFTER A is merged into it. Holds `server_dart/`, `functions/`, `tools/upload_content`, regenerated `functions/src/generated/pantas_core.js`. None of this exists on integration. Merge B into `web/staging-candidate-r1` only.
- Order: A1..A7 and B tasks run in the order of section 6. B starts after A is merged into staging. Between A and B the staging tree does not compile `server_dart` (A deletes the topic map it imports), so B1 is NOT first on B: B3's codec edit is the first commit on B to keep the tree compiling; B1 and B2 follow.
- Drift to check before cutting: staging's f176a763 contains integration only up to fefe36a0. Integration's tip a3386e42 is a second merge of the same `web/lesson-svg-r1`, not an ancestor of staging. Merging A into staging brings a3386e42 in. Expect no conflict; if there is one, stop.
- The R2 screen task C1 is a later branch off integration, blocked (section 8).
- Worktrees: one per task agent. Policy: workers read `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from `origin/main`, record the revision, and run `dart run build_runner build --delete-conflicting-outputs` first in a fresh worktree.

## 4. Exact interfaces between tasks

All pure Dart under `lib/features/roadmap/domain/` (only pure imports: the engine is compiled to JS; `tool/check_layering.dart` must stay clean).

```
enum LinkStrength { required, helpful }
class LessonLink { LessonId lessonId; LinkStrength strength; }          // typedef LessonLinks = Map<LessonId, List<LessonLink>>
class QuestionHistory { QuestionId id; int answered; List<bool> recent; // oldest to newest, at most 3
                        String? lastWrongChoiceId; }                      // only questions with answered > 0
enum MasteryKind { unseen, learning, weak, solid }
class LessonMastery { LessonId id; MasteryKind kind; int answered; double? recentAccuracy; double? recall; }
abstract final class Mastery { static Map<LessonId, LessonMastery> compute({lessons, questions, history, recall}); }
abstract final class LessonGraph {   // required + helpful, scoped, cycle-closing links dropped
  static LessonGraphResult build(LessonLinks links, Iterable<LessonId> scoped);   // .requiredOf(id), .helpfulOf(id), .cycleDetected
  static LessonId? firstUnmet(LessonId target, LessonGraphResult g, Map<LessonId, LessonMastery> m); // deepest unseen/weak required prerequisite, or null
}
abstract final class TopicLinks { static Map<TopicId, List<TopicId>> derive(LessonGraphResult g, List<RoadmapLesson> lessons); } // required only, cross-topic only
enum PlanReasonKind { prerequisite, followUp, weakTopic, nextUp }
class PlanReason { PlanReasonKind kind; LessonId? forLessonId; }       // item id is the map key
class DayPlan { ... Map<String, PlanReason> reasons = const {} }        // keys: lesson ids and question ids
// RoadmapInputs: REMOVE `prerequisites`. ADD:
//   LessonLinks lessonLinks; List<QuestionHistory> history; Map<QuestionId,double> recall; Map<String,LessonId> gapTags;
// Roadmap: unchanged shape (cycleDetected now also set by lesson-level cycles).
class SessionDiagnosis {
  static SessionDiagnosisResult compute({inputs, sessionAnswers, mistakeNotes, includeDetail});
}
// Result: tracedCount; traced: [{prerequisite, forLesson, via: gapTag|requiredWeak, questions:[{questionId, position(1-based), mistake?}]}];
//         withinLesson: [{lesson, questions:[{questionId, position}]}]. includeDetail=false leaves only tracedCount.
```

JSON (server codec, `server_dart/roadmap_codec.dart`), all optional with empty defaults:
- inputs: `lessonLinks` `{lessonId:[{lesson,strength}]}`, `history` `[{id,answered,recent:[bool],lastWrongChoiceId}]`, `recall` `{qid:number}`, `gapTags` `{choiceId:lessonId}`. The `prerequisites` key is no longer read.
- plan out (`planToJson`, `roadmapToJson`): `reasons` `{itemId:{kind,forLesson}}`, omitted when empty.
- new core function `pantasSessionDiagnosis(json) -> json`: input `{inputs, session:{sessionId, answers:[{questionId,chosen,correct}]}, notes:{choiceId:text}, includeDetail}`.

Snapshot JSON (`DaySnapshot.toJson`): plan gets optional `reasons`. Old stored rows without it must still load (empty).

## 5. Rules to tests (spec acceptance list)

| Rule | Proof (Dart tests under `test/features/roadmap/domain/` unless noted) |
|---|---|
| 1 states | `lesson_mastery_test.dart`: unseen (unread, no answers), learning (4 answers), weak at exactly 5 answers and 69%, solid at exactly 70%, weak by low recall with good accuracy, recent window uses only last 3 per question, lesson with no questions is `learning` after reading and never weak |
| 2 target unchanged | existing `build_roadmap_test`, `topic_order_test`, `day_selection_test`, `coverage_property_test` pass UNCHANGED with empty links (git diff on those files shows only added tests) |
| 3 detour | `prerequisite_queue_test.dart`: unseen required prerequisite goes first; weak prerequisite two levels deep (T needs R1 weak needs R2 weak: R2 first); R2 solid and R1 weak: R1 first; solid prerequisite: plan identical to the no-link plan (no detour); weak read prerequisite surfaces as practice questions at the front and the dependent lesson is withheld today; unread prerequisite in a later topic is pulled before its dependent |
| 4 attribution | `follow_up_test.dart`: tagged wrong choice with unseen/weak P schedules P before L's re-practice; weak required prerequisite with no tag does the same; P solid or learning: no detour and no trace; correct answer or untagged wrong choice: no trace |
| 5 never block | property test: with random acyclic links every unread lesson is in the queue and appears in `weeksAhead`; withheld lesson is not dropped; helpful links never withhold, they only reorder inside a topic; `ordering` tie-break unchanged |
| 6 reason | property test: every id in `today.lessonIds` and every detour question has a reason; kinds match the cause |
| 7 FSRS | `git diff --stat origin/<base> -- lib/core/fsrs` is empty; engine files import nothing from `core/fsrs`; with no weak prerequisite the review list equals the no-link review list; overdue reviews still appear |
| 8 cycles | engine: A requires B requires A gives `cycleDetected`, back edge ignored, deterministic; export: same fixture exits 65 (`test/tools/build_content_export_links_test.dart`) |
| Topic links | `topic_links_test.dart`: fixture of the four old UPCAT links as required lesson links derives exactly the old map; second test derives from the real export and prints the diff to the old map (informational until Q1 is answered) |
| Parity | `server_dart` fixtures regenerated with R1 scenarios (links, weak states, tags); `node --test functions/test/pantas-core.test.mjs` byte for byte |
| No leak | `functions/test/session-diagnosis.emulator.mjs` (section 7) |
| No Free cap | `study-roadmap.emulator.mjs`: a Free account advances 3 times in a row with no tier error |

## 6. Tasks

Each task is sized for one Codex gpt-6.1-sol low run. Write the failing test first, run it to see the right failure, then implement (SUBAGENTS Part 3). Each commit message says why. Never stage a file outside the task's list. The lead reviews every result.

### Branch A (client lineage)

**A1. Model, links, mastery, topic-link derivation.** Depends on nothing.
Files: new `domain/lesson_links.dart`, `domain/lesson_mastery.dart`, `domain/mastery_thresholds.dart`, `domain/topic_links.dart`; edit `domain/roadmap_inputs.dart`, `domain/roadmap.dart` (`PlanReason`, `DayPlan.reasons` with default empty and in equality); edit `domain/topic_order.dart` only if its input type changes (it keeps `Map<TopicId, List<TopicId>>`, now produced by `TopicLinks.derive`); delete `data/topic_prerequisites.dart` and `test/features/roadmap/data/topic_prerequisites_test.dart`; edit `application/roadmap_inputs_reader.dart` just enough to compile (empty links) until A5; fix every constructor call of `RoadmapInputs` and `DayPlan` in `lib/` and `test/`.
Expected: section 4 types exist; `Mastery.compute` and `LessonGraph`/`TopicLinks` behave per 1.2 and rule 8; `BuildRoadmap` feeds `TopicOrder` with `TopicLinks.derive(...)` and sets `cycleDetected` for lesson cycles. With empty links all existing roadmap tests pass unchanged.
Tests: `lesson_mastery_test`, `lesson_graph_test`, `topic_links_test` (rows 1, 8, topic links).
Verify: `flutter test test/features/roadmap`, `flutter analyze`, `dart format --output=none --set-exit-if-changed lib test`, `dart run tool/check_layering.dart`.
Stop: any existing roadmap test needs editing other than adding the new constructor arguments.

**A2. Prerequisite-aware lesson queue, day selection, weeks ahead, reasons.** After A1.
Files: new `domain/lesson_queue.dart`; edit `domain/day_selection.dart`, `domain/week_preview.dart`, `domain/build_roadmap.dart`.
Expected:
- One shared `LessonQueue.build` replaces the two copies of "unread lessons by topic order then ordering" (today's picks and the week preview). Today takes the first eligible entries; the preview takes the rest, so today and the week stay consistent.
- Order: topic rank, then `ordering`, then id (unchanged). Then: a helpful prerequisite in the same topic moves ahead of its dependent (tie-break only). Then: an unread required prerequisite, in any topic, is placed before its dependent (stable depth-first, same style as `TopicOrder.emit`).
- Eligibility today: a lesson is withheld while any required prerequisite below it is `weak` (read). An `unseen` required prerequisite is simply ahead of it in the queue (rule 3 "recommend it first"). The preview treats weak as satisfied (assumes the detour is done).
- A weak read prerequisite W becomes practice items: up to 5 of W's questions (lowest recall, then last wrong, then unseen) at the front of `reviewQuestionIds` (seen) and `newQuestionIds` (unseen), at most 2 such prerequisites a day. They do not count against the review capacity or `newToday` quota.
- Questions of a withheld lesson sort after other candidates in the ranked walk but stay reachable, so the coverage property test still holds.
- Reasons: lesson picks get `prerequisite` (forLesson = dependent), `weakTopic` (topic measured under 0.70) or `nextUp`. Detour questions get `prerequisite`.
Tests: `prerequisite_queue_test.dart`, extended `coverage_property_test` and `week_preview_test` (rows 3, 5, 6).
Verify: `flutter test test/features/roadmap`, `flutter analyze`, layering.
Stop: coverage property test fails or today and week queues disagree.

**A3. Rule 4 follow-up and the session diagnosis.** After A2.
Files: new `domain/follow_up.dart`, `domain/session_diagnosis.dart`; edit `domain/day_selection.dart`, `domain/build_roadmap.dart`.
Expected: attribution per 1.3 over `history.lastWrongChoiceId` and `gapTags`. For a read lesson L with an attributed unmet P: P is surfaced as in A2 (lesson P if unseen, practice if weak) with reason `followUp`, and L's own review questions sort after P's practice (never dropped). `SessionDiagnosis.compute` classifies each wrong answer of a session as traced (with `via`) or within-lesson, 1-based `position` from the answers order, `mistake` from `notes[chosenChoiceId]` only when `includeDetail`; when false the result carries only `tracedCount`. Correct and blank answers are ignored.
Tests: `follow_up_test.dart`, `session_diagnosis_test.dart` (row 4, plus: Free result serializes with no ids).
Verify: as A2.
Stop: the same miss is traced by the debrief but produces no plan fix.

**A4. Snapshot persistence and client decoding of reasons.** After A1 (needs only the `DayPlan.reasons` field).
Files: `domain/day_snapshot.dart` (plan JSON `reasons`, `advance()` merges added items' reasons, `remaining()` passes reasons through), `lib/features/home/domain/study_models.dart` (`decodeStudyDayPlan` reads `reasons`), `lib/features/home/application/today_questions.dart` and `plan_provider.dart` constructors if they rebuild `DayPlan` (keep reasons).
Expected: a snapshot written before this change loads with empty reasons; round trip keeps reasons; server `today.reasons` reaches `RoadmapToday`. No visible UI.
Tests: `day_snapshot_test`, `roadmap_repositories_test`, a `study_models` decode test.
Verify: `flutter test test/features/roadmap test/features/home`, analyze, format.

**A5. Native reader inputs.** After A1.
Files: `application/roadmap_inputs_reader.dart`, new `application/lesson_links_loader.dart` (reads `assets/seed/lesson_links.json`), `pubspec.yaml` asset line, provider replacing `topicPrerequisitesProvider`.
Expected: `inputs()` fills `lessonLinks` (asset), `history` (completed attempts ordered by `completedAt`, last 3 outcomes, `lastWrongChoiceId`), `recall` (every in-scope review state, `scheduler.retrievability(state, now)`). `gapTags` stays empty on native (deferred surface; Free devices must not hold tags). Cost stays one pass over attempts; no question bodies (QLP-1).
Tests: extend `roadmap_controller_test`; reader test with a fake DB: history order, window of 3, recall for non-due states.
Verify: `flutter test test/features/roadmap`, analyze, format, layering.

**A6. Content export validation and slim asset.** Independent; needs the content lead's YAML fix (finding 3) for the real-data run.
Files: `tools/build_content_export/build_content_export.dart` (new `buildLessonLinks`, `buildGapTags`; export keys `lessonLink`, `gapTag`; writes `assets/seed/lesson_links.json` when given an `--assets-out` path), new `test/tools/build_content_export_links_test.dart`, fixtures under `test/tools/fixtures/`.
Expected: all validations in 1.4 with one clear message each (file, id, reason), exit 65. Choice text compared after `trim()`, the same normalization as the question mapper. Output sorted and stable (same input, same bytes).
Tests: one failing fixture per validation (including a cycle, a no-match tag, a duplicate-text tag, a tag on the correct choice) and one passing fixture.
Verify: `flutter test test/tools/build_content_export_links_test.dart`; then, on a checkout of `content/cse-rewrite-r1`, `dart run tools/build_content_export/build_content_export.dart /tmp/export.json .` exits 0 and reports 64 links and 115 tags; paste the output.
Stop: the real run rejects data. Report to the lead; do not edit content.

**A7. Client call for the diagnosis (data layer only, no UI).** After A4.
Files: `lib/features/home/data/study_api.dart` or a new `lib/features/quiz/data/session_diagnosis_api.dart`, provider `sessionDiagnosisProvider(sessionId)` that returns `null` when `studyUsesServerProvider` is false (native) or the status is `pending`.
Expected: parses `{status, tracedCount, detail?}`; never logs ids; one retry after 3 seconds when pending, then gives up silently.
Tests: parse tests with Free and Pro payloads. Verify: focused tests, analyze, format.

Merge A into `integration/new-design-r1` after the lead runs the full set (section 10), then into `web/staging-candidate-r1`.

### Branch B (server lineage)

**B3 (first). Codec, engine wiring, fixtures, build.** Files: `server_dart/roadmap_codec.dart` (new inputs and outputs, drop the `topic_prerequisites` import), `server_dart/pantas_core.dart` (+ `pantasSessionDiagnosis`), new `server_dart/diagnosis_codec.dart`, `server_dart/make_fixtures.dart` (R1 scenarios: links with a two-level weak chain, a cycle, tags, a no-question lesson; keep one UPCAT-equivalent scenario built from lesson links), `functions/src/_core.ts` (add `sessionDiagnosis` to the `Core` type and loader), regenerated `functions/src/generated/pantas_core.js` and `server_dart/fixtures/*`.
Verify, in this order:
1. `dart run server_dart/make_fixtures.dart && dart run server_dart/reference.dart`
2. `server_dart/build.sh`
3. `server_dart/build.sh --check` prints "generated JS is current"
4. `cd functions && npm run build && node --test test/pantas-core.test.mjs` (byte for byte, source hash current)
Stop: parity differs for any scenario (Date or Map ordering is the usual cause: sort ids before output).

**B1. Answer totals version 3 and the chosen-length fix.** Files: `functions/src/_answerTotals.ts`, `functions/src/_answers.ts`, `functions/src/ingestSession.ts` (only if the signature changes), `functions/test/answer-totals.test.mjs`.
Expected:
- `chosen` limit becomes 130 (`MAX_ID_LENGTH` 128 plus `_x`). Test with a 71-character choice id.
- `TotalsRow` gains `recent` (integer, last 3 outcomes with a leading 1 marker, so 0 means none) and `lw` (letter a to f or empty), written by `addSession`. `lw` is set only when the answer is wrong and `chosen` equals `<qid>_<letter>`; a later correct answer clears it.
- `toDoc`/`fromDoc` version 3; `needsBackfill` true for any other version; `backfill` sorts stored sessions by `finishedAt` before `addSession`, so rebuilt `recent` is in finish order.
- `viewOf` gains per-question `history` and still returns the old fields.
- Cost bound: no new collection and no session scan on a normal read. The existing one-time backfill is unchanged in kind. The worst-case size test is updated and must stay under 1 MiB minus its 100 KB margin (expected growth: about 7 bytes per row, at most 6000 rows).
Verify: `cd functions && npm run build && node --test test/answer-totals.test.mjs test/mock-reviews-core.test.mjs`.
Stop: the 1 MiB test fails or v2 documents stop loading.

**B2. Upload gaps and catalog links.** Files: `functions/src/contentUpload.ts` (`ContentKind` + `gaps`; `catalogItems` takes `links`; `gapItem(tags)`; `writeContent` scans `gaps`), `tools/upload_content/upload_content.mjs` (read `lessonLink` and `gapTag` from the export; one gap document), `functions/test/content-upload.test.mjs`, `functions/test/server-content.rules.mjs`.
Expected: catalog lesson entries carry `prerequisites`; `content/gaps/items/tags` is written once and idempotent (version digest); `getContent` with kind `gaps` still returns `invalid-argument`; a Free `getContent` of every kind contains no gap tag string (grep test over the served payloads of the fixture).
Verify: `cd functions && npm run build && node --test test/content-upload.test.mjs`, then `node tools/upload_content/upload_content.mjs --dry-run --export /tmp/export.json`, then (emulator) `firebase emulators:exec --only firestore --project demo-pantas-test "node --test test/server-content.rules.mjs test/content-access.emulator.mjs"`.
Stop: catalog document passes the 700 KB split because of links, or the YAML defect (finding 3) is still present.

**B4. Wire R1 into the server roadmap and add the diagnosis callable.** After B1, B2, B3.
Files: `functions/src/_examContent.ts` (`StudyContent.lessons` gains `prerequisites`; new `loadGapTags(db, now)` with the same 5 minute cache as `loadExamContent`), `functions/src/roadmap.ts`, new `functions/src/sessionDiagnosis.ts`, `functions/src/index.ts` (export), `functions/test/study-roadmap.emulator.mjs`, new `functions/test/session-diagnosis.emulator.mjs`, `firestore.rules` unchanged.
Expected:
- `studyContext` builds `lessonLinks` from the catalog (links to lessons outside the scoped list are dropped), `history` from `viewOf`, `recall` from every in-scope review state (move the due filter after the core call), `gapTags` from `loadGapTags`. The legacy `build()` projection passes empty R1 inputs (it is the pre-catalog compatibility path).
- `publicToday` is unchanged except that `today` now carries `reasons`. Free and Pro get the same Today. `comingUp`/`history` stay Pro only.
- `getSessionDiagnosis({examId, sessionId, expectedUid})`: owner check (`assertStudyOwner`), rate limit key `getSessionDiagnosis` 600 per hour, reads in one transaction: the session doc, `answerTotals`, `lessonReads`, `settings`, the catalog, and `tx.getAll` of the review states of only the involved lessons' questions (at most 300 documents; refuse beyond). If the session doc is missing: `{status:'pending'}`. If the session belongs to another exam: `failed-precondition`.
- Free response: `{status:'ok', tier:'free', tracedCount}` and nothing else. Pro response: same plus `traced` and `withinLesson` from section 4, where `mistake` is the Pro note for the chosen choice from `contentPro/{setId}` (index = letter position). The Dart call gets `includeDetail = pro`, and TS also whitelists the Free fields, so a codec change cannot leak.
- Honesty rule in data: `tracedCount` is 0 unless attribution traced at least one miss.
Tests: emulator tests: Pro full detail; Free exact key set; Free body scanned for every question id, choice id, lesson id and note text in the fixture (none may appear); pending; wrong exam; foreign uid; over-limit; Free advance 3 times; Today `reasons` present for Free and Pro; cost bound (count document reads in the diagnosis transaction and assert at most the bound; count that `answers/items` is never listed).
Verify: `cd functions && npm test` (build, plain tests, emulator suites). Paste the pass counts.
Stop: any Free response contains an id or note; any read path lists all sessions.

## 7. Server cost and data bounds

- Roadmap read: still one `answerTotals` document (plus `reviews` and `lessonReads` collections it already reads). Version 3 adds about 7 bytes per question row.
- Debrief: one session document, one totals document, at most 300 review documents. No session scan.
- Gap tags: one cached document, about 15 KB. Catalog links: about 5 KB.
- Backfill from sessions stays the existing one-time path for pre-v3 accounts (nothing is deployed yet, so only test accounts).

## 8. R2 screen (task C1): BLOCKED until Aedwon approves the final board in the visual companion

Data and gating are planned and built in A3, A7, B4. The screen is not implemented until the board is approved and the implementation matches it 1:1 (`WORKFLOW.md`, visual checking). Nothing in A or B renders a new widget. The `because` text on Today and in the "Next" card is also visible UI and is blocked the same way.

The preview must show these states, each in light and dark, on the phone width of the session end layout:
1. Free, 3 misses traced: "Next" card with the recommendation, its `because` line, and under it the one dismissible row (gold `PRO` tag, "3 of your misses trace to an earlier lesson. See which").
2. Free, exactly 1 traced (singular wording).
3. Free, row dismissed (card without the row, no gap left).
4. Free, no trace (card with `because` only, no row).
5. Pro, one traced prerequisite plus misses within the lesson: section "Where your misses came from" above "Your mistakes", with the prerequisite row (question numbers, the mistake) and the within-lesson row.
6. Pro, two or more traced prerequisites (row order, long mistake text wrapping or trimming, question numbers list).
7. Pro, all misses traced (no within-lesson row).
8. Pro, no trace (section absent, "Your mistakes" as today).
9. Pro, section dismissed.
10. Pending or failed diagnosis (must look the same as "no trace").
11. Second session the same day (no row, "never on two screens the same day").
12. Pro paused (existing "Pro paused" line) and review-batch session ("Reviews · Session 2 of 3" with the "Start Session" button) to show where the row sits.
13. Large text (130 percent) and screen reader order for the row, the tap target, and the paywall entry from the Free row (it opens the paywall at the diagnosis).
Also on the board: the `because` wording per kind (`prerequisite`, `followUp`, `weakTopic`, `nextUp`) and whether the "Next" card is added to this screen at all (finding 4).

## 9. Questions for the lead (not decided here)

1. UPCAT topic links. Data derives 1 of the 4 old links (finding 1). Options: content adds required lesson links for UPCAT lessons (recommended; spec says derived, not hand kept); or keep `topic_prerequisites.dart` as a fallback merged with derived links (contradicts "replaces the hardcoded map"). Until answered, A1 deletes the map and the real-data test only reports.
2. Native. `studyUsesServerProvider` is `kIsWeb`; native runs the engine on device and holds all Pro notes already. Plan: gap tags and the debrief diagnosis are web (server) only at launch; native gets links, no tags. Confirm this is acceptable while store publishing is deferred.
3. "Recent" and "weak" formula (1.2): `min(recentAccuracy, recall) < 0.70` with last 3 outcomes per question. The spec leaves the combination open. Confirm or choose accuracy only.
4. `unseen` means unread AND zero answers (a student who answered a lesson's questions without opening it is not `unseen`). Spec says "not read". Confirm.
5. Mid-day effect. Rule 3 and 4 act on the next day's plan or on "Advance", not on today's stored plan (spec section 4.9 stores the day). Alternative: add a mastery signature to the digest so a session reshapes today (cost: today's list changes under the student, noisier change log). Recommend: keep the day stable.
6. Weak, already-read prerequisite is surfaced as practice questions, not a re-read (a re-read cannot be marked done by the current completion facts). Confirm.
7. "Every recommendation carries a `because`": plan gives it to lessons and detour practice only. Due reviews and new questions keep no reason. Confirm.
8. Free `because` for a rule 4 detour names the two lessons ("practice P before returning to L") but no question, choice or mistake. Free also sees `tracedCount`. Both follow the spec's own Free mockup; confirm neither counts as "diagnosis data" for Free.
9. The `because` strings are structured kinds in data; text is localized in the client. Strings and where they show need Aedwon's approval (section 8).
10. Tag validation: reject a tag whose prerequisite is not a link of the question's own lesson (stricter than the spec; all 115 tags pass).
11. The Pro "mistake" line uses the existing wrong-choice note verbatim. Notes are long (mistake, why it looks right, one check). Trim rule for the board.
12. The Next card does not exist on the session-finished screen (finding 4).
13. Content: finding 3 (YAML defect) and the 3 link targets outside the 90 lessons being UPCAT lessons that must be in the export.

## 10. Final verification by the lead (combined work)

Branch A, then again on the staging merge:
```
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test tools server_dart
dart run tool/check_layering.dart
dart run tool/check_no_ai_attribution.dart
git diff --stat <base>..HEAD -- lib/core/fsrs        # must be empty
```
Branch B on the staging merge:
```
server_dart/build.sh --check
cd functions && npm test
dart run tools/build_content_export/build_content_export.dart /tmp/export.json .   # on cse content: 64 links, 115 tags
node tools/upload_content/upload_content.mjs --dry-run --export /tmp/export.json --root <content checkout>
```
Evidence: exact commands, exit codes, pass counts, source SHAs, in `plans/pwa-launch/evidence/` per project habit. Known intermittent failures (`content_seed_writer_test`, `import_questions/cli_test`) are re-run alone and reported, not hidden. Independent review (SUBAGENTS): the leak test and `answerTotals` size test are the two high-risk items; consider one Astra read-only audit of B4 before merge (payments-style high-stakes: access gating).

## 11. Global stop conditions

- A required spec rule contradicts the code or data (report, do not choose).
- Any existing roadmap test must change meaning to pass.
- Server fixture parity differs and the cause is not a sort order.
- Any Free-reachable response, file or log contains a gap tag, a traced question, or a note.
- FSRS files change. The 1 MiB totals test fails. A session scan appears in a read path.
- A task needs a file outside its list: report it as a finding, do not stage it.

## 12. Lead rulings (October 29, Claude lead, Opus 5.5)

Technical rulings within the approved spec. None changes product behavior a student sees at launch.

1. UPCAT topic links (Q1): `TopicLinks.derive` output is merged with the October 1 map for any topic pair
   the lesson data does not cover. Reason: the launch is CSE only; UPCAT has no lesson links yet, and
   deleting the map would regress UPCAT ordering. Name the limit and the upgrade path (content adds UPCAT
   required lesson links, then delete the map) in a code comment. `topic_prerequisites.dart` stays; A1
   does not delete it or its test. The topic-link test asserts the merged result equals the old map for
   UPCAT and adds the derived CSE links.
2. Native (Q2): accepted. Gap tags and the debrief diagnosis are server (web) only at launch; native
   gets lesson links, no tags.
3. Weak formula (Q3): accepted as written: `min(recentAccuracy, recall ?? 1) < 0.70`, window 3, at least
   5 answers. Constants in one file; the spec already says tune with data.
4. `unseen` (Q4): accepted: unread and zero answers.
5. Mid-day effect (Q5): keep the stored day stable; effects show on the next day or Advance.
6. Weak read prerequisite (Q6): accepted: practice questions, not a re-read.
7. Reasons (Q7): accepted: lessons and detour practice only.
8. Free data (Q8): accepted. `tracedCount` and the lesson-level reason kinds are Free data per the
   spec's Free mockup. Question ids, choices and mistake notes are Pro only.
9. Visible text (Q9, Q11, Q12): the `because` wording, the mistake trim rule and whether the session
   screen gains a "Next" card go to Aedwon with the C1 board. No task renders reason text before that.
10. Tag validation (Q10): accepted (stricter check; all 115 tags pass today).
11. Content (Q13, finding 3): recorded for the content lead in STATUS. A6 and B2 real-data runs wait
    for the YAML fix; their fixture tests do not.
12. Execution: Codex gpt-6.1-sol low through `codex-pick`, one task per run, lead review after each.
    A1 runs first; A4, A5 and A6 may follow in parallel worktrees once A1 lands, A2 and A3 in order.
