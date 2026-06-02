# Science — Audit Findings

Lessons read: 51 across earth-science-astronomy (11), biology (10),
chemistry (17), physics (13). Every science lesson uses a four-section
layout: Core Concept, Examples, Speed Tricks & Shortcuts, Traps to Watch
For (no Mnemonics).

Correctness note: sampled computations verified across topics (molarity in
`solutions.md`, $F_{net}=ma$ in `dynamics.md`, $Q=mc\Delta T$ in
`thermodynamics.md`, empirical→molecular ratio for glucose in
`stoichiometry.md`). No error surfaced in the sample; full re-derivation is
an optional follow-up.

## No blockers
The single DEVICE sweep blocker is a false positive (see Dismissed). No
formula gaps: every FORMULA sweep line in physics and chemistry was traced
to a unit symbol (m, s, N, J, g, L) or element symbol (C, H) that the sweep
mistook for an untaught variable. In each case the governing equation is in
Core Concept ($F_{net}=ma$, $v=f\lambda$, $Q=mc\Delta T$, molarity
$M=\text{mol}/L$, etc.). All are dismissed below.

## Illustration gaps (20 sweep lines)
- SCI-PHY-001 [important] physics (13 lines): figure-dependent examples
  with no placeholder — free-body / projectile / vector-resolution /
  circuit setups in `dynamics.md`, `two-dimensional-motion.md`,
  `scalars-and-vectors.md`, `electricity-and-magnetism.md`,
  `fluid-mechanics.md`, and others. Physics word problems genuinely need
  the setup drawn. Add one placeholder per flagged example.
- SCI-EAS-001 [important] earth-science-astronomy (5 lines): e.g.
  eclipse geometry, moon phases, rock cycle, earth layers — diagrams a
  student cannot self-learn from prose alone. Add placeholders.
- SCI-BIO-001 [important] biology (2 lines): flagged figure-dependent
  examples without placeholders. Add placeholders.

Coverage of visual needs is otherwise good: `cell-biology.md` and similar
already carry strong placeholders.

## Coverage vs benchmarks
Strong and CET-complete; chemistry and physics exceed university-CET depth
(quantum numbers, nuclear chemistry, stoichiometry limiting reactant),
which is justified by DOST-SEI Scientific Ability. See OUTLINE-004 in
`00-overview.md`. No missing CET-tested science topic found.

## Template fit — proposal for Science
The four-section layout mostly works, with one real misfit:
- SCI-TMPL-001 [important] "Speed Tricks & Shortcuts" is a computation
  frame that misfits conceptual biology and earth science. The content
  under it there is genuinely useful exam *strategy* (trophic-level
  counting, symbiosis +/− charts), not arithmetic shortcuts. Recommend
  renaming the section to **"Exam Strategies"** (or allowing that title)
  for non-computational science lessons; keep "Speed Tricks & Shortcuts"
  where real calculation shortcuts exist (physics, quantitative
  chemistry). The app renders section titles generically, so this is a
  pure content/style-guide change.
- Consider an optional **"Key Terms"** callout for term-dense lessons
  (taxonomy, cell biology, genetics) so self-learners get a scannable
  glossary. Fold into style guide v2 as an allowed optional section.

## Dismissed sweep lines
- `DEVICE blocker … taxonomy-and-classification.md:35` — the text
  "written in italics (or underlined by hand)" explains the naming
  convention for scientific names; the names themselves are correctly
  italicized (*Homo sapiens*). No question references a missing underline.
  False positive.
- `FORMULA … solutions.md:38 [L]`, `stoichiometry.md:85 [C,H]`,
  `dynamics.md:43 [a,m,s]`, `fluid-mechanics.md:65 [N,W,g]`,
  `kinematics.md:38–93 [m,s]`, `momentum-and-impulse.md:42–80 [m,s,v,F,N]`,
  `scalars-and-vectors.md:70 [N]`, `thermodynamics.md:68 [J]`,
  `two-dimensional-motion.md:40–76 [m,s]`, `units-and-measurements.md:53–76
  [h,m,s]`, `waves-and-sound.md:42 [m,s]`, `work-energy-power.md:84 [J]` —
  all are SI unit or element symbols, not untaught variables; governing
  equations are in Core Concept. False positives.
