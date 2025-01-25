class Player {
  final String id;
  final String name;
  final String photoPath;
  int score;

  Player({
    required this.id,
    required this.name,
    required this.photoPath,
    this.score = 0,
  });
}
