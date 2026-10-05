"""Lead's set comparison of accepted maps, with no body-reading or new tags."""
import hashlib
import itertools
import json
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).parent
mapping = json.loads((ROOT / 'requirement-map.json').read_text())
catalog = json.loads((ROOT / 'lesson-exam-tags.json').read_text())
EXAMS = ['upcat','dcat','acet','ustet','pupcet','dost-sei','sm-foundation',
         'cse-professional','cse-subprofessional']
rows = {row['id']:row for row in mapping['rows']}
lessons = catalog['lessons']
byid = {lesson['metadata__id']:lesson for lesson in lessons}
assert len(byid) == len(lessons) == 158
assert len(rows) == 535

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def support(lid, exam):
    return [rid for rid in byid[lid]['evidenceRows'] if rows[rid]['exam']==exam]

def membership(lid):
    return byid[lid]['provisionalExamTags']

input_paths = [ROOT / name for name in ['requirement-map.json','lesson-exam-tags.json',
    'inventory-lessons.json','map-input-manifest.json','requirement-input-manifest.json',
    'level1-publication-readback.json','exam-format-profiles.md']]
input_paths += sorted((ROOT/'requirements').glob('*.md'))
input_paths += sorted((ROOT/'maps').glob('*.md'))
input_hashes = {str(path):sha(path) for path in input_paths}

lesson_rows=[]
for lesson in lessons:
    lid=lesson['metadata__id']
    exams=membership(lid)
    category='shared candidate' if len(exams)>1 else 'single map candidate' if exams else 'unknown relevance'
    lesson_rows.append({'lessonId':lid,'path':lesson['path'],'title':lesson['metadata_title'],
        'subject':lesson['subject'],'topic':lesson['topic'],'candidateExams':exams,
        'membershipClass':category,'perExamEvidence':{exam:support(lid,exam) for exam in exams},
        'lessonExtent':'partial or unknown; common name lead does not prove full body or depth equivalence',
        'exclusiveToExam':None,'bodyReuse':'unknown; Level3 not authorized',
        'languageAndDepth':'see accepted evidence-row qualifiers and sourced scope contrasts',
        'runtimeAvailability':'unknown'})

exam_lessons={exam:{l['lessonId'] for l in lesson_rows if exam in l['candidateExams']} for exam in EXAMS}
pairs=[]
for a,b in itertools.combinations(EXAMS,2):
    shared=sorted(exam_lessons[a]&exam_lessons[b])
    a_only=sorted(exam_lessons[a]-exam_lessons[b])
    b_only=sorted(exam_lessons[b]-exam_lessons[a])
    # Placement in an authored subject/topic is not an organizer's section roster.
    subjects=[]
    for subject in sorted({l['subject'] for l in lessons}):
        relevant=[lid for lid in shared if byid[lid]['subject']==subject]
        if relevant:
            subjects.append({'corpusSubject':subject,'sharedCandidateIds':relevant,
                'extent':'candidate intersection only; see named organizer scope and facet differences'})
    topics=[]
    for subject,topic in sorted({(l['subject'],l['topic']) for l in lessons}):
        relevant=[lid for lid in shared if (byid[lid]['subject'],byid[lid]['topic'])==(subject,topic)]
        if relevant:
            topics.append({'corpusSubject':subject,'corpusTopic':topic,'sharedCandidateIds':relevant,
                'extent':'partial or unknown at actual skill/depth level'})
    if {a,b}=={'cse-professional','cse-subprofessional'}:
        scope='partial overall roster; full identical organizer-named common core only'
        notes='General Information, bilingual Verbal and English Numerical have identical named scope. Professional Analytical and Subprofessional Clerical differ. Difficulty/finer depth and full body reuse unknown.'
    elif {a,b}=={'upcat','ustet'}:
        scope='full at Mathematics/Science subject-label granularity; finer scope partial or unknown'
        notes='Both current organizer rosters name Mathematics and Science. UPCAT explicitly has bilingual Language Proficiency/Reading; USTET English/Mental Ability arrangements and item languages differ or remain unknown. Equal named Math/Science does not prove equal detailed depth.'
    else:
        scope='shared preparation candidates; full current detailed scope not established'
        notes='Compare actual sourced facets, language, curriculum cohort and version. Same inventory subject/topic/lesson does not prove same exam requirement. Unmapped counterparts are not exclusions. DOST2026 scope does not confirm2027 continuity.'
    pairs.append({'pairId':a+'--'+b,'examA':a,'examB':b,
        'scopeExtent':scope,'scopeNote':notes,'sharedCandidateCount':len(shared),
        'sharedCandidateIds':shared,'onlyInMapA':a_only,'onlyInMapB':b_only,
        'sharedCorpusSubjects':subjects,'sharedCorpusTopics':topics,
        'requirementPackets':[f'requirements/{a}.md',f'requirements/{b}.md'],
        'sharingEvidence':{lid:{a:support(lid,a),b:support(lid,b)} for lid in shared},
        'fullLessonSharingConfirmed':False,'examExclusiveCandidatesConfirmed':False})

topic_rows=[]
for subject,topic in sorted({(l['subject'],l['topic']) for l in lessons}):
    members=[l for l in lesson_rows if l['subject']==subject and l['topic']==topic]
    per_exam={e:[l['lessonId'] for l in members if e in l['candidateExams']] for e in EXAMS}
    topic_rows.append({'subject':subject,'topic':topic,'lessonIds':[l['lessonId'] for l in members],
        'perExamCandidateIds':per_exam,'candidateExamCount':sum(bool(ids) for ids in per_exam.values()),
        'extent':'partial or unknown; each constituent lesson/facet remains separately sourced',
        'analysisOnly':True,'createsContentTag':False})

subject_rows=[]
for subject in sorted({l['subject'] for l in lessons}):
    members=[l for l in lesson_rows if l['subject']==subject]
    subject_rows.append({'subject':subject,'lessonIds':[l['lessonId'] for l in members],
        'perExamCandidateIds':{e:[l['lessonId'] for l in members if e in l['candidateExams']] for e in EXAMS},
        'organizerRosterInferenceAllowed':False,'analysisOnly':True,'createsContentTag':False})

result={'level':2,'status':'DRAFT comparison pending semantic scope integration and independent checks',
    'corpusCommit':catalog['corpusCommit'],'policyCommit':'cb48097bedf15bec2cfbe4fb3aa7e957753b1727',
    'auditBase':'2cc836b1e1cca4c2533c29531057b668b4696f81',
    'method':'Exact set intersections of accepted Level1 candidate edges, never coverage percentages or tested-depth equality. Scope findings use accepted source packets. No lesson bodies or content edits.',
    'exams':EXAMS,'inputHashes':input_hashes,'lessons':lesson_rows,'pairs':pairs,
    'topics':topic_rows,'subjects':subject_rows,
    'evidenceIndex':{rid:{key:row[key] for key in ['exam','line','group','kind','evidence','confidence','text','requirementPath','status','uncertainties']} for rid,row in rows.items()},
    'counts':{'lessons':len(lesson_rows),'pairs':len(pairs),'topics':len(topic_rows),'subjects':len(subject_rows),
        'candidateExamEdges':sum(len(l['candidateExams']) for l in lesson_rows),
        'sharedCandidates':sum(l['membershipClass']=='shared candidate' for l in lesson_rows),
        'singleMapCandidates':sum(l['membershipClass']=='single map candidate' for l in lesson_rows),
        'unknownRelevance':sum(l['membershipClass']=='unknown relevance' for l in lesson_rows),
        'allNineMapCandidates':sum(len(l['candidateExams'])==9 for l in lesson_rows)}}
assert result['counts']=={'lessons':158,'pairs':36,'topics':25,'subjects':6,
    'candidateExamEdges':819,'sharedCandidates':137,'singleMapCandidates':19,
    'unknownRelevance':2,'allNineMapCandidates':34}
(ROOT/'overlap-data.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')

text='# Level2 lesson candidate overlap ledger\n\n'
text+='158 existing lessons are listed once. Exam membership is the accepted name-level map, not confirmed exam scope or full lesson reuse. Every entry links its exact accepted evidence rows in overlap-data.json. Same-ID membership is measured; skill/language/depth equivalence is not assumed. No body reading or Level3 judgment.\n\n'
for lesson in lesson_rows:
    text+='## '+lesson['title']+'\n\n'
    text+='ID: `'+lesson['lessonId']+'`. Path: `'+lesson['path']+'`. Class: '+lesson['membershipClass']+'.\n\n'
    text+='Candidate exams: '+(', '.join(lesson['candidateExams']) or 'none assigned')+'.\n\n'
    text+='Extent: '+lesson['lessonExtent']+'. Exclusivity, full body reuse and student access remain unknown.\n\n'
    for exam,evidence in lesson['perExamEvidence'].items():
        text+='- '+exam+': '+', '.join('`'+rid+'`' for rid in evidence)+'\n'
    text+='\n'
(ROOT/'overlap-lessons.md').write_text(text)
print(result['counts'])
