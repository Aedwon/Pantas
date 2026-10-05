"""Render evidence-backed lesson prerequisite recommendations after full accounting."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parent
data = json.loads((ROOT / 'lesson-structure-data.json').read_text())
manifest = json.loads((ROOT / 'structure-input-manifest.json').read_text())
if data['pendingTopics']:
    raise SystemExit('REFUSED: incomplete topic readings; no prerequisite output inferred')
lessons = [lesson for topic in data['topicRecords'] for lesson in topic['lessons']]
ids = {lesson['id'] for lesson in lessons}
if ids != set(manifest['lessons']) or len(lessons) != len(ids):
    raise SystemExit('REFUSED: complete existing lesson accounting required')
graph = {lesson['id']: sorted({dep['lessonId'] for dep in lesson['prerequisites']}) for lesson in lessons}
for lid, deps in graph.items():
    if any(dep not in ids or dep == lid for dep in deps):
        raise SystemExit('REFUSED: unknown or self prerequisite at ' + lid)
visiting, visited = set(), set()
def visit(lid):
    if lid in visiting:
        raise SystemExit('REFUSED: prerequisite cycle through ' + lid)
    if lid in visited:
        return
    visiting.add(lid)
    for dep in graph[lid]:
        visit(dep)
    visiting.remove(lid)
    visited.add(lid)
for lid in graph:
    visit(lid)

def escape(s):
    return str(s).replace('|', '\\|').replace('\n', ' ')
def cite(evidence):
    return '; '.join(f"{e['path']}:{e['lines'][0]}-{e['lines'][1]} ({e.get('note', '')})" for e in evidence)
lines = ['# Lesson prerequisite recommendations', '', 'DRAFT evidence integration. Findings only; independent review and lead acceptance must be recorded separately. No roadmap or content changes.', '', 'Corpus: ' + data['corpusCommit'] + '. Policy: ' + data['policyCommit'] + '.', '', 'One row per consumer with necessary existing-lesson links. A related concept, authored order or useful enrichment is insufficient. Reasons and both-end evidence correspond to each prerequisite listed. Empty JSON lists have the explicit disposition below; they never stand for an unread lesson.', '', '| Lesson id | Prerequisite lesson ids | Reason | Scope | Evidence |', '|---|---|---|---|---|']
none, missing, unresolved = [], [x for x in lessons if x['missingFoundations'] or x['prerequisiteStatus'] == 'missing-foundation'], []
for lesson in sorted(lessons, key=lambda x: x['id']):
    lid, deps = lesson['id'], lesson['prerequisites']
    if deps:
        for dep in deps:
            if not dep['consumerEvidence'] or not dep['foundationEvidence']:
                raise SystemExit('REFUSED: both-end evidence missing at ' + lid)
        lines.append('| ' + ' | '.join(escape(v) for v in [lid, '; '.join(d['lessonId'] for d in deps), '; '.join(d['lessonId'] + ': ' + d['reason'] for d in deps), '; '.join(d['lessonId'] + ': ' + d['scope'] for d in deps), '; '.join(d['lessonId'] + ': consumer ' + cite(d['consumerEvidence']) + '; foundation ' + cite(d['foundationEvidence']) for d in deps)]) + ' |')
    elif lesson['prerequisiteStatus'] == 'none-found':
        none.append(lid)
    elif lesson['prerequisiteStatus'] == 'missing-foundation':
        pass
    else:
        unresolved.append(lesson)
lines += ['', '## No necessary existing-lesson prerequisite found', ''] + ['- ' + lid for lid in none]
lines += ['', '## Missing foundations, including consumers that also have verified links', ''] + ['- ' + x['id'] + ': ' + escape(json.dumps(x['missingFoundations'], ensure_ascii=False)) for x in missing]
lines += ['', '## Unresolved prerequisite disposition', ''] + ['- ' + x['id'] + ': ' + escape(x['prerequisiteStatus']) for x in unresolved]
if not unresolved:
    lines.append('None.')
(ROOT / 'lesson-prerequisites.json').write_text(json.dumps(dict(sorted(graph.items())), indent=2) + '\n')
(ROOT / 'lesson-prerequisites.md').write_text('\n'.join(lines) + '\n')
print(json.dumps({'lessons': len(graph), 'links': sum(map(len, graph.values())), 'consumers': sum(bool(v) for v in graph.values()), 'noneFound': len(none), 'lessonsWithMissingFoundations': len(missing), 'unresolvedWithoutLink': len(unresolved), 'acyclic': True, 'semanticAcceptance': False}))
