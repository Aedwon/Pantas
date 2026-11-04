# CET lesson splits: plan

Date: November 4, 2026. Decision: Aedwon, "split the splittable" (decision log on main, `2026-11-03-post-beta-priorities-log.md`, November 4 entries). The five lessons just over 3,000 words (water cycle, thermodynamics and kinetics, unit circle, laws of sines and cosines, basic organic chemistry) are left as they are: the line is approximate and trimming risks cutting needed teaching.

Precedent: the CSE splits (`fdcbdba3`, `567f990c`). Text and questions move word for word, question ids stay unchanged, and a question is moved, never copied (copies caused 49 duplicate ids in the CSE split and the server rejected the catalog).

## The eight splits

The original file keeps its path and `_id`; its title and summary change to fit. The new file sits in the same folder.

| Original | Keeps | New lesson (slug) | Moves to the new lesson |
|---|---|---|---|
| physics/light-and-optics | reflection, refraction, critical angle and total internal reflection, electromagnetic spectrum | mirrors-and-lenses | mirrors, lenses, sign convention and equations, image versus object position, optical instruments |
| biology/human-anatomy-physiology | levels of organization, digestive, respiratory, circulatory, urinary and excretion | human-body-control-movement-and-defense | nervous, endocrine, skeletal, muscular, reproductive, immune, how systems work together |
| physics/fluid-mechanics | density, pressure, pressure and depth, Pascal, Archimedes and buoyancy | fluid-flow-continuity-and-bernoulli | continuity, Bernoulli |
| physics/dynamics | Newton's laws, common forces, mass and weight, normal force, free-body diagrams | friction-tension-and-inclines | friction, tension, inclines, pulling at an angle |
| earth-science-astronomy/heavenly-bodies | solar system: planets, moons, asteroids, comets, meteoroids | stars-and-galaxies | stars, comparing stars, how stars change, galaxies |
| physics/waves-and-sound | wave properties, mechanical versus electromagnetic, transverse versus longitudinal, sound | interference-diffraction-and-doppler | interference, diffraction, Doppler effect |
| biology/cellular-metabolism | words used, enzymes, biomolecules, photosynthesis | cellular-respiration-and-fermentation | cellular respiration, respiration without oxygen, how the two processes connect |
| biology/cellular-reproduction | chromosomes and chromatids, cell cycle, mitosis | meiosis-and-genetic-variation | meiosis, how meiosis makes variation, why it reduces the number, mitosis and meiosis compared |

## Steps per lesson

1. A Sonnet writer moves the sections, and the examples, shortcuts and traps that belong to them, word for word. Each part gets a short Core Concept opening and names the other part as its prerequisite where it relies on it. Examples and traps renumber from #1 in each part. Frontmatter: the new file uses the original's keys in the same order, `_id: "lesson-<topic>-<new slug>"`, its own title and summary, and `estimatedMinutes` from 8 to 15.
2. The writer moves each question in `content/questions/science/<topic>/<slug>.yaml` to the file of the lesson that teaches it: a new `<new slug>.yaml` with the same `meta` (subject, topic, `subtopic: <new slug>`, exams). Questions move word for word with ids unchanged.
3. The lead adds the new lesson to `tools/lesson_author/outline.json` after the original, and updates the original's title there. The lead validates with Python: both YAML files parse, the question total and id set are unchanged, no id repeats, every `meta` has all four keys.
4. A fresh Opus reader reads each part (`reads/split/round-N/<lesson-id>.json`). Sonnet fixes Blockers and Majors; up to 3 reads per part, as in the final run. Parts are checked with `check_cet_lesson.py --base <split commit>`. The original's length guard is expected to flag the shrink against the old base.
5. Track status in `docs/content/rewrite/cet/splits.json`.

## Not done here

- The Dart import check and the content export check need Dart, which the cloud session lacks. Run them on Aedwon's Mac before any merge: `dart run tools/import_questions/import_questions.dart --root content/questions/science` and the export build.
- Each part ends with fewer than 20 questions. New questions are added in the question phase (P5).
- Exam tags for the new lessons follow the parent's `meta.exams` until the tag phase (P4).
