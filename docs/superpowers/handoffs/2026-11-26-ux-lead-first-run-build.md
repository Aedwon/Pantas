# First-run build (E-179): hand-off to the CSE release lead r8, Nov 26

UX design lead. Policy main 4a0a3028c and later. Controlling sources: board "First Run" https://claude.ai/artifact/D3JLTrRGiN8vjnfLrbhoMN version 1795614653-2f1d (his "okay lgtm!", Nov 25 about 10:50 PM Manila); plan `docs/superpowers/plans/2026-11-25-first-run-build.md` with 19 lead rulings for undrawn states; rulings file entries E-165, E-176, E-179 and "support email row in Settings".

## Candidate

Branch `ux/first-run-r1`, head e8deced0c (pushed). Built on origin/main 6824f933b; merge main in before shipping.

What it contains:
- "Try Pantas first" after setup (route `/try`, above the web shell): intro with Start and Skip, the fractions lesson (Core Concept, Memory Aids, Example 1), questions 0001, 0003, 0002 with pick, Check and explanation, end screen "You finished the lesson" with the count, Done. Skip and Esc go Home with no confirm; reload resumes the step. Offered only to a learner who just finished setup, whose exam has the lesson (UPCAT, ACET, DLSUCET, USTET, PUPCET, CSE Professional, CSE Subprofessional) and who has no assessment result. Nothing counts: no attempt, scheduling, accuracy, streak, `question_answered` or server session; the lesson read is recorded under the normal read rule.
- Assessment: each pick saved on the device, resume from Home, Quiz tab and Plan ("Continue the assessment", "N of M answered.", Continue); the 3 first-run questions always left out; leave dialog "Your answers are saved on this device. Continue from Home." with a teal Leave.
- Settings › About: "Email support", support@pantas.study, opens the mail app (his "ok" relayed by the manager).
- New check `internal-terms` in `tool/checks/` (no lane word or decision code in on-screen strings), shown failing on "Taste finished".
- Shared code touched: `SessionEntryMotion` moved to `lib/core/ui/motion/`; `RollingDigits` extracted from `HalfRingGauge` (gauge goldens unchanged); opt-in flags (off by default) on the web bottom bar, choice row and answer reveal. Every existing golden is byte-identical.

## Checks

- Hosted CI on e8deced0c: green (run 45669505337; the Android job failed once on a dependency download, androidx.test:runner, and passed on rerun).
- Goldens: 26 new and Settings About (2) generated on the CI image (run 45667012387) and committed; no other golden changed (byte compare against the artifact).
- Side-by-side review (fresh Sonnet, headless renders of every frame at 390 and 1440, light and dark): 18 must-fix and 9 minor; all must-fix fixed; minor M1, M2, M5 and focus fixed; kept by lead ruling: "Correct answer" capital (design system README governs), Home Continue button size (same component as the live card), shared dialog width, static intro previews (a test ties them to the content). Internal-term and voice scan: no hits.
- Local, through the shared lock: first-run tests 85, `test/core/ui` 2,962, analyze clean, layering OK, run_checks all OK, design lint at baseline, format clean.

## Not verified

- No phone or browser run of the whole flow (no journey added). His visual pass on the build applies.
- Motion was checked from code and board keyframes, not watched.

## Rule 7

No fixed item added (no job, secret, service, index, collection, functions change). Per real learner: 1 to 2 `getContent` calls and 1 `recordLessonRead`. Assessment progress is device-only. `/try` reports as `other` in usage visits, so no functions deploy. Staging proof estimate: one onboarding plus one run plus one assessment start, about 3 `getContent` calls and 1 `recordLessonRead` beyond today's per-step costs.

## Ships

Web only for the opening. Standing ship-it applies (board approved). Content: the fractions lesson and questions 0001 to 0003 must be in the shipped content package for the CSE exams (they are tagged and approved in the source).
