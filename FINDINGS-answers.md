# Answers and Review State

- Local origin/main is 80f0c8ef5775f9298c58f57fc0eba711999c8772. The database schema starts at 26. This assigned worktree is on gen/qg-p2-answers.

## Needs the lead

- Content Resolve owns Question and the resolver. The resolver must expose the resolved variantIndex to answer and session writers. Historical review application providers belong to Selection per map section 8.
- L4 supersedes Task 2.4 and the older spec storage wording. Sync owns the after-pull call.

- The codec test reached the expected red stage. AttemptItem lacks the getter and AnswerOutcome lacks the constructor argument.

- Quiz pin tests reached the expected missing repository API. Keep bare IDs in questionIdsJson because an existing presentation reader decodes that list directly. Pin indexes in a separate JSON column with a legacy default.

- Schema migration test failed with the expected missing served_variants_json column. The rebuild uses the latest timestamp per question and index across completed attempts and submitted Mock answers. Quiz pin column defaults to an empty JSON map.

- Mock snapshot tests failed on the expected missing answer and paper pin fields.
- Native Mock route currently passes only IDs into its controller and is a presentation file. Route wiring requires a lead ruling under the no-screen-file boundary.

- SubmitAnswer test reached the expected missing input and served state getter. The review cache is excluded from ReviewState JSON to preserve the existing server and sync shape.

- Assessment test failed on the missing session pin input. Assessment selection can now supply a map keyed by question ID.
