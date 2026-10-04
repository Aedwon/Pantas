# Independent level 1 exam map review

Status: CORRECTION RECHECK COMPLETE, FLAGS. Initial findings are preserved as history; the latest disposition is below.

Policy: main `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`.
Assigned audit HEAD: `261f8685b5add6652037cc6ba0f62c21dc8ce8cb`.
Corpus: `765c5dc0fa5586281047bf4f7b30d09ab3707887`.

Scope: independent review of nine maps, requirement records, and all 535 catalog records using accepted requirements and stored names, summaries, and outlines only. No lesson bodies, questions, new source research, overlap extent, structure, standards, app edits, or target edits.

Initial draft checklist completed below: input hashes, accounting checks, representative matches, semantic findings, and result.

## Reviewed input identity

SHA256 at review start:

- `review/requirements-acceptance.md`: `b3b41a81adf272a4cfc683449abb9cd0689f62348338de77d7f779fa39bade05`
- `requirement-input-manifest.json`: `f47c0ee3481607a26619e2f66d1d054ccc7a869e80b98de911c95fd8fbf36531`
- `requirement-map.json`: `1ae0f1fbe56108365cccadc41b581079cc546aedb81595e07db9f63c522ff1b0`
- `lesson-exam-tags.json`: `c614bb079dcd5ab6a7a7fb5e98f9225b961dc5fb7104431ccaac04da20d6ad9c`
- `outline-comparison.md`: `31d8d294ccd7b310bc8b80989ab62bc1dfd5d886ddaa14edd0dc65dd63c3e088`
- `inventory-lessons.json`: `4c26a6655ab6f288a0c758eeccd3ceb308e58ae83251773dd57ea4a939edc414`
- `original-corpus-tab-capture.md`: `3b2bc8da6343a3eccc6a9194c86f2b07e7021a9047e8891f48e3706c41b5db2e`
- `original-corpus-tab-structure-before.json`: `0441ac6e8fe287196a492d9abad56d4454090a44d54a99b6bc9eca37cf47c902`
- `requirements/acet.md`: `cc0dd9c8a2b2e5609166fcbd4d5d05a312b82b6a1510c3869992a3ed8e91315e`
- `requirements/cse-professional.md`: `ef24b0f70aeeec1c3d00c9b731bfd4758b067dbe818414ff46662553fd48e51b`
- `requirements/cse-subprofessional.md`: `ef86371dc96ebf3cd550c916170261df2578501841b6cdd49669cd7a9abd9990`
- `requirements/dcat.md`: `84ca5901bd744c655c937f0199f1578cee9c5806a9a8b463f45d6ab88c57de97`
- `requirements/dost-sei.md`: `e6d07ba21e0d194f6efdeade6e2429ffa7a5af8ae5d0c7e9df9c7dde9bce730a`
- `requirements/pupcet.md`: `87c388bc5d09285dabebde9e1a9d79e7f0776cb8898496741eaec68d4843b002`
- `requirements/sm-foundation.md`: `34908cdcee12d4be37f0011e5479c0f70357f2df9f3a7fd631f8f7a1e9a9a8de`
- `requirements/upcat.md`: `ae3228df48f83f6909a1939e793afa92c7651d0cb2dbfdc221d328b63a8126d6`
- `requirements/ustet.md`: `9d674fe20a1c714a0f262b1b173ff79ca2cbb4d98ce737dd6a305b2392b806aa`
- `maps/acet.md`: `2c5533c3e2dfc312072d9a3a9e8a3cf21950304d444c776a2647176637e84a0e`
- `maps/cse-professional.md`: `269bb26f45b0fe2bccc399dfa0ec9139b3abe205f0dbf0cbc52b2a31094c6400`
- `maps/cse-subprofessional.md`: `55e6273746fee473c2c447358efe70a15f76580a20734e354305821a87235fd7`
- `maps/dcat.md`: `470f2ce60252fba8b510c5cdaa3c65d159db500c1391ee1c8e784a6c137238c3`
- `maps/dost-sei.md`: `524033e6398deb40716f745d09a3bd548ec26f31ff899c652740f7ce4e67b8d3`
- `maps/pupcet.md`: `1c73ac02df26b241fec6aab5b33d32c467a6c49c9040a4c420ad5197f0ece17d`
- `maps/sm-foundation.md`: `b5e8c7ee86634bccb12728938fb5cff473fded2a96cc9c02eb50d68d9099ea81`
- `maps/upcat.md`: `ee88a3930edaf2f0580565e83fad344f3f7d4950cac40d026c7a31055090baf4`
- `maps/ustet.md`: `d8a831492611c4d092e7676adf054a2b1fc1bb5df8a708422d85b084f96757d6`

## Interim semantic flags

All 535 requirement catalog records have now been inspected against their exact text, assigned lesson IDs, and uncertainty fields. The 158 lesson titles and summaries and stored original outline were read. Concrete correction groups remain: subject-domain leakage in broad rows; substring and polysemous word collisions; unknown/negative constraints becoming positive links; missing named facets; incorrect facet uncertainties. Mechanical accounting succeeds but does not resolve these flags. Precise examples and final disposition follow below.

## Independent checks and actual output

The review reads accepted requirement sections 2-3 as the source of truth, not new organizer research. Exact row texts were compared to the packets and rendered maps. All 535 records were inspected for subject meaning, facet meaning, status, source qualifiers, and linked titles. The complete stored outline and all 158 metadata records were read. The map headings, source text, and lesson-ID occurrences agree with the machine-readable rows. This agreement checks rendering, not correctness of a link.

```text
requirement_records=535
by_exam: UPCAT=114 DCAT=55 ACET=67 USTET=50 PUPCET=53 DOST=50 SM=50 CSE_Professional=45 CSE_Subprofessional=51
statuses: CONTEXT=42 PARTIAL_NAME_LEADS=157 UNKNOWN=57 PROVISIONAL_NAME_LEADS=269 CONSTRAINT_OR_SOURCE_CONFLICT=3 APPARENT_GAP_OR_UNSPECIFIED_CONNECTION=6 UNKNOWN_BROAD_SCOPE_CONNECTION=1
lesson_edges=3785
inventory=158 unique_ids=158 unique_paths=158 subjects=6 topics=25
tag_records=158 unique_ids=158 inventory_tag_id_parity=True
missing_edge_lesson_ids=0
complete_outline_lesson_appearances=158
all_9_map_heading_counts_match=True
all_9_map_row_texts_present=True
all_9_map_lesson_ID_occurrence_counts_match=True
```

These are actual checks against this snapshot. Every lesson appears once in the complete view. Only lessons carry exam tags; subject/topic headings carry none. The 17 additional units listed in reconciliation account for the difference between the stored 141-unit outline and the 158-unit authored inventory. No lesson or question bodies were inspected. Runtime availability remains unknown.

## Findings requiring correction

### MAP-01: Broad rows mix the subject with language and neighboring areas

Targets: `requirement-map.json`, the corresponding nine `maps/*.md` records, and the derived evidence rows in `lesson-exam-tags.json` and `outline-comparison.md`.

- `upcat-L035` Science and `upcat-L036` Mathematics include Grammar, Vocabulary, and Reading lessons because the row also says the test language is unknown. Those words describe delivery language, not extra content inside Science or Mathematics. `upcat-L033` and `upcat-L034` also collapse the separately named Language Proficiency and Reading Comprehension areas into the same union.
- `dcat-L035` Mathematics, `dcat-L036` Statistics, and `dcat-L037` Science include English grammar and comprehension. Statistics additionally receives the broader Mathematics union. `dcat-L040` Abstract Reasoning imports verbal and mechanical reasoning without evidence that this row describes them. `dcat-L041` Personality questionnaire imports English lessons despite the accepted packet explicitly withholding academic-subtest classification.
- `acet-L038` Mathematics imports English. `acet-L040` General Knowledge receives English despite the unknown syllabus. `acet-L041` Abstract Reasoning and `acet-L042` Essay receive broad neighboring reasoning families, including folding and matrices for the essay. The accepted packet does not establish those component skills.
- `ustet-L039` Mathematics and `ustet-L040` Science import English lessons. `ustet-L041` Mental Ability includes function lessons unrelated to its supported reasoning candidates.
- `sm-foundation-L045` Language Proficiency and `sm-foundation-L047` Nonverbal Reasoning share a large language/reasoning union. `sm-foundation-L046` Numerical Reasoning imports English and spatial lessons. `sm-foundation-L048` Science imports the Mathematics union merely because the historical report mentions a science-related numerical item, while separate Science scope remains unknown.
- `cse-professional-L033` and `cse-subprofessional-L045` General Information import English instruction from the language-of-area annotation. CSC's English delivery rule does not turn grammar/comprehension into General Information requirements.

Correction: treat the named area and language/cycle/format clauses separately. Aggregate only finer candidates actually assigned to that area's group in the accepted packet. Preserve unknown section boundaries and depth. For DCAT's personality questionnaire, assign no academic lesson requirement unless a separately accepted source establishes one. Use separate areas for UPCAT's language and reading domains. This is a level 1 association correction, not a demand to read lesson bodies or prove depth.

Source basis: each exact accepted packet record above, including its organizer/curriculum/weak label and citations. The packet qualifiers explicitly separate domain scope from language and unknown section status. Catalog titles provide no semantic connection from Science, Mathematics, General Information, or personality measurement to English grammar merely because English is named as delivery language.

### MAP-02: Substring and polysemous word links create false relevance

The following are concrete false connections, not merely uncertain depth:

- `cse-professional-L090/L097` word analogies and `L092/L099` conclusions link Atomic Structure, History of the Atom, and Matter. `cse-subprofessional-L116/L117` Constitution and R.A. 6713 do the same. `cse-subprofessional-L146` clerical prefixes/abbreviations/organizations links atomic chemistry and Genetics and Heredity. These catalog summaries concern physical particles, atomic models, matter, and inherited biological information. They do not concern relationships in words, legal provisions, organizations, or surname ordering.
- `cse-subprofessional-L118` international human-rights/environment instruments links Genetics and Heredity. The lesson concerns genetic inheritance, not the word fragment in international.
- `cse-professional-L098` tables/pie graphs links Acids, Bases, and pH. A competency-code character sequence is not a chemistry requirement.
- `cse-professional-L057` corruption links Ratio and Proportion and contextual rates. Public corruption is not numerical proportion.
- `cse-subprofessional-L137/L142` topic weights/item ranges link Springs and Weights and Geometry Measurement. Their summaries describe a physical spring and geometric formulas, not examination composition. `L147` warns against importing the Professional Analytical blueprint but links Geometry Measurement.
- `pupcet-L153` history/geography/cultural continuity links Basic Derivatives, Basic Integrals, and Limits and Continuity. Mathematical continuity is not continuity/change in history. It is the sole evidence row producing the PUPCET tag for those three calculus lessons.
- `sm-foundation-L096` STEM Pre-Calculus links those same three calculus lessons. The accepted record names conics, induction, advanced trigonometry, and polar coordinates, not calculus competencies. `dost-sei-L134` likewise imports basic-calculus lessons from a Pre-Calculus label. Keep actual calculus candidates tied to DOST's `L122/L135`, not this label.
- `upcat-L144`, `ustet-L114`, and `pupcet-L115` balanced chemical equations link Pulleys and Levers. Mechanical lever balance is not equation balancing.
- `dcat-L083`, `ustet-L124`, and `dost-sei-L058` translational/rotational physical motion link Mental Rotation and 3D Visualization. That summary concerns imagined object orientation, cube nets, and shadows, not dynamics of rotating objects.
- `acet-L127/L129`, `dost-sei-L058`, and `cse-subprofessional-L107` living systems, hydraulic systems, or ecosystem impacts link Systems of Equations. None of those clauses identifies simultaneous mathematical equations.
- `upcat-L060`, `dcat-L093`, `ustet-L063`, `pupcet-L059`, `dost-sei-L078`, and `cse-subprofessional-L094/L097` discourse patterns, sequence connectors, or event ordering link Number and Letter Sequences. That lesson's summary concerns finding numerical/letter rules, not ordering events or organizing discourse.
- `acet-L067/L069/L078`, `dcat-L051`, `ustet-L091`, and `sm-foundation-L094` mathematical modeling or variation link Measures of Central Tendency without a mean/median/mode facet.

Correction: remove those specific edges. Retain separately supported edges of the same lesson rather than deleting the lesson. Interpret complete words in the named subject and facet; word boundaries alone cannot repair continuity, balance, rotation, systems, model, or sequence. Re-derive tags from corrected edges. In particular, remove the CSE Subprofessional Springs and Weights tag, both CSE tags from atomic chemistry unless another valid accepted row supports them, and the PUPCET tags on the three calculus lessons. All current CSE atomic-chemistry evidence rows are unrelated clauses.

Source basis: exact accepted requirement records listed above and the independent inventory summaries. No external source extension is needed to distinguish these different meanings. No prerequisite claim was supplied that could justify the false links, and prerequisites belong to later review.

### MAP-03: Unknown source connections and limits are presented as positive support

- `ustet-L145` explicitly says no curriculum competency is assigned to Mental Ability without evidence of a connection. It is labeled `supported, curriculum` / `curriculum preparation`, assigned a positive status, and links Functions and Relations, Types of Functions, and Inferencing and Conclusions. The negative qualification does not provide curriculum support for that subtest.
- `cse-subprofessional-L137/L142/L147` are mix/depth/blueprint constraints, not teaching candidates. Their positive lesson links are specified in MAP-02.
- `dost-sei-L038` says the 2027 page does not confirm 2026 structure. It is classified as a `subject` with official subject-style confidence. Its literal text preserves the uncertainty and no edge exists, so this is a record-classification correction, not a claim that the human-readable map asserts current 2027 scope.

Correction: record these as unknown connection, cycle limit, or constraint/context. Keep any legitimate name candidates from separate supported rows. Do not treat organizer silence as exclusion. Keep DOST's 2026 domains historical and its 2027 continuity unknown.

### MAP-04: Direct named facets are omitted despite available name leads

- `upcat-L193` explicitly names circle properties but omits `lesson-geometry-circles`. Its inventory title and summary name circle parts, arcs, angles, sectors, and tangents. Add that name lead alongside the existing polygon/coordinate/measurement leads.
- `pupcet-L115` explicitly names gases but omits `lesson-chemistry-gas-laws`, whose title and summary describe pressure/volume/temperature/amount relationships. Add the candidate gas connection or explicitly say the source's gas facet is broader and remains unmatched. Do not infer teaching absence.
- `pupcet-L123` chemical reaction amounts maps chemistry structure/kinetics but omits Chemical Reactions and Stoichiometry, although their summaries name balancing and reaction quantities. Add the direct candidates or explicitly retain the unmatched quantity facet.
- `cse-subprofessional-L127` explicitly names graphs, but neither graph-analysis nor tables/charts lessons appear and no graph uncertainty is recorded. Link the direct graph-analysis candidate while retaining the reviewer's weak status.
- `dost-sei-L094` confirms five 2026 science domains but links only two Space Science lessons. Biology, Chemistry, Earth Science, and Physics have direct names and finer candidates elsewhere in that packet. `dost-sei-L122` names Algebra, Geometry, Trigonometry, Statistics, and Calculus but links only the last three families. Account for each named domain using its valid finer candidates or give it an explicit unassigned connection. The combined structure row is not a substitute for domain-level accounting.

Correction: retain each distinct facet. A global statement that all compound rows need body checking is appropriate but does not explain an omitted available name lead. These are level 1 matches only; they neither confirm teaching nor require a lesson-depth pass now.

### MAP-05: Uncertainty labels themselves confuse unrelated skills

- `dcat-L056`, `pupcet-L098`, and `dost-sei-L131` function composition receive the uncertainty `productive writing/essay teaching and worked composition`. Function composition is directly named in Functions and Relations' summary and the stored outline; it is not essay writing.
- `upcat-L186`, `acet-L067`, and `pupcet-L093` equations/systems in variables receive `inquiry design, variables/controls or microscope technique`. Mathematical variables are not controlled experimental variables.
- `ustet-L116` biological variation receives the mathematics label `variation/induction/polar-coordinate/proof methods as applicable`.
- `cse-subprofessional-L097` listened-to texts receive that same mathematics label. `dost-sei-L080` unfamiliar vocabulary/instructions also receives it. These do not provide evidence of mathematical induction.
- `upcat-L109` reading essays receives an essay-production uncertainty even though the source says read, not compose. Retain its actual unmatched play/text-type or language facets separately if needed.

Correction: remove these unrelated uncertainty strings and use the source's actual remaining facets. Keep valid qualifications about Filipino language, experimental design, writing production, advanced finance, and inferential statistics where the source actually calls for them. Conservative wording is not automatically correct when it describes a different skill.

## Representative independent matches for each exam

These comparisons were re-derived from the accepted requirement's action and independently read title/summary/outline detail before assessing the proposed link. They are naming leads only.

- UPCAT `L191`: prove/use Pythagoras maps to Triangles. The stored outline explicitly lists Pythagorean theorem and special right triangles; the summary names Pythagoras. This connection is valid curriculum preparation. `L193` additionally needs the direct Circles lead identified above.
- DCAT `L054`: center/radius, circle relationships, and coordinate distance supply Circles plus Coordinate Geometry leads. Their summaries and stored outline identify circle parts and distance formulas. The DCAT curriculum and weak-source limits remain intact. `L056` function composition is also a direct Functions and Relations lead, not essay uncertainty.
- ACET `L065`: unions, intersections, subsets, and Venn problems map to Sets and Set Notation. Both the title and summary identify those operations and diagrams. It remains curriculum preparation, not organizer-confirmed ACET scope. `L155` should not attach atomic chemistry to spatial relationships.
- USTET `L117`: Newton's laws, momentum, heat, waves/light, and electricity have direct separate Dynamics, Momentum and Impulse, Thermodynamics, Waves and Sound, Light and Optics, and Electricity and Magnetism leads. Summaries name those skills. Their tested depth remains unknown. `L145` cannot promote an explicitly unassigned curriculum connection.
- PUPCET `L118`: distance/speed/acceleration and motion graphs map to Kinematics; Newton's laws to Dynamics; momentum to Momentum and Impulse; projectile motion to Two-Dimensional Motion. The summaries and stored outline supply each link. Exam inclusion stays unknown. `L153` historical continuity supplies no calculus lead.
- DOST `L049`: visualize/rotate/disassemble objects maps to Mental Rotation and 3D Visualization. The summary and outline describe object rotation and cube nets. This is valid official 2026 sample/domain evidence, with 2027 continuity unknown. It does not justify using the same lesson for physical rotational motion in `L058`.
- SM `L075`: sentence completion and error identification map to the directly named lessons; synonym/antonym tasks map to Synonyms and Antonyms. Summaries describe completion, checking sentence errors, and contextual word relations. The historical weak report does not confirm 2026 inclusion. `L096` Pre-Calculus supplies no derivative/integral/limit method lead.
- CSE Professional `L093/L098`: interpreting tables/pie graphs maps to Tables and Charts, Data Analysis and Graph Interpretation, and Visual Media. The summaries identify quantitative tables/charts and graphic encoding. Acids, Bases, and pH is unrelated. CSE Professional's Analytical scope remains separate from Subprofessional Clerical scope.
- CSE Subprofessional `L080/L131`: filing maps to Alphabetic Filing Rules; numeric/date-based filing is a broader uncertain candidate under the official generic filing label. The summary correctly says follow a stated indexing convention, so it does not invent a universal detailed CSC rule. `L081/L132` supplies a direct English Spelling Rules lead. Unknown prefixes/surnames in `L146` supply no genetics or atomic-chemistry lead.

## Preserved valid qualifications and scope limits

- Every map states that names are leads and teaching, examples, prior knowledge, practice, and availability are deferred. No complete coverage, mastery, or teaching-absence conclusion is claimed.
- Detailed compound rows remain globally unconfirmed. The correction request concerns wrong or missing level 1 associations, not proof of body depth.
- Bilingual candidate metadata does not establish Filipino instruction. Mixed-language titles and the English-focused summaries justify partial language qualifiers. The existing Filipino-body uncertainty is appropriate where Filipino scope is actually sourced.
- DOST's accepted 2026 primer remains official historical evidence. The map text does not assert confirmed 2027 continuity. No new 2027 source research occurred.
- CSE Professional and Subprofessional remain separate packets and maps. Shared Numerical number-sequence and word-problem records were retained; the Professional-only Analytical blueprint was not accepted as Subprofessional scope. The erroneous Subprofessional Measurement link in that warning must still be removed.
- Broad scope with unknown depth may retain a suitable name lead. Correct uncertainty is not a defect. No unsupported exclusion is requested.

## Disposition

RESULT: FLAGS.

Task 4 independent map review is complete for the hashed 535-record snapshot. Mechanical accounting passes. Five semantic correction groups above require lead correction and focused independent recheck before map acceptance or publication of derived tags. Examples identify exact records; the collision groups are systemic, so the lead should reassess every affected vocabulary rule and resulting edge rather than fix only the examples. This does not reopen the accepted source gate.

Only this review file was written. The map targets were not edited. No git mutation, app/content/schema/importer edit, lesson-body read, question read, source research, computer control, overlap analysis, structure review, or standards review occurred. Level 2 remains unauthorized. Flutter checks are inapplicable to this documentation review; no app verification is claimed.

Final verification output:

```text
exact_packet_line_comparison=535 mismatches=0
hashed_inputs=26 changed_inputs=0
report_emdashes=0
RESULT_FLAGS_present=True
```


## Correction recheck, October 5, 2026

Recheck completed against the corrected map-input-manifest.json. Original findings above remain historical. Policy reread from main at cb48097bedf15bec2cfbe4fb3aa7e957753b1727. No scope or approval gate changed.

### Corrected input identity

SHA256 values independently recomputed, not copied from the manifest:

- `build_level1_maps.py`: `16208f7c0ad3b74e00d81c5ee9204293326d1e064766a3755841c9f830193d00`
- `requirement-map.json`: `61e1a02e1fbaa9dbba3f98885643ec2d3d0cbe820febdcc0525941af4cfc64a1`
- `lesson-exam-tags.json`: `c88ef277a58ba5ac76dd10d44f8423569c842eab21c2bd4383a543daece141f5`
- `outline-comparison.md`: `7d46f2202ccf63d9d175d7019c45a200b0350fa247dda191c051185608d2bddb`
- `maps/cse-subprofessional.md`: `43a33d80a6221f2eb3b550dd5fbe859117f3cae7364b1e5babf852523e82c876`
- `maps/dcat.md`: `4e07384a4628df956610e5546214baf80300a961ca5829d49c9b5e1fdee3a9dd`
- `maps/upcat.md`: `1824baaff9c95cc1b33ac7d04e33fc140093b936fae68a7e8b527620b339c95e`
- `maps/pupcet.md`: `2af05cdf9487fe55b8a040b6e43ad2516de6f1c808ec5f65e471b74bb021d986`
- `maps/dost-sei.md`: `90b279b2422fe770f1c33f00eeaa4175c8cdc170d4e5de8d169faeedc7880024`
- `maps/acet.md`: `197e55f74b3c0f98cec5c25239073ada21404369802a777a2d9eef828f4b98a5`
- `maps/cse-professional.md`: `ec2f3d4d18d6419c3b27fdcb97737d98dab64004eea46780e348e6da0b56714d`
- `maps/sm-foundation.md`: `468a060bcd8be04898f535705b0e20f29a85fab480daf266d8e088857cc5c38c`
- `maps/ustet.md`: `cc094c21d4f74a11450e13a3136833a5cd7238741758d06ef1c1ab68e2ce835a`
- `map-input-manifest.json`: `717c9b8abdb57d1f99551093b74f68cacb6a19bc19cdae95c7390717da8409ca`
- `map-input-manifest-first-draft.json`: `99f98f44a5a59e6cfaa5f481ab3ff4c55fd273665e81541b1b2b56e8d2b51d6c`
- `review/map-corrections.md`: `a5a18b1f86cba0065b6f491d39962ec2860af269677d9a5ff0400d6f15d518de`

### Recheck scope and actual output

I inspected the corrected connections, statuses, evidence classes, and uncertainty fields across all 535 records, not only the reported examples. The accepted requirement texts, acceptance record, inventory, and stored original captures remain byte-identical to the first review. The corrected manifest matches all 13 named targets. Its own hash and the correction-record hash are recorded above. The reviewer did not execute the generator or edit its targets.

```text
records=535
by_exam: UPCAT=114 DCAT=55 ACET=67 USTET=50 PUPCET=53 DOST=50 SM=50 CSE_Professional=45 CSE_Subprofessional=51
edges=2959
derived_lesson_exam_tags=822
statuses: CONTEXT=42 PARTIAL_NAME_LEADS=142 UNKNOWN=65 PROVISIONAL_NAME_LEADS=269 CONSTRAINT_OR_SOURCE_CONFLICT=7 APPARENT_GAP_OR_UNSPECIFIED_CONNECTION=10
manifest_files=13 manifest_mismatches=0
exact_packet_line_mismatches=0
rendered_exact_row_text_parity=True
complete_view_lesson_appearances=158
unknown_or_constraint_status_rows_with_edges=0
six_requested_direct_facet_cases=True
accepted_requirement_inventory_capture_changes=0
```

The corrected reconciliation distinguishes six stored subject records, five populated subjects, and an empty General Information placeholder. It also distinguishes the Google text's merged inference/fact-opinion bullet from the stored 141 lesson units. This fixes the reconciliation statement. The reference text and structured capture remain unchanged.

### Original finding closures and remaining scope

- MAP-01: delivery-language leakage is corrected in the named Science, Mathematics, and General Information rows. UPCAT Language Proficiency and Reading Comprehension now have distinct families. The DCAT personality questionnaire has zero academic edges. ACET Essay and the reported Abstract/Nonverbal parts have constrained families. Two remaining classification/domain-import examples are R1 below.
- MAP-02: the precise atomic-chemistry/CSE, Genetics/clerical, citation/pH, corruption/proportion, weights/springs, historical-continuity/calculus, Pre-Calculus/calculus, chemical-balance/pulleys, physical-rotation/mental-rotation, biological-systems/equations, and model/central-tendency examples are corrected. The PUPCET and SM tags on Basic Derivatives, Basic Integrals, and Limits and Continuity are removed. Those three lessons now have only DOST tags, from `dost-sei-L036/L122/L135`; `L135` is the actual accepted STEM calculus candidate, and the aggregate records retain historical 2026 limits. Residual meaning collisions remain in R2.
- MAP-03: USTET `L145`, DOST `L037/L038`, and CSE Subprofessional `L136/L137/L138/L142-L147` now have zero edges. Cycle and composition qualifications are preserved. Some explicit unknown connection statements still lack matching unknown classification, detailed in R1/R3. Nine unknown records retain an evidence-group string beginning `confirmed`, but their confidence and status explicitly say unknown; these do not themselves claim confirmed coverage. Aligning the evidence string would improve consistency.
- MAP-04: all six requested cases now contain the requested direct candidates: UPCAT circle properties; PUPCET gas and reaction quantities; CSE Subprofessional graphs; all five historical DOST science domains; and all five historical DOST mathematics domains. The aggregate DOST records explicitly defer tested depth and 2027 continuity. Additional direct-facet omissions found during the full recheck are R4.
- MAP-05: all listed false essay/function-composition, inquiry/mathematical-variable, biological-variation/mathematics, listened-text/mathematics, vocabulary/mathematics, and reading-essay/writing-production uncertainty strings are corrected. Proper Filipino, finance, experimental-design, and inference qualifications remain.

### Residual R1: Named-area/unknown records still import unrelated domains

- `acet-L043` states that boundaries between Reading Comprehension, Verbal Analogy, Logical Reasoning, Numerical Ability, and General Intelligence have unknown current official status. The record is still a positive reported subject with official-style confidence, and it imports Cell Biology, Cellular Metabolism, Characteristics of Life, Ecology, Matter, Plate Tectonics, Weather and Climate, Kinematics, and Work/Energy/Power from the General Knowledge grouping. None of those lesson titles matches the boundary question. Classify this record as an unknown boundary/context statement with zero edges. Retain separate provisional General Knowledge candidates in their actual sourced group.
- `ustet-L041/L141` Mental Ability retain `lesson-mechanical-technical-reasoning-fluid-pressure`. The only positive finer Mental Ability records, `L149/L150`, identify patterns/sequences and logical/spatial relationships. They contain no fluid/mechanical-pressure candidate. `L154` explicitly leaves mechanical inclusion unconfirmed and has no edges. Remove the fluid-pressure edges from the Mental Ability records. Its separate USTET science connection in `L124` may remain. This does not remove the exam tag from the lesson when a valid Science candidate independently supplies it.

### Residual R2: Meaning guards still miss several affected contexts

- `upcat-L057` English logical connectors and `pupcet-L077` logical relationships between reading ideas still link Syllogisms and Deductive Logic and Truth Tables and Propositional Logic. The metadata and outline distinguish formal proposition/syllogism reasoning from sentence cohesion and connectors. Remove the formal-logic links from these language clauses; retain the grammar/paragraph/reading leads and any separate formal-logic preparation rows.
- `pupcet-L059` text-development patterns and `dost-sei-L078` text patterns still link `lesson-logical-verbal-reasoning-number-and-letter-sequences`. These clauses concern text organization, not numerical/letter pattern rules. Remove that edge. The previously reported chronological/sequence examples are fixed, but this original pattern-context issue remains.
- `acet-L150`, `pupcet-L139`, and `sm-foundation-L118` logical operations still link Fractions/Decimals/Percentages, Order of Operations, and Properties of Real Numbers. AND/OR/NOT and proposition truth values are not arithmetic operations on numbers. The independently read summaries make this distinction explicit. Keep their valid formal-logic leads and remove the arithmetic trio from those clauses.
- `cse-subprofessional-L058` constitutional articles still links `lesson-text-types-essays-editorials-articles`. Legal constitutional articles are not news articles, editorials, essays, or opinion columns. Remove that text-type edge while retaining the direct constitutional lessons.
- `dcat-L071` a recalled separate statistics area still links `lesson-geometry-measurement`. Its summary concerns perimeter/area/surface area/volume. A testing area is not a geometric area. Remove that edge; retain the separately sourced Statistics family.
- `dost-sei-L058` physical translational/rotational motion still links `lesson-algebra-algebraic-expressions`. Its summary describes translating English sentences into mathematical expressions, not translational physical motion. Remove that edge; preserve its motion/machine/fluid leads.
- The new graph connection restores actual chart facets but also links function and motion graphs to `lesson-statistics-and-probability-data-analysis-graphs`, whose title/summary specifies pie charts, bar graphs, scatter plots, and numerical data interpretation. Function graphs in `upcat-L188/L189`, `dcat-L053`, `acet-L078`, `pupcet-L098`, and `dost-sei-L131` concern functions/polynomials/domain/range, already named in Functions and Relations or Types of Functions. Motion graphs in `upcat-L162`, `dcat-L082`, `ustet-L117`, `pupcet-L118`, `dost-sei-L054/L107`, and `sm-foundation-L139` concern position/speed/motion, already named in Kinematics. Do not attach a statistical-chart facet merely from the word graph. Remove the direct statistical Graph Analysis edges or explicitly distinguish a merely related, unconfirmed general graph-reading candidate from the actual function/motion skill. Numerical Tables and Charts may supply broad reading support, but that likewise cannot silently stand in for the missing graph-specific method. No lesson body inspection is required to preserve this naming distinction.

These corrections concern requirement edges. Most affected lessons have separate valid exam evidence, so corrections must preserve those tags. This is not a recommendation to delete any lesson.

### Residual R3: Explicitly missing curriculum support is classified as curriculum preparation

- `cse-subprofessional-L102` states specialized filing rules are unknown and no relevant DepEd competency was established. It remains `PROVISIONAL NAME LEADS`, evidence `supported, curriculum`, confidence `curriculum preparation`, with two filing edges.
- `cse-subprofessional-L108` states R.A. 6713-specific curriculum support is unknown and this curriculum pass does not establish provision-level teaching. It likewise remains positive curriculum preparation with four law-lesson edges.

Treat these as unknown curriculum connections with zero requirement edges, consistent with the corrected USTET `L145` handling. The separate organizer-confirmed filing and R.A. 6713 scope can still carry their appropriate provisional name leads. Unknown body depth is not the issue; the actual source record explicitly says the curriculum connection was not established.

### Residual R4: A direct name lead is still lost by phrase variation

- `upcat-L162` and `dost-sei-L100` explicitly name laws of motion, but omit `lesson-physics-dynamics`, whose independently read summary explicitly names Newton's laws and common forces. Add the direct Dynamics name candidate or mark the laws-of-motion facet separately unassigned. Kinematics describes motion, not its force-law explanation.
- `ustet-L123` names atomic and molecular structure, but omits `lesson-chemistry-atomic-structure` and supplies no separate atomic-structure uncertainty. Add its direct candidate while retaining the molecular/bonding leads. The insertion of "and molecular" between atomic and structure does not remove the atomic facet.

These are naming corrections only. They do not establish tested depth, teaching completeness, or universal curriculum exposure.

### Recheck disposition

RESULT: FLAGS for the corrected snapshot.

All 535 records were rechecked. Requested direct-facet and uncertainty-label corrections pass, and most first-review semantic defects are closed. R1-R4 remain and require correction plus a focused recheck before acceptance. The initial FLAGS and hashes above remain historical evidence; they are not current unresolved findings where this closure section says corrected. No required new source research, lesson reading, or later-level task follows from these flags.

Only this review document was updated. All map targets, accepted sources, original captures, content, app, importer, and schema remain unedited by the reviewer. No overlap/structure/standards work or Google writes occurred. Level 2 remains unauthorized.

Final correction-recheck verification:

```text
logical_arithmetic_residual=True
discourse_sequence_residual=True
graph_residual_examples=True
legal_article_residual=True
missing_dynamics_residual=True
missing_atomic_facet_residual=True
manifest_files_changed=0
report_emdashes=0
```
