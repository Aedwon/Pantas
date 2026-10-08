# Language Application structure audit

Status: COMPLETE author reading and findings, pending fresh independent review. Level3 only; no content changes.

## Identity and read log

Current main policy `1aaebad9814ba7bd9404d8b43fc010281abb97cf` matched live/cache. Audit startup `c74ea0f50d95b227bc91c99053f56cf530c983cd`; resumed live/local `c1b3766c7ca7c631e61b576c0c083df9f2549134`. Corpus `content/question-qa-r2` at `765c5dc0fa5586281047bf4f7b30d09ab3707887`, clean and read-only. Retrieved current policies; all nine mandatory blobs match prior full reads. Full approved spec, plan, later October4/5/8 decisions, ORCHESTRATOR, both briefs and reader contract control this assignment. Full accepted nine-exam requirements and relevant overlap notes were read; their unchanged identities preserve prior full reads.

Startup DRAFT preceded body reading; saved checkpoints after Error Identification, Paragraph Organization, and Sentence Completion. The two saved completed reads were preserved on resumption. Full ranges and SHA256 values are in the JSON lesson records: Error Identification1-86, Paragraph Organization1-93, Sentence Completion1-94. Narrow candidate-foundation read: `content/lessons/language-proficiency/grammar-and-structure/sentence-structure.md`1-101, SHA256 `ef876c783e5ff202618abfac958eb04c26367b048a5da47ba79c99c9d024c1a1`; inspected only to test dependency/reuse, with no coverage verdict for that topic.

## Findings and structure

- Retain the three distinct goals: edit a sentence, arrange supplied sentences, and complete a sentence. Each combines related checks for one application. Splitting every grammar category or merging all three would fragment or blur those decisions; no split is justified by their length. Structural use of L01/L17.
- Error Identification develops selected agreement cases and dangling-modifier repair. Pronoun-reference teaching is narrow; tense/aspect, parallelism, clause boundaries, punctuation and word-form checks mostly remain labels. They need category-specific local methods or optional foundation access before they can support broader teaching claims. Evidence: `content/lessons/language-proficiency/language-application/error-identification.md`14-24/30-60. B03/L01/L19 used for scope and instruction, not a Level4 compliance verdict.
- Paragraph Organization explains reference links, context-dependent transitions and global coherence. Its C-B-A-D chain models one arrangement; chronology/procedural ordering has no worked application. It teaches neither essay production nor claims/evidence/counterclaim evaluation. Evidence: `content/lessons/language-proficiency/language-application/paragraph-organization.md`16-24/30-65/69-73. L01/L19 structural use.
- Sentence Completion develops contrast, cause, coordinated blanks and one finite-verb selection. Collocation is a short list; the many grammar families at18 have no distinct methods. Evidence: `content/lessons/language-proficiency/language-application/sentence-completion.md`14-24/30-66. The blanket dismissal of other grammar-fit choices at66 needs usage/context qualification: [Cambridge collective agreement](https://dictionary.cambridge.org/grammar/british-grammar/nouns-singular-and-plural) permits plural committee agreement, while [Purdue agreement](https://owl.purdue.edu/owl/general_writing/grammar/subject_verb_agreement.html) presents singular agreement. Preserve the natural completed-event reading without making it a universal grammatical exclusion. The source ledger records the encountered concern.
- All three owned bodies teach and exemplify English only. Shared reasoning does not supply Filipino rules, vocabulary, connectors or worked applications. Actual Filipino forms in the narrow Sentence Structure source29-36 show why this is a local application gap, not a claim that the whole corpus lacks Filipino. Keep English and Filipino applicability separate.
- Reuse the short transition-meaning explanations between ordering and completion as a common concept/reference, while preserving paragraph links versus blank selection. Benefit: avoid competing mechanical transition rules. Cost: later targeted cross-reference/editing and independent review. Do not duplicate entire grammar lessons or collapse reading into writing. No change is made now.

## Scope and prerequisites

The [official2026 CSE-PPT announcement](https://csc.gov.ph/phocadownload/userupload/erpo/announcements/2026/ExamAnn_2026_03_Conduct%20of%2009%20Aug%202026%20CSE-PPT_orig%20signed.pdf), p7F, names the application tasks in a bilingual verbal area. That supports the shared English core, not a fixed task format, English/Filipino allocation, exact rule inventory or equal difficulty. Accepted [Professional](../requirements/cse-professional.md) and [Subprofessional](../requirements/cse-subprofessional.md) requirements remain distinct source records.

Other exam links retain official broad labels versus curriculum/weak preparation. DOST English evidence is2026;2027 continuity remains unknown. DCAT/ACET/PUPCET/SM current finer rosters remain uncertain. SHS completion/cohorts remain conditional. [ACET records](../requirements/acet.md) and [accepted essay comparison](../overlap/cet-scholarship-scope.md#essay-and-writing) leave the current exam essay weak/unknown; an application essay cannot establish it. Added Sentence Completion links for six exam packets are bounded English grammar/context preparation leads, not newly confirmed completion item types. All58 candidate requirement rows are accounted for by separate facets, not closed as whole requirements.

Necessary prerequisite edges: none. Explicit checked no-prerequisite list:

- `lesson-language-application-error-identification`
- `lesson-language-application-paragraph-organization`
- `lesson-language-application-sentence-completion`

The examples supply the operative agreement, attachment and discourse relationships. Error Identification's clause-boundary reminder lacks its own method; the existing Sentence Structure foundation explains clauses at14-20 and works classification at50-73, but these applications never count/classify clauses. That richer foundation remains optional preparation, not an indispensable edge inferred from a checklist name. Taught completion/ordering methods similarly explain the needed relations locally. Missing teaching components remain facet gaps; no absent-corpus foundation is asserted. No self-links, future-content links or authored-order assumptions.

No load-bearing figure dependency encountered. Runtime availability remains unknown; practice is deferred Level5. No illustration assessment, readability/style sweep, question reading, blind solve or full factual/standards pass occurred. Previous topic outputs remain immutable. Scoped attribution through the Dart scanner is not inherited as a pass: the lead canceled a nonreturning run with exit130; that scanner result remains unverified. Author evidence is supporting only; fresh semantic review and lead acceptance remain required.

## Actual author checks

The inline Python scoped check read the actual saved artifact, immutable packet/map/manifest and corpus files. Exit0:

```text
{
  "assignedIDs": 3,
  "lessonRecords": 3,
  "fullReadHashesAndRanges": 3,
  "facets": 58,
  "packetRequirementRefs": 58,
  "unaccountedPacketRefs": [],
  "uniqueRefs": 58,
  "referenceOccurrences": 421,
  "evidenceRangesChecked": 179,
  "strictEdges": 0,
  "selfLinks": 0,
  "cycles": 0,
  "bothEndEdgesToCheck": 0,
  "explicitNoPrerequisiteIDs": 3,
  "ledgerEntries": 8,
  "corpusHEAD": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "corpusDirty": false,
  "priorArtifactsChanged": [],
  "emDashes": 0,
  "trailingWhitespaceLines": 0,
  "scopedCreditMarkers": [],
  "errors": []
}
```

Shared supporting validator, `python3 docs/content/audit/coverage-r1/check_level3_outputs.py`, exit0. Snapshot below records combined author accounting only; gate readiness remains false:

```text
{
  "level": 3,
  "completeTopics": 13,
  "expectedTopics": 25,
  "completeLessons": 110,
  "expectedLessons": 158,
  "complete": [
    "language-proficiency-grammar-and-structure",
    "language-proficiency-language-application",
    "mathematics-algebra",
    "mathematics-arithmetic-number-sense",
    "mathematics-data-interpretation",
    "mathematics-geometry",
    "mathematics-precalculus-basic-calculus",
    "mathematics-statistics-and-probability",
    "mathematics-trigonometry",
    "science-biology",
    "science-chemistry",
    "science-earth-science-astronomy",
    "science-physics"
  ],
  "pending": [
    "general-information-code-of-conduct-ra-6713:NOT_STARTED",
    "general-information-environment-management:NOT_STARTED",
    "general-information-peace-and-human-rights:NOT_STARTED",
    "general-information-philippine-constitution:NOT_STARTED",
    "language-proficiency-vocabulary:DRAFT",
    "reading-comprehension-comprehension-skills:NOT_STARTED",
    "reading-comprehension-text-types:NOT_STARTED",
    "reasoning-clerical-ability:NOT_STARTED",
    "reasoning-logical-verbal-reasoning:NOT_STARTED",
    "reasoning-mechanical-technical-reasoning:NOT_STARTED",
    "reasoning-spatial-abstract-reasoning:NOT_STARTED",
    "reasoning-verbal-logic:NOT_STARTED"
  ],
  "errors": [],
  "mechanicalAccountingReady": false,
  "gateReady": false
}
```

`git diff --check -- docs/content/audit/coverage-r1/topics/language-proficiency-language-application-lessons.md` returned exit0 with no output. The direct text check also found no trailing whitespace, including any untracked content. The supplemental scoped credit-marker check is not a substitute for the unverified Dart policy scanner. All findings remain recommendations; no corpus edits or later-level work. After inserting the check record, final parse confirmed COMPLETE, 3 lessons, 58 facets, exactly one JSON appendix and zero pending placeholders. Shared validator again returned exit0, errors[], 13/25 topics and 110/158 lessons, with gateReady false.


## JSON appendix

```json
{
  "level": 3,
  "status": "COMPLETE",
  "subject": "language-proficiency",
  "topic": "language-application",
  "policyCommit": "1aaebad9814ba7bd9404d8b43fc010281abb97cf",
  "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "lessons": [
    {
      "id": "lesson-language-application-error-identification",
      "path": "content/lessons/language-proficiency/language-application/error-identification.md",
      "sha256": "db4dd522670e7b6c9b87126fc6cbf0500cbdfbe89e5b6c338697bca055c50db9",
      "readLines": [
        1,
        86
      ],
      "goal": "Identify a specific English sentence error, or accept a correct sentence, using grammatical evidence.",
      "skills": [
        {
          "name": "Find subject and finite-verb agreement errors",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                16,
                16
              ],
              "note": "Agreement check"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                30,
                44
              ],
              "note": "Singular each and plural committee members; interrupting phrase excluded"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                48,
                52
              ],
              "note": "Proximity agreement with neither/nor"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                30,
                36
              ],
              "note": "Each has, singular their retained"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                40,
                44
              ],
              "note": "Committee members were"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                48,
                52
              ],
              "note": "Accept correct neither/nor sentence"
            }
          ],
          "requirementRefs": [
            "acet-L101",
            "cse-professional-L071",
            "cse-professional-L077",
            "cse-subprofessional-L067",
            "cse-subprofessional-L068",
            "cse-subprofessional-L095",
            "dost-sei-L072",
            "dost-sei-L076",
            "upcat-L069",
            "upcat-L072",
            "sm-foundation-L066"
          ],
          "limitations": [
            "Examples teach these English cases; subject/finite verb labels do not provide general clause parsing."
          ]
        },
        {
          "name": "Check pronoun reference and number; recognize singular their",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                17,
                17
              ],
              "note": "Diagnostic question"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                34,
                36
              ],
              "note": "Singular their retained as standard"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                76,
                78
              ],
              "note": "Accepted variation"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                30,
                36
              ],
              "note": "Agreement correction does not change their"
            }
          ],
          "requirementRefs": [
            "cse-professional-L082",
            "cse-subprofessional-L122"
          ],
          "limitations": [
            "No unclear-antecedent or pronoun-number repair method/example."
          ]
        },
        {
          "name": "Detect and repair dangling modifiers",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                19,
                19
              ],
              "note": "Attachment diagnostic"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                56,
                60
              ],
              "note": "Identify wrong grammatical subject and rewrite using Maria"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                56,
                60
              ],
              "note": "Umbrella/Maria attachment repair"
            }
          ],
          "requirementRefs": [
            "upcat-L071",
            "upcat-L072",
            "upcat-L074"
          ],
          "limitations": [
            "English example only; not Filipino bahagi ng pananalita or wastong gamit instruction."
          ]
        },
        {
          "name": "Diagnose tense and aspect consistency",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                18,
                18
              ],
              "note": "Timeline question without rule"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L092",
            "sm-foundation-L066",
            "upcat-L057",
            "cse-professional-L082",
            "cse-subprofessional-L095",
            "cse-subprofessional-L122"
          ],
          "limitations": [
            "Past versus past-perfect/aspect selection not developed."
          ]
        },
        {
          "name": "Diagnose parallel structure",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                20,
                20
              ],
              "note": "Structural compatibility question"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L101",
            "dcat-L091",
            "dost-sei-L076",
            "cse-professional-L077",
            "cse-subprofessional-L122",
            "upcat-L058"
          ],
          "limitations": [
            "No comparison/coordination construction or repair."
          ]
        },
        {
          "name": "Diagnose clause boundaries and punctuation",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                21,
                21
              ],
              "note": "Independent/dependent clause question"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                64,
                64
              ],
              "note": "Find boundaries first"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "ustet-L058",
            "upcat-L057",
            "upcat-L071",
            "sm-foundation-L066",
            "cse-professional-L082",
            "cse-subprofessional-L122"
          ],
          "limitations": [
            "Run-ons, comma splices, capitalization and linking rules not taught here."
          ]
        },
        {
          "name": "Check word form and usage",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                22,
                24
              ],
              "note": "Form/meaning check and specific-error standard"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L110",
            "dcat-L096",
            "dost-sei-L072",
            "pupcet-L063",
            "ustet-L069"
          ],
          "limitations": [
            "No part-of-speech selection or vocabulary repair example."
          ]
        },
        {
          "name": "Use an evidence-based editing checklist without invented format rules",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                12,
                24
              ],
              "note": "Scope caution and checklist"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                64,
                86
              ],
              "note": "No frequency ranking, exactly-one-error or universal no-change assumption"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/error-identification.md",
              "lines": [
                48,
                52
              ],
              "note": "Correct sentence accepted with grammatical reason"
            }
          ],
          "requirementRefs": [
            "cse-professional-L071",
            "cse-subprofessional-L067",
            "upcat-L072",
            "sm-foundation-L075"
          ],
          "limitations": [
            "Current CSC2026 PPT scope supports named task only; no format or frequency inference."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L101",
            "acet-L110"
          ],
          "sharedCore": "English editing routine, selected agreement cases and dangling-modifier repair.",
          "partialLimits": "Checklist-only grammar facets are not full teaching; no Filipino teaching or whole compound requirement closure.",
          "depth": "unknown: named task or curriculum/weak preparation does not establish tested rules or difficulty",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain bounded English preparation; restrict unsupported Filipino and untaught component claims."
        },
        {
          "exam": "cse-professional",
          "requirementRefs": [
            "cse-professional-L071",
            "cse-professional-L077",
            "cse-professional-L080",
            "cse-professional-L082"
          ],
          "sharedCore": "English editing routine, selected agreement cases and dangling-modifier repair.",
          "partialLimits": "Checklist-only grammar facets are not full teaching; no Filipino teaching or whole compound requirement closure.",
          "depth": "unknown: named task or curriculum/weak preparation does not establish tested rules or difficulty",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain bounded English preparation; restrict unsupported Filipino and untaught component claims."
        },
        {
          "exam": "cse-subprofessional",
          "requirementRefs": [
            "cse-subprofessional-L067",
            "cse-subprofessional-L068",
            "cse-subprofessional-L095",
            "cse-subprofessional-L096",
            "cse-subprofessional-L122"
          ],
          "sharedCore": "English editing routine, selected agreement cases and dangling-modifier repair.",
          "partialLimits": "Checklist-only grammar facets are not full teaching; no Filipino teaching or whole compound requirement closure.",
          "depth": "unknown: named task or curriculum/weak preparation does not establish tested rules or difficulty",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain bounded English preparation; restrict unsupported Filipino and untaught component claims."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L091",
            "dcat-L092",
            "dcat-L096"
          ],
          "sharedCore": "English editing routine, selected agreement cases and dangling-modifier repair.",
          "partialLimits": "Checklist-only grammar facets are not full teaching; no Filipino teaching or whole compound requirement closure.",
          "depth": "unknown: named task or curriculum/weak preparation does not establish tested rules or difficulty",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain bounded English preparation; restrict unsupported Filipino and untaught component claims."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L072",
            "dost-sei-L076"
          ],
          "sharedCore": "English editing routine, selected agreement cases and dangling-modifier repair.",
          "partialLimits": "Checklist-only grammar facets are not full teaching; no Filipino teaching or whole compound requirement closure.",
          "depth": "unknown: named task or curriculum/weak preparation does not establish tested rules or difficulty",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain bounded English preparation; restrict unsupported Filipino and untaught component claims."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L063",
            "pupcet-L076",
            "pupcet-L081"
          ],
          "sharedCore": "English editing routine, selected agreement cases and dangling-modifier repair.",
          "partialLimits": "Checklist-only grammar facets are not full teaching; no Filipino teaching or whole compound requirement closure.",
          "depth": "unknown: named task or curriculum/weak preparation does not establish tested rules or difficulty",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain bounded English preparation; restrict unsupported Filipino and untaught component claims."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L066",
            "sm-foundation-L075",
            "sm-foundation-L076"
          ],
          "sharedCore": "English editing routine, selected agreement cases and dangling-modifier repair.",
          "partialLimits": "Checklist-only grammar facets are not full teaching; no Filipino teaching or whole compound requirement closure.",
          "depth": "unknown: named task or curriculum/weak preparation does not establish tested rules or difficulty",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain bounded English preparation; restrict unsupported Filipino and untaught component claims."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L050",
            "upcat-L057",
            "upcat-L069",
            "upcat-L071",
            "upcat-L072",
            "upcat-L073",
            "upcat-L074"
          ],
          "sharedCore": "English editing routine, selected agreement cases and dangling-modifier repair.",
          "partialLimits": "Checklist-only grammar facets are not full teaching; no Filipino teaching or whole compound requirement closure.",
          "depth": "unknown: named task or curriculum/weak preparation does not establish tested rules or difficulty",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain bounded English preparation; restrict unsupported Filipino and untaught component claims."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L051",
            "ustet-L058",
            "ustet-L069"
          ],
          "sharedCore": "English editing routine, selected agreement cases and dangling-modifier repair.",
          "partialLimits": "Checklist-only grammar facets are not full teaching; no Filipino teaching or whole compound requirement closure.",
          "depth": "unknown: named task or curriculum/weak preparation does not establish tested rules or difficulty",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain bounded English preparation; restrict unsupported Filipino and untaught component claims."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The checklist and focused examples form a coherent editing routine. Named categories need local method development or optional foundation access, not a split by every category.",
        "evidence": [
          {
            "path": "content/lessons/language-proficiency/language-application/error-identification.md",
            "lines": [
              14,
              24
            ],
            "note": "Diagnostic checklist"
          },
          {
            "path": "content/lessons/language-proficiency/language-application/error-identification.md",
            "lines": [
              28,
              60
            ],
            "note": "Focused examples"
          }
        ],
        "proposal": "Retain English editing goal; label checklist items as reminders and supply category-specific instruction when later content work is approved.",
        "cost": "Later authoring/review of methods and bilingual counterparts; no content change now."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-language-application-paragraph-organization",
      "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
      "sha256": "0d31c7024268d90892f29464e198c7152ca677c959ba650146fc1cb12bb4ff3e",
      "readLines": [
        1,
        93
      ],
      "goal": "Arrange a self-contained set of English sentences into a coherent paragraph using meaning and reference.",
      "skills": [
        {
          "name": "Choose an orienting opening without treating it as a universal topic-sentence rule",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                16,
                16
              ],
              "note": "Orientation criterion and rhetorical exceptions"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                71,
                73
              ],
              "note": "Verify whole sequence"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                87,
                89
              ],
              "note": "Narrative/rhetorical limit"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                30,
                39
              ],
              "note": "C introduces topic without unsupported backward reference"
            }
          ],
          "requirementRefs": [
            "cse-professional-L072",
            "cse-subprofessional-L069",
            "acet-L170",
            "dcat-L093",
            "ustet-L063",
            "sm-foundation-L069"
          ],
          "limitations": [
            "Arranging supplied sentences is not drafting a topic sentence or full essay."
          ]
        },
        {
          "name": "Track backward reference and cohesive links",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                18,
                18
              ],
              "note": "Reference depends on text/context"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                69,
                73
              ],
              "note": "Link and global check method"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                77,
                81
              ],
              "note": "Pronoun-first exception"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                30,
                57
              ],
              "note": "Resources to competition to conflicts to wars, C-B-A-D"
            }
          ],
          "requirementRefs": [
            "upcat-L058",
            "dcat-L091",
            "acet-L101",
            "ustet-L059",
            "ustet-L065",
            "pupcet-L058",
            "pupcet-L077",
            "dost-sei-L076",
            "cse-professional-L077",
            "sm-foundation-L066"
          ],
          "limitations": [
            "English demonstratives only; Filipino cohesive devices not taught."
          ]
        },
        {
          "name": "Use transition meaning instead of fixed sentence positions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                20,
                20
              ],
              "note": "Meaning relation can reach broader earlier idea"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                83,
                85
              ],
              "note": "Contrast/result/illustration meanings"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                59,
                65
              ],
              "note": "However signals contrast but not unique preceding sentence"
            }
          ],
          "requirementRefs": [
            "upcat-L057",
            "upcat-L058",
            "dcat-L091",
            "acet-L101",
            "pupcet-L058",
            "dost-sei-L076",
            "sm-foundation-L066",
            "ustet-L059",
            "cse-professional-L077"
          ],
          "limitations": [
            "However developed; no worked result or illustration sequence."
          ]
        },
        {
          "name": "Order chronology or a procedure",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                22,
                22
              ],
              "note": "Time/sequence markers"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                69,
                69
              ],
              "note": "Mark chronology"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L060",
            "pupcet-L076",
            "cse-subprofessional-L097"
          ],
          "limitations": [
            "No timed/procedural sequence example; cited curriculum facets specifically Filipino, while this body is English."
          ]
        },
        {
          "name": "Use cause/effect chain while allowing effect-first discourse",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                24,
                24
              ],
              "note": "Follow discourse signals"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                91,
                93
              ],
              "note": "Effect-first possibility"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                47,
                57
              ],
              "note": "Competition precedes linked conflicts and wars"
            }
          ],
          "requirementRefs": [
            "cse-professional-L080",
            "cse-subprofessional-L097",
            "upcat-L060",
            "pupcet-L076"
          ],
          "limitations": [
            "One English chain; no Filipino causal or narrative connector teaching and no worked effect-first arrangement."
          ]
        },
        {
          "name": "Test global coherence after building local pairs",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                69,
                73
              ],
              "note": "Link, orient and test full paragraph"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
              "lines": [
                39,
                57
              ],
              "note": "Each step produces a complete four-sentence sequence"
            }
          ],
          "requirementRefs": [
            "cse-professional-L072",
            "cse-subprofessional-L069",
            "acet-L170",
            "dcat-L093",
            "ustet-L063",
            "sm-foundation-L069"
          ],
          "limitations": [
            "One extended worked chain; transfer to varied text-development patterns not demonstrated."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L101",
            "acet-L170",
            "acet-L171"
          ],
          "sharedCore": "English supplied-sentence ordering, reference links and transition meaning.",
          "partialLimits": "No Filipino counterpart, essay composition, textual-evidence evaluation, broad genre/academic-writing or complete compound reading coverage.",
          "depth": "unknown: exact exam task formats and depth not established by curriculum leads",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain ordering/cohesion preparation and distinguish it from production and other compound facets."
        },
        {
          "exam": "cse-professional",
          "requirementRefs": [
            "cse-professional-L072",
            "cse-professional-L077",
            "cse-professional-L080"
          ],
          "sharedCore": "English supplied-sentence ordering, reference links and transition meaning.",
          "partialLimits": "No Filipino counterpart, essay composition, textual-evidence evaluation, broad genre/academic-writing or complete compound reading coverage.",
          "depth": "unknown: exact exam task formats and depth not established by curriculum leads",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain ordering/cohesion preparation and distinguish it from production and other compound facets."
        },
        {
          "exam": "cse-subprofessional",
          "requirementRefs": [
            "cse-subprofessional-L069",
            "cse-subprofessional-L097"
          ],
          "sharedCore": "English supplied-sentence ordering, reference links and transition meaning.",
          "partialLimits": "No Filipino counterpart, essay composition, textual-evidence evaluation, broad genre/academic-writing or complete compound reading coverage.",
          "depth": "unknown: exact exam task formats and depth not established by curriculum leads",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain ordering/cohesion preparation and distinguish it from production and other compound facets."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L091",
            "dcat-L093"
          ],
          "sharedCore": "English supplied-sentence ordering, reference links and transition meaning.",
          "partialLimits": "No Filipino counterpart, essay composition, textual-evidence evaluation, broad genre/academic-writing or complete compound reading coverage.",
          "depth": "unknown: exact exam task formats and depth not established by curriculum leads",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain ordering/cohesion preparation and distinguish it from production and other compound facets."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L076"
          ],
          "sharedCore": "English supplied-sentence ordering, reference links and transition meaning.",
          "partialLimits": "No Filipino counterpart, essay composition, textual-evidence evaluation, broad genre/academic-writing or complete compound reading coverage.",
          "depth": "unknown: exact exam task formats and depth not established by curriculum leads",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain ordering/cohesion preparation and distinguish it from production and other compound facets."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L058",
            "pupcet-L076",
            "pupcet-L077"
          ],
          "sharedCore": "English supplied-sentence ordering, reference links and transition meaning.",
          "partialLimits": "No Filipino counterpart, essay composition, textual-evidence evaluation, broad genre/academic-writing or complete compound reading coverage.",
          "depth": "unknown: exact exam task formats and depth not established by curriculum leads",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain ordering/cohesion preparation and distinguish it from production and other compound facets."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L066",
            "sm-foundation-L069"
          ],
          "sharedCore": "English supplied-sentence ordering, reference links and transition meaning.",
          "partialLimits": "No Filipino counterpart, essay composition, textual-evidence evaluation, broad genre/academic-writing or complete compound reading coverage.",
          "depth": "unknown: exact exam task formats and depth not established by curriculum leads",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain ordering/cohesion preparation and distinguish it from production and other compound facets."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L050",
            "upcat-L057",
            "upcat-L058",
            "upcat-L060",
            "upcat-L075"
          ],
          "sharedCore": "English supplied-sentence ordering, reference links and transition meaning.",
          "partialLimits": "No Filipino counterpart, essay composition, textual-evidence evaluation, broad genre/academic-writing or complete compound reading coverage.",
          "depth": "unknown: exact exam task formats and depth not established by curriculum leads",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain ordering/cohesion preparation and distinguish it from production and other compound facets."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L051",
            "ustet-L059",
            "ustet-L063",
            "ustet-L065"
          ],
          "sharedCore": "English supplied-sentence ordering, reference links and transition meaning.",
          "partialLimits": "No Filipino counterpart, essay composition, textual-evidence evaluation, broad genre/academic-writing or complete compound reading coverage.",
          "depth": "unknown: exact exam task formats and depth not established by curriculum leads",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain ordering/cohesion preparation and distinguish it from production and other compound facets."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The linked worked chain and however discussion have one clear ordering goal; splitting would fragment the method.",
        "evidence": [
          {
            "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
            "lines": [
              14,
              24
            ],
            "note": "Complementary ordering clues"
          },
          {
            "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
            "lines": [
              28,
              65
            ],
            "note": "Connected ordering sequence and context-dependent transition"
          }
        ],
        "proposal": "Keep ordering as its own shared English core; later add separate chronological/procedural and Filipino applications without labeling it essay instruction.",
        "cost": "Later examples and language-specific review; no current corpus change."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-language-application-sentence-completion",
      "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
      "sha256": "8f7f4249fdb388a2ca20a1a6d54ffaa0dc6371609193a936fe22a6e1b6327901",
      "readLines": [
        1,
        94
      ],
      "goal": "Choose a coherent English sentence completion by combining discourse meaning, grammatical form and word combination.",
      "skills": [
        {
          "name": "Interpret concession/contrast and cause clues",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                16,
                16
              ],
              "note": "Discourse relations not automatic polarity switches"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                72,
                72
              ],
              "note": "Although, because, therefore meanings"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                30,
                36
              ],
              "note": "Rain forecast versus successful event"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                40,
                46
              ],
              "note": "Damage supports unsafe"
            }
          ],
          "requirementRefs": [
            "cse-professional-L070",
            "cse-subprofessional-L066",
            "sm-foundation-L075",
            "upcat-L057",
            "dost-sei-L072",
            "acet-L110",
            "ustet-L069"
          ],
          "limitations": [
            "Result/illustration are mentioned but not worked; test inclusion beyond CSE is a bounded preparation lead."
          ]
        },
        {
          "name": "Coordinate two blanks and verify whole-sentence meaning",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                22,
                24
              ],
              "note": "Whole sentence and constrained-blank strategy"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                92,
                94
              ],
              "note": "Pair/set coherence"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                50,
                56
              ],
              "note": "Thorough preparation versus nervous response"
            }
          ],
          "requirementRefs": [
            "cse-professional-L070",
            "cse-subprofessional-L066",
            "sm-foundation-L075"
          ],
          "limitations": [
            "Does not establish a guaranteed multi-blank exam format."
          ]
        },
        {
          "name": "Supply a finite verb fitting the sentence context",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                18,
                18
              ],
              "note": "Grammar category/form check"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                60,
                66
              ],
              "note": "Completed event interpretation; rejects time-phrase automation"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                88,
                90
              ],
              "note": "Timeline/context caution"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                60,
                66
              ],
              "note": "Approved as natural completed-event finite verb"
            }
          ],
          "requirementRefs": [
            "cse-professional-L070",
            "cse-subprofessional-L066",
            "sm-foundation-L075",
            "upcat-L057",
            "dost-sei-L072",
            "pupcet-L063"
          ],
          "limitations": [
            "Finite verb is named rather than generally defined; only selected context is modeled. Blanket exclusion of approve needs dialect/collective-agreement qualification."
          ]
        },
        {
          "name": "Recognize collocations and idiomatic combinations",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                20,
                20
              ],
              "note": "Strong evidence, make a decision, interested in"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                74,
                74
              ],
              "note": "Check idiomatic combination"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L058",
            "dcat-L091",
            "acet-L110",
            "dost-sei-L072"
          ],
          "limitations": [
            "Combinations are supplied without a worked elimination comparison; idiom interpretation is not developed."
          ]
        },
        {
          "name": "Use agreement, aspect, complementation, articles, prepositions and parallelism to eliminate choices",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                18,
                18
              ],
              "note": "Grammar categories listed"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                70,
                70
              ],
              "note": "Predict category and meaning"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                60,
                66
              ],
              "note": "One finite-verb form selection"
            }
          ],
          "requirementRefs": [
            "acet-L101",
            "dost-sei-L076",
            "upcat-L057",
            "upcat-L058",
            "pupcet-L063"
          ],
          "limitations": [
            "Finite-verb example does not teach listed rule families; most have no distinct procedure or application."
          ]
        },
        {
          "name": "Check meaning and grammar together without mechanical tense/transition rules",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                12,
                24
              ],
              "note": "Joint coherence criteria"
            },
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                70,
                90
              ],
              "note": "Predict, read completed sentence, avoid mechanical switches"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
              "lines": [
                30,
                66
              ],
              "note": "Contrast, cause, pair and finite-verb examples"
            }
          ],
          "requirementRefs": [
            "cse-professional-L070",
            "cse-subprofessional-L066",
            "sm-foundation-L075",
            "dcat-L096",
            "acet-L110",
            "ustet-L069"
          ],
          "limitations": [
            "All teaching/examples English; Filipino completion not present."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "cse-professional",
          "requirementRefs": [
            "cse-professional-L070"
          ],
          "sharedCore": "English completion through discourse meaning and limited grammatical fit.",
          "partialLimits": "No Filipino completion, systematic grammar-family rules, lexical-idiom interpretation or full vocabulary/reading instruction. Added CET/DOST rows are preparation facets, not verified completion item types.",
          "depth": "unknown: exact vocabulary/rule depth and item format not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Official2026 PPT sentence-completion task supports English core, not bilingual completion coverage."
        },
        {
          "exam": "cse-subprofessional",
          "requirementRefs": [
            "cse-subprofessional-L066"
          ],
          "sharedCore": "English completion through discourse meaning and limited grammatical fit.",
          "partialLimits": "No Filipino completion, systematic grammar-family rules, lexical-idiom interpretation or full vocabulary/reading instruction. Added CET/DOST rows are preparation facets, not verified completion item types.",
          "depth": "unknown: exact vocabulary/rule depth and item format not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Official2026 PPT sentence-completion task supports English core, not bilingual completion coverage."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L075"
          ],
          "sharedCore": "English completion through discourse meaning and limited grammatical fit.",
          "partialLimits": "No Filipino completion, systematic grammar-family rules, lexical-idiom interpretation or full vocabulary/reading instruction. Added CET/DOST rows are preparation facets, not verified completion item types.",
          "depth": "unknown: exact vocabulary/rule depth and item format not established",
          "tagRecommendation": "uncertain",
          "reason": "Historical weak sentence-completion report; current inclusion/language unknown."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L050",
            "upcat-L057",
            "upcat-L058"
          ],
          "sharedCore": "English completion through discourse meaning and limited grammatical fit.",
          "partialLimits": "No Filipino completion, systematic grammar-family rules, lexical-idiom interpretation or full vocabulary/reading instruction. Added CET/DOST rows are preparation facets, not verified completion item types.",
          "depth": "unknown: exact vocabulary/rule depth and item format not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Unassigned English context/grammar leads justify bounded preparation review, not a new whole-lesson exam claim."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L091",
            "dcat-L096"
          ],
          "sharedCore": "English completion through discourse meaning and limited grammatical fit.",
          "partialLimits": "No Filipino completion, systematic grammar-family rules, lexical-idiom interpretation or full vocabulary/reading instruction. Added CET/DOST rows are preparation facets, not verified completion item types.",
          "depth": "unknown: exact vocabulary/rule depth and item format not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Unassigned English context/grammar leads justify bounded preparation review, not a new whole-lesson exam claim."
        },
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L101",
            "acet-L110"
          ],
          "sharedCore": "English completion through discourse meaning and limited grammatical fit.",
          "partialLimits": "No Filipino completion, systematic grammar-family rules, lexical-idiom interpretation or full vocabulary/reading instruction. Added CET/DOST rows are preparation facets, not verified completion item types.",
          "depth": "unknown: exact vocabulary/rule depth and item format not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Unassigned English context/grammar leads justify bounded preparation review, not a new whole-lesson exam claim."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L051",
            "ustet-L069"
          ],
          "sharedCore": "English completion through discourse meaning and limited grammatical fit.",
          "partialLimits": "No Filipino completion, systematic grammar-family rules, lexical-idiom interpretation or full vocabulary/reading instruction. Added CET/DOST rows are preparation facets, not verified completion item types.",
          "depth": "unknown: exact vocabulary/rule depth and item format not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Unassigned English context/grammar leads justify bounded preparation review, not a new whole-lesson exam claim."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L063"
          ],
          "sharedCore": "English completion through discourse meaning and limited grammatical fit.",
          "partialLimits": "No Filipino completion, systematic grammar-family rules, lexical-idiom interpretation or full vocabulary/reading instruction. Added CET/DOST rows are preparation facets, not verified completion item types.",
          "depth": "unknown: exact vocabulary/rule depth and item format not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Unassigned English context/grammar leads justify bounded preparation review, not a new whole-lesson exam claim."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L072",
            "dost-sei-L076"
          ],
          "sharedCore": "English completion through discourse meaning and limited grammatical fit.",
          "partialLimits": "No Filipino completion, systematic grammar-family rules, lexical-idiom interpretation or full vocabulary/reading instruction. Added CET/DOST rows are preparation facets, not verified completion item types.",
          "depth": "unknown: 2026 English domain confirmed, 2027 continuity and completion formats unknown",
          "tagRecommendation": "revise-candidate",
          "reason": "Unassigned English context/grammar leads justify bounded preparation review, not a new whole-lesson exam claim."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Meaning, form and whole-sentence checks contribute to one completion goal; separating them would weaken the combined decision method.",
        "evidence": [
          {
            "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
            "lines": [
              12,
              24
            ],
            "note": "Integrated decision method"
          },
          {
            "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
            "lines": [
              28,
              66
            ],
            "note": "Distinct example applications"
          }
        ],
        "proposal": "Retain as shared English application core; optional brief access to word-context and grammar instruction can support untaught rule families. Keep language-specific additions separate.",
        "cost": "Later targeted methods/examples and review; avoid duplicating entire grammar/vocabulary lessons."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    }
  ],
  "requirementFacets": [
    {
      "requirementRefs": [
        "acet-L101",
        "cse-professional-L071",
        "cse-professional-L077",
        "cse-subprofessional-L067",
        "cse-subprofessional-L068",
        "cse-subprofessional-L095",
        "dost-sei-L072",
        "dost-sei-L076",
        "upcat-L069",
        "upcat-L072",
        "sm-foundation-L066"
      ],
      "facet": "English: Find subject and finite-verb agreement errors",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            16,
            16
          ],
          "note": "Agreement check"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            30,
            44
          ],
          "note": "Singular each and plural committee members; interrupting phrase excluded"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            48,
            52
          ],
          "note": "Proximity agreement with neither/nor"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            30,
            36
          ],
          "note": "Each has, singular their retained"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            40,
            44
          ],
          "note": "Committee members were"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            48,
            52
          ],
          "note": "Accept correct neither/nor sentence"
        }
      ],
      "missingIdeas": [
        "Examples teach these English cases; subject/finite verb labels do not provide general clause parsing."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: Each has, singular their retained; Committee members were; Accept correct neither/nor sentence",
      "scopeLimit": "acet: curriculum preparation; cse-professional: official domain/skill; see exact qualifiers; cse-professional: curriculum preparation; cse-subprofessional: official domain/skill; see exact qualifiers; cse-subprofessional: curriculum preparation; dost-sei: official domain/skill; see exact qualifiers; dost-sei: curriculum preparation; upcat: weak preparation; sm-foundation: curriculum preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L082",
        "cse-subprofessional-L122"
      ],
      "facet": "English: Check pronoun reference and number; recognize singular their",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            17,
            17
          ],
          "note": "Diagnostic question"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            34,
            36
          ],
          "note": "Singular their retained as standard"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            76,
            78
          ],
          "note": "Accepted variation"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            30,
            36
          ],
          "note": "Agreement correction does not change their"
        }
      ],
      "missingIdeas": [
        "No unclear-antecedent or pronoun-number repair method/example."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "thin: Agreement correction does not change their",
      "scopeLimit": "cse-professional: weak preparation; cse-subprofessional: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L071",
        "upcat-L072",
        "upcat-L074"
      ],
      "facet": "English: Detect and repair dangling modifiers",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            19,
            19
          ],
          "note": "Attachment diagnostic"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            56,
            60
          ],
          "note": "Identify wrong grammatical subject and rewrite using Maria"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            56,
            60
          ],
          "note": "Umbrella/Maria attachment repair"
        }
      ],
      "missingIdeas": [
        "English example only; not Filipino bahagi ng pananalita or wastong gamit instruction."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: Umbrella/Maria attachment repair",
      "scopeLimit": "upcat: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "dcat-L092",
        "sm-foundation-L066",
        "upcat-L057",
        "cse-professional-L082",
        "cse-subprofessional-L095",
        "cse-subprofessional-L122"
      ],
      "facet": "English: Diagnose tense and aspect consistency",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            18,
            18
          ],
          "note": "Timeline question without rule"
        }
      ],
      "missingIdeas": [
        "Past versus past-perfect/aspect selection not developed."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "none: ",
      "scopeLimit": "dcat: curriculum preparation; sm-foundation: curriculum preparation; upcat: curriculum preparation; cse-professional: weak preparation; cse-subprofessional: curriculum preparation; cse-subprofessional: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "acet-L101",
        "dcat-L091",
        "dost-sei-L076",
        "cse-professional-L077",
        "cse-subprofessional-L122",
        "upcat-L058"
      ],
      "facet": "English: Diagnose parallel structure",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            20,
            20
          ],
          "note": "Structural compatibility question"
        }
      ],
      "missingIdeas": [
        "No comparison/coordination construction or repair."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "none: ",
      "scopeLimit": "acet: curriculum preparation; dcat: curriculum preparation; dost-sei: curriculum preparation; cse-professional: curriculum preparation; cse-subprofessional: weak preparation; upcat: curriculum preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "ustet-L058",
        "upcat-L057",
        "upcat-L071",
        "sm-foundation-L066",
        "cse-professional-L082",
        "cse-subprofessional-L122"
      ],
      "facet": "English: Diagnose clause boundaries and punctuation",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            21,
            21
          ],
          "note": "Independent/dependent clause question"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            64,
            64
          ],
          "note": "Find boundaries first"
        }
      ],
      "missingIdeas": [
        "Run-ons, comma splices, capitalization and linking rules not taught here."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "none: ",
      "scopeLimit": "ustet: curriculum preparation; upcat: curriculum preparation; upcat: weak preparation; sm-foundation: curriculum preparation; cse-professional: weak preparation; cse-subprofessional: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "acet-L110",
        "dcat-L096",
        "dost-sei-L072",
        "pupcet-L063",
        "ustet-L069"
      ],
      "facet": "English: Check word form and usage",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            22,
            24
          ],
          "note": "Form/meaning check and specific-error standard"
        }
      ],
      "missingIdeas": [
        "No part-of-speech selection or vocabulary repair example."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "none: ",
      "scopeLimit": "acet: weak preparation; dcat: weak preparation; dost-sei: official domain/skill; see exact qualifiers; pupcet: weak preparation; ustet: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L071",
        "cse-subprofessional-L067",
        "upcat-L072",
        "sm-foundation-L075"
      ],
      "facet": "English: Use an evidence-based editing checklist without invented format rules",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            12,
            24
          ],
          "note": "Scope caution and checklist"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            64,
            86
          ],
          "note": "No frequency ranking, exactly-one-error or universal no-change assumption"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            48,
            52
          ],
          "note": "Correct sentence accepted with grammatical reason"
        }
      ],
      "missingIdeas": [
        "Current CSC2026 PPT scope supports named task only; no format or frequency inference."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: Correct sentence accepted with grammatical reason",
      "scopeLimit": "cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers; upcat: weak preparation; sm-foundation: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L072",
        "cse-subprofessional-L069",
        "acet-L170",
        "dcat-L093",
        "ustet-L063",
        "sm-foundation-L069"
      ],
      "facet": "English: Choose an orienting opening without treating it as a universal topic-sentence rule",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            16,
            16
          ],
          "note": "Orientation criterion and rhetorical exceptions"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            71,
            73
          ],
          "note": "Verify whole sequence"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            87,
            89
          ],
          "note": "Narrative/rhetorical limit"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            30,
            39
          ],
          "note": "C introduces topic without unsupported backward reference"
        }
      ],
      "missingIdeas": [
        "Arranging supplied sentences is not drafting a topic sentence or full essay."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: C introduces topic without unsupported backward reference",
      "scopeLimit": "cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers; acet: curriculum preparation; dcat: unknown/context; see exact qualifiers; ustet: curriculum preparation; sm-foundation: curriculum preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L058",
        "dcat-L091",
        "acet-L101",
        "ustet-L059",
        "ustet-L065",
        "pupcet-L058",
        "pupcet-L077",
        "dost-sei-L076",
        "cse-professional-L077",
        "sm-foundation-L066"
      ],
      "facet": "English: Track backward reference and cohesive links",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            18,
            18
          ],
          "note": "Reference depends on text/context"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            69,
            73
          ],
          "note": "Link and global check method"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            77,
            81
          ],
          "note": "Pronoun-first exception"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            30,
            57
          ],
          "note": "Resources to competition to conflicts to wars, C-B-A-D"
        }
      ],
      "missingIdeas": [
        "English demonstratives only; Filipino cohesive devices not taught."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: Resources to competition to conflicts to wars, C-B-A-D",
      "scopeLimit": "upcat: curriculum preparation; dcat: curriculum preparation; acet: curriculum preparation; ustet: curriculum preparation; pupcet: curriculum preparation; dost-sei: curriculum preparation; cse-professional: curriculum preparation; sm-foundation: curriculum preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L057",
        "upcat-L058",
        "dcat-L091",
        "acet-L101",
        "pupcet-L058",
        "dost-sei-L076",
        "sm-foundation-L066",
        "ustet-L059",
        "cse-professional-L077"
      ],
      "facet": "English: Use transition meaning instead of fixed sentence positions",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            20,
            20
          ],
          "note": "Meaning relation can reach broader earlier idea"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            83,
            85
          ],
          "note": "Contrast/result/illustration meanings"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            59,
            65
          ],
          "note": "However signals contrast but not unique preceding sentence"
        }
      ],
      "missingIdeas": [
        "However developed; no worked result or illustration sequence."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: However signals contrast but not unique preceding sentence",
      "scopeLimit": "upcat: curriculum preparation; dcat: curriculum preparation; acet: curriculum preparation; pupcet: curriculum preparation; dost-sei: curriculum preparation; sm-foundation: curriculum preparation; ustet: curriculum preparation; cse-professional: curriculum preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L060",
        "pupcet-L076",
        "cse-subprofessional-L097"
      ],
      "facet": "English: Order chronology or a procedure",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            22,
            22
          ],
          "note": "Time/sequence markers"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            69,
            69
          ],
          "note": "Mark chronology"
        }
      ],
      "missingIdeas": [
        "No timed/procedural sequence example; cited curriculum facets specifically Filipino, while this body is English."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "none: ",
      "scopeLimit": "upcat: curriculum preparation; pupcet: curriculum preparation; cse-subprofessional: curriculum preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L080",
        "cse-subprofessional-L097",
        "upcat-L060",
        "pupcet-L076"
      ],
      "facet": "English: Use cause/effect chain while allowing effect-first discourse",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            24,
            24
          ],
          "note": "Follow discourse signals"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            91,
            93
          ],
          "note": "Effect-first possibility"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            47,
            57
          ],
          "note": "Competition precedes linked conflicts and wars"
        }
      ],
      "missingIdeas": [
        "One English chain; no Filipino causal or narrative connector teaching and no worked effect-first arrangement."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: Competition precedes linked conflicts and wars",
      "scopeLimit": "cse-professional: curriculum preparation; cse-subprofessional: curriculum preparation; upcat: curriculum preparation; pupcet: curriculum preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L072",
        "cse-subprofessional-L069",
        "acet-L170",
        "dcat-L093",
        "ustet-L063",
        "sm-foundation-L069"
      ],
      "facet": "English: Test global coherence after building local pairs",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            69,
            73
          ],
          "note": "Link, orient and test full paragraph"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            39,
            57
          ],
          "note": "Each step produces a complete four-sentence sequence"
        }
      ],
      "missingIdeas": [
        "One extended worked chain; transfer to varied text-development patterns not demonstrated."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: Each step produces a complete four-sentence sequence",
      "scopeLimit": "cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers; acet: curriculum preparation; dcat: unknown/context; see exact qualifiers; ustet: curriculum preparation; sm-foundation: curriculum preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L070",
        "cse-subprofessional-L066",
        "sm-foundation-L075",
        "upcat-L057",
        "dost-sei-L072",
        "acet-L110",
        "ustet-L069"
      ],
      "facet": "English: Interpret concession/contrast and cause clues",
      "lessonIds": [
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            16,
            16
          ],
          "note": "Discourse relations not automatic polarity switches"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            72,
            72
          ],
          "note": "Although, because, therefore meanings"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            30,
            36
          ],
          "note": "Rain forecast versus successful event"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            40,
            46
          ],
          "note": "Damage supports unsafe"
        }
      ],
      "missingIdeas": [
        "Result/illustration are mentioned but not worked; test inclusion beyond CSE is a bounded preparation lead."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: Rain forecast versus successful event; Damage supports unsafe",
      "scopeLimit": "cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers; sm-foundation: weak preparation; upcat: curriculum preparation; dost-sei: official domain/skill; see exact qualifiers; acet: weak preparation; ustet: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L070",
        "cse-subprofessional-L066",
        "sm-foundation-L075"
      ],
      "facet": "English: Coordinate two blanks and verify whole-sentence meaning",
      "lessonIds": [
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            22,
            24
          ],
          "note": "Whole sentence and constrained-blank strategy"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            92,
            94
          ],
          "note": "Pair/set coherence"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            50,
            56
          ],
          "note": "Thorough preparation versus nervous response"
        }
      ],
      "missingIdeas": [
        "Does not establish a guaranteed multi-blank exam format."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: Thorough preparation versus nervous response",
      "scopeLimit": "cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers; sm-foundation: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L070",
        "cse-subprofessional-L066",
        "sm-foundation-L075",
        "upcat-L057",
        "dost-sei-L072",
        "pupcet-L063"
      ],
      "facet": "English: Supply a finite verb fitting the sentence context",
      "lessonIds": [
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            18,
            18
          ],
          "note": "Grammar category/form check"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            60,
            66
          ],
          "note": "Completed event interpretation; rejects time-phrase automation"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            88,
            90
          ],
          "note": "Timeline/context caution"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            60,
            66
          ],
          "note": "Approved as natural completed-event finite verb"
        }
      ],
      "missingIdeas": [
        "Finite verb is named rather than generally defined; only selected context is modeled. Blanket exclusion of approve needs dialect/collective-agreement qualification."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: Approved as natural completed-event finite verb",
      "scopeLimit": "cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers; sm-foundation: weak preparation; upcat: curriculum preparation; dost-sei: official domain/skill; see exact qualifiers; pupcet: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L058",
        "dcat-L091",
        "acet-L110",
        "dost-sei-L072"
      ],
      "facet": "English: Recognize collocations and idiomatic combinations",
      "lessonIds": [
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            20,
            20
          ],
          "note": "Strong evidence, make a decision, interested in"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            74,
            74
          ],
          "note": "Check idiomatic combination"
        }
      ],
      "missingIdeas": [
        "Combinations are supplied without a worked elimination comparison; idiom interpretation is not developed."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "none: ",
      "scopeLimit": "upcat: curriculum preparation; dcat: curriculum preparation; acet: weak preparation; dost-sei: official domain/skill; see exact qualifiers. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "acet-L101",
        "dost-sei-L076",
        "upcat-L057",
        "upcat-L058",
        "pupcet-L063"
      ],
      "facet": "English: Use agreement, aspect, complementation, articles, prepositions and parallelism to eliminate choices",
      "lessonIds": [
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            18,
            18
          ],
          "note": "Grammar categories listed"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            70,
            70
          ],
          "note": "Predict category and meaning"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            60,
            66
          ],
          "note": "One finite-verb form selection"
        }
      ],
      "missingIdeas": [
        "Finite-verb example does not teach listed rule families; most have no distinct procedure or application."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "thin: One finite-verb form selection",
      "scopeLimit": "acet: curriculum preparation; dost-sei: curriculum preparation; upcat: curriculum preparation; pupcet: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L070",
        "cse-subprofessional-L066",
        "sm-foundation-L075",
        "dcat-L096",
        "acet-L110",
        "ustet-L069"
      ],
      "facet": "English: Check meaning and grammar together without mechanical tense/transition rules",
      "lessonIds": [
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            12,
            24
          ],
          "note": "Joint coherence criteria"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            70,
            90
          ],
          "note": "Predict, read completed sentence, avoid mechanical switches"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            30,
            66
          ],
          "note": "Contrast, cause, pair and finite-verb examples"
        }
      ],
      "missingIdeas": [
        "All teaching/examples English; Filipino completion not present."
      ],
      "priorKnowledge": "Ordinary reading and vocabulary are assumed. Locally explained task relationships do not require another whole lesson; checklist-only families remain underdeveloped, not strict dependencies.",
      "workedExamples": "worked: Contrast, cause, pair and finite-verb examples",
      "scopeLimit": "cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers; sm-foundation: weak preparation; dcat: weak preparation; acet: weak preparation; ustet: weak preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L057",
        "dcat-L092",
        "acet-L101",
        "ustet-L058",
        "sm-foundation-L066",
        "upcat-L071"
      ],
      "facet": "English: active/passive voice selection and conversion",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Voice meanings, grammatical transformations and worked voice choices."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "upcat: curriculum preparation; dcat: curriculum preparation; acet: curriculum preparation; ustet: curriculum preparation; sm-foundation: curriculum preparation; upcat: weak preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L057",
        "dcat-L092",
        "ustet-L058",
        "sm-foundation-L066"
      ],
      "facet": "English: direct/reported speech transformations",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Reporting constructions, pronoun/time changes and speech conversion examples."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "upcat: curriculum preparation; dcat: curriculum preparation; ustet: curriculum preparation; sm-foundation: curriculum preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L057",
        "dcat-L092",
        "sm-foundation-L066",
        "cse-subprofessional-L095",
        "cse-professional-L082",
        "cse-subprofessional-L122"
      ],
      "facet": "English: systematic past versus past-perfect and verb-aspect choice",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            18,
            18
          ],
          "note": "Timeline checklist only"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            60,
            66
          ],
          "note": "One completed-event approved example"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            88,
            90
          ],
          "note": "Context warning"
        }
      ],
      "missingIdeas": [
        "Timeline/aspect definitions, contrasting past/past-perfect contexts and aspect applications."
      ],
      "priorKnowledge": "Selected completed-event reasoning is supplied locally; richer tense instruction is optional preparation.",
      "workedExamples": "One finite-verb completion, not contrasting tense/aspect examples.",
      "scopeLimit": "upcat: curriculum preparation; dcat: curriculum preparation; sm-foundation: curriculum preparation; cse-subprofessional: curriculum preparation; cse-professional: weak preparation; cse-subprofessional: weak preparation. English aspect/tense preparation is only partially developed; Filipino verb-time competencies require separate evidence. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "acet-L101",
        "ustet-L058",
        "pupcet-L058",
        "dost-sei-L076",
        "cse-professional-L077"
      ],
      "facet": "English: modal meaning and construction",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Permission, ability, obligation or probability meanings and modal-form choices."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "acet: curriculum preparation; ustet: curriculum preparation; pupcet: curriculum preparation; dost-sei: curriculum preparation; cse-professional: curriculum preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "acet-L101"
      ],
      "facet": "English: conditional constructions",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Condition/result structures and context-dependent conditional choices."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "acet: curriculum preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "acet-L101"
      ],
      "facet": "English: reflexive and intensive pronoun distinctions",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Reference/emphasis distinction and worked forms."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "acet: curriculum preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L071",
        "ustet-L058"
      ],
      "facet": "English: capitalization rules and applications",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Sentence/proper-name capitalization methods."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "upcat: weak preparation; ustet: curriculum preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L071",
        "ustet-L058",
        "cse-professional-L082",
        "cse-subprofessional-L122"
      ],
      "facet": "English: punctuation, run-ons and comma-splice repair",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            21,
            21
          ],
          "note": "Clause-boundary/punctuation check named without correction rules"
        }
      ],
      "missingIdeas": [
        "Identify independent/dependent clauses and connect them with valid punctuation; worked run-on/comma-splice repairs."
      ],
      "priorKnowledge": "Sentence Structure supplies clause-type examples at 14-20/50-73, but a checklist label without an actual clause-boundary application does not establish an indispensable current edge.",
      "workedExamples": "No punctuation/run-on correction example.",
      "scopeLimit": "upcat: weak preparation; ustet: curriculum preparation; cse-professional: weak preparation; cse-subprofessional: weak preparation. Specific English rule candidates, not a published CSC finer inventory. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L057",
        "sm-foundation-L066",
        "cse-professional-L071",
        "cse-subprofessional-L068"
      ],
      "facet": "English: phrases, clauses and sentence classification/construction",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            21,
            21
          ],
          "note": "Clause labels"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            18,
            18
          ],
          "note": "Grammar category list"
        }
      ],
      "missingIdeas": [
        "Phrase/clause distinctions and independent/dependent definitions; sentence-type classification/construction."
      ],
      "priorKnowledge": "Verified optional Sentence Structure foundation teaches structures at 14-20 and examples50-73; current applications neither count nor classify clauses.",
      "workedExamples": "No sentence-type classification or creation.",
      "scopeLimit": "upcat: curriculum preparation; sm-foundation: curriculum preparation; cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers. Error recognition/finite-verb completion does not close the separate sentence-structure domain. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L058"
      ],
      "facet": "English: interpret lexical idioms from context",
      "lessonIds": [
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Nonliteral idiom meaning and context-dependent idiom interpretation."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "upcat: curriculum preparation. Collocation examples are not a method for interpreting lexical idioms. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "dcat-L091",
        "dcat-L096",
        "acet-L110",
        "ustet-L069",
        "pupcet-L063",
        "dost-sei-L072",
        "cse-professional-L070"
      ],
      "facet": "English: context-supported meaning during completion",
      "lessonIds": [
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            30,
            46
          ],
          "note": "Contrast/cause constrain successful/unsafe"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            70,
            76
          ],
          "note": "Predict meaning and reread"
        }
      ],
      "missingIdeas": [
        "Unfamiliar word definitions and broader vocabulary depth remain unknown/not taught."
      ],
      "priorKnowledge": "Everyday meanings of answer words are assumed; relation-based reasoning is explained.",
      "workedExamples": "Contrast and damage examples justify the selected meaning.",
      "scopeLimit": "dcat: curriculum preparation; dcat: weak preparation; acet: weak preparation; ustet: weak preparation; pupcet: weak preparation; dost-sei: official domain/skill; see exact qualifiers; cse-professional: official domain/skill; see exact qualifiers. Added completion preparation beyond original three map tags is a facet lead, not a verified exam task. Word meaning, grammar and passage reading remain separate. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L082",
        "cse-subprofessional-L122",
        "sm-foundation-L075"
      ],
      "facet": "English: lexical synonyms, antonyms and homonyms",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Lexical relations and confusing same-sound/same-spelling words."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "cse-professional: weak preparation; cse-subprofessional: weak preparation; sm-foundation: weak preparation. No vocabulary-family completeness claim follows from selecting successful or unsafe. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-subprofessional-L122"
      ],
      "facet": "English: word-part meaning",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Roots, prefixes, suffixes and applying them to unfamiliar words."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "cse-subprofessional: weak preparation. Weak reviewer preparation, not a CSC-confirmed task list. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "dcat-L093",
        "acet-L170",
        "acet-L171",
        "ustet-L063",
        "sm-foundation-L069"
      ],
      "facet": "English: recognize varied text-development patterns",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            16,
            24
          ],
          "note": "Orientation, sequence and cause/effect clues"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            87,
            93
          ],
          "note": "Narrative/rhetorical/effect-first possibilities named"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            30,
            57
          ],
          "note": "One referential cause-linked sequence"
        }
      ],
      "missingIdeas": [
        "Systematic comparison of description, narration, comparison, definition, exemplification, persuasion and other patterns."
      ],
      "priorKnowledge": "Local ordering clues are supplied; no extra lesson required to follow this chain.",
      "workedExamples": "One cause-linked arrangement; no contrasting development-pattern applications.",
      "scopeLimit": "dcat: unknown/context; see exact qualifiers; acet: curriculum preparation; ustet: curriculum preparation; sm-foundation: curriculum preparation. SHS scheduling/cohort and organizer relevance remain conditional; a paragraph-order method does not close all reading/writing patterns. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "dcat-L093",
        "acet-L170",
        "acet-L171",
        "ustet-L063",
        "sm-foundation-L069"
      ],
      "facet": "Writing: identify explicit/implicit claims and claims of fact, policy or value",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Claim classification, assertion interpretation and claim-identification examples."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "dcat: unknown/context; see exact qualifiers; acet: curriculum preparation; ustet: curriculum preparation; sm-foundation: curriculum preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "dcat-L093",
        "acet-L170",
        "ustet-L063",
        "sm-foundation-L069"
      ],
      "facet": "Writing: evaluate evidence supporting claims and counterclaims",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Textual evidence quality, reasoning and counterclaim evaluation."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "dcat: unknown/context; see exact qualifiers; acet: curriculum preparation; ustet: curriculum preparation; sm-foundation: curriculum preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "acet-L171",
        "acet-L042"
      ],
      "facet": "Writing: produce coherent arguments or narratives for purpose and audience",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Plan, draft and revise a complete original argument/narrative for an audience."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "acet: curriculum preparation; acet: weak reported subject. ACET exam essay scope/language/rubric/cycle remain weak/unknown; application essay is separate. Strengthened-SHS writing is conditional preparation. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "acet-L171",
        "dcat-L096",
        "ustet-L063"
      ],
      "facet": "Writing: critical reviews and academic-text purposes",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Critical-review construction and academic genre/purpose distinctions."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "acet: curriculum preparation; dcat: weak preparation; ustet: curriculum preparation. Academic-writing recollection or curriculum preparation is not verified exam essay production. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "dcat-L093",
        "acet-L170"
      ],
      "facet": "Writing: assess and revise appropriate language and mechanics in sustained text",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Sustained paragraph/essay editing for register, mechanics and audience."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "dcat: unknown/context; see exact qualifiers; acet: curriculum preparation. Sentence editing examples are a narrower task than editing a whole composition. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "dcat-L096",
        "ustet-L059"
      ],
      "facet": "Reading: tone and mood",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Tone/mood distinctions and evidence-based interpretation."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "dcat: weak preparation; ustet: curriculum preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "dcat-L096",
        "ustet-L059",
        "ustet-L065"
      ],
      "facet": "Reading: author purpose, intent and literary technique",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Purpose/intent inference and technique interpretation beyond sentence order."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "dcat: weak preparation; ustet: curriculum preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "ustet-L065"
      ],
      "facet": "Reading: implicit meaning and bias",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Distinguish supported implication and biased framing."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "ustet: curriculum preparation. Compound requirements remain open beyond the current task core. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "ustet-L065"
      ],
      "facet": "Academic communication: citation ethics",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Attribution and ethical source use."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "ustet: curriculum preparation. Version/cohort-limited curriculum candidate; no exam item format established. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "ustet-L065"
      ],
      "facet": "Academic reading: charts/tables and unfamiliar academic vocabulary",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "No chart/table interpretation or academic-vocabulary instruction in these application bodies."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "ustet: curriculum preparation. Compound-row remainder is outside this local core; other topics may teach it and are not rated absent here. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L072",
        "dcat-L096",
        "ustet-L069",
        "pupcet-L063",
        "dost-sei-L072"
      ],
      "facet": "Reading: broader passage comprehension beyond ordering",
      "lessonIds": [
        "lesson-language-application-paragraph-organization",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            30,
            57
          ],
          "note": "Short supplied-sentence chain"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            22,
            24
          ],
          "note": "Whole-sentence meaning"
        }
      ],
      "missingIdeas": [
        "Main idea/details/inference, varied genres and broader passage demands are not developed by these applications."
      ],
      "priorKnowledge": "Ordinary reading assumed; no strict application prerequisite inferred from broader reading goals.",
      "workedExamples": "One paragraph arrangement; sentence completions, not sustained passage-comprehension methods.",
      "scopeLimit": "cse-professional: official domain/skill; see exact qualifiers; dcat: weak preparation; ustet: weak preparation; pupcet: weak preparation; dost-sei: official domain/skill; see exact qualifiers. Specific other reading facets may be taught elsewhere; no corpus-wide absence claim. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L033",
        "upcat-L050",
        "upcat-L073",
        "upcat-L074",
        "pupcet-L081",
        "cse-professional-L034",
        "cse-professional-L071",
        "cse-subprofessional-L046",
        "cse-subprofessional-L067"
      ],
      "facet": "Filipino: error recognition and wastong gamit",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino sentence errors, language-specific rules and corrections."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "upcat: unknown/context; see exact qualifiers; upcat: official domain/skill; see exact qualifiers; upcat: weak preparation; pupcet: weak preparation; cse-professional: official; see cycle/language qualifiers; cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official; see cycle/language qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L074",
        "upcat-L075"
      ],
      "facet": "Filipino: bahagi ng pananalita, pronouns, pang-uri and pang-abay applications",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino word classes and context-dependent pronoun/modifier forms."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "upcat: weak preparation. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L075"
      ],
      "facet": "Filipino: spelling in sentences",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino spelling/usage application."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "upcat: weak preparation. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L080",
        "cse-subprofessional-L068",
        "upcat-L050"
      ],
      "facet": "Filipino: sentence types and structure",
      "lessonIds": [
        "lesson-language-application-error-identification"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino sentence-type recognition/construction and application."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "cse-professional: curriculum preparation; cse-subprofessional: official domain/skill; see exact qualifiers; upcat: official domain/skill; see exact qualifiers. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L034",
        "cse-professional-L070",
        "cse-subprofessional-L046",
        "cse-subprofessional-L066"
      ],
      "facet": "Filipino: sentence completion",
      "lessonIds": [
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino contextual meaning, grammar and natural combinations in completion."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "cse-professional: official; see cycle/language qualifiers; cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official; see cycle/language qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L034",
        "cse-professional-L072",
        "cse-subprofessional-L046",
        "cse-subprofessional-L069"
      ],
      "facet": "Filipino: paragraph organization",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino paragraph arrangement and referential/cohesive links."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "cse-professional: official; see cycle/language qualifiers; cse-professional: official domain/skill; see exact qualifiers; cse-subprofessional: official; see cycle/language qualifiers; cse-subprofessional: official domain/skill; see exact qualifiers. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L060",
        "pupcet-L076",
        "cse-subprofessional-L097",
        "upcat-L075"
      ],
      "facet": "Filipino: sequence/narrative connectors and event ordering",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino narrative/sequence connectors and worked event sequence."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "upcat: curriculum preparation; pupcet: curriculum preparation; cse-subprofessional: curriculum preparation; upcat: weak preparation. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-professional-L080",
        "cse-subprofessional-L097"
      ],
      "facet": "Filipino: causal connectors",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino cause/effect connector choice and sentence/paragraph application."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "cse-professional: curriculum preparation; cse-subprofessional: curriculum preparation. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "pupcet-L076",
        "pupcet-L077"
      ],
      "facet": "Filipino: unity/cohesion, opinions and logical idea relationships",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino opinion expression, cohesive devices and logical links."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "pupcet: curriculum preparation. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "pupcet-L077",
        "cse-subprofessional-L097"
      ],
      "facet": "Filipino: topic, key meanings, explain ideas and outline a read text",
      "lessonIds": [
        "lesson-language-application-paragraph-organization"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            10,
            93
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino topic/key-word interpretation, text explanation and outline construction."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "pupcet: curriculum preparation; cse-subprofessional: curriculum preparation. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L060",
        "cse-subprofessional-L096"
      ],
      "facet": "Filipino: possibility, time/place adverbs and action/event/experience verb forms",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Language-specific expressions, adverbial phrases and verbs by time."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "upcat: curriculum preparation; cse-subprofessional: curriculum preparation. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "cse-subprofessional-L096",
        "pupcet-L081"
      ],
      "facet": "Filipino: vocabulary through synonyms",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            10,
            86
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            10,
            94
          ],
          "note": "Full owned-body check: this component is not taught or exemplified."
        }
      ],
      "missingIdeas": [
        "Filipino synonym/context meanings and examples."
      ],
      "priorKnowledge": "Not an indispensable dependency of the currently taught applications. Related or future instruction cannot justify a current strict link.",
      "workedExamples": "None for this component.",
      "scopeLimit": "cse-subprofessional: curriculum preparation; pupcet: weak preparation. All three owned teaching bodies and examples are English. Methods may transfer partly, but no Filipino-language instruction or worked Filipino application appears. Narrow cross-topic Sentence Structure source has Filipino forms at29-36; that does not repair owned application coverage. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    },
    {
      "requirementRefs": [
        "upcat-L050",
        "dcat-L038",
        "acet-L039",
        "ustet-L038",
        "ustet-L051",
        "dost-sei-L036",
        "dost-sei-L072",
        "sm-foundation-L045",
        "sm-foundation-L076"
      ],
      "facet": "Broad exam labels and detailed application inclusion/depth",
      "lessonIds": [
        "lesson-language-application-error-identification",
        "lesson-language-application-paragraph-organization",
        "lesson-language-application-sentence-completion"
      ],
      "verdict": "unknown",
      "evidence": [
        {
          "path": "content/lessons/language-proficiency/language-application/error-identification.md",
          "lines": [
            12,
            24
          ],
          "note": "Editing scope/checklist"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/paragraph-organization.md",
          "lines": [
            12,
            24
          ],
          "note": "Paragraph core"
        },
        {
          "path": "content/lessons/language-proficiency/language-application/sentence-completion.md",
          "lines": [
            12,
            24
          ],
          "note": "Completion core"
        }
      ],
      "missingIdeas": [
        "Official finer CET/SM application inventories, difficulty, language allocations and current essay specifications remain unknown."
      ],
      "priorKnowledge": "Curriculum/reviewer methods are preparation, not prerequisites inferred from organizer labels.",
      "workedExamples": "Current owned English examples establish local teaching only.",
      "scopeLimit": "upcat: official domain/skill; see exact qualifiers; dcat: weak reported subject; acet: weak reported subject; ustet: official; see cycle/language qualifiers; ustet: official domain/skill; see exact qualifiers; dost-sei: official; see cycle/language qualifiers; dost-sei: official domain/skill; see exact qualifiers; sm-foundation: weak reported subject; sm-foundation: weak preparation. Broad English/Language proficiency labels do not prove any fixed editing/completion/ordering format. SM advice from another exam is not an SM blueprint. Only these three owned bodies assessed; local absence is not a corpus-wide or exam-exclusion claim. English/Filipino allocation, tested depth and actual item forms unknown. Official CSE scope is 2026 PPT; DOST is 2026 with 2027 continuity unconfirmed. Curriculum means inferred preparation, with legacy/strengthened SHS cohort/completion limits where applicable; weak reports/advice do not establish current blueprints."
    }
  ],
  "sourceLedger": [
    {
      "item": "lesson-language-application-error-identification",
      "issue": "Encountered exam scope statement at line12",
      "originalContent": "Current public CSE scope names error recognition and sentence structure.",
      "disposition": "CONFIRMED for accepted2026 PPT baseline; later cycles and computer variants unknown",
      "source": "CSC Announcement No03s2026; accepted CSE Professional/Subprofessional packets",
      "sourceUrl": "https://csc.gov.ph/phocadownload/userupload/erpo/announcements/2026/ExamAnn_2026_03_Conduct%20of%2009%20Aug%202026%20CSE-PPT_orig%20signed.pdf",
      "page": "p7 sectionF",
      "verificationNote": "Accepted cse-professional-L071 and cse-subprofessional-L067/L068 name tasks. Reused independently accepted source body checks from October5, not a fresh organizer retrieval. Source names scope and bilingual verbal area, not one guaranteed error count, blank count, format or frequency ranking.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-language-application-paragraph-organization",
      "issue": "Encountered exam scope statement at line12",
      "originalContent": "Current public CSE scope names paragraph organization.",
      "disposition": "CONFIRMED for accepted2026 PPT baseline; later cycles and computer variants unknown",
      "source": "CSC Announcement No03s2026; accepted CSE Professional/Subprofessional packets",
      "sourceUrl": "https://csc.gov.ph/phocadownload/userupload/erpo/announcements/2026/ExamAnn_2026_03_Conduct%20of%2009%20Aug%202026%20CSE-PPT_orig%20signed.pdf",
      "page": "p7 sectionF",
      "verificationNote": "Accepted cse-professional-L072 and cse-subprofessional-L069 name task. Reused independently accepted source body checks from October5, not a fresh organizer retrieval. Source names scope and bilingual verbal area, not one guaranteed error count, blank count, format or frequency ranking.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-language-application-sentence-completion",
      "issue": "Encountered exam scope statement at line12",
      "originalContent": "Current public CSE verbal scope names sentence completion.",
      "disposition": "CONFIRMED for accepted2026 PPT baseline; later cycles and computer variants unknown",
      "source": "CSC Announcement No03s2026; accepted CSE Professional/Subprofessional packets",
      "sourceUrl": "https://csc.gov.ph/phocadownload/userupload/erpo/announcements/2026/ExamAnn_2026_03_Conduct%20of%2009%20Aug%202026%20CSE-PPT_orig%20signed.pdf",
      "page": "p7 sectionF",
      "verificationNote": "Accepted cse-professional-L070 and cse-subprofessional-L066 name task. Reused independently accepted source body checks from October5, not a fresh organizer retrieval. Source names scope and bilingual verbal area, not one guaranteed error count, blank count, format or frequency ranking.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-language-application-error-identification",
      "issue": "Encountered selected agreement conventions at30-52",
      "originalContent": "Each takes has; interrupting along-with phrase does not control agreement; neither/nor agrees with nearer plural noun.",
      "disposition": "CONFIRMED within stated English cases",
      "source": "Purdue OWL, Making Subjects and Verbs Agree",
      "sourceUrl": "https://owl.purdue.edu/owl/general_writing/grammar/subject_verb_agreement.html",
      "page": "rules3,5,6,11",
      "verificationNote": "Opened university resource October8; it states nearer-noun or/nor agreement, disregard of interrupting phrases, singular each and non-number-changing with expressions. This is reference support, not a finer CSC blueprint.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-language-application-error-identification",
      "issue": "Encountered singular their at34-36/76-78",
      "originalContent": "Modern standard English can retain singular their.",
      "disposition": "CONFIRMED as accepted standard usage; organizer item conventions unknown",
      "source": "Purdue OWL, Changes in APA7",
      "sourceUrl": "https://owl.purdue.edu/owl/research_and_citation/apa_style/apa_formatting_and_style_guide/apa_changes_7th_edition.html",
      "page": "Writing Style and Grammar, Chapter4",
      "verificationNote": "University resource states APA7 accepts singular they and its related forms. Direct APA page returned no readable body, so that empty response is not treated as verification. No rule about a particular exam's scoring is inferred.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-language-application-error-identification",
      "issue": "Encountered dangling-modifier diagnosis at56-60",
      "originalContent": "Introductory rushing phrase must describe Maria, not the umbrella; rewrite with Maria as following subject.",
      "disposition": "CONFIRMED",
      "source": "Purdue OWL, Dangling Modifiers and How to Correct Them",
      "sourceUrl": "https://owl.purdue.edu/owl/general_writing/mechanics/dangling_modifiers_and_how_to_correct_them.html",
      "page": "definition and revision strategy1",
      "verificationNote": "Opened university resource October8. Its participial example identifies the following subject as doer and repairs the sentence by naming that doer. This supports the local method.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-language-application-sentence-completion",
      "issue": "Encountered usage/context concern at60-66; tension with error-identification78",
      "originalContent": "Approved gives a natural completed-event reading, but line66 says other choices require a different grammatical structure.",
      "disposition": "QUALIFY later; current corpus unchanged",
      "source": "Cambridge English Grammar Today plus Purdue OWL agreement",
      "sourceUrl": "https://dictionary.cambridge.org/grammar/british-grammar/nouns-singular-and-plural",
      "page": "Collective nouns (group words); Purdue rule10",
      "verificationNote": "Cambridge web open returned403; direct non-UI HTTP returned200,455031-byte HTML and the full relevant paragraph. Committee is included among collectives permitting singular/plural agreement by unit/individual construal. Purdue favors singular committee in its American-oriented guide. Approved remains a natural American completed-event answer, but approve can be a finite present plural-agreement reading in accepted English. The future instruction should specify convention/context or use a noncollective singular subject rather than excluding every alternative by grammar. This is an encountered source concern, not a full correctness or question-standards review.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-language-application-paragraph-organization",
      "issue": "Scope boundary: arrangement is not exam essay production",
      "originalContent": "Paragraph organization has supplied English sentence ordering and cohesion methods, not drafting an essay.",
      "disposition": "UNKNOWN current ACET exam essay; retain separate preparation facets",
      "source": "Accepted ACET requirements and overlap essay comparison; Ateneo official page inaccessible in accepted source research",
      "sourceUrl": "https://www.ateneo.edu/college/admissions/acet",
      "page": "requirements/acet.md recordsacet-L042/L170/L171/L179; overlap/cet-scholarship-scope.md essay section",
      "verificationNote": "Accepted research preserves weak exam-essay reports, inaccessible organizer body, and unknown language/rubric/cycle. Application essay cannot fill that gap. Legacy and strengthened SHS composition competencies are conditional preparation; local arrangement examples do not teach producing a complete argument/narrative.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    }
  ]
}
```
