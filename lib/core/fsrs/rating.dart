enum Rating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  const Rating(this.grade);
  final int grade;

  static Rating fromGrade(int g) => switch (g) {
        1 => Rating.again,
        2 => Rating.hard,
        3 => Rating.good,
        4 => Rating.easy,
        _ => throw ArgumentError('rating grade must be 1..4, got $g'),
      };
}
