import {createHash} from 'node:crypto';
import type {Firestore} from 'firebase-admin/firestore';
import {BANK_MARKER_ID, BUILDER_VERSION, SUMMARY_COLLECTION, buildExamContent, summaryPartId} from './_examContentBuild.js';

export type ContentKind = 'lessons' | 'questions' | 'mocks' | 'catalog' | 'gaps';
export type ContentItem = {kind: ContentKind; id: string; data: Record<string, unknown> & {version: string}};
export type ProItem = {id: string; data: Record<string, unknown> & {version: string}};
export type PlanCounts = {create: number; update: number; unchanged: number};

const underscore = (slug: string): string => slug.replaceAll('-', '_');

function canonical(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonical).join(',')}]`;
  if (value && typeof value === 'object') {
    const entries = Object.entries(value as Record<string, unknown>).filter(([, v]) => v !== undefined)
      .sort(([a], [b]) => (a < b ? -1 : 1));
    return `{${entries.map(([k, v]) => `${JSON.stringify(k)}:${canonical(v)}`).join(',')}}`;
  }
  return JSON.stringify(value ?? null);
}

const digest = (value: unknown): string => createHash('sha256').update(canonical(value)).digest('hex').slice(0, 16);

/** Matches the Dart exporter. Quantitative Science is not in this pilot. */
export function lessonQuizSize(front: Record<string, unknown>, body: string): number {
  const keys = Array.isArray(front.keyPoints) ? front.keyPoints.length : 0;
  if (!keys) return 5;
  let examples = 0, inExamples = false;
  if (front.subject === 'subject-mathematics') {
    for (const line of body.split(/\r?\n/)) {
      if (line.startsWith('## ')) inExamples = line.trim() === '## Examples';
      if (inExamples && line.startsWith('### ')) examples++;
    }
  }
  return Math.min(6, Math.max(2, keys + Math.min(2, examples)));
}

/** One lesson: frontmatter fields plus the Markdown body. Lessons are free, so there is no Pro document. */
export function lessonItem(front: Record<string, unknown>, body: string): ContentItem & {pro?: undefined} {
  const id = String(front._id ?? '');
  if (!id) throw new Error('lesson has no _id');
  const fields = {
    title: front.title ?? null, summary: front.summary ?? null, subject: front.subject ?? null,
    topic: front.topic ?? null, estimatedMinutes: front.estimatedMinutes ?? null, body,
    status: front.status ?? 'active', replacedBy: front.replacedBy ?? [],
    part: front.part ?? null, partCount: front.partCount ?? null, ordering: front.ordering ?? 0,
    keyPoints: front.keyPoints ?? [], quizSize: front.quizSize ?? lessonQuizSize(front, body),
  };
  return {kind: 'lessons', id, data: {kind: 'lessons', id, ...fields, version: digest(fields)}};
}

/**
 * One mock blueprint, stored at `content/mocks/items/{examId}`. The server reads it to assemble papers;
 * `getContent` does not serve it. Sections are kept as the JSON string the Dart sampler parses.
 */
export function blueprintItem(doc: Record<string, unknown>): ContentItem {
  const examId = String(doc.exam ?? '');
  if (!examId || !Array.isArray(doc.sections) || doc.sections.length < 1) throw new Error('blueprint needs exam and sections');
  // The mock clock is durationMinutes; without a positive number a strict mock would end at once.
  const minutes = doc.durationMinutes;
  if (typeof minutes !== 'number' || !Number.isFinite(minutes) || minutes <= 0) {
    throw new Error(`blueprint ${examId} needs a positive duration in minutes`);
  }
  const fields = {
    name: doc.name ?? null, durationMinutes: minutes,
    sectionalTiming: doc.sectionalTiming ?? null, sectionsJson: JSON.stringify(doc.sections),
  };
  return {kind: 'mocks', id: examId, data: {kind: 'mocks', id: examId, ...fields, version: digest(fields)}};
}

export type QuestionSource = {meta: Record<string, unknown>; questions: Record<string, unknown>[];
  passages?: {id: string; title?: string; body?: string}[]};

/**
 * One question set. Wrong-choice notes (`rationale` on a choice) move to the Pro document as
 * `{questionId: [note | null per choice]}`; everything else stays in the free document. Both are
 * stored as JSON strings because Firestore rejects nested arrays (figure specs use them).
 * Passage text comes from the `passages` list of the same YAML file. It travels inside the set
 * (never in the catalog), in the free document: a passage has no Pro-only fields.
 */
export function questionSetItems(source: QuestionSource, relativePath: string): {item: ContentItem; pro?: ProItem} {
  const id = `qs-${relativePath.replace(/\.ya?ml$/, '').split('/').join('__')}`;
  const notes: Record<string, (string | null)[]> = {};
  const questions = source.questions.map((question) => {
    const choices = Array.isArray(question.choices) ? question.choices as Record<string, unknown>[] : [];
    const stripped = choices.map((choice) => {
      const {rationale: _rationale, ...rest} = choice;
      return rest;
    });
    if (choices.some((choice) => typeof choice.rationale === 'string')) {
      notes[String(question.id)] = choices.map((choice) => typeof choice.rationale === 'string' ? choice.rationale : null);
    }
    return Array.isArray(question.choices) ? {...question, choices: stripped} : question;
  });
  const topic = underscore(String(source.meta.topic ?? ''));
  const defined = new Map((source.passages ?? []).map(p => [String(p.id), p]));
  const named = [...new Set(source.questions.flatMap(q => typeof q.passage === 'string' ? [q.passage] : []))];
  const served = named.map((passageId) => {
    const found = defined.get(passageId);
    if (!found || typeof found.body !== 'string') throw new Error(`${relativePath}: passage ${passageId} is not defined`);
    // wordCount is counted from the text, not typed in.
    return {id: passageId, topic: `topic_upcat_${topic}`, title: String(found.title ?? ''), body: found.body,
      language: 'en', wordCount: found.body.trim().split(/\s+/).length};
  });
  const payload = JSON.stringify({meta: source.meta, questions, ...(served.length > 0 ? {passages: served} : {})});
  const proPayload = Object.keys(notes).length > 0 ? JSON.stringify(notes) : undefined;
  const version = digest({payload, proPayload});
  const item: ContentItem = {kind: 'questions', id, data: {kind: 'questions', id, version, count: questions.length, payload}};
  return proPayload === undefined ? {item}
    : {item, pro: {id, data: {id, version, payload: proPayload}}};
}

// ---- catalog ----------------------------------------------------------------------------------
// Served as kind `catalog`; the format is written down in web/README.md ("Content catalog").

type Doc = Record<string, unknown>;
export type CatalogStructure = {exam?: Doc[]; subject?: Doc[]; topic?: Doc[]; mockBlueprint?: Doc[]; diagnosticSet?: Doc[]};
export type LessonLink = {lesson: string; requires: string; strength: 'required' | 'helpful'};
export type GapTag = {question: string; choice: string; prerequisite: string};

/** Server-only attribution data. Never included in a served catalog or question set. */
export function gapItem(tags: GapTag[]): ContentItem {
  const grouped = new Map<string, Record<string, string>>();
  for (const tag of tags) {
    const choices = grouped.get(tag.question) ?? {};
    choices[tag.choice] = tag.prerequisite;
    grouped.set(tag.question, choices);
  }
  const payload = canonical(Object.fromEntries(grouped));
  return {kind: 'gaps', id: 'tags', data: {kind: 'gaps', id: 'tags', payload, version: digest(payload)}};
}

export type CatalogInput = {links?: LessonLink[]; structure: CatalogStructure; lessons: Doc[]; sets: {source: QuestionSource; relativePath: string}[]};
/** A catalog document is split above this many bytes of JSON; Firestore allows 1 MiB per document. */
export const CATALOG_SPLIT_BYTES = 700_000;
export const CATALOG_HARD_LIMIT_BYTES = 1_000_000;

const refId = (value: unknown): string => String(value && typeof value === 'object' ? (value as Doc)._ref ?? '' : value ?? '');

/**
 * The catalog documents: `index` (every exam, subject and topic, and which exams have content) and one
 * `<examId>` per exam that has at least one question set. Lessons and questions appear as ids and
 * structure only. An exam document over `splitAbove` bytes moves its lessons and sets into parts, one per
 * subject (`<examId>.<subjectId>`), named in `parts`.
 */
export function catalogItems(input: CatalogInput, options: {splitAbove?: number; hardLimit?: number} = {}): ContentItem[] {
  const splitAbove = options.splitAbove ?? CATALOG_SPLIT_BYTES;
  const hardLimit = options.hardLimit ?? CATALOG_HARD_LIMIT_BYTES;
  const {structure} = input;
  const subjects = structure.subject ?? [];
  const topics = structure.topic ?? [];

  const nextOrdering = new Map<string, number>();
  const lessons = input.lessons.filter(front => front.isActive !== false).map((front) => {
    const id = String(front._id ?? '');
    const topic = String(front.topic ?? '').replace(/^topic-/, '');
    const fallback = (nextOrdering.get(topic) ?? 0) + 1;
    nextOrdering.set(topic, fallback);
    return {id, topic: `topic_upcat_${underscore(topic)}`, subtopic: `subtopic_${id.replace(`lesson-${topic}-`, '')}`,
      title: front.title, summary: front.summary, estimatedMinutes: front.estimatedMinutes,
      ...(front.status != null ? {status: front.status} : {}),
      ...(front.replacedBy != null ? {replacedBy: front.replacedBy} : {}),
      ...Object.fromEntries(['part', 'partCount', 'keyPoints', 'quizSize']
        .filter(key => front[key] != null).map(key => [key, front[key]])),
      ordering: typeof front.ordering === 'number' ? front.ordering : fallback,
      ...((input.links ?? []).some(link => link.lesson === id) ? {prerequisites: (input.links ?? [])
        .filter(link => link.lesson === id).map(link => ({lesson: link.requires, strength: link.strength}))
        .sort((a, b) => a.lesson.localeCompare(b.lesson))} : {})};
  });

  const sets = input.sets.map(({source, relativePath}) => {
    const meta = source.meta as {topic?: unknown; subtopic?: unknown; exams?: unknown};
    const topic = String(meta.topic);
    const subtopic = String(meta.subtopic);
    return {
      id: `qs-${relativePath.replace(/\.ya?ml$/, '').split('/').join('__')}`,
      topic: `topic_upcat_${underscore(topic)}`, subtopic: `subtopic_${subtopic}`, lesson: `lesson-${topic}-${subtopic}`,
      exams: (Array.isArray(meta.exams) ? meta.exams : []).map(code => `exam_${underscore(String(code))}`), language: 'en',
      questions: source.questions
        // Same rule as the bundled build: a figure that is not drawn yet is held back.
        .filter(q => !(q.figure != null && String(q.figure).trim() !== '' && q.figureSpec == null))
        .map(q => ({id: String(q.id), ...(typeof q.passage === 'string' ? {passage: q.passage} : {}),
          ...(q.figureSpec != null ? {figure: true} : {}),
          ...(typeof q.lesson === 'string' ? {lesson: q.lesson} : {}),
          ...(q.keyPoint != null ? {keyPoint: q.keyPoint} : {})})),
    };
  });

  const withContent = (structure.exam ?? []).map(e => String(e._id)).filter(id => sets.some(set => set.exams.includes(id)));
  const out: ContentItem[] = [];
  const add = (document: Doc & {id: string}): void => {
    const payload = JSON.stringify(document);
    const bytes = Buffer.byteLength(payload);
    if (bytes > hardLimit) throw new Error(`catalog document ${document.id} is ${bytes} bytes, over the ${hardLimit} limit`);
    out.push({kind: 'catalog', id: document.id, data: {kind: 'catalog', id: document.id, version: digest(payload), payload}});
  };

  add({id: 'index', exams: structure.exam ?? [], subjects, topics, catalogs: withContent});

  for (const examId of withContent) {
    const examSubjects = subjects.filter(s => refId(s.exam) === examId);
    const subjectOf = new Map(topics.filter(t => examSubjects.some(s => s._id === refId(t.subject)))
      .map(t => [String(t._id), refId(t.subject)]));
    const full: Doc & {id: string} = {
      id: examId,
      subjects: examSubjects,
      topics: topics.filter(t => subjectOf.has(String(t._id))),
      lessons: lessons.filter(l => subjectOf.has(l.topic)),
      sets: sets.filter(set => set.exams.includes(examId)),
      diagnosticSets: (structure.diagnosticSet ?? []).filter(d => refId(d.exam) === examId),
      mockBlueprints: (structure.mockBlueprint ?? []).filter(b => refId(b.exam) === examId),
    };
    if (Buffer.byteLength(JSON.stringify(full)) <= splitAbove) { add(full); continue; }
    const parts: string[] = [];
    const groups = [...examSubjects.map(s => String(s._id)), 'other'];
    for (const group of groups) {
      const inGroup = (topic: string): boolean => (subjectOf.get(topic) ?? 'other') === group;
      const part = {id: `${examId}.${group}`, lessons: (full.lessons as typeof lessons).filter(l => inGroup(l.topic)),
        sets: (full.sets as typeof sets).filter(set => inGroup(set.topic))};
      if (part.lessons.length + part.sets.length === 0) continue;
      parts.push(part.id);
      add(part);
    }
    add({...full, lessons: undefined, sets: undefined, parts});
  }
  return out;
}

/** Compares each item's version with what is stored. `existing` maps `kind/id` to the stored version. */
export function planWrites(items: ContentItem[], existing: Map<string, string>):
  {counts: PlanCounts; changed: ContentItem[]} {
  const counts: PlanCounts = {create: 0, update: 0, unchanged: 0};
  const changed: ContentItem[] = [];
  for (const item of items) {
    const stored = existing.get(`${item.kind}/${item.id}`);
    if (stored === undefined) counts.create += 1;
    else if (stored !== item.data.version) counts.update += 1;
    else { counts.unchanged += 1; continue; }
    changed.push(item);
  }
  return {counts, changed};
}

// ---- exam summaries ---------------------------------------------------------------------------
// One document per exam with what `loadExamContent` would build from the whole bank, so the server
// reads 2 or 3 documents instead of every lesson and question set. Plan:
// docs/superpowers/plans/2026-11-21-exam-content-summary.md.

export const SUMMARY_SPLIT_CHARS = 700_000;
const SUMMARY_HARD_LIMIT_BYTES = 1_000_000;
const BANK_KINDS = new Set<ContentKind>(['lessons', 'questions']);
const byId = <T extends {id: string}>(a: T, b: T): number => (a.id < b.id ? -1 : a.id > b.id ? 1 : 0);

/** A digest of every lesson and question-set id and version in `items`: the bank they make up. */
export function bankVersionOf(items: ContentItem[]): string {
  return digest(items.filter((item) => BANK_KINDS.has(item.kind)).map((item) => `${item.kind}/${item.id}:${item.data.version}`).sort());
}

/**
 * The exam summaries for a bank made of exactly these lesson and question-set items, in parts of at
 * most SUMMARY_SPLIT_CHARS characters. Exams come from the sets' `meta.exams`.
 */
export function summaryItems(items: ContentItem[]): {id: string; data: Record<string, unknown>}[] {
  const bankVersion = bankVersionOf(items);
  // Document id order, as the scan reads them from Firestore.
  const lessons = items.filter((item) => item.kind === 'lessons').sort(byId).map((item) => ({...item.data, id: item.id}));
  const sets = items.filter((item) => item.kind === 'questions').sort(byId).map((item) => ({id: item.id, payload: item.data.payload}));
  const slugs = new Set<string>();
  for (const set of sets) {
    try {
      const exams = (JSON.parse(String(set.payload)) as {meta?: {exams?: unknown}}).meta?.exams;
      if (Array.isArray(exams)) for (const slug of exams) if (typeof slug === 'string' && slug) slugs.add(slug);
    } catch {
      // The builder skips a malformed set too.
    }
  }
  const out: {id: string; data: Record<string, unknown>}[] = [];
  for (const slug of [...slugs].sort()) {
    const examId = `exam_${underscore(slug)}`;
    const payload = JSON.stringify(buildExamContent(examId, lessons, sets));
    const chunks: string[] = [];
    for (let start = 0; start < payload.length; start += SUMMARY_SPLIT_CHARS) chunks.push(payload.slice(start, start + SUMMARY_SPLIT_CHARS));
    if (!chunks.length) chunks.push('');
    for (const chunk of chunks) {
      if (Buffer.byteLength(chunk, 'utf8') > SUMMARY_HARD_LIMIT_BYTES) throw new Error(`exam summary ${examId} part is over ${SUMMARY_HARD_LIMIT_BYTES} bytes`);
    }
    out.push({id: examId, data: {kind: 'summaries', id: examId, bankVersion, builderVersion: BUILDER_VERSION, parts: chunks.length, payload: chunks[0]}});
    chunks.slice(1).forEach((chunk, i) => {
      const id = summaryPartId(examId, i + 1);
      out.push({id, data: {kind: 'summaries', id, bankVersion, part: i + 1, payload: chunk}});
    });
  }
  return out;
}

export type SummaryResult = 'written' | 'unchanged' | 'partial' | 'not touched';

/**
 * Idempotent upload to `content/{kind}/items/{id}` and `contentPro/{id}`. A dry run reads and
 * plans but writes nothing. The caller chooses the target; the CLI points it at the emulator
 * unless `--live` is given.
 */
export async function writeContent(db: Firestore, items: ContentItem[], pros: ProItem[],
  options: {dryRun?: boolean}): Promise<{counts: PlanCounts; proWritten: number; summaries: SummaryResult}> {
  const existing = new Map<string, string>();
  for (const kind of ['lessons', 'questions', 'mocks', 'catalog', 'gaps'] as const) {
    const snapshot = await db.collection(`content/${kind}/items`).select('version').get();
    for (const doc of snapshot.docs) existing.set(`${kind}/${doc.id}`, String(doc.get('version')));
  }
  const {counts, changed} = planWrites(items, existing);
  const changedQuestionIds = new Set(changed.filter((item) => item.kind === 'questions').map((item) => item.id));
  const proChanged = pros.filter((pro) => changedQuestionIds.has(pro.id));
  // Exam summaries are written only when this upload holds the whole stored bank (every stored lesson
  // and question set), because writes never delete: a partial upload cannot know the bank's full state.
  const markerRef = db.doc(`${SUMMARY_COLLECTION}/${BANK_MARKER_ID}`);
  const marker = await markerRef.get();
  const inputBank = new Set(items.filter((item) => BANK_KINDS.has(item.kind)).map((item) => `${item.kind}/${item.id}`));
  const covered = [...existing.keys()].filter((key) => key.startsWith('lessons/') || key.startsWith('questions/')).every((key) => inputBank.has(key));
  const bankChanging = changed.some((item) => BANK_KINDS.has(item.kind));
  const bankVersion = covered ? bankVersionOf(items) : null;
  // An upload with no lessons or question sets (only catalog, mocks or gaps) leaves summaries alone.
  const summariesDue = covered && inputBank.size > 0 && (bankChanging || !marker.exists || marker.get('bankVersion') !== bankVersion
    || marker.get('builderVersion') !== BUILDER_VERSION);
  const summaries: SummaryResult = summariesDue ? 'written' : covered && inputBank.size > 0 ? 'unchanged' : bankChanging ? 'partial' : 'not touched';
  const commitAll = async (writes: {ref: FirebaseFirestore.DocumentReference; data: Record<string, unknown>}[]): Promise<void> => {
    for (let start = 0; start < writes.length; start += 400) {
      const batch = db.batch();
      for (const write of writes.slice(start, start + 400)) batch.set(write.ref, write.data);
      await batch.commit();
    }
  };
  if (!options.dryRun) {
    // The marker goes invalid before any lesson or question changes and turns valid only after the
    // summaries, so a stop at any point leaves readers scanning the bank.
    if (bankChanging || summariesDue) await commitAll([{ref: markerRef, data: {bankVersion: `writing:${Date.now()}`}}]);
    // Pro first: a client never sees a free version whose notes are not yet stored.
    const writes: {ref: FirebaseFirestore.DocumentReference; data: Record<string, unknown>}[] = [
      ...proChanged.map((pro) => ({ref: db.doc(`contentPro/${pro.id}`), data: pro.data})),
      ...changed.map((item) => ({ref: db.doc(`content/${item.kind}/items/${item.id}`), data: item.data})),
    ];
    // A set that lost its notes must not keep a stale Pro document.
    const proIds = new Set(pros.map((pro) => pro.id));
    const staleIds = [...changedQuestionIds].filter((id) => !proIds.has(id));
    for (let start = 0; start < writes.length; start += 400) {
      const batch = db.batch();
      for (const write of writes.slice(start, start + 400)) batch.set(write.ref, write.data);
      await batch.commit();
    }
    for (let start = 0; start < staleIds.length; start += 400) {
      const batch = db.batch();
      for (const id of staleIds.slice(start, start + 400)) batch.delete(db.doc(`contentPro/${id}`));
      await batch.commit();
    }
    if (summariesDue) {
      await commitAll(summaryItems(items).map((summary) => ({ref: db.doc(`${SUMMARY_COLLECTION}/${summary.id}`), data: summary.data})));
      await commitAll([{ref: markerRef, data: {bankVersion, builderVersion: BUILDER_VERSION}}]);
    } else if (bankChanging) {
      await commitAll([{ref: markerRef, data: {bankVersion: `partial:${Date.now()}`}}]);
    }
  }
  return {counts, proWritten: proChanged.length, summaries};
}
