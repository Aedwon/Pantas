# Study plan decision log

The design round on the study plan, the largest outstanding design job. Chronological.
Later entries append; they never edit earlier ones.

---

## 4 August 2026: the scope question, and Aedwon catching me overstating the problem

**The round opened on the question `2026-08-03-next-rounds.md` Part 1.2 says to ask first:**
does v1 ship this at all, or ship with the entry row still hidden?

### What I put to him, and what was wrong with it

I reported three blockers:

1. The feature's targeting hangs on `quizPickerCalibrationProvider` from Spec 4, and that
   identifier appears nowhere in `lib/`.
2. `exam.targetMastery` is not wired.
3. The engine is denominated in **mastery**, a construct the Progress tab deliberately refuses
   to print, and its pace curve produces an "on track" verdict that is a claim about the future.

**He did not accept it.** Verbatim:

> "are you sure these problems don't get resolved from other specs?"

**He was right, and on the largest of the three.**

- **Targeting is already solved under a different name.** `topicAccuracyProvider`, built by
  `home-05-practice-panel`, answers "which topics are weakest" from live attempts with a
  three-question floor. The collision map already lists it as shared by H4, H5 and G3. The
  study plan needs no calibration provider of its own. **I treated an unbuilt identifier named
  in a May spec as a missing subsystem, when the job it does had since been built elsewhere.**
- **Sizing inputs are fine too.** `lib/core/fsrs/` exists, so "what is due today" is measured.

### What survived the check

Verified properly the second time:

- `targetMastery` appears in Spec 6 and its own two plans. **Nowhere else** in any spec, plan
  or line of code.
- The Progress spec says "mastery" **zero times** and explicitly rejects difficulty calibration
  "for the circularity reason in Section 10".
- `TopicMastery` exists, but only inside the assessment feature. It freezes on assessment day
  and each percentage rests on at most three questions, which is why Home was rewritten to read
  attempts instead.

So the feature has a **measured half** that is nearly free, and one **unfounded piece**:
`pace_curve.dart`, `daily_sizer.dart`'s ±5% tolerance band, and the "on track" verdict.

### The options, re-priced after the correction

| Option | Cost |
|---|---|
| **Ship the measured half, cut the curve** | Loses the pacing story. Two of the thirteen files get deleted rather than wired. Cheap, because targeting comes free. |
| Ship it all, rule on the curve first | Needs an evidentiary ruling before any drawing, and `targetMastery` still has to come from somewhere real per exam. |
| Keep the row hidden | The coach pillar loses its spine and two shipped plans keep carrying reservations. Weaker once most of the feature turns out reachable. |
| Draw first, decide after | One round before any decision. |

### What he chose

**Ship the measured half, cut the curve.**

### The lesson worth keeping

**My first framing overpriced the work by treating a May spec's vocabulary as the current
state of the tree.** The check that fixed it was three greps. Run them before reporting a
blocker, not after being challenged on one.
