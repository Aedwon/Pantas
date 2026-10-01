# Tendency confidence: show measured figures early, claim a finding only when it is clear

**Date:** 1 October 2026
**Status:** Approach approved by Aedwon, 1 October 2026 ("okay let's go with this but for codex
work just have it prepare the backend things. i'll brainstorm the presentation of this with
Claude Design"). Backend only; presentation is the UI round's.
**Decision log:** `docs/superpowers/decisions/2026-09-30-adaptive-roadmap-log.md`, 1 October.
**Reference:** `docs/superpowers/specs/2026-10-01-you-screens-reference.md`.

## Part 1: for Aedwon

- **The 14-session floor no longer gates the tendencies.** It was a judgment from the June
  metrics spec with no source, and the wrong unit (sessions, not answers).
- **Figures appear as soon as both sides of a comparison have data.** Under pressure and Stamina
  still need a finished mock, because before that there is nothing to compare.
- **The sentence appears only when the gap is clear**: a standard statistical test says the
  difference is unlikely to be chance (95 percent confidence).
- **Each tendency carries one of three states** for the design to show: early (figures exist,
  too few answers to judge), forming (enough to judge, no clear difference yet), clear (the
  sentence shows). Every step comes from the data; no count to unlock is shown and no finish
  line is invented.
- **A tiny gap may stay "forming" indefinitely.** Calling it "no real difference" would need a
  chosen smallest meaningful gap, which is a judgment the app does not make.
- **Free and Pro:** the engine provides the state to both; the design decides whether Free sees
  it (figures stay Pro, Gate 1).
- **Unchanged:** the profile label and "When you work" keep the 14-session floor.

## Part 2: agent section

For each tendency the provider returns, alongside the existing fields:
`confidence` (`TendencyConfidence.early | forming | clear`), figures whenever both sides have at
least one observation, and `sentence` only when `clear`. Remove the prep-window 14-session gate
for these computations only (signals may take a flag or a window whose floor is 1; keep the
floor for archetypes and "When you work").

Tests and rules, by tendency (two-sided, alpha 0.05):

| Tendency | Data | Test | "early" until (textbook validity condition) |
|---|---|---|---|
| Under pressure | correct and total, practice vs mock | two-proportion z-test | each side has at least 5 correct and 5 wrong |
| Stamina | correct and total, first vs second half (all submitted mocks) | two-proportion z-test | same |
| How you answer | response times, correct vs wrong (timed only) | Welch's t-test on log response time (times are right-skewed) | each side has at least 30 answers |
| How you study | read-first vs answered-first counts | exact two-sided binomial test against one half | at least 10 lessons counted |
| How long you remember | lapses over reviews | 95 percent Wilson interval on the lapse rate | at least 10 reviews; "clear" when the interval's half-width is at most 5 points (precision of an estimate, not a comparison; recorded as a lead judgment) |

`forming` = valid but not significant; `clear` = significant (or, for the estimate, precise).
The validity conditions are standard textbook rules for when these tests' approximations hold,
not tuned values. Put them in one constants file with a comment citing that purpose.

Unlock lines drop the session floor again: they name only what is missing on each side
(for example "Finish one full length mock"). Sentences are unchanged in wording.

Verification: unit tests per test with hand-computed fixtures (state the expected statistic in
the test), each state boundary, figures shown before clear, sentence only when clear, Free and
Pro providers both carry the state, archetypes still gated at 14 sessions, and no new
user-facing number other than the measured figures.
