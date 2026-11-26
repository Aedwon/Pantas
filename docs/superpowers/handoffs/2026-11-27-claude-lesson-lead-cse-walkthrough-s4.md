# Handoff: CSE lesson walk-through rewrite, Claude lesson lead session 4 (E-198)

Date: November 27, 2026, from 1:31 AM Manila (resume after the Claude 5-hour limit stop at 9:47 PM). Lead: Claude Opus 5.5 lesson lead. Branch `content/lesson-walkthrough-cse-r1`; checks branch `tools/walkthrough-checks-r1`. Policy read: `origin/main` `6a2b2ec97` (the Nov 26 Claude-limit entry: at most 2 workers per lead, 4 Claude workers across lanes, 1 Fable audit at a time, audits to Codex first). Manager thread: `mcp:launch:aec6f0b94357a6bdd55f540c8424f611aeda70dba0b2000f468126a93604918c`. Read the session 2 handoff and the state file's session 3 section first.

## Round 6: what went wrong (manager asked for this to be logged)

Grammar round 6 Codex (`codex-grammar-r6.md`, target `81f4db5bc`) came back worse than round 5: 81 Blockers, 102 Majors, against 42 and 52. Two causes, both ours:
1. **Word-budget cuts removed required Checks.** The lane rule "a lesson's pre-tap word count must not grow" pushed sweep fixers and verifiers (one verifier's section 4 listed "cut the Example 2 Check" as a saving) to delete worked-example `**Check:**` lines. The spec (Part B) requires one on every example. 29 Blockers were missing Checks. The lead wrote both rules and did not tell workers which one wins.
2. **Free sweeping edits created new defects.** The pattern sweep let fixers rewrite any check, try or example. Some rewrites left stale references (a try asked about a word its example no longer had), taught a form only in the past tense and tested it in the present, or opened a second defensible answer.
Also: Codex started auditing question files (12 rows), and a full fresh read each round finds a new layer.

Fixes, manager-approved with four conditions (Nov 27, about 2 AM):
- **Check (in, shown failing first):** `walkthrough_example_check_line_check.dart` (`3358aaa08`) fails any worked example without a `**Check:**`, or a try whose Check is outside its answer. 39 failures at the start; all restored. It runs before every commit.
- **Method:** fixers change only what a finding names plus its restatements (P5); no free sweeps. A required Check is never cut to save words; cuts come from lines a reader would not miss. Briefs: `grammar-r6-fix-brief.md`.
- **Rounds:** delta Codex rounds (open rows plus changed lines) until clean, then ONE full Codex read. Only a full read with 0 Blockers and 0 Majors counts as PASS (manager condition 2).
- **Question files:** not edited in this lane; listed in `question-file-findings.md` and settled by the release lead on `content/cse-question-fixes-r1` `22b8ccc2f` (8 rows fixed in 11 questions, 4 no change). When the lessons move to the content root, take the root's copies of those 11 questions.
- **Codex:** shared with the GI lead, one run at a time; before each run, check `codex-pick --status` and tell the manager the planned run count.

## Other failures this session and their checks

- Worker edits glued a closing `:::` or a list item onto the previous line (Edit tool losing a newline): 3 times in Vocabulary, 10 times in Grammar, 2 bullets. The closing-fence check in `lesson_checks.dart` and the parser catch them. The lead once committed with the parser showing 3 failures (`6bbfabd65`, fixed in `750129591`); from then on the lead commits only on parser failing 0 and `lesson_checks.dart` exit 0.
- Headings and numbered lists glued under a prose line: verifiers flagged them as Majors four times. The app renders them correctly, but they cost fix rounds. New check `walkthrough_block_spacing_check.dart` (`3048ee151`), shown failing on fixtures and 6 lessons; all 6 fixed (`d2483bce3`).
- A paragraph line glued to another paragraph merges on screen and no line check can tell it from a wrapped sentence; verifiers still look for it.

## State at the end of this note

- Grammar (52): round 6 rows fixed, missing Checks restored, within budget; both delta verifiers (`grammar-r6-fil-verifier-findings.md`, `grammar-r6-en-verifier-findings.md`): 0 Blockers; their 10 Majors fixed. Round 7 Codex delta audit running at `f31be1dca` (brief `codex-grammar-r7-delta.brief.md`, workdir `scratchpad/codex/g-r7`).
- Vocabulary (29): pattern sweep, two verifiers, fixes, delta verifier (`vocab-delta-verifier-findings.md`): 0 Blockers, 5 Majors, all fixed (`9785415c0`). Codex round 3 delta brief committed (`codex-vocab-r3-delta.brief.md`), runs after the Grammar delta.
- Language Application (24): Fable round 2 PASS (`3a971099`, session 3); needs its Codex confirmation when room allows.
- Math, Reasoning: fresh-instance sweeps done (session 2); Codex post-rule audits still owed.
- Reading Comprehension (40): not started.
- Codex b at 2:29 AM: 5-hour window 55% used (resets 6:42 AM), weekly 9% (resets Dec 4). Planned runs told to the manager: Grammar delta, Vocabulary delta, then after 6:42 AM a full Grammar read and a full Vocabulary read.

## Next actions

1. Grammar delta result: fix any open row or new Blocker or Major (rows only), verify the diff, then the full Grammar read.
2. Vocabulary delta, fix, then the full read.
3. Language Application Codex confirmation; Math and Reasoning post-rule Codex audits; Reading Comprehension writing.
