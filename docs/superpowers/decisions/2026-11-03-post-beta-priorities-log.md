# Post-beta priorities: decision log

Policy read from `origin/main` at 875d78dd.

## November 3, 2026: what to do beyond the beta

Aedwon's exact request: "i feel like I'm heavily under-utilizing my Claude Max plan. I want to do things beyond the beta. what do you suggest? check the SSOT, the roadmaps or something. i think the SSOT is also stale"

Findings given first:

- The SSOT was stale. The readiness tab stopped on October 6, its top checkpoint was September 7, and neither it nor the Home tab mentioned the PWA or PayMongo. The Home tab also omitted the Civil Service weekly and yearly plans, and the beta tab still described Google Play.
- The limit is Aedwon's approval time, not Claude capacity. Nine previews were waiting on him, and nothing was deployed for the November 9 beta (audit of November 2).
- This session's usage tool reported a Pro plan at 29% weekly use, not Max, so Max usage could not be read from it.

Options offered, in the lead's recommended order, with costs. None is approved for build:

1. Question generator with abstract reasoning: unlocks PSHS-NCE and the four academy exams and reduces repeats in thin CSE pools. Cost: a large build, and generated questions need an independent audit.
2. Smarter roadmap with knowledge map and readiness forecast: the clearest reason to buy Pro. Cost: a large build with heavy design input from Aedwon; forecasts must follow the rule against invented figures.
3. Founder app: four tabs already chosen. Cost: a medium build; saves weekly time but adds no students.
4. Next-exam brief: ranks exams by candidates, dates, overlap and price. Cost: low; runs without him.
5. Funding brief: checks grants and credits. Cost: low; the SSOT listed no deadlines.

Advised to skip for now: store releases (waiting on funds) and review center deals (parked). Timing advised: refresh the SSOT and run briefs 4 and 5 this week, and choose a build after November 15 using beta data.

Question: "Should I refresh the SSOT and write the two post-beta briefs now?" Options: "Yes, start both" or "SSOT only".

Aedwon's answer: "Yes, start both"

Result:

- SSOT refreshed: a Current status section and corrected Civil Service prices on Home, a new top checkpoint and a dated catch-up entry on the readiness tab, and a status note on the beta tab. The September 7 checkpoint's title now says SUPERSEDED; its text and all earlier entries are unchanged.
- Briefs written: `docs/future/2026-11-03-next-exam-brief.md` and `docs/future/2026-11-03-funding-brief.md`. Neither is approved scope.

Corrections made during lead review, before publishing:

- The next-exam draft called UPCAT the largest official pool. PUPCET's official count is larger (181,598 against 147,437); both figures were rechecked on the official pages.
- The next-exam draft said Student products are live, which holds only for store products. They have no web price, and Civil Service does. The draft also missed the rewrite of 98 non-CSE UPCAT sets, the required lesson links, and the deferred finales. UPCAT stayed first, as a judgment, with these costs stated.
- The next-exam draft's NAPOLCOM "about 80,000 seats" was replaced by the registrations it cites, about 89,000 including promotional takers.
- The funding draft said "take no equity" where the pages only do not mention equity. It told Aedwon to start BIR registration, which is already pending. It missed Google's exclusions (educational institutions, consultancies, agencies) and its funding-stage wording, which may affect Pantas.

## November 3, 2026: UPCAT with other CETs, and official sites

Aedwon's exact comment: "upcat, and other CETs also? also official sites you can check in the browser here. you are the max account, and in claude app rn in macos"

Result, as a recommendation only (he has not approved it):

- The next-exam brief now recommends UPCAT, DCAT, USTET and ACET together. The four use 137 sets, and the 98 not shared with CSE are the same 98 UPCAT alone needs. The current cycle is too soon, so the target is the next one, from March 2027 by past pattern.
- PUPCET and DOST-SEI stay in a second wave. PUP has no published schedule or format.
- Aedwon's comment was taken as permission to read official pages in the built-in browser for this research, an exception to the computer-control rule in `WORKFLOW.md`, which is unchanged. UP, DLSU, UST, Ateneo, PUP, PSHS, CSC, PRC, QBO, Microsoft and startup.gov.ph were read. This resolved the ACET date conflict and gave official USTET and PSHS dates.
- PCIEERD's security check was not bypassed. DOST's scholarship site showed no readable text. Those items stay marked as unverified.
- On the account: this session's usage tool still reported "Pro" at 31% weekly after his comment. Aedwon says this is the Max account; the reason for the difference is unknown.

## November 3, 2026: which audit covered the other exams

Aedwon's exact comment: "the last content audit i think included exams other than CSE, it was only after level 4 (or at the start of level 4) that I decided to narrow down to only CSE. can you check which that was? there should be an outline of subjects/topics/lessons already in the SSOT"

Finding: it was the exam content coverage audit, coverage-r1, approved October 4 for nine exams. Levels 1 to 3 covered all nine (Level 3 approved October 9). Level 4 was built for all 158 lessons on October 10 and 11, and Aedwon narrowed it to CSE on October 19, before any lesson read ran. The outline is the SSOT tab Pantas Audited Corpus r1.

Mistake corrected: the brief's "98 sets" came from older tags on question files and assumed that only sets tagged CSE were rewritten. By the accepted audit tags and the files actually changed, the four CETs use 132 lessons, 63 rewritten and 69 not. UPCAT alone is 65, so the bundle adds 4 lessons, not zero. The recommendation stays.

## November 3, 2026: how to continue Levels 4 and 5 for the other exams

Aedwon's exact question: "would you recommend I continue the rest of the exams for Level 4 and Level 5? i'd like the same process we did for CSE where, lessons were written/rewritten first and then the questions adjusted to the lessons. or would  you propose a better way?"

Options offered, with costs:

1. Repeat the CSE process: audit, triage, rewrite, then questions. Familiar, but about 132 lessons read and triaged before any fix; 233 of 866 CSE findings were judgment calls, and the rewrite got its own read anyway.
2. Combine audit and rewrite (recommended): rewrite from the standards and Level 3 gaps, a different model reads, loop until clean, then questions, an Astra audit and Aedwon's review. Risk: writers may miss what a separate audit would catch; a pilot tests it.
3. Ship the CET lessons as they are: least cost, but 69 lessons never checked against the standards.

Aedwon's question on involvement: "is it possible to keep me out of this loop only until the end?"

Answer given: yes, apart from approving the spec at the start. Tradeoff stated: a bad ruling could spread before he sees it, which costs rework at the end, not a bad release.

Aedwon's answer: "okay, write the spec for option 2. codex for 6.1 Sol will reset in ~19h so i think we could use that eventually. if not, sonnet 5.5 would be good i think? let me know what's best here"

Result: spec `docs/superpowers/specs/2026-11-03-cet-content-design.md` written, awaiting approval of Part A and a complexity level. Recommendation on models: Sonnet 5.5 writes and Codex GPT 6.1 Sol reads, with 5 of the 15 pilot lessons swapped to compare first reads. A tie goes to Sonnet. Checked at writing: Codex accounts at 100%, 95% and 96% weekly, resetting November 4 at 14:45, 18:20 and 14:51.
