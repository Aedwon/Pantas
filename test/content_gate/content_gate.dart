// The content gate, layer (a): every active item in a content export goes
// through the app's own code, and every failure is collected, never thrown.
//
// Nov 22 2026: 261 prod questions had ids past 64 characters and every answer
// to them failed to save. Nothing had run each real item through the real save
// path. This does, once per item, with no network and an in-memory database.
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service.dart';
import 'package:pantas/core/content/repos/mock_blueprint_repo.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/storage/data/app_database.dart' hide QuestionRow;
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/features/home/data/study_writes.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/data/mock_sampler.dart';
import 'package:pantas/features/quiz/application/completed_quiz.dart';
import 'package:pantas/features/quiz/application/quiz_completion_coordinator.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/resume_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:pantas/features/quiz/presentation/quiz_question_viewer.dart';

import '../../tool/checks/content_snapshot.dart';
import '../../tool/checks/mock_blueprint_topics.dart';
import 'accepted.dart';

/// One failure: which item, which check, and why.
class GateFailure {
  const GateFailure(this.itemId, this.check, this.cause);
  final String itemId;
  final String check;
  final String cause;
}

/// Server limits, read from the server's own source so they cannot drift.
class ServerLimits {
  ServerLimits._(this.maxAnswers, this.maxIdLength, this.idPattern);

  factory ServerLimits.read([String root = '.']) {
    final answers = File('$root/functions/src/_answers.ts').readAsStringSync();
    final content = File('$root/functions/src/content.ts').readAsStringSync();
    int number(String name) =>
        int.parse(RegExp('$name = (\\d+)').firstMatch(answers)![1]!);
    final pattern = RegExp('ID_PATTERN = /(.+)/;').firstMatch(content)![1]!;
    return ServerLimits._(
      number('MAX_ANSWERS'),
      number('MAX_ID_LENGTH'),
      RegExp(pattern),
    );
  }

  final int maxAnswers;
  final int maxIdLength;
  final RegExp idPattern;
}

class GateReport {
  final failures = <GateFailure>[];

  /// Item id to the exams it is served under.
  final examsOf = <String, Set<String>>{};
  final counts = <String, int>{};
  final examsSeen = <String>{};

  /// Findings the existing checks already accept. Listed, never failed.
  final accepted = <String>{};

  /// Set while the Pro copy is checked: its findings say so, and one the Free
  /// copy already has is not repeated.
  String tier = '';

  void fail(String id, String check, String cause) {
    for (final a in acceptedFindings) {
      if (a.id == id && a.check == check) {
        accepted.add(
          '$id [$check] $cause (accepted: ${a.reason}; owner: ${a.owner}; '
          '${a.date})',
        );
        return;
      }
    }
    if (tier.isNotEmpty &&
        failures.any((f) => f.itemId == id && f.check == check)) {
      return;
    }
    final text = tier.isEmpty ? cause : '$cause $tier';
    // The same finding from two mock seeds is one finding.
    if (failures.any(
      (f) => f.itemId == id && f.check == check && f.cause == text,
    )) {
      return;
    }
    failures.add(GateFailure(id, check, text));
  }

  void count(String kind, [int by = 1]) {
    final key = tier.isEmpty ? kind : '$kind $tier';
    counts[key] = (counts[key] ?? 0) + by;
  }

  String toMarkdown({required String title, required Duration took}) {
    final out = StringBuffer('## $title\n\n')
      ..writeln('Run time: ${took.inSeconds}s. Checked: '
          '${counts.entries.map((e) => '${e.value} ${e.key}').join(', ')}.\n');
    final exams = {...examsSeen, '(no exam)'}.toList()..sort();
    out
      ..writeln('| Exam | Failing items | Failures |')
      ..writeln('| --- | --- | --- |');
    final byExam = <String, List<GateFailure>>{};
    for (final f in failures) {
      for (final e in examsOf[f.itemId] ?? const {'(no exam)'}) {
        (byExam[e] ??= []).add(f);
      }
    }
    for (final e in exams) {
      final list = byExam[e] ?? const <GateFailure>[];
      out.writeln(
        '| $e | ${list.map((f) => f.itemId).toSet().length} | ${list.length} |',
      );
    }
    if (accepted.isNotEmpty) {
      out.writeln('\nAccepted findings, not counted:');
      for (final a in accepted) {
        out.writeln('- $a');
      }
    }
    for (final e in exams) {
      final list = byExam[e];
      if (list == null || list.isEmpty) continue;
      out.writeln('\n### $e\n');
      for (final f in list) {
        out.writeln('- `${f.itemId}` [${f.check}] ${f.cause}');
      }
    }
    return out.toString();
  }

  String summary() => failures.isEmpty
      ? 'content gate: no failures'
      : 'content gate: ${failures.length} failures\n'
          '${_lines(failures)}';
}

class _Telemetry implements Telemetry {
  Map<String, Object>? last;
  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    last = properties;
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}
  @override
  Future<void> setEnabled({required bool enabled}) async {}
  @override
  Future<void> setUserIdentifier(String identifier) async {}
}

/// A [ContentRemote] that answers from the documents the upload packaged.
class _ServedRemote implements ContentRemote {
  _ServedRemote(Directory served, {required this.pro}) {
    for (final kind in ContentKind.values) {
      final folder =
          pro && kind == ContentKind.questions ? 'questions-pro' : kind.wire;
      final dir = Directory('${served.path}/$folder');
      if (!dir.existsSync()) continue;
      for (final file in dir.listSync().whereType<File>()) {
        if (!file.path.endsWith('.json')) continue;
        final name = file.uri.pathSegments.last;
        docs['${kind.wire}/${name.substring(0, name.length - 5)}'] =
            (jsonDecode(file.readAsStringSync()) as Map)
                .cast<String, Object?>();
      }
    }
  }

  final bool pro;
  final docs = <String, Map<String, Object?>>{};

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async =>
      ContentFetch(
        tier: pro ? 'pro' : 'free',
        entries: {
          for (final id in ids)
            id: docs.containsKey('${kind.wire}/$id')
                ? RemoteEntry.ok(
                    version: pro ? 'gate.p' : 'gate.f',
                    data: docs['${kind.wire}/$id'],
                  )
                : const RemoteEntry.missing(),
        },
      );
}

/// Runs the gate. [tester] renders; everything else is plain async.
///
/// [served] holds what the upload packages and the app receives, one file per
/// document: `catalog/`, `questions/` and `lessons/` (the output of
/// `tools/upload_content/upload_content.mjs --out-dir`). Everything is loaded
/// through the real `ContentMirror`, as a student's app does. The optional
/// `invalid.txt` is the uploader's list of sources it refused.
Future<GateReport> runContentGate(
  WidgetTester tester,
  Directory served, {
  ServerLimits? limits,
}) async {
  limits ??= ServerLimits.read();
  final report = GateReport();
  await _runTier(tester, served, limits, report, pro: false);
  // The same app code on the Pro copy of every set: wrong-choice notes map,
  // render, and must not break the save or the analytics.
  report.tier = '[Pro copy]';
  await _runTier(tester, served, limits, report, pro: true);
  report.tier = '';
  return report;
}

Future<void> _runTier(
  WidgetTester tester,
  Directory served,
  ServerLimits limits,
  GateReport report, {
  required bool pro,
}) async {
  final contentDb = ContentDatabase(NativeDatabase.memory());
  final appDb = AppDatabase(NativeDatabase.memory());
  late final ContentMirror mirror;
  late final ContentService service;
  addTearDown(contentDb.close);
  addTearDown(appDb.close);
  addTearDown(() async {
    await mirror.dispose();
    await service.dispose();
  });
  late final ContentRepository content;

  // 1. Load through the mirror: catalog first, then every set and lesson.
  await tester.runAsync(() async {
    final invalid = File('${served.path}/invalid.txt');
    if (!pro && invalid.existsSync()) {
      for (final line in invalid.readAsLinesSync()) {
        final m = RegExp(r'^(\S+\.(?:yaml|md)): (.*)$').firstMatch(line);
        if (m != null) report.fail(m[1]!, 'upload', 'not packaged: ${m[2]}');
      }
    }
    service = ContentService(
      remote: _ServedRemote(served, pro: pro),
      cache: ContentCache(appDb),
    );
    mirror = ContentMirror(db: contentDb, service: service);
    content = ContentRepository(contentDb, fetchHook: mirror);
    await mirror.start();
    await mirror.idle;
    report.count('catalog');
  });

  await tester.runAsync(() async {
    // 2. Which exam serves which item.
    final exams = [
      for (final e in await content.listExams())
        if (e.isActive) e,
    ];
    report.examsSeen.addAll(exams.map((e) => e.id));
    final lessonExams = <String, Set<String>>{};
    for (final exam in exams) {
      final topics = await content.topicsByExam(exam.id);
      final lessons = await content.lessonsByTopics(
        [for (final t in topics) t.id],
        examId: exam.id,
      );
      for (final l in lessons.values.expand((x) => x)) {
        (lessonExams[l.id] ??= {}).add(exam.id);
      }
    }

    // 3. Questions.
    final ids = [
      for (final row in await (contentDb.select(contentDb.contentQuestions)
            ..where((q) => q.isActive.equals(true)))
          .get())
        row.id,
    ];
    final ready = await mirror.ensureQuestions(ids);
    await mirror.idle;
    for (final id in ids) {
      if (!ready.contains(id)) {
        report.fail(id, 'loads', 'its question set did not load or apply');
      }
    }
    final questions = await content.hydrateSelectedQuestions(ids);
    final loaded = {for (final q in questions) q.id: q};
    for (final id in ids) {
      if (!loaded.containsKey(id) && ready.contains(id)) {
        report.fail(id, 'loads', 'does not load');
      }
    }

    final telemetry = _Telemetry();
    final submit = SubmitAnswer(
      reviewRepo: ReviewStateRepository(appDb),
      scheduler: const FsrsScheduler(),
      sessions: QuizSessionRepository(appDb),
      telemetry: telemetry,
    );
    final sessions = QuizSessionRepository(appDb);
    final attempts = AttemptsRepository(appDb);
    final completion =
        QuizCompletionCoordinator(attempts: attempts, sessions: sessions);
    final resume = ResumeSession(content: content, sessions: sessions);
    final passages = <String, Passage>{};
    final renderable = <Question>[];
    var n = 0;

    for (final q in questions) {
      report.examsOf[q.id] = q.examIds.toSet();
      report.count('question checked');
      void fail(String check, String cause) => report.fail(q.id, check, cause);

      // Shape: one correct, 2 to 6 choices, unique ids.
      final correct = q.choices.where((c) => c.isCorrect).toList();
      if (correct.length != 1) {
        fail('shape', '${correct.length} correct choices, need exactly 1');
      }
      if (q.choices.length < 2 || q.choices.length > 6) {
        fail('shape', '${q.choices.length} choices, need 2 to 6');
      }
      if (q.choices.map((c) => c.id).toSet().length != q.choices.length) {
        fail('shape', 'choice ids are not unique');
      }
      if (q.stem.trim().isEmpty) fail('shape', 'empty stem');
      if (q.examIds.isEmpty) fail('shape', 'tagged for no exam');

      // Passage must load.
      final pid = q.passageId;
      if (pid != null && !passages.containsKey(pid)) {
        final p = await content.passageById(pid);
        if (p == null) {
          fail('passage', 'passage $pid does not load');
        } else {
          passages[pid] = p;
        }
      }

      if (correct.length != 1 || q.choices.length < 2) continue;
      final right = correct.single;
      final wrong = q.choices.firstWhere((c) => !c.isCorrect);

      // Grading, and the answer saved through SubmitAnswer into a session.
      try {
        final now = DateTime.utc(2026, 11, 23, 1, 0, n % 60);
        final graded = await submit(
          question: q,
          chosenChoiceId: right.id,
          responseMs: 1000,
          now: now,
        );
        if (!graded.isCorrect) fail('grading', 'correct choice graded wrong');

        final sid = 'gate-$n';
        n++;
        final exam = q.examIds.isEmpty ? 'exam_none' : q.examIds.first;
        await sessions.create(
          sessionId: sid,
          userId: 'gate',
          examId: exam,
          origin: SessionOrigin.todayTopic,
          questionIds: [q.id],
          startedAt: now,
        );
        final resumed = await resume(userId: 'gate', examId: exam);
        if (resumed == null ||
            resumed.currentQuestion.id != q.id ||
            resumed.currentIndex != 0) {
          fail('resume', 'a fresh session does not resume at the item');
        }
        telemetry.last = null;
        final outcome = await submit(
          question: q,
          chosenChoiceId: wrong.id,
          responseMs: 1000,
          now: now.add(const Duration(seconds: 1)),
          sessionId: sid,
          userId: 'gate',
          examId: exam,
          origin: 'today_topic',
        );
        if (outcome.isCorrect) fail('grading', 'wrong choice graded correct');
        final props = telemetry.last;
        if (props == null) {
          fail('analytics', 'no question_answered properties logged');
        } else {
          try {
            assertPropertiesAllowed(props);
          } on Object catch (e) {
            fail('analytics', 'properties not allowed: $e');
          }
          final dropped = <String>[];
          allowedProperties(props, onDropped: dropped.add);
          if (dropped.isNotEmpty) fail('analytics', 'dropped $dropped');
        }

        final stored = await sessions.activeFor(userId: 'gate', examId: exam);
        if (stored == null || stored.outcomes.length != 1) {
          fail('save', 'the answer is not in the stored session');
        }
        var session = QuizSession.start(
          sessionId: sid,
          examId: exam,
          questions: [q],
          startedAt: now,
        ).record(outcome);
        session = session.copyWith(currentIndex: 0);
        final attempt = await completion.complete(
          session: session,
          now: now.add(const Duration(seconds: 2)),
          persisted: true,
        );

        // Results and review rebuild from the stored record.
        final saved = await attempts.byId(sid);
        if (saved == null) {
          fail('results', 'completed attempt is not stored');
        } else {
          final review = await hydrateCompletedQuiz(saved, content);
          if (review.score != (0, 1)) {
            fail('results', 'score ${review.score}, expected (0, 1)');
          }
        }

        _checkPayload(attempt, limits, fail);
      } on Object catch (e) {
        fail('save-path', '$e');
      }
      renderable.add(q);
    }

    // 4. Lessons and parts load.
    final lessonIds = [
      for (final row in pro
          ? const <ContentLessonRow>[]
          : await (contentDb.select(contentDb.contentLessons)
                ..where((l) => l.isActive.equals(true)))
              .get())
        row.id,
    ];
    report.count('lesson part', 0);
    for (final id in lessonIds) {
      report.count('lesson part');
      report.examsOf[id] = lessonExams[id] ?? {};
      final lesson = await content.lessonById(id);
      if (lesson == null) {
        report.fail(id, 'lesson', 'does not load');
      } else if (lesson.bodyJson.isEmpty) {
        report.fail(id, 'lesson', 'empty body');
      }
    }

    final mockExams = [if (!pro) ...exams];
    // 5. Mocks fill every slot.
    final blueprints = MockBlueprintRepo(contentDb);
    final container = ProviderContainer(
      overrides: [contentRepositoryProvider.overrideWithValue(content)],
    );
    addTearDown(container.dispose);
    // The existing mock-blueprint-topics check, run on what was loaded. Its
    // accepted findings explain a short section; no new acceptances here.
    final unresolved = findUnresolvedTopics(
      ContentSnapshot(
        blueprints: [
          for (final exam in mockExams)
            for (final bp in await blueprints.byExam(exam.id))
              BlueprintRow(bp.id, exam.id, [
                for (final sec in BlueprintSection.parseList(bp.sectionsJson))
                  BlueprintSectionRow(sec.id, sec.topicIds),
              ]),
        ],
        questions: [
          for (final q in questions)
            QuestionRow(
              id: q.id,
              topicId: q.topicId,
              examIds: q.examIds.toSet(),
              stem: q.stem,
            ),
        ],
      ),
    );
    bool accepted(String blueprint, String section) {
      final found = unresolved.where((v) => v.where == '$blueprint/$section');
      return found.isNotEmpty && found.every((v) => v.acceptedBecause != null);
    }

    for (final exam in mockExams) {
      for (final bp in await blueprints.byExam(exam.id)) {
        report.count('mock blueprint');
        report.examsOf[bp.id] = {exam.id};
        try {
          final pools =
              await container.read(mockQuestionPoolsProvider(exam.id).future);
          final tagged = {
            for (final q in questions)
              if (q.examIds.contains(exam.id)) q.id,
          };
          for (final seed in [1, 2]) {
            final sample = MockSampler().sample(
              sections: BlueprintSection.parseList(bp.sectionsJson),
              poolsByTopic: pools.poolsByTopic,
              passageSetsByTopic: pools.passageSetsByTopic,
              recentlySampledQuestionIds: {},
              seed: seed,
            );
            final defs = BlueprintSection.parseList(bp.sectionsJson);
            for (final s in sample.sections) {
              final want =
                  defs.firstWhere((d) => d.id == s.sectionId).questionCount;
              if (s.questionIds.length != want &&
                  accepted(bp.id, s.sectionId)) {
                final why = unresolved
                    .firstWhere((v) => v.where == '${bp.id}/${s.sectionId}')
                    .acceptedBecause;
                report.accepted.add(
                  '${bp.id} section ${s.sectionId} fills '
                  '${s.questionIds.length} of $want slots (accepted: $why)',
                );
              } else if (s.questionIds.length != want) {
                report.fail(
                  bp.id,
                  'mock',
                  'section ${s.sectionId} fills '
                      '${s.questionIds.length} of $want slots',
                );
              }
              if (s.questionIds.toSet().length != s.questionIds.length) {
                report.fail(
                  bp.id,
                  'mock',
                  'section ${s.sectionId} repeats an item',
                );
              }
              for (final qid in s.questionIds) {
                if (!tagged.contains(qid)) {
                  report.fail(
                    bp.id,
                    'mock',
                    'section ${s.sectionId} holds $qid, which is not '
                        'active and tagged for ${exam.id}',
                  );
                }
              }
            }
            if (sample.sections.length != defs.length) {
              report.fail(bp.id, 'mock', 'a section was left out');
            }
          }
        } on Object catch (e) {
          report.fail(bp.id, 'mock', '$e');
        }
      }
    }

    // Keep the rendering inputs for the widget phase.
    _renderQueue
      ..clear()
      ..addAll(renderable);
    _renderPassages
      ..clear()
      ..addAll(passages);
    _renderLessons.clear();
    for (final id in lessonIds) {
      final l = await content.lessonById(id);
      if (l != null) _renderLessons.add(l.id, l.bodyJson);
    }
  });

  final overrides = [
    appDatabaseProvider.overrideWithValue(appDb),
    contentRepositoryProvider.overrideWithValue(content),
  ];
  // 6. Render offscreen. Real viewer for questions, real renderer for lessons.
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  Future<void> show(String id, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: [PantasColors.light, PantasTypeBundle.create()],
          ),
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
    await tester.pump();
    Object? error;
    while ((error = tester.takeException()) != null) {
      report.fail(id, 'render', '$error'.split('\n').first);
    }
    if (find.byType(ErrorWidget).evaluate().isNotEmpty) {
      report.fail(id, 'render', 'an error widget is on screen');
    }
  }

  for (final q in _renderQueue) {
    report.count('rendered question');
    final wrong = q.choices.firstWhere((c) => !c.isCorrect);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: [PantasColors.light, PantasTypeBundle.create()],
          ),
          home: QuizQuestionViewer(
            questions: [q],
            items: [
              AttemptItem(
                questionId: q.id,
                questionVersion: q.version,
                chosenChoiceId: wrong.id,
                correctChoiceId: q.correctChoice.id,
                responseMs: 1000,
              ),
            ],
            passages: _renderPassages,
            pro: pro,
            onBack: () {},
            onNote: (_, __, ___) async {},
            onReport: (_) async => null,
          ),
        ),
      ),
    );
    await tester.pump();
    Object? error;
    while ((error = tester.takeException()) != null) {
      report.fail(q.id, 'render', '$error'.split('\n').first);
    }
    if (find.byType(ErrorWidget).evaluate().isNotEmpty) {
      report.fail(q.id, 'render', 'an error widget is on screen');
    }
  }
  for (final entry in _renderLessons.entries) {
    await show(
      entry.$1,
      ContentRenderer(blocks: entry.$2, readerFigures: true),
    );
  }
}

void _checkPayload(
  Attempt attempt,
  ServerLimits limits,
  void Function(String check, String cause) fail,
) {
  final payload = studySessionPayload(attempt);
  final answers = payload['answers']! as List;
  if (answers.isEmpty || answers.length > limits.maxAnswers) {
    fail(
      'server',
      '${answers.length} answers, limit 1 to ${limits.maxAnswers}',
    );
  }
  for (final raw in answers) {
    final a = raw as Map<String, Object?>;
    final id = a['questionId']! as String;
    if (!limits.idPattern.hasMatch(id) || id.length > limits.maxIdLength) {
      fail(
        'server',
        'question id is ${id.length} characters; the server takes at most '
            '${limits.maxIdLength} of letters, digits, _ . -',
      );
    }
    final chosen = a['chosen'];
    if (chosen is! String || chosen.length > limits.maxIdLength + 2) {
      fail(
        'server',
        'chosen choice id is too long: '
            '${chosen is String ? chosen.length : chosen}',
      );
    }
    final ms = a['responseMs'];
    if (ms is! int || ms < 0 || ms > 86400000) {
      fail('server', 'bad responseMs $ms');
    }
    final v = a['questionVersion'];
    if (v is! int || v < 1) fail('server', 'bad questionVersion $v');
  }
}

final _renderQueue = <Question>[];
final _renderPassages = <String, Passage>{};
final _renderLessons = _LessonList();

class _LessonList {
  final _items = <(String, List<Map<String, dynamic>>)>[];
  void clear() => _items.clear();
  void add(String id, List<Map<String, dynamic>> body) =>
      _items.add((id, body));
  Iterable<(String, List<Map<String, dynamic>>)> get entries => _items;
}

String _lines(List<GateFailure> failures) =>
    failures.map((f) => '${f.itemId} [${f.check}] ${f.cause}').join('\n');
