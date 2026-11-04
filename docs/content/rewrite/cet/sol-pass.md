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
