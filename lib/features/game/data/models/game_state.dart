class GameState {
  final int roundNumber;
  final String pov;
  final List<String> photoUrls; // URLs of photos taken in the round
  final Map<String, int> scores; // Player names with scores

  GameState({
    required this.roundNumber,
    required this.pov,
    required this.photoUrls,
    required this.scores,
  });

  GameState copyWith({
    int? roundNumber,
    String? pov,
    List<String>? photoUrls,
    Map<String, int>? scores,
  }) {
    return GameState(
      roundNumber: roundNumber ?? this.roundNumber,
      pov: pov ?? this.pov,
      photoUrls: photoUrls ?? this.photoUrls,
      scores: scores ?? this.scores,
    );
  }
}
