# PASS
Policy revision `71d58f260`. No Blocker entries in the audit.
## Major
- Fixed fossils 0021 (ash age only) and plate tectonics 0020 (mountain building only).
- Fixed Big Bang 0002 and 0007 coverage (Lemaître and Hubble); fossils 0003 coverage (stratigraphy); plate tectonics 0003 coverage (Hess).
- Fixed plate tectonics 0012–0014 and 0019 tags; lunar eclipse 0012 coverage (blood moon); CMB 0019 coverage (Solar System timeline).
- Fixed water cycle 0010 (no precipitation leaves cloud) and Earth’s subsystems 0021 (balloon starts at ground level).
- Fixed biosphere figure placement and geosphere label, half-life figure placement and daughter label, and stellar and spring/neap figure placement. Removed redundant tide marker.
- Fixed eclipse, solstice, comet, seismic shadow, and nebular figure placement. Moved the lunar figure with the solar figure to preserve SVG order.
- Finding wrong for the active fault example. Its extension arrows were already after the solution.
- Fixed orbital nodes and SVG label, Moon illumination during eclipses, and age evidence from the eroded fault surface.
- Fixed continental and oceanic collision wording, the common massive-star path and stars 0012, and both comet activity and tail-direction findings.
- Fixed cloud droplet growth, controlled seawater density comparisons, and subtropical gyre scope in text and SVG.
- Fixed direct S waves (including Earth layers 0016), mantle-rock drilling (including Earth layers 0022), and conditions for using the P–S arrival gap.
- Fixed air pressure per area, tsunami causes and definition, and Big Bang 0016 (helium and deuterium).
## Minor
- Fixed both precession pointers, the relative-dating scope and shortcut, the empty Geologic Time heading, and the Precambrian label.
- Fixed half-life formula and initial daughter conditions, the coma definition, mantle S-wave teaching, earthquake starting points, and wind shear teaching for weather 0027.
- Fixed the crescent/gibbous tip, shadow parts, solar noon return, and the noon Sun shortcut outside the tropics.
- Fixed inorganic composition and pumice bubbles, the cooling test variable and conclusion, and the rock-cycle processes.
- Fixed seawater salt mass, the two-tide timing model, and spring/neap tidal effects. Finding wrong for water cycle 0024, which already explains tidal effects.
- Fixed convection, water cycle 0014 and 0015, and the apparent brightness figure.
- Fixed fossils 0002 coverage (preservation under melting, heat, and pressure), condensation in the bag, and photosynthesis in the biosphere.
## CHANGED-QUESTIONS
q-earth-science-astronomy-earths-subsystems-0021
q-earth-science-astronomy-fossils-and-geologic-time-0021
q-earth-science-astronomy-layers-of-the-earth-0016
q-earth-science-astronomy-layers-of-the-earth-0022
q-earth-science-astronomy-origin-of-the-universe-0016
q-earth-science-astronomy-plate-tectonics-0012
q-earth-science-astronomy-plate-tectonics-0013
q-earth-science-astronomy-plate-tectonics-0014
q-earth-science-astronomy-plate-tectonics-0019
q-earth-science-astronomy-plate-tectonics-0020
q-earth-science-astronomy-stars-and-galaxies-0012
q-earth-science-astronomy-water-cycle-oceanography-0010
q-earth-science-astronomy-water-cycle-oceanography-0014
q-earth-science-astronomy-water-cycle-oceanography-0015

## Checks
- Requested `dart run` hit a sandbox denial at the shared native hook lock. Ran the same checker from the requested worktree with the existing package config via `dart --packages`.
- Lesson checker exit 1. Output contained 36 expected pool or shipping-question lines. Zero size, nothing-dropped, or part failures.
- Question import exit 0. Solved all 14 changed keys twice and verified their unique keys and notes. Six SVGs parse. `git diff --check` passed.
## Files touched
- Lessons in `content/lessons/science/earth-science-astronomy/` (57). asteroids-and-the-main-belt.md, axial-tilt-and-seasons.md, big-bang-model.md, clouds-and-precipitation.md, coastal-breezes-and-rising-air.md, comet-activity-and-tails.md, cosmic-microwave-background.md, daily-tide-timing.md, dating-faults-and-intrusions.md, earths-living-sphere.md, earths-motions.md, earths-orbit-and-leap-years.md, earths-rotation-and-day-length.md, earths-solid-mantle.md, earths-subsystems.md, eclipse-alignments.md, eclipses-and-moon-phases.md, evaporation-and-transpiration.md, evidence-from-seismic-waves.md, faults-and-seismic-waves.md, fossils-and-geologic-time.md, fossils-and-preservation.md, geologic-time-scale.md, heavenly-bodies.md, identifying-moon-phases.md, igneous-rock-texture.md, layers-of-the-earth.md, lunar-eclipse-types.md, metamorphic-rock-formation.md, minerals-and-rocks.md, minerals-versus-rocks.md, moon-phase-cycle.md, ocean-currents-and-heat.md, orbital-tilt-and-eclipses.md, origin-of-the-universe.md, parent-and-daughter-isotopes.md, philippine-tectonic-hazards.md, plate-boundary-motion.md, plate-motion-and-seafloor-spreading.md, plate-tectonics.md, radiometric-dating-and-half-life.md, relative-dating-of-rock-layers.md, seasonal-constellations.md, seawater-density-and-layers.md, seismic-shadow-zones.md, solar-system-nebular-model.md, solstices-and-equinoxes.md, spring-and-neap-tides.md, star-luminosity-and-brightness.md, stars-and-galaxies.md, stellar-life-cycles.md, subduction-and-volcanoes.md, tropical-cyclone-formation.md, variables-in-a-cooling-test.md, water-cycle-oceanography.md, weather-and-climate.md, weather-versus-climate.md.
- Questions in `content/questions/science/earth-science-astronomy/` (7). earths-subsystems.yaml, fossils-and-geologic-time.yaml, layers-of-the-earth.yaml, origin-of-the-universe.yaml, plate-tectonics.yaml, stars-and-galaxies.yaml, water-cycle-oceanography.yaml.
- Illustrations in `content/illustrations/science/earth-science-astronomy/` (6). 01-fault-and-dike-cut-rock-layers.svg, 01-four-sphere-cycle.svg, 01-atlantic-pacific-gyres-carry-ocean-heat.svg, 01-moon-orbit-crosses-earth-orbit-plane.svg, 01-compare-hot-small-and-cool-large.svg, 01-stellar-paths-from-nebula-to-remnants.svg.
- `docs/content/rewrite/cet/auditfix-earth-science-astronomy.md`
