# CET mock pool topic IDs

Code and policy `origin/main` `fd6789a45`. Content `work/cet-mk` at `29bc87c1f`.
That content head has DCAT and USTET YAML but no ACET YAML. The offline run used main's ACET YAML with the same content head's question bank. The live ACET document was not checked.

## Server and staging web

- `tools/upload_content/upload_content.mjs:112–127` reads question and mock YAML. `functions/src/contentUpload.ts:55–67,80–107,248–269` stores question set metadata and writes each mock's unmodified `sectionsJson` to `content/mocks/items/{examId}`.
- `functions/src/_examContent.ts:45–50,72–87` filters question sets by exam tag, drops inactive and unresolved-figure questions, then assigns `topic_dlsucet_*`, `topic_ustet_*` or `topic_acet_*` from the requested exam and the set topic slug.
- `functions/src/mock.ts:126–154,272,466–471` keys questions and passage sets by those IDs and passes the blueprint JSON, pools and last two papers to the compiled Dart sampler. `server_dart/mock_codec.dart:11–35` parses the same section IDs and weights the native sampler uses.
- `lib/features/mock_exam/data/mock_sampler.dart:33–43,81–85,103–133` allocates slots by blueprint topic and looks up each pool by its exact key. Its only fallback maps CSE-prefixed blueprint IDs to shared IDs. It throws when a section is empty and can return a short section when some questions fit.
- `functions/src/mock.ts:124,148–154` turns a sampler throw into `failed-precondition` with “There are not enough questions for this mock yet.”
- Staging builds Flutter web from `lib/main_staging.dart` (`tool/deploy/staging_web.sh:8–12`). The web flag selects server setup and start (`lib/features/mock_exam/application/server_mock_results_providers.dart:12,214–224`, `lib/features/mock_exam/presentation/pages/mock_setup_route.dart:62–76`, `lib/features/mock_exam/presentation/pages/server_mock_route.dart:197–212,622–636`). Setup calls the same assembly at seed 0 (`functions/src/mockReader.ts:110–113`). Main's setup UI shows “Mock paper not ready” after that refusal (`mock_setup_route.dart:194–203`).

## Local Dart path

- `tools/build_content_export/build_content_export.dart:144–173,455–466,804–839` exports shared `topic_upcat_*` identities and keeps blueprint IDs and weights as authored. The web catalog also ships shared topic IDs and authored blueprints (`functions/src/contentUpload.ts:170–185,197–210`).
- `lib/features/mock_exam/application/mock_blueprint_providers.dart:5–18` parses local blueprint sections. `lib/core/storage/data/repos/content_repository.dart:91–145,371–392` exposes shared topic IDs and filters questions by exam tag. `lib/features/mock_exam/application/mock_start_providers.dart:65–89` keys both local pools by those topic IDs.
- Native start runs Dart locally and shows its retry view if sampling throws (`lib/features/mock_exam/presentation/pages/mock_start_route.dart:151–197,835–846`). The earlier “web sampler” rejection matches this local-pool test when given CET-prefixed blueprint IDs. The deployed web route samples on the server.
- UPCAT uses `topic_upcat_*` on both paths (`content/mock/upcat.yaml:22–25`). CSE Pro and Sub use `topic_cse_pro_*` and `topic_cse_sub_*` (`content/mock/cse-pro.yaml:34–43`, `content/mock/cse-sub.yaml:32–39`). Those match the server pools directly. The fallback resolves them against shared local pools.

## Offline proof and verdict

- Main's Functions build, Dart export and uploader `--out-dir` exited 0. The uploader reported 183 question sets and 6 mock blueprints for the scratch inputs. Uploader tests passed 33/33.
- Scratch evidence is in `/private/tmp/cet-mock-id-trace.aOaJhE/`. Run `node probe.cjs` there. It uses main's real `assemblePaper` with an in-memory Firestore reader, the compiled sampler, uploader payloads and export rows. It compares section sizes and counts repeated IDs across the whole paper. Each successful route ran seeds 0–127 with empty history and with two prior papers.
- All three shared-ID blueprints reproduced the server error. Replacing both ID lists and weight keys with the exam prefix, in memory, made all three fail locally. Listing both forms would split the fixed allocation across keys each path can only partly resolve.
- With matching prefixes, DCAT returned 235/235 and USTET 300/300 in every run. ACET returned 270/270 on every first attempt and 126 of 128 retakes. Seeds 0 and 119 returned 269/270 because the English comprehension draw filled 14 of 15 slots. All returned CET papers had zero repeated IDs.
- UPCAT, CSE Pro and CSE Sub filled all first attempts with their authored IDs on both paths. One UPCAT retake was short by one. Both CSE papers filled every tested retake.
- Smallest ID fix is in `functions/src/mock.ts:137–144`. Key both DCAT, USTET and ACET mock pool maps with the shared prefix. Keep the exam-tag filter and the existing CSE and UPCAT behavior. This keeps the YAML usable by the local sampler as written.
- Full ACET retakes also need a fallback at `lib/features/mock_exam/data/mock_sampler.dart:45–75`. If the greedy passage draw comes up short, find an exact fit using whole sets, preferring unseen sets and allowing recent sets when needed. Rebuild `functions/src/generated/pantas_core.js` with `server_dart/build.sh` so web gets the same fix.
- Only this note changed. The package build and verification are conditional on a content-only fix. Staging was not contacted.

NEEDS CODE CHANGE: use shared CET topic keys in server mock pools and add an exact-fit fallback for short passage draws.
