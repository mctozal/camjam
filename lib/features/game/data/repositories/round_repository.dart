import 'package:camjam/features/game/data/models/round.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoundRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen to rounds updates for a specific game
  Stream<QuerySnapshot> listenToRounds(String gameCode) {
    return _firestore
        .collection('games')
        .doc(gameCode)
        .collection('rounds')
        .snapshots();
  }

  // Listen to round updates
  Stream<DocumentSnapshot> listenToRound(String gameCode, int roundNumber) {
    return _firestore
        .collection('games')
        .doc(gameCode)
        .collection('rounds')
        .doc('round_$roundNumber')
        .snapshots();
  }

  // Update game state (e.g., waiting, in-progress, completed, paused)
  Future<void> updateRoundState(
      String gameCode, String roundNumber, String newState) async {
    try {
      await _firestore
          .collection('games')
          .doc(gameCode)
          .collection('rounds')
          .doc(roundNumber)
          .update({'status': newState, 'endTime': Timestamp.now()});
    } catch (e) {
      throw Exception('Error updating game state: $e');
    }
  }

  // Add a round to the game (store round information)
  Future<void> addRound(String gameCode, Round round) async {
    try {
      await _firestore
          .collection('games')
          .doc(gameCode)
          .collection('rounds')
          .doc('${round.roundNumber}')
          .set(round.toMap());
    } catch (e) {
      throw Exception('Error adding round to Firestore: $e');
    }
  }

  // Complete the game (set game state to 'completed')
  Future<void> completeRound(String gameCode, String roundNumber) async {
    await updateRoundState(gameCode, roundNumber, 'completed');
    // Additional logic to finalize scores, etc.
  }
}
