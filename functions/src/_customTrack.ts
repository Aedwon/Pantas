import type {Firestore} from 'firebase-admin/firestore';
import {HttpsError} from 'firebase-functions/v2/https';
import {ID_PATTERN} from './content.js';
import {examCatalog} from './revenuecatPasses.js';

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
