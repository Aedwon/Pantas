import type {Firestore, Transaction} from 'firebase-admin/firestore';
import {HttpsError} from 'firebase-functions/v2/https';
import type {Answer} from './_answers.js';
import {core} from './_core.js';
import {phDay, phStamp} from './_phDate.js';

const reviews = (db: Firestore, uid: string) => db.collection(`users/${uid}/server/reviews/items`);
/** Prepare before any transaction writes; apply only after all other reads finish. */
export async function prepareReviewAnswers(tx: Transaction, db: Firestore, uid: string,
  answers: Answer[], finishedAt: number, seedMissing: boolean): Promise<() => void> {
  const chosen = answers.filter(a => a.chosen !== null);
  const ids = [...new Set(chosen.map(a => a.questionId))];
  if (!ids.length) return () => {};
  const snapshots = await tx.getAll(...ids.map(id => reviews(db, uid).doc(encodeURIComponent(id))));
  const previous = new Map(snapshots.map((row, i) => [ids[i], row.exists ? JSON.parse(String(row.get('stateJson'))) : null]));
  const input = chosen.filter(a => seedMissing || previous.get(a.questionId) !== null).map(a => {
    const state = previous.get(a.questionId);
    if (state && state.questionId !== a.questionId) throw new HttpsError('failed-precondition', 'Saved review identity differs.');
    // C7's existing mapper/mirror sets questionVersion=1 for these published questions.
    return {questionId: a.questionId, questionVersion: a.questionVersion ?? 1, correct: a.correct, previous: state};
  });
  if (!input.length) return () => {};
  const states = JSON.parse(core().scheduleReviews(JSON.stringify({now: finishedAt, reviews: input}))) as
    {questionId: string; due: string; lastReview: string}[];
  return () => {
    for (const state of states) {
      const before = previous.get(state.questionId);
      if (before && Date.parse(before.lastReview) > finishedAt) continue;
      tx.set(reviews(db, uid).doc(encodeURIComponent(state.questionId)), {
        questionId: state.questionId, due: Date.parse(state.due), stateJson: JSON.stringify(state),
      });
    }
  };
}

/** Same end-of-Philippine-day scope and scheduler retrievability as the native reader. */
export async function dueReviewInputs(db: Firestore, uid: string, now: number, scopedIds: Set<string>) {
  const endOfToday = Date.parse(`${phDay(now)}T00:00:00+08:00`) + 86400000;
  const rows = await reviews(db, uid).where('due', '<', endOfToday).get();
  const states = rows.docs.filter(d => scopedIds.has(d.get('questionId'))).map(d => JSON.parse(String(d.get('stateJson'))));
  if (!states.length) return [];
  const inputs = JSON.parse(core().dueReviews(JSON.stringify({now, states}))) as {id: string; due: number; retrievability: number}[];
  return inputs.map(row => ({id: row.id, due: phStamp(row.due), retrievability: row.retrievability}));
}
