// coverage:ignore-file
import 'package:cse_cet_reviewer/core/storage/data/tables/exams_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/topics_table.dart';
import 'package:drift/drift.dart';

/// Topics a track hides.
///
/// An exclusion list rather than an inclusion list, so "narrowing filters, it
/// never purges" is literal: a row means hidden, no rows means everything is
/// in. Re-ticking deletes the row and everything is back, because nothing was
/// ever keyed on the scope.
@DataClassName('TrackScopeExclusionRow')
class TrackScopeLocal extends Table {
  TextColumn get examId => text().references(Exams, #id)();
  TextColumn get topicId => text().references(Topics, #id)();

  @override
  Set<Column<Object>> get primaryKey => {examId, topicId};
}
