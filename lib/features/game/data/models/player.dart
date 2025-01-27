import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String id;
  final String name;
  int score;
  final Timestamp joinedAt;
  final String status; // "active", "inactive"

  Player({
    required this.id,
    required this.name,
    this.score = 0,
    required this.joinedAt,
    required this.status,
  });

  // Convert Player model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'joinedAt': joinedAt,
      'status': status,
    };
  }

  // Convert Firestore document to Player model
  factory Player.fromMap(Map<String, dynamic> data) {
    return Player(
      id: data['id'],
      name: data['name'],
      score: data['score'] ?? 0,
      joinedAt: data['joinedAt'],
      status: data['status'] ?? "active",
    );
  }
}
