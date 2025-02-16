import 'package:camjam/features/game/data/models/game.dart';
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

  // Update game state (e.g., waiting, in-progress, completed, paused)
  Future<void> updateGameState(String gameCode, String newState) async {
    try {
      await _firestore.collection('games').doc(gameCode).update({
        'status': newState,
      });
    } catch (e) {
      throw Exception('Error updating game state: $e');
    }
  }

  // Update pov
  Future<void> updatePov(String gameCode, String pov) async {
    try {
      await _firestore.collection('games').doc(gameCode).update({
        'pov': pov,
      });
    } catch (e) {
      throw Exception('Error updating game state: $e');
    }
  }

  Future<String?> getGameStatus(String gameCode) async {
    try {
      // Fetch the game document by gameCode
      DocumentSnapshot doc =
          await _firestore.collection('games').doc(gameCode).get();

      // Check if the document exists and contains gameState
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] ??
            'unknown'; // Return the gameState or 'unknown' if not found
      } else {
        return null; // Return null if the game doesn't exist
      }
    } catch (e) {
      throw Exception('Error fetching game status: $e');
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

  Stream<Game> listenToGame(String gameCode) {
    return _firestore
        .collection('games')
        .doc(gameCode)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return Game.fromFirestore(
            snapshot.data()!); // Convert single document to Game object
      } else {
        return Game(
            gameCode: gameCode,
            timePerRound: 0,
            numberOfRounds: 0,
            creatorId: '',
            createdAt: Timestamp.now(),
            status: 'not_found',
            pov: ''); // Return a default/fallback Game
      }
    });
  }
}
