// Emulator-only sample student. Usage: node tools/local/seed_student.mjs <uid> <profile> [today] [--state=<id>]
// profile: new | steady | behind | examWeek. today: YYYY-MM-DD (Philippine day), default the real day.
// state: optional Home state for the chosen profile, see STATES. Dates are relative to today.
//
// The server owns study records on web, so this runs the compiled server handlers with admin
// dependencies: exam settings, lesson reads, finished sessions and mocks, each stamped with its own
// past time. Streak, accuracy, due reviews and the plan are then whatever the server computes.
// It first deletes that uid's study documents and cloud backup (never its entitlement or trial) and nothing else.
import {createRequire} from 'node:module';
import {resolve} from 'node:path';
import {networkInterfaces} from 'node:os';
import {readFileSync} from 'node:fs';

const require = createRequire(resolve('functions/package.json'));
const project = 'demo-pantas-local';
for (const [key, port] of [['FIRESTORE_EMULATOR_HOST', 8080], ['FIREBASE_AUTH_EMULATOR_HOST', 9099]]) {
  const host = process.env[key]?.split(':')[0];
  const addresses = Object.values(networkInterfaces()).flat().map(row => row?.address);
  if (!addresses.includes(host) || process.env[key] !== `${host}:${port}`) throw Error(`Unsafe ${key}`);
}
process.env.GCLOUD_PROJECT = project;
process.env.GOOGLE_CLOUD_PROJECT = project;

const positional = process.argv.slice(2).filter(arg => !arg.startsWith('--'));
const [uid, profileId, todayArg] = positional;
const stateId = process.argv.slice(2).find(arg => arg.startsWith('--state='))?.slice('--state='.length);
const EXAM = 'exam_cse_pro';
const DAY = 86_400_000;
const PH = 8 * 3_600_000;

// Targets from the local test panel spec. Steady's exam is 28 days out, as the Home boards show.
const PROFILES = {
  new: {startDaysAgo: 1, lastStudyDaysAgo: 1, streakDays: 1, answers: 12, lessons: 1, accuracy: 0.70,
    examInDays: 120, poolSize: 40, assessmentLimit: 8},
  steady: {startDaysAgo: 21, lastStudyDaysAgo: 1, streakDays: 18, answers: 400, lessons: 30, accuracy: 0.75,
    examInDays: 28, poolSize: 220, mockAt: [0.7], mockAccuracy: [0.70]},
  behind: {startDaysAgo: 35, lastStudyDaysAgo: 6, streakDays: 6, earlierRate: 0.55, answers: 250, lessons: 14,
    accuracy: 0.55, examInDays: 45, poolSize: 160, weakShare: 0.3, breakStreak: true},
  examWeek: {startDaysAgo: 70, lastStudyDaysAgo: 1, streakDays: 24, earlierRate: 0.7, answers: 900, lessons: 60,
    accuracy: 0.80, examInDays: 5, poolSize: 420, mockAt: [0.35, 0.55, 0.75, 0.92],
    mockAccuracy: [0.55, 0.65, 0.73, 0.80]},
};
// Home states a board shows. Each one changes the chosen profile as little as it can; the server's own
// handlers still decide what Home draws. `examInDays` null means no exam date, `examMonth` this month's
// exam month without a day. `finishToday` completes today's whole plan, as the student would. `noHistory`
// drops the study days; `unassessed` leaves the placement test untaken; `coverDaysAgo` has the student read every
// lesson and answer every question that many days ago, so the plan holds only what has come due since.
const STATES = {
  dayDone: {finishToday: true},
  nothingDue: {noHistory: true, coverDaysAgo: 1, examInDays: 120},
  dayOff: {restToday: true},
  resume: {resume: true},
  beforeAssessment: {noHistory: true, unassessed: true, examInDays: 28},
  mockDay: {examInDays: 6},
  // Inside the last days the plan crams what is left; the student finishes it, with a mock done yesterday.
  reviewWeek: {examInDays: 2, finishToday: true, mockAt: [0.7, 1], mockAccuracy: [0.7, 0.75]},
  lastDay: {examInDays: 1, finishToday: true, mockAt: [0.7, 1], mockAccuracy: [0.7, 0.75]},
  examDay: {examInDays: 0},
  examPassed: {examInDays: -7},
  noDate: {examInDays: null},
  monthOnly: {examMonth: true},
  // The student finished today, took the extra day, and finished that too, so the offer returns.
  advanceAgain: {finishToday: true, advanceTimes: 1, finishAdvanced: true},
  // The mock is due today with the exam 4 days or 1 day out. The "moved to today" line needs the server to
  // have stored an earlier mock day, which this seed cannot arrange, so Home shows the ordinary note.
  mockMoved: {examInDays: 4},
  mockDropped: {examInDays: 1},
  // A busy day: the exam 10 days out leaves many lessons for today.
  manyLessons: {examInDays: 10},
  nothingDueReview: {noHistory: true, coverDaysAgo: 1, examInDays: 5},
  // A Pro trial with two days left (the grant's end is moved; startsAt stays).
  trial: {trialDaysLeft: 2},
};
if (stateId !== undefined && !STATES[stateId]) throw Error(`Unknown state ${stateId}.`);
const state$ = STATES[stateId] ?? {};
const profile = PROFILES[profileId] && {...PROFILES[profileId], ...state$};
if (!uid || !profile) throw Error('Usage: seed_student.mjs <uid> <new|steady|behind|examWeek> [YYYY-MM-DD] [--state=<id>]');
const {earlierRate = 0, weakShare = 0, breakStreak = false, mockAt = [], mockAccuracy = [], assessmentLimit} = profile;
const MOCK_QUESTIONS_PER_SECTION = 12;

const {initializeApp} = require('firebase-admin/app');
const {getAuth} = require('firebase-admin/auth');
const {getFirestore} = require('firebase-admin/firestore');
initializeApp({projectId: project});
const db = getFirestore();
const lib = name => require(resolve(`functions/lib/${name}.js`));
const {recordSession} = lib('ingestSession');
const {saveExamSettings, readStudyRoadmap, advanceStudyRoadmap} = lib('roadmap');
const {writeLessonRead} = lib('studyObservations');
const {beginMock, recordMock} = lib('mock');
const {loadExamContent, clearExamContentCache} = lib('_examContent');
const {blueprintItem} = lib('contentUpload');

// A seeded random source, so a profile always produces the same student.
let state = [...profileId].reduce((hash, ch) => (hash * 31 + ch.charCodeAt(0)) & 0x7fffffff, 17) >>> 0;
function random() {
  state = (state + 0x6d2b79f5) >>> 0;
  let t = state;
  t = Math.imul(t ^ (t >>> 15), t | 1);
  t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
}
const int = n => Math.floor(random() * n);
function shuffled(items) {
  const out = [...items];
  for (let i = out.length - 1; i > 0; i--) {
    const j = int(i + 1);
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

// Philippine calendar days as whole numbers since 1970-01-01.
const dayIndex = ms => Math.floor((ms + PH) / DAY);
const dayText = index => new Date(index * DAY).toISOString().slice(0, 10);
const weekday = index => new Date(index * DAY).getUTCDay(); // 0 is Sunday
const at = (index, hour, minute = 0) => index * DAY - PH + hour * 3_600_000 + minute * 60_000;
const today = todayArg ? Math.floor(Date.parse(`${todayArg}T00:00:00Z`) / DAY) : dayIndex(Date.now());
if (!Number.isFinite(today)) throw Error('Bad date.');

// ---------------------------------------------------------------- the account
const claims = (await getAuth().getUser(uid)).customClaims ?? {};
const auth = {uid, token: {...claims, email: `${uid}@pantas.local`, email_verified: true,
  firebase: {sign_in_provider: 'password', identities: {password: [`${uid}@pantas.local`]}}}};
const allow = async () => true;
const at$ = now => ({db, now: () => now, allow});

// ---------------------------------------------------------------- start clean
// Study documents only. The entitlement and the trial grant stay.
for (const ref of await db.collection(`users/${uid}/server`).listDocuments()) {
  if (['entitlement', 'trial'].includes(ref.id)) continue;
  await db.recursiveDelete(ref);
}
// The cloud backup of an earlier sample student (its answers and assessment result) would be
// restored into the next browser, so a re-seeded account must not keep it.
await db.recursiveDelete(db.collection(`users/${uid}/sync_generations`));
await db.recursiveDelete(db.collection(`users/${uid}/sync_state`));
// Rate-limit counters from earlier loads would block the plan (the trial counter stays).
for (const ref of await db.collection(`users/${uid}/limits`).listDocuments()) {
  if (ref.id !== 'webTrial') await ref.delete();
}

// ---------------------------------------------------------------- content
clearExamContentCache();
const content = await loadExamContent(db, EXAM, Date.now());
const sets = new Map();
for (const doc of (await db.collection('content/questions/items').get()).docs) {
  let set;
  try { set = JSON.parse(String(doc.get('payload'))); } catch { continue; }
  for (const question of set.questions ?? []) sets.set(question.id, question);
}
const choicesOf = id => (sets.get(id)?.choices ?? []).map((choice, index) =>
  ({id: `${id}_${'abcdefgh'[index]}`, correct: choice.correct === true}));
const usable = content.questions.filter(q => {
  const choices = choicesOf(q.id);
  return choices.length >= 2 && choices.some(c => c.correct);
});
if (usable.length === 0) throw Error('No questions for this exam. Is the content uploaded?');

// One question at a time from each topic in turn, so the pool covers every topic.
function buildPool() {
  const byTopic = new Map();
  for (const q of usable) (byTopic.get(q.topicId) ?? byTopic.set(q.topicId, []).get(q.topicId)).push(q.id);
  const queues = [...byTopic.keys()].sort().map(topic => shuffled(byTopic.get(topic).sort()));
  const picked = [];
  for (let round = 0; picked.length < profile.poolSize; round++) {
    let any = false;
    for (const queue of queues) {
      if (round < queue.length && picked.length < profile.poolSize) { picked.push(queue[round]); any = true; }
    }
    if (!any) break;
  }
  return picked;
}
const pool = buildPool();

// A mock needs a blueprint on the server. The local corpus may not carry one for this exam, so
// build it from the repository's blueprint, cut to what the bank holds and to a short paper.
async function ensureBlueprint() {
  if ((await db.doc(`content/mocks/items/${EXAM}`).get()).exists) return;
  const {parse} = require('yaml');
  const doc = parse(readFileSync('content/mock/cse-pro.yaml', 'utf8'));
  const sizeOf = new Map();
  for (const q of usable) sizeOf.set(q.topicId, (sizeOf.get(q.topicId) ?? 0) + 1);
  doc.sections = doc.sections.map(section => {
    const topicIds = section.topicIds.filter(id => sizeOf.has(id));
    const available = topicIds.reduce((sum, id) => sum + sizeOf.get(id), 0);
    const weight = topicIds.reduce((sum, id) => sum + (section.topicWeights?.[id] ?? 1), 0) || 1;
    return {...section, topicIds, questionCount: Math.min(MOCK_QUESTIONS_PER_SECTION, available),
      topicWeights: Object.fromEntries(topicIds.map(id => [id, (section.topicWeights?.[id] ?? 1) / weight]))};
  }).filter(section => section.topicIds.length > 0 && section.questionCount > 0);
  const item = blueprintItem(doc);
  await db.doc(`content/mocks/items/${EXAM}`).set(item.data);
}

// ---------------------------------------------------------------- study days
// Mon to Sat. The run ends on the last study day; earlier days are studied by chance.
// A state with no history has no study days at all.
const anchor = today - profile.lastStudyDaysAgo;
const window = profile.noHistory ? [] : [anchor];
for (let cursor = anchor; window.length > 0 && window.length < profile.streakDays;) {
  cursor -= 1;
  if (weekday(cursor) !== 0) window.push(cursor);
}
window.sort((a, b) => a - b);
const studied = new Set(window);
let skipped = window.length ? window[0] - 1 : 0;
while (weekday(skipped) === 0) skipped -= 1;
for (let day = today - profile.startDaysAgo; window.length && day < window[0]; day++) {
  if (weekday(day) === 0 || day === skipped) continue;
  if (random() < earlierRate) studied.add(day);
}
const days = [...studied].sort((a, b) => a - b);

// Streak as the app counts it: a Sunday never breaks it, any other missed day does.
let streak = 0, longest = 0, last = null;
for (const day of days) {
  let missed = 0;
  if (last !== null) for (let d = last + 1; d < day; d++) if (weekday(d) !== 0) missed++;
  streak = last === null || missed > 0 ? 1 : streak + 1;
  longest = Math.max(longest, streak);
  last = day;
}
if (breakStreak) streak = 0;

// ---------------------------------------------------------------- plan the events
const mockByDay = new Map();
if (mockAt.length && days.length) {
  await ensureBlueprint();
  mockAt.forEach((fraction, i) => mockByDay.set(Math.round(fraction * (days.length - 1)), mockAccuracy[i]));
}
const assessmentSize = profile.noHistory ? 0 : Math.min(assessmentLimit ?? 30, pool.length);
const mockSize = mockByDay.size ? MOCK_QUESTIONS_PER_SECTION * 4 : 0; // an upper bound for sizing
const sessionTotal = Math.max(days.length, profile.answers - assessmentSize - mockByDay.size * mockSize);
const weights = days.map(() => 0.7 + random() * 0.6);
const weightSum = weights.reduce((a, b) => a + b, 0);
const sizes = weights.map(w => Math.max(1, Math.round(sessionTotal * w / weightSum)));
if (sizes.length) sizes[sizes.length - 1] = Math.max(1, sessionTotal - sizes.slice(0, -1).reduce((a, b) => a + b, 0));

// Settings first, at the start of the first study day, so the roadmap exists and gives lesson order.
// The exam date as the page keeps it: a day, a month without a day, or none.
const examDay = profile.examInDays === null ? null : today + profile.examInDays;
const monthStart = new Date(today * DAY);
const examDate = profile.examMonth
  ? {precision: 'month', year: monthStart.getUTCFullYear(), month: monthStart.getUTCMonth() + 1}
  : examDay === null ? null : {precision: 'day', day: dayText(examDay)};
// The boards show a study day. If today is a Sunday (never a study day), Sunday is added so Home draws a day with work.
const settings = {expectedUid: uid, examId: EXAM, examDate, studyDays: weekday(today) === 0 ? [1, 2, 3, 4, 5, 6, 7] : [1, 2, 3, 4, 5, 6],
  ...(profile.unassessed ? {assessmentCompleted: false} : profile.noHistory ? {assessmentCompleted: true} : {})};
// A day off: every weekday but today's, Sunday being 7 on the server.
const finalSettings = profile.restToday ? {...settings, studyDays: [1, 2, 3, 4, 5, 6, 7].filter(day => day !== (weekday(today) || 7))}
  : settings;
await saveExamSettings(auth, settings, at$(at(days[0] ?? today - (profile.coverDaysAgo ?? 1) - 1, 8)));
const roadmap = JSON.parse(String((await db.doc(`users/${uid}/server/roadmap`).get()).get('roadmapJson') ?? '{}'));
const topicRank = new Map((roadmap.topicOrder ?? []).map((id, i) => [id, i]));
const lessons = [...content.lessons].sort((a, b) =>
  (topicRank.get(a.topicId) ?? 1e6) - (topicRank.get(b.topicId) ?? 1e6) || a.ordering - b.ordering || (a.id < b.id ? -1 : 1));
const lessonCount = Math.min(profile.lessons, lessons.length);
const lessonsByDay = new Map();
for (let k = 0; k < lessonCount; k++) {
  if (!days.length) break;
  const i = Math.min(days.length - 1, Math.floor(k * days.length / lessonCount));
  (lessonsByDay.get(i) ?? lessonsByDay.set(i, []).get(i)).push(lessons[k].id);
}

const weak = new Set(weakShare > 0 ? shuffled(pool).slice(0, 18) : []);
const unseen = shuffled(pool);
const answeredOn = new Map(); // question id to the day index it was last answered
const counts = {sessions: 0, answers: 0, lessons: 0, mocks: 0};

function pick(size, day) {
  const picks = [];
  const has = id => picks.includes(id);
  for (const id of shuffled([...weak]).slice(0, Math.round(size * weakShare))) picks.push(id);
  // Questions answered on an earlier day come back, as a review would bring them.
  const earlier = shuffled([...answeredOn].filter(([id, d]) => d < day && !has(id)).map(([id]) => id));
  for (const id of earlier.slice(0, Math.round(size * 0.4))) if (picks.length < size) picks.push(id);
  for (const id of unseen) {
    if (picks.length >= size) break;
    if (!answeredOn.has(id) && !has(id)) picks.push(id);
  }
  for (let guard = 0; picks.length < size && guard < size * 20 && picks.length < pool.length; guard++) {
    const id = pool[int(pool.length)];
    if (!has(id)) picks.push(id);
  }
  return picks;
}

function answerFor(id, correct) {
  const choices = choicesOf(id);
  const right = choices.find(c => c.correct);
  const wrong = shuffled(choices.filter(c => !c.correct))[0];
  return {questionId: id, chosen: (correct ? right : wrong).id, correct};
}

async function session({sessionId, origin, day, startAt, ids, accuracyFor}) {
  let clock = startAt;
  const answers = ids.map(id => {
    const responseMs = 4000 + int(16000) + (random() < 0.05 ? 20000 : 0);
    clock += responseMs;
    const correct = random() < accuracyFor(id);
    return {...answerFor(id, correct), responseMs, questionVersion: 1};
  });
  const finishedAt = clock + 5000;
  await recordSession(auth, {sessionId, expectedUid: uid, examId: EXAM, origin, startedAt: startAt, finishedAt,
    durationMs: finishedAt - startAt, answers}, {...at$(finishedAt), dailySessions: 1e9});
  for (const id of ids) answeredOn.set(id, day);
  counts.sessions++;
  counts.answers += answers.length;
}

// A mock is begun and submitted by the server's own handlers. The Free allowance of one mock in 30
// days would refuse a second sample mock, so earlier sample mocks are set aside while the next is
// begun and put back afterwards. Only this uid's sample mocks are touched.
const setAside = [];
async function mock(day, accuracy, index) {
  const start = at(day, 9, 30);
  const mocksRef = db.collection(`users/${uid}/server/mocks/items`);
  for (const doc of (await mocksRef.get()).docs) { setAside.push([doc.ref, doc.data()]); await doc.ref.delete(); }
  const paperSeed = (state ^ (index * 7919)) >>> 0;
  const begun = await beginMock(auth, {examId: EXAM, strict: false}, {...at$(start), seed: () => paperSeed});
  let seconds = 0;
  const answers = [];
  for (const section of begun.paper.sections) {
    for (const question of section.questions) {
      const roll = random();
      if (roll >= 0.97) continue; // left blank
      seconds += 25 + int(35);
      answers.push({...answerFor(question.id, roll < accuracy), answeredAt: start + seconds * 1000,
        responseMs: 25_000});
    }
  }
  const submittedAt = start + (seconds + 30) * 1000;
  await recordMock(auth, {mockId: begun.mockId, answers, durationMs: submittedAt - start}, at$(submittedAt));
  for (const answer of answers) answeredOn.set(answer.questionId, day);
  counts.mocks++;
  counts.answers += answers.length;
}

// ---------------------------------------------------------------- run, oldest first
for (let i = 0; i < days.length; i++) {
  const day = days[i];
  const progress = days.length === 1 ? 1 : i / (days.length - 1);
  if (mockByDay.has(i)) await mock(day, mockByDay.get(i), i);
  let minute = 0;
  for (const lessonId of lessonsByDay.get(i) ?? []) {
    await writeLessonRead(auth, {expectedUid: uid, lessonId, readAt: at(day, 16, minute)}, at$(at(day, 16, minute)));
    counts.lessons++;
    minute += 5;
  }
  if (i === 0 && assessmentSize > 0) {
    await session({sessionId: `sample-${profileId}-assessment`, origin: 'assessment', day, startAt: at(day, 16, 30),
      ids: pool.slice(0, assessmentSize), accuracyFor: () => profile.accuracy});
  }
  const base = weakShare > 0 ? (profile.accuracy - weakShare * 0.2) / (1 - weakShare) : profile.accuracy;
  const accuracy = Math.min(0.95, Math.max(0.2, base + (progress - 0.5) * 0.1));
  const ids = pick(sizes[i], day);
  if (ids.length === 0) continue;
  await session({sessionId: `sample-${profileId}-session-${i}`, day,
    origin: ['today_topic', 'new_questions', 'today_interleaved'][i % 3],
    startAt: at(day, 17 + int(4), 10 + int(40)), ids,
    accuracyFor: id => (weak.has(id) && weakShare > 0 ? 0.2 : accuracy)});
}
for (const [ref, data] of setAside) await ref.set(data);

// ---------------------------------------------------------------- a state that needs more work
// Everything the plan could hold, done on an earlier day, so nothing is new today.
if (profile.coverDaysAgo) {
  const day = today - profile.coverDaysAgo;
  for (let k = 0; k < lessons.length; k++) {
    const readAt = at(day, 8, k % 60);
    await writeLessonRead(auth, {expectedUid: uid, lessonId: lessons[k].id, readAt}, at$(readAt));
  }
  const ids = shuffled(usable.map(q => q.id));
  for (let from = 0, n = 0; from < ids.length; from += 100, n++) {
    await session({sessionId: `sample-${profileId}-cover-${n}`, origin: 'today_interleaved', day,
      startAt: at(day, 9, n), ids: ids.slice(from, from + 100), accuracyFor: () => 1});
  }
  // Those answers are the only study the account has, so they are its streak.
  last = day;
  streak = profile.coverDaysAgo > 1 ? 0 : 1;
  longest = 1;
}

// The Pro trial grant: the web trial lasts seven days; a state may leave fewer. Other states restore it.
for (const doc of (await db.collection(`users/${uid}/grants`).get()).docs) {
  if (doc.get('source') !== 'trial') continue;
  const endsAt = profile.trialDaysLeft === undefined ? doc.get('startsAt') + 7 * DAY
    : at(today, 12) + profile.trialDaysLeft * DAY;
  if (doc.get('endsAt') !== endsAt) await doc.ref.update({endsAt});
}

// Leave the plan computed for the real time, as a real student's last request would.
await saveExamSettings(auth, finalSettings, {db, allow});
const readPlan = () => readStudyRoadmap(auth, {expectedUid: uid, examId: EXAM}, {db, allow});
let plan = await readPlan();

// Today's whole plan done, as a student would: the lessons read, then every review and new question
// answered, early today. The server's handlers then report what is left (nothing).
if (profile.finishToday) {
  const finishAt = Math.min(at(today, 5), Date.now() - 30 * 60_000);
  const startAt = Math.max(at(today, 0, 1), finishAt - 20 * 60_000);
  let minute = 0;
  for (const lessonId of plan.today.lessonIds) {
    const readAt = startAt + minute++ * 60_000;
    await writeLessonRead(auth, {expectedUid: uid, lessonId, readAt}, at$(readAt));
    counts.lessons++;
  }
  const ids = [...new Set([...plan.today.reviewQuestionIds, ...plan.today.newQuestionIds])];
  for (let from = 0, n = 0; from < ids.length; from += 300, n++) { // a session takes at most 300 answers
    await session({sessionId: `sample-${profileId}-today-${n}`, origin: 'today_interleaved', day: today,
      startAt: startAt + (10 + n) * 60_000, ids: ids.slice(from, from + 300), accuracyFor: () => profile.accuracy});
  }
  plan = await readPlan();
}
// The extra day, taken and finished: the server's advance handler, then the new remaining work answered.
for (let n = 0; n < (profile.advanceTimes ?? 0); n++) {
  await advanceStudyRoadmap(auth, {expectedUid: uid, examId: EXAM, requestId: `sample-${uid}-advance-${n}`,
    expectedDay: plan.today.day, expectedRevision: plan.revision}, {db, allow});
  plan = await readPlan();
  if (!profile.finishAdvanced) continue;
  const finishAt = Math.min(at(today, 5), Date.now() - 20 * 60_000);
  let minute = 0;
  for (const lessonId of plan.remaining.lessonIds) {
    const readAt = finishAt - 10 * 60_000 + minute++ * 30_000;
    await writeLessonRead(auth, {expectedUid: uid, lessonId, readAt}, at$(readAt));
    counts.lessons++;
  }
  const ids = [...new Set([...plan.remaining.reviewQuestionIds, ...plan.remaining.newQuestionIds])];
  for (let from = 0, k = 0; from < ids.length; from += 300, k++) {
    await session({sessionId: `sample-${profileId}-advanced-${n}-${k}`, origin: 'today_interleaved', day: today,
      startAt: finishAt - 5 * 60_000 + k * 1000, ids: ids.slice(from, from + 300), accuracyFor: () => profile.accuracy});
  }
  plan = await readPlan();
}
// A lesson part-read: the first lesson still to read. The page keeps the position, so it is returned.
const resumeLessonId = profile.resume ? plan.remaining.lessonIds[0] ?? null : null;

const roadmapNow = JSON.parse(String((await db.doc(`users/${uid}/server/roadmap`).get()).get('roadmapJson') ?? '{}'));
const size = list => list.length;
console.log(JSON.stringify({
  uid, profile: profileId, state: stateId ?? null, examId: EXAM,
  // The page keeps the same exam date and study days it sent to the server.
  examDate: examDate === null ? null : examDate.precision === 'day' ? examDate.day
    : `${examDate.year}-${String(examDate.month).padStart(2, '0')}-01`,
  examPrecision: examDate?.precision ?? null,
  studyDays: finalSettings.studyDays.join(','), assessmentDone: !profile.unassessed, resumeLessonId,
  streak, longest, lastActiveDate: last === null ? null : dayText(last), ...counts,
  roadmapState: roadmapNow.state ?? null,
  plan: {state: plan.state, today: plan.today.day, lessons: size(plan.today.lessonIds),
    reviews: size(plan.today.reviewQuestionIds), newQuestions: size(plan.today.newQuestionIds),
    remaining: size(plan.remaining.lessonIds) + size(plan.remaining.reviewQuestionIds) + size(plan.remaining.newQuestionIds),
    isMockDay: plan.today.isMockDay, isRestDay: plan.today.isRestDay,
    originalDone: plan.originalDone, canAdvance: plan.canAdvance},
}));
