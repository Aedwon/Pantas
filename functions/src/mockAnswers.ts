import type {Firestore, Transaction} from 'firebase-admin/firestore';
import {HttpsError} from 'firebase-functions/v2/https';
import type {Answer} from './_answers.js';
import {addSession, backfill, fromDoc, prune, toDoc, totalsRef} from './_answerTotals.js';
import {prepareReviewAnswers} from './serverReviews.js';

type Paper = {sections: {questions: {id: string}[]}[]};
export function checkPaperAnswers(answers: Answer[], paper: Paper): void {
  const pinned = new Set(paper.sections.flatMap(s => s.questions.map(q => q.id)));
  const sent = new Set<string>();
  for (const answer of answers) {
    if (!pinned.has(answer.questionId) || sent.has(answer.questionId) || (answer.chosen === null && answer.correct)) {
      throw new HttpsError('invalid-argument', 'Answers must name distinct questions on this paper.');
    }
    sent.add(answer.questionId);
  }
}

/** Mock submission, answers, totals and scheduler updates commit together, once. */
export async function recordMockAnswers(tx: Transaction, db: Firestore, uid: string,
  mockId: string, row: FirebaseFirestore.DocumentData, receivedAt: number): Promise<void> {
  // Public C9 ids cannot contain ':', so a client cannot preempt this internal record.
  const sessionId = `mock:${mockId}`;
  const ref = db.doc(`users/${uid}/server/answers/items/${sessionId}`);
  if ((await tx.get(ref)).exists) return;
  const saved = (row.answers ?? []) as Answer[];
  checkPaperAnswers(saved, row.paper);
  const answers = saved.filter(a => a.chosen !== null);
  const snapshot = await tx.get(totalsRef(db, uid));
  const totals = snapshot.exists ? fromDoc(snapshot.data()) : await backfill(tx, db, uid);
  const applyReviews = await prepareReviewAnswers(tx, db, uid, answers, Number(row.submittedAt), true);
  addSession(totals, answers); prune(totals);
  tx.set(totalsRef(db, uid), toDoc(totals));
  tx.create(ref, {sessionId, mockId, examId: row.examId, origin: 'mock', startedAt: row.startedAt,
    finishedAt: row.submittedAt, durationMs: row.durationMs, answerCount: answers.length, answers, receivedAt});
  applyReviews();
}
