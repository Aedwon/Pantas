// Hand-written catalog documents in the shapes `catalogItems` produces (functions/src/contentUpload.ts):
// a set tagged for two exams appears in both exam documents, a subject can exist with no set anywhere,
// lessons can live in another exam's document, and one exam document can be split into parts.
const subject = (id, exam, name, ordering) => ({_id: id, exam: {_ref: exam}, name, ordering});
const topic = (id, subjectId, name) => ({_id: id, subject: {_ref: subjectId}, name, ordering: 1});
const lesson = (id, topicId, title, ordering, extra = {}) => ({id, topic: topicId, title, ordering, ...extra});
const set = (id, topicId, lessonId, exams, questions) => ({id, topic: topicId, lesson: lessonId, exams, language: 'en', questions});

export const sci = subject('subj_sci', 'exam_alpha', 'Science', 1);
export const math = subject('subj_math', 'exam_beta', 'Mathematics', 2);
export const verbal = subject('subj_verbal', 'exam_gamma', 'Verbal Ability', 3);
export const bio = topic('topic_bio', 'subj_sci', 'Biology');
export const alg = topic('topic_alg', 'subj_math', 'Algebra');
export const vocab = topic('topic_vocab', 'subj_verbal', 'Vocabulary');
export const cells = lesson('lesson-bio-cells', 'topic_bio', 'Cells', 1);
export const genes = lesson('lesson-bio-genes', 'topic_bio', 'Genes', 2, {prerequisites: [{lesson: 'lesson-alg-eq', strength: 'required'}]});
export const equations = lesson('lesson-alg-eq', 'topic_alg', 'Equations', 1);
export const sharedSet = set('qs-bio__cells', 'topic_bio', 'lesson-bio-cells', ['exam_alpha', 'exam_beta'],
  [{id: 'bio-1'}, {id: 'bio-2', passage: 'rc-1'}]);
export const genesSet = set('qs-bio__genes', 'topic_bio', 'lesson-bio-genes', ['exam_alpha'], [{id: 'bio-3'}]);
export const algebraSet = set('qs-alg__eq', 'topic_alg', 'lesson-alg-eq', ['exam_beta'], [{id: 'alg-1'}]);

export const documents = () => ({
  index: {id: 'index', exams: [{_id: 'exam_alpha'}, {_id: 'exam_beta'}, {_id: 'exam_gamma'}],
    subjects: [sci, math, verbal], topics: [bio, alg, vocab], catalogs: ['exam_alpha', 'exam_beta']},
  exam_alpha: {id: 'exam_alpha', subjects: [sci], topics: [bio], lessons: [cells, genes], sets: [sharedSet, genesSet]},
  exam_beta: {id: 'exam_beta', subjects: [math], topics: [alg], parts: ['exam_beta.subj_math']},
  'exam_beta.subj_math': {id: 'exam_beta.subj_math', lessons: [equations], sets: [sharedSet, algebraSet]},
});

/** Documents are stored as the upload writes them: a JSON string payload and a version. */
export function fakeDb(docs = documents()) {
  const reads = [];
  const stored = new Map(Object.entries(docs).map(([id, value]) => [`content/catalog/items/${id}`,
    {payload: typeof value === 'string' ? value : JSON.stringify(value), version: `v-${id}`}]));
  const db = {reads, stored, doc: path => ({path, get: async () => {
    reads.push(path);
    const data = stored.get(path);
    return {exists: data !== undefined, get: field => data?.[field]};
  }})};
  const tx = {get: ref => ref.get()};
  return {db, tx};
}
