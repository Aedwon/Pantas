# CET completeness sweep

Content base `29bc87c1f`. Main tools and policy `fd6789a45`. Local checks only.

- Fixed five false approval flags in Essays, Editorials, Opinion Pieces, and News Articles (0016–0020).
- Fixed ten false approval flags in Visual Media (0011–0020).
- Filled six PSHS-NCE pools that started at 0 of 2. The standard pool check skips lessons with no question exam tags at all.
- Labeling Overlap Regions, Labeling Three-Shape Regions, and Matching Dot Placement now have two questions each.
- Matching Dots Outside a Shape, Matching Two Dots, and Dots on Shape Boundaries now have two questions each.
- Independent blind solves matched all 27 keys. `approve.dart` recorded each approval. Evidence is in `docs/content/verification/cet-split.md`.
- Scanned all 4,404 authored questions. None is missing from both ledgers. None has `approved: false` or `isActive: false`.
- Checked 1,066 active authored lessons. All have full per-exam quiz pools, summaries, and a file for each illustration marker. The 174 retired lessons were excluded from text checks.
- The text sweep found no unfinished CET copy matching the requested markers. CSE Subprofessional has an explicitly labeled placeholder split because official section counts are unavailable. That paper filled in the mock probe.

## Verification

- Main export exit 0. It skipped four questions waiting for figures and resolved 1,117 lesson links and 204 gap tags.
- Approval gate, lesson checks from `cet-finish-443d02`, and main's check runner exited 0. The question validator emitted 4,404 rows with zero errors.
- Tier regeneration matched the checked-in file byte for byte. Functions built and all 33 uploader tests passed.
- Upload dry run and offline document export exited 0. Dry run reported `no database was read or written`.
- SVG preflight checked 427 files with zero failures. All seven Python tests passed. The negative fixtures produced all 29 expected failures.
- The seed and signed package built. Package verification exited 0 with key ID `f1aa79b5e6889511` and digest `af2709af684430e2e4ae31e3a26e2e4a59fb18bb5e3220f324d7a25128e392f0`.
- Raw logs are in `/private/tmp/cet-sweep-check`. Package artifacts and offline upload documents stayed there. Nothing was staged, committed, or uploaded.

LEFT:

- `q-geometry-practical-measurement-0006` needs a closed polygon through authored vertices on a unit square grid. The graph painter can plot points and lines. The geometry painter draws fixed shapes.
- `q-geometry-practical-measurement-0012` needs a closed polygon through five authored vertices on a unit dot grid. The registry has no dot-grid polygon type.
- `q-geometry-practical-measurement-0016` needs two closed polygons labeled P and Q on separate dot grids with the same unit scale. No painter draws these panels.
- `q-arithmetic-number-sense-counting-and-digit-patterns-0014` needs a 4-by-4 unit grid with only the top and right edges of the upper-right cell omitted. The matrix painter tops out at 3-by-3 and the cube-net painter at eight cells.
- Five active Text Types lessons lack key points. Essays and Editorials, Poetry, Short Stories and Excerpts from Novels, Speeches, and Visual Media were outside the settled split plan. They retain their five-question quizzes. Adding key points alone changes quiz length under the exporter. They need a split and question map.
- DCAT and USTET each filled 128 of 128 draws with local shared topic IDs and 0 of 128 with server IDs. The blueprints use `topic_upcat_*`. The server uses exam-prefixed IDs, and the sampler only maps CSE aliases. One YAML ID cannot serve both paths today.
- UPCAT filled 125 of 128 draws in each path. Three retakes had 49 of 50 Reading Comprehension questions. Greedy passage selection can strand one comprehension slot after recent questions are removed. The sampler needs to find a combination that fits the existing 25/25 blueprint.
- ACET has no blueprint in this branch. Main's copy has an unresolved 27-minute aptitude placeholder. The current pool has 54 verbal logic questions for its 45 slots.
- Two existing lesson diagrams have fixed painter text. Orbital Shapes pairs subshell capacities with orbital labels. Seismograph Arrivals omits the shared-path and steady-speed condition. The lesson text gives the correct labels and condition.
- The legacy illustration audit exited 1 with the same 607 lines as the baseline. It still expects the pre-split inventory. The active marker-to-file scan and offline uploader passed.
- The corpus and fixture SVG Flutter render tests and the placeholder test each failed to start because the sandbox denied the loopback socket. Staging account verification requires an upload and remains unrun.
