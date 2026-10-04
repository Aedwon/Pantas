"""Lead's reproducible level-1 name/metadata mapping. Never reads lesson bodies."""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).parent
CORPUS = Path('/Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2')
inventory = json.loads((ROOT / 'inventory-lessons.json').read_text())
lessons = inventory['lessons']
assert len(lessons) == 158
outline = json.loads((CORPUS / 'tools/lesson_author/outline.json').read_text())
outline_rows = {}
for subject in outline['subjects']:
    for topic in subject['topics']:
        for lesson in topic['lessons']:
            outline_rows[(subject['slug'], topic['slug'], lesson['slug'])] = lesson

# Explicit vocabulary connections chosen by the lead after reading all packets.
# Indices refer to the saved, ordered metadata inventory, never body search results.
rules = [
    (r'constitution|constitutional|bill of rights|branches of government', range(8,12)),
    (r'r\.?a\.?\s*6713|public.offici[ae]l conduct|public.conduct|ethical standards|conduct norms|public ethics|corruption|gift rules', range(0,4)),
    (r'human rights|human.rights|rights and responsibilities|humanitarian|peace concepts|peace and', [6,7,9]),
    (r'environment management|environmental (?:protection|laws|problems|decisions)|environment:|protect.*resources|environmental issues', [4,5,112]),
    (r'grammar|grammatical|sentence usage|usage rules', range(12,23)),
    (r'modifier|modification|dangling', [12]),
    (r'parallel', [13]),
    (r'parts of speech|bahagi ng pananalita|word classes', [14]),
    (r'phrases|clauses', [15,19]),
    (r'pronoun|antecedent', [16]),
    (r'punctuation|capitalization|comma splice', [17,22]),
    (r'redundan|double negative|multiple negative', [18]),
    (r'sentence structure|sentence types|construct.*sentences|sentence construction|run.on', [19,22]),
    (r'agreement|wastong gamit', [20]),
    (r'tense|voice|verb aspects|pandiwa|action/event/experience', [21]),
    (r'error recognition|error identification|error location|detect errors|recognize errors|sentence correction|sentence editing|sentence errors|erroneous', [22]),
    (r'paragraph organization|paragraph order|organize paragraphs|cohesi|coheren|connector|pang.ugnay|chronolog', [23,84]),
    (r'sentence completion|complete sentences|completing sentences|fill.in', [24]),
    (r'confusing words|homonym|nang|ng,|sila|sina', [25]),
    (r'vocabulary|word meaning|word meanings|infer meanings|context clue|unfamiliar|words for context|denotati|connotati', [26,79]),
    (r'idiom|sawikain|salawikain|tayutay|figurative|figures of speech', [27,86]),
    (r'affix|root|word parts|word.part|word structure|morpholog', [28]),
    (r'spelling|misspelling|orthograph', [29]),
    (r'synonym|antonym', [30]),
    (r'algebraic expressions|manipulate expressions|simplify expressions|translation|translate.*equation|evaluate expressions', [31]),
    (r'exponent|logarithm', [32,40]),
    (r'functions|domain/range|domain and range|composition|inverse functions|function.model', [33,40]),
    (r'linear equations|inequalities|slope|graphing', [34]),
    (r'polynomial|factor|factoring', [35,46]),
    (r'quadratic|discriminant|completing the square', [36,40]),
    (r'radical|rationalization', [37]),
    (r'\bsets\b|subset|cardinality|venn|union|intersection', [38]),
    (r'systems|simultaneous|nonlinear|non.linear', [39]),
    (r'rational algebraic|rational expressions', [31,35]),
    (r'word problem|age, mixture|mixture, work|distance.*time|distance, rate|situational math|contextual mathematics', [41]),
    (r'business math|financial|finance|interest|annuit|loans?|investment|discount|commission|sales tax|payroll|wages|stocks|bonds', [42]),
    (r'divisib', [43]),
    (r'fraction|decimal|percent', [44,51]),
    (r'arithmetic|basic operations|fundamental calculation|order of operations|operate on|operations on|operations,', [44,45,47]),
    (r'prime|gcd|gcf|lcm|factors|multiples|common factors', [46]),
    (r'real.number|real numbers|rational numbers|integer|number sense|number systems|absolute value', [47,49]),
    (r'ratio|proportion|rates|rate,|speed', [48,51]),
    (r'sequence|series|patterns|fibonacci', [50,92]),
    (r'data interpretation|interpret data|tables|charts|data displays|graph data|pie graph|data presentations|\bgraphs\b', [52,67,89]),
    (r'angles|plane figures|geometric concepts', [53]),
    (r'circles|circle relations|circle properties|circle and polygon|chords|arcs|tangent|secant', [54]),
    (r'coordinate|distance formula|midpoints|rectangular', [55]),
    (r'conditional statements|converse|contraposi|conditional forms|geometric deductions|axiomatic geometry', [56,93,94]),
    (r'measurement|volume|area|perimeter|solid figures', [57]),
    (r'parallel/perpendicular|parallel and perpendicular|transversal', [58]),
    (r'polygon|quadrilateral|parallelogram', [59]),
    (r'triang|congruence|similarity|pythagorean', [60]),
    (r'derivative|differentiat', [61]),
    (r'integral|integrat|antideriv|riemann', [62]),
    (r'conic|parabola|ellipse|hyperbola', [63]),
    (r'calculus|limits/continuity|limits and continuity|continuity', [61,62,64]),
    (r'probability|probabilities|events|random.variable', [65]),
    (r'permut|combinator|combinations|counting', [66]),
    (r'statistic|scatter|correlation|regression|normal distribution|sampling|hypothes', [67,68,69]),
    (r'central tendency|mean, median|averages|median|mode\b', [68]),
    (r'variability|variance|standard deviation', [69]),
    (r'radian|degree', [70]),
    (r'trigonometr|right.triangle ratios|triangle ratios', [71,74]),
    (r'inverse trigonometr', [72]),
    (r'law[s]? of sines|law[s]? of cosines|oblique', [73]),
    (r'elevation|depression|solve right triangles', [74]),
    (r'identit', [75]),
    (r'unit.circle|circular functions|standard angles', [76]),
    (r'author|purpose|tone|mood|point of view|intent|bias', [77]),
    (r'appropriate title|suitable title', [78]),
    (r'fact.*opinion|claims|assertion|counterclaim|information judgment', [80,81]),
    (r'infer|implied|implicit|conclusion|evidence|justify|judgment|critical read', [81]),
    (r'main idea|key idea|main points|main messages|important ideas|topic sentence|paksa|text.s topic', [82]),
    (r'\bread\w*\b|comprehension|scann|skimm|explicit|specific details|retrieve details|supporting details', [81,82,83]),
    (r'sequence.*event|sequencing|chronolog|narrative connectors', [84]),
    (r'essay|editorial|article|informational text|academic text|academic writing|text.development|persuasi', [85]),
    (r'poem|poetry|imagery|literary devices', [86]),
    (r'story|stories|novel|literary|genre|characters|conflict|plot', [87]),
    (r'speeches|speech context|speech style|speech acts|speaker purpose|oral communication', [88]),
    (r'visual information|visual media|comic|cartoon|illustrations|diagrams|non.linear|nonlinear text', [89]),
    (r'filing|alphabet|sort names|personal names|business.organization', [90,91]),
    (r'letter sequence|number sequence|numerical patterns|numerical sequences', [92,50]),
    (r'syllogism|deductive|fallac|validity|logical arguments|logical relationships', [93]),
    (r'logic|proposition|truth|tautolog|contradiction|logical operations', [94,93]),
    (r'analog|word relationship|verbal relationships|verbal relations', [95]),
    (r'fluid|hydraul|pressure', [96,147]),
    (r'gear|rotation direction', [97]),
    (r'mechanical:|mechanical/electrical|mechanical reasoning', [96,97,98,99,100]),
    (r'pulley|lever|mechanical advantage|simple.*machine|balance|fulcrum', [98]),
    (r'spring|weights', [99]),
    (r'stability|center of gravity', [100]),
    (r'odd.one|figure grouping', [101]),
    (r'matrices|matrix|number grids|boxes of cells', [102]),
    (r'figural patterns|figure series|next shape|nonverbal patterns|abstract patterns|pattern recognition|shape orientation', [103,101,102]),
    (r'spatial|visualize|rotate.*objects|rotation|cube|disassemble|shadows', [104]),
    (r'paper.fold|folding|cutting', [105]),
    (r'assumption|argument|draw.*conclusion', [106]),
    (r'botany|plant structures|plant reproduction|tropism|plant tissue', [107]),
    (r'cells|cell |cellular organization|organelle|membrane|transport|microscope', [108]),
    (r'photosynth|respiration|cellular energy|metaboli|bioenerget', [109]),
    (r'cell division|mitosis|meiosis|cell cycle|reproduction', [110]),
    (r'levels of organization|biological organization|living systems|life science', [111,108,112]),
    (r'ecolog|ecosystem|food web|energy flow|energy and matter cycling|biodiversity|population|symbiosis', [112]),
    (r'evolut|adaptation|natural selection|species diversity', [113]),
    (r'heredit|inherit|genetic|dna|rna|mutat|gene expression|mendel|sex.link', [114]),
    (r'anatomy|body systems|organ systems|organs|digestive|digestion|circulatory|circulation|feedback|physiolog', [115]),
    (r'classif.*organism|taxonomy|diversity|binomial', [116]),
    (r'acids|bases|\bph\b|neutralization', [117]),
    (r'atomic structure|particles|particle nature|particle models|ions|isotope|atomic rearrangements', [118,124,125]),
    (r'organic|carbon compounds|hydrocarbon|functional groups|biomolecule', [119]),
    (r'bonding|polarity|molecular structure|molecular properties|lewis|vsepr', [120]),
    (r'nomenclature|formulas|naming compounds', [121]),
    (r'chemical change|chemical reactions|balanced equations|balance.*equations|reaction types|reaction patterns|redox', [122]),
    (r'gas laws|gas behavior|gas relationships|ideal gases|\bgases\b|kinetic molecular|pressure.volume.temperature', [123]),
    (r'atomic model|history of the atom', [124]),
    (r'\bmatter\b|substances|states|phase changes|elements/compounds', [125]),
    (r'mixture|separation|filtration|distillation', [126]),
    (r'\bmole\b|molar mass|mole conversions|mass.mass|mole.mass|mole.mole', [127,132]),
    (r'nuclear|fission|fusion|radioact', [128]),
    (r'periodic|trends', [129]),
    (r'quantum|electron configuration', [130]),
    (r'solution[s]?|solubility|concentration|dilution|molarity|molality', [131]),
    (r'stoichiom|limiting|reactants/products|reaction quantities|reaction amounts|chemical reaction rates and amounts|yield|conservation of mass', [132,122]),
    (r'kinetic|reaction rate|reaction conditions|catalyst|enthalpy|thermochemistry|endothermic|reaction energy|factors.*reaction', [133]),
    (r'seasons|earth.s motion|rotation, revolution|precession', [134]),
    (r'earth systems|earth subsystems|life.supporting|lithosphere|atmospher|hydrosphere', [135]),
    (r'eclipse|moon phase', [136]),
    (r'fossil|geologic time|strata|stratigraph', [137]),
    (r'solar.system|stars|stellar|astronomy|space science|comet|galax', [138,141]),
    (r'earth layers|layers of.*earth', [139]),
    (r'rock|mineral|earth materials|landform', [140]),
    (r'universe|solar.system origins|nebular', [141]),
    (r'plate|fault|earthquake|volcano|geolog|hazard mitigation', [142]),
    (r'water cycl|ocean|tides', [143]),
    (r'weather|climate|monsoon|itcz|breezes|tropical cyclone|typhoon|climatic', [144]),
    (r'newton|forces|\bforce\b|dynamics|friction', [145]),
    (r'electric|magnet|circuit|charging|generator|motor', [146]),
    (r'gravitation|gravity|kepler', [148]),
    (r'motion|kinematic|distance/speed|distance and speed', [149]),
    (r'light|optics|optical|reflection|refraction|lens|mirror', [150]),
    (r'momentum|impulse|collision', [151]),
    (r'scalar|vector|relative motion', [152]),
    (r'\bheat\b|thermodynamic|thermal|energy transfer', [153]),
    (r'projectile|rotational motion|two.dimensional|circular motion', [154]),
    (r'units|measurement|conversion|dimensional|measure effects', [155]),
    (r'waves|sound|wavelength|doppler', [156]),
    (r'\bwork\b|\benergy\b|\bpower\b|machine efficiency', [157]),
]

# Named facets without a clear title/summary lead, never confirmed body omissions.
unclear = {
    r'annuit|loans?|stocks|bonds|payroll|wages': 'advanced finance beyond the business-math price/discount/interest summary',
    r'quartiles?|deciles?|percentiles?|measures of position|positional measures': 'measures of position',
    r'normal probabil|normal distribution|standard scores|z scores|random.variable|probability distributions': 'random-variable/normal-distribution inference',
    r'sampling|estimation|confidence intervals|hypothesis|type i|type ii|correlation|regression': 'sampling/estimation/testing/correlation/regression depth',
    r'rational expressions|rational equations|rational algebraic': 'rational-expression/equation methods beyond the named algebra leads',
    r'variation|induction|polar coordinates|counterexamples|proof': 'variation/induction/polar-coordinate/proof methods as applicable',
    r'modals|reflexive|intensive pronouns|reported speech|direct/indirect speech|direct/reported speech': 'modals/reflexives/reported-speech details',
    r'filipino|pang.uri|pang.abay|pang.ugnay|pandiwa|sawikain|salawikain|bahagi|wastong': 'Filipino instruction and exact Filipino competencies require body/language checking',
    r'argument writing|compose|essay|write critical|writing/reasoning|writing:|argumentative|persuasive text': 'productive writing/essay teaching and worked composition',
    r'speech acts|speech context|speech style|communication breakdown|repair strategies|pragmatic': 'pragmatic speech-act/context/repair skills',
    r'biomolecules|biological molecules|enzyme|biotechnology|desired traits': 'biomolecules/enzymes/biotechnology details',
    r'microscope|variables|controls|controlled|scientific inquiry|investigation': 'inquiry design, variables/controls or microscope technique',
    r'equilibrium|relativity': 'chemical equilibrium or relativity as applicable',
    r'constellation': 'seasonal/nightly constellations',
    r'itcz|breezes|el nino|philippine resources|archipelago|geothermal|resource use|rocks/resources': 'named Philippine resources, weather mechanisms or resource/geothermal applications',
    r'chemical handling|safe chemical|household|product composition|electrical safety|energy efficiency': 'household/product/safety-specific applications',
    r'current events|contemporary issues|history, geography|history/culture|world history|economics|inflation|maps/atlases': 'history/geography/culture/economics/current-event scope beyond the named General Information lessons',
}

def clean(text):
    return re.sub(r'[*`]', '', text).lower()

def vocabulary_match(pattern,text):
    # A stem may begin a real word, but may never begin inside another word.
    # Explicit whole-word endings handle polysemous short tokens such as "mode".
    return re.search(r'(?<![a-z0-9])(?:'+pattern+r')',text)

def extract(exam):
    path = ROOT / 'requirements' / f'{exam}.md'
    rows = []
    section = None
    group = ''
    evidence = 'context'
    for lineno, raw in enumerate(path.read_text().splitlines(), 1):
        if raw.startswith('## '):
            section = int(re.match(r'## (\d+)', raw).group(1))
            group, evidence = raw, 'context'
            continue
        if section not in (2,3) or not raw.strip():
            continue
        if raw.startswith('#'):
            group = raw.lstrip('# ').strip()
            label=clean(group)
            if label.startswith(('confirmed','supported','unknown')):
                evidence=label
            continue
        if re.match(r'^\*\*(?:Confirmed|Supported|Unknown)[^*]*\*\*(?:$|\s*\()', raw) or (raw.startswith('**') and raw.endswith('**') and ':' not in raw[:-2]):
            label = clean(raw)
            if label.startswith(('confirmed','supported','unknown')):
                evidence = label
            else:
                group = raw.strip('*')
            continue
        bullet = bool(re.match(r'^\s*- ', raw))
        candidate_table = raw.startswith('|') and not raw.startswith(('| Candidate','|---'))
        if raw.startswith('|') and not candidate_table:
            continue
        kind = 'subject' if section == 2 else 'skill'
        if not bullet and not candidate_table:
            if evidence.startswith('unknown'):
                ev = 'unknown'
            elif raw.startswith('**Supported, weak:'):
                ev = 'supported, weak'
            elif raw.startswith('**Unknown'):
                ev = 'unknown'
            else:
                kind, ev = 'context', 'context'
        else:
            ev = evidence
            prefix = re.match(r'^-\s*(supported, curriculum|supported, weak|unknown):', clean(raw))
            if prefix:
                ev = prefix.group(1)
            if section == 2:
                ev = 'reported subject; inspect exact source qualifier'
        if 'curriculum' in ev:
            confidence = 'curriculum preparation'
        elif 'weak' in ev:
            confidence = 'weak preparation'
        elif ev.startswith('confirmed'):
            confidence = 'official domain/skill; see exact qualifiers'
        else:
            confidence = 'unknown/context; see exact qualifiers'
        if section == 2 and 'weak' in clean(raw):
            confidence = 'weak reported subject'
        elif section == 2 and 'official' in clean(raw):
            confidence = 'official; see cycle/language qualifiers'
        rows.append({'id':f'{exam}-L{lineno:03d}', 'exam':exam, 'line':lineno,
                     'group':group, 'kind':kind, 'evidence':ev, 'confidence':confidence,
                     'text':raw.strip(), 'requirementPath':str(path.relative_to(ROOT))})
    return rows

all_rows = []
exam_names = {'upcat':'UPCAT','dcat':'DCAT','acet':'ACET','ustet':'USTET',
              'pupcet':'PUPCET','dost-sei':'DOST-SEI undergraduate',
              'sm-foundation':'SM Foundation','cse-professional':'CSE Professional',
              'cse-subprofessional':'CSE Subprofessional'}
for exam in exam_names:
    rows = extract(exam)
    for row in rows:
        text = clean(row['text'])
        unknown = row['evidence'].startswith('unknown') or text.startswith(('- unknown', '- no specific curriculum', '- current detailed', '- current english topic', '- current meaning', '- current reasoning topic', '- current exam-essay', '- specific disciplines', '- specific topics', '- specific grammar', '- specific comprehension', '- supported, curriculum: no specific', '- filipino: sources'))
        constraint = 'conflicts and limits' in clean(row['group']) or text.startswith('- the 2027 application page establishes')
        context = row['kind'] == 'context'
        indices = set()
        # Only positive candidate wording supplies connections. Original full text stays intact.
        positive = text.split('[')[0].replace('pre-calculus','precalculus')
        positive = re.split(r'\. (?:these|this|no |current |exact |actual |whether |the curriculum|the guide|school logic|completion|grade |detailed |required depth)|\b(?:does not|do not|not proof|not a |without |unknown|unconfirmed|unverified|not verified|no claim)', positive)[0]
        if not unknown and not context and not constraint:
            for pattern, targets in rules:
                if vocabulary_match(pattern, positive):
                    indices.update(targets)
        notes = [description for pattern,description in unclear.items() if vocabulary_match(pattern,positive)] if not unknown and not context and not constraint else []
        # Non-mathematical language about composition/relationships is not a math function.
        lang = re.search(r'english|filipino|language|reading|verbal|vocabulary|grammar|essay|literary', clean(row['group']))
        if lang and not re.search(r'math|numerical|analytical|logic|general information', clean(row['group'])):
            indices = {i for i in indices if not 31 <= i <= 76 and i < 107}
        group_text = clean(row['group'])
        if re.search(r'mathematics|numerical|statistics|geometry|trigonometry', group_text):
            # "Work" in an algebra word problem is not a Physics lesson connection.
            indices = {i for i in indices if 31 <= i <= 76 or i in (92,93,94,106,155)}
        elif re.search(r'science|biology|chemistry|physics|earth|space', group_text):
            # Organ systems are not systems of equations; atomic matter is not finance.
            indices = {i for i in indices if i >= 96 or i in (52,67,89)}
        elif 'clerical' in group_text:
            indices = {i for i in indices if i in (29,90,91)}
            if re.search(r'alphabet|personal names|surnames',positive):
                indices.discard(91)
        elif 'general information' in group_text or 'general knowledge' in group_text:
            indices = {i for i in indices if i < 12 or i >= 107 or 77 <= i <= 89 or i==106}
        # Same word, different action: mechanical balance, imagined rotation,
        # numerical sequences and physical systems require their actual context.
        if 98 in indices and not re.search(r'pulley|lever|machine|fulcrum|mechanical|balance.*objects',positive):
            indices.discard(98)
        if 104 in indices and not re.search(r'spatial|visualiz|disassemble|objects|cube|shadows|shape orientation',positive):
            indices.discard(104)
        if 39 in indices and not re.search(r'(?:systems|simultaneous).*equation|equation.*systems|nonlinear|non.linear|in two variables',positive):
            indices.discard(39)
        if re.search(r'paragraph|cohesi|connector|events|discourse',positive) and not re.search(r'numerical|number|letter|arithmetic|geometric',positive):
            indices.difference_update((50,92))
        if not re.search(r'math|numerical|statistics|calculus',group_text):
            indices.difference_update((61,62,64))
        if re.search(r'math|numerical|statistics',group_text):
            notes=[n for n in notes if not n.startswith(('productive writing','inquiry design'))]
        if not re.search(r'math|numerical|statistics|logic',group_text):
            notes=[n for n in notes if not n.startswith('variation/induction')]
        if not re.search(r'compose\s+(?!functions)|argument writing|writing/reasoning|writing:|write critical|writing.*organize|writing.*coherent',positive):
            notes=[n for n in notes if not n.startswith('productive writing')]
        if constraint:
            status='CONSTRAINT OR SOURCE CONFLICT'
            indices=set()
            notes=['Source/cycle/composition constraint; no teaching connection follows from this statement.']
            row['kind']='constraint'
            row['confidence']='constraint; see exact source qualifiers'
        elif unknown:
            status = 'UNKNOWN'
            row['confidence']='unknown connection/depth; see exact source qualifiers'
        elif context:
            status = 'CONTEXT'
        elif not indices:
            status = 'APPARENT GAP OR UNSPECIFIED CONNECTION'
            notes.append('No specific positive title/metadata connection assigned; source scope may be broad or unconfirmed.')
        else:
            status = 'PARTIAL NAME LEADS' if notes else 'PROVISIONAL NAME LEADS'
        row.update({'status':status, 'lessonIds':[lessons[i]['metadata__id'] for i in sorted(indices)],
                    'lessonPaths':[lessons[i]['path'] for i in sorted(indices)],
                    'uncertainties':notes,
                    'availability':'unknown: no corpus-bound runtime availability evidence',
                    'coverage':'not evaluated: lesson bodies/examples/prerequisites/practice deferred'})
    families = [(r'language proficiency.*broad domain',lambda l:l['subject']=='language-proficiency'),
                (r'^- english is',lambda l:l['subject'] in ('language-proficiency','reading-comprehension')),
                (r'^- mathematics[, ]',lambda l:l['subject']=='mathematics'),
                (r'^- science[, ]',lambda l:l['subject']=='science'),
                (r'^- biology\.',lambda l:l['topic']=='biology'),
                (r'^- chemistry\.',lambda l:l['topic']=='chemistry'),
                (r'^- physics\.',lambda l:l['topic']=='physics'),
                (r'^- earth science\.',lambda l:l['topic']=='earth-science-astronomy'),
                (r'^- algebra\.',lambda l:l['topic']=='algebra'),
                (r'^- geometry:',lambda l:l['topic']=='geometry'),
                (r'^- mental ability is',lambda l:l['subject']=='reasoning'),
                (r'^- passage meaning',lambda l:l['subject']=='reading-comprehension')]
    by_id={l['metadata__id']:l for l in lessons}
    for row in rows:
        if row['status'] != 'APPARENT GAP OR UNSPECIFIED CONNECTION':
            continue
        for pattern,predicate in families:
            if re.search(pattern,clean(row['text'])):
                lids=sorted({lid for x in rows if x['kind']=='skill' for lid in x['lessonIds'] if predicate(by_id[lid])})
                if lids:
                    row['lessonIds']=lids
                    row['lessonPaths']=[by_id[lid]['path'] for lid in lids]
                    row['status']='PARTIAL NAME LEADS'
                    row['uncertainties']=['Broad family has related finer candidate connections in this exam packet; tested depth and subtest placement remain unconfirmed.']
        if re.search(r'calculating devices|calculations must respect|application page establishes delivery|reviewer 16 says numerical',clean(row['text'])):
            row['status']='CONSTRAINT OR SOURCE CONFLICT'
            row['lessonIds'],row['lessonPaths']=[],[]
            row['uncertainties']=['Administrative/format/source-conflict constraint, not a missing teaching unit.']
    # Composite organizer domain statements must retain every named discipline.
    for row in rows:
        if row['evidence'].startswith('confirmed') and re.search(r'biology, chemistry, earth science, physics, and space science|algebra, geometry, trigonometry, statistics, and calculus',clean(row['text'])):
            science='biology' in clean(row['text'])
            lids={lid for finer in rows if finer['kind']=='skill' and finer['status'] not in ('UNKNOWN','CONTEXT','CONSTRAINT OR SOURCE CONFLICT') and ('science' if science else 'mathematics') in clean(finer['group']) for lid in finer['lessonIds'] if by_id[lid]['subject']==('science' if science else 'mathematics')}
            row['lessonIds']=sorted(set(row['lessonIds'])|lids)
            row['lessonPaths']=[by_id[lid]['path'] for lid in row['lessonIds']]
            row['status']='PARTIAL NAME LEADS'
            row['uncertainties'].append('Each named historical2026 domain uses its finer candidate leads; scope/depth and2027 continuity remain unconfirmed.')
    # Broad section2 labels never use their language-of-delivery clauses as content.
    for row in rows:
        if row['kind'] != 'subject' or row['status'] in ('UNKNOWN','CONSTRAINT OR SOURCE CONFLICT'):
            continue
        full=clean(row['text'])
        label=full.split('|')[1].strip() if full.startswith('|') else full.split(':')[0].strip('- ')
        targets=set()
        domain_patterns=[]
        allowed=lambda l:False
        if 'personality' in label:
            row['status']='UNKNOWN'
            row['confidence']='unknown academic classification'
            row['lessonIds'],row['lessonPaths']=[],[]
            row['uncertainties']=['Recalled personality questionnaire is not classified as an academic teaching requirement.']
            continue
        if label.startswith('languages'):
            row['status']='CONSTRAINT OR SOURCE CONFLICT'
            row['lessonIds'],row['lessonPaths']=[],[]
            row['uncertainties']=['Language/cycle observation, not additional academic content.']
            continue
        if 'general information' in label:
            domain_patterns=['general information'];allowed=lambda l:l['subject']=='general-information'
        elif 'general knowledge' in label or 'general intelligence' in label:
            domain_patterns=['general knowledge','general intelligence'];allowed=lambda l:l['subject'] in ('general-information','science','reading-comprehension')
        elif 'clerical' in label:
            domain_patterns=['clerical'];allowed=lambda l:l['metadata__id'] in {lessons[i]['metadata__id'] for i in (29,90,91)}
        elif 'analytical' in label:
            domain_patterns=['analytical'];allowed=lambda l:l['subject'] in ('reasoning','mathematics','reading-comprehension')
        elif 'essay' in label:
            domain_patterns=['essay'];allowed=lambda l:l['subject'] in ('language-proficiency','reading-comprehension')
        elif 'abstract' in label or 'nonverbal' in label:
            domain_patterns=['abstract','reasoning preparation','mental ability'];allowed=lambda l:l['topic']=='spatial-abstract-reasoning'
        elif 'mental ability' in label:
            domain_patterns=['mental ability'];allowed=lambda l:l['subject']=='reasoning'
        elif 'statistics' in label:
            domain_patterns=['statistics'];allowed=lambda l:l['topic'] in ('statistics-and-probability','data-interpretation')
        elif 'mathematics' in label or 'numerical' in label:
            domain_patterns=['mathematics','numerical'];allowed=lambda l:l['subject']=='mathematics'
        elif 'science' in label:
            domain_patterns=['science'];allowed=lambda l:l['subject']=='science'
        elif 'language proficiency' in label and 'reading comprehension' in label:
            domain_patterns=['language proficiency','reading comprehension','english','language'];allowed=lambda l:l['subject'] in ('language-proficiency','reading-comprehension')
        elif 'language proficiency' in label:
            domain_patterns=['language proficiency','language preparation'];allowed=lambda l:l['subject']=='language-proficiency'
        elif 'reading comprehension' in label:
            domain_patterns=['reading comprehension'];allowed=lambda l:l['subject']=='reading-comprehension'
        elif 'english' in label or 'verbal' in label:
            domain_patterns=['english','verbal'];allowed=lambda l:l['subject'] in ('language-proficiency','reading-comprehension')
        elif '2026 structure' in label:
            domain_patterns=['part i','part ii','part iii'];allowed=lambda l:True
        for finer in rows:
            if finer['kind'] == 'skill' and finer['status'] not in ('UNKNOWN','CONTEXT','CONSTRAINT OR SOURCE CONFLICT'):
                finer_group=clean(finer['group'])
                if not any(pattern in finer_group for pattern in domain_patterns):
                    continue
                for lid in finer['lessonIds']:
                    if allowed(by_id[lid]):
                        targets.add(lid)
        row['lessonIds'] = sorted(targets)
        row['lessonPaths'] = [next(x['path'] for x in lessons if x['metadata__id']==lid) for lid in row['lessonIds']]
        if targets:
            row['status'] = 'PARTIAL NAME LEADS'
            row['uncertainties'].append('Broad area uses only finer candidate connections in this packet; exact depth, language and subject boundaries remain as sourced.')
        else:
            row['status']='UNKNOWN BROAD SCOPE CONNECTION'
            row['uncertainties'].append('Broad reported label has no detailed sourced connection assigned here; not a confirmed missing subject.')
    all_rows.extend(rows)

catalog = {'corpusCommit':inventory['corpusCommit'], 'requirementsAccepted':True,
           'method':'Lead-authored explicit vocabulary links to paths/frontmatter/outline names only. Every line in requirement sections2-3 is accounted for; compound skills remain partial leads, never teaching verdicts.',
           'rows':all_rows}
(ROOT / 'maps').mkdir(exist_ok=True)
(ROOT / 'requirement-map.json').write_text(json.dumps(catalog,indent=2,ensure_ascii=False)+'\n')
for exam,name in exam_names.items():
    rows = [x for x in all_rows if x['exam']==exam]
    text = f'# {name}: provisional level1 exam map\n\n'
    text += f'Accepted source packet: [requirements/{exam}.md](../requirements/{exam}.md). Corpus `{inventory["corpusCommit"]}`. Each row retains exact source qualifiers and original line locator. Organizer-confirmed scope, curriculum preparation and weak leads remain distinct. DOST2026 scope is historical;2027 continuity is unknown. No unpublished blueprint becomes complete coverage.\n\n'
    text += 'Names, frontmatter summaries and outline labels supply leads only. No lesson body, example, prior knowledge, practice quality or availability verdict is made. Every compound row remains incomplete until each constituent skill is checked at level3. Filipino titles are candidate leads; English metadata cannot prove Filipino instruction. An apparent gap means no adequate name-level connection, not missing teaching. Runtime availability is unknown for all nine exams.\n\n'
    for row in rows:
        text += f'## {row["id"]}: {row["group"]}\n\n'
        text += f'Source locator: [line{row["line"]}](../{row["requirementPath"]}#L{row["line"]}). Kind: {row["kind"]}. Evidence: {row["confidence"]}.\n\n'
        text += row['text']+'\n\nStatus: '+row['status']+'.\n\n'
        if row['lessonIds']:
            for lid,path in zip(row['lessonIds'],row['lessonPaths']):
                text += f'- `{lid}`: `{path}`\n'
            text += '\n'
        else:
            text += 'Lesson connection: none assigned for this unknown/context/apparent-gap row.\n\n'
        if row['uncertainties']:
            text += 'Unmatched or unconfirmed facets:\n\n'+''.join('- '+n+'\n' for n in row['uncertainties'])+'\n'
    (ROOT / 'maps' / f'{exam}.md').write_text(text)

# One complete corpus list, with lesson-only provisional exam tags and evidence edges.
corpus_rows=[]
for l in lessons:
    links=[x for x in all_rows if l['metadata__id'] in x['lessonIds']]
    tags=sorted({x['exam'] for x in links})
    corpus_rows.append({**l,'outlinePresent':(l['subject'],l['topic'],l['slug']) in outline_rows,
                       'provisionalExamTags':tags,'evidenceRows':[x['id'] for x in links],
                       'tagNote':'All tags are uncertain name-level relevance. Source tier/cycle and partial facets are in the linked exam-map rows. No body or runtime confirmation.',
                       'availability':'unknown'})
(ROOT/'lesson-exam-tags.json').write_text(json.dumps({'corpusCommit':inventory['corpusCommit'],'lessons':corpus_rows},indent=2,ensure_ascii=False)+'\n')

text='# Outline comparison and nine provisional exam maps\n\n'
text+='Level1 only. All-nine requirement/source/rebuild gate accepted before this mapping. Read-only corpus: `'+inventory['corpusCommit']+'`. No lesson bodies read. No overlap extent, structure, standards or quiz work performed.\n\n'
text+='## Corpus reconciliation\n\n'
text+='The actual authored corpus has158 lessons across six subjects. The stored outline has141 lesson units across five populated subjects plus an empty General Information subject placeholder, six subject records and25topics total. The original Google tab lacks the General Information subject and the additional clerical/data/argument lesson units recorded below. The original text capture also combines inference and fact/opinion in one bullet; these are two actual lesson units. Nested bullets do not establish an exact original-tab lesson count. Existing prose/title differences remain in the historical pilot capture. No original tab changes are authorized. Runtime offering/lesson availability remains unknown because no runtime input bound to this corpus commit was verified. Authored presence and provisional exam relevance do not establish offered access.\n\n'
text+='Inventory lessons absent from the stored outline:\n\n'
for l in corpus_rows:
    if not l['outlinePresent']:text+='- `'+l['path']+'`\n'
text+='\n## Per-exam maps\n\n'
for exam,name in exam_names.items():
    text+=f'- [{name}](maps/{exam}.md): its sourced subjects, topics, skills, uncertainty and lesson leads.\n'
text+='\nThe machine-readable requirement-map.json retains every nonheading record in requirement sections2-3, including unknowns and context. Each positive row links unique lesson IDs and paths. Compound rows remain partial until each skill is checked from bodies. lesson-exam-tags.json lists every authored lesson exactly once and derives lesson-only tags from these edges; no subject/topic tags are adopted from legacy outline metadata.\n\n'
text+='## Complete authored corpus, provisional lesson tags\n\n'
last=None
for l in corpus_rows:
    group=(l['subject'],l['topic'])
    if group!=last:
        text+=f'\n### {l["subject"]} / {l["topic"]}\n\n';last=group
    tag=', '.join(l['provisionalExamTags']) or 'no specific source-backed name connection assigned'
    text+=f'- {l["metadata_title"]} [`{l["metadata__id"]}`], tags: {tag}. UNCERTAIN, provisional.\n'
text+='\n## Historical pilot findings retained for later confirmation\n\n'
text+='The prior UPCAT Science draft is preserved in outline-comparison-upcat-science-historical.md. Its leads concern biomolecules/biotechnology/microscope use, stability, Philippine resources/weather mechanisms, constellations, equilibrium and relativity. These are not current body-confirmed omissions. Stability now has a cross-subject title lead in Reasoning; chemical reaction/organic/metabolism titles supply related leads but do not prove biomolecule or equilibrium depth. The current maps explicitly retain those unresolved facets and distinguish curriculum support from weak advanced-science leads. No split/removal recommendation is confirmed at level1.\n\n'
text+='Counting check and Google audited-tab readback remain pending. No complete-coverage claim is made.\n'
(ROOT/'outline-comparison.md').write_text(text)
print('maps',len(exam_names),'inventory',len(corpus_rows),'requirement records',len(all_rows),'outline omissions',sum(not l['outlinePresent'] for l in corpus_rows))
