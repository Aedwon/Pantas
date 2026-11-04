# CET final run: lead rulings and rejected findings

Run started November 3, 2026, on `content/cet-rewrite-r1` from 213ab320. Policy read from origin/main dc6c42fd.
Rulings bind later writers and readers in this run. Aedwon reviews them at the final review.

| Lesson | Read | Finding | Ruling | Reason |
|---|---|---|---|---|
| lesson-chemistry-acids-bases-ph | round-1 | L24 Major, title "Acids, Bases, and pH" differs from outline "Acids, Bases, and pH Scale" | Downgraded to Minor; title kept | The mismatch is in the base, the two titles name the same content, and writer rule 6 keeps a title unless the content needs a change. The outline is outside this run's scope; listed for the final review. |

## Split candidates (reported, not applied)

| Lesson | Words | Note |
|---|---|---|
| lesson-biology-cellular-reproduction | 3,052 | Writer taught every brief item, including meiotic variation; the brief's reorder candidate was not applied. |
| lesson-biology-cellular-metabolism | 3,121 | Writer taught every brief item (photosynthesis stages, respiration stages, fermentation, enzymes, biomolecules). |
| lesson-biology-human-anatomy-physiology | 3,478 | 13 worked examples plus hierarchy and body-system integration teaching. |
| lesson-chemistry-basic-organic-chemistry | 3,005 | Crossed 3,000 in the round-2 fix (naming rules and the boiling-point reason). Borderline. |
| lesson-earth-science-astronomy-heavenly-bodies | 3,171 | Every brief item taught, including the weak-class stellar-stage item. |
| lesson-chemistry-thermodynamics-and-kinetics | 3,013 | Crossed 3,000 in the round-1 fix. Borderline. |
| lesson-physics-fluid-mechanics | 3,492 | Writer added continuity and apparent weight beyond the brief; check for padding. |
| lesson-physics-light-and-optics | 3,826 | Mirror and lens ray diagrams and image cases. |
| lesson-earth-science-astronomy-water-cycle-oceanography | 3,080 | Crossed 3,000 in the round-1 fix (density limits and the far-side tide). Borderline. |
| lesson-physics-dynamics | 3,310 | Crossed 3,000 in the round-1 fix (restored figures, component splitting, term meanings). |
| lesson-physics-waves-and-sound | 3,242 | Interference, diffraction and spectrum order added from the brief. |

## Rulings during the run (continued)

- lesson-geometry-triangles, round-2 B01 on "SSA works only as HL": upheld. SSA also fixes a triangle when the given angle is right or obtuse, or lies opposite the longer given side. The fix may keep the school rule (SSA is not a congruence test; HL is the right-triangle case) but must not say HL is the only exception.
- Lead error, gas laws: the lead's writer prompt said molar volume 22.4 L "applies only at 0 °C and 1 atm". The round-1 reader rightly flagged the resulting "only" as false (the same molar volume holds at other temperature and pressure pairs with the same ratio, and IUPAC STP at 1 bar gives about 22.7 L). Later prompts state the condition without "only".
- lesson-chemistry-nuclear-chemistry: half-life calculation is not taught. The base never taught it and the brief marks the required depth unknown, so writer rule 1 keeps it out. Readers should not raise its absence.
- Lead error, periodic table: the lead's writer prompt named the ionization-energy dips at groups 13 and 16 as exceptions to test, and the writer stated them as general. The round-1 reader rightly found they fail in later periods (NIST). Later prompts give exceptions with their period limits.
- lesson-chemistry-basic-organic-chemistry, round-3 B01 on parent-chain choice (Trap #4): upheld on the fact (IUPAC 2013, P-44, puts chain length before unsaturation) but ruled Major, not Blocker. The lesson's rule is the older IUPAC convention most school texts still teach; the defect is calling the other choice wrong without naming the convention. The lesson stays open after 3 reads with this finding kept. Aedwon should choose which convention CET lessons teach.
- lesson-chemistry-thermodynamics-and-kinetics, round-1 B01 on "A pressure change shifts the position only when the moles of gas differ on the two sides, and only when the volume changes": downgraded to Minor. The sentence is the standard rule for pressure changes made by changing volume (OpenStax Chemistry 2e, 15.3). The reader's counterexamples (adding a gas at constant volume, heating at constant volume) are shifts the lesson's own add-a-substance and temperature rules cover. A fixer may add a clarifying clause but need not. The other two round-1 Blockers stand.
- Session resumed November 4 in the local worktree. The round-3 read of light-and-optics had not been saved, so a fresh round-3 read ran.
- lesson-physics-light-and-optics, round-3 B01 on "Red light has a wavelength of $600$ nm": upheld. Standard color bands put 600 nm in orange (about 590 to 620 nm); red starts near 620 nm. The worked numbers are right. The lesson stays open after 3 reads with this finding.
- lesson-physics-dynamics, round-3 B01 on "connected objects have accelerations of the same size while the rope stays tight": upheld. A movable pulley is a standard exception: the hanging block moves at half the rate of the rope's free end. The lesson stays open after 3 reads with this finding.
- lesson-algebra-functions-and-relations, round-2 B01 on "Round-bracket any end the domain leaves out": upheld. For $x^2$ on $(-2,2]$ the left-out end's output 4 is also reached at $x=2$, so the range is $[0,4]$.
- Process note: two round-1 fixers in this session skipped the origin/main standards reads. The lead checked both diffs, found one internal contradiction (radicals shortcut examples vs. the extended square list), and sent it back to the same fixer before accepting. Later prompts require the reads.
- lesson-algebra-functions-and-relations, round-3 B01 on "If the domain has no end on one side, a line's range has no end on that side": upheld. A falling line flips the side ($-2x+1$ on $x\ge0$ gives $(-\infty,1]$), and the paragraph split separated the sentence from the not-horizontal condition. The lesson stays open after 3 reads with this finding.
- lesson-physics-units-and-measurements, round-2 fix: the fixer's first wording, "an integer: a whole number that can be positive, negative, or zero", kept the round-2 error in other words. The lead sent it back; the text now reads "an integer, such as $3$, $0$ or $-6$".
- lesson-physics-waves-and-sound, round-2 B01 on "so only the pitch changes" (Example #6): the reader graded it Minor by analogy with the thermodynamics downgrade. The lead accepts Minor on its own grounds: the sentence contrasts pitch with loudness at equal intensity, the step itself states the wavelength change, and equal-loudness contours show only a small loudness difference between 440 and 880 Hz. The intended answer is the standard school answer. Readers should still grade by the checklist, not by analogy to a lead ruling.
- lesson-physics-two-dimensional-motion: done at minor after round 3 (1 Minor, paragraph length).
- lesson-algebra-systems-of-equations: done clean after round 3.
- lesson-geometry-parallel-perpendicular-lines, round 1: the reader found the writer's report wrong (the base has 7 figure markers, not 8, and the zigzag marker is unchanged from the base, so its labels no longer match the rewritten Example 7). The Major stands; the fixer must update that marker's labels to the new question and keep the answer out of the question figure.
- lesson-algebra-radicals-and-rationalization: done at minor after round 3 (2 Minors).
- lesson-geometry-parallel-perpendicular-lines, round-3 L05 Major: upheld. The Example 4 question figure's semanticsLabel, from the base, says the angles are equal while the example asks whether they are equal or supplementary. The lesson stays open after 3 reads with this finding; the fix is a one-line marker edit. Rounds 2 and 3 found answer-revealing base figure markers one at a time, so the final review should check every question marker in this lesson.
- Quadrilaterals round-3 L05 Major upheld: the Example 1 question marker keeps type polygon-triangulation, and the app renderer for that type always draws the diagonals into triangles, so the figure shows the method. Lesson set to open after 3 reads. The Trap #5 title Minor stays as recorded. Final review: change that marker type (for example to a plain hexagon) when figures are handled.
- Measures-of-variability round-1 Blockers upheld: "sample variance is larger" fails when all values are equal (both 0), and "Only squared deviations measure spread" contradicts the lesson's own range section.
- Measures-of-variability round-1 L18 Major upheld: dcat-L069 is curriculum class and names mean and variance of a random variable, and no CET lesson teaches it. The lead's earlier note that it sat outside a spread lesson was wrong. The fix adds discrete random-variable mean and variance only. Distribution functions and normal-region evaluation stay a gap for the final review, with no lesson covering them.
- Measures-of-variability round-2 B01 upheld: "A sample mean sits closer to the sample's own values than the true mean does" fails in plain distance (sample 0, 0, 3). The reader called it new this round; it was in the writer's text and round 1 missed it. The lead replaced it with the least-squares statement, which holds with equality when the two means match.
- Fluid-pressure and basic-trigonometric-ratios writers added ILLUSTRATION and FIGURE markers to examples. Writer rule 7 allows new markers; none may show an answer or method, and readers check that.
- Basic-trigonometric-ratios round-1 L27 Major upheld: the triples shortcut gave no hypotenuse condition. The lead added it with the legs 4 and 5 counterexample. The reader also noted the writer's report was wrong: base Examples 1 and 2 were not merged.
- Fluid-pressure round-1 B01 upheld: common cooking oils are about 910 to 930 kg/m³, not about 800. L05 Major upheld: the connected vessel renderer always draws equal levels (its code comment says so), so the marker on the Example 2 question shows the answer. Ruling: move that base marker, unchanged, below the Example 2 solution, where it shows the result. L19 Major upheld: Example 10 uses a pressure-change form of Bernoulli that Core Concept never gives.
- Measures-of-variability round 3: both Majors upheld (0 and 1 not stated as allowed probabilities; Sets A and B given only inside the illustration marker). Lesson set to open after 3 reads.
- Fluid-pressure round-1 L05 Major rejected on recheck (lead error in upholding it): the connected-vessel marker already sat after the Example 2 solution, before the Example 3 heading, so it shows the result, not the question. The fixer restored its base label there. Basic-trigonometric-ratios done at minor after round 2.
- Laws-of-sines-and-cosines round-1 B01 upheld: sin B = 1 gives a triangle only when A is acute (A = 150°, a = 1, b = 2 gives none). The lead added the condition to step 3.
