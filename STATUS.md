# CSE rewrite status

Plan: `docs/superpowers/plans/pwa-launch/E4-E7-cse-content-rewrite.md` on main (approved October
25, balanced). Base: `content/question-qa-r2` at 765c5dc0.

## P0 preparation

| Task | State | Evidence |
|---|---|---|
| P0.1 brief builder | done | d978d5a9; 78 briefs + `new-lessons.md`; 11 tests pass |
| P0.2 mechanical fixer | done, applied | bd03b0b1; 62 tests pass; 15 dash and 52 number fixes in 22 lessons, idempotent; 36 items left for writers (`needs-review`); 27 traps without a one-line warning and 43 table rows left for writers |
| P0.3 question typing check | done | d978d5a9; 24 tests pass; 8 real problems in `science/physics/light-and-optics.yaml` (not CSE) |
| P0.4 prompt page and relay hand-in | phase 1 done (rewrite, read); pull-request hand-in added Oct 25 (see below) | `tools/content_rewrite/relay/`; 118 tests pass; 28 rewrite batches planned; GitHub check passes (736d8b47); read form rule text synced to checklist 14a218d8; tools live on this branch, not the audit branch |
| P0.5 terms check | done | main `docs/superpowers/decisions/2026-10-25-cse-rewrite-p0-notes.md` |
| P0.6 new lessons and splits | applied, not committed | Plans in `docs/content/rewrite/plans/`. Oct 25 decisions applied: 5 splits (Bill of Rights x4, environment x4 plus laws, duties x2, tenses x2), 8 new part lessons plus 4 new lessons as stubs (12 files each for lesson and questions), 41 questions moved with ids unchanged (3,215 ids before and after), 12 `outline.json` entries, `split-map.json` (99 rows) applied by the brief builder (86 briefs; row totals unchanged), 18 builder tests pass. New files hold teaching only where it was moved; the rest is `<!-- REWRITE -->`. Each new file is short of 20 questions. Open: first-part titles kept (question C), tenses Filipino part inherits all 9 exam tags (question F) |
| P0.7 illustration worklist | done | 7 markers in the corpus, 3 in CSE lessons; README count stale |
| P0.8 SVG in the app | waiting | style D approved Oct 25 (`docs/content/rewrite/figure-style/`); app code waits for engineering coordination |
| P0.9 source ledger | done | `docs/content/audit/cse-rewrite-ledger.md` (header only) |

Notes: B08 brief rows on lines the fixer changed may already be fixed; the writer checks the
line and the reader confirms. Two stray chat citation markers removed from the visual media
lesson (bd03b0b1).

## October 25: splits applied (fdcbdba3)

12 lessons added: 8 split parts and 4 new stubs; 41 questions moved with ids unchanged (3,215 ids
before and after); importer exit 0. The push check on fdcbdba3 failed as expected: the length
guard (written to catch a truncated chat rewrite) flagged the two lessons that shrank by design
(bill of rights, duties and prohibited acts). Later pushes compare with the split versions. The
`REWRITE` placeholder comments raise the AI-TELL sweep count by 1 per lesson until rewritten.
New question shortfall to 20: 14 lessons, about 240 questions in all.

## October 25: pilot run 1 (Aedwon pasting, two ChatGPT accounts)

- Rewritten and handed in: RW-001 to RW-005 (14 lessons; commits 34ecd529 to 11614784).
- Read and handed in: RD-002 (3 RA 6713 lessons), RD-004 (3 comprehension lessons).
- Not done: RW-006 (earth science) and the other read batches.
- Blocker: in some chats the ChatGPT GitHub connector refused to create the `[relay]` issue
  ("This tool call was blocked by OpenAI's safety checks"), before GitHub received it. Same
  workflow succeeded in other chats, so it is intermittent or payload-specific. The chats stopped
  as instructed and did not work around it. Do not retry around the check; the lead designs a
  path that does not carry file writes in issue bodies.
- Next: lead reviews the 14 rewrites and 6 reads after the Claude usage reset.

## October 25: pull-request hand-in (built, not yet run on GitHub)

Replaces the relay issues for rewrite and read batches. The chat commits to `cse-inbox/<batch id>` with the
GitHub connector and opens a pull request `[handin] <batch id>` into this branch. Workflow
`.github/workflows/cse-handin.yml` (check name `CSE hand-in`) runs `relay/handin_ci.py`, keeps one bot comment,
holds the pull request (label `held`) on the third rejection, and squash-merges an accepted one. The old relay
hand-in still works for manual use (`/api/prompt?id=<batch>&mode=relay`).

- Batch definitions are now files in `docs/content/rewrite/batches/<batch id>.json` (the lead commits them
  before any hand-in); the state folder keeps only the order.
- A merge by `GITHUB_TOKEN` starts no push workflow, so the hand-in workflow starts `cse-rewrite-checks.yml`
  with `workflow_dispatch` (added to that file; needs `actions: write`). The page reads that run.
- `planner.py requeue` adds a read's open findings and not-fixed brief items to a new rewrite batch.
  RW-007 (the three RA 6713 lessons) was made this way.
- Live test: commit and push this branch, then run on a throwaway branch `cse-inbox/RW-007` a hand-in with
  the three lessons (or a one-line change in a fixture batch), open the pull request, and read the Actions tab.

## October 25: pull-request hand-in live

Committed dd8365cf (319 tests pass). Live test PR #30 (`cse-inbox/RW-007`, one of three lessons):
the `CSE hand-in` check rejected it in 14 seconds, naming the two missing lessons; PR closed
unmerged. The merge path is untested until the first real batch. Branch `cse-inbox/RW-007`
was deleted with Aedwon's approval.
Requeue batch RW-007 holds the three RA 6713 lessons whose reads found Major problems.

## October 25: pilot run 2

- PR hand-in merges work: RD-001 (#31), RD-005 (#32), RW-007 (#33) merged by the workflow.
- RW-006 (earth science): the ChatGPT GitHub connector refused the lesson commit (second refusal
  for this lesson, after the relay refusal). Per the plan's fallback, Codex GPT 6.1 Sol (high,
  then low for the fix) rewrote it locally; the lead cleared the earlier relay chats' two
  rejections (backup `~/.pantas-rewrite/rejections.json.bak-rw006`), ran the hand-in: one
  rejection (ILLUS, STRUCT), Codex fixed both, accepted as 58f22421 after rebase. Codex's
  sandbox cannot commit in this worktree, so the lead runs the hand-in for Codex batches.
- RD-007 duplicated RD-006 (same lessons, same rewrite commit) and was removed unused.
  RD-008 reads RW-006.
- Oct 25: RD-003 (connector refused the first file commit) runs on Codex 6.1 Sol; RD-008
  (connector refused branch creation; same earth science lesson as before) runs on a Claude
  Sonnet reader, since Codex wrote RW-006. Empty branch `cse-inbox/RD-003` left by the chat;
  delete with Aedwon's approval. Aedwon now has three Codex accounts (a, b, c) for delegation;
  how to select each account is not yet recorded. The lead's Claude usage is near its limit, so
  the lead keeps involvement minimal.
- Codex accounts (Aedwon, Oct 25): `~/.codex` is account b (default), `~/.codex-a` and
  `~/.codex-c` are a and c; all support `gpt-6.1-sol`. Select with
  `CODEX_HOME=/Users/aedwon/.codex-a codex exec -m gpt-6.1-sol ...`; unset means b. On a usage
  limit, note the reset time and switch accounts. Engineering asks before using Sol. Aedwon
  chose this setup after the October 25 terms note about limit circumvention.
- Pilot reads complete: RD-003 (Codex reader; one L09 fix by Codex account a; 72decc37), RD-006
  (PR #34 held after three form rejections; lead fixed L19 via Codex account c and handed in
  locally, 92c5bd55; PR closed unmerged), RD-008 (Sonnet reader; 28370225). Leftover branches
  `cse-inbox/RD-003` and `cse-inbox/RD-006` await Aedwon's approval to delete.

## October 25: pilot report

- 15 lessons rewritten and read (14 via web chat, 1 via Codex; RA 6713 lessons rewritten twice).
- Brief items in latest reads: 278 fixed, 9 not fixed (all in the 3 language application lessons).
- New findings in latest reads: Blocker 2, Major 20, Minor 7. 17 of the 20 Majors and both
  Blockers are in the 3 language application lessons; L18 (example coverage) is 12 of 20 Majors.
  Single Majors (L18) in penalties and enforcement, statements of assets, number and letter
  sequences.
- Hand-in rejections were mostly form-format slips; 2 batches held, both recovered by the lead.
- ChatGPT GitHub connector refusals: at least 4 named (earth science lesson 3 times), plus
  unnamed relay refusals in run 1. Codex and Sonnet fallbacks worked.
- Time: rewrites 15:34 to 18:31, reads 15:56 to 19:03 (two accounts, part-time pasting).
- Length: the 15 lessons went from 9,965 to 20,996 words (about 1,400 per lesson, within the
  1,700 ceiling).

## Final state (October 27)

| Phase | State | Evidence |
|---|---|---|
| P1/P2 lesson rewrite and reads | done: 90 lessons (78 scope + 8 split parts + 4 new lessons); 86 clean, 4 minor-only, 0 Blocker or Major | `docs/content/audit/cse-rewrite-ledger.md` (lead rulings, final state) |
| P4 questions | done: 243 new questions (all CSE files at 20+); blind solves of 1,343 questions (1 key fixed); 94 figure questions checked (2 fixed, 11 need Aedwon's visual check); 54 files synced to rewritten lessons | `docs/content/audit/cse-blind-solve-r1.md` |
| P5 Astra audit | done: 27 findings on General Information, 26 verified and fixed | `docs/content/audit/cse-astra-audit.md`, `cse-astra-verdicts.md` |
| Roadmap inputs (E8) | done: `content/lesson-prerequisites.json` (4 required, 60 helpful), `content/question-gap-tags.json` (116 tags) | spec on main `docs/superpowers/specs/2026-10-26-prerequisite-roadmap-design.md` |
| P3 figures | resumed and done Oct 29: 94 SVGs plus 2 visual-media PNGs cover all 100 lesson markers. 28 held figures committed after two Sonnet fix rounds with Codex review (17 fixed; 2 known minor spacing gaps: visual-media 07, citizenship 01). Oct 29 later: 3 figures were drawn from markers the lessons had since changed (citizenship 01, three-branches 02 and 04); Codex rewrote their briefs from the current lessons, Sonnet redrew them, Codex traced every connector (accuracy OK; layout fixed). Citizenship 01 is 627 tall, over the 560 cap, because the full flow does not fit at 14-unit text. All 96 brief markers now match their lessons. Colors: Aedwon chose option C (follow the app theme) from a trial; all 94 SVGs now use the app's theme tokens (ink, secondary ink, paper, accent), with the 9 black-and-white reasoning figures in fixed light colors so black stays black. Lead rendered all 94 in light and dark and fixed what the trial did not cover (faint outlines, red focus marks, dots). Style rules rewritten. Not yet seen in the app: renderer must map the tokens (documented in lesson-svg-authoring). 8 new: visual-media 03 to 09, logic-and-reasoning 01 (new brief; old 01, 02 renumbered 02, 03). Visual-media PNGs renumbered to lesson order; stale duplicate cartoon removed. All figures use Geist text and KaTeX math (approved trial); style rule updated. Checker 94/94 pass. Not yet seen in the app: renderer must resolve Geist and KaTeX families (engineering). `worklist.tsv` is stale (science now uses FIGURE specs) | `docs/content/rewrite/figure-briefs/`, figure-style rules |
| E7 export readiness (Oct 30) | done at 85961bca: engineering's checks pass against this branch, run with the tools from `web/staging-candidate-r1` ea0aa5bf (`build_content_export.dart build/export.json <this checkout>`: 64 links and 116 tags, one tag more than engineering expected; `upload_content.mjs --dry-run --root <this checkout>/content --export build/export.json`: no invalid sources, 170 lessons, 170 question sets). Fixes: visual-media 01 and 02 PNGs (no credit) replaced by original SVGs (Aedwon: "Replace with SVGs"), Codex review OK; layers-of-the-earth PNGs resized to 1080 px and compressed (820 KB to 137 KB, checksums updated); ratio-and-proportion choice line break fixed. `assets.json` not generated: the current export builds the map from the figure files and passes without it; generating it needs the Sanity upload tool and credentials | engineering's request |
| E7 duplicate question IDs (Oct 31) | done at 567f990c: 49 IDs shared by split lesson files (bill-of-rights x3, code-of-conduct, environment, grammar) fixed per engineering's list on main (`docs/content/2026-10-31-duplicate-question-ids.md`). IDs kept in the original file; 78 copies in the newer split files renamed to `q-<topic>-<file>-NNNN`; map in `docs/content/audit/2026-10-31-question-id-renames.tsv`. Checks with engineering's tools from `web/staging-candidate-r1` 0ad7883b: 3,246 question IDs, 0 duplicates in source and export; export 64 links and 116 tags; upload dry run no invalid sources | engineering's request |
| E7 CSE mock blueprints (Nov 1) | added `content/mock/cse-pro.yaml` and `cse-sub.yaml`, byte-identical to `web/staging-candidate-r1` 9043ad48 (approved Oct 19, Aedwon: "proceed"; last change 20692945). The uploader and the export read blueprints only from `<root>/mock`, which held only `upcat.yaml`, so CSE students would have had no mock. Checks with engineering's tools from `web/staging-candidate-r1` 9043ad48: export 64 links and 116 tags, 3 blueprints; every blueprint topic has a pool from this root (server ids `topic_<exam>_<meta.topic>`); the server's compiled sampler fills every paper over 20 seeds (Professional 155: 20/55/35/45; Subprofessional 145: 36/36/36/37; tightest pools: Professional algebra 18 of 20, Subprofessional clerical 36 of 40); upload dry run no invalid sources, 170 lessons, 170 question sets, 3 mock blueprints, 9 catalog documents, 1 gap document, 170 pro documents | release blocker, decision log Nov 1 |
| Open for Aedwon | confirm two lead rulings (penalties Section 11(c) framing; citizenship treated as English); review content; visual check of 11 figure questions; visual check of the figure gallery; build and upload (E7) | ledger |

## CET pilot (branch content/cet-rewrite-r1, from 7032eec5)

Plan: `docs/superpowers/plans/2026-11-03-cet-content-pilot.md` on main. Policy read from main 014461cb.

| Task | State | Evidence |
|---|---|---|
| 1. Branch, briefs and rules | done, not reviewed | 15 of 15 briefs in `docs/content/rewrite/cet/briefs/`; tests for the builder (27) and the lesson check (7) pass; `check_cet_lesson.py` exits 0 on all 15 unchanged lessons (longest: triangles, 1,685 words) |
| 2. Sonnet writes 10 lessons | not started | |

Briefs: 12 lessons resolve by a `### <id>` section; genetics-and-heredity and cell-biology by a `## <id>` section
(lead ruling, November 3); pulleys-and-levers has no section in its topic artifact, so its brief is built from the
facets of that exact id in `lesson-structure-data.json` and says so. No match is made by name.

Known and not ours: `dart run tool/check_no_ai_attribution.dart` exits 1 on this branch from the base. The hits are
the vendor name "chatgpt" in existing files under `tools/content_rewrite/relay/` and `tools/content_rewrite/tests/`.
This pilot adds none. They are left as they are.

## November 3: CET pilot, Sonnet writers done

Ten Sonnet lessons pass `check_cet_lesson.py`. Words after: stoichiometry 1,640; chemical-bonding 1,644; kinematics 1,553; electricity-and-magnetism 1,677; eclipses-and-moon-phases 1,649; genetics-and-heredity 1,672; triangles 1,669; quadratic-equations 1,398; pulleys-and-levers 1,676; short-stories-and-novels 1,688. Most sit near the 1,700 ceiling, so readers should watch for padding and for cut teaching. Writer flags: the short stories lesson has no worked example for style and its Filipino excerpt is writer-composed; electricity has an unknown-class Kirchhoff item left out. Not read yet: Sol reads wait for the Codex reset. Sol's 5 lessons not written.

## November 3: readers changed

Aedwon: "nah let's not wait for codex". Sonnet writes all 15 pilot lessons and Claude Fable reads them. The rule that no model reads its own writing still holds, but the cross-vendor read and the Sol writer comparison are dropped from the pilot. The Astra audit stays as the cross-vendor check. Sol may read in the final run.

Aedwon: "what why fable, you can read it yourself can't you? or another opus 5.5 agent". The Fable readers were stopped and their partial output discarded. Opus 5.5 agents read instead.

Post-pilot cross-vendor check. Lead proposed Astra on 3 to 5 Opus-passed lessons. Aedwon: "i think for now we can only afford a 6.1 Sol high audit. 5% weekly is about 30% of 1 5-hour session in codex". The check uses Sol at high effort, starting with 3 lessons. It runs through `codex-pick` after the Opus reads, as read-only.

## November 3: round 1 reads (Opus)

All 15 lessons had a Blocker or Major: 6 Blockers, 83 Majors, 52 Minors. Readers reported all worked answers correct in the batches that stated it. Top Major rules: L25 27, L18 22, L26 10, L27 8. This fails the first pilot criterion (15 of 15 against the line of 63%). Part A's fallback, a separate audit read, is on hold pending Aedwon. Round 2 runs on 5 lessons with added writer rules, to measure convergence.

## November 3: pilot verdict and final run

Verdict: first criterion failed (15 of 15 had a Blocker or Major). Convergence: Blockers and Majors fell from 35 to 10 in round 2 on 5 lessons. Aedwon approved skipping the audit fallback, dropping the 1,700 limit, and spending the cloud credit in order. The lead read stoichiometry in full and spot-read two others; the third full read named in the plan was not done because of the November 5 credit deadline. A Sol audit of 3 lessons is running; its result will be added here. Next: the cloud run from `docs/content/rewrite/cet/goal-prompt.md`.

Sol high audit done (stoichiometry, quadratic-equations, circles), 109,801 tokens. It found 2 Blockers Opus had missed, both false general statements, plus 2 Majors in quadratic-equations that Opus had not raised in that form. It also agreed with Opus on the circles "vertex" finding. Results are in `reads/sol-audit/`. Reader and writer rules now require testing general statements. Cross-vendor reads catch what Opus misses, so the final audit should sample widely.

## November 3: CET final run (cloud session)

Policy read from origin/main dc6c42fd. Status values in `final-run.json`: `round-N-fixed` means the writer closed round N's Blockers and Majors and the round N+1 read is pending. Rulings and rejected findings: `docs/content/rewrite/cet/final-run-rulings.md`.

- Fixes after round 1: stoichiometry (also the Sol Blocker), chemical-bonding, acids-bases-ph, kinematics. All pass `check_cet_lesson.py`. Round 2 reads running.
- Fixes: work-energy-power and eclipses-and-moon-phases after round 1; plate-tectonics after round 2 (its round 3 read is the last). All pass the check.
- Fixes after round 1: electricity-and-magnetism (one unconfirmed field value removed) and genetics-and-heredity. Both pass the check.
- Done at minor after round 2: acids-bases-ph (2 Minors), eclipses-and-moon-phases (1 Minor).
- Done at minor after round 3: plate-tectonics (1 Minor). Fixes: kinematics after round 2 (distance and displacement Blocker), triangles after round 1, cell-biology and circles after round 2 (round 3 reads running).
- Done clean after round 3: stoichiometry.
- Done clean after round 3: circles, cell-biology. Round 2 reads: chemical-bonding (2 Blockers, 3 Majors), electricity-and-magnetism (1 Blocker); final fixes running. Genetics fixed after round 2.
- Done at minor after round 3: kinematics (1 Minor). Pulleys-and-levers fixed after round 1.
- Done at minor after round 3: quadratic-equations (2 Minors). Botany written; electricity and chemical-bonding fixed after round 2.
- Done at minor after round 3: short-stories-and-novels (2 Minors). Written: cellular-reproduction (3,052 words) and cellular-metabolism (3,121 words), both split candidates.
- Open after 3 reads: work-energy-power (round 3: 1 Blocker, Trap #3 omits 'sliding' for friction; 1 Major, spring PE untaught). Triangles fixed after round 2. Human anatomy written (3,478 words, split candidate).
- Done at minor after round 3: genetics-and-heredity (1 Minor). Round reads: botany r1 (1 Blocker, 1 Major), pulleys-and-levers r2 (2 Blockers); fixes running.
- Open after 3 reads: electricity-and-magnetism (round 3: 1 Major, electrical safety untaught and unworked). Botany fixed after round 1.
- Open after 3 reads: chemical-bonding (round 3: 1 Blocker, boron octet trap too broad; 1 Major, formal charge meaning). Characteristics-of-life fixed after round 1; taxonomy and atomic-structure written.
- Open after 3 reads: triangles (round 3: 1 Blocker, 'square and subtract' shortcut gives a wrong hypotenuse). Round 1 reads: cellular-metabolism (2 Blockers), evolution (4 Blockers), all false absolutes.
- Open after 3 reads: pulleys-and-levers (round 3: 2 Blockers, ideal-machine definition omits pulley weight; bar weight at the middle only for a uniform bar). All 15 pilot lessons finished: 3 clean, 7 minor, 5 open. Cellular-metabolism fixed after round 1.
- Written: chemical-reactions, gas-laws, history-of-the-atom. Reads: taxonomy r1, human-anatomy r1 (6 Blockers), characteristics-of-life r2, cellular-reproduction r2, atomic-structure r1 (4 Blockers); fixes running.
- Done at minor after round 2: cellular-metabolism (1 Minor; split candidate). Fixes after round 1: atomic-structure, human-anatomy, taxonomy; after round 2: cellular-reproduction, characteristics-of-life.
- Done at minor after round 3: botany (2 Minors).
- Written: matter, mixtures-and-separation, mole-concept. Round 1 reads: history-of-the-atom, gas-laws, chemical-reactions (Blockers); fixes running. Evolution, cellular-reproduction and characteristics-of-life at round 3.
- Done at minor after round 3: cellular-reproduction (1 Minor; split candidate). Open after 3 reads: characteristics-of-life (1 Blocker: 'a seed is made of living cells' ignores dead seeds). Round 2 Blockers: atomic-structure (NH4+ ion formation), taxonomy (Rafflesia); last fixes running.
- Open after 3 reads: evolution (round 3: 2 Blockers, parthenogenesis uses eggs; Trap #3 contradicts the drift examples).
- Written: nuclear-chemistry, solutions, periodic-table. Ruling: half-life stays out of nuclear chemistry (unknown class, not in base).
- Done at minor after round 3: taxonomy (1 Minor, title vs outline). Round reads: chemical-reactions r2 (1 Blocker), matter r1 (2 Blockers, 1 Major); fixes running.
- Done clean after round 3: atomic-structure. Round 2 Blockers: history-of-the-atom (technetium sentence), gas-laws (Example 11, which ideal-gas assumption fails first); last fixes running.
- Open after 3 reads: human-anatomy-physiology (round 3: 2 Blockers, mature red blood cells need no oxygen; RNA enzymes; split candidate). History-of-the-atom and gas-laws fixed after round 2.
- Done at minor after round 2: mole-concept (1 Minor). Mixtures fixed after round 1.
- Round 1 reads: periodic-table (3 Blockers, 1 Major), nuclear-chemistry (2 Blockers, 1 Major); fixes running. Written: earths-subsystems.
- Done at minor after round 2: matter (2 Minors). Written: thermodynamics-and-kinetics. Periodic-table fixed after round 1.
- Open after 3 reads: basic-organic-chemistry (round 3: parent-chain rule, ruled Major; see rulings). Written: earths-motions. Nuclear-chemistry fixed after round 1.
- Done clean after round 3: gas-laws. Open after 3 reads: history-of-the-atom (round 3: 1 Blocker, gold-foil scattering cannot show the charge's sign).
- Done at minor after round 2: mixtures-and-separation (2 Minors).
- Done at minor after round 2: solutions (1 Minor).
- Open after 3 reads: chemical-reactions (round 3: 1 Blocker, combustion rule fails for H2 and charcoal; 1 Major, Cl = -1 used without a rule).
- Written: heavenly-bodies (3,171 words, split candidate), fossils-and-geologic-time, layers-of-the-earth. Periodic-table round 2: 1 Blocker; last fix running.
- Done at minor after round 2: nuclear-chemistry (2 Minors). Thermodynamics-and-kinetics fixed after round 1 (3,013 words, borderline split candidate).
- Done at minor after round 2: earths-subsystems (2 Minors). Layers-of-the-earth round 1: 1 Major (S-wave reason); fix running.
- Done at minor after round 3: periodic-table (1 Minor). Written: minerals-and-rocks, origin-of-the-universe, water-cycle-oceanography. Fossils fixed after round 1; heavenly-bodies round 1: 1 Blocker (Europa), 1 Major.
- Done at minor after round 2: layers-of-the-earth (1 Minor). Written: fluid-mechanics (3,261 words, split candidate). Origin-of-the-universe round 1: 1 Blocker (lithium problem). Earth's-motions fixed after round 2.
- Written: dynamics, light-and-optics (split candidate). Thermodynamics fixed after round 2.
- Done at minor after round 2: fossils-and-geologic-time (1 Minor). Minerals fixed after round 1; water-cycle round 1: 2 Blockers, 1 Major.
- Done at minor after round 3: thermodynamics-and-kinetics (2 Minors; borderline split candidate). Written: physics thermodynamics, momentum-and-impulse, scalars-and-vectors.
- Open after 3 reads: earths-motions (round 3: 1 Blocker, seasonal-constellation rule ignores circumpolar stars). Origin-of-the-universe fixed after round 2.
- Done at minor after round 2: minerals-and-rocks (2 Minors).
- Done at minor after round 3: heavenly-bodies (1 Minor; split candidate). Round 1 reads: fluid-mechanics, light-and-optics, dynamics (Blockers); fixes running.
- Done clean after round 1: momentum-and-impulse.
- Done at minor: physics thermodynamics (round 1), origin-of-the-universe (round 3). Written: units-and-measurements. Water-cycle fixed after round 2; scalars-and-vectors round 1: 1 Major.
- Written: two-dimensional-motion, waves-and-sound (split candidate).
- Done at minor after round 3: water-cycle-oceanography (2 Minors; borderline split candidate). Written: functions-and-relations, radicals-and-rationalization. Fluid-mechanics round 2: 1 Blocker, 1 Major; last fix running.
- Done at minor after round 2: scalars-and-vectors (1 Minor). Round reads with Blockers: light-and-optics r2, two-dimensional-motion r1, units-and-measurements r1, waves-and-sound r1; fixes running.
- Paused at the user's request: no new agents; running ones finish. Fixed after round 1: two-dimensional-motion, units-and-measurements, waves-and-sound. Written: basic-geometric-concepts, systems-of-equations. Their next reads are not started.
- Paused: dynamics fixed after round 2 (round 3 read not started).
- Paused: radicals-and-rationalization round 1: 3 Majors (fix not started).
- Paused: functions-and-relations round 1: 1 Blocker, 1 Major (fix not started).
- Done at minor after round 1: sets-and-set-notation (2 Minors).
- Stopped by the user after the usage-limit reset; no new agents. Open after 3 reads: fluid-mechanics (round 3: 1 Major, 'ideal flow' undefined; split candidate). Light-and-optics round 3 still running.
- Resumed locally November 4. Fixed after round 1: functions-and-relations (range ends, turning point), radicals-and-rationalization (shortcut, two-radical equations). Light-and-optics and dynamics round 3 reads running.
- Open after 3 reads: light-and-optics (600 nm called red), dynamics (equal-acceleration rule fails for a movable pulley). Functions-and-relations round 2: 1 Blocker (range bracket rule); fix running.
- Round 2 reads: two-dimensional-motion (1 Blocker: every ideal path a parabola; 1 Major), units-and-measurements (1 Blocker: exponent called a whole number); fixes running. Functions fixed after round 2.
- Open after 3 reads: functions-and-relations (unbounded-domain rule fails for a falling line). Fixed after round 2: two-dimensional-motion, units-and-measurements; their round 3 reads and the waves-and-sound round 2 read are running.
- Done at minor: two-dimensional-motion (round 3), waves-and-sound (round 2; split candidate, 3,242 words). Systems-of-equations round 1 read running.
- Done at minor after round 3: units-and-measurements (3 Minors). Writing: coordinate-geometry.
- Round 1 reads: systems-of-equations (1 Blocker: slope tests fail for vertical lines; 2 Majors), basic-geometric-concepts (2 Majors: 'undefined terms' cut, angles on a line untaught); fixes running.
- Fixed after round 1: systems-of-equations, basic-geometric-concepts. Coordinate-geometry written (2,602 words); its round 1 read is running.
- Coordinate-geometry round 1: 2 Majors (completing the square half taught; circle-center trap worded without its limit); fix running.
- Done at minor after round 2: basic-geometric-concepts (2 Minors). Writing: parallel-perpendicular-lines.
- Systems-of-equations round 2: 2 Majors (factoring not shown; a line called a curve); fix running. Coordinate-geometry fixed after round 1; round 2 read running.
- Written: parallel-perpendicular-lines (2,060 words). Systems-of-equations fixed after round 2.
- Done at minor after round 2: coordinate-geometry (1 Minor). Parallel-perpendicular-lines round 1 read running.
- Pause requested by the user: no new agents. Running agents finish and are recorded (systems-of-equations round 3, parallel-perpendicular-lines round 1 read, quadrilaterals-and-polygons write).
- Done clean after round 3: systems-of-equations.
- Parallel-perpendicular-lines round 1: 1 Blocker (equal angles 'prove nothing' fails at 90 degrees), 2 Majors (zigzag figure marker, three-letter angle names). Fix not started (paused).
- Written: quadrilaterals-and-polygons (2,787 words). Paused here at the user's request: no agents running.
- Resumed at the user's request (5-hour usage at 72%). Running: radicals round 2 read, parallel-perpendicular-lines round 1 fix, quadrilaterals round 1 read.
- Parallel-perpendicular-lines fixed after round 1 (lead sent Trap #4 back once: the first fix kept 'prove nothing').
- Radicals round 2: 2 Majors ((a+b)^2 untaught; trinomial factoring with no prerequisite named); fix running.
- Radicals fixed after round 2. Quadrilaterals round 1: 1 Blocker (single-corner split fails for an H-shaped polygon), 1 Major (Pythagorean theorem first stated in a solution); fix running.
- Parallel-perpendicular-lines round 2: 2 Majors (base question figures in Examples 1 and 3 print the answers); fix running. Quadrilaterals fixed after round 1; round 2 read running.
- Done at minor after round 3: radicals-and-rationalization (2 Minors). Parallel lines fixed after round 2. Writing: combinatorics.
- Open after 3 reads: parallel-perpendicular-lines (1 Major: Example 4 figure label gives the answer).
- Quadrilaterals round 2: 4 Majors (question figure markers give answers or methods); fix running.
- Written: combinatorics (1,746 words), measures-of-variability (1,518). Quadrilaterals fixed after round 2; round 3 read running.
- Hit the 5-hour usage limit; cut off the quadrilaterals round-3, combinatorics round-1 and measures-of-variability round-1 reads. Resumed after the reset.
- Quadrilaterals open after 3 reads (1 Major: Example 1 figure type draws the method). Combinatorics fixed after round 1; round 2 read running. Measures-of-variability round 1: 2 Blockers, 1 Major; fix running.
- Combinatorics done at minor. Variability fixed after round 2 (1 Blocker); round 3 read next. Written: basic-trigonometric-ratios (2,359 words), fluid-pressure (2,138).
- Measures-of-variability open after 3 reads (2 Majors). Basic-trigonometric-ratios fixed after round 1; round 2 read running. Fluid-pressure round 1: 1 Blocker, 2 Majors; fix running.
- Fluid-pressure done at minor. Basic-trigonometric-ratios done at minor. Written: laws-of-sines-and-cosines (2,985 words, round 1 read running), solving-right-triangles (2,339).
- Laws-of-sines-and-cosines done at minor. Solving-right-triangles fixed after round 1; round 2 read running. Trig identities written (2,164 words); round 1 read running.
- Trig identities and solving-right-triangles done at minor. Unit circle written (3,001 words, split candidate); round 1 read running.
- Unit circle done at minor. Written: structural-stability (2,851 words), speeches (2,348); round 1 reads running.
- Structural-stability open after 3 reads (1 Blocker from the lead's own wording, 1 Major). Speeches round 3 read running.
- CET final run finished: 7 clean, 41 minor, 21 open. Final report written.
- November 4: Aedwon chose IUPAC 2013 parent-chain naming. Basic-organic-chemistry updated (rule, step 1, Trap #4, a note on the older school rule); no example name changed. A verification read is next (reads/round-4).
- Basic-organic-chemistry verification read (round 4): minor. Status open to minor. Counts: 7 clean, 42 minor, 20 open.
- November 4: split light-and-optics (adds mirrors-and-lenses), human-anatomy-physiology (adds human-body-control-movement-and-defense) and fluid-mechanics (adds fluid-flow-continuity-and-bernoulli). Questions moved with ids unchanged; totals unchanged (Python check). Outline updated. Dart import and export checks still to run on Aedwon's Mac.
- November 4: split heavenly-bodies (adds stars-and-galaxies) and waves-and-sound (adds interference-diffraction-and-doppler). Questions moved with ids unchanged; totals unchanged.
- November 4: split dynamics (adds friction-tension-and-inclines). Questions moved with ids unchanged; totals unchanged.
- November 4: split cellular-metabolism (adds cellular-respiration-and-fermentation). Questions moved with ids unchanged; totals unchanged.
- November 4: split cellular-reproduction (adds meiosis-and-genetic-variation). Questions moved with ids unchanged; totals unchanged. All eight planned splits are done.
- November 4: split reads finished. The 8 new lessons: 2 clean, 5 minor, 1 open (meiosis). The 8 shortened originals: 7 minor, 1 open (cellular metabolism). Each open lesson has a one-sentence fix recorded in final-run-rulings.md. final-run.json now lists 77 lessons: 9 clean, 50 minor, 18 open.
- November 5 (Mac, policy 8684e9fc4): Dart question import check over all of content/questions exits 0, and the content export build exits 0. All 16 split lessons are in the export with their questions. Sol pass on the 18 open lessons started (plan: docs/content/rewrite/cet/sol-pass.md); Sonnet fixes of the last-read findings are running.
- November 5, 00:39: codex-pick exit 75, all three accounts at 100% of the 5-hour limit (16% weekly), reset 01:49. Sol reads resume after the reset. The first Sol read (chemical-bonding round 4) did not run. Group 1 fixes done (6 lessons, all check exit 0).
- November 5: all 18 open lessons fixed after their last read (Sonnet; lead reviewed each diff). All pass check_cet_lesson.py. Sol round-4 reads wait for the Codex reset at 01:49.
- November 5: Aedwon chose no Codex. Round 4 is one fresh Opus read per lesson, one at a time; no round 5 (sol-pass.md).
- November 5: round-4 Opus reads done for all 18. All stay open (17 had their round-3 findings fixed; new Blockers and Majors found). Counts unchanged: 9 clean, 50 minor, 18 open. Details in final-run-report.md and final-run-rulings.md.
- November 5: rework and round-5 reads done for all 18. Closed 6 (2 clean, 4 minor); 12 stay open. Counts: 11 clean, 54 minor, 12 open. Next: exam tags (P4).
- November 5: exam tags (P4) applied to 86 question files from the audit's Level 1 tags (tags-pass.md, tag-changes.json). Lessons per exam: UPCAT 136 to 131, ACET 86 to 80, DCAT 136 to 90, USTET 145 to 110. CSE and other tags unchanged. UPCAT mock: precalculus topic removed (no UPCAT lessons left), Mathematics split evenly over five topics. Import and export pass; no required roadmap link leaves its exam. Next: questions (P5).
- CET question check (November 5): plan and tools done. Pilot of 3 files on Codex Sol: 60 of 60 match the key, about 2% of one account's 5-hour window. Full blind solve of 120 more files running, 3 at a time.
- CET question check: blind solve done. 1,928 of 1,928 match the key (5 low-confidence, all wording flags, sent to the fit read). 755 skipped as unchanged since the CSE solve. Fit reads: 101 CET-only files now; 41 CSE-shared files wait for CSE sign-off.
- CET question check, round 2 (November 5): blind re-solve of the 77 fixed files, 1,454 of 1,454 match. Sol re-read: 57 clean, 2 minor, 18 with Blocker or Major; second Sonnet fix round done on those 18 (3 lever-figure findings rejected, see rulings). Round-3 re-check of the 18 starts after the 13:43 Codex reset.
