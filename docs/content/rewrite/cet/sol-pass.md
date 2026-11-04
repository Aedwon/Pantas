# Sol pass on the open lessons

November 5, 2026. Policy read from origin/main 8684e9fc4. Aedwon approved "proceed just before the astra audit" (post-beta priorities log, November 4) and, on November 5, "okay you can proceed" for this step.

## Why

18 lessons are open in `final-run.json`: Opus reads found a Blocker or Major after 3 rounds. The spec allows 5 rounds per lesson (P2). The Sol audit in the pilot found Blockers that Opus missed, so the last two rounds use a different vendor.

## Steps per lesson

1. Fix: a Sonnet 5.5 subagent fixes the Blocker and Major findings of the lesson's last read (`reads/round-3/` or `reads/split/round-3/`), except findings `final-run-rulings.md` rejects or downgrades. It runs `check_cet_lesson.py` until it exits 0. The lead checks the diff.
2. Read, round 4: GPT 6.1 Sol at high effort, through `codex-pick`, read-only sandbox. It follows `reader-rules.md` and returns the read JSON as its last message. The lead validates quotes and severities, then saves it to `reads/round-4/<lesson-id>.json` (split lessons: `reads/split/round-4/`) with `"reader": "sol-high"`.
3. If round 4 has a Blocker or Major: Sonnet fixes it, then Sol reads round 5. After round 5 the lesson stops and stays open with its findings kept.
4. Status: `final-run.json` gets clean, minor or open. Rulings go in `final-run-rulings.md`.

Neither model reads its own writing: Sonnet writes and fixes, Sol reads. The lead does not edit lesson text in this pass.

## Bases for the check and the reader

- Most lessons: `7032eec5` (the script default).
- `lesson-biology-cellular-metabolism`: `f6f6b373d` (split commit).
- `lesson-biology-meiosis-and-genetic-variation`: `1fef92406` (split commit).

## Limits

At most 3 subagents or Codex jobs at a time. Change only the 18 lessons, files under `docs/content/rewrite/cet/`, and `STATUS.md`. No question files, tags, figures or app code. No AI attribution in commits.

## Change, November 5: Opus reads instead of Sol, one round

Another session used up all three Codex accounts before the round-4 reads ran. Lead offered: wait for the reset and share Codex with that session, or have fresh Opus readers do round 4 now (the final run's loop), with Astra as the later cross-vendor check. Lead recommended one round only.

Aedwon: "no codex use. possible? and why is codex essential here"; "please don't parallelize so much because you have limited usage"; "why two more rounds this time?"; "okay proceed".

Result: one fresh Opus 5.5 read per lesson (round 4), run one at a time. No round 5: a lesson with a Blocker or Major after round 4 stays open with its findings for the final review and the Astra audit. Sonnet wrote all fixes in this pass, so Opus does not read its own writing here. Three of the lessons (measures-of-variability, structural-stability, speeches) carry earlier lead (Opus) edits from the final run, as noted in the final report.

## Change, November 5: one careful rework, then round 5

Round 4 left all 18 open, with new findings in each and six new Blockers added by fixes. Lead recommended one careful rework per lesson, then one read. Aedwon: "proceed as you recommend."

Per lesson, one at a time:
1. A Sonnet writer fixes the round-4 Blockers and Majors (except those the rulings downgrade or reject), then sweeps the whole lesson: every general statement ("only", "always", "never", "every", "all", "no", "cannot", "must", and each stated rule) is tested at boundary values and a known exception and checked against a source; every term an example or rule uses is defined or names its prerequisite lesson; every question figure marker before a solution is checked so it shows only the givens. The writer lists each statement it changed.
2. A fresh Opus reader reads it (round 5). After round 5 the lesson is final: clean, minor, or open.

Figure markers: the writer may edit label text, move a marker unchanged to after the solution, or replace a FIGURE marker whose renderer type draws the answer or a wrong shape with an ILLUSTRATION marker that names only the givens (precedent: quadrilaterals, round 3).
