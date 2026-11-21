# Exam content summary documents (plan)

Owner: security and billing lead (r2). Approval: operations manager, Nov 21, 2026, verbatim: "go on the
summary document. One condition: if a summary is missing or its content version doesn't match the bank,
fall back to the current scan and log a warning. Add a test that fails when they disagree, so a stale
summary can never serve wrong lessons. Codex Sol builds it, Sol High reviews, then the staging proof.
Report when it is ready for prod; I'll take the "ship it" to Aedwon."
Branch `web/exam-content-summary-r1` from main. Velocity E-130. Policy main 0172e8dfb (re-read c6feb916b).

## Why

`loadExamContent` in `functions/src/_examContent.ts` reads every lesson and every question set (1,460
reads on Nov 20 content) on a cold instance or after its 5-minute cache. Its callers are `roadmap.ts`
(settings saves, roadmap rebuilds), `ingestSession.ts` (new lesson reads) and `mock.ts` (mock setup
preview and mock start). This cost staging 110,000 reads in one proof on Nov 20, and about 30 real cold
calls a day would use prod's whole free read quota (rule 7, launch log Nov 21).

## What changes

1. **One builder.** Move the body of `loadExamContent` that turns lesson and question-set documents into
   an `ExamContent` into a pure exported function (for example `buildExamContent(examId, lessons, sets)`).
   The scan path and the upload both call it, so the two cannot drift. Behavior of the scan is unchanged.
2. **Upload writes summaries.** `contentUpload.ts` gains a summary item kind written by
   `tools/upload_content/upload_content.mjs` through the existing `writeContent` plan:
   - one summary per exam found in question-set `meta.exams`, holding the `ExamContent`, a
     `bankVersion` and a `builderVersion`;
   - `bankVersion` is a digest of the sorted id and version of every lesson and question item in the
     upload, so it changes whenever any lesson or question changes;
   - `builderVersion` is a constant in `_examContent.ts`, raised whenever the builder's output can change;
   - a summary above 700,000 bytes is split into parts, like catalog items (`CATALOG_SPLIT_BYTES`), with a
     hard stop at 1,000,000 (Firestore's document limit is 1 MiB).
3. **A bank marker, written in a safe order.** One marker document holds the current `bankVersion`.
   An upload that changes any lesson or question first sets the marker to a value no summary can carry
   (for example `writing:<timestamp>`), then writes the content items, then the summaries, and sets the
   marker to the final `bankVersion` last. A crash at any point leaves the marker and the summaries
   disagreeing, so readers scan.
4. **Reader.** `loadExamContent` keeps its in-memory cache. On a miss it reads the marker and the exam's
   summary (and its parts) in one `getAll`. It uses the summary only if the summary exists, all parts are
   present, `summary.bankVersion === marker.bankVersion` and `summary.builderVersion === BUILDER_VERSION`.
   Otherwise it logs one warning line (`exam content summary unusable: <reason> <examId>`) and runs the
   current scan. Errors reading the summary also fall back to the scan.
5. The custom-exam corpus path (`loadCorpusCached`) and every other read path are out of scope.

## Tests (write first, show each failing before the code)

- Parity: for the repository's fixture content and for a sample built from `content/`, the upload's
  summary equals `buildExamContent` run on the same documents, for every exam.
- Stale: emulator or fake Firestore with a summary whose `bankVersion` differs from the marker, a missing
  summary, a missing part, a wrong `builderVersion`, and a `writing:` marker: each returns the scan's
  result (not the summary's) and logs the warning. Include a case where the stale summary lists a lesson
  the bank no longer has, and assert that lesson is not served.
- Reads: the summary path issues one `getAll` and no collection query (assert on the fake).
- Upload order: a simulated failure after the content items and before the summaries leaves the marker
  at `writing:` (assert).
- Existing suites stay green: `npm test` in `functions/` (unit and emulator), `node --test tool/checks/`.

## Free-tier count (rule 7)

0 scheduled jobs, 0 secrets, 0 minimum instances, no new API. About 10 small documents per project
(one per exam, the marker, parts if any), about 12 writes and about 10 plan reads per upload that changes
content. Reads drop from 1,460 to 2 or 3 per cold load on both projects.

## Verification and release

1. Lead review of the diff against this plan; Codex GPT 6.2 Sol High review (read-only), findings fixed.
2. CI green on the branch (`web/**` runs CI).
3. Staging (no prod): functions deploy with the pinned CLI, staging image cleanup, content upload from
   main's content tree with summaries. Proof: call each of the three paths once on staging (read cost
   measured from the Firestore read metric), confirm no `summary unusable` warning, then upload a
   one-lesson change without summaries in a scratch run and confirm the warning and the scan. Plan the
   reads first under the staging read budget (`docs/deploy-prod.md`).
4. Report to the manager as ready for prod. Prod needs Aedwon's "ship it". Prod order: functions first
   (the reader falls back while no summary exists), then the content upload that writes summaries.

## Limits

- Content edited outside the upload tool (for example in the Firebase console) does not move the marker,
  so a summary could go stale. Content is only written by the upload tool today; the fix if that changes
  is a marker update in that path.

## Standards applied

`~/Documents/Projects/agent-standards/server-caching.md` (written for this plan): a validator on every
copy (CACHE-VALIDATE), never serving a stale copy and falling back to the source (CACHE-STALE), and
Firestore read billing and document size (CACHE-FS-READS, CACHE-FS-SIZE).
