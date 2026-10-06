# L2 W4g: Wrapped and sharing

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 12fb353b. Revised after the level 2 gate review (Oct 6).
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W1, W2, W3 (history gate), W4b (Your record row).
Traceability: 41 rows with workstream `W4g` (12 boards, 29 other items).

## 1. Purpose and scope

Rebuild Wrapped as three moments with their own slide arcs, the share screen, shared links in
About, and Pro's Wrapped history from Your record.

Out of scope: The public web page's copy and layout (kept as built, G-g-19); the topic-turned-strong moment (dropped, R-14).
In scope since October 6 (abuse review 1): the share abuse fixes in §10, which change share creation, the storage rules and the public page function.

## 2. Inputs

Boards (12): L_Share, WR_Mock, WR_Streak, WR_Topic, WR_Exam, WR_Share, WR_ShareExam, WR_ShareOffline, WR_Links, WR_LinkRemove, WR_LinksEmpty, WR_History.

Other traceability rows (29; X-1 and X-7 added Oct 6): X-1, X-7, D-245, D-246, D-247, D-251, R-14, S0-8, S0-31, S0-40, G-g-1, G-g-3, G-g-5, G-g-6, G-g-8, G-g-9, G-g-10, G-g-11, G-g-12, G-g-13, G-g-14, G-g-15, G-g-16, G-g-17, G-g-19, G-g-20, G-g-21, G-h-14, G-h-28.
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
- The old globe icon on the share note and the reveal bar's bookmark icon are removed: the share note
  is text only (WR_Share) and the reveal bar holds Share and Done (WR_Mock, WR_Streak, WR_Exam)
  (G-h-28).
- No `wrapped_revealed` or `wrapped_shared` analytics events exist; none are added (G-g-21; adding them is Aedwon's decision).
- After Pro lapses: saved Wrappeds are kept and renewing restores (Aedwon, Oct 6, gate F-18); the
  history row shows the Pro tag after a lapse (lead default).
- The public pantas.app page is website copy, which Aedwon writes; it is kept as built and listed for
  his review (gate F-30).
- Free and Pro: history is Pro (D-251). Placeholders: none.
- Wrapped history stays on the phone and is lost on reinstall until sync exists (Aedwon, Oct 6); no student-facing wording.
- Replaces every retired Ink component and `showInkSheet` call in its own screens with W2's components.

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
- The share function, storage rules and renderer changes in §10 deploy after this family's review, with Aedwon's approval, once W6 Task 1 has landed (one policy for all backend changes, W6 §4).

## 8. Files and directories

`lib/features/wrapped/`, `lib/app/routes/wrapped_routes.dart`, tests. Amended Oct 6 (level 3 gate review 1) (L3-7): one-line trigger calls in W4e's mock submit path and the streak update (after those families land), and `functions/src/renderWrappedPage.ts` (Play link default). Amended Oct 6 (abuse review 1): new `functions/src/createWrappedShare.ts` and `takedownShare.ts`, their exports in `functions/src/index.ts` (after W6 Task 1), the `wrapped_shares` rule in `firestore.rules` (after W6 and W3), `storage.rules` (the `wrapped/` match only).

## 9. Order and parallelism

After W2, W3, W4b's Your record slot and W4f's About slot (both must land first). Small; can run alongside W4h. W4h's pattern task lands before this family's state screens.

## 10. Abuse cases (added October 6, abuse review 1)

Source: `gates/abuse-review-1.md`.

| ID | Finding | Abuse case | Required behavior |
|---|---|---|---|
| AC-G1 | CX-1 | A share record points at another user's stored file, and the public page serves it | The renderer never reads a stored path. It derives the file as `wrapped/{ownerUid}/{shareId}.png` from the share record's owner and id, and serves nothing if the record is malformed. Clients can no longer write share records (AC-G2). Test: a record naming another user's file serves nothing. |
| AC-G2 | CX-7 | Anyone signed in (anonymous included) uploads large or non-image files, swaps a file after it was checked, and publishes links to them, at Pantas's cost | Share records are created only by a callable `createWrappedShare` (App Check, signed in). The app uploads to `wrapped/{uid}/upload/{shareId}.png`; the callable first checks the account's limits in a transaction with a counter document (gate L2A2-11), then checks the PNG signature bytes and size (under 1 MB), copies it to the server-only path `wrapped/{uid}/{shareId}.png` (clients cannot write there), deletes the upload, then writes the record. Limits (approved by Aedwon Oct 6): 10 new links a day, 50 live links, images under 1 MB. Storage rules allow clients only to create (never overwrite) files under `upload/`, `image/png`, under 1 MB. The renderer streams the file with a size cap and a maximum instance count (level 3 sets both). An admin-only callable `takedownShare(shareId)` (W6's `requireAdmin`) revokes a share and deletes its file (audited). Messages approved by Aedwon Oct 6: "You've made a lot of links today. Try again tomorrow." and "You have 50 links. Remove one in Shared links to make a new one.". the share screen (this family) shows them from the callable's `resource-exhausted` error. The limit counts are W4g's own (a count per window over its share records), not W6's helper. Test per limit, an overwrite attempt, and a non-PNG file. Accepted (gate L2A-23): new anonymous accounts get fresh limits. |
| AC-G3 | review section 4 | Shared images are copied before removal | Accepted risk; the share screen's public-link note already says links are public. |

