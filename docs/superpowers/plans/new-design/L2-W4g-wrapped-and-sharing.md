# L2 W4g: Wrapped and sharing

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 12fb353b. Revised after the level 2 gate review (Oct 6).
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W1, W2, W3 (history gate), W4b (Your record row).
Traceability: 38 rows with workstream `W4g` (12 boards, 26 other items).

## 1. Purpose and scope

Rebuild Wrapped as three moments with their own slide arcs, the share screen, shared links in
About, and Pro's Wrapped history from Your record.

Out of scope: The public web page (kept as built, G-g-19); the topic-turned-strong moment (dropped, R-14).

## 2. Inputs

Boards (12): L_Share, WR_Mock, WR_Streak, WR_Topic, WR_Exam, WR_Share, WR_ShareExam, WR_ShareOffline, WR_Links, WR_LinkRemove, WR_LinksEmpty, WR_History.

Other traceability rows (26): D-245, D-246, D-247, D-251, R-14, S0-8, S0-31, S0-40, G-g-1, G-g-3, G-g-5, G-g-6, G-g-8, G-g-9, G-g-10, G-g-11, G-g-12, G-g-13, G-g-14, G-g-15, G-g-16, G-g-17, G-g-19, G-g-20, G-g-21, G-h-14.
Each row's status column in `traceability.md` is binding; "lead default" rows are listed in
section 4 where they shape behavior. Superseded sections of older specs for this family: amendment
spec B1 (rows naming this family's screens); those sections are not built.

## 3. Contracts

Owned. Routes live in this family's route file  (W1 creates it);
W1 removes retired routes and this family deletes the screens behind them:
- Keep `/wrapped/:artifactId`; new `/wrapped/:artifactId/share`, `/record/wrapped` (history),
  `/settings/about/shared-links`.
- Moment triggers and slide composition; share link reuse.
- `WrappedRecordRow` (for W4b's Your record slot) and `SharedLinksRow` (for W4f's About slot).

Consumed by reference: W1 tokens, type, icons, curves, effects, dates, shell; W2 components; W3 `coversExam`; W4b Your record slot; W4f About slot.

## 4. Behavior

- Three moments (R-14, D-245 corrected): first mock or a new best; streak of 7, 30, 100 or 365;
  the day after the exam, once. WR_History's "turned strong" row is not built; the mastery-crossing
  artifact and its trigger are removed.
- First shown on the next app open after the event (S0-40); tap or swipe through slides with a close
  button; slides with no data are skipped; no label means the label slide is skipped.
- Share per D-246: exact image preview, three switches all off (no name means no name switch; no
  exam date hides Week of prep), the link line, offline note; sharing again reuses the same link.
- Shared links per D-247 and S0-40: list with count, Remove with confirm, empty state; deleting the
  account removes shared links and images.
- History per D-251: Pro row in Your record; Free sees the row with the Pro tag and opens the Pro
  page; saved Wrappeds kept after a lapse; one list across exams with each exam named; replay uses
  saved figures.
- No ordinary-mock message; no Wrapped push (S0-31, S0-8); W4f deletes the push router. Words
  "cards" and "mastery" never appear.
- Consent-gated analytics events `wrapped_revealed` and `wrapped_shared` are kept (G-g-21).
- After Pro lapses: per Aedwon (gate F-18; proposed: saved Wrappeds are kept and history shows the
  Pro tag; renewing restores).
- The public pantas.app page is website copy, which Aedwon writes; it is kept as built and listed for
  his review (gate F-30).
- Free and Pro: history is Pro (D-251). Placeholders: none.

## 5. Motion

Boards WR_Mock, WR_Streak, WR_Exam loop every 9 s on the canvas; build each slide's entry once (MOTION rule 2).
Run `python3 docs/design/tools/timeline.py docs/design/boards/<Board>.html` for every animated board
and build from the tap, start to last change; reduce motion shows the last frame.

## 6. Acceptance

- Every board listed below matches 1:1 at rest, in each drawn state, in light mode; dark mode uses
  W1 tokens. Motion matches `docs/design/tools/timeline.py` output for each animated board.
- Widget tests for each screen state listed in section 4, including reduce motion (last frame) and
  large text without overflow; unit tests for every rule in section 4.
- Old screens, routes and widgets this family replaces are deleted; no dead route remains.
- Full required checks on the integrated family (SUBAGENTS Part 5).
- Aedwon: visual check on his phones against the boards (Android, and iPhone per S0-49).

## 7. Risks and stop conditions

- A board contradicts this plan, the amendment spec or the decision record: stop; the lead decides
  and records it before code changes (README: "ask instead of guessing").
- A figure with no measured or published source: stop (AGENTS.md), except the recorded placeholders.
- A needed shared component or contract is missing from W1, W2 or W3: stop; do not build a local copy.
- A schema change is needed: stop; W0 owns the data layer and needs an amendment first.
- A board conflicts with the README or DECISIONS.md, or a needed string has no board: stop and ask
  the lead (README "ask instead of guessing").
- Server-side link removal and deletion purge use existing functions; any change to them needs Aedwon's deploy approval.

## 8. Files and directories

`lib/features/wrapped/`, routes, tests.

## 9. Order and parallelism

After W2, W3 and W4b's Your record. Small; can run alongside W4h.
