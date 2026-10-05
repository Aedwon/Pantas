"""Collect completed topic records without inventing semantic coverage verdicts."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[3]
manifest = json.loads((ROOT / 'structure-input-manifest.json').read_text())
rows = json.loads((ROOT / 'requirement-map.json').read_text())['rows']
records, pending, output_hashes = [], [], {}
for topic in manifest['topics']:
    path = REPO / topic['output']
    if not path.exists():
        pending.append(topic['key'])
        continue
    blocks = re.findall(r'```json\s*\n(.*?)\n```', path.read_text(), re.S)
    if len(blocks) != 1:
        pending.append(topic['key'])
        continue
    data = json.loads(blocks[0])
    if data.get('status') != 'COMPLETE':
        pending.append(topic['key'])
        continue
    records.append(data)
    output_hashes[topic['output']] = hashlib.sha256(path.read_bytes()).hexdigest()
facets = {}
for topic in records:
    key = topic['subject'] + '-' + topic['topic']
    for index, facet in enumerate(topic.get('requirementFacets', [])):
        for ref in facet.get('requirementRefs', []):
            facets.setdefault(ref, []).append({'topicKey': key, 'facetIndex': index, 'assessment': facet})
accounting = []
for row in rows:
    accounting.append({'requirementId': row['id'], 'exam': row['exam'], 'text': row['text'], 'sourceEvidence': row['evidence'], 'sourceConfidence': row['confidence'], 'sourceStatus': row['status'], 'localFacets': facets.get(row['id'], []), 'globalFinding': 'PENDING lead reconciliation; local facets do not cover entire compound row', 'practice': 'deferred Level5', 'availability': 'unknown: corpus-bound runtime not verified'})
result = {'level': 3, 'status': 'DRAFT; independent review and lead reconciliation pending', 'corpusCommit': manifest['corpusCommit'], 'policyCommit': manifest['policyCommit'], 'topicOutputHashes': output_hashes, 'pendingTopics': pending, 'topicRecords': records, 'requirementAccounting': accounting}
(ROOT / 'lesson-structure-data.json').write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n')
print(json.dumps({'collectedTopics': len(records), 'collectedLessons': sum(len(x['lessons']) for x in records), 'pendingTopics': len(pending), 'preservedRequirements': len(accounting), 'semanticAcceptance': False}))
