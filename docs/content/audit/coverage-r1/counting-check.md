# Counting check, all exams

Status: FINAL NARROW-RECHECK COUNT PASS. The prior UNKNOWN evidence mismatch is corrected.

## Identity and inputs

Policy read from `origin/main` at `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`. Audit branch snapshot: `docs/content-coverage-audit-r1`, HEAD `261f8685b5add6652037cc6ba0f62c21dc8ce8cb`. Pinned corpus: `content/question-qa-r2`, commit `765c5dc0fa5586281047bf4f7b30d09ab3707887`. The source/rebuild gate is accepted in `review/requirements-acceptance.md`. The task snapshot is the file hashes below; do not apply these results to regenerated inputs.

The corpus check read only each of the 158 pinned lesson paths' frontmatter through the closing delimiter. It checked `_id`, title, subject, and topic against the inventory. All 158 matched. Aggregate SHA-256 of ordered frontmatter bytes: `5b8db5fb683427f84e21486c3f03370fb4d3ead0de8d770ba743be176ea1c649`.

| Input | SHA-256 |
|---|---|
| `docs/content/audit/coverage-r1/inventory-lessons.json` | `4c26a6655ab6f288a0c758eeccd3ceb308e58ae83251773dd57ea4a939edc414` |
| `tools/lesson_author/outline.json` | `8b436e36f9bed39eb55b4356f82a4e91121b2506337b27c8fcb11f791d319e1a` |
| `docs/content/audit/coverage-r1/original-corpus-tab-capture.md` | `3b2bc8da6343a3eccc6a9194c86f2b07e7021a9047e8891f48e3706c41b5db2e` |
| `docs/content/audit/coverage-r1/original-corpus-tab-structure-before.json` | `0441ac6e8fe287196a492d9abad56d4454090a44d54a99b6bc9eca37cf47c902` |
| `docs/content/audit/coverage-r1/requirement-input-manifest.json` | `f47c0ee3481607a26619e2f66d1d054ccc7a869e80b98de911c95fd8fbf36531` |
| `docs/content/audit/coverage-r1/requirement-map.json` | `1ae0f1fbe56108365cccadc41b581079cc546aedb81595e07db9f63c522ff1b0` |
| `docs/content/audit/coverage-r1/lesson-exam-tags.json` | `c614bb079dcd5ab6a7a7fb5e98f9225b961dc5fb7104431ccaac04da20d6ad9c` |
| `docs/content/audit/coverage-r1/outline-comparison.md` | `31d8d294ccd7b310bc8b80989ab62bc1dfd5d886ddaa14edd0dc65dd63c3e088` |
| `docs/content/exam-format-profiles.md` | `9dcc230d6c3a7fced854485a3309d3b35ddecebe6d12d8898749056c84661937` |

The nine requirement and nine map hashes appear below. Requirement hashes equal the accepted input manifest; all 10 manifest hashes (nine requirements and profiles) are unchanged.

| Exam | Requirement SHA-256 | Map SHA-256 | Requirement rows / map headings |
|---|---|---|---:|
| ACET | `cc0dd9c8a2b2e5609166fcbd4d5d05a312b82b6a1510c3869992a3ed8e91315e` | `2c5533c3e2dfc312072d9a3a9e8a3cf21950304d444c776a2647176637e84a0e` | 67 / 67 |
| CSE Professional | `ef24b0f70aeeec1c3d00c9b731bfd4758b067dbe818414ff46662553fd48e51b` | `269bb26f45b0fe2bccc399dfa0ec9139b3abe205f0dbf0cbc52b2a31094c6400` | 45 / 45 |
| CSE Subprofessional | `ef86371dc96ebf3cd550c916170261df2578501841b6cdd49669cd7a9abd9990` | `55e6273746fee473c2c447358efe70a15f76580a20734e354305821a87235fd7` | 51 / 51 |
| DCAT | `84ca5901bd744c655c937f0199f1578cee9c5806a9a8b463f45d6ab88c57de97` | `470f2ce60252fba8b510c5cdaa3c65d159db500c1391ee1c8e784a6c137238c3` | 55 / 55 |
| DOST-SEI | `e6d07ba21e0d194f6efdeade6e2429ffa7a5af8ae5d0c7e9df9c7dde9bce730a` | `524033e6398eb40716f745d09a3bd548ec26f31ff899c652740f7ce4e67b8d3` | 50 / 50 |
| PUPCET | `87c388bc5d09285dabebde9e1a9d79e7f0776cb8898496741eaec68d4843b002` | `1c73ac02df26b241fec6aab5b33d32c467a6c49c9040a4c420ad5197f0ece17d` | 53 / 53 |
| SM Foundation | `34908cdcee12d4be37f0011e5479c0f70357f2df9f3a7fd631f8f7a1e9a9a8de` | `b5e8c7ee86634bccb12728938fb5cff473fded2a96cc9c02eb50d68d9099ea81` | 50 / 50 |
| UPCAT | `ae3228df48f83f6909a1939e793afa92c7651d0cb2dbfdc221d328b63a8126d6` | `ee88a3930edaf2f0580565e83fad344f3f7d4950cac40d026c7a31055090baf4` | 114 / 114 |
| USTET | `9d674fe20a1c714a0f262b1b173ff79ca2cbb4d98ce737dd6a305b2392b806aa` | `d8a831492611c4d092e7676adf054a2b1fc1bb5df8a708422d85b084f96757d6` | 50 / 50 |

## Independent counts and checks

- Catalog: 158 lesson rows; 158 unique IDs and paths. All 158 paths and frontmatter fields match the pinned corpus.
- Tags: 158 rows; IDs and paths exactly equal the catalog. Each lesson's exam tags and evidence-row IDs exactly equal the connected requirement-map edges. No missing or extra references. There are 848 distinct lesson-exam edges.
- Requirement records: 535 unique IDs; all 478 bullet lines in source sections 2 and 3 map to a record. The other 57 records preserve subject or scope records not formatted as bullets. All 535 source line locators point to exact line text, and each exact record text appears in its exam map.
- Nine maps: 535 unique headings in total, with no missing or extra headings. The maps have nine distinct exam names.
- Requirement edges: all linked lesson IDs and paths resolve to the same actual inventory entry. Each row preserves equal ID and path counts. The 57 rows labeled `UNKNOWN` and three rows labeled `CONSTRAINT OR SOURCE CONFLICT` have no lesson edges. Compound rows with edges remain `PARTIAL NAME LEADS` or `PROVISIONAL NAME LEADS`; none is labeled as taught or complete.
- Profiles: nine exam tables and 11 entries per table, 99 entries total. Every row has a valid confidence label, source, and checked date. Each profile table exactly matches its accepted requirement table.
- Outline: six subjects, 25 topics, 141 unique lesson units. The inventory has six subjects, 25 topics, and 158 lessons. All 141 outline units resolve. Exactly 17 inventory lessons are absent from the outline, and all 17 paths below match the omission list in `outline-comparison.md`.
- Original corpus reference: the capture preserves the text export and title. Its SHA-256 is recorded in that capture. The separate 238,105-byte structural snapshot supplies a formatting baseline. The captured original outline combines “Inferencing and Drawing Conclusions Distinguishing Fact from Opinion” in one bullet; the chosen catalog represents these as separate lesson units. Nested bullets in the original tab do not establish an exact original lesson count.
- No questions or lesson bodies were read. No claim is made about teaching, examples, depth, practice, runtime availability, or later levels.

Inventory lessons absent from the stored outline:

- `content/lessons/general-information/code-of-conduct-ra-6713/duties-and-prohibited-acts.md`
- `content/lessons/general-information/code-of-conduct-ra-6713/norms-of-conduct.md`
- `content/lessons/general-information/code-of-conduct-ra-6713/penalties-and-enforcement.md`
- `content/lessons/general-information/code-of-conduct-ra-6713/statements-of-assets-and-divestment.md`
- `content/lessons/general-information/environment-management/environmental-concepts.md`
- `content/lessons/general-information/environment-management/the-environmental-laws.md`
- `content/lessons/general-information/peace-and-human-rights/human-rights-fundamentals.md`
- `content/lessons/general-information/peace-and-human-rights/humanitarian-law-and-human-rights-law.md`
- `content/lessons/general-information/philippine-constitution/accountability-and-impeachment.md`
- `content/lessons/general-information/philippine-constitution/bill-of-rights.md`
- `content/lessons/general-information/philippine-constitution/the-articles-in-outline.md`
- `content/lessons/general-information/philippine-constitution/the-civil-service-commission.md`
- `content/lessons/mathematics/data-interpretation/rates-ratios-and-percentages-in-context.md`
- `content/lessons/mathematics/data-interpretation/tables-and-charts.md`
- `content/lessons/reasoning/clerical-ability/alphabetic-filing-rules.md`
- `content/lessons/reasoning/clerical-ability/numeric-and-chronological-filing.md`
- `content/lessons/reasoning/verbal-logic/assumptions-and-conclusions.md`

## First-draft semantic exceptions (historical)

Mechanical reference checks do not prove relevance. A separate Sol map review flagged these rows for incorrect provisional links: `cse-subprofessional-L137` and `cse-subprofessional-L142` linked Springs and Weights to unknown topic weights; `cse-subprofessional-L116` and `cse-subprofessional-L117` linked atomic chemistry through unbounded “ions” keyword matches to Constitution/RA 6713 topics. The lead regenerated the maps. The first-draft hashes and flags remain recorded above.

## Result

**First-draft result: FLAGS.** The independent mechanical counts and references passed at the first-draft hashes above. The four semantic exceptions prevented a combined map pass. The lead then corrected and regenerated the map artifacts.

## First correction independent recount (historical)

Recount date: October 5, 2026. Policy remains `main` commit `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`; audit HEAD remains `261f8685b5add6652037cc6ba0f62c21dc8ce8cb`; corpus remains `765c5dc0fa5586281047bf4f7b30d09ab3707887`. Current map hashes are pinned in `map-input-manifest.json`, SHA-256 `717c9b8abdb57d1f99551093b74f68cacb6a19bc19cdae95c7390717da8409ca`. All 13 manifest hashes match their files. Requirements remain at the 10 hashes in `requirement-input-manifest.json`, SHA-256 `f47c0ee3481607a26619e2f66d1d054ccc7a869e80b98de911c95fd8fbf36531`; all 10 match.

| Corrected input | SHA-256 |
|---|---|
| `docs/content/audit/coverage-r1/requirement-map.json` | `61e1a02e1fbaa9dbba3f98885643ec2d3d0cbe820febdcc0525941af4cfc64a1` |
| `docs/content/audit/coverage-r1/lesson-exam-tags.json` | `c88ef277a58ba5ac76dd10d44f8423569c842eab21c2bd4383a543daece141f5` |
| `docs/content/audit/coverage-r1/outline-comparison.md` | `7d46f2202ccf63d9d175d7019c45a200b0350fa247dda191c051185608d2bddb` |
| `docs/content/audit/coverage-r1/maps/acet.md` | `197e55f74b3c0f98cec5c25239073ada21404369802a777a2d9eef828f4b98a5` |
| `docs/content/audit/coverage-r1/maps/cse-professional.md` | `ec2f3d4d18d6419c3b27fdcb97737d98dab64004eea46780e348e6da0b56714d` |
| `docs/content/audit/coverage-r1/maps/cse-subprofessional.md` | `43a33d80a6221f2eb3b550dd5fbe859117f3cae7364b1e5babf852523e82c876` |
| `docs/content/audit/coverage-r1/maps/dcat.md` | `4e07384a4628df956610e5546214baf80300a961ca5829d49c9b5e1fdee3a9dd` |
| `docs/content/audit/coverage-r1/maps/dost-sei.md` | `90b279b2422fe770f1c33f00eeaa4175c8cdc170d4e5de8d169faeedc7880024` |
| `docs/content/audit/coverage-r1/maps/pupcet.md` | `2af05cdf9487fe55b8a040b6e43ad2516de6f1c808ec5f65e471b74bb021d986` |
| `docs/content/audit/coverage-r1/maps/sm-foundation.md` | `468a060bcd8be04898f535705b0e20f29a85fab480daf266d8e088857cc5c38c` |
| `docs/content/audit/coverage-r1/maps/upcat.md` | `1824baaff9c95cc1b33ac7d04e33fc140093b936fae68a7e8b527620b339c95e` |
| `docs/content/audit/coverage-r1/maps/ustet.md` | `cc094c21d4f74a11450e13a3136833a5cd7238741758d06ef1c1ab68e2ce835a` |

The corrected `build_level1_maps.py` hash is `16208f7c0ad3b74e00d81c5ee9204293326d1e064766a3755841c9f830193d00`. The current outline comparison retains the inventory hash above; the corrected content and map artifacts are tracked separately in the manifest.

The independent recount found:

- 158 inventory lessons, each with a unique ID and path. All 158 pinned corpus paths exist, and frontmatter `_id`, title, subject, and topic match. Ordered-frontmatter SHA-256 remains `5b8db5fb683427f84e21486c3f03370fb4d3ead0de8d770ba743be176ea1c649`.
- 158 tag records with exact catalog ID and path sets. Each lesson's evidence-row IDs and exam tags equal the edges in the corrected requirement map. No extra or missing references; 822 distinct lesson-exam edges.
- 535 unique requirement records. All 478 bullet lines in source sections 2 and 3 have records; all 535 line locators match exact source text, and all 535 exact record texts appear in the corresponding map. The nine maps contain exactly 67, 45, 51, 55, 50, 53, 50, 114, and 50 unique headings, respectively, with no missing or extra headings.
- Every linked ID/path pair resolves to the same inventory lesson. There are no linked rows with kind `unknown`, `constraint`, or `context`, or status `UNKNOWN` or `CONSTRAINT OR SOURCE CONFLICT`.
- All 99 format-profile rows (nine profiles, 11 entries each) have valid confidence, source, and date fields. Each table exactly matches its accepted requirement table. All ten accepted requirement/profile hashes remain unchanged.
- The outline has six subject records, 25 topics, and 141 unique lesson units across five populated subjects. Its General Information placeholder has four topics and zero lessons. All 141 outline units resolve to inventory paths; exactly 17 inventory lessons remain absent, matching the 17 paths listed above.
- Original-tab text and title remain represented by the text capture; the structural JSON remains the formatting baseline. The original text combines “Inferencing and Drawing Conclusions Distinguishing Fact from Opinion” in one bullet, while the inventory treats those as separate lesson units. Nested bullets do not provide an exact original lesson count.

The four earlier semantic examples now have no erroneous edges. `cse-subprofessional-L137` and `cse-subprofessional-L142` have no lesson edges. `cse-subprofessional-L116` points only to Constitution lessons, and `cse-subprofessional-L117` points only to R.A. 6713 lessons; neither points to atomic chemistry. This recount establishes map accounting and target identity, not whether every other connection is semantically correct. Fresh Sol review of the correction groups remains the independent semantic gate.

**First-correction count result: PASS.** Independent semantic acceptance remained pending. No lesson bodies or questions were read. No later-level work was started.

## Second correction independent recount

Recount date: October 5, 2026. Policy remains `main` commit `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`. Audit checkpoint `02a5c71ca5e1d0a89001ca7a4eda44bb9e7635ad` matches the local and live audit branch. Corpus remains `765c5dc0fa5586281047bf4f7b30d09ab3707887`, read only. Current map-input manifest SHA-256: `72f892dcb79ada10f8a132a9be9f4ed65c9be5015fdb78b392b80caf41dbbd69`. Its 13 listed hashes match. Requirements/profile manifest SHA-256 remains `f47c0ee3481607a26619e2f66d1d054ccc7a869e80b98de911c95fd8fbf36531`; all ten hashes still match, including accepted profile SHA-256 `9dcc230d6c3a7fced854485a3309d3b35ddecebe6d12d8898749056c84661937`.

The second correction's map manifest pins the current catalog and maps:

| Input | SHA-256 |
|---|---|
| `docs/content/audit/coverage-r1/build_level1_maps.py` | `392cd6ae8a3abf2a370677f31e57e46bd5a815d9436bcd740c3ffb1ee793c6c2` |
| `docs/content/audit/coverage-r1/requirement-map.json` | `4908c060f9edced27bad9d6e069a5bcbea727673b656cf9d14d6387e8ac5a92b` |
| `docs/content/audit/coverage-r1/lesson-exam-tags.json` | `9ea1b39172e722f0297f432766f094c717279df636255fac0302e5964a3d3e74` |
| `docs/content/audit/coverage-r1/outline-comparison.md` | `64eb0cb62abbd6347e7da362aa4c7e7a2c6448400283c96d2bf0e5bc998f4110` |
| `docs/content/audit/coverage-r1/maps/acet.md` | `3e6fcf95e521dd4ce325027858f68b193f8863173bd8db7a023ad9fb6ad45af3` |
| `docs/content/audit/coverage-r1/maps/cse-professional.md` | `ec2f3d4d18d6419c3b27fdcb97737d98dab64004eea46780e348e6da0b56714d` |
| `docs/content/audit/coverage-r1/maps/cse-subprofessional.md` | `afb8b1b248e05d4ddc2e93a9b7aa7f200609da8828a7b285faf09ac864b9a8b4` |
| `docs/content/audit/coverage-r1/maps/dcat.md` | `09226497e57fc8b573650c1d33ea9d9b1a08a98093d02efec099ba2f9d3ad2e0` |
| `docs/content/audit/coverage-r1/maps/dost-sei.md` | `c8251ed648fc285fe25f9fd194188c60c9708e503144631b3ac727110d4b28c2` |
| `docs/content/audit/coverage-r1/maps/pupcet.md` | `443549c603694b424801b594a2149b57a31f6bb14f6c603599335ec5e6144950` |
| `docs/content/audit/coverage-r1/maps/sm-foundation.md` | `8237a63e8d67f89b30aab3c274dde00e1cff61606aea6d130d542b67d32f2d75` |
| `docs/content/audit/coverage-r1/maps/upcat.md` | `cd769a0d95102fe87b07a2689041c356db6d2bcf051f24ccf72bc802d9050cd7` |
| `docs/content/audit/coverage-r1/maps/ustet.md` | `9edab99c9b60b28666988052916b2228a10273fc7ca674272c1895f88c35b9df` |

The independent mechanical recount confirms:

- 158 catalog lessons, each with one unique ID and path; all 158 pinned corpus frontmatter records match the inventory. The aggregate frontmatter hash remains `5b8db5fb683427f84e21486c3f03370fb4d3ead0de8d770ba743be176ea1c649`.
- 158 tag records match the catalog IDs and paths. Every evidence-row list and exam-tag list exactly matches requirement-map edges. There are 819 distinct lesson-exam edges.
- 535 unique requirement records; all 478 section 2 and 3 bullet lines are represented. All 535 line locators point to exact source text, and all 535 complete record texts appear in their maps. Nine distinct maps contain exactly 67, 45, 51, 55, 50, 53, 50, 114, and 50 unique headings, with no missing or extra headings.
- Every edge resolves to an actual inventory ID and matching path. No `kind` `unknown`, `constraint`, or `context` row has lesson edges. No row with status `CONSTRAINT OR SOURCE CONFLICT` has edges.
- The format profiles still contain 99 rows, with valid confidence, source, and date values. All nine tables equal the accepted requirement tables, and the accepted profile and requirement hashes are unchanged.
- The outline still has six subject records and 25 topics. It has 141 unique lesson units across five populated subjects; General Information has four placeholder topics and no lessons. All 141 outline units resolve to the inventory. Exactly 17 inventory lessons remain omitted, matching the path list above.
- ACET `L043`, CSE Subprofessional `L102` and `L108` all have status `UNKNOWN`, evidence `unknown`, and no lesson edges. CSE Subprofessional `L142` is likewise unknown with no edges. `L137` is a constraint with supported-weak source evidence and no lesson edges. `L116` links only Constitution lessons, and `L117` only R.A. 6713 lessons; neither links atomic chemistry. USTET Mental Ability rows contain no fluid or mechanical-reasoning lesson links. Fluid-science links in the separately named USTET Science rows remain.

One classification inconsistency remains: `dcat-L041` has status `UNKNOWN`, no lesson edges, and text that says the academic classification is unknown, but its evidence field is `reported subject; inspect exact source qualifier` rather than `unknown`. The source locator and rendered text match. This is an evidence/status mismatch, not a missing lesson reference.

**Second-correction count result: FLAGS (historical).** All catalog, tag, source-record, map-render, profile, and outline counts passed. The `dcat-L041` evidence mismatch prevented a count PASS under the explicit-unknown consistency check. The lead then normalized its evidence label.

## Final narrow consistency recheck

Recount date: October 5, 2026. Policy remains `main` commit `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`; audit checkpoint is `02a5c71ca5e1d0a89001ca7a4eda44bb9e7635ad`; corpus remains `765c5dc0fa5586281047bf4f7b30d09ab3707887`. Current `map-input-manifest.json` SHA-256 is `7033ba5feae5a2780da176e20f9714cf56a92fd1e33732f4118ba2f0c465976c`; all 13 listed file hashes match. The previous second-correction manifest remains preserved as `map-input-manifest-second-correction.json`.

The updated output hashes are:

| Input | SHA-256 |
|---|---|
| `docs/content/audit/coverage-r1/build_level1_maps.py` | `210af363b9ceeed254bb8d5e08d2f031c04d03a4e334adcd70dae105212ee9fd` |
| `docs/content/audit/coverage-r1/requirement-map.json` | `023a24c7c6b21ae809d38542869b81b9f466cf089bc5f50927d34b1e192a3493` |

The other 11 listed outputs retain the second-correction hashes recorded above. The accepted requirement/profile manifest remains byte-identical at SHA-256 `f47c0ee3481607a26619e2f66d1d054ccc7a869e80b98de911c95fd8fbf36531`. Its 10 file hashes match; the accepted profiles remain 99 rows at SHA-256 `9dcc230d6c3a7fced854485a3309d3b35ddecebe6d12d8898749056c84661937`.

The final narrow recount confirms:

- Catalog and tags remain 158 lessons each, with unique and matching IDs and paths. All 158 pinned corpus frontmatter records match the catalog. The tag evidence rows and exam tags exactly match the requirement-map edges: 819 distinct lesson-exam edges, with no invalid target or parity errors.
- All 535 requirement records still have exact source line locators and exact rendered text. All 478 source bullets in sections 2 and 3 are represented. The nine maps still contain 67, 45, 51, 55, 50, 53, 50, 114, and 50 unique headings, with no missing or extra headings.
- All 68 rows with status `UNKNOWN` now have evidence `unknown`; none has lesson edges. No row with kind `unknown`, `constraint`, or `context`, or status `CONSTRAINT OR SOURCE CONFLICT`, has lesson edges.
- The profiles remain 99 rows across nine exams, with valid confidence, source, and date fields. Each table matches its accepted requirement table. All accepted requirement and profile hashes are unchanged.
- The outline remains six subject records and 25 topics, with 141 unique lesson units in five populated subjects. The General Information placeholder has four topics and no lessons. Exactly 17 inventory lessons remain absent, all listed above, with no duplicate or invalid outline targets.
- The prior regression checks remain clear: ACET `L043`, CSE Subprofessional `L102/L108`, and CSE Subprofessional `L142` have explicit unknown status/evidence and no edges. `L137` remains a constraint with no edges. `L116/L117` point only to Constitution and R.A. 6713 lessons, not chemistry. USTET Mental Ability still has no fluid or mechanical-reasoning links.

The final `dcat-L041` record now has status `UNKNOWN`, evidence `unknown`, confidence `unknown academic classification`, and no lesson edges. Its source line and rendered text remain exact. This resolves the sole counting flag from the previous snapshot.

The fresh Sol semantic review reports PASS for the second-correction provisional maps, with R1-R4 closed. The narrow evidence normalization does not alter any map, lesson tag, edge, or outline output. This counting check confirms the records and references; it does not establish teaching depth, worked examples, prerequisites, practice quality, runtime availability, mastery, or full exam coverage.

**Final narrow-recheck count result: PASS.** The semantic review is separately recorded as PASS. No lesson bodies or questions were read, and no later-level work was started.
