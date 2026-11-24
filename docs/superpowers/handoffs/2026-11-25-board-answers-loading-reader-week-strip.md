# Board answers: loading percent, reader lesson dashes, week strip frames (E-152), Nov 25

UX design lead. Policy read from main at 58e934669. Earlier note: `2026-11-25-loading-reader-line-week-strip-boards.md`.

## His words (Nov 25, about 1:35 AM Manila)

"i think B makes sense because the industry uses it and it's more familiar and what users expect. is it possible to add a % number?
i don't understand the reader line, i just wanted you to maybe remove the lesson indicator on top because it gets so long when there's a lot of lessons in a certain topic, and especially so after the instruction to make the lessons bite-sized. for the thing that indicates how far along you are in the lesson itself, no changes
also what is this in the week strip?"

Rulings and findings: `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, "Nov 25, UX design lead: his answers to the loading, reader and week strip board".

## 1. Loading: B picked, a real percent is possible (board only, nothing built)

- Prod sends app files brotli-compressed through Cloudflare with no Content-Length, so the browser cannot see the total. The app's service worker already passes every app file on return visits, so it can count decoded bytes against decoded sizes the build writes. Both are measured.
- Limit: the splash shows only on return visits, and the number only while files download (first open after an update, or after the browser clears its files). After 100% the app still starts up, so the number hides and the spinner stays.
- Board: page 1, rows "B with %" (phone and wide, light and dark) and "B with %, Reduce Motion". Waiting on his look. Build after his pick: build-time size list, counting in `web/pantas_sw.js`, number under the spinner in the splash.

## 2. Reader: lesson dashes removed on wide web (built, handed off)

- Branch `ux/reader-lesson-pills-r1`, head 7c3424f5a, pushed, not merged. Handed to the CSE release lead (integrator) Nov 25 to ship.
- Wide reader top bar: the per-lesson dash row is gone; title, "N of M", chevron and lesson list stay. Phone had no such row; nothing changed there. In-lesson progress unchanged.
- New test fails on the old code and passes now; 7 goldens at 1440 rendered on the CI image (run 45453848721) and committed; focused tests 937 passed; analyze clean; run_checks exit 0. Full CI runs on the PR.
- Capture sheets for his confirmation: `~/Documents/Projects/Pantas-handoffs/2026-11-25-reader-indicator/reader_indicator_before.png` and `_after.png`.
- Ship gate: no board draws it; it is the removal he asked for. The manager decides whether prod waits for his look at the sheet.
- Board page 2 renamed "2 Reader line (retired)"; options A, B and C retired.

## 3. Week strip frames: fixed (board only)

- Cause: the frames imported the strip part without loading its stylesheets in their own head; the canvas loads stylesheets only from the shown frame. His boards carry the links in each frame.
- Fix: the part is now a copy of his `HP_WeekFrame` with only the chip name as input; every frame carries his three stylesheet links; the stylesheets were copied from the Pantas Redesign canvas (byte-identical to the old copies); the invented greeting line is gone. Not rendered by the lead (canvas rule); he does the visual check.

## Board

https://claude.ai/artifact/MQxxjEmiWjbzwUqaF8h9Ec, version 6. Source files in the lead's scratchpad are disposable; the canvas holds them.

## Open

- His look at "B with %" (section 1) and at the reader capture sheet (section 2).
- CSE release lead: integrate and ship the reader branch.
