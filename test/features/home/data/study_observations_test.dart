import 'package:cloud_functions/cloud_functions.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/data/study_observations.dart';

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
    final sent = <String>[];
    final sender = StudyObservations(
      db,
      coreToken: 'c',
      request: StudyRequest(
        uid: 'u',
        examId: 'e',
        isCurrent: () async => true,
        api: StudyApi((_, p) async {
          sent.add(p['lessonId']! as String);
          if (p['lessonId'] == 'bad') {
            throw FirebaseFunctionsException(
              code: 'invalid-argument',
              message: 'Retired lesson',
            );
          }
          return <String, Object?>{};
        }),
      ),
    );
    await expectLater(
      sender.flush(),
      throwsA(isA<FirebaseFunctionsException>()),
    );
    expect(sent, ['bad', 'good']);
    await sender.flush();
    expect(sent, ['bad', 'good']);
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

  test('rate limit stops the flush before the next observation', () async {
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
          sent.add(p['lessonId']! as String);
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
    expect(sent, ['first']);
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
      sent.last['readAt'],
      DateTime.utc(2026, 10, 24).millisecondsSinceEpoch,
    );
    expect(sent.last['expectedUid'], 'original');
    current = false;
    await expectLater(sender.flush(), throwsStateError);
    expect(sent, hasLength(2));
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
