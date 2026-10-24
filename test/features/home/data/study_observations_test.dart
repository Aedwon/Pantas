import 'package:cloud_functions/cloud_functions.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
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
    await expectLater(
      sender.flush(),
      throwsA(isA<FirebaseFunctionsException>()),
    );
    expect(sent, ['bad', 'good', 'bad']);
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
}
