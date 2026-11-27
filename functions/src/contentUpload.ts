import {createHash} from 'node:crypto';
import {isDeepStrictEqual} from 'node:util';
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

export const SUMMARY_SPLIT_BYTES = 700_000;
const BANK_KINDS = new Set<ContentKind>(['lessons', 'questions']);
const byId = <T extends {id: string}>(a: T, b: T): number => (a.id < b.id ? -1 : a.id > b.id ? 1 : 0);

/** A digest of every lesson and question-set id and version in `items`: the bank they make up. */
export function bankVersionOf(items: ContentItem[]): string {
  return digest(items.filter((item) => BANK_KINDS.has(item.kind)).map((item) => `${item.kind}/${item.id}:${item.data.version}`).sort());
}

/** Splits text into parts of at most `maxBytes` UTF-8 bytes, never inside a character. */
export function splitUtf8(text: string, maxBytes: number): string[] {
  const parts: string[] = [];
  let start = 0;
  while (start < text.length) {
    let end = Math.min(text.length, start + maxBytes);
    while (Buffer.byteLength(text.slice(start, end), 'utf8') > maxBytes) end = start + Math.floor((end - start) * 0.9);
    // Do not end a part between the two halves of a surrogate pair.
    if (end < text.length && /[\uD800-\uDBFF]/.test(text[end - 1])) end -= 1;
    parts.push(text.slice(start, end));
    start = end;
  }
  return parts.length ? parts : [''];
}

/**
 * The exam summaries for a bank made of exactly these lesson and question-set items (no duplicate ids),
 * in parts of at most SUMMARY_SPLIT_BYTES. Exams come from the sets' `meta.exams`. An exam whose content
 * would not read back identically from JSON gets no summary, so the server scans for it. Throws when the
 * builder rejects the bank (for example a replacedBy cycle), which the scan would also reject.
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
    const content = buildExamContent(examId, lessons, sets);
    const payload = JSON.stringify(content);
    if (!isDeepStrictEqual(JSON.parse(payload), content)) continue;
    const chunks = splitUtf8(payload, SUMMARY_SPLIT_BYTES);
    out.push({id: examId, data: {kind: 'summaries', id: examId, bankVersion, builderVersion: BUILDER_VERSION, parts: chunks.length, payload: chunks[0]}});
    chunks.slice(1).forEach((chunk, i) => {
      const id = summaryPartId(examId, i + 1);
      out.push({id, data: {kind: 'summaries', id, bankVersion, part: i + 1, payload: chunk}});
    });
  }
  return out;
}

export type SummaryResult = 'written' | 'unchanged' | 'partial' | 'not touched';

// A batch is capped by bytes as well as by count. Summary parts run up to SUMMARY_SPLIT_BYTES each, so a
// count-only cap of 400 sent several megabytes in one commit, which missed Firestore's 60 s deadline on
// a slow link four times on Nov 28, 2026, after the lessons were live.
export const BATCH_MAX_BYTES = 2_000_000;
export const BATCH_MAX_WRITES = 400;
const COMMIT_ATTEMPTS = 4;
// gRPC DEADLINE_EXCEEDED and UNAVAILABLE. A set is idempotent, so resending a whole batch is safe.
const RETRYABLE_CODES = new Set([4, 14]);

/** Groups writes in order into batches of at most BATCH_MAX_WRITES and BATCH_MAX_BYTES (a single larger write goes alone). */
export function groupWrites<T extends {data?: unknown}>(writes: T[]): T[][] {
  const groups: T[][] = [];
  let current: T[] = [];
  let bytes = 0;
  for (const write of writes) {
    const size = Buffer.byteLength(JSON.stringify(write.data ?? null), 'utf8');
    if (current.length && (current.length >= BATCH_MAX_WRITES || bytes + size > BATCH_MAX_BYTES)) {
      groups.push(current);
      current = [];
      bytes = 0;
    }
    current.push(write);
    bytes += size;
  }
  if (current.length) groups.push(current);
  return groups;
}

/** Commits one batch, building it afresh for each attempt (a committed batch cannot be reused). */
async function commitWithRetry(commit: () => Promise<unknown>): Promise<void> {
  for (let attempt = 1; ; attempt++) {
    try {
      await commit();
      return;
    } catch (error) {
      if (attempt >= COMMIT_ATTEMPTS || !RETRYABLE_CODES.has(Number((error as {code?: unknown}).code))) throw error;
    }
  }
}

// ---- version list -----------------------------------------------------------------------------
// One index document per content kind at `content/versions/items/{kind}` holding id -> version, so a plan
// reads a handful of documents instead of one per stored content document (about 1,500). The path is under
// the server-only `content/{kind}/items/{id}` rule (no client reads it) and `versions` is not a kind that
// `getContent` serves. Process-improvement: "Upload runs read past the free tier again (Nov 28)".

export const VERSION_INDEX_COLLECTION = 'content/versions/items';
const CONTENT_KINDS = ['lessons', 'questions', 'mocks', 'catalog', 'gaps'] as const;
// Lessons are about 1,300 ids, roughly 100 KB. Over this size the index is not kept and plans scan.
const VERSION_INDEX_MAX_BYTES = 900_000;

/**
 * The documents a plan reads before it writes anything: one index document per kind plus the bank marker, or
 * (for `--full-scan`) one per stored document, estimated by the items in this upload, plus the marker. A kind
 * whose index is missing or wrong adds a scan of that kind; `writeContent` asks `beforeReads` first.
 */
export function expectedPlanReads(items: ContentItem[], options: {fullScan?: boolean}): number {
  return (options.fullScan ? items.length : CONTENT_KINDS.length) + 1;
}

/** The stored id -> version map for a kind, or null when the index is missing, unreadable, or its count disagrees. */
async function readVersionIndex(db: Firestore, kind: ContentKind): Promise<Map<string, string> | null> {
  try {
    const snapshot = await db.doc(`${VERSION_INDEX_COLLECTION}/${kind}`).get();
    if (!snapshot.exists) return null;
    const payload: unknown = snapshot.get('payload');
    const count: unknown = snapshot.get('count');
    if (typeof payload !== 'string' || typeof count !== 'number') return null;
    const parsed: unknown = JSON.parse(payload);
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) return null;
    const entries = Object.entries(parsed as Record<string, unknown>);
    if (entries.length !== count || entries.some(([, version]) => typeof version !== 'string')) return null;
    return new Map(entries as [string, string][]);
  } catch {
    return null;
  }
}

/**
 * Idempotent upload to `content/{kind}/items/{id}` and `contentPro/{id}`. A dry run reads and
 * plans but writes nothing. The caller chooses the target; the CLI points it at the emulator
 * unless `--live` is given.
 *
 * The plan reads the version list. A kind whose list is missing or wrong is scanned instead
 * (`beforeReads(n)` is called first with the estimated reads, and may throw to stop the run before any
 * write), and a live upload rewrites that list. `fullScan` scans every kind and rewrites every list.
 */
export async function writeContent(db: Firestore, items: ContentItem[], pros: ProItem[],
  options: {dryRun?: boolean; fullScan?: boolean; beforeReads?: (reads: number) => Promise<void>}):
  Promise<{counts: PlanCounts; proWritten: number; summaries: SummaryResult; bankChanges: number}> {
  const existing = new Map<string, string>();
  const stored = new Map<ContentKind, Map<string, string>>();
  const indexStale = new Set<ContentKind>();
  for (const kind of CONTENT_KINDS) {
    let versions = options.fullScan ? null : await readVersionIndex(db, kind);
    if (versions === null) {
      if (!options.fullScan) await options.beforeReads?.(Math.max(1, items.filter((item) => item.kind === kind).length));
      const snapshot = await db.collection(`content/${kind}/items`).select('version').get();
      versions = new Map(snapshot.docs.map((doc) => [doc.id, String(doc.get('version'))] as [string, string]));
      indexStale.add(kind);
    }
    stored.set(kind, versions);
    for (const [id, version] of versions) existing.set(`${kind}/${id}`, version);
  }
  const {counts, changed} = planWrites(items, existing);
  const changedQuestionIds = new Set(changed.filter((item) => item.kind === 'questions').map((item) => item.id));
  const proChanged = pros.filter((pro) => changedQuestionIds.has(pro.id));
  // Exam summaries are written only when this upload holds the whole stored bank (every stored lesson
  // and question set), because writes never delete: a partial upload cannot know the bank's full state.
  const markerRef = db.doc(`${SUMMARY_COLLECTION}/${BANK_MARKER_ID}`);
  const marker = await markerRef.get();
  const inputBank = new Set(items.filter((item) => BANK_KINDS.has(item.kind)).map((item) => `${item.kind}/${item.id}`));
  const bankItems = items.filter((item) => BANK_KINDS.has(item.kind));
  // Duplicate ids: Firestore keeps one copy, so the input is not the stored bank.
  const covered = inputBank.size === bankItems.length
    && [...existing.keys()].filter((key) => key.startsWith('lessons/') || key.startsWith('questions/')).every((key) => inputBank.has(key));
  const bankChanging = changed.some((item) => BANK_KINDS.has(item.kind));
  const bankVersion = covered ? bankVersionOf(items) : null;
  // An upload with no lessons or question sets (only catalog, mocks or gaps) leaves summaries alone.
  const summariesDue = covered && inputBank.size > 0 && (bankChanging || !marker.exists || marker.get('bankVersion') !== bankVersion
    || marker.get('builderVersion') !== BUILDER_VERSION);
  // Built before any write, dry run included, so a bank the builder rejects fails the upload untouched.
  const summaryDocs = summariesDue ? summaryItems(items) : [];
  const summaries: SummaryResult = summariesDue ? 'written' : covered && inputBank.size > 0 ? 'unchanged' : bankChanging ? 'partial' : 'not touched';
  const commitAll = async (writes: {ref: FirebaseFirestore.DocumentReference; data: Record<string, unknown>}[]): Promise<void> => {
    for (const group of groupWrites(writes)) {
      await commitWithRetry(() => {
        const batch = db.batch();
        for (const write of group) batch.set(write.ref, write.data);
        return batch.commit();
      });
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
    await commitAll(writes);
    for (const group of groupWrites(staleIds.map((id) => ({id, data: null})))) {
      await commitWithRetry(() => {
        const batch = db.batch();
        for (const {id} of group) batch.delete(db.doc(`contentPro/${id}`));
        return batch.commit();
      });
    }
    // The version list, after the content writes and before the marker turns valid. A crash before this
    // leaves an older list, which only makes the next plan rewrite documents it need not.
    const indexWrites: {ref: FirebaseFirestore.DocumentReference; data: Record<string, unknown>}[] = [];
    const indexDeletes: FirebaseFirestore.DocumentReference[] = [];
    for (const kind of CONTENT_KINDS) {
      const next = new Map(stored.get(kind));
      let touched = indexStale.has(kind);
      for (const item of changed) if (item.kind === kind) { next.set(item.id, item.data.version); touched = true; }
      if (!touched) continue;
      const payload = JSON.stringify(Object.fromEntries([...next].sort(([a], [b]) => (a < b ? -1 : 1))));
      const ref = db.doc(`${VERSION_INDEX_COLLECTION}/${kind}`);
      // Too big to keep: remove the list so no plan trusts an old one.
      if (Buffer.byteLength(payload) > VERSION_INDEX_MAX_BYTES) indexDeletes.push(ref);
      else indexWrites.push({ref, data: {kind: 'versions', id: kind, count: next.size, payload}});
    }
    await commitAll(indexWrites);
    for (const ref of indexDeletes) await commitWithRetry(() => { const batch = db.batch(); batch.delete(ref); return batch.commit(); });
    if (summariesDue) {
      await commitAll(summaryDocs.map((summary) => ({ref: db.doc(`${SUMMARY_COLLECTION}/${summary.id}`), data: summary.data})));
      await commitAll([{ref: markerRef, data: {bankVersion, builderVersion: BUILDER_VERSION}}]);
    } else if (bankChanging) {
      await commitAll([{ref: markerRef, data: {bankVersion: `partial:${Date.now()}`}}]);
    }
  }
  return {counts, proWritten: proChanged.length, summaries, bankChanges: changed.filter((item) => BANK_KINDS.has(item.kind)).length};
}
