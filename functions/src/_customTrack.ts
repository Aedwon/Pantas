import {readFileSync} from 'node:fs';
import {join} from 'node:path';
import type {DocumentSnapshot, Firestore, Transaction} from 'firebase-admin/firestore';
import {HttpsError} from 'firebase-functions/v2/https';
import {ID_PATTERN} from './content.js';
import {examCatalog} from './revenuecatPasses.js';
import type {PriceTier} from './revenuecatCoverage.js';

/** What `CustomTrackRepository.create` makes: `exam_custom_` plus a lowercase version 4 uuid. */
export const CUSTOM_EXAM_ID = /^exam_custom_[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
export const isCustomExamId = (id: unknown): id is string => typeof id === 'string' && CUSTOM_EXAM_ID.test(id);
/** A listed exam or a custom one. Format only: every reader stays scoped to the signed-in account. */
export const isStudyExamId = (id: unknown): id is string =>
  typeof id === 'string' && (examCatalog.some(e => e.id === id) || CUSTOM_EXAM_ID.test(id));
export const customTrackRef = (db: Firestore, uid: string, examId: string) =>
  db.doc(`users/${uid}/server/customTracks/items/${examId}`);
export const MAX_CUSTOM_TRACKS = 50;

/** Choice 1A: every custom exam draws on the whole corpus. A later narrowing changes only this function. */
export const inCustomCorpus = (_set: {id: string; exams: string[]}): boolean => true;

export type CustomBlueprint = {
  sectionsJson: string; totalQuestions: number; totalMinutes: number; sectionsTimedSeparately: boolean; updatedAt: number;
};
export type CustomBlock = {name?: string; blueprint?: CustomBlueprint};

const MAX_NAME = 80, MAX_SECTIONS_BYTES = 64_000, DAY_MS = 86_400_000;
const SECTION_ID = /^section_(all|\d{1,3})$/;
const badSetup = () => new HttpsError('invalid-argument', 'Bad mock setup.');
const isObject = (value: unknown): value is Record<string, unknown> =>
  !!value && typeof value === 'object' && !Array.isArray(value);
const inRange = (value: unknown, min: number, max: number): value is number =>
  typeof value === 'number' && Number.isInteger(value) && value >= min && value <= max;

/**
 * Shape only. Whether the ticked subjects can supply the paper is not checked here, so narrowing
 * What's Included can never be refused. Only the five fields the sampler reads are kept: the server
 * sets topic weights itself, so any sent are dropped.
 */
export function checkCustomBlueprint(raw: unknown, now: number): CustomBlueprint {
  if (!isObject(raw)) throw badSetup();
  const {sectionsJson, totalQuestions, totalMinutes, sectionsTimedSeparately, updatedAt} = raw;
  if (typeof sectionsJson !== 'string' || Buffer.byteLength(sectionsJson) > MAX_SECTIONS_BYTES) throw badSetup();
  let parsed: unknown;
  try { parsed = JSON.parse(sectionsJson); } catch { throw badSetup(); }
  if (!Array.isArray(parsed) || parsed.length < 1 || parsed.length > 20) throw badSetup();
  const ids = new Set<string>();
  let questions = 0, minutes = 0;
  const sections = parsed.map(section => {
    if (!isObject(section)) throw badSetup();
    const {id, name, questionCount, suggestedMinutes, topicIds} = section;
    if (typeof id !== 'string' || !SECTION_ID.test(id) || ids.has(id)) throw badSetup();
    ids.add(id);
    if (typeof name !== 'string' || name.length < 1 || name.length > MAX_NAME) throw badSetup();
    if (!inRange(questionCount, 1, 300) || !inRange(suggestedMinutes, 1, 720)) throw badSetup();
    if (!Array.isArray(topicIds) || topicIds.length < 1 || topicIds.length > 64
        || !topicIds.every(topic => typeof topic === 'string' && ID_PATTERN.test(topic))) throw badSetup();
    questions += questionCount;
    minutes += suggestedMinutes;
    return {id, name, questionCount, suggestedMinutes, topicIds};
  });
  if (!inRange(totalQuestions, 1, 300) || totalQuestions !== questions) throw badSetup();
  if (!inRange(totalMinutes, 1, 720)) throw badSetup();
  if (typeof sectionsTimedSeparately !== 'boolean') throw badSetup();
  if (sectionsTimedSeparately && (sections.length < 2 || totalMinutes !== minutes)) throw badSetup();
  if (typeof updatedAt !== 'number' || !Number.isSafeInteger(updatedAt) || updatedAt > now + DAY_MS) throw badSetup();
  return {sectionsJson: JSON.stringify(sections), totalQuestions, totalMinutes, sectionsTimedSeparately, updatedAt};
}

/**
 * The `customTrack` block on `setExamSettings`. Absent is allowed, because a cached client from before
 * this change reaches the server through the same call. Only `name` and `blueprint` are read.
 */
export function checkCustomBlock(raw: unknown, now: number): CustomBlock {
  if (raw === undefined || raw === null) return {};
  if (!isObject(raw)) throw new HttpsError('invalid-argument', 'Bad custom exam.');
  const out: CustomBlock = {};
  if (raw.name !== undefined && raw.name !== null) {
    if (typeof raw.name !== 'string') throw new HttpsError('invalid-argument', 'Bad custom exam.');
    const name = Array.from(raw.name.trim()).slice(0, MAX_NAME).join('').trim();
    if (name) out.name = name;
  }
  if (raw.blueprint !== undefined && raw.blueprint !== null) out.blueprint = checkCustomBlueprint(raw.blueprint, now);
  return out;
}

// ---- price tier -----------------------------------------------------------------------------------
type TierName = 'Student' | 'Civil Service' | 'Licensure';
type TierTable = {version: number; subjects: {name: string; tier: TierName; topicIds: string[]}[]; topicTiers: Record<string, TierName>};
/** Generated by `tools/custom_tiers/build_custom_tiers.dart`; a repo check keeps it current. */
export const customSubjectTiers = JSON.parse(readFileSync(join(__dirname, 'customSubjectTiers.json'), 'utf8')) as TierTable;
const LADDER: PriceTier[] = ['student', 'civilService', 'licensure'];
const TIER_OF: Record<TierName, PriceTier> = {'Student': 'student', 'Civil Service': 'civilService', 'Licensure': 'licensure'};
const NAME_OF: Record<string, TierName> = {student: 'Student', civilService: 'Civil Service', licensure: 'Licensure'};
/** The catalog's display string for a ladder tier, for display only. */
export const tierDisplayName = (tier: PriceTier): string => NAME_OF[tier] ?? 'Student';

/**
 * A custom exam's price tier: the highest tier among the subjects it keeps. A subject is kept while any
 * of its topics is not excluded. A topic the table places in no subject is kept while it is not excluded
 * and counts at its own highest tier, so it can never lower a price. Fail closed: when the caller has the
 * corpus, a kept corpus topic that is in neither a subject nor `topicTiers` (new content before the table
 * is rebuilt) raises the tier to the top of the ladder, so it can never under-price. With no corpus (the
 * track list read) the table alone decides and such a topic cannot be seen. Pure: the caller passes the
 * exclusions from the server's own records, never from a request field.
 */
export function customTier(excludedTopicIds: readonly string[], corpusTopicIds?: Iterable<string>): PriceTier {
  const excluded = new Set(excludedTopicIds);
  let top = 0;
  const raise = (name: TierName) => { top = Math.max(top, LADDER.indexOf(TIER_OF[name])); };
  const placed = new Set<string>();
  for (const subject of customSubjectTiers.subjects) {
    for (const id of subject.topicIds) placed.add(id);
    if (subject.topicIds.some(id => !excluded.has(id))) raise(subject.tier);
  }
  for (const [id, name] of Object.entries(customSubjectTiers.topicTiers)) {
    if (!placed.has(id) && !excluded.has(id)) raise(name);
  }
  if (corpusTopicIds) {
    for (const id of corpusTopicIds) {
      if (!placed.has(id) && !(id in customSubjectTiers.topicTiers) && !excluded.has(id)) raise('Licensure');
    }
  }
  return LADDER[top];
}

/** The higher of two ladder tiers. */
/** The tier a custom mock row pins at start: the higher of the two exclusion reads beginMock compares. */
export function paperTier(exclusions: readonly string[], assembled: readonly string[], corpusTopicIds?: Iterable<string>): PriceTier {
  const corpus = corpusTopicIds ? [...corpusTopicIds] : undefined;
  return higherTier(customTier(exclusions, corpus), customTier(assembled, corpus));
}

export const higherTier = (a: PriceTier, b: PriceTier): PriceTier => LADDER[Math.max(LADDER.indexOf(a), LADDER.indexOf(b))];

type Covers = {coversExam(examId: string): boolean; coversCustom(tier: PriceTier): boolean};
const listOf = (value: unknown): string[] => Array.isArray(value) ? value.filter((v): v is string => typeof v === 'string') : [];

/**
 * Excluded topic ids per custom exam id, from the server's own records: the settings document while that
 * exam is active, else its track document. A missing record means nothing is excluded, so the exam prices
 * at its highest tier rather than the lowest. Reads only; call before any write in the transaction.
 */
export async function customExclusions(tx: Transaction, db: Firestore, uid: string, examIds: readonly string[],
  settings?: DocumentSnapshot): Promise<Map<string, string[]>> {
  const out = new Map<string, string[]>();
  const wanted = [...new Set(examIds.filter(isCustomExamId))];
  if (!wanted.length) return out;
  const active = settings ?? await tx.get(db.doc(`users/${uid}/server/settings`));
  const others = wanted.filter(id => !(active.exists && active.get('examId') === id));
  const tracks = others.length ? await tx.getAll(...others.map(id => customTrackRef(db, uid, id))) : [];
  for (const id of wanted) {
    if (active.exists && active.get('examId') === id) out.set(id, listOf(active.get('excludedTopicIds')));
    else out.set(id, listOf(tracks[others.indexOf(id)]?.get('excludedTopicIds')));
  }
  return out;
}

/**
 * Whether the account's Pro covers this exam: a listed exam by its catalog tier, a custom one by `customTier`.
 * `corpusTopicIds` makes an unknown kept topic fail closed. `assembledExclusions` is for a caller that built
 * something from one read of the exclusions and checks coverage from another: the higher tier of the two
 * counts, so a concurrent edit that lowers the tier between them cannot lower the price of what was built.
 */
export function coversStudyExam(access: Covers, examId: string, exclusions: ReadonlyMap<string, string[]>,
  options: {corpusTopicIds?: Iterable<string>; assembledExclusions?: readonly string[]; pinnedTier?: unknown} = {}): boolean {
  if (!isCustomExamId(examId)) return access.coversExam(examId);
  const corpus = options.corpusTopicIds ? [...options.corpusTopicIds] : undefined;
  let tier = customTier(exclusions.get(examId) ?? [], corpus);
  if (options.assembledExclusions) tier = higherTier(tier, customTier(options.assembledExclusions, corpus));
  // A mock row pins the tier its paper was drawn at, so narrowing the subjects later cannot lower the
  // tier its results and review are read at. A stored value that is not a tier fails closed.
  if ('pinnedTier' in options && options.pinnedTier !== undefined) {
    tier = higherTier(tier, LADDER.includes(options.pinnedTier as PriceTier) ? options.pinnedTier as PriceTier : 'licensure');
  }
  return access.coversCustom(tier);
}
