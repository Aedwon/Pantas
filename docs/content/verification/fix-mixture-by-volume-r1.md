# Two mixture questions now say their percentages are by volume (CSE release lead r10)

Nov 28, 2026. Branch `content/cse-mixture-fixes-r1`, on the content root live on prod
(`content/cse-math-pilot-staging-r1` b4105bbff). Source: the Math pilot's Codex read 1 (agent finding),
held for after the opening (launch log, Nov 27 about 7:40 PM: "two mixture questions do not say the
percentages are by volume"); manager queue item 3: "the percentages must say by volume. Use the
question process (blind solve, approve.dart), staging first, then prod as a content upload."

## Changes (stems only; keys, choices, notes and explanations unchanged)

| Question | Added before "Assume the volumes add ..." |
|---|---|
| q-algebra-word-problems-0010 (salt, key 10 liters) | "All percentages are by volume." |
| q-algebra-word-problems-0016 (sugar, key 18 liters) | "All percentages are by volume." |

Why: both explanations treat the dissolved amount as liters (0016: "The sugar volume stays 3 liters";
0010's note "This reports the liters of salt needed"), which holds only if the percentages are by
volume. Without it, a percent by mass is the usual reading for salt and sugar solutions.

## Independent blind solve (key, explanation and notes hidden; choices reordered)

One Sonnet 5.5 solver, given only the two new stems and shuffled choices.

| Question | Blind solve | Key | Second defensible answer | Verdict |
|---|---|---|---|---|
| word-problems-0010 | 10 liters | 10 liters | none | AGREE |
| word-problems-0016 | 18 liters | 18 liters | none (30 liters is the final volume) | AGREE |
