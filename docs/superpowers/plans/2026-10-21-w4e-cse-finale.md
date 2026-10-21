# W4e CSE finale implementation plan

> For agentic workers: use executing-plans inline, tests first, and one independent review of the completed bounded slice. Repository workflow supersedes extra skill approval gates.

Goal: carry the approved taller13-column CSE booklet through the original scan/gather/impact sequence into actual saved results.
Architecture: feature-local sampled motion and geometry feed a painter and one animation clock. The result view consumes that clock for original reveal intervals; route freshness selects this only for a real CSE submission. Default/history views remain unchanged.
Tech: existing Flutter animation, CustomPainter, W1 tokens and existing HalfRingGauge.mock; no packages/assets/network calls.
Spec: docs/superpowers/specs/2026-10-21-w4e-cse-finale.md; current-main L2/L3 W4e and later rulings.

## Constraints and review focus

- One dot per actual retained question;155/145/short papers and empty parts.
- Real outcome order, no use of preview sample answers or permutation.
- Original171 tracks preserved; evenly select tracks by correct-answer ordinal, translate endpoints to the actual gathering point, preserve opacity/scale/timing.
- Initial/checking13columns with vertical16/18; card/count/scan bounds for all supported counts.
- No correct answers omit ball/shake/impact; all-retired input is omitted by the existing builder.
- Fresh route only; rebuilds cannot restart; reduce motion initially or mid-flight cannot replay.
- Large text/dark/phone widths; final results retain access gates and real score/section fields.
- Data/selection changes or disposal cannot leave a ticker running; no new session writes.
- No external-workstream changes or complete-family claim.

## Task1: approved geometry and sampled motion

Files: feature widgets/cse_finale_motion.dart, cse_finale_tracks.dart; test/features/mock_exam/presentation/cse_finale_motion_test.dart. Tracks are ordinary source data extracted from the approved board, not edited .g.dart files. Create tool/extract_cse_finale_motion.py for deterministic regeneration from the main-checkout board and timeline parser.
Interfaces: CseFinaleMotion(input), dotCount, initialCard/checkingCard, initial/checking dot positions, scanEnd, frame(milliseconds) per-dot outcomes/coordinates/scale/opacity; optional verticalOffset/gatheringCenter arguments carry large-text reflow to the same real gathering point and original ball/impact sampling. Data remains immutable.
- [x] Write tests pinning155/145/short counts, thirteen-column row positions and card/count/scan bounds.
- [x] Run tests and observe missing implementation RED.
- [x] Extract original tracks from the preserved approved source; implement geometry and exact per-stop sampling/affine endpoint adjustment.
- [x] Verify geometry, outcomes, source motion stops, zero correct and final endpoints with focused tests.

## Task2: scene and result reveal

Files: feature widgets/cse_mock_finale.dart; existing mock_results_page.dart/mock_results_route.dart; optional mock-gauge opacity parameters and focused tests only if needed.
Interfaces: CseMockFinale(input,blueprintName,resultsBuilder), one original timeline clock; result view optional finaleClock. Existing consumers remain unchanged.
- [x] Tests first: actual dot semantics/count, once-only fresh CSE route, historical non-replay, reduced motion initial/mid-flight, final live review/Done controls, dark/200%/phone widths.
- [x] Run valid RED before implementation.
- [x] Paint original scanning/gather/ball/trail/impact tracks; render actual count/headers with original timing. Results own original gauge/number/breakdown/control reveal; do not duplicate the final screen or start a second gauge animation.
- [x] Preserve other-exam behavior and explicitly record still-unimplemented non-CSE finale scope.
- [x] Run focused native mock/app/shared-component checks after source freezes.

## Task3: verify, review and save

- [x] Independent read-only scoped review of this slice and actual evidence, then one tests-first correction pass if needed.
- [x] Full suite once on frozen source; scoped/broad analysis, format lib/test/tool, layering, attribution, whitespace. Preserve exact existing reader-family exception, not an invented clean claim.
- [x] Update W4e evidence and main status/decision record; normal upload and exact remote SHA verification. No development integration or family acceptance while external dependencies remain.


## Execution ledger and closeout

Source base86269158; approved text extension/e5f2f3fc decision record controls. One independent scoped review returned two P2 findings, both reproduced and fixed in one pass: eased/reflow-relative scan state and consumed-finale route lifetime across access loading. No deferred reviewer minor finding. Regression/source details are in existing evidence/W4e.md.

Final frozen-source full run:10:37 +4174 All tests passed, exit0. Renewed mock/app/gauge585pass. Analysis has only the unchanged recorded reader-family onReorder deprecation; owned code is clean. Format1487files/0changes, layering, attribution and whitespace pass. Code hashes remain unchanged through the full run, and original sampled-data regeneration remains byte-identical after verification. This completes this bounded CSE slice, not full W4e acceptance/integration. Native strict and non-CSE paths remain as before. External server/W4d contracts and human phone/live PWA acceptance are not fulfilled by these results.
