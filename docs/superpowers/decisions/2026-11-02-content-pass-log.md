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

## 2 November 2026: Free and Pro, device sizes, controls

Prompt: after the first build, Aedwon asked "no Free/Pro toggle?" The lead said there was none, offered
one for questions, and recommended it.

Aedwon, verbatim: "yes please add.

also some toggles could be icons instead. say, phone and wide (i think it should be desktop tablet and phone) and also light mode and dark mode

and then make it easier for me to distinguish between options, check the your performance screen of the app itself where i can choose viewing between subjects topics and lessons, maybe adopt that, or maybe you have a better option.

please also use apple design guidelines/principles. not saying you should copy the design but just the principles you know what i mean"

Options put to him, in an inline preview. The preview approximates: real build uses Phosphor icons and Geist.

- All controls use the app's segmented switch from the Performance screen: a recessed track with a
  raised selected segment. The lead found no better control. It is also the standard Apple
  pattern.
- Placement A: everything in one top bar. Cost: what each control affects is less clear.
- Placement B (recommended): exam and status on the queue, device, theme and plan on the screen.
  Cost: about 80px of queue height, and it moves two controls from the approved top bar.
- Selected state: neutral as in the app, or green. Green is easier to spot. It uses the accent color on
  chrome that was meant to stay quiet.
- Tablet: one size, portrait, is the default. The app has a separate tablet landscape layout, and
  this question is still open.

Choice: pending at the time of this entry.

The first preview lost its labels and selected state because the host page's button styling won. Aedwon
replied "what" with a screenshot. The lead redrew it without real buttons.

Aedwon, verbatim: "okay go B, green. also add animations please so that it's satisfying"

Choice: placement B, green selected state, animations added. No animation option was shown first, because he
asked for it directly. The lead ruled that animations touch only the reviewer chrome, and never block input
or change the real screens' own motion. Tablet is portrait only until he says otherwise.

Aedwon, verbatim, on the open tablet question: "wait please add tablet landscape"

Choice: four sizes: Desktop, Tablet portrait, Tablet landscape (1180x820), Phone. The landscape icon is the
tablet icon turned a quarter. It costs one more segment in the toolbar.
