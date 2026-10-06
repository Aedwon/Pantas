# L3 W4g: Wrapped and sharing (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W4g-wrapped-and-sharing.md`. Base: integration branch after W2, W3, W4b Task 8
(Your record slot), W4f Task 5 (About slot) and W4h's pattern task. Executor per strategy B7 as amended October 6: GPT-6.1 Sol
High through Codex builds, GPT-6 Astra audits, the Opus lead reviews and accepts the backend and
rules changes. Own worktree. Task 3b starts after W6 Task 1 integrates.

Inventory facts (Oct 6): nothing triggers a Wrapped today (rule classes exist, no call sites);
the `wrapped_revealed` and `wrapped_shared` analytics events do not exist (G-g-21 "kept" means none
are added; status corrected in the traceability table); sharing again makes a new link; the public
page defaults its Play link to `app.pantas` while the Android id is `com.aedwon.pantas`.

Before each screen task: open its boards and run `timeline.py` (WR_* loops on the canvas: build each
slide's entry once). Every task: tests first, code, task checks (`flutter test test/features/wrapped
test/tool/wrapped_boundary_test.dart`), commit. W1 theme API, W2 components.

Pro gates read W3's `proForActiveExamProvider` (Pro for the active exam), never `proIsActive` (level 3 gate review 2).

## Task 1. Triggers for three moments

Wire the existing rule classes: first mock or a new best (from W4e's submit path), a streak of 7,
30, 100 or 365 days (from the streak update), the day after the exam (on the next app open, once).
Delete the mastery-crossing artifact, its batcher case and tests (R-14). A Wrapped is created with
`UserMetricsArtifactRepository.upsert` and shown on the next app open after its event (S0-40); no
push (S0-8). Tests: each trigger fires once; no trigger for an ordinary mock (S0-31).

## Task 2. Slides

Boards WR_Mock, WR_Streak, WR_Exam; D-245 as corrected (three moments). Teal slides with the
segmented bar on top, label after its figures, tap or swipe through with a close button, last slide
Share and Done; slides with no data skipped; no label means the label slide is skipped. The reveal
bar holds Share and Done only (the old bookmark icon removed). Every figure comes from the student's
measured data.

## Task 3. Share screen and links

Boards WR_Share, WR_ShareExam, WR_ShareOffline, L_Share; D-246. Exact image preview, three switches
all off (Your name hidden when there is no name; Week of prep hidden without an exam date), the
text-only public-link note (globe icon removed), offline note, button wait "Creating your link" then
"Link copied". Sharing again reuses the Wrapped's existing link (store one `shareId` per artifact).

## Task 3b. Safe share creation (AC-G1, AC-G2)

Traceability: X-1, X-7. Aedwon approved the limits and messages (Oct 6).
1. App: upload the on-phone PNG to `wrapped/{uid}/upload/{shareId}.png`, then call
   `createWrappedShare(shareId)`; no direct Firestore write to `wrapped_shares`.
2. New `functions/src/createWrappedShare.ts` (App Check, signed in): in one transaction, refuse over
   10 new links a day (counter document `users/{uid}/limits/wrappedShares`) or 50 live links (a
   count query on `wrapped_shares` where `ownerUid == uid` and `revoked == false`, so Remove frees a
   slot; L3X-10) with `resource-exhausted` and the reason; then check the upload's PNG signature bytes and
   size under 1 MB, copy it to `wrapped/{uid}/{shareId}.png`, delete the upload, and create the
   record with a create that fails if `shareId` already exists (`ownerUid`, `shareId`,
   `createdAt`, `revoked: false`, no stored path; L3X-11).
3. `functions/src/renderWrappedPage.ts`: serve only `wrapped/{ownerUid}/{shareId}.png` derived from
   the record; nothing for a malformed record; stream with a size cap of 1 MB; `maxInstances: 10`.
4. New `functions/src/takedownShare.ts`: W6's `requireAdmin`, revokes and deletes, audited.
5. Rules: `firestore.rules` `wrapped_shares` create denied to clients (update to `revoked` only
   stays); `storage.rules` `wrapped/{uid}/upload/{name}`: create only (no overwrite), `image/png`,
   under 1 MB; `wrapped/{uid}/{shareId}.png`: no client access. Exports in `functions/src/index.ts`.
6. Share screen: on `resource-exhausted`, show "You've made a lot of links today. Try again
   tomorrow." or "You have 50 links. Remove one in Shared links to make a new one."
Tests (AC-G1, AC-G2): a record naming another user's file serves nothing; over each limit refused
with its message; overwrite after the check refused; a non-PNG refused; a client record write
denied; takedown by a non-admin denied; removing one link at 50 lets the next create succeed; a
second user's call with an existing `shareId` is refused and the record is unchanged.
Checks: `npm test` in `functions/` green; `flutter test test/features/wrapped` green.
Deploy: after this family's review, with Aedwon's approval, after W6 Task 1 (strategy B7 deploy
policy).

## Task 4. Shared links

Boards WR_Links, WR_LinkRemove, WR_LinksEmpty; D-247. `SharedLinksRow` in W4f's About slot with the
count; route `/settings/about/shared-links` in `wrapped_routes.dart` (W4g's own file); rows with date and link, Remove with confirm
(`FirebaseWrappedShareHost.revoke`), empty state, load and remove failures per W4h.

## Task 5. History

Boards YR_Wrapped, YR_WrappedFree, WR_History; D-251. `WrappedRecordRow` in W4b's Your record slot;
route `/record/wrapped`; newest first, replay with saved figures, share; Free sees the row with the
Pro tag and opens the Pro page; after a lapse the Pro tag shows (lead default) and saved Wrappeds are
kept; one list across exams with each exam named; no "turned strong" row.

## Task 6. Public page link fix

`functions/src/renderWrappedPage.ts`: default Play link to `com.aedwon.pantas` (the Android
application id), keep the `PANTAS_PLAY_URL` override. Page copy unchanged (Aedwon owns website
copy). Deploy only with Aedwon's approval.
Test first: a functions test that the page's default Play link names `com.aedwon.pantas` and
`PANTAS_PLAY_URL` overrides it. Checks: `npm test` in `functions/` green.

## Task 7. Delete and check

Keep the existing account-deletion purge of hosted Wrapped links and images (`deleteAccount.ts`,
G-g-20) with its test green; no analytics events are added (G-g-21).

Delete the old reveal page layout, share privacy sheet and `my_shared_cards_page.dart` once
replaced; update `test/tool/wrapped_boundary_test.dart` for the deleted notification router. All
required checks plus `npm test` in `functions/`; evidence `evidence/W4g.md`; GPT-6 Astra audit and the Opus lead's
review and acceptance (B7 as amended);
Aedwon's visual check against the WR_* and YR_Wrapped boards.
