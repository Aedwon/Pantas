# Nov 3 change requests: handoff to the Max account

Written Nov 3, 2026 by the Opus lead on Aedwon's Pro account, for a lead on his Max account. Aedwon
used the running app (wide web in Brave, phone web in iPhone Safari and Brave phone emulation) and
sent 17 changes. Nothing below is implemented. His exact words are in the launch decision log
(`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`, "Requested changes from using the app
(Aedwon, Nov 3)"). Screenshots: `nov3-requests/` next to this file.

## Start here

1. Policy: `AGENTS.md`, `WORKFLOW.md`, `docs/workflow/orchestrator.md` from origin/main (there is
   no root `ORCHESTRATOR.md`). Then HANDOFF 15 and the Nov 3 update in `visual-pass-plan.md`.
2. Branches: fixes `web/visual-check-fixes-r1` (worktree `Pantas-wt-vc-fixes-r1`, edit here) and
   staging `web/staging-candidate-r1` (worktree `Pantas-wt-staging-candidate-r1`), both at
   c39cb87e, pushed. Fast-forward staging after each verified batch. Nothing deployed.
3. **Waiting on Aedwon before implementation:** the complexity level. Offered: minimal (only what
   he described, about a day), balanced (all 17, previews for motion and new-feature items, about
   3 to 4 days plus his preview approvals; recommended), hardened (balanced plus motion and
   performance regression tests, about a week). He has not chosen.
4. Aedwon's standing rules for this pass: his calls from using the app override boards (Nov 2).
   Where a board shows it and nothing conflicts, follow the board without asking. Any UI decision
   that is new or not on a board gets a visual companion preview first, built 1:1 after approval
   (`docs/workflow/visual-companion.md`). He asked for frame-by-frame investigation of transitions
   (items 1, 5, 15); the "Why" section of `visual-pass-plan.md` authorizes the lead's own captures
   for this pass.
5. Local run: Aedwon starts it with Spotlight "Pantas Local Test" (LAN). If the lead starts it from
   a Claude session in the background, the session kills it at the background time limit (30
   minutes by default, 2 hours max) and Aedwon's browser loses the server. Prefer his launcher.
   Each restart resets test data. It serves a `--profile` web build, not release.

## The 17 items

Grouped in the proposed order. Number = decision log number.

### A. Bugs (do first)

- **3. Stuck after a custom exam.** Onboarding with "My exam isn't listed" ends on `/onboarding`
  showing three gray skeleton bars forever (`02-custom-exam-skeleton.png`, dark wide web). CSE
  Professional does not do this. Local server log showed no errors at the time, so likely client
  side. Leads: skeletons in `exam_picker_screen.dart` (web skeleton at the loading branch) and
  `steps/custom_track_subjects_step.dart`; the bars in the shot do not look like the exam picker
  skeleton (no 64 px cards), so check which provider never resolves after the custom track is saved.
  Use systematic debugging; reproduce before fixing.
- **2. Skeleton look on that path** ("awkward skeleton loading when coming from a custom exam").
  Fix after 3; if the wait remains, it needs a skeleton that matches the destination screen.
- **14. "Could not load your mock." on CSE Professional** (`14-mock-error.png`). May share a cause
  with the open Nov 2 item "Mock setup error for the Steady student on Free" (results page said the
  next Free mock opens Nov 26). Check whether this is a Free-limit state shown as an error; if so,
  the message is wrong, not just the load.
- **8. Figure zoom in lessons** (`08-zoom-phone.png`, `08-zoom-wide.png`). Phone: the viewer opens
  already zoomed and cropped (one and a half of five shapes). Wide web: figure cropped both sides;
  the scrim covers about the left two-thirds, the lesson behind shifts left, a lighter band on the
  right holds the close button. Wanted: open fitted to the whole figure, then pinch, scroll and +/-
  zoom with panning, clamped; full-screen scrim; nothing behind moves.

### B. Clear fixes

- **10. Date strip balance** (`10-date-strip.png`). The three dots between "Sat 7" and the exam
  tile sit closer to the tile. Center them optically between the last day and the tile.
- **12. Last opened card with long titles** (`12-last-opened.png`). Resume on the right squeezes
  the title to four lines and the topic to two. Needs a layout that holds long titles (for example
  the button below the text, or a line limit on the title). Show Aedwon options if no board covers
  it.
- **13. Remove all scroll bars**, every platform and layout. Scrolling stays. Told Aedwon: mouse
  users lose the drag handle and position sense on long pages.
- **4. Study page on wide web** (`04-study-wide.png`). Empty Bookmarks section shows on first open
  ("at first open there's no bookmarks"); with nothing selected, the topic list is a narrow left
  column with titles truncated ("Spatial & Abstract (Non-Verbal) R...") and the rest of the page
  is empty. Needs a preview: hide or shrink empty Bookmarks, and use the width when nothing is
  selected.
- **11. Floating tab bar on phone web** (`11-iphone-tab-bar.png`, `11-brave-phone-study.png`). In
  iPhone Safari and in Brave's phone emulation, content is clipped at a hard line above the tab
  bar with a solid band behind it; in Brave the list is also clipped under the search field and the
  tab bar runs past the bottom, cutting its labels. Wanted: the tab bar floats over content that
  scrolls under it, no block, and it respects the bottom safe area. Reproducible in Brave's
  emulation; confirm on a real iPhone through Aedwon.

### C. Motion (preview first)

- **1. Legal pages open with a full-page slide**, logo included. Wanted: more elegant, maybe a fade;
  the frame and logo should stay still.
- **5. Opening a lesson is "jarring and terrible".** Capture frame by frame, then propose.
- **15. Settings on wide web:** choosing a row animates the whole right panel
  (`15-settings-wide.png`). Only the content should change, calmly.
- **17. Missing motion everywhere.** Audit every screen for missing small motion: tab bar
  selection, row, chip and card selection, slides between related views. Write the list, show a
  preview of the motion set, then build. Keep motion consistent with the onboarding continuity
  decision (frame still, content moves).

### D. New features (preview first)

- **6. Lesson reader full-width option** (`06-07-reader-wide.png`). A control that lets the student
  widen the text column. Decide where the control lives, whether the choice is remembered, and the
  maximum line length.
- **7. Lesson hierarchy on wide web.** Section labels like Core Concept read clearer on phones than
  on wide web, where they are small gray caps. Show phone and web side by side with options.
- **9. Pull up for the next lesson on wide web**, like phones. Aedwon: "thought through very deeply
  to ensure best UX". Cover mouse wheel, trackpad momentum (must not trigger by accident at the
  end), keyboard, and a visible fallback control. Preview before building.

### E. Performance

- **16. Choppy, low frame rate on phones.** The local run is a profile build over LAN; measure a
  release build on the phone first, then find the expensive frames (DevTools performance trace).
  Motion work in C must not make this worse.

## Already done this session

- Phone exam picker "Coming soon" label: 16 px from the card edge per O_Picker, under the subtitle
  at large text sizes (c39cb87e, recorded in `docs/ui-audit.md`). Not yet seen in the running app.

## Other open items carried from HANDOFF 15

Tapping a read lesson reopens it (unconfirmed); assessment glitch and inconsistent Free loading;
968 unapproved questions still exported; Firebase spend caps doc check.
