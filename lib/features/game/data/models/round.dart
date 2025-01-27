import 'package:cloud_firestore/cloud_firestore.dart';

class Round {
  final int roundNumber;
  final Timestamp startTime;
  final Timestamp endTime;
  final String status; // "in-progress", "completed"
  final Map<String, PlayerScore> scores;

  Round({
    required this.roundNumber,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.scores,
  });

  // Convert Round model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'roundNumber': roundNumber,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'scores': scores.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  // Convert Firestore document to Round model
  factory Round.fromMap(Map<String, dynamic> data) {
    return Round(
      roundNumber: data['roundNumber'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      status: data['status'],
      scores: (data['scores'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          PlayerScore.fromMap(value),
        ),
      ),
    );
  }
}

class PlayerScore {
  final int score;
  final String pictureUrl;
  final Timestamp timestamp;

  PlayerScore({
    required this.score,
    required this.pictureUrl,
    required this.timestamp,
  });

  // Convert PlayerScore to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'pictureUrl': pictureUrl,
      'timestamp': timestamp,
    };
  }

  // Convert Firestore document to PlayerScore
  factory PlayerScore.fromMap(Map<String, dynamic> data) {
    return PlayerScore(
      score: data['score'],
      pictureUrl: data['pictureUrl'],
      timestamp: data['timestamp'],
    );
  }
}
