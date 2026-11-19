# CET lesson figures fix

PASS. All 15 assigned lessons have one figure per marker, in marker order.

| Lesson | SVGs drawn | Marker moved after its solution |
|---|---:|---|
| gamma-emission-and-radiation-penetration | 1 | None |
| spring-and-neap-tides | 1 | 2 |
| faults-and-seismic-waves | 1 | 1 |
| force-time-graphs-and-impulse | 1 | 1 |
| velocity-time-graph-slope-and-area | 1 | 2 |
| segregation-and-punnett-squares | 1 | 1 |
| breathing-and-gas-exchange | 1 | 1 |
| meiosis-i-and-meiosis-ii | 1 | 1 |
| hormones-and-blood-glucose-feedback | 1 | 1 |
| nerves-reflexes-and-brain-control | 1 | 1 |
| taxonomy-and-traditional-ranks | 1 | 1 |
| levels-of-biological-organization | 1 | 1 |
| osmosis-and-tonicity | 1 | 1 |
| triangle-angle-sums-and-types | 1 | 1 |
| triangle-side-limits | 1 | 2 |

Full static check output (one line):
```text
SVG preflight: 436 files, 0 failures
```

- All figures drawn. The gamma decay comparison uses a two-by-two grid for phone-width labels. Meiosis uses chromosome shapes to distinguish homologs within the style D theme palette.
- The penetration PNG moved to slot 02. Its bytes match HEAD. The existing triangle-angle SVG was already in slot 02.
- The Flutter render harness could not bind to 127.0.0.1 in the sandbox. Verification used the static checker and a review of labels, geometry, and marker positions.
- The broader lesson audit stopped on the outdated illustration inventory documented in the figure plan.
- Files touched: 15 new SVGs, 15 briefs, 14 lesson files, one PNG rename, and this summary. The index is empty.
- Policy revision: `71d58f260893792d546c221341a39515b6bf8c10`.
