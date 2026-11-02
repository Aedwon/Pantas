import 'dart:async';

import 'package:flutter/widgets.dart';

import 'api.dart';
import 'databases.dart';
import 'exams.dart';
import 'models.dart';
import 'study_order.dart';

/// One line of the queue: a group heading or an item.
class QueueRow {
  const QueueRow.header(this.heading, this.done, this.total) : item = null;
  const QueueRow.item(ReviewItem this.item)
      : heading = null,
        done = 0,
        total = 0;

  final String? heading;
  final int done;
  final int total;
  final ReviewItem? item;
}

const _groupOrder = [
  ('lesson', 'Lessons'),
  ('question', 'Questions'),
  ('mock', 'Mock exams'),
  ('figure', 'Figures'),
];

/// Everything the reviewer window shows and changes.
class ReviewController extends ChangeNotifier {
  ReviewController({required this.api, required this.databases});

  final ContentPassApi api;
  final ReviewDatabases databases;

  /// Where each exam's lessons sit, taken from the app's own study map.
  Map<String, List<String>> studyOrder = {};
  final Map<String, List<ReviewItem>> _byExam = {};
  final Map<String, ReviewItem> _byId = {};
  final Map<String, NoteRecord> _records = {};

  String exam = 'cse-pro';

  /// `not_reviewed`, `tagged` or `all`.
  String statusFilter = 'not_reviewed';
  bool wide = false;
  bool dark = false;
  String? currentId;
  String screenState = 'question';
  String? wrongLetter;

  int generation = 0;
  String commitLabel = '';
  String? notice;
  String? message;
  bool checking = false;
  bool nothingLeft = false;

  /// Lessons the study map lists that the manifest has no entry for, and the
  /// reverse, per exam.
  final Map<String, ({int map, int files})> lessonCounts = {};

  final FocusNode commentFocus = FocusNode();
  final TextEditingController commentText = TextEditingController();
  Timer? _debounce;
  var _dirtyComment = false;

  ReviewItem? get current => _byId[currentId];

  List<ReviewItem> get _items => _byExam[exam] ?? const [];

  NoteRecord recordOf(String id) => _records[id] ?? NoteRecord(id: id);

  bool _matches(ReviewItem item) {
    final status = recordOf(item.id).status;
    return switch (statusFilter) {
      'not_reviewed' => status == 'not_reviewed',
      'tagged' => status == 'tagged',
      _ => true,
    };
  }

  List<QueueRow> get rows {
    final out = <QueueRow>[];
    for (final (kind, heading) in _groupOrder) {
      final ofKind = [
        for (final i in _items)
          if (i.kind == kind) i,
      ];
      if (ofKind.isEmpty) continue;
      final done =
          ofKind.where((i) => recordOf(i.id).status != 'not_reviewed').length;
      out.add(QueueRow.header(heading, done, ofKind.length));
      for (final item in ofKind) {
        if (_matches(item) || item.id == currentId) {
          out.add(QueueRow.item(item));
        }
      }
    }
    return out;
  }

  // Loading --------------------------------------------------------------

  Future<void> load({Map<String, String> query = const {}}) async {
    final state = await api.state();
    final manifest = await api.manifest();
    studyOrder = await computeStudyOrder(databases);
    _setItems(manifest);
    _records
      ..clear()
      ..addAll({
        for (final r in (state['records'] as List? ?? const []))
          (r as Map)['id'] as String:
              NoteRecord.fromJson(Map<String, Object?>.from(r)),
      });
    _applyState(state);
    final position = Map<String, Object?>.from(
      state['position'] as Map? ?? const {},
    );
    exam = _pick(query['exam'] ?? position['exam'], examCodes, exam);
    statusFilter = _pick(
      position['status'],
      const ['not_reviewed', 'tagged', 'all'],
      statusFilter,
    );
    final size = query['size'] ?? position['size'];
    wide = size == 'wide';
    final theme = query['theme'] ?? position['theme'];
    dark = theme == 'dark';
    final wanted = query['item'] ?? position['itemId'];
    final wantedItem = _byId[wanted];
    if (wantedItem != null) {
      exam = wantedItem.exams.contains(exam) ? exam : wantedItem.exams.first;
      _open(
        wantedItem,
        state: query['state'] ?? position['questionState'] as String?,
      );
      wrongLetter = query['choice'] ?? (position['choice'] as String?);
    } else {
      _openFirst();
    }
    if (query.isNotEmpty) _savePosition();
    notifyListeners();
  }

  String _pick(Object? value, List<String> allowed, String fallback) =>
      allowed.contains(value) ? value! as String : fallback;

  void _applyState(Map<String, Object?> state) {
    generation = state['generation'] as int? ?? generation;
    commitLabel = '${state['label'] ?? ''}';
    final back = state['wentBack'] as int? ?? 0;
    final notes = state['notesNotice'] as String?;
    notice = notes ??
        (back > 0
            ? '$back ${back == 1 ? 'item' : 'items'} changed and went back '
                'to Not reviewed.'
            : null);
    final msg = '${state['message'] ?? ''}';
    message = msg.isEmpty ? null : msg;
  }

  void _setItems(Map<String, Object?> manifest) {
    final all = [
      for (final i in manifest['items']! as List)
        ReviewItem.fromJson(Map<String, Object?>.from(i as Map)),
    ];
    _byExam.clear();
    _byId
      ..clear()
      ..addAll({for (final i in all) i.id: i});
    lessonCounts.clear();
    for (final code in examCodes) {
      final order = studyOrder[code] ?? const <String>[];
      final position = {for (var i = 0; i < order.length; i++) order[i]: i};
      final mine = [
        for (final i in all)
          if (i.exams.contains(code)) i,
      ];
      final lessons = mine.where((i) => i.kind == 'lesson').toList();
      final inMap = lessons.where((l) => position.containsKey(l.id)).toList()
        ..sort((a, b) => position[a.id]!.compareTo(position[b.id]!));
      lessonCounts[code] = (map: order.length, files: lessons.length);
      int lessonRank(String? id) => position[id] ?? 1 << 20;
      final questions = mine.where((i) => i.kind == 'question').toList()
        ..sort((a, b) {
          final byLesson =
              lessonRank(a.lessonId).compareTo(lessonRank(b.lessonId));
          return byLesson != 0 ? byLesson : a.order.compareTo(b.order);
        });
      final mocks = mine.where((i) => i.kind == 'mock').toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      final figures = [
        for (final f in mine.where((i) => i.kind == 'figure'))
          if (position.containsKey(f.lessonId)) f,
      ]..sort((a, b) {
          final byLesson =
              lessonRank(a.lessonId).compareTo(lessonRank(b.lessonId));
          return byLesson != 0 ? byLesson : (a.seq ?? 0).compareTo(b.seq ?? 0);
        });
      _byExam[code] = [...inMap, ...questions, ...mocks, ...figures];
    }
  }

  /// Asks the server to check the source again, then reloads when it changed.
  Future<void> checkForUpdates() async {
    checking = true;
    notifyListeners();
    try {
      final before = generation;
      final state = await api.refresh();
      if ((state['generation'] as int? ?? before) != before) {
        await databases.replaceContent(await api.contentDb());
        final id = currentId;
        final manifest = await api.manifest();
        studyOrder = await computeStudyOrder(databases);
        _setItems(manifest);
        _records
          ..clear()
          ..addAll({
            for (final r in (state['records'] as List? ?? const []))
              (r as Map)['id'] as String:
                  NoteRecord.fromJson(Map<String, Object?>.from(r)),
          });
        currentId = _byId.containsKey(id) ? id : null;
        if (currentId == null) _openFirst();
      }
      _applyState(state);
    } on Object catch (e) {
      message = 'Could not check for updates: $e';
    } finally {
      checking = false;
      notifyListeners();
    }
  }

  // Navigation -----------------------------------------------------------

  void _openFirst() {
    final first = _items.where(_matches).firstOrNull;
    if (first != null) {
      _open(first);
      return;
    }
    final any = _items.firstOrNull;
    if (any == null) {
      currentId = null;
    } else {
      _open(any);
      nothingLeft = true;
    }
  }

  void _open(ReviewItem item, {String? state}) {
    currentId = item.id;
    nothingLeft = false;
    wrongLetter = null;
    screenState = switch (item.kind) {
      'question' => const ['question', 'correct', 'wrong'].contains(state)
          ? state!
          : 'question',
      'mock' => state == 'exam' ? 'exam' : 'start',
      _ => '',
    };
    final record = recordOf(item.id);
    commentText.text = record.comment;
    _dirtyComment = false;
  }

  /// Opens an item from the queue.
  void select(ReviewItem item) {
    flushComment();
    _open(item);
    _savePosition();
    notifyListeners();
  }

  void dismissNotice() {
    notice = null;
    notifyListeners();
  }

  void setExam(String code) {
    if (code == exam) return;
    flushComment();
    exam = code;
    _openFirst();
    _savePosition();
    notifyListeners();
  }

  void setStatusFilter(String value) {
    flushComment();
    statusFilter = value;
    nothingLeft = false;
    final current = _items.where((i) => i.id == currentId).firstOrNull;
    if (current == null || !_matches(current)) _openFirst();
    _savePosition();
    notifyListeners();
  }

  void setWide({required bool value}) {
    wide = value;
    _savePosition();
    notifyListeners();
  }

  void setDark({required bool value}) {
    dark = value;
    _savePosition();
    notifyListeners();
  }

  void setScreenState(String value) {
    screenState = value;
    wrongLetter = null;
    _savePosition();
    notifyListeners();
  }

  void setWrongLetter(String letter) {
    wrongLetter = letter;
    _savePosition();
    notifyListeners();
  }

  void _savePosition() {
    unawaited(
      api.savePosition({
        'exam': exam,
        'status': statusFilter,
        'itemId': currentId,
        'size': wide ? 'wide' : 'phone',
        'theme': dark ? 'dark' : 'light',
        'questionState': screenState,
        'choice': wrongLetter,
      }),
    );
  }

  // Notes ----------------------------------------------------------------

  void toggleTag(int index) {
    final item = current;
    if (item == null) return;
    final name = tagNames[index];
    final record = recordOf(item.id);
    final tags = [...record.tags];
    if (!tags.remove(name)) tags.add(name);
    tags.sort((a, b) => tagNames.indexOf(a).compareTo(tagNames.indexOf(b)));
    _save(item, tags: tags, comment: commentText.text);
  }

  void commentChanged() {
    _dirtyComment = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), flushComment);
  }

  void flushComment() {
    _debounce?.cancel();
    final item = current;
    if (!_dirtyComment || item == null) return;
    _dirtyComment = false;
    _save(item, tags: recordOf(item.id).tags, comment: commentText.text);
  }

  String _statusFor(List<String> tags, String comment, String old) {
    if (tags.isNotEmpty || comment.trim().isNotEmpty) return 'tagged';
    return old == 'tagged' ? 'not_reviewed' : old;
  }

  void _save(
    ReviewItem item, {
    required List<String> tags,
    required String comment,
    String? status,
  }) {
    final old = recordOf(item.id);
    final next = NoteRecord(
      id: item.id,
      tags: tags,
      comment: comment,
      status: status ?? _statusFor(tags, comment, old.status),
      previous: old.previous,
    );
    _records[item.id] = next;
    unawaited(
      api.saveNote({
        'id': item.id,
        'kind': item.kind,
        'file': item.file,
        'exams': item.exams,
        'state': screenState,
        if (screenState == 'wrong') 'choice': wrongLetter,
        'size': wide ? 'wide' : 'phone',
        'theme': dark ? 'dark' : 'light',
        'tags': tags,
        'comment': comment,
        'status': next.status,
        'hash': item.hash,
        'commit': '',
        if (old.previous != null) 'previous': old.previous,
      }),
    );
    notifyListeners();
  }

  /// Marks the item as fine and moves on.
  void looksGood() {
    final item = current;
    if (item == null) return;
    flushComment();
    final record = recordOf(item.id);
    _save(
      item,
      tags: record.tags,
      comment: record.comment,
      status: 'looks_good',
    );
    _advance(item);
  }

  /// Moves on, keeping whatever was noted.
  void next() {
    final item = current;
    if (item == null) return;
    flushComment();
    final record = recordOf(item.id);
    if (record.tags.isNotEmpty || record.comment.trim().isNotEmpty) {
      if (record.status != 'tagged') {
        _save(item, tags: record.tags, comment: record.comment);
      }
    }
    _advance(item);
  }

  void _advance(ReviewItem from) {
    final at = _items.indexWhere((i) => i.id == from.id);
    final target = _items.skip(at + 1).where(_matches).firstOrNull;
    if (target == null) {
      nothingLeft = true;
    } else {
      _open(target);
    }
    _savePosition();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    commentFocus.dispose();
    commentText.dispose();
    super.dispose();
  }
}
