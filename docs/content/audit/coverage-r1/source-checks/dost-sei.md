# DOST-SEI source check

Policy: main `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`; workstream: `63147ad7b6eefa596a38248a58fa07c4b3394ed4`. Input SHA-256: `0524d2e6e12adaefcba67c683205c69c6f3670fbebc504ff7b69396bd383598c` (`requirements/dost-sei.md`). Checked October 5, 2026.

Status: source retrieval and claim-by-claim verification completed. See findings and access limits below.

## Source access

| Source number | Loads | Label correct | Corrected label if wrong | Note |
|---:|---|---|---|---|
| 1 | yes, direct HTTP 200 | yes |  | DOST-SEI live 2027 page loaded. It shows the Nov. 14-15, 2026 pen-and-paper exam, Form E5, past-graduate pathways, cutoff-score process, and award effective AY 2027-2028. |
| 2 | yes, direct HTTP 200; valid 16-page PDF | yes |  | DOST-SEI 2026 primer downloaded and extracted in memory. Printed pp. 4-14 support structure, timing, scoring, domains, sample items, English samples, and NOT stem. 2027 continuity stays unknown. |
| 3 | yes, direct HTTP 200 | yes |  | DOST-SEI 2027 FAQ loaded. It says all Grade 12 learners in the Strengthened SHS pilot may apply if other criteria are met; Form E5 applies. |
| 4 | yes, direct HTTP 200; valid 257-page PDF | yes |  | The retained DepEd Math PDF matches the live HTTP file (SHA-256 `0032eae0a37eda9e9c784edd6470356a84fae01bdb4c37ff5b114c2da1d698d4`). Its cover confirms August 2016, Grades 1-10; cited pp. 8, 210, 220, 232, 240, 247-253 were checked; see locator flag below. |
| 5 | yes, direct HTTP 200; valid 203-page PDF | yes |  | The retained DepEd Science PDF matches the live HTTP file (SHA-256 `23f65e150eae6f243f62c8a72d14994cc6e2de8d3dbacf8dba51a89e92b4e710`). Its cover confirms August 2016, Grades 3-10; cited pages were checked, including standards, charging, heat, motion, biology, geology, gas laws, and constellations; see locator flag below. |
| 6 | yes, direct HTTP 200; valid 247-page PDF | yes |  | DepEd English guide cover confirms May 2016, Grades 1-10. Cited pp. 103-107, 163-164, 176-177 inspected in memory; cited skills are present. |
| 7 | yes, direct HTTP 200; valid 6-page PDF | yes |  | DepEd SHS Core General Mathematics guide cover confirms May 2016, Grade 11, first semester. Cited pp. 1-4 inspected; function, finance, and logic claims are supported. |
| 8 | yes, direct HTTP 200; valid 8-page PDF | yes |  | DepEd SHS Core Reading and Writing guide cover confirms December 2013, Grades 11/12, second semester. Cited pp. 1-2 inspected; text patterns, claims, and evidence are supported. |
| 9 | yes, direct HTTP 200; valid 7-page PDF | yes |  | DepEd SHS Core Statistics and Probability guide cover confirms December 2013, Grades 11/12. Cited pp. 1-4 and 6 inspected; competencies and p. 6 enrichment label are supported. |
| 10 | yes, direct HTTP 200 and DepEd Learning Portal page | yes |  | Live record title and curriculum metadata read. Competency list supports the cited Earth systems, rocks/minerals, resources, hazards, energy, life processes, evolution, and ecosystems; Grade 11/12. |
| 11 | yes, direct HTTP 200 and DepEd Learning Portal page | yes |  | Live record title and competency list read. It supports the cited matter structure, polarity, reaction rates/yield, astronomical models, Newtonian motion, momentum, and light. |
| 12 | yes, direct HTTP 200 and DepEd Learning Portal page | yes |  | Live record confirms Grade 11 STEM Basic Calculus, published September 20, 2018; listed topics include limits, continuity, derivatives, integration, Riemann sums, definite integrals, and area. |
| 13 | yes, direct HTTP 200 and DepEd Learning Portal page | yes |  | Live record confirms Grade 11 STEM Pre-Calculus, published September 21, 2018. Cited competencies include conics, nonlinear systems, sequences/induction, circular functions/identities, inverse trigonometry, and polar coordinates. |
| 14 | yes, direct HTTP 200 and DepEd Learning Portal page | yes |  | Live record confirms Grade 12 STEM General Physics 1, published January 10, 2022. It lists kinematics, momentum, gravity, fluids, ideal gases, and thermodynamics; cited skills appear in the competency listing. |
| 15 | yes, direct HTTP 200; valid 153-page PDF | yes |  | Web reader returned 403, but direct HTTP returned a valid PDF. Text extraction did not expose the scanned cover/body paragraph on STEM science-core substitutions. The requirement correctly leaves that rule unverified. |
| 16 | yes, direct HTTP 200; valid 14-page PDF | yes |  | DepEd Memorandum PDF p. 4 states that SY 2025-2026 pilot Grade 11 learners continue into strengthened Grade 12 in SY 2026-2027, while other Grade 12 learners remain under the current curriculum. Cover date remains unreadable. |
| 17 | yes, direct HTTP 200 | yes |  | DepEd program index has no displayed publication date. It links to all three cited strengthened guides and later issuances; later policy bodies are appropriately left unverified. |
| 18 | yes, direct HTTP 200; valid 8-page PDF | yes |  | Cover confirms Strengthened SHS General Mathematics, Grade 11. Cited pp. 2-8 support the stated finance, sequences, measurement/geometry, trigonometry, statistics, hypothesis testing, and logic preparation. No edition date appears on cover. |
| 19 | yes, direct HTTP 200; valid 8-page PDF | yes |  | Cover confirms Strengthened SHS General Science, Grade 11. Cited pp. 2-8 support machines/fluids, household chemistry, reactions, cellular energy, organ systems, ecology, Earth materials, and hazards. No edition date appears on cover. |
| 20 | yes, direct HTTP 200; valid 9-page PDF | yes |  | Cover confirms Strengthened SHS Effective Communication, Grade 11. Cited pp. 2, 5-7 support bilingual strands, messages/bias, vocabulary strategies, charts/tables, and instructions. No edition date appears on cover. |
| 21 | yes, HTTP 200 HTML only, no PDF | yes, confidence unknown |  | The candidate route returned a 2,384-byte HTML page, not a PDF; document identity remains unknown. The live 2027 organizer page does not supply a primer or continuation statement. |
| 22 | yes, direct HTTP 200 and DepEd Learning Portal page | yes |  | Live record confirms STEM Biology 1, published September 20, 2018, Grades 11/12. It lists cell cycle/mitosis, membrane transport, photosynthesis/respiration, biological molecules, and enzyme activity. |
| 23 | yes, direct HTTP 200 and DepEd Learning Portal page | yes |  | Live record confirms STEM General Chemistry 1 and 2, published September 20, 2018, Grade 11. It lists atomic theory, bonding, kinetics, equilibrium, acids/bases, and related competencies. |
| 24 | yes, direct HTTP 200; valid 7-page PDF | yes |  | DepEd cover confirms Oral Communication in Context, December 2013, Grades 11/12, first semester. Cited pp. 2-3 support speech context/style, communicative strategies, and appropriate verbal/nonverbal behavior. |

## Access limits

- Sources 4-6: the web reader returned 403, but direct HTTP with `Mozilla/5.0` returned 200 and valid PDFs. Cited pages were extracted in memory and checked.
- Source 15: the web reader returned 403, but direct HTTP returned a valid 153-page PDF. Text extraction did not reveal its scanned cover or the STEM substitution paragraph. That paragraph remains unverified.
- Retained Math and Science PDFs were valid, with 257 and 203 pages; their covers and cited pages were checked. Their SHA-256 values are recorded in rows 4-5.
- The retained `SHS-Core_General-Math-CG.pdf` file is 258,180 bytes of invalid HTML, not a PDF (SHA-256 `e367e56050bdc4681eaa6ca8bf323ee614f44cb69f3d41ffb944cc12cf174301`). I did not use it; the live official URL in source 7 returned a valid six-page PDF.
- Source 21: the candidate URL returned HTTP 200 HTML, not a PDF. This does not establish whether a newer primer exists.
- Unnumbered routes were rechecked October 5, 2026: DOST Region VII returned 403; Region V failed its TLS handshake; the Region I brochure returned 403. No requirement claim relies on their unread contents.

## Claim problems

| Exact claim | Citation | Issue | Source-supported correction, under 25 words |
|---|---|---|---|
| “Space Science: compare solar-system bodies; explain seasons, eclipses, and changing visibility of constellations.” | [5, PDF pp. 7, 103-104] | These pages support planetary comparison, seasons, and eclipses, but not changing constellation visibility. That competency appears on p. 168. | Add PDF p. 168, which covers changing constellation positions at night and across the year. |
| “Geometry: reason about polygons, congruence, triangle inequalities/similarity, parallelograms, circles, and coordinate geometry.” | [4, PDF p. 8, p. 250] | Page 8 supports the grade-level topics. Page 250 covers polynomial functions, not geometry; circle and coordinate-geometry competencies are on p. 251. | Replace p. 250 with p. 251 for circle and coordinate-geometry competencies. |
| Confidence cells: “official, cycle-limited; unknown current”; “official sample evidence, cycle-limited”; “official sample evidence; unknown current” (two rows); “official, cycle-limited; no inferred length rule”; “official, current cycle”; “official, cycle-limited scoring; unknown current formula.” | [1-2] | The profile template permits only `official`, `strong secondary`, `weak`, or `unknown`; sample, cycle, and scoring limits belong in value or notes. | Use `official` or `unknown` as the confidence value; retain sample, cycle, and scoring limits in the value or note. |

RESULT: FLAGS 3
