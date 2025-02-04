import 'package:cloud_firestore/cloud_firestore.dart';

class Round {
  final int roundNumber;
  final Timestamp startTime;
  final Timestamp endTime;
  final String status; // "in-progress", "completed"

  Round({
    required this.roundNumber,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  // Convert Round model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'roundNumber': roundNumber,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
    };
  }

  // Convert Firestore document to Round model
  factory Round.fromMap(Map<String, dynamic> data) {
    return Round(
        roundNumber: data['roundNumber'],
        startTime: data['startTime'],
        endTime: data['endTime'],
        status: data['status']);
  }
}
