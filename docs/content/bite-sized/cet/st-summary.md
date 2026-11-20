# CET staging investigation
Main code and policy `2afab8d64` (cached `origin/main`, fetch blocked at `FETCH_HEAD`). Staging content and outline `f3d5c6f9b`.

## A. CSE mock weights
- Main's `functions/test/cse-mock-blueprint.test.mjs:37,53–70` reads `../../content/mock/{cse-pro,cse-sub}.yaml` from the test file. Both “blueprint is valid, reported and sums to the examinee's counts” tests fail: `Math.max(...weights) - Math.min(...weights) < 1e-9` (“even weights”), except Pro Numerical (0.6 arithmetic, 0.4 algebra).
- Only Verbal Ability differs. In vocabulary, grammar and structure, language application, comprehension skills order, the exact weights are:
  - Pro main `[0.3333333333333333, 0.3333333333333333, 0.33333333333333337]` → staging `[0.2727272727272727, 0.2727272727272727, 0.2727272727272727, 0.18181818181818182]`.
  - Sub main uses the same three weights → staging `[0.28703703703703703, 0.28703703703703703, 0.28703703703703703, 0.1388888888888889]`.
- Main's assertion dates to Oct 19 (`5454b9644`, Pro Numerical exception `4000ba425`). Content copied those blueprints Nov 1 (`912a57a7c`), then intentionally added CSE comprehension Nov 5 (`1ca8dfd0c`, absent from main). Pro gives comprehension 10/55 and Sub 5/36 for whole five-question passages. The Text Types split did not change the weights. Both files match prod root `646326517`.
- Both sampler tests pass. Substituting main's two YAML files in scratch made all four tests pass. The exact reverse diff is `git diff HEAD origin/main -- content/mock/cse-pro.yaml content/mock/cse-sub.yaml`. It removes both comprehension topic entries, restores the three weights above, and reverts the source notes. That would remove intended mock coverage.
- Main's Functions suite on Node 22 reached 714/717. The third failure was the App Check test's denied socket. The unit failures stopped `npm test` before the emulator phase.

## B. Grid figures
- Main's export and offline question-set payloads contain all four active `grid-polygon` specs. All four are tagged PSHS-NCE only.
- The Areas on a Grid lesson pool contains practical-measurement 0006, 0012 and 0016. Counting-and-digit-patterns 0014 belongs to Counting Squares by Size in Arithmetic and Number Sense. That gives three in a lesson- or Geometry-scoped count and four across the export. Exam filtering alone cannot yield three.
- The live page's counting scope is still unverified. The generated exam catalogs contain none of the four because they omit PSHS-NCE. Their raw question-set documents contain all four.

## C. Areas on a Grid quiz
- One key point covers counting, splitting and subtracting. One worked example gives quiz size 2. `shipping_questions.dart` and the per-exam lesson check give PSHS-NCE five shipping questions for key point 1 (0002, 0006, 0012, 0016, 0021) and every other exam zero.
- `contentUpload.ts` writes quiz size 2 and the key point to the lesson, and keeps the lesson links, key points and specs in the question-set payload. The exporter emits PSHS-NCE question references but has no PSHS-NCE exam entry. As a result, the uploader writes no PSHS-NCE catalog. The bundled exam list also marks it Coming Soon, and the web picker allows only CSE.
- `lesson_page.dart` passes the active exam to `reader_gap.dart`. `quiz_starts.dart` shows the button only if that exam has an active question linked to this lesson. No quiz question or lesson edit is needed.
- Smallest staging fix: add PSHS-NCE to the roster in `tools/build_content_export/build_content_export.dart` so the uploader generates its catalog. Use a staging-only PSHS-NCE override in `lib/features/onboarding/presentation/exam_picker_screen.dart` for Coming Soon and the web CSE restriction once the catalog is available. Keep the reader's exam filter.
- In a scratch check, adding just the PSHS-NCE exam record to the exported data produced its catalog. Main's server then returned the lesson and all five quiz questions using the existing shared topic IDs.

`lesson_checks`, `content_gate`, export, and offline uploader exited 0. Only this summary was added. No upload or commit.

FAIL
