# Level1 checkpoint: maps accepted, Google tab blocked

Level1 is not finished. State: BLOCKED because the native Google Docs write tool requires approval and the session's approval policy is never. Level2 has neither approval nor any started task. All work is findings/recommendations and documentation only; lessons, questions, app, importer, and schema remain unchanged.

## Accepted work

- Nine separate [exam maps](maps/), all source registers, source checks, fresh organizer-first rebuilds, and resolved flags.
- [Filled format profiles](exam-format-profiles.md): nine exams,99source/date/confidence entries, explicit unknowns and historical-cycle limitations. The canonical branch-worktree copy is also saved at docs/content/exam-format-profiles.md; its exact audit-local copy preserves the reviewed document within the watcher's save scope.
- [Complete corpus comparison](outline-comparison.md):158existing lessons, six subjects,25topics. The stored outline has141lesson units and17omissions, including its empty General Information placeholder. Original Google text has different grouping and a merged inference/fact-opinion bullet; nested concepts do not define extra lessons.
- [All-exam counting](counting-check.md):535exactsource records including478bullets; unique158lesson IDs/paths;819distinct provisional lesson-exam tags, no missing/duplicate target and exact map/tag parity. All99profiles match accepted packets and all68unknown records have zero lesson connections.
- [Independent semantic review](review/exam-map-review.md): all original five correction groups and R1-R4 closed, final evidence-label normalization confirmed by exact JSON diff. Earlier FLAGS are retained as history and do not apply where closure is explicit.

## Material uncertainty

The organizer sources often publish broad domains without detailed current syllabi. Curriculum candidates and weak recollections never become official topic requirements. DOST's2026primer does not establish2027continuity. Exact topic depth, portions of bilingual instruction, several format/scoring entries, subtest proportions and topic weights remain unknown. Names and metadata identify candidate lessons, not taught coverage. Worked examples, prerequisites, practice quality, body depth, runtime exam offering and student access remain unverified. No complete-coverage claim is justified.

## Google document result

The new audited tab was not created. The write tool returned exactly:

> MCP tool call requires approval, but approval policy is never

After the blocked request, a fresh native read confirmed the original title, body, styles and full tab structure exactly match the stored snapshot:219bodyelements, same document revision, no audited tab. [Verification record](google-tab-verification.json).

The complete [human-readable audited-tab draft](audited-tab-draft.md) and [insertion payload](audited-tab-draft.json) are saved:200paragraphs,158lesson paragraphs,21529UTF16characters. Every lesson title and tag list matches the accepted catalog. The draft is ready for the already-authorized new-tab write once tool approval is available. It preserves the original tab and applies no tags to subject/topic headings.

## Agent recovery details

Current main policy:cb48097bedf15bec2cfbe4fb3aa7e957753b1727. Corpus read-only:content/question-qa-r2 at765c5dc0fa5586281047bf4f7b30d09ab3707887. Latest verified watcher checkpoint:02a5c71ca5e1d0a89001ca7a4eda44bb9e7635ad. Source and map manifests identify exact current inputs; final map manifest SHA7033ba5feae5a2780da176e20f9714cf56a92fd1e33732f4118ba2f0c465976c. Lead performs no git mutations; watcher saves/uploads allowed documents.

Latest lead verification:13map hashes and10requirement/profile hashes match;158/535/819parity passes; all158draft title/tag lists match; audit-local and canonical profile bytes identical; git diff --check exits0; pinned corpus remains clean. Google live read confirms original preservation and write blocker. No Flutter suite is applicable because application/content code is unchanged.

Automatic resumes must do nothing while first-line STATE is BLOCKED. Recovery needs Aedwon to provide tool approval for Google Docs writes. Then resume only level1: verify policy/corpus/hashes and originaltab structure, create one separate auditedtab, insert/format only thattab, readback158title/tag lists and exact original preservation, finish verification. Only afterward set AWAITING_APPROVAL level1done and ask to start level2overlap. A quota-test message is never approval.
