/// Maps a blueprint topic id to the topic id in the seed built from the
/// content files.
///
/// The server paper names topics per exam (`topic_cse_pro_<slug>`, see
/// `topicIdFor` in functions/src/_examContent.ts). The exported seed names
/// them `topic_upcat_<slug>`. Other ids pass through unchanged.
String seedTopicId(String blueprintTopicId) {
  final match = RegExp(r'^topic_cse_(?:pro|sub)_(.+)$').firstMatch(
    blueprintTopicId,
  );
  return match == null ? blueprintTopicId : 'topic_upcat_${match.group(1)}';
}
