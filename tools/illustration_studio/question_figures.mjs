// Scans content/questions/**/*.yaml for figure-pending questions and builds
// items shaped like Illustration Studio's lesson items, plus the
// docs/content/question-figures/worklist.tsv audit trail.
import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';

export function buildFigureItems(subject, topic, subtopic, doc) {
  const items = [];
  for (const q of doc?.questions ?? []) {
    if (!q.figure) continue;
    items.push({
      kind: 'question',
      subject,
      topic,
      subtopic,
      questionId: q.id,
      slug: q.figure,
      stem: q.stem,
      description: q.stem,
      choices: q.choices ?? [],
      explanation: q.explanation,
      target: `content/illustrations/questions/${subject}/${topic}/${subtopic}/${q.figure}.png`,
    });
  }
  return items;
}

export function worklistTsv(items) {
  const header = ['subject', 'topic', 'subtopic', 'slug', 'question_id', 'target_file', 'status'];
  const lines = [header.join('\t')];
  for (const it of items) {
    lines.push([it.subject, it.topic, it.subtopic, it.slug, it.questionId, it.target, it.status].join('\t'));
  }
  return lines.join('\n') + '\n';
}

export async function scanQuestionFigures(repoRoot) {
  const YAML = (await import('yaml')).default;
  const contentRoot = join(repoRoot, 'content', 'questions');
  const items = [];
  const subjects = (await readdir(contentRoot, { withFileTypes: true })).filter((d) => d.isDirectory());
  for (const subject of subjects) {
    const subjectDir = join(contentRoot, subject.name);
    const topics = (await readdir(subjectDir, { withFileTypes: true })).filter((d) => d.isDirectory());
    for (const topic of topics) {
      const topicDir = join(subjectDir, topic.name);
      const files = (await readdir(topicDir, { withFileTypes: true }))
        .filter((d) => d.isFile() && d.name.endsWith('.yaml'));
      for (const file of files) {
        const subtopic = file.name.replace(/\.yaml$/, '');
        const doc = YAML.parse(await readFile(join(topicDir, file.name), 'utf8')) ?? {};
        items.push(...buildFigureItems(subject.name, topic.name, subtopic, doc));
      }
    }
  }
  return items;
}
