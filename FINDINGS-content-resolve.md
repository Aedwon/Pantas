# Content Resolve

- Policy checked at origin/main 80f0c8ef5775f9298c58f57fc0eba711999c8772. The remote main matches. This worker worktree is gen/qg-p2-resolve at b2f5499e6, which contains the Phase 2 map and rulings.

## Needs the lead

- Task 2.2 requires agreement with the figure-choice lead on the content database schema version. Map section 8 proposes 11 to 12. Adding native variant storage and figure fields requires that step.
- L7 compatibility conflict: current main reads all entries in the web `questions` list and would construct a blank type question if a type row were inserted there. Deliver web type metadata in a separate `types` array, and keep type ids out of the old question catalog list. Native rollback packaging also needs compatibility verification against the matching installer.
 
## Verification notes

- The initial pure resolver and selector test failed to load on the expected missing implementation files.
- The protected installer on current main hard-codes schema 11 and requires an exact match before installing. A schema 12 package would be rejected by old native clients. Coordinate installer changes, package delivery and the L7 native compatibility test with the lead and Export.

## Implementation notes

- The pure selector ranks indexes by SHA-256 of the SHA-256 user/type seed and each index. Full digest ordering is independent of Dart's runtime hash and random implementations. The resolver preserves source-order choice identity before the per-variant shuffle.
- The legacy web mapper matches origin/main byte for byte. Added a fixture for the proposed separate type array. The actual Export output is still needed for an end-to-end L7 assertion.
- The variant cache test failed to compile on the missing `ContentKind.variants` before the change. Variant documents now use the existing kind-keyed cache with note removal at downgrade and refresh on access change.
- Repository-wide format check reported six preexisting formatting differences under `tool/lints`. The layering command hit a native-asset dylib rename collision while another Dart command was active; retry verification sequentially.
- Pure resolver tests passed. A standalone VM and compiled JavaScript selector probe both returned [0, 3, 2, 1] for the same fixture. The test suite now pins that sequence.
- The web mirror rollback test reproduced an explicitly inactive row remaining active. The mirror now applies an explicit activity field inside the existing transaction and preserves catalog activity if the set omits the field.
- Layering passed on retry. Attribution passed. The first analyzer run reported an analysis server initialization error.
