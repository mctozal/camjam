import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String gameCode;
  final int timePerRound;
  final int numberOfRounds;
  final String creatorId;
  final Timestamp createdAt;
  final String status; // "waiting", "in-progress", "completed"
  final String pov;

  final int currentRound;
  final String roundPhase;
  final Timestamp? phaseStartTime;
  final int? phaseDuration;

  Game(
      {required this.gameCode,
      required this.timePerRound,
      required this.numberOfRounds,
      required this.creatorId,
      required this.createdAt,
      required this.status,
      required this.pov,
      required this.currentRound,
      required this.roundPhase, // "counter", "pov", "photo", "voting"
      this.phaseStartTime,
      this.phaseDuration});

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
      'currentRound': currentRound,
      'roundPhase': roundPhase,
      'phaseStartTime': phaseStartTime,
      'phaseDuration': phaseDuration,
    };
  }

  // Convert Firestore document to Game model
  factory Game.fromFirestore(Map<String, dynamic> data) {
    return Game(
        gameCode: data['gameCode'],
        timePerRound: data['timePerRound'] ?? 30,
        numberOfRounds: data['numberOfRounds'] ?? 3,
        creatorId: data['creatorId'],
        createdAt: data['createdAt'],
        status: data['status'],
        pov: data['pov'],
        currentRound: data['currentRound'] ?? 1,
        roundPhase: data['roundPhase'] ?? 'counter',
        phaseStartTime: data['phaseStartTime'],
        phaseDuration: data['phaseDuration']);
  }

  Game copyWith({
    String? gameCode,
    String? creatorId,
    String? status,
    int? numberOfRounds,
    int? timePerRound,
    String? pov,
    Timestamp? createdAt,
    int? currentRound,
    String? roundPhase,
    Timestamp? phaseStartTime,
    int? phaseDuration,
  }) {
    return Game(
      gameCode: gameCode ?? this.gameCode,
      creatorId: creatorId ?? this.creatorId,
      status: status ?? this.status,
      numberOfRounds: numberOfRounds ?? this.numberOfRounds,
      timePerRound: timePerRound ?? this.timePerRound,
      pov: pov ?? this.pov,
      createdAt: createdAt ?? this.createdAt,
      currentRound: currentRound ?? this.currentRound,
      roundPhase: roundPhase ?? this.roundPhase,
      phaseStartTime: phaseStartTime ?? this.phaseStartTime,
      phaseDuration: phaseDuration ?? this.phaseDuration,
    );
  }
}
