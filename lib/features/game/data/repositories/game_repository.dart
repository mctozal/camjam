import 'package:camjam/features/game/data/models/game.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/data/models/round.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update a game
  Future<void> addGame(Game game) async {
    try {
      await _firestore.collection('games').doc(game.gameCode).set(game.toMap());
    } catch (e) {
      throw Exception('Error adding/updating game: $e');
    }
  }

  Future<void> addPlayer(String gameCode, Player player) async {
    try {
      await _firestore
          .collection('games')
          .doc(gameCode)
          .collection('players')
          .add(player.toMap());
    } catch (e) {
      throw Exception('Error adding/updating player: $e');
    }
  }

  // Update game state (e.g., waiting, in-progress, completed, paused)
  Future<void> updateGameState(String gameCode, String newState) async {
    try {
      await _firestore.collection('games').doc(gameCode).update({
        'gameState': newState,
      });
    } catch (e) {
      throw Exception('Error updating game state: $e');
    }
  }

  // Start the game (set game state to 'in-progress')
  Future<void> startGame(String gameCode) async {
    await updateGameState(gameCode, 'in-progress');
    // Additional logic to create rounds, etc.
  }

  // Complete the game (set game state to 'completed')
  Future<void> completeGame(String gameCode) async {
    await updateGameState(gameCode, 'completed');
    // Additional logic to finalize scores, etc.
  }

  // Pause the game (set game state to 'paused')
  Future<void> pauseGame(String gameCode) async {
    await updateGameState(gameCode, 'paused');
    // Additional logic to pause rounds, etc.
  }

  // Resume the game (set game state to 'in-progress')
  Future<void> resumeGame(String gameCode) async {
    await updateGameState(gameCode, 'in-progress');
    // Additional logic to resume rounds, etc.
  }

  // Add a round to the game (store round information)
  Future<void> addRound(String gameCode, Round round) async {
    try {
      await _firestore
          .collection('games')
          .doc(gameCode)
          .collection('rounds')
          .doc('round_${round.roundNumber}')
          .set(round.toMap());
    } catch (e) {
      throw Exception('Error adding round to Firestore: $e');
    }
  }

  // Update round scores
  Future<void> updateRoundScores(
      String gameCode, int roundNumber, Map<String, dynamic> scores) async {
    try {
      await _firestore
          .collection('games')
          .doc(gameCode)
          .collection('rounds')
          .doc('round_$roundNumber')
          .update({'scores': scores});
    } catch (e) {
      throw Exception('Error updating round scores: $e');
    }
  }

  // Listen to game updates (including gameState and players)
  Stream<DocumentSnapshot> listenToGame(String gameCode) {
    return _firestore.collection('games').doc(gameCode).snapshots();
  }

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

  Stream<List<Player>> listenToPlayers(String gameCode) {
    return _firestore
        .collection('games')
        .doc(gameCode)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final players = (data['players'] as List<dynamic>?)
            ?.map((playerData) => Player.fromMap(playerData))
            .toList();
        return players ?? [];
      } else {
        return [];
      }
    });
  }
}
