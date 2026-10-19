import {createHash} from 'node:crypto';
import type {Firestore} from 'firebase-admin/firestore';

export type ContentKind = 'lessons' | 'questions' | 'mocks';
export type ContentItem = {kind: ContentKind; id: string; data: Record<string, unknown> & {version: string}};
export type ProItem = {id: string; data: Record<string, unknown> & {version: string}};
export type PlanCounts = {create: number; update: number; unchanged: number};

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

/** One lesson: frontmatter fields plus the Markdown body. Lessons are free, so there is no Pro document. */
export function lessonItem(front: Record<string, unknown>, body: string): ContentItem & {pro?: undefined} {
  const id = String(front._id ?? '');
  if (!id) throw new Error('lesson has no _id');
  const fields = {
    title: front.title ?? null, summary: front.summary ?? null, subject: front.subject ?? null,
    topic: front.topic ?? null, estimatedMinutes: front.estimatedMinutes ?? null, body,
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
  const fields = {
    name: doc.name ?? null, durationMinutes: doc.durationMinutes ?? null,
    sectionalTiming: doc.sectionalTiming ?? null, sectionsJson: JSON.stringify(doc.sections),
  };
  return {kind: 'mocks', id: examId, data: {kind: 'mocks', id: examId, ...fields, version: digest(fields)}};
}

export type QuestionSource = {meta: Record<string, unknown>; questions: Record<string, unknown>[]};

/**
 * One question set. Wrong-choice notes (`rationale` on a choice) move to the Pro document as
 * `{questionId: [note | null per choice]}`; everything else stays in the free document. Both are
 * stored as JSON strings because Firestore rejects nested arrays (figure specs use them).
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
  const payload = JSON.stringify({meta: source.meta, questions});
  const proPayload = Object.keys(notes).length > 0 ? JSON.stringify(notes) : undefined;
  const version = digest({payload, proPayload});
  const item: ContentItem = {kind: 'questions', id, data: {kind: 'questions', id, version, count: questions.length, payload}};
  return proPayload === undefined ? {item}
    : {item, pro: {id, data: {id, version, payload: proPayload}}};
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

/**
 * Idempotent upload to `content/{kind}/items/{id}` and `contentPro/{id}`. A dry run reads and
 * plans but writes nothing. The caller chooses the target; the CLI points it at the emulator
 * unless `--live` is given.
 */
export async function writeContent(db: Firestore, items: ContentItem[], pros: ProItem[],
  options: {dryRun?: boolean}): Promise<{counts: PlanCounts; proWritten: number}> {
  const existing = new Map<string, string>();
  for (const kind of ['lessons', 'questions', 'mocks'] as const) {
    const snapshot = await db.collection(`content/${kind}/items`).select('version').get();
    for (const doc of snapshot.docs) existing.set(`${kind}/${doc.id}`, String(doc.get('version')));
  }
  const {counts, changed} = planWrites(items, existing);
  const changedQuestionIds = new Set(changed.filter((item) => item.kind === 'questions').map((item) => item.id));
  const proChanged = pros.filter((pro) => changedQuestionIds.has(pro.id));
  if (!options.dryRun) {
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
  }
  return {counts, proWritten: proChanged.length};
}
