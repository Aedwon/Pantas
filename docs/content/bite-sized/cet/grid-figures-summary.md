# CET grid figures

- Added and reapproved Geometry 0006 and 0012 and Counting 0014. Their existing figure slugs stay beside the specs.
- Held Geometry 0016. At 358 logical pixels, PR #77 draws P cells at 25.83 pixels and Q cells at 31. The stem says the grids have the same spacing.
- Independent blind solve matched all four keys. Zero mismatches and zero low-confidence answers. See [verification](../../verification/cet-split.md).
- Used cached origin/main `fd6789a45` and PR #77 `a0dad3cfb`. The fetch was blocked by sandbox permissions.
- `lesson_checks`, `content_gate`, and main's question validator exited 0. Main accepted the new kind.
- The main export and asset export matched byte for byte. The export grew from 4,425 to 4,428 questions, adding exactly the three approved IDs. Geometry 0016 is absent.
- The seed build and local package build and verification exited 0. SQLite preserved all three specs.
- Custom tiers, repository checks, and the functions build exited 0. Uploader tests passed 33 of 33.
- Offline upload dry run and file output exited 0. The output preserved all three specs and retained 0016's existing slug-only row. No upload ran.
- SVG preflight passed 436 files. Its seven tests passed, and the 29 invalid fixtures failed as expected.
- The legacy illustration audit exited 1 with the same output on the base and candidate. SVG render and placeholder tests could not start because the sandbox denied the loopback socket.
- Logs and local artifacts are in `/private/tmp/cet-grid-figures.aR9VC6`.

Geometry 0016 needs matching cell spacing in both panels. The Flutter render checks still need a runner with loopback access.

FAIL
