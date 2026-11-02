# Content Pass decision log

Chronological. Later entries append; earlier ones stay as written.

## 2 November 2026: approved scope

Aedwon approved the balanced build and the layout in the session that started this work
(local_22c7c6e5). His exact words are in that session's record; this session received them as a
brief, so nothing here is quoted as his wording. Scope and layout are in
`docs/superpowers/specs/2026-11-02-content-pass.md`.

## 2 November 2026: lead rulings during the build

- **Real pipeline, not a parser.** Options: (1) mount only the plain-data widgets
  (`ContentRenderer`, `WebQuizQuestion`), cheap, but loses each screen's frame, so it would show
  something users do not see; (2) mount the real pages over a real seed database with test
  seams, more work and depends on provider overrides; (3) fill the web content mirror through a fake
  server, closest to the web path, but it needs the server's response shapes. Chosen: 2. A worker's
  first map recommended 1. The lead overruled it because the brief forbids showing anything
  users do not see.
- **Spike result.** `LessonPage` and `QuizPage` rendered with overrides for the two databases,
  auth and the quiz controller only. The lead read the screenshots before the build went on.
- **Window.** Options: Chrome app mode (Chrome is not installed, and a browser in app mode cannot
  handle reopen), or a Swift WebKit window (small, needs a compile). Chosen: Swift.
- **Wrong state.** The approved layout names one Wrong state. Each wrong choice has its own note,
  so Wrong gained a letter switch. It costs one extra row of small buttons. It does not change
  the approved layout.
- **Mock Exam state.** A worker reported that the mock could not render: "Section
  sec_cse_pro_general_information has no available questions." The lead traced this. The blueprint uses
  `topic_cse_pro_*`, the local export uses `topic_upcat_*`, and the server maps between them with
  `topicIdFor`. So the client sampler was the wrong path and this is not a bug users hit.
  The tool now applies the same mapping.
- **Screenshots.** `WORKFLOW.md` says agents do not start app screenshot review. The brief for this
  task told the orchestrator to spot-check real screenshots, because worker notes have been
  unreliable. The checks use headless Chromium and a snapshot of the app's own window. No
  computer-control tool was used. This does not replace Aedwon's visual checking.
- **Notes file.** Not committed. It is per-machine review state, and agents read it from
  `~/Library/Application Support/Content Pass/notes.json`.

## 2 November 2026: what the real run found

- The first launch of the real app failed with "Can't load the content". The window app worked, but the
  install script named the tools differently from what the server called. A worker's stub test could
  not catch this. Fixed.
- Findings listed for Aedwon, not fixed, per the brief:
  - 246 of 1345 CSE questions have hard line breaks inside the stem, so a sentence breaks mid-line
    on screen (example: `q-code-of-conduct-ra-6713-corruption-and-its-effects-0002`).
  - `mathematics/algebra/linear-equations-inequalities/01-number-line-with-an-open.svg` shows a garbled
    "x" in its label.
  - 509 Pro and 459 Subpro questions have `approved: false`, and the export does not filter on it.
