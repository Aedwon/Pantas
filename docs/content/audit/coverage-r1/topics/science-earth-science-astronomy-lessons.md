# Earth science and astronomy lesson structure audit

Status: DRAFT. Author findings only; independent semantic review pending.

## Identity and scope

Policy: current main `ac4b30da31b0bcca7e7ed1e47c930b1ac00ced6c`, live/cached match October 5, 2026. Corpus `765c5dc0fa5586281047bf4f7b30d09ab3707887`, pinned clean worktree. Audit startup HEAD 7d5f2ed6a6d6f30e35d1b3f64467f31e7d122112. Watcher owns Git mutations. Sole output ownership; other authors and frozen application code preserved. Chemistry output remains immutable.

Current main AGENTS, WORKFLOW, SUBAGENTS, startup and three content policies retrieved/read; full spec, plan, orchestrator, October 4 and latest Level 3 decisions and illustration decision read. Relevant accepted requirements, inventory, overlap and scope notes read. Policy blobs are unchanged from the earlier read revision, verified at current main. Historical pending headers do not override accepted Levels 1/2.

Evidence paths are pinned corpus-relative; lines are 1-based inclusive. Full-read hashes/ranges are in the appendix. B03/L01/L17/L19 references support structural teaching findings only. Level 4 standards, Level 5 questions/practice/blind solves and illustration assessment remain deferred. Runtime availability is unknown.

## Lesson findings

### lesson-earth-science-astronomy-earths-motions

Goal: Distinguish rotation, revolution and precession, explain opposite seasons, and apply the Gregorian leap-year rule.

- Rotation and daily apparent sky motion: explained; examples worked. content/lessons/science/earth-science-astronomy/earths-motions.md:14-18 (L01 local teaching: Rotation and daily apparent sky motion); content/lessons/science/earth-science-astronomy/earths-motions.md:38-44 (L19 example: Rotation and daily apparent sky motion). Refs: upcat-L136, dost-sei-L102, pupcet-L122.
- Revolution axial tilt and seasonal hemispheres: explained; examples worked. content/lessons/science/earth-science-astronomy/earths-motions.md:21-25 (L01 local teaching: Revolution axial tilt and seasonal hemispheres); content/lessons/science/earth-science-astronomy/earths-motions.md:46-54 (L19 example: Revolution axial tilt and seasonal hemispheres). Refs: upcat-L135, upcat-L163, ustet-L118, dost-sei-L102, pupcet-L122, sm-foundation-L140.
- Gregorian leap-year application: explained; examples worked. content/lessons/science/earth-science-astronomy/earths-motions.md:28-28 (L01 local teaching: Gregorian leap-year application); content/lessons/science/earth-science-astronomy/earths-motions.md:57-64 (L19 example: Gregorian leap-year application). Limits: Calendar detail supports the local year goal; no explicit finer exam requirement. Refs: local lesson goal; exact exam demand unconfirmed.
- Precession and changing pole direction: explained; examples none. content/lessons/science/earth-science-astronomy/earths-motions.md:31-33 (L01 local teaching: Precession and changing pole direction). Limits: No applied precession example; required long-term-motion depth unknown. Refs: upcat-L136.
- Seasonal visibility of constellations: absent; examples none. content/lessons/science/earth-science-astronomy/earths-motions.md:14-33 (L01 local teaching: Seasonal visibility of constellations). Limits: Daily sky motion and pole precession do not explain seasonal nighttime constellation visibility. Refs: upcat-L163, pupcet-L122, dost-sei-L102.

Structure: retain. Teaching and examples support a coherent local goal. Proposal: Keep one shared core; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance. Evidence: content/lessons/science/earth-science-astronomy/earths-motions.md:10-91.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

## Explicit no-existing-prerequisite list

lesson-earth-science-astronomy-earths-motions. Missing-foundation statuses remain separate from verified links.

## Machine-readable appendix

```json
{
  "level": 3,
  "status": "DRAFT",
  "subject": "science",
  "topic": "earth-science-astronomy",
  "policyCommit": "ac4b30da31b0bcca7e7ed1e47c930b1ac00ced6c",
  "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "lessons": [
    {
      "id": "lesson-earth-science-astronomy-earths-motions",
      "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
      "sha256": "06a2927f9937c59f819fcb6232c9a108470891946c2bf4bb0a33df9158058c1d",
      "readLines": [
        1,
        91
      ],
      "goal": "Distinguish rotation, revolution and precession, explain opposite seasons, and apply the Gregorian leap-year rule.",
      "skills": [
        {
          "name": "Rotation and daily apparent sky motion",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
              "lines": [
                14,
                18
              ],
              "note": "L01 local teaching: Rotation and daily apparent sky motion"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
              "lines": [
                38,
                44
              ],
              "note": "L19 example: Rotation and daily apparent sky motion"
            }
          ],
          "requirementRefs": [
            "upcat-L136",
            "dost-sei-L102",
            "pupcet-L122"
          ],
          "limitations": []
        },
        {
          "name": "Revolution axial tilt and seasonal hemispheres",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
              "lines": [
                21,
                25
              ],
              "note": "L01 local teaching: Revolution axial tilt and seasonal hemispheres"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
              "lines": [
                46,
                54
              ],
              "note": "L19 example: Revolution axial tilt and seasonal hemispheres"
            }
          ],
          "requirementRefs": [
            "upcat-L135",
            "upcat-L163",
            "ustet-L118",
            "dost-sei-L102",
            "pupcet-L122",
            "sm-foundation-L140"
          ],
          "limitations": []
        },
        {
          "name": "Gregorian leap-year application",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
              "lines": [
                28,
                28
              ],
              "note": "L01 local teaching: Gregorian leap-year application"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
              "lines": [
                57,
                64
              ],
              "note": "L19 example: Gregorian leap-year application"
            }
          ],
          "requirementRefs": [],
          "limitations": [
            "Calendar detail supports the local year goal; no explicit finer exam requirement"
          ]
        },
        {
          "name": "Precession and changing pole direction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
              "lines": [
                31,
                33
              ],
              "note": "L01 local teaching: Precession and changing pole direction"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L136"
          ],
          "limitations": [
            "No applied precession example; required long-term-motion depth unknown"
          ]
        },
        {
          "name": "Seasonal visibility of constellations",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
              "lines": [
                14,
                33
              ],
              "note": "L01 local teaching: Seasonal visibility of constellations"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L163",
            "pupcet-L122",
            "dost-sei-L102"
          ],
          "limitations": [
            "Daily sky motion and pole precession do not explain seasonal nighttime constellation visibility"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L102"
          ],
          "sharedCore": "Rotation and daily apparent sky motion; Revolution axial tilt and seasonal hemispheres; Gregorian leap-year application; Precession and changing pole direction",
          "partialLimits": "Official Earth/Space domains are historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L122",
            "pupcet-L128"
          ],
          "sharedCore": "Rotation and daily apparent sky motion; Revolution axial tilt and seasonal hemispheres; Gregorian leap-year application; Precession and changing pole direction",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L048",
            "sm-foundation-L140"
          ],
          "sharedCore": "Rotation and daily apparent sky motion; Revolution axial tilt and seasonal hemispheres; Gregorian leap-year application; Precession and changing pole direction",
          "partialLimits": "Science inclusion itself unconfirmed; conditional background only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L129",
            "upcat-L135",
            "upcat-L136",
            "upcat-L163"
          ],
          "sharedCore": "Rotation and daily apparent sky motion; Revolution axial tilt and seasonal hemispheres; Gregorian leap-year application; Precession and changing pole direction",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L118"
          ],
          "sharedCore": "Rotation and daily apparent sky motion; Revolution axial tilt and seasonal hemispheres; Gregorian leap-year application; Precession and changing pole direction",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Teaching and examples support a coherent local goal.",
        "proposal": "Keep one shared core; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance.",
        "evidence": [
          {
            "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
            "lines": [
              10,
              91
            ],
            "note": "structure basis"
          }
        ]
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
        "upcat-L136",
        "dost-sei-L102",
        "pupcet-L122"
      ],
      "facet": "Rotation and daily apparent sky motion",
      "lessonIds": [
        "lesson-earth-science-astronomy-earths-motions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
          "lines": [
            14,
            18
          ],
          "note": "L01 local teaching: Rotation and daily apparent sky motion"
        },
        {
          "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
          "lines": [
            38,
            44
          ],
          "note": "L19 example: Rotation and daily apparent sky motion"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "upcat-L135",
        "upcat-L163",
        "ustet-L118",
        "dost-sei-L102",
        "pupcet-L122",
        "sm-foundation-L140"
      ],
      "facet": "Revolution axial tilt and seasonal hemispheres",
      "lessonIds": [
        "lesson-earth-science-astronomy-earths-motions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
          "lines": [
            21,
            25
          ],
          "note": "L01 local teaching: Revolution axial tilt and seasonal hemispheres"
        },
        {
          "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
          "lines": [
            46,
            54
          ],
          "note": "L19 example: Revolution axial tilt and seasonal hemispheres"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [],
      "facet": "Gregorian leap-year application",
      "lessonIds": [
        "lesson-earth-science-astronomy-earths-motions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
          "lines": [
            28,
            28
          ],
          "note": "L01 local teaching: Gregorian leap-year application"
        },
        {
          "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
          "lines": [
            57,
            64
          ],
          "note": "L19 example: Gregorian leap-year application"
        }
      ],
      "missingIdeas": [
        "Calendar detail supports the local year goal; no explicit finer exam requirement"
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "upcat-L136"
      ],
      "facet": "Precession and changing pole direction",
      "lessonIds": [
        "lesson-earth-science-astronomy-earths-motions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
          "lines": [
            31,
            33
          ],
          "note": "L01 local teaching: Precession and changing pole direction"
        }
      ],
      "missingIdeas": [
        "No applied precession example; required long-term-motion depth unknown"
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "upcat-L163",
        "pupcet-L122",
        "dost-sei-L102"
      ],
      "facet": "Seasonal visibility of constellations",
      "lessonIds": [
        "lesson-earth-science-astronomy-earths-motions"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/earth-science-astronomy/earths-motions.md",
          "lines": [
            14,
            33
          ],
          "note": "L01 local teaching: Seasonal visibility of constellations"
        }
      ],
      "missingIdeas": [
        "Daily sky motion and pole precession do not explain seasonal nighttime constellation visibility"
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    }
  ],
  "sourceLedger": []
}
```
