# Outlines for the 4 new CSE lessons (plan task P0.6)

Policy commit: `d1943470` (origin/main, `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`, plan E4-E7, style guide, runbook, source policy read in full).
Inputs: `docs/content/rewrite/briefs/new-lessons.md`, `cse-teaching-gaps.jsonl` (rows #84 to #90 of the Constitution topic, #29 to #32 of the Code of Conduct topic, #52 of the same topic), the requirement records and `lesson-exam-tags.json` on the audit branch.
This is a proposal for the lead. No lesson, outline, tag or question file was touched.

## Conventions used

- Lesson id: `lesson-<topicSlug>-<lessonSlug>`. File: `content/lessons/general-information/<topicSlug>/<lessonSlug>.md`. Questions: `content/questions/general-information/<topicSlug>/<lessonSlug>.yaml`, ids `q-<topicSlug>-<lessonSlug>-NNNN`, `meta.exams: [cse-pro, cse-sub]` like the 12 existing General Information files.
- `tools/lesson_author/outline.json` has empty `lessons` lists for all 4 General Information topics today (verified). The 12 existing lessons exist as files only. Open question 1 asks whether the new lessons get outline entries.
- Layout per the style guide: Core Concept, Examples, Traps to Watch For. Speed Tricks & Shortcuts only where a real shortcut exists. No mnemonics section (none is natural here).
- Length basis: existing lessons run 372 to 1,685 words (median 796, estimatedMinutes 8 to 15, about 77 words per minute). The word estimates below use that scale. They are planning estimates, not measurements.
- Language: Grade 5 teaching prose, exam-realistic question wording. Dates and numbers inside `$...$`.
- Source note: every URL below was fetched with the WebFetch tool. That tool returns a short summary of the page, not verbatim text. "Reached" means the page loaded and matched the expected law. Writers must still re-read the exact section text before writing a legal fact and record it in the rewrite ledger (`source-policy.md` row format).

## Exam tagging (all four)

| Lesson | cse-professional | cse-subprofessional | pupcet | Evidence |
|---|---|---|---|---|
| Three branches | yes | yes | yes | `cse-professional-L048` (Constitution, official), `cse-subprofessional-L058` (official), `cse-subprofessional-L116` (branches, officers' powers and qualifications; weak reviewer source), `pupcet-L154` (government authority; official curriculum, exam inclusion unknown) |
| Citizenship and suffrage | yes | yes | yes | same rows; `pupcet-L154` names rights, responsibilities and democratic participation |
| Amending the Constitution | yes | yes | yes, weak | same CSE rows; `pupcet-L154` names "the Constitution" only |
| Corruption and its effects | yes | yes, weak | no | `cse-professional-L057` (explain corruption, evaluate effects; DepEd curriculum, not a CSC requirement). `cse-subprofessional` has no corruption line. Its only support is the sibling Code of Conduct lessons (`cse-subprofessional-L059`, `L117`). |

Notes:
- The 4 existing Constitution lessons carry `cse-professional, cse-subprofessional, pupcet` on the same `pupcet-L154` row, so the 3 Constitution lessons follow that. Their question files list only `cse-pro, cse-sub`; keep question tags that way.
- No other exam file (UPCAT, ACET, DCAT, DOST-SEI, USTET, SM Foundation) mentions the Constitution, citizenship, suffrage, amendment or corruption. Checked by search of all nine requirement files.
- Corruption for Subprofessional is a judgment call. Tagging it matches the other 4 Code of Conduct lessons. Open question 2.

---

## 1. The three branches of government and their powers

- Proposed id: `lesson-philippine-constitution-the-three-branches-and-their-powers`
- Slug: `the-three-branches-and-their-powers`. Topic: `philippine-constitution`. Subject: `general-information`.
- Title: "The Three Branches of Government and Their Powers"
- Summary: "Learn who holds legislative, executive and judicial power under Articles VI, VII and VIII, what each branch can do, and who may hold each office."
- estimatedMinutes: 15. Estimated length 1,500 to 1,700 words if all example slots are used. This is the longest of the four. See the tripwire below.

### Gap parts covered (by key)

| Key | Facet | Section that covers it |
|---|---|---|
| `general-information-philippine-constitution#84` | Explain legislative powers | Core Concept, "Legislative power: Congress"; Examples 2 to 4 |
| `#85` | Explain executive powers | Core Concept, "Executive power: the President"; Examples 5 to 8 |
| `#86` | Explain judicial powers | Core Concept, "Judicial power: the courts"; Examples 9 to 10 |
| `#87` | Apply constitutional officer qualifications beyond CSC | Core Concept, "Who may hold each office"; Examples 11 to 13; Speed Tricks |

### Section outline

1. **Core Concept**
   - The idea of three branches: one branch makes law, one carries it out, one interprets it. Art. VI Sec. 1, Art. VII Sec. 1, Art. VIII Sec. 1 each vest the power. One short analogy allowed (a school: rule makers, principal, discipline board). Define "check and balance" in one line.
   - Legislative power: Congress of two Houses. Senate: 24 senators elected at large, 6-year term, no more than 2 consecutive terms (Art. VI Sec. 2, 4). House: not more than 250 members unless law fixes otherwise, district seats plus party-list seats (20% of the House), 3-year term, no more than 3 consecutive terms (Sec. 5, 7). Powers to teach: make laws; appropriation, revenue, tariff and similar bills start in the House (Sec. 24); Congress may not raise the President's recommended budget (Sec. 25); legislative inquiries in aid of legislation with published rules (Sec. 21); declare the existence of war by two-thirds of both Houses (Sec. 23); override a veto by two-thirds of all Members of each House (Sec. 27). Define "originate", "veto", "override", "all its Members".
   - Executive power: the President. Term 6 years, no reelection (Art. VII Sec. 4). Main powers: control of executive departments (Sec. 17); appoint department heads, ambassadors and officers from colonel or naval captain up, with Commission on Appointments consent (Sec. 16); Commander-in-Chief and limits on martial law and suspension of habeas corpus: 60 days, report within 48 hours, Congress may revoke, Supreme Court may review (Sec. 18); pardon, but not in impeachment cases, and amnesty with the concurrence of a majority of all Members of Congress (Sec. 19); treaties need two-thirds of all Senators (Sec. 21); submit the budget (Sec. 22). Succession: the Vice-President (Sec. 8). Define "pardon", "amnesty", "martial law" in one line each.
   - Judicial power: the Supreme Court and lower courts (Art. VIII Sec. 1). Judicial power includes settling actual controversies and checking grave abuse of discretion (Sec. 1, second paragraph; writers to quote exactly). Supreme Court: Chief Justice plus 14 Associate Justices, en banc or in divisions (Sec. 4). Judges hold office during good behavior until age 70 or incapacity (Sec. 11). Appointment from at least 3 nominees of the Judicial and Bar Council (Sec. 8, 9). Define "judicial review" in one line.
   - Who may hold each office (the qualification ladder): Representative 25, Senator 35, President and Vice-President 40, Supreme Court Member 40. Compare residence and citizenship requirements. Then beyond CSC: COMELEC (chair plus 6, 35, college degree, majority including Chair are lawyers of 10 years), COA (chair plus 2, 35, CPA or lawyer with 10 years), Ombudsman (40, lawyer, 10 years as judge or practitioner). Link to the CSC lesson for the CSC row.
   - Checks and balances: four short arrows (veto and override; confirmation by Commission on Appointments; impeachment; judicial review).
2. **Examples** (ordered basic to exam level, one per distinct case)
   1. Match a power to its branch (basic; three scenarios).
   2. Senate versus House terms and term limits (6 and 2, versus 3 and 3).
   3. Which House starts a bill (appropriation or revenue bill versus another bill).
   4. Veto and override (30 days to act; two-thirds of all Members of each House). Show the "all Members" arithmetic with a hypothetical House size.
   5. Which appointment needs Commission on Appointments consent.
   6. Martial law limits: 60 days, 48 hours, who may revoke, who may review.
   7. Pardon limits: not for impeachment cases; amnesty needs Congress.
   8. Treaty concurrence: two-thirds of all Senators, with an arithmetic case using 24 senators (16).
   9. Supreme Court composition and voting seats (15 Members; division sizes 3, 5 or 7).
   10. Judicial review: which branch declares a law void and on what ground.
   11. Compare three candidates' ages and apply the ladder (25, 35, 40).
   12. Qualify a person for the Supreme Court (age 40, 15 years as judge or lawyer) versus a lower-court judge (citizen and Bar member).
   13. COMELEC, COA or Ombudsman qualification case (35, 35, 40 and the 10-year practice rule; "candidate in the immediately preceding election" disqualifier).
   14. Exam level: a mixed scenario naming a check (for example, Congress overrides a veto, then a court voids the law), asking which branch used which power.
   - Cap at 12 if the word budget is tight. Merge 6 and 7, merge 9 and 10.
3. **Speed Tricks & Shortcuts** (real shortcut only): the ladder 25, 35, 40, with a one-line rule for which office sits on which rung; and "two-thirds of all" appears for veto override, treaties, war, and calling a constitutional convention (links to lesson 3). Drop if the writer cannot state it plainly.
4. **Traps to Watch For**
   - "All Members" is not "Members present" (Sec. 27, Sec. 21, Art. XVII).
   - Senator 35 versus President 40 versus Representative 25.
   - The President serves one term of 6 years; the Vice-President may serve two successive terms (Art. VII Sec. 4).
   - Pardon cannot erase an impeachment case; amnesty is not pardon.
   - Not every appointment needs Commission on Appointments consent (Sec. 16: only the listed ranks).
   - Judges do not make law; courts interpret and check, Congress makes law.
   - Terms of 7 years without reappointment belong to the Constitutional Commissions and the Ombudsman, not to the President.

### Prerequisites (existing ids; the lead owns the final links)

- `lesson-philippine-constitution-the-articles-in-outline`: locates Articles VI, VII, VIII and the order of the branches. Useful, not necessary; the new lesson restates the article numbers.
- `lesson-philippine-constitution-the-civil-service-commission`: supplies the CSC qualification row used in the officer comparison. Useful only.
- `lesson-philippine-constitution-accountability-and-impeachment`: impeachment is the legislative check; link forward rather than re-teach.
- Dependents: lesson 3 (amending) uses the voting thresholds taught here.

### Primary legal sources

| Source | Provision | URL | Status |
|---|---|---|---|
| 1987 Constitution | Art. VI Sec. 1 to 5, 7, 21 to 25, 27; Art. VII Sec. 1 to 4, 8, 16 to 19, 21, 22; Art. VIII Sec. 1, 4, 5, 7 to 9, 11; Art. IX-A Sec. 1 to 3; Art. IX-C Sec. 1; Art. IX-D Sec. 1; Art. XI Sec. 5, 8, 11 | https://lawphil.net/consti/cons1987.html | Reached. Each rule above came from the page. Exact text to be re-read per section. |
| Same | Official Gazette copy | https://www.officialgazette.gov.ph/constitutions/the-1987-constitution-of-the-republic-of-the-philippines/ | Not verified: returned HTTP 403 to the fetch tool. Do not cite until opened by hand. |

Facts that need a second look at write time: the exact wording of Art. VIII Sec. 1 (second paragraph, judicial power) and Art. VI Sec. 5 (party-list share), because the fetch summarized them. Do not state how the two Houses vote on Congress-wide thresholds beyond the text.

### Figures that would help

1. Three-column diagram: the branches, who heads each, and their main powers (SVG, full color).
2. Checks and balances: three arrows among the branches, each labeled with the power (veto, confirmation, judicial review, impeachment).
3. Qualification ladder: age bars 25, 35, 40 with offices on each rung (replaces a table; tables are banned in lessons).
4. Martial law timeline: day 0, 48-hour report, day 60 limit. Animation candidate.

### Question archetypes (target 24; file needs at least 20)

1. Branch that holds a named power (match).
2. Senate size, term, consecutive-term limit.
3. House size rule, party-list share, term, limit.
4. Senator, Representative, President, Vice-President age and residence (apply to a person).
5. Qualification check with a "natural-born" or "registered voter" twist.
6. Which House originates appropriation and revenue bills.
7. Veto: days to act, override threshold, "all Members" arithmetic.
8. Which official needs Commission on Appointments consent.
9. Martial law and habeas corpus limits (days, report, who revokes, who reviews).
10. Pardon versus amnesty limits.
11. Treaty concurrence (two-thirds of all Senators; arithmetic with 24).
12. Vote needed to declare a state of war.
13. Supreme Court composition, en banc versus division.
14. Judicial review: which body voids an unconstitutional act.
15. Retirement age and tenure of judges; how judges are appointed (JBC list of at least 3).
16. Supreme Court Member qualification case.
17. COMELEC composition and qualification case.
18. COA qualification case (CPA or lawyer with 10 years).
19. Ombudsman qualification and term case.
20. Match the check to the branch (veto, impeachment, confirmation, judicial review).
21. Succession when the President dies (Vice-President).
22. Presidential term limit versus Vice-President limit.
23. Exam level: a scenario with two powers; pick the correct branch for each.
24. Exam level: which statement about the legislative inquiry, budget or tax rule is correct (Sec. 21, 24, 25).

### Tripwire

If the first draft exceeds 1,700 words or 14 examples, split before review into `the-legislative-department` (gaps #84, part of #87) and `the-executive-and-judicial-departments` (gaps #85, #86, rest of #87). This adds one id (5 new lessons in total). Flagged to the lead as open question 3.

---

## 2. Citizenship and suffrage

- Proposed id: `lesson-philippine-constitution-citizenship-and-suffrage`
- Slug: `citizenship-and-suffrage`. Topic: `philippine-constitution`.
- Title: "Articles IV and V: Citizenship and Suffrage"
- Summary: "Learn who is a Filipino citizen, who is a natural-born citizen, and who may vote under Articles IV and V of the 1987 Constitution."
- estimatedMinutes: 12. Estimated length 900 to 1,050 words.

### Gap parts covered

| Key | Facet | Section |
|---|---|---|
| `general-information-philippine-constitution#88` | Determine citizenship | Core Concept "Who is a citizen" and "Natural-born and naturalized"; Examples 1 to 7 |
| `#89` | Determine suffrage eligibility | Core Concept "Who may vote" and "Protecting the vote"; Examples 8 to 11 |

### Section outline

1. **Core Concept**
   - Why citizenship matters (many offices and rights depend on it; one line).
   - Four groups of citizens (Art. IV Sec. 1): citizens when the Constitution was adopted; those whose father or mother is a citizen; those born before January 17, 1973 to Filipino mothers who elect Philippine citizenship at the age of majority; those naturalized under law. Define "elect", "age of majority", "naturalized".
   - Natural-born (Sec. 2): citizen from birth without any act to acquire or perfect it. Those who elect under Sec. 1(3) are deemed natural-born. Why the difference matters: President, Senator, Representative, CSC and other offices require natural-born status.
   - Marriage to an alien (Sec. 4): citizenship is kept unless renounced by act or omission under the law. Loss and reacquisition by law (Sec. 3): RA 9225 (retention and reacquisition by oath), RA 8171 (repatriation), Commonwealth Act 473 (naturalization, 10 years' residence and 21 years of age in its Sec. 2 as summarized by the fetch; check amendments before use). Dual allegiance is inimical to the national interest (Sec. 5); explain how it differs from dual citizenship under RA 9225.
   - Who may vote (Art. V Sec. 1): citizen, at least 18, resident of the Philippines for at least 1 year and of the place of voting for at least 6 months before the election, not disqualified by law. No literacy, property or other substantive requirement.
   - Protecting the vote (Sec. 2): secrecy and sanctity of the ballot, absentee voting for qualified Filipinos abroad, a procedure for disabled and illiterate voters without assistance. Statutes: RA 8189 (voter registration and disqualifications), RA 9189 as amended by RA 10590 (overseas voting).
2. **Examples**
   1. Basic: is a child with a Filipino mother and an alien father a citizen? (Sec. 1(2)).
   2. A person whose parents were Filipino citizens at the time of the child's birth abroad (parent rule, not place of birth).
   3. Born before January 17, 1973 to a Filipino mother and alien father: must elect at the age of majority; once elected, natural-born (Sec. 1(3), Sec. 2).
   4. Natural-born versus naturalized: which can run for an office that requires natural-born status.
   5. Filipino marries an alien: effect on citizenship (Sec. 4).
   6. Natural-born Filipino naturalized abroad: reacquisition by oath (RA 9225 Sec. 3) and the sworn renunciation needed before running for office (RA 9225 Sec. 5; verified summary).
   7. Dual allegiance versus dual citizenship (exam level).
   8. Voter qualification check with age, residence in the Philippines and residence in the place (basic).
   9. Residence edge cases: one person who passes (long residence in the country, 8 months in the place) and one who fails (3 months in the place). Writer sets the numbers.
   10. "Can the law require a voter to pass a reading test or own land?" (Sec. 1, last sentence).
   11. Exam level: secrecy of the ballot, absentee voting and the disabled or illiterate voter procedure (Sec. 2).
3. **Traps to Watch For**
   - Citizenship follows the parent, not the birthplace.
   - Only those born before January 17, 1973 to Filipino mothers need to elect.
   - Marrying an alien does not by itself remove citizenship.
   - Naturalized is not natural-born.
   - Dual allegiance is not the same as dual citizenship.
   - "At least 18" and residence counts are minimums; no literacy or property test.
   - Absentee voting is guaranteed by the Constitution but set by law.
4. No Speed Tricks section.

### Prerequisites

- `lesson-philippine-constitution-the-articles-in-outline`: confirms Article IV is Citizenship and Article V is Suffrage. Useful, not necessary.
- `lesson-philippine-constitution-the-civil-service-commission`: the "natural-born" requirement for CSC members is the first appearance of the term. Useful, so this lesson explains it in full.
- Dependents: lesson 3 (plebiscite voters), lesson 1 (office qualifications use natural-born).

### Primary legal sources

| Source | Provision | URL | Status |
|---|---|---|---|
| 1987 Constitution | Art. IV Sec. 1 to 5; Art. V Sec. 1 and 2 | https://lawphil.net/consti/cons1987.html | Reached; text of both articles read |
| RA 9225, Citizenship Retention and Re-acquisition Act of 2003 (approved August 29, 2003) | Sec. 3, 5 | https://lawphil.net/statutes/repacts/ra2003/ra_9225_2003.html | Reached |
| RA 8171, repatriation (lapsed into law July 3, 1995) | Who may repatriate | https://lawphil.net/statutes/repacts/ra1995/ra_8171_1995.html | Reached. (The 1998 path returns 404; use the 1995 path.) |
| Commonwealth Act 473, Revised Naturalization Law (June 17, 1939) | Sec. 2 qualifications | https://lawphil.net/statutes/comacts/ca_473_1939.html | Reached. Check later amendments (for example administrative naturalization, RA 9139) before stating years of residence. |
| RA 8189, Voter's Registration Act of 1996 (June 11, 1996) | Sec. 9 qualifications, Sec. 11 disqualifications | https://lawphil.net/statutes/repacts/ra1996/ra_8189_1996.html | Reached. The fetch reported disqualifications under Sec. 11, not Sec. 8; writer to confirm section numbers. |
| RA 9189 (February 13, 2003) | Overseas absentee voting | https://lawphil.net/statutes/repacts/ra2003/ra_9189_2003.html | Reached |
| RA 10590 (May 27, 2013) | Amends RA 9189 | https://lawphil.net/statutes/repacts/ra2013/ra_10590_2013.html | Reached |

Needs a check at write time: the moment when "at least 18" is measured (registration day or election day) in RA 8189 Sec. 9; I did not verify it. Do not state it in the lesson until checked.

### Figures that would help

1. Citizenship decision flow: parent a citizen? born before January 17, 1973 to a Filipino mother? elected? naturalized? ends at "citizen" or "natural-born citizen" (SVG).
2. Voter checklist: four boxes (citizen, 18, 1 year in the country, 6 months in the place) with a pass or fail stamp.

### Question archetypes (target 22; file needs at least 20)

1. Who are citizens under Sec. 1 (group identification).
2. Child of a Filipino father or mother, born abroad.
3. Pre-1973 child of a Filipino mother and election of citizenship.
4. Natural-born definition (Sec. 2).
5. Elected citizenship counts as natural-born.
6. Naturalized versus natural-born, which offices need which (apply).
7. Marriage to an alien (Sec. 4).
8. Loss and reacquisition by law (Sec. 3).
9. RA 9225 oath and dual citizenship of a natural-born Filipino.
10. Sworn renunciation before candidacy (RA 9225 Sec. 5).
11. Dual allegiance (Sec. 5).
12. Repatriation (RA 8171) who qualifies.
13. Voter age minimum.
14. Residence in the Philippines (1 year).
15. Residence in the place of voting (6 months).
16. Apply all three to a person (pass).
17. Apply all three to a person (fail by one test).
18. Literacy or property requirement forbidden.
19. Secrecy and sanctity of the ballot.
20. Absentee voting for Filipinos abroad.
21. Disabled and illiterate voters (voting without assistance).
22. Exam level: mixed citizenship and voting scenario with a distractor on residence.

---

## 3. Amending and revising the Constitution

- Proposed id: `lesson-philippine-constitution-amending-and-revising-the-constitution`
- Slug: `amending-and-revising-the-constitution`. Topic: `philippine-constitution`.
- Title: "Article XVII: Amending and Revising the Constitution"
- Summary: "Learn who may propose changes to the Constitution, the votes needed, and how the people ratify a change."
- estimatedMinutes: 12. Estimated length 800 to 950 words.

### Gap part covered

| Key | Facet | Section |
|---|---|---|
| `general-information-philippine-constitution#90` | Distinguish amendment and revision procedures | all sections |

### Section outline

1. **Core Concept**
   - Why a constitution has an amendment rule (one line). Define "amendment" (a change to specific provisions) and "revision" (a broad change to the basic structure, such as moving from a presidential to a parliamentary system). Teach the two tests the Supreme Court used (how many provisions change; whether the basic principles change) in *Lambino v. COMELEC*, framed in plain words. Record that this definition comes from case law, not from the text of Article XVII.
   - Three ways to propose (Art. XVII):
     - Sec. 1(1): Congress, by a vote of three-fourths of all its Members.
     - Sec. 1(2) with Sec. 3: a constitutional convention. Congress calls it by a two-thirds vote of all its Members, or by a majority vote of all its Members submits the question of calling it to the voters.
     - Sec. 2: the people, through initiative, for amendments only: a petition of at least 12% of the total registered voters, with every legislative district represented by at least 3% of its registered voters. Not within 5 years after ratification of the 1987 Constitution and not more than once every 5 years afterward. Congress provides the implementing law.
   - Ratification (Sec. 4): majority of the votes cast in a plebiscite. Timing: not earlier than 60 days nor later than 90 days after Congress or the convention approves the change; for initiative, after COMELEC certifies that the petition is sufficient. Define "plebiscite" and "votes cast".
   - Who votes in a plebiscite: link to suffrage (lesson 2).
2. **Examples**
   1. Basic: who may propose a change (match each route to its body).
   2. Amendment or revision? Change the term of one office versus change the form of government.
   3. Congress proposal threshold: three-fourths of all Members, with arithmetic on a hypothetical number of Members.
   4. Calling a convention: two-thirds to call versus majority to submit the question.
   5. Initiative signatures: 12% of registered voters with a district minimum of 3%, computed on hypothetical figures (for example 40,000 registered voters in a district, so at least 1,200 signatures there).
   6. Plebiscite window: change approved on a given date, find the earliest and latest plebiscite dates (60 to 90 days). Writer recomputes with a calendar.
   7. Ratification arithmetic: "majority of votes cast", not of registered voters.
   8. Initiative timing: the 5-year rule.
   9. Exam level: a scenario in which a proposal skips the plebiscite, or an initiative tries to revise; identify what makes it invalid.
3. **Traps to Watch For**
   - Three-fourths, two-thirds and a majority each have a separate job.
   - "All its Members" is not "Members present".
   - A people's initiative can propose only amendments, not revisions.
   - Plebiscite timing runs from different events in Sec. 1 and Sec. 2.
   - Ratification needs a majority of votes cast, not of all registered voters.
   - Congress alone or a convention alone cannot make a change valid.
4. Speed Tricks: none needed unless the writer finds a natural one. Do not invent a memory aid.

### Prerequisites

- `lesson-philippine-constitution-the-three-branches-and-their-powers` (new, lesson 1): Congress and its membership are used for the "all Members" thresholds. Necessary.
- `lesson-philippine-constitution-citizenship-and-suffrage` (new, lesson 2): defines registered voters and the plebiscite electorate. Necessary for Sec. 2 and Sec. 4 arithmetic.
- `lesson-philippine-constitution-the-articles-in-outline`: Article XVII location. Useful only.

### Primary legal sources

| Source | Provision | URL | Status |
|---|---|---|---|
| 1987 Constitution | Art. XVII Sec. 1 to 4 | https://lawphil.net/consti/cons1987.html | Reached; sections quoted from the page |
| RA 6735, Initiative and Referendum Act (approved August 4, 1989) | Sec. 5(b) | https://lawphil.net/statutes/repacts/ra1989/ra_6735_1989.html | Reached |
| *Santiago v. COMELEC*, G.R. No. 127325, March 19, 1997 | RA 6735 held inadequate for initiative on amendments | https://lawphil.net/judjuris/juri1997/mar1997/gr_127325_1997.html | Reached |
| *Lambino v. COMELEC*, G.R. No. 174153, October 25, 2006 | Amendment versus revision; initiative text requirement | https://lawphil.net/judjuris/juri2006/oct2006/gr_174153_2006.html | Reached |

Needs a check at write time: whether Congress has since passed an adequate implementing law for initiative on the Constitution. I did not check. Until checked, the lesson must teach only what Art. XVII says and leave out any statement about whether the initiative route is usable today. Also do not say whether the Houses vote together or separately on the three-fourths vote; the text is silent.

### Figures that would help

1. Flow diagram: three routes to propose, then plebiscite, then valid (SVG). Animation candidate.
2. Timeline bar: approval day, then a shaded window from day 60 to day 90.
3. Two small circles comparing the vote thresholds (three-fourths, two-thirds, majority) with who uses each.

### Question archetypes (target 20; file needs at least 20)

1. Number of ways to propose a change.
2. Congress proposal vote (three-fourths of all Members).
3. Vote to call a convention (two-thirds of all Members).
4. Majority vote to submit the convention question.
5. Initiative signature threshold (12%).
6. District minimum (3%).
7. Arithmetic: signatures needed in a district.
8. Initiative covers amendments only.
9. Spacing: first allowed time and once every 5 years.
10. Define amendment (specific change).
11. Define revision (broad, basic structure).
12. Classify a described change as amendment or revision.
13. Who ratifies (the voters, by plebiscite).
14. Vote needed to ratify (majority of votes cast).
15. Earliest plebiscite date (60 days).
16. Latest plebiscite date (90 days).
17. Timing for the initiative route (after COMELEC certification).
18. "All its Members" arithmetic.
19. Identify the invalid step in a described proposal.
20. Match each rule to its section (Sec. 1, 2, 3, 4).
21. Exam level: what must happen for a proposed change to be valid.
22. Exam level: a statute changes the Constitution, true or false and why.

---

## 4. Corruption and its effects

- Proposed id: `lesson-code-of-conduct-ra-6713-corruption-and-its-effects`
- Slug: `corruption-and-its-effects`. Topic: `code-of-conduct-ra-6713`. (The gap rows sit under this topic. The lesson widens past RA 6713, so the lead may prefer another topic home; open question 4.)
- Title: "Corruption and Its Effects"
- Summary: "Learn what corruption is, the main forms it takes in public office, and how it harms society, the economy and government."
- estimatedMinutes: 12. Estimated length 950 to 1,100 words.

### Gap parts covered

| Key | Facet | Tier | Section |
|---|---|---|---|
| `general-information-code-of-conduct-ra-6713#29` | Explain corruption | curriculum | Core Concept "What corruption is" and "Forms"; Examples 1 to 4 |
| `#30` | Evaluate corruption social effects | curriculum | "Social effects"; Example 5 |
| `#31` | Evaluate corruption economic effects | curriculum | "Economic effects"; Example 6 |
| `#32` | Evaluate corruption political effects | curriculum | "Political effects"; Example 7 |
| `general-information-code-of-conduct-ra-6713#52` | Evaluate corruption effects (from the norms lesson) | curriculum | "Weighing the effects"; Examples 8 to 11 |

All five rows are curriculum tier: they rest on the DepEd Grade 10 competencies named in `cse-professional-L057` (AP10IPP-IId-7 and IIe-8). They are preparation support, not a CSC requirement. The lesson must not claim the exam asks these items.

### Section outline

1. **Core Concept**
   - What corruption is: misuse of public office or public trust for private gain. Tie to Art. XI Sec. 1 (public office is a public trust).
   - Forms, each defined from a verified legal source only: bribery and graft and corruption (named in Art. XI Sec. 2 as impeachment grounds); the corrupt practices of RA 3019 Sec. 3 (for example gifts tied to a contract, undue injury or unwarranted benefits through manifest partiality, evident bad faith or gross inexcusable negligence, interest in a transaction the official handles, leaking confidential information); plunder (RA 7080: a public officer who gathers ill-gotten wealth through a series of acts, worth at least the amount in the law); red tape and fixers (RA 11032 sets processing times of 3, 7 and 20 working days for simple, complex and highly technical transactions). Other forms (nepotism, malversation) only after a source is verified.
   - Effects, in three groups with plain cause-and-effect chains and no statistics:
     - Social: services reach people by who they know instead of need; trust between citizens and officials falls; poor households lose the most.
     - Economic: public money is wasted or lost; projects cost more and are of lower quality; honest businesses and investors are discouraged; red tape adds cost.
     - Political: weak institutions, loss of trust in elections and government, officials answer to payers instead of voters. Vote buying and selling is an election offense (Omnibus Election Code Sec. 261(a)).
   - How the State responds: Ombudsman (Art. XI; RA 6770), Sandiganbayan (Art. XI Sec. 4), accountability through impeachment, SALN (link), RA 6713 gift rules (link).
   - Weighing effects: separate cause from effect; one act can have social, economic and political effects at once.
2. **Examples**
   1. Basic: is this act corruption? (private gain from office versus honest mistake).
   2. Name the form: bribery scenario.
   3. Match a scenario to a RA 3019 Sec. 3 clause (for example a gift tied to a contract).
   4. Plunder: series of acts and a threshold, no penalty teaching until verified (see source note).
   5. Social effect: classify a result.
   6. Economic effect: classify a result and trace one chain (inflated project cost to fewer classrooms).
   7. Political effect: classify a result.
   8. Classify a mixed list of effects into social, economic, political.
   9. Which institution handles a given complaint.
   10. Which measure reduces corruption and why (transparent process, SALN, processing-time limits).
   11. Exam level: evaluate a claim such as "corruption only affects the government's budget"; choose the best reasoning.
3. **Traps to Watch For**
   - A gift is not automatically a bribe; use the RA 6713 exceptions already taught in the duties lesson.
   - One effect can fall in more than one group; choose by the main harm named in the question.
   - Slow service is red tape; it becomes corruption when someone seeks private gain from it.
   - Corruption is not only cash; favoritism and misuse of information also count (only if those forms are sourced).
   - "Victimless" claims ignore who loses public services.
4. No Speed Tricks section.

### Prerequisites

- `lesson-code-of-conduct-ra-6713-norms-of-conduct`: the norms of public interest and simple living are the standard that corruption breaks. Necessary.
- `lesson-code-of-conduct-ra-6713-duties-and-prohibited-acts`: the gift rule and its exceptions separate a bribe from an allowed gift. Necessary.
- `lesson-philippine-constitution-accountability-and-impeachment`: bribery and graft and corruption as impeachment grounds, and public trust. Necessary for the "State responds" part.
- `lesson-code-of-conduct-ra-6713-statements-of-assets-and-divestment`: SALN as a prevention tool. Useful only.

### Primary legal sources

| Source | Provision | URL | Status |
|---|---|---|---|
| 1987 Constitution | Art. XI Sec. 1, 2, 4, 5, 8 | https://lawphil.net/consti/cons1987.html | Reached |
| RA 3019, Anti-Graft and Corrupt Practices Act (August 17, 1960) | Sec. 3(a) to (k) | https://lawphil.net/statutes/repacts/ra1960/ra_3019_1960.html | Reached; list of clauses read |
| RA 7080, Plunder (July 12, 1991) | Sec. 2 | https://lawphil.net/statutes/repacts/ra1991/ra_7080_1991.html | Reached. Its text shows ₱75,000,000 and life imprisonment. |
| RA 7659 (December 13, 1993) | Sec. 12 amends RA 7080 Sec. 2: "at least Fifty million pesos" | https://lawphil.net/statutes/repacts/ra1993/ra_7659_1993.html | Reached. The penalty after RA 7659 and RA 9346 was not checked. Do not teach the plunder penalty until checked. |
| RA 9346 (June 24, 2006) | Death penalty prohibited | https://lawphil.net/statutes/repacts/ra2006/ra_9346_2006.html | Reached |
| RA 6713 (February 20, 1989) | Sec. 2, 4, 5, 7 | https://lawphil.net/statutes/repacts/ra1989/ra_6713_1989.html | Reached |
| RA 6770, Ombudsman Act of 1989 (November 17, 1989) | Sec. 13 | https://lawphil.net/statutes/repacts/ra1989/ra_6770_1989.html | Reached |
| RA 11032, Ease of Doing Business (May 28, 2018), amending RA 9485 | Sec. 9: 3, 7 and 20 working days | https://lawphil.net/statutes/repacts/ra2018/ra_11032_2018.html | Reached |
| Omnibus Election Code, BP 881 | Sec. 261(a) vote buying and selling; Sec. 264 penalty | https://lawphil.net/statutes/bataspam/bp1985/bp_881_1985.html | Reached; Sec. 261(a) read (the fetch tool read it with an offset) |
| DepEd Araling Panlipunan Gabay Pangkurikulum (curriculum tier) | AP10IPP-IId-7, IIe-8 | https://www.deped.gov.ph/wp-content/uploads/2019/01/AP-CG.pdf | Reached, but the PDF text did not extract. I could not confirm the competency wording. It is quoted in the audit record only. |
| UN Convention against Corruption | Preamble on effects | not found | Not verified: three UNODC URLs returned HTTP 404. Do not cite UNCAC until a working URL is found. |

Never print a corruption statistic (index scores, peso losses, rank). The "never invent a figure" rule applies, and no source for one was verified.

### Figures that would help

1. Effects map: "corruption" in the center, three arms (social, economic, political), two plain examples each (SVG).
2. Cause-and-effect chain: inflated project cost, fewer classrooms, lower trust. Animation candidate.
3. Who handles what: complaint, Ombudsman, Sandiganbayan, with one line each.

### Question archetypes (target 22; file needs at least 20)

1. Definition of corruption.
2. Public office is a public trust (Art. XI Sec. 1).
3. Bribery recognition in a scenario.
4. Graft and corruption as impeachment grounds.
5. RA 3019 clause match: gifts tied to a transaction.
6. RA 3019: undue injury or unwarranted benefit.
7. RA 3019: financial interest in a transaction.
8. RA 3019: leaking confidential information.
9. Plunder: what makes an act plunder (series of acts; threshold name only).
10. Red tape: which law sets 3, 7 and 20 working days.
11. Social effect identification.
12. Economic effect identification.
13. Political effect identification.
14. Classify a list of effects.
15. Trace one chain of effects.
16. Which body investigates complaints against officials (Ombudsman).
17. Which court tries graft cases (Sandiganbayan, Art. XI Sec. 4).
18. Vote buying as an election offense.
19. Gift versus bribe using the RA 6713 exceptions.
20. Which prevention measure addresses a described weakness.
21. Exam level: evaluate a claim about who is harmed.
22. Exam level: choose the statement that best links cause to effect.

---

## Open questions for the lead

1. Outline entries: all 4 General Information topics have `lessons: []` in `outline.json`. Do the new lessons get entries, or does the file stay empty for this subject?
2. Corruption tag for CSE Subprofessional: tag it (consistent with siblings, weak evidence) or tag only Professional (the only direct line)?
3. Branches lesson size: accept one lesson with the 1,700-word tripwire, or plan 2 lessons now (5 new ids)?
4. Topic home for corruption: stay under `code-of-conduct-ra-6713`, or create it under a topic that is not tied to one law?
5. Plunder: confirm whether to teach any plunder number or penalty. The threshold is verified at ₱50 million (RA 7659 Sec. 12). The penalty is not.
6. Initiative status: confirm whether the lesson may say anything about whether the people's initiative route works today. The lesson should not until someone checks for a later implementing law.
7. UNCAC and the Official Gazette Constitution could not be fetched. Is another source acceptable, or should the lesson cite only Philippine primary law?
