# CSE key fixes r6: independent verification

Policy commit used: `Aedwon/Pantas` main `23c82fdf6b4ec872d8c64335415faee0c868a155` (AGENTS.md, WORKFLOW.md, SUBAGENTS.md Parts 4 and 7b).
Target: branch `content/cse-key-fixes-r1`, commits 013989708 and 951becb2f on d97de9415. 20 files changed.
Method: stem and choices read first with the key and notes hidden; answer solved; then compared with the key.

## 1. Questions

| Question | My answer | Key | Result |
|---|---|---|---|
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0011 | GCF(315, 420) = 105 packages; 3 blankets + 4 lanterns = 450 + 1000 = 1,450 | 1,450 | PASS. "Use all" removes the 315-package reading. |
| q-algebra-word-problems-0004 | 10 L x 0.10 = 1 L | 1 liter | PASS. "By volume" fixes the basis. |
| q-grammar-and-structure-parallelism-0010 | "She enjoys hiking and swimming." | same | PASS. D is grammatical but is not a repair of the pair, and its note now says why. |
| q-grammar-and-structure-pronoun-antecedent-agreement-0007 | Their | Their | PASS. "who share one project" rules out Her and His; "Theirs" cannot precede a noun. |
| q-grammar-and-structure-punctuation-and-capitalization-0014 | no commas around "who missed the test" | same | PASS. Stem now says only those students report, so the paired commas in B change the meaning. D splits subject and verb. |
| q-language-application-error-identification-0017 | "to Paolo only" | same | PASS. B limits the sender, C the item, D the timing. |
| q-vocabulary-context-clues-0020 | ability to adapt and keep going after a setback | same | PASS. B fails because the store switched while the road was still closed. |
| q-vocabulary-root-words-prefixes-suffixes-0017 | To work jointly | same | PASS. "col-" before l is correct. |
| q-vocabulary-spelling-rules-0017 | Seize | Seize | PASS. The sentence fixes the meaning, so "Seise" no longer fits. |
| q-vocabulary-spelling-rules-0014 | Noticable (should be noticeable) | same | PASS. Managing, Courageous, Argument are correct spellings. |

Checks on all ten: one defensible answer; the key is never the longest choice; no em dash; American spelling (grep of added lines found no British forms); LaTeX strings use single quotes or block scalars (validator exit 0). Each explanation states only why the key is right.

Findings that caused each edit are fixed: recheck 2, 9, 28, 30, 31, 35, 39, 40, 41, 43 (all confirmed against the new text).

Minor observations (style, not correctness; the wording comes from the audit's own fix text):
- spelling-rules.yaml:318 ("Managing" note) has no "why it looks right" and no one-line check. Same at word-problems.yaml:92 (9 liters note), spelling-rules.yaml:390 ("Seise" note), context-clues.yaml:482 (D note). parallelism.yaml:230 and punctuation-and-capitalization.yaml:312 give the mistake and the repair but no separate check line. AGENTS.md asks for mistake, why it looks right and one check.

## 2. Lessons

| File | Result |
|---|---|
| saln-executive-military-and-other-offices.md | PASS on law facts. Colonel and above to the Office of the President, below to the Deputy Ombudsman, the rest to CSC all match Section 8(A). |
| saln-national-legislative-and-judicial-offices.md | PASS. Ombudsman, Secretaries of Senate and House, Clerk of Court (justices), Court Administrator (judges) match Section 8(A). |
| saln-filing-dates.md | PASS on law facts (see section 3). |
| saln-public-access-and-use.md | PASS on law facts. FINDING (minor, reading level): line 20 is one dense paragraph with three timing rules, not Grade 5 plain. Example 1 step 1 (line 36) now gives two timing rules to a question that asks "when", so a student cannot name one answer. |
| matching-forms-in-lists.md | PASS. |
| parallel-pairs-and-comparisons.md | PASS. The "as warm as it was yesterday" example is correct and the key point matches. |
| pronouns-for-groups-and-joined-antecedents.md | PASS. One right answer ("their"). |
| its-and-it-is-or-it-has.md | PASS. Only "its" fits. Minor: "they’re" uses a curly apostrophe, the rest of the file uses straight ones. |
| event-verb-forms.md | PASS. Order is warning, postponed repairs, collapse. |
| projections-and-forecasts.md | PASS. The quoted sentence is the forecast itself, and the solution fits. |

## 3. Law facts (primary sources)

- RA 6713 Section 8(A), filing offices: constitutional and national elective officials with the national office of the Ombudsman; Senators and Congressmen with the Secretaries of the Senate and House; Justices with the Clerk of Court of the Supreme Court; Judges with the Court Administrator; national executive officials with the Office of the President; regional and local officials and employees with the Deputy Ombudsman in their regions; armed forces officers from colonel or naval captain up with the Office of the President, those below with the Deputy Ombudsman; all other public officials and employees with the CSC. Source: https://lawphil.net/statutes/repacts/ra1989/ra_6713_1989.html (also https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/6474). CONFIRMED.
- Section 8(C): inspection "at reasonable hours"; copying "after ten (10) working days from the time they are filed"; requester pays "a reasonable fee to cover the cost of reproduction and mailing ... as well as the cost of certification"; available to the public ten years after receipt, then may be destroyed "unless needed in an ongoing investigation". Same sources. CONFIRMED. Section 8(D): no use "contrary to morals or public policy" or "for any commercial purpose other than by news and communications media". CONFIRMED.
- CSC Omnibus Rules on the SALN (2025 forms). Source: https://www.csc.gov.ph/phocadownload/userupload/irmo/policy%20resolutions/2025/saln/SALN%20Guidelines.pdf (scanned PDF, read by OCR).
  - Section 86: three original copies go "to the Human Resource Management Office (HRMO) or its equivalent office"; the first goes to the review and compliance committee "for transmittal to the repository agency". CONFIRMED.
  - Section 87 (Rule VII): "The SALN shall be filed with the HRMO or its equivalent of the department, agency, or office of the declarant". CONFIRMED.
  - Section 106 (Rule IX): "The Chief/Head of the HRMO shall transmit all original copies of the SALNs received to the concerned offices". CONFIRMED.
  - Section 109: "available for inspection at reasonable hours upon a valid and lawful request for inspection ... subject to the rules established by each repository agency". Section 110 (10 working days from filing), 111 (fee), 112 (10 years, then may be destroyed unless needed), 113 (prohibited acts). CONFIRMED.
- Ombudsman Memorandum Circular No. 3, s. 2025. Source: https://www.ombudsman.gov.ph/wp-content/uploads/2025/11/Memorandum-Circular-No-3-Series-of-2025.pdf (scanned PDF, read by OCR).
  - Sec. 3(c): "existing inventories of SALNs on file with the Office of the Ombudsman shall not be destroyed and shall be digitally stored". CONFIRMED (supports "keeps and digitizes").
  - Sec. 3(d): available "after they have been processed and recorded into the official repository, but in no case ... earlier than ten (10) working days after the final submission deadline from all government agencies". CONFIRMED.
  - Sec. 6: request on the prescribed form, valid IDs, requester pays reproduction and certification costs. Supports "lawful request under the repository's rules". CONFIRMED.
- Not confirmed: the Annex D list of repository agencies in the CSC rules was not in the fetched text, so I did not check it against the lesson lists. The lesson lists match RA 6713 Section 8(A), which I did check. The 1989 Implementing Rules and Regulations of RA 6713 were not fetched; the "Rule VII" I checked is Rule VII of the CSC Omnibus Rules.
- Scope note: the lessons say Ombudsman timing applies "for Ombudsman repositories". That matches the circular's coverage (Sec. 2).

## 4. Mock

- File content/mock/cse-pro.yaml: sections 20 + 55 + 35 + 40 = 150; `unscoredItems: 20`; `durationMinutes: 190`. Parsed with Ruby YAML (sum=150 unscored=20).
- Comprehension: 0.18181818 x 55 = 10 questions, which is two whole five-question passages. Numerical Ability 0.6/0.4 x 40 = 24 and 16 (16 is under the 20 algebra questions in the bank). General Information 5 per topic.
- CSC Examination Advisory No. 19, s. 2026: https://csc.gov.ph/downloads/examination/category/552-2026?download=3907 (and the long form linked in the audit). NOT VERIFIED DIRECTLY: csc.gov.ph returns HTTP 403 (Cloudflare challenge) to automated fetches, and I did not try to bypass it. I could not read page 7.
- Corroboration from the same CSC site: Examination Advisory No. 02, s. 2026 (08 March 2026 CSE-PPT), https://csc.gov.ph/phocadownload/userupload/erpo/advisories/2026/ExamAdvisory_2026_02_School%20Assignment%20Impt%20Reminders%20for%2008%20March%202026%20CSE-PPT%20Sgd.pdf. OCR of its table: Test Proper "150" (Professional) and "145" (Sub-Professional); EDQ "20" and "20"; Total "170" and "165"; Time Limit "3 hours, 10 minutes" and "2 hours, 40 minutes"; footnote "*Examinee Descriptive Questionnaire, pertaining to personal data of examinees". Search results for Advisory No. 10, s. 2026 report the same counts (snippet only, not opened). The 150 / 20 / 190 figures are therefore confirmed for the 2026 CSE-PPT Professional level, but the exact wording of Advisory No. 19 is not.

## 5. Gate output

```
validator: 0
emdash grep exit: 1
```

(Exit 1 from grep means no match, so no em dash in any changed file.) A grep of added lines for colour, behaviour, practise, analyse, grey, centre and organis also found nothing.

## 6. Summary

All 10 questions PASS. Lessons PASS with two minor findings in saln-public-access-and-use.md (line 20 reading level; example 1 step 1 gives two timing answers). Minor note-format observations in section 1. Mock sums to 150 and keeps whole passage groups. Advisory No. 19 wording is not verified at source.

## Lead follow-up (CSE release lead r6, Nov 25)

- After this re-solve the lead rewrote six wrong-choice notes so each names the mistake, why it looks right, and one check: spelling-rules 0014 (Managing) and 0017 (Seise), word-problems 0004 (9 liters), context-clues 0020 (Refusal), parallelism 0010 (choice D), punctuation-and-capitalization 0014 (choice B). No stem, choice text or key changed, so the independent solves above still apply.
- saln-public-access-and-use.md: the access paragraph is split into short sentences, and Example 1 step 1 now gives one answer to "when" for this statement. Facts unchanged from those checked above.
- Mock count: csc.gov.ph refused automated fetches of Advisory No. 19, s. 2026. Examination Advisory No. 02, s. 2026 (same site) gives 150 Test Proper, 20 EDQ items, 170 in all and 3 hours 10 minutes for Professional, which agrees. The Codex b audit cites Advisory No. 19, s. 2026, page 7, section D.2 for the same figures.
- Lesson checks (main's `tool/content/lesson_checks.dart`) first failed: the retired parents (statements-of-assets-and-divestment, parallelism, pronoun-antecedent-agreement, confusing-words, fact-vs-opinion, sequencing-of-events) still held the old example and trap text that the split coverage check requires to match their parts. The lead copied each fixed item into its retired parent, restored the bold "Parallelism" term in matching-forms-in-lists, and trimmed saln-public-access-and-use to 450 teaching words. Final: lesson checks 0, content gate 0 (all 10 questions approved with this file as evidence), validator 0, no em dashes.
