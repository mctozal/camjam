import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String gameCode;
  final int timePerRound;
  final int numberOfRounds;
  final String creatorId;
  final Timestamp createdAt;
  final String status; // "waiting", "in-progress", "completed"
  final String pov;

  Game(
      {required this.gameCode,
      required this.timePerRound,
      required this.numberOfRounds,
      required this.creatorId,
      required this.createdAt,
      required this.status,
      required this.pov});

  // Convert Game model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'gameCode': gameCode,
      'timePerRound': timePerRound,
      'numberOfRounds': numberOfRounds,
      'creatorId': creatorId,
      'createdAt': createdAt,
      'status': status,
      'pov': pov,
    };
  }

  // Convert Firestore document to Game model
  factory Game.fromFirestore(Map<String, dynamic> data) {
    return Game(
        gameCode: data['gameCode'],
        timePerRound: data['timePerRound'],
        numberOfRounds: data['numberOfRounds'],
        creatorId: data['creatorId'],
        createdAt: data['createdAt'],
        status: data['status'],
        pov: data['pov']);
  }
}
