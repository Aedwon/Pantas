# Export findings

- Policy ref is 80f0c8ef5. The assigned worktree uses gen/qg-p2-export and contains the Phase 2 map at b2f5499e6.
- L1 supersedes the plan's template delivery. Export will render once and keep Free data separate from Pro notes.
- Seed integration depends on Content Resolve's Drift companions. This work will keep the seed adapter local to tools and record its expected interface.

## Needs the lead

- The map describes current web sets by file, while L1 assigns types by lesson. Type-only sets keyed by lesson keep legacy file sets stable and provide a place for lessons without a source file. These need a compatibility filter for old clients.
- The current app branch has the five original spatial reasoning lessons, but the type files refer to bite-sized lesson IDs absent from content/lessons/. The plan assigns the release content root to Phase 3. Keep the authored IDs and measure against source, with lesson delivery on the release root still to verify.
- Functions test reached red because variantItems is missing. The Dart build hooks stalled during initial test startup, so I also ran the exporter directly to check its output.
- Direct exporter baseline reached red with a missing problemTypes key.
- Compatibility seam for Content Resolve and Server: the shared export key is problemTypes, containing {question, free, pro}. Web question-set and catalog overlays use problemTypes so old readers do not see an unresolved row in questions. Server must forward and consume that overlay.

## Measurements

- Largest Free wrapper is 165,981 UTF-8 JSON bytes, including the serialized payload and digest, for qt-spatial-abstract-reasoning-matrix-size-transfer. The 200,000-byte limit passed for all 28.
- Extra documents are listed as Free plus Pro variant documents, with one extra question set per lesson. Lesson suffix and total: combined-and-mixed-figure-patterns 11, figure-counts-and-fills 3, figure-turns-and-positions 3, folding-and-checking-cube-nets 3, grouping-outlines-and-symmetry 5, grouping-regions-and-inside-details 7, matrix-keeping-all-features 9, matrix-row-and-column-rules 15, matrix-turns-and-counts 9. Total: 65 documents across nine lessons, before any catalog shard changes.
- Web overlay test reached red because withProblemTypes is missing. The CLI now emits one stable type-only set per authored lesson, with a problemTypes array. Existing question files stay in their existing sets.

## Native seam

- Seed input is problemTypes: [{question, free, pro}]. The seed writer will insert metadata and the Free and Pro JSON in one transaction. Content Resolve owns the table definitions and generated companions. Confirm intended SQL names when integrating.
- Direct seed adapter test reached red because nativeProblemType is missing.
- Current main ContentMirror ignores isActive in question payloads. Older clients can still use existing singles and cannot see the type rows. New Content Resolve must honor explicit isActive on the upsert.
- Proposed SQL seam is content_questions.{variant_count, merged_questions_json, choice_kind, show_question_figure, difficulty, type} and content_variants.{type_id, free_json, pro_json}. Seed intentionally fails inside its transaction if the resolved schema differs. Replace these calls with the actual companions when Content Resolve's schema lands.
- All 28 merged source IDs exist in this branch's native question rows and export as inactive while their types are enabled.
- The default emulator Firestore port was already in use. Retrying on isolated local ports with the demo project. Initial concurrent Dart commands also collided in native asset hooks. Subsequent Dart runs will be serialized.
