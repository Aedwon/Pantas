"""Integrate complete topic evidence with explicit, bounded source-row findings."""
from collections import Counter
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parent
data = json.loads((ROOT / 'lesson-structure-data.json').read_text())
manifest = json.loads((ROOT / 'structure-input-manifest.json').read_text())
original = json.loads((ROOT / 'requirement-map.json').read_text())['rows']
decisions = json.loads((ROOT / 'structure/requirement-reconciliation-decisions.json').read_text())['decisions']
if data['pendingTopics']:
    raise SystemExit('REFUSED: complete topic bodies required')
lessons = {l['id']: l for t in data['topicRecords'] for l in t['lessons']}
if set(lessons) != set(manifest['lessons']):
    raise SystemExit('REFUSED: complete existing lesson accounting required')
topic_keys = {t['subject'] + '-' + t['topic'] for t in data['topicRecords']}
missing = set()
assert len(original) == len(data['requirementAccounting'])
for row, finding in zip(original, data['requirementAccounting']):
    assert row['id'] == finding['requirementId']
    finding['sourceRecordGroup'] = row['group']
    finding['sourceLine'] = row['line']
    if row['kind'] in ('context', 'constraint') or row['status'] == 'UNKNOWN':
        finding['reconciliation'] = {
            'disposition': 'source-context' if row['kind'] == 'context' else 'scope-constraint' if row['kind'] == 'constraint' else 'unknown-required-skill',
            'note': finding['globalFinding'],
            'fullCoverageClaim': False,
        }
        continue
    facets = finding['localFacets']
    if not facets:
        missing.add(row['id'])
        explicit = decisions[row['id']]
        assert set(explicit['providerTopicKeys']) <= topic_keys
        finding['globalFinding'] = explicit['note']
        finding['reconciliation'] = {**explicit, 'fullCoverageClaim': False}
        continue
    by_verdict = Counter(x['assessment']['verdict'] for x in facets)
    finding['globalFinding'] = (
        'Actual local skill assessments are recorded below, including teaching, applications and prior knowledge. '
        'A local absence remains local unless a separate lead reconciliation establishes a corpus gap. '
        'These facets do not establish the entire compound source record, exact exam depth, practice or access.'
    )
    finding['reconciliation'] = {
        'disposition': 'observed-local-facets-with-source-limits',
        'localAssessmentCounts': dict(by_verdict),
        'explainedLocalFacets': [x['assessment']['facet'] for x in facets if x['assessment']['verdict'] == 'explained'],
        'limitedLocalFacets': [x['assessment']['facet'] for x in facets if x['assessment']['verdict'] in ('thin', 'named-only', 'absent', 'unknown')],
        'fullCoverageClaim': False,
        'note': 'Read each facet scopeLimit and exact source record; a count or one explained facet cannot close a broad requirement.',
    }
assert missing == set(decisions), (missing - set(decisions), set(decisions) - missing)
data['status'] = 'RECONCILED Level3 findings; independent mechanical verification and lead gate acceptance pending'
data['reconciliationMethod'] = {
    'sourceRecords': len(original), 'positiveRecords': 421,
    'explicitNoFacetDispositions': len(decisions),
    'scope': 'Teaching/structure only. Practice Level5 deferred; runtime unknown; no full exam completeness, mastery or correctness claim.',
    'localAbsenceRule': 'Do not merge similar words into a global skill match. Lead cross-topic findings and source conditions are stated separately.',
}
(ROOT / 'lesson-structure-data.json').write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n')

# A focused source-record index avoids duplicating the detailed facet appendix.
def escape(value):
    return str(value).replace('|', '\\|').replace('\n', ' ')
lines = ['# Source requirement teaching findings, Level 3', '',
         'All535accepted source records are accounted below. Local skill evidence and distinct facets are in lesson-structure-data.json and the current topic artifacts. Broad/weak/curriculum/cycle/language constraints remain as accepted. No whole-record or whole-exam coverage, practice, runtime, mastery or full correctness claim.', '',
         'Source-context, operational constraints and unknown requirements are distinguished from positive teaching leads. Absence in one topic is not automatically corpus absence. Explicit broader source/provider dispositions are evidence navigation, not attribution of every provider lesson.', '']
for exam in dict.fromkeys(x['exam'] for x in original):
    lines += ['## ' + exam, '', '| Source record | Accepted statement | Level3 finding | Evidence |', '|---|---|---|---|']
    for source, finding in zip(original, data['requirementAccounting']):
        if source['exam'] != exam:
            continue
        rec = finding['reconciliation']
        if rec['disposition'] == 'observed-local-facets-with-source-limits':
            note = 'Observed local facets: ' + ', '.join(f'{k}={v}' for k, v in rec['localAssessmentCounts'].items()) + '. Complete compound scope/depth remains unestablished.'
            providers = sorted({x['topicKey'] for x in finding['localFacets']})
        else:
            note = finding['globalFinding']
            providers = rec.get('providerTopicKeys', [])
        evidence = source['requirementPath'] + ':' + str(source['line']) + '; providers: ' + (', '.join(providers) or 'explicit context/constraint/uncertainty')
        lines.append('| ' + ' | '.join(escape(v) for v in [source['id'], source['text'], note, evidence]) + ' |')
    lines += ['']
(ROOT / 'requirement-teaching-findings.md').write_text('\n'.join(lines) + '\n')

tags = json.loads((ROOT / 'lesson-exam-tags.json').read_text())['lessons']
tag_result = {'level': 3, 'status': 'RECONCILED local tag recommendations, not applied; final verification pending',
              'corpusCommit': manifest['corpusCommit'], 'originalTagCatalogUnchanged': True,
              'topicOutputHashes': data['topicOutputHashes'], 'lessons': []}
for old in tags:
    lesson = lessons[old['metadata__id']]
    tag_result['lessons'].append({'lessonId': lesson['id'], 'path': lesson['path'],
        'originalProvisionalExamTags': old['provisionalExamTags'],
        'bodyAssessmentStatus': 'Complete body evidence; current topic sample and lead acceptance remain separately recorded',
        'recommendations': lesson['examApplicability'], 'availability': lesson['availability'], 'practice': lesson['practice']})
(ROOT / 'lesson-exam-tag-recommendations.json').write_text(json.dumps(tag_result, indent=2, ensure_ascii=False) + '\n')
print(json.dumps({'accountedSourceRecords': len(original), 'sourceRowsWithLocalFacets': sum(bool(x['localFacets']) for x in data['requirementAccounting']),
                  'explicitNoFacetDispositions': len(decisions), 'existingLessons': len(lessons), 'appliedTags': False, 'semanticGateAccepted': False}))
