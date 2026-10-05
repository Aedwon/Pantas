"""Add explicit bilateral and single-map limits from accepted packet records."""
import json
from pathlib import Path

ROOT=Path(__file__).parent
data=json.loads((ROOT/'overlap-data.json').read_text())
names={'upcat':'UPCAT','dcat':'DCAT','acet':'ACET','ustet':'USTET','pupcet':'PUPCET',
       'dost-sei':'DOST-SEI','sm-foundation':'SM Foundation',
       'cse-professional':'CSE Professional','cse-subprofessional':'CSE Subprofessional'}
# Every bilateral comparison retains actual named/unknown scope, not a depth proxy.
profiles={
'upcat':{'fraction':'upcat-L181','math':'Current organizer Mathematics is broad; curriculum adds algebra/trigonometry and descriptive data, while calculus reviewers conflict.', 'mathRefs':['upcat-L171','upcat-L172','upcat-L185','upcat-L196','upcat-L198','upcat-L212'], 'language':'Language/Reading are officially English and Filipino; Mathematics item language is unknown.', 'languageRefs':['upcat-L033','upcat-L034','upcat-L036'], 'section':'mathematics-foundations-and-extensions'},
'dcat':{'fraction':'dcat-L051','math':'Current academic roster/depth unknown; separately recalled Statistics and inferential/regression examples are historical weak leads, not equivalent to descriptive arithmetic.', 'mathRefs':['dcat-L045','dcat-L070','dcat-L072','dcat-L073'], 'language':'English/reading labels are weak2025 reports; Mathematics language and Filipino inclusion remain unknown.', 'languageRefs':['dcat-L035','dcat-L038','dcat-L097'], 'section':'mathematics-foundations-and-extensions'},
'acet':{'fraction':'acet-L062','math':'Mathematics is weakly reported; quadratic/function/oblique-triangle study is curriculum preparation, current scope unconfirmed, and the reported essay is a separate uncertain component.', 'mathRefs':['acet-L038','acet-L068','acet-L071','acet-L078','acet-L042','acet-L165'], 'language':'English is weakly reported; item-language allocation and Filipino exclusion are unconfirmed, including the exam essay language.', 'languageRefs':['acet-L039','acet-L044','acet-L165'], 'section':'essay-and-writing'},
'ustet':{'fraction':'ustet-L083','math':'Mathematics is a current organizer subject; functions/finance/inference are preparation candidates, not published detailed depth. Mental Ability is separately named but its families are unconfirmed.', 'mathRefs':['ustet-L079','ustet-L091','ustet-L092','ustet-L094','ustet-L141','ustet-L154'], 'language':'English is a subject name, not a complete item-language rule; Mathematics and Mental Ability languages remain unknown.', 'languageRefs':['ustet-L038','ustet-L039','ustet-L041'], 'section':'mathematics-foundations-and-extensions'},
'pupcet':{'fraction':'pupcet-L091','math':'Current academic roster/depth unconfirmed; functions/inference and history/civics are curriculum candidates. Preparation lists do not define a current exam blueprint.', 'mathRefs':['pupcet-L048','pupcet-L098','pupcet-L100','pupcet-L108','pupcet-L154'], 'language':'English and Filipino are preparation candidates; current language allocation and separate/combined sections are unknown.', 'languageRefs':['pupcet-L040','pupcet-L067','pupcet-L085'], 'section':'subject-and-skill-comparisons'},
'dost-sei':{'fraction':'dost-sei-L126','math':'Official2026 Mathematics names Algebra/Geometry/Trigonometry/Statistics/Calculus; particular methods are curriculum/conditional, and2027 continuity is unconfirmed.', 'mathRefs':['dost-sei-L038','dost-sei-L122','dost-sei-L135','dost-sei-L144'], 'language':'The2026 primer explicitly assesses English and shows English samples; current2027 languages and Filipino inclusion remain unknown.', 'languageRefs':['dost-sei-L037','dost-sei-L072','dost-sei-L088'], 'section':'mathematics-foundations-and-extensions'},
'sm-foundation':{'fraction':'sm-foundation-L090','math':'Current academic roster/depth unknown; historical arithmetic/basic algebra and conditional SHS statistics/conics are different evidence from a confirmed current syllabus. A science-related numerical item does not establish Science.', 'mathRefs':['sm-foundation-L054','sm-foundation-L095','sm-foundation-L096','sm-foundation-L101','sm-foundation-L148'], 'language':'Current item languages are unknown; historical language labels and bilingual school communication do not establish an exam-language rule.', 'languageRefs':['sm-foundation-L039','sm-foundation-L045','sm-foundation-L080'], 'section':'exam-identities-and-source-limits'},
'cse-professional':{'fraction':'cse-professional-L114','math':'Current2026 PPT names basic operations/number sequence/word problems plus separate Analytical data/logic. Finer problem families/difficulty are unknown; data interpretation does not establish inferential statistics or calculus.', 'mathRefs':['cse-professional-L108','cse-professional-L109','cse-professional-L110','cse-professional-L093','cse-professional-L091','cse-professional-L120'], 'language':'Numerical and General Information use English; Verbal uses English and Filipino. Computer-variant equivalence remains unknown.', 'languageRefs':['cse-professional-L033','cse-professional-L034','cse-professional-L036'], 'section':'cse-professional-versus-cse-subprofessional'},
'cse-subprofessional':{'fraction':'cse-subprofessional-L089','math':'Current2026 PPT names basic operations/number sequence/word problems plus separate Clerical filing/spelling. Exact numerical families/difficulty and filing conventions are unknown; no separate Professional Analytical blueprint is imported.', 'mathRefs':['cse-subprofessional-L074','cse-subprofessional-L075','cse-subprofessional-L076','cse-subprofessional-L080','cse-subprofessional-L081','cse-subprofessional-L145'], 'language':'Numerical/General Information/Clerical use English; Verbal uses English and Filipino. Computer-variant equivalence remains unknown.', 'languageRefs':['cse-subprofessional-L045','cse-subprofessional-L046','cse-subprofessional-L047','cse-subprofessional-L048'], 'section':'cse-professional-versus-cse-subprofessional'}
}
fraction_id='lesson-arithmetic-number-sense-fractions-decimals-percentages'
evidence=data['evidenceIndex']
for exam,profile in profiles.items():
    for rid in [profile['fraction']]+profile['mathRefs']+profile['languageRefs']:
        assert rid in evidence and evidence[rid]['exam']==exam,(exam,rid)

for pair in data['pairs']:
    a,b=pair['examA'],pair['examB']
    assert fraction_id in pair['sharedCandidateIds']
    refs=[profiles[a]['fraction'],profiles[b]['fraction']]
    for rid in refs:
        assert rid in pair['sharingEvidence'][fraction_id][evidence[rid]['exam']]
    pair['bilateralContrast']={'sharedFacet':'Fraction-number preparation, not every decimal/percent/application facet in the whole title',
        'sharedLessonId':fraction_id,'sharedFacetRecords':refs,
        'scopeA':{'summary':profiles[a]['math'],'records':profiles[a]['mathRefs']},
        'scopeB':{'summary':profiles[b]['math'],'records':profiles[b]['mathRefs']},
        'languageA':{'summary':profiles[a]['language'],'records':profiles[a]['languageRefs']},
        'languageB':{'summary':profiles[b]['language'],'records':profiles[b]['languageRefs']},
        'extent':'Shared fraction preparation candidate; other named methods/components and language/cycle evidence differ or are unknown. No equal tested difficulty or full lesson reuse follows.'}
    pair['scopeNote']=names[a]+': '+profiles[a]['math']+' '+names[b]+': '+profiles[b]['math']+' Common fraction preparation is supported by '+refs[0]+' and '+refs[1]+'. '+names[a]+' language: '+profiles[a]['language']+' '+names[b]+' language: '+profiles[b]['language']+' These are documented evidence/preparation differences; actual required depth remains unconfirmed.'
    if 'cse-' in a or 'cse-' in b:
        other=b if 'cse-' in a else a
        section=profiles[a]['section'] if 'cse-' in a and 'cse-' in b else {'upcat':'upcat','dcat':'dcat','acet':'acet','ustet':'ustet','pupcet':'pupcet','dost-sei':'dost-undergraduate-scholarship-examination','sm-foundation':'sm-foundation-scholarship-examination'}[other]
        pair['contrastEvidence']=['overlap/cse-scope.md#'+section]
    else:
        pair['contrastEvidence']=['overlap/cet-scholarship-scope.md#'+profiles[a]['section'],'overlap/cet-scholarship-scope.md#'+profiles[b]['section']]

# Actual title boundaries are stated individually, without inspecting their bodies.
single={
'lesson-precalculus-basic-calculus-basic-derivatives':('dost-sei-L135','Derivative-method preparation is STEM-specific;2026 named Calculus is broader than the title power/product/quotient/chain methods. Exact methods/current2027 demand and other exams inclusion remain unknown.'),
'lesson-precalculus-basic-calculus-basic-integrals':('dost-sei-L135','Antiderivative/definite-integral preparation is STEM-specific. Historical2026 Calculus does not establish every integration/area method or2027 continuity; other exams current inclusion remains unknown.'),
'lesson-precalculus-basic-calculus-limits-and-continuity':('dost-sei-L135','Limits/continuity are a STEM preparation lead under historical2026 Calculus. Specific indeterminate forms, continuity tests and2027 demands are unconfirmed; sole tag is not exclusion elsewhere.'),
'lesson-trigonometry-inverse-trigonometric-functions':('dost-sei-L134','Inverse trigonometry is a STEM Pre-Calculus candidate. Historical named Trigonometry does not specify principal-value/function methods or current2027 inclusion; broader other-exam trig records do not exclude it.'),
'lesson-comprehension-skills-choosing-a-title':('upcat-L104','Selecting a suitable title is a weak UPCAT reviewer reading lead. Organizer confirms broad reading only, not current title-selection difficulty; other broad reading domains do not exclude this facet.'),
'lesson-clerical-ability-alphabetic-filing-rules':('cse-subprofessional-L131','CSC names filing; surname/name/business/title/suffix conventions are weak reviewer detail, not a universal official filing protocol. Clerical is a Subprofessional column distinction, not exclusive relevance across every exam.'),
'lesson-clerical-ability-numeric-and-chronological-filing':('cse-subprofessional-L080','Official broad filing supports only a candidate lead. Numeric/date keys, direction and tie-breaking are not specified by CSC. Separate alphabetical weak evidence does not confirm these numeric/chronological rules or exclusivity.'),
'lesson-mechanical-technical-reasoning-gear-rotations':('dost-sei-L048','Historical2026 mechanical relationships support a broad gear candidate. The title/summary external-gear direction/speed ratios and particular arrangements are not a published requirement; current2027/other exams finer mechanical scope unknown.'),
'lesson-mechanical-technical-reasoning-springs-and-weights':('dost-sei-L048','Historical2026 mechanical/electrical force relationships are broader than spring extension/stiffness and specific load models. These title/summary facets are not explicitly required; current2027 and other exams mechanical detail remain unknown.'),
'lesson-spatial-abstract-reasoning-paper-folding-and-cutting':('acet-L155','The weak spatial category explicitly does not specify folding/rotation/cube tasks. A cutting/unfolding title is an uncertain related lead, not verified ACET folding demand; no global exclusion or actual body-sharing verdict.'),
'lesson-biology-botany':('upcat-L141','Weak plant-structure/function preparation is broader than named tissues, tropisms and plant reproduction in the title. Current organizer Science does not specify Botany depth; other Biology/plant preparation cannot be excluded.'),
'lesson-biology-taxonomy-and-classification':('upcat-L138','Weak organism classification supports a taxonomy candidate; precise ranks/domains/binomial naming or evolving classification detail is not a current UPCAT blueprint. Curriculum diversity/adaptation is related, not full taxonomy scope; other Biology domains remain broad.'),
'lesson-chemistry-chemical-nomenclature':('dost-sei-L106','STEM formulas/atomic/bonding preparation provides a naming candidate; exact ionic/molecular naming conventions are not specified by historical2026 Chemistry or current2027 sources. Other Chemistry domains do not exclude nomenclature.'),
'lesson-chemistry-nuclear-chemistry':('upcat-L146','Nuclear chemistry is a weak reviewer extension. Radioactive modes/fission/fusion in the title are not confirmed current UPCAT requirements; other broad Chemistry/Physics rosters do not establish either inclusion or exclusion.'),
'lesson-chemistry-periodic-table':('upcat-L144','Periodic trends are weak reviewer preparation. Organization/electron-structure/trend exceptions in the summary exceed the published broad Science label; other atomic/chemistry candidates may relate despite absent tags, exact depth unknown.'),
'lesson-earth-science-astronomy-fossils-and-geologic-time':('upcat-L132','Fossils/strata/geologic time are weak reviewer leads. Specific relative/radiometric chronology methods are not confirmed current UPCAT scope; other broad Earth Science domains cannot be excluded.'),
'lesson-earth-science-astronomy-layers-of-the-earth':('upcat-L130','Earth layers are weak reviewer preparation. Composition and seismic-inference methods named in metadata are not confirmed detailed UPCAT scope; other Earth/geological-hazard candidates may relate, exclusivity unknown.'),
'lesson-earth-science-astronomy-water-cycle-oceanography':('upcat-L131','Water cycling/tides are weak reviewer leads. Full basic oceanography named in the title is not established by those facets or the current broad Science label; other Earth/subsystem preparation may overlap, exact demand unknown.'),
'lesson-physics-scalars-and-vectors':('upcat-L150','Scalar/vector distinction is weak reviewer preparation. Addition/resolution methods named by the title/metadata are not confirmed current UPCAT depth; other motion/quantitative preparation does not exclude them.')}
assert len(single)==19
for lesson in data['lessons']:
    if lesson['membershipClass']=='single map candidate':
        rid,limit=single[lesson['lessonId']]
        assert rid in lesson['perExamEvidence'][lesson['candidateExams'][0]],(lesson['lessonId'],rid)
        lesson['specificFacetLimit']={'records':[rid],'text':limit,
            'metadataTitle':lesson['title'],'basis':'accepted packet statement versus visible title/summary, no body inspection'}
        lesson['lessonExtent']=limit

data['status']='DRAFT specific bilateral and single-map annotations corrected; independent rechecks pending'
(ROOT/'overlap-data.json').write_text(json.dumps(data,indent=2,ensure_ascii=False)+'\n')
text='# Level 2 specific bilateral scope comparisons\n\nEach pair has a concrete common fraction-preparation facet and separately sourced scope/language limits. Different preparation records are not proof of different actual required difficulty. Existing candidate memberships and all Level1 sources remain unchanged. No body or later-level judgment.\n\n'
for pair in data['pairs']:
    a,b=pair['examA'],pair['examB'];c=pair['bilateralContrast']
    text+='## '+names[a]+' / '+names[b]+'\n\n'
    text+='Named extent: '+pair['scopeExtent']+'.\n\n'
    text+='Common facet: '+c['sharedFacet']+'. Candidate `'+c['sharedLessonId']+'`; exact records `'+c['sharedFacetRecords'][0]+'`, `'+c['sharedFacetRecords'][1]+'`.\n\n'
    for key,label in [('scopeA',names[a]+' scope'),('scopeB',names[b]+' scope'),('languageA',names[a]+' language'),('languageB',names[b]+' language')]:
        entry=c[key];text+=label+': '+entry['summary']+' Evidence: '+', '.join('`'+rid+'`' for rid in entry['records'])+'.\n\n'
    text+='Extent: '+c['extent']+' Detailed counterpart discussion: '+', '.join('[assessment section]('+p+')' for p in pair['contrastEvidence'])+'.\n\n'
(ROOT/'overlap-pairs.md').write_text(text)
ledger=(ROOT/'overlap-lessons.md').read_text()
for lesson in data['lessons']:
    if lesson['membershipClass']=='single map candidate':
        start=ledger.index('## '+lesson['title']+'\n');end=ledger.find('\n## ',start+1);end=len(ledger) if end<0 else end
        block=ledger[start:end]
        old='Extent: partial or unknown; common name lead does not prove full body or depth equivalence. Exclusivity, full body reuse and student access remain unknown.'
        new='Specific facet limit: '+lesson['specificFacetLimit']['text']+' Evidence: `'+lesson['specificFacetLimit']['records'][0]+'`. Full body reuse and student access remain unknown.'
        assert old in block,lesson['lessonId'];ledger=ledger[:start]+block.replace(old,new)+ledger[end:]
(ROOT/'overlap-lessons.md').write_text(ledger)

report=(ROOT/'overlap.md').read_text()
report=report.replace('Detailed facet contrasts are in the two sourced notes.','Every pair has a concrete bilateral facet, separate scope/language records and precise assessment links in [the 36-pair comparison](overlap-pairs.md). The two sourced notes supply broader family context.')
insert='## All 19 single-map candidates, specific evidence limits\n\nThese are selected map connections, not exclusive exam requirements. Each row uses its own accepted record and visible title/summary boundary; no body was inspected. The same annotations appear in overlap-data.json and the lesson ledger.\n\n| Existing lesson | Map candidate | Specific facet/evidence limit |\n|---|---|---|\n'
for lesson in data['lessons']:
    if lesson['membershipClass']=='single map candidate':
        entry=lesson['specificFacetLimit'];insert+='| '+lesson['title']+' | '+names[lesson['candidateExams'][0]]+' | '+entry['text']+' `'+entry['records'][0]+'` |\n'
report=report.replace('## Checks and gate',insert+'\n## Checks and gate')
(ROOT/'overlap.md').write_text(report)
print('specific pairs',len(data['pairs']),'single-map limits',len(single),'candidate memberships unchanged',data['counts']['candidateExamEdges'])
