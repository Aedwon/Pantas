import 'dart:convert';

import 'package:pantas/core/content/remote/lesson_markdown.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';

/// A small SVG picture as the lesson carries it: a data URI. [viewBox] gives
/// the natural size through the viewBox; without it the size comes from
/// width and height, and [sized] false leaves the picture with no size at all.
String pictureUri(
  double w,
  double h, {
  bool viewBox = true,
  bool sized = true,
}) {
  final size = !sized
      ? ''
      : viewBox
          ? ' viewBox="0 0 $w $h"'
          : ' width="$w" height="$h"';
  final svg = [
    '<svg xmlns="http://www.w3.org/2000/svg"$size>',
    '<rect x="0" y="0" width="$w" height="$h" fill="#d8e4f0"/>',
    '<circle cx="${w / 2}" cy="${h / 2}" r="${h / 4}" fill="#4a78b0"/>',
    '</svg>',
  ].join();
  return 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}';
}

/// A lesson `image` block that carries [url].
Map<String, Object?> pictureBlock(String url, {String alt = 'A picture'}) => {
      '_type': 'image',
      'alt': alt,
      'asset': {'url': url},
    };

Map<String, Object?> paragraph(String text) => {
      '_type': 'block',
      'style': 'normal',
      'children': [
        {'_type': 'span', 'text': text},
      ],
    };

Map<String, Object?> heading(String text, String style) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text},
      ],
    };

/// A walk-through lesson shaped like the age problems lesson: a paragraph, a
/// picture, then a Why? and a pair, and a second section.
List<Map<String, Object?>> agePicturesLesson({String? url}) {
  final blocks = lessonBlocksFromMarkdown(r'''
## Core Concept

### Ages Today

Anna is twice as old as Ben. Their ages add up to 36 years.

:::why
Why call Ben's age $x$? Then Anna is $2x$, and the two add up to $3x$.
:::

:::pair #age-sum
Right: $x + 2x = 36$
Wrong: $x + 2 = 36$
Anna is twice Ben, so her age is $2x$, not $x + 2$.
:::

### Ages Later

In 4 years, each age is 4 more.
''');
  final at = blocks.indexWhere(
    (b) => b['_type'] == 'block' && b.toString().contains('Anna is twice'),
  );
  return [
    ...blocks.sublist(0, at + 1),
    pictureBlock(url ?? pictureUri(360, 208)),
    ...blocks.sublist(at + 1),
  ];
}

ReaderContext readerFor(String id, List<Map<String, Object?>> body) =>
    ReaderContext(
      lesson: Lesson(
        id: id,
        topicId: 't',
        title: 'Age Word Problems',
        summary: '',
        estimatedMinutes: 10,
        bodyJson: body,
      ),
      topicId: 't',
      topicName: 'Algebra',
      next: null,
      positionInTopic: 1,
      lessonsInTopic: 1,
      topicLessons: const [
        StudyLesson(
          id: 'x',
          title: 'x',
          isRead: false,
          isBookmarked: false,
        ),
      ],
      isRead: false,
      isBookmarked: false,
      examId: 'e',
    );
