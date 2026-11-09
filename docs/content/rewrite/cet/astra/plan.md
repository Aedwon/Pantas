# P8: Astra audit

November 9, 2026. Policy read from origin/main 1f6907c80. Spec P8: every Blocker fix, every changed answer key, every new lesson, every large rewrite, plus a random 10% of everything else; audit only; the lead verifies each finding before it is applied.

## Scope ruling

- All 77 CET lessons are large rewrites, and 58 of them had a Blocker at some read, so the scope is every lesson. Each job reads one lesson and solves its worked examples.
- Questions: each job also checks that lesson's new or key-changed questions (248 in all, listed per lesson in `scope.json`). Sol already blind-solved every one of them, so Astra is a second, different-model check.
- Model: `gpt-6-astra`, high effort, read-only, through `codex-pick`, one job at a time (`run1.sh`, `loop.sh`). Brief: `brief.md`.

## Cost and timing

- Cost test on structural-stability: 55,616 tokens, about 2% of one account's weekly quota. All 77 lessons need about 150% of one account's week.
- On November 9 at 20:35 the three accounts had 17%, 16% and 7% weekly room, resetting November 11 at 20:49. The beta runs to November 15 and engineering also uses Codex; the spec says this pass yields to it.
- Lead ruling: stage 1 runs now, the 17 lessons that were open after round 3 (the most fixes), and stops when total room across the three accounts falls below 20%, leaving that for engineering until the reset. The other 60 lessons run after the November 11 reset, with the same stop rule.

## Results

(Appended per stage.)

- structural-stability (cost test): 1 Blocker, upheld by the lead (a tilted object's tipping test compared the weight line with the contact region instead of the pivot edge). Fixed in 50d2d5a3e and 23407d24f, independent Opus check passed.
- Stage 1 (November 9, 21:12 to 21:36): 15 lessons audited before total room fell to 18%; parallel-perpendicular-lines and measures-of-variability wait for stage 2. 24 findings (22 Blocker, 2 Major) in 13 lessons; functions-and-relations and quadrilaterals-and-polygons had none. Each job took about 2 minutes and about 1.5% of one account's week.
- Lead rulings (`stage1-rulings.md`): 13 upheld, 7 downgraded to Minor but fixed with one hedge, 4 downgraded with no change. Most upheld findings were narrow general statements the reads had missed (SSA equal-sides case with an obtuse angle, formal charge with an unpaired electron, pulley effort only at steady speed, energy rising "unless" energy leaves).
- Fixes: Sonnet (64b34ea15); independent Opus check failed 3 of 20, all corrected (c791fbbab) and passed on recheck.
- Stage 1 is a risk set, not a random sample, so it gives no error rate for the corpus. Stage 2 (60 lessons) runs after the November 11 reset.
