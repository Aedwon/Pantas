import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/data/study_observations.dart';

/// The lesson ids in one batched `recordLessonRead` payload.
List<String> readIds(Map<String, Object?> p) => [
      for (final read in p['reads']! as List<Object?>)
        (read! as Map<String, Object?>)['lessonId']! as String,
    ];

void main() {
  test('a rejected observation does not prevent later real observations',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    for (final id in ['bad', 'good']) {
      await db.into(db.lessonProgressLocal).insert(
            LessonProgressLocalCompanion.insert(
              lessonId: id,
              readAt: DateTime.utc(2026, 10, 24),
            ),
          );
    }
    final calls = <List<String>>[];
    final sender = StudyObservations(
      db,
      coreToken: 'c',
      request: StudyRequest(
        uid: 'u',
        examId: 'e',
        isCurrent: () async => true,
        api: StudyApi((_, p) async {
          final ids = readIds(p);
          calls.add(ids);
          // The server rejects the retired lesson and keeps the other.
          return <String, Object?>{
            'stored': [ids.indexOf('good')],
            'unchanged': <int>[],
            'rejected': [ids.indexOf('bad')],
          };
        }),
      ),
    );
    await sender.flush();
    expect(calls, [
      ['bad', 'good'],
    ]);
    await sender.flush();
    expect(calls, hasLength(1), reason: 'both rows have a receipt now');
    final receipts = await db.select(db.devicePrefs).get();
    final byKey = {for (final r in receipts) r.key: r.value};
    expect(
      byKey.entries.where((e) => e.key.contains('lesson_bad_')).single.value,
      'rejected',
    );
    expect(
      byKey.entries.where((e) => e.key.contains('lesson_good_')).single.value,
      '1',
    );
  });

  for (final code in ['permission-denied', 'failed-precondition']) {
    test('$code observations are not retried on every read', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.into(db.lessonProgressLocal).insert(
            LessonProgressLocalCompanion.insert(
              lessonId: 'l',
              readAt: DateTime(2026),
            ),
          );
      var calls = 0;
      final sender = StudyObservations(
        db,
        coreToken: 'c',
        request: StudyRequest(
          uid: 'u',
          examId: 'e',
          isCurrent: () async => true,
          api: StudyApi((_, __) async {
            calls++;
            throw FirebaseFunctionsException(code: code, message: 'Rejected');
          }),
        ),
      );
      await expectLater(
        sender.flush(),
        throwsA(isA<FirebaseFunctionsException>()),
      );
      await sender.flush();
      expect(calls, 1);
    });
  }
  test('malformed local timing cannot block a valid later session', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    for (final id in ['bad', 'good']) {
      await AttemptsRepository(db).save(
        Attempt(
          id: id,
          examId: 'e',
          origin: 'drill',
          startedAt: DateTime(2026, 10, 24, 12),
          completedAt: DateTime(2026, 10, 24, id == 'bad' ? 11 : 13),
          items: const [
            AttemptItem(
              questionId: 'q',
              questionVersion: 1,
              chosenChoiceId: 'a',
              correctChoiceId: 'a',
              responseMs: 1000,
            ),
          ],
        ),
      );
    }
    final sent = <String>[];
    final sender = StudyObservations(
      db,
      coreToken: 'c',
      request: StudyRequest(
        uid: 'u',
        examId: 'e',
        isCurrent: () async => true,
        api: StudyApi((_, p) async {
          sent.add(p['sessionId']! as String);
          return <String, Object?>{};
        }),
      ),
    );
    await expectLater(sender.flush(), throwsStateError);
    expect(sent, ['good']);
    await sender.flush();
    expect(sent, ['good']);
  });

  test('rate limit surfaces from the one batched call', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    for (final id in ['first', 'second']) {
      await db.into(db.lessonProgressLocal).insert(
            LessonProgressLocalCompanion.insert(
              lessonId: id,
              readAt: DateTime.utc(2026, 10, 24),
            ),
          );
    }
    final sent = <String>[];
    final sender = StudyObservations(
      db,
      coreToken: 'c',
      request: StudyRequest(
        uid: 'u',
        examId: 'e',
        isCurrent: () async => true,
        api: StudyApi((_, p) async {
          sent.addAll(readIds(p));
          throw FirebaseFunctionsException(
            code: 'resource-exhausted',
            message: 'Quota',
          );
        }),
      ),
    );
    await expectLater(
      sender.flush(),
      throwsA(isA<FirebaseFunctionsException>()),
    );
    expect(sent, ['first', 'second'], reason: 'both reads in one call');
  });

  test('stored lesson reads retry with original owner and earliest actual time',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'lesson',
            readAt: DateTime.utc(2026, 10, 24),
          ),
        );
    var online = false;
    var current = true;
    final sent = <Map<String, Object?>>[];
    final sender = StudyObservations(
      db,
      coreToken: 'core',
      request: StudyRequest(
        api: StudyApi((name, data) async {
          expect(name, 'recordLessonRead');
          sent.add(data);
          if (!online) throw StateError('offline');
          return <String, Object?>{};
        }),
        uid: 'original',
        examId: 'exam',
        isCurrent: () async => current,
      ),
    );
    await expectLater(sender.flush(), throwsStateError);
    online = true;
    await sender.flush();
    await sender.flush();
    expect(sent, hasLength(2));
    expect(sent.first, sent.last);
    expect(
      (sent.last['reads']! as List<Object?>).single,
      {
        'lessonId': 'lesson',
        'readAt': DateTime.utc(2026, 10, 24).millisecondsSinceEpoch,
      },
    );
    expect(sent.last['expectedUid'], 'original');
    current = false;
    await expectLater(sender.flush(), throwsStateError);
    expect(sent, hasLength(2));
  });
  group('a first sync of many lesson reads', () {
    Future<AppDatabase> dbWithReads(int count) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.batch(
        (b) => b.insertAll(db.lessonProgressLocal, [
          for (var i = 0; i < count; i++)
            LessonProgressLocalCompanion.insert(
              lessonId: 'l$i',
              readAt: DateTime.utc(2026, 10, 24, 0, 0, i),
            ),
        ]),
      );
      return db;
    }

    StudyObservations senderFor(
      AppDatabase db,
      Future<Object?> Function(String, Map<String, Object?>) call,
    ) =>
        StudyObservations(
          db,
          coreToken: 'c',
          request: StudyRequest(
            uid: 'u',
            examId: 'e',
            isCurrent: () async => true,
            api: StudyApi(call),
          ),
        );

    test('N reads up to 200 make one call, 201 make two', () async {
      for (final (count, calls) in [(1, 1), (50, 1), (200, 1), (201, 2)]) {
        final db = await dbWithReads(count);
        final sizes = <int>[];
        final sender = senderFor(db, (name, p) async {
          expect(name, 'recordLessonRead');
          sizes.add(readIds(p).length);
          return <String, Object?>{
            'stored': List<int>.generate(readIds(p).length, (i) => i),
            'unchanged': <int>[],
            'rejected': <int>[],
          };
        });
        await sender.flush();
        expect(sizes.length, calls, reason: '$count reads');
        expect(sizes.reduce((a, b) => a + b), count);
        expect(sizes.every((s) => s <= 200), isTrue);
        await sender.flush();
        expect(sizes.length, calls, reason: 'every row has a receipt');
      }
    });

    test('each row gets its own receipt and a rejected one blocks no other',
        () async {
      final db = await dbWithReads(5);
      var calls = 0;
      final sender = senderFor(db, (_, p) async {
        calls++;
        return <String, Object?>{
          'stored': [0, 4],
          'unchanged': [1, 2],
          'rejected': [3],
        };
      });
      await sender.flush();
      final receipts = {
        for (final r in await db.select(db.devicePrefs).get()) r.key: r.value,
      };
      String receiptFor(String id) => receipts.entries
          .singleWhere((e) => e.key.contains('lesson_${id}_'))
          .value;
      expect(
        [for (var i = 0; i < 5; i++) receiptFor('l$i')],
        ['1', '1', '1', 'rejected', '1'],
      );
      await sender.flush();
      expect(calls, 1);
    });

    test('a failed call leaves the reads unsent for the next sync', () async {
      final db = await dbWithReads(3);
      var online = false;
      var calls = 0;
      final sender = senderFor(db, (_, p) async {
        calls++;
        if (!online) throw StateError('offline');
        return <String, Object?>{};
      });
      await expectLater(sender.flush(), throwsStateError);
      expect(await db.select(db.devicePrefs).get(), isEmpty);
      online = true;
      await sender.flush();
      await sender.flush();
      expect(calls, 2);
    });

    test('a rate limit stops the pass without marking anything', () async {
      final db = await dbWithReads(201);
      var calls = 0;
      final sender = senderFor(db, (_, __) async {
        calls++;
        throw FirebaseFunctionsException(
          code: 'resource-exhausted',
          message: 'Slow down',
        );
      });
      await expectLater(
        sender.flush(),
        throwsA(isA<FirebaseFunctionsException>()),
      );
      expect(calls, 1, reason: 'the second chunk is not tried');
      expect(await db.select(db.devicePrefs).get(), isEmpty);
    });
  });

  test('a receipt is read once and a sent row is never loaded', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // A row that cannot be read back. Loading it would fail the flush, so a
    // flush that passes proves the sent row was skipped before loading.
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'sent',
            examId: 'e',
            startedAt: DateTime(2026, 10, 24, 12),
            completedAt: Value(DateTime(2026, 10, 24, 13)),
            origin: const Value('drill'),
            itemsJson: 'not json',
          ),
        );
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(
            key: 'home_sent_u_c_session_sent',
            value: '1',
          ),
        );
    // A receipt for another account must not hide this account's row.
    final readAtMs = DateTime.utc(2026, 10, 24).millisecondsSinceEpoch;
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'kept',
            readAt: DateTime.utc(2026, 10, 24),
          ),
        );
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(
            key: 'home_sent_other_c_lesson_kept_$readAtMs',
            value: '1',
          ),
        );
    final sent = <String>[];
    final sender = StudyObservations(
      db,
      coreToken: 'c',
      request: StudyRequest(
        uid: 'u',
        examId: 'e',
        isCurrent: () async => true,
        api: StudyApi((name, p) async {
          sent.add(name);
          return <String, Object?>{};
        }),
      ),
    );

    await sender.flush();

    expect(sent, ['recordLessonRead'], reason: 'only the unsent lesson');
  });

  test('two senders flushing at once send each observation once', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    for (final id in ['a', 'b']) {
      await db.into(db.lessonProgressLocal).insert(
            LessonProgressLocalCompanion.insert(
              lessonId: id,
              readAt: DateTime.utc(2026, 10, 24),
            ),
          );
    }
    final gate = Completer<void>();
    final sent = <String>[];
    StudyObservations senderFor() => StudyObservations(
          db,
          coreToken: 'c',
          request: StudyRequest(
            uid: 'u',
            examId: 'e',
            isCurrent: () async => true,
            api: StudyApi((_, p) async {
              sent.addAll(readIds(p));
              await gate.future;
              return <String, Object?>{};
            }),
          ),
        );

    // The read path and the lifecycle path each own a sender.
    final both = Future.wait([senderFor().flush(), senderFor().flush()]);
    await pumpEventQueue();
    gate.complete();
    await both;

    expect(sent, ['a', 'b']);
  });

  test('a flush started by a stale owner does not fail a current sender',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'a',
            readAt: DateTime.utc(2026, 10, 24),
          ),
        );
    final sent = <String>[];
    StudyObservations senderFor({required bool current}) => StudyObservations(
          db,
          coreToken: 'c',
          request: StudyRequest(
            uid: 'u',
            examId: 'e',
            isCurrent: () async => current,
            api: StudyApi((_, p) async {
              sent.addAll(readIds(p));
              return <String, Object?>{};
            }),
          ),
        );

    final stale = senderFor(current: false).flush();
    final live = senderFor(current: true).flush();

    await expectLater(stale, throwsStateError);
    await live;
    expect(sent, ['a']);
  });

  test(
      'a flush that joins a running one still sends work finished after it '
      'took its snapshot', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'old',
            readAt: DateTime.utc(2026, 10, 24),
          ),
        );
    final gate = Completer<void>();
    final sent = <String>[];
    final sender = StudyObservations(
      db,
      coreToken: 'c',
      request: StudyRequest(
        uid: 'u',
        examId: 'e',
        isCurrent: () async => true,
        api: StudyApi((endpoint, p) async {
          final lessons = p['reads'] == null ? <String>[] : readIds(p);
          sent.add(
            '$endpoint:${lessons.isEmpty ? p['sessionId'] : lessons.join(',')}',
          );
          if (lessons.contains('old')) await gate.future;
          return <String, Object?>{};
        }),
      ),
    );

    final first = sender.flush();
    await pumpEventQueue();
    expect(sent, ['recordLessonRead:old'], reason: 'the older send is held');

    // A quiz finishes after the running pass took its snapshot.
    await AttemptsRepository(db).save(
      Attempt(
        id: 'fresh',
        examId: 'e',
        origin: 'drill',
        startedAt: DateTime(2026, 10, 24, 12),
        completedAt: DateTime(2026, 10, 24, 13),
        items: const [
          AttemptItem(
            questionId: 'q',
            questionVersion: 1,
            chosenChoiceId: 'a',
            correctChoiceId: 'a',
            responseMs: 1000,
          ),
        ],
      ),
    );
    var secondDone = false;
    var thirdDone = false;
    final second = sender.flush().whenComplete(() => secondDone = true);
    final third = sender.flush().whenComplete(() => thirdDone = true);
    await pumpEventQueue();
    expect(secondDone, isFalse);
    expect(thirdDone, isFalse);

    gate.complete();
    await Future.wait([first, second, third]);

    expect(
      sent.where((s) => s == 'ingestSession:fresh'),
      hasLength(1),
      reason: 'the new attempt is sent, once',
    );
    expect(sent.where((s) => s == 'recordLessonRead:old'), hasLength(1));
    // The callers resolved only after the new attempt went out.
    expect(sent, contains('ingestSession:fresh'));
    await sender.flush();
    expect(sent, hasLength(2), reason: 'nothing acknowledged is sent again');
  });

  group('a custom exam session', () {
    const customId = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';

    Future<void> saveSession(AppDatabase db, String examId) =>
        AttemptsRepository(db).save(
          Attempt(
            id: 'att',
            examId: examId,
            origin: 'drill',
            startedAt: DateTime(2026, 10, 24, 12),
            completedAt: DateTime(2026, 10, 24, 13),
            items: const [
              AttemptItem(
                questionId: 'q',
                questionVersion: 1,
                chosenChoiceId: 'a',
                correctChoiceId: 'a',
                responseMs: 1000,
              ),
            ],
          ),
        );

    StudyObservations senderFor(
      AppDatabase db,
      String examId,
      List<String> sent, {
      Future<void> Function()? onSend,
    }) =>
        StudyObservations(
          db,
          coreToken: 'c',
          request: StudyRequest(
            uid: 'u',
            examId: examId,
            isCurrent: () async => true,
            api: StudyApi((name, p) async {
              sent.add('$name:${p['sessionId']}');
              await onSend?.call();
              return <String, Object?>{};
            }),
          ),
        );

    test('is recorded under its own delivery id', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await saveSession(db, customId);
      final sent = <String>[];

      await senderFor(db, customId, sent).flush();

      expect(sent, ['ingestSession:att']);
      final prefs = AppPreferencesRepository(db);
      expect(await prefs.deviceValue('home_sent_u_c_custom_session_att'), '1');
      expect(await prefs.deviceValue('home_sent_u_c_session_att'), isNull);
    });

    test('a listed exam keeps its old delivery id', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await saveSession(db, 'e');
      final sent = <String>[];

      await senderFor(db, 'e', sent).flush();

      final prefs = AppPreferencesRepository(db);
      expect(await prefs.deviceValue('home_sent_u_c_session_att'), '1');
      expect(
        await prefs.deviceValue('home_sent_u_c_custom_session_att'),
        isNull,
      );
    });

    test('an old rejected receipt does not block it, and it is sent once',
        () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await saveSession(db, customId);
      await AppPreferencesRepository(db)
          .setDeviceValue('home_sent_u_c_session_att', 'rejected');
      final sent = <String>[];
      final sender = senderFor(db, customId, sent);

      await sender.flush();
      await sender.flush();

      expect(sent, ['ingestSession:att']);
      expect(
        await AppPreferencesRepository(db)
            .deviceValue('home_sent_u_c_session_att'),
        'rejected',
      );
    });

    test('a rejection under the new id is final', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await saveSession(db, customId);
      var calls = 0;
      final sender = StudyObservations(
        db,
        coreToken: 'c',
        request: StudyRequest(
          uid: 'u',
          examId: customId,
          isCurrent: () async => true,
          api: StudyApi((_, __) async {
            calls++;
            throw FirebaseFunctionsException(
              code: 'invalid-argument',
              message: 'Rejected',
            );
          }),
        ),
      );

      await expectLater(
        sender.flush(),
        throwsA(isA<FirebaseFunctionsException>()),
      );
      await sender.flush();

      expect(calls, 1);
      expect(
        await AppPreferencesRepository(db)
            .deviceValue('home_sent_u_c_custom_session_att'),
        'rejected',
      );
    });

    test('lesson reads keep their delivery id', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final readAt = DateTime.utc(2026, 10, 24);
      await db.into(db.lessonProgressLocal).insert(
            LessonProgressLocalCompanion.insert(
              lessonId: 'lesson',
              readAt: readAt,
            ),
          );

      await senderFor(db, customId, []).flush();

      expect(
        await AppPreferencesRepository(db).deviceValue(
          'home_sent_u_c_lesson_lesson_${readAt.millisecondsSinceEpoch}',
        ),
        '1',
      );
    });
  });
}
