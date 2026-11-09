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
