import 'package:pantas/core/fsrs/rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('values map to grades 1..4', () {
    expect(Rating.again.grade, equals(1));
    expect(Rating.hard.grade, equals(2));
    expect(Rating.good.grade, equals(3));
    expect(Rating.easy.grade, equals(4));
  });

  test('fromGrade round-trips', () {
    for (final r in Rating.values) {
      expect(Rating.fromGrade(r.grade), equals(r));
    }
  });

  test('fromGrade throws on invalid grade', () {
    expect(() => Rating.fromGrade(0), throwsArgumentError);
    expect(() => Rating.fromGrade(5), throwsArgumentError);
  });
}
