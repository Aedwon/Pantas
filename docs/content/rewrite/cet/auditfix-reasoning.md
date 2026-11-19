PASS — CET reasoning audit fixes (policy `71d58f260`)
- Blocker 1 fixed. Gear 0006 no longer shows the unknown gear; both speed and tooth-passage checks give 16 teeth.
- Major 1 fixed. Equal speeds give equal pressures at equal heights in the stated ideal flow.
- Major 2 fixed. The friction claim now assumes a level pipe with no pump.
- Major 3 fixed. Identical branches have equal outlet heights and pressures; different branches can split flow unevenly.
- Major 4 fixed. The part and gear 0019 use the pitch point. Equal rim travel and reciprocal speed/radius ratios agree.
- Major 5 fixed. Gear 0016 points to Gear Speeds and Tooth Counts, which explains cancellation. Mesh parity and signed ratios agree.
- Major 6 fixed. Defined absolute and gauge pressure for 0017, 0018, and 0020. Added conversion to 0017; depth difference and separate pressure totals both give 6 kPa.
- Major 7 fixed. Pulley 0015 supplies the pulley effort. Torque balance and the arm ratio both give 250 N for the lever.
- Major 8 fixed. Part 5 classifies the wheelbarrow. Part 6 gives the 200 N balance calculation for horizontal arms and a weightless, frictionless barrow.
- Major 9 fixed. Lever-class MA values explicitly use ideal conditions.
- Major 10 fixed. Made the push slant down, described torque magnitude, and kept the 1 m arm in the torque calculation.
- Major 11 fixed. Hooke’s law uses the linear range; returning to the old shape alone does not establish linearity.
- Major 12 fixed. Hooke’s law part teaches equal-gravity mass and weight ratios for spring 0010, 0013, and 0015.
- Major 13 fixed. Defined uniform density and stated constant thickness for the plate symmetry and triangle rules.
- Major 14 fixed. Stability 0011 supplies the rounded toy’s geometry and asks about torque at the contact point. The weight line and rise in center height both give a restoring turn.
- Major 15 fixed. Stability 0019 centers both weight lines. The slope ratio and tipping geometry both give the wider box a larger angle.
- Major 16 fixed. Described gravity as downward acceleration near Earth.
- Minor 1 fixed. Named the sealed-tank example and defined the pascal in the active part. The retired original already defines it.
- Minor 2 fixed. Named the oil-and-water example, gave the density and mixing conditions, and excluded capillary effects in Example 1.
- Minor 3 fixed. Specified that pressure is higher at the lower piston in the resting liquid.
- Minor 4 fixed. The teaching gear figure now has two gears and marks only the first direction.
- Minor 5 fixed. Removed the duplicate equal-level teaching figure. The worked solution retains its figure.
- Minor 6 fixed. Specified a single fixed pulley used as a guide and a steady-speed lift.
- Minor 7 fixed. Specified a single weightless rope in an ideal, frictionless system.
- Minor 8 fixed. Removed the old numbering note, referenced both examples by their support counts, and restored the ideal vertical-support conditions.
- Minor 9 fixed. Pulley 0023 and 0024 use pulley wheels. Tracing the rope and counting moving-block attachments both give 5 and 6.
- Minor 10 fixed. Used Reading Right Triangle Ratios and named the angled-effort example. Removed the retired numbering note.
- Minor 11 fixed. The hanging-mass formula now states the linear-range condition.
- Minor 12 fixed. Specified four square corners and explained the two-point segment and finite-foot strip.
- Minor 13 fixed. Defined torque as a turning effect at first use.
- Minor 14 fixed. Restated the tipping formula and distances up front. The retired original already teaches them in the same section.
- Minor 15 fixed. Defined the lever arm and gave the two threshold forces, with tipping just above them.
- Minor 16 fixed. Named the slow-tilt model and described the outside wheels carrying more of the load.
CHANGED-QUESTIONS
q-mechanical-technical-reasoning-fluid-pressure-0017
q-mechanical-technical-reasoning-gear-rotations-0006
q-mechanical-technical-reasoning-gear-rotations-0016
q-mechanical-technical-reasoning-gear-rotations-0019
q-mechanical-technical-reasoning-pulleys-and-levers-0015
q-mechanical-technical-reasoning-pulleys-and-levers-0023
q-mechanical-technical-reasoning-pulleys-and-levers-0024
q-mechanical-technical-reasoning-structural-stability-0011
q-mechanical-technical-reasoning-structural-stability-0019
- Checks. `dart run` hit a sandbox lock; the same checker via direct Dart invocation exited 1 with only 11 expected pool findings (4 pool counts, 7 shipping key points). Zero size, nothing-dropped, or part failures.
- Reasoning importer exited 0 (403 questions, empty stderr). Solved each changed key twice. Changed questions await reapproval. `git diff --check` passed.
- Files touched under `content/lessons/reasoning/mechanical-technical-reasoning/` (all .md) — balancing-lever-torques, classes-of-levers, combined-center-of-gravity, comparing-tipping-angles, counting-pulley-supports, finding-the-base-of-support, finding-the-tipping-angle, flow-rate-in-straight-and-branching-pipes, flow-speed-height-and-pressure, fluid-pressure, gear-rotations, gear-speeds-and-tooth-counts, hookes-law-and-stiffness, ideal-mechanical-advantage, liquid-levels-in-connected-vessels, locating-the-center-of-gravity, pressure-and-force-in-hydraulics, pressure-in-a-resting-liquid, pulleys-and-levers, pushing-an-object-over, rotation-directions-in-gear-systems, spring-extension-under-weight, springs-and-weights, structural-stability, supporting-rope-segments, torque-from-angled-forces, weight-line-and-tipping, why-vehicles-roll-in-turns.
- Files touched under `content/questions/reasoning/mechanical-technical-reasoning/` — fluid-pressure.yaml, gear-rotations.yaml, pulleys-and-levers.yaml, structural-stability.yaml. Also this report.
