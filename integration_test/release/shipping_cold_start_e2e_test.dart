import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pantas/core/content/bundle/protected_content_installer.dart';
import 'package:pantas/core/content/content_seed_version.dart';
import 'package:pantas/core/content/security/content_package_verifier.dart';
import 'package:pantas/core/content/security/content_signing_keys.dart';
import 'package:pantas/core/storage/storage.dart';

import 'support/release_harness.dart';

const _candidate = String.fromEnvironment('RELEASE_E2E_CANDIDATE');
const _contentSha = String.fromEnvironment('RELEASE_E2E_CONTENT_SHA');
const _localOnly = bool.fromEnvironment('RELEASE_E2E_LOCAL_ONLY');

const _examName = 'Civil Service Examination — Professional';
const _topicName = 'Vocabulary';
const _lessonId = 'les_vocab_context';
const _lessonTitle = 'Reading Context Clues';

Future<void> _openShippingLessonFromStudy(WidgetTester tester) async {
  await tapReleaseControl(
    tester,
    find.text('Study').last,
  );

  final studyList = find.byType(ListView);
  await _waitForShippingControl(
    tester,
    studyList,
    diagnostics: 'waiting for Study topic list',
    hitTestable: true,
  );

  final topic = find.text(_topicName);
  await tester.dragUntilVisible(
    topic,
    studyList,
    const Offset(0, -240),
    maxIteration: 20,
  );
  await tester.pumpAndSettle();
  await tapReleaseControl(
    tester,
    topic,
  );
  await tapReleaseControl(
    tester,
    find.text(_lessonTitle),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shipping cold start persists lesson read state offline',
      (tester) async {
    expect(RegExp(r'^[0-9a-fA-F]{40}$').hasMatch(_candidate), isTrue);
    expect(RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(_contentSha), isTrue);
    expect(_localOnly, isTrue);
    final payload = await rootBundle.load(ContentPackageAssets.payloadPath);
    expect(
      sha256
          .convert(
            payload.buffer.asUint8List(
              payload.offsetInBytes,
              payload.lengthInBytes,
            ),
          )
          .toString(),
      _contentSha,
    );
    final installed = await ensureProtectedContentInstalled(
      verifier: BundledContentPackageVerifier(
        loadAssetBytes: (path) async {
          final data = await rootBundle.load(path);
          return data.buffer
              .asUint8List(data.offsetInBytes, data.lengthInBytes);
        },
        signingKeyLookup: ContentSigningKeys.lookupEntry,
        bootstrapKeyLookup: (id) => id != 'content-bootstrap-v1'
            ? null
            : ContentBootstrapKeyEntry(
                keyId: id,
                keyBytes: base64Decode(
                  const String.fromEnvironment(
                    'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64',
                  ),
                ),
                sequenceWindow:
                    const ContentSequenceWindow(minReleaseSequence: 1),
              ),
      ),
    );
    expect(installed.identity.payloadSha256, _contentSha);
    // The version describes the source corpus, not the encrypted payload hash.
    expect(contentSeedVersion, isNotEmpty);

    final harness = ReleaseHarness();
    await harness.openDatabases();
    try {
      final content = harness.providerContainer.read(contentRepositoryProvider);
      final shippingExam = (await content.listExams()).singleWhere(
        (exam) => exam.name == _examName,
      );
      expect(shippingExam.isActive, isTrue);

      final shippingLesson = await content.lessonById(_lessonId);
      expect(shippingLesson?.title, _lessonTitle);
      expect(shippingLesson?.bodyJson, isNotEmpty);

      await harness.pumpProductionApp(tester);
      await tester.pumpAndSettle();
      await completeOnboardingThroughUi(
        tester,
        examId: 'exam_cse_pro',
        studentName: 'Release Shipping',
      );

      final skipNotificationRationale = find.text('Not right now');
      if (skipNotificationRationale.evaluate().isNotEmpty) {
        await tester.tap(skipNotificationRationale);
        await tester.pumpAndSettle();
      }

      expect(find.text('Study'), findsWidgets);
      await _openShippingLessonFromStudy(tester);
      expect(find.text(_lessonTitle), findsWidgets);

      final progress =
          harness.providerContainer.read(lessonProgressRepositoryProvider);
      final reader = find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.controller != null &&
            widget.scrollDirection == Axis.vertical,
      );
      final scrollController =
          tester.widget<SingleChildScrollView>(reader).controller;
      expect(scrollController, isNotNull);
      for (var attempt = 0;
          attempt < 300 && scrollController!.position.extentAfter > 1;
          attempt++) {
        // Finish the real reader scroll with bounded gestures. Keep each
        // gesture small so the pull-to-advance affordance cannot be armed.
        await tester.drag(reader, const Offset(0, -40));
        await tester.pumpAndSettle();
      }
      expect(
        scrollController!.position.extentAfter,
        lessThanOrEqualTo(1),
        reason: 'reader must reach its real end through production scrolling',
      );

      await waitUntil(
        () async {
          if (await progress.isRead(_lessonId)) return true;

          // The real dwell timer reads the reader's current end position.
          await tester.pump();
          return progress.isRead(_lessonId);
        },
        deadline: DateTime.now().add(const Duration(seconds: 25)),
        diagnostics: () => 'lesson=$_lessonId '
            'routeTitle='
            '${find.text(_lessonTitle).evaluate().length}',
        pollInterval: const Duration(milliseconds: 100),
        delay: (duration) => tester.runAsync(
          () => Future<void>.delayed(duration),
        ),
      );
      expect(await progress.isRead(_lessonId), isTrue);

      await harness.reconstruct(
        disposeAppTree: () async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        },
      );
      await harness.pumpProductionApp(tester);
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsNothing);
      final reopenedProgress =
          harness.providerContainer.read(lessonProgressRepositoryProvider);
      expect(await reopenedProgress.isRead(_lessonId), isTrue);

      final reopenedContent =
          harness.providerContainer.read(contentRepositoryProvider);
      final reopenedLesson = await reopenedContent.lessonById(_lessonId);
      expect(reopenedLesson?.title, _lessonTitle);
      expect(reopenedLesson?.bodyJson, isNotEmpty);

      await _openShippingLessonFromStudy(tester);
      expect(find.text(_lessonTitle), findsWidgets);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await harness.dispose();
    }
  });
}

Future<void> _waitForShippingControl(
  WidgetTester tester,
  Finder target, {
  required String diagnostics,
  bool hitTestable = false,
}) =>
    waitUntil(
      () async {
        await tester.pump();
        return target.evaluate().length == 1 &&
            (!hitTestable || target.hitTestable().evaluate().length == 1);
      },
      deadline: DateTime.now().add(const Duration(seconds: 10)),
      diagnostics: () => diagnostics,
      delay: tester.pump,
    );
