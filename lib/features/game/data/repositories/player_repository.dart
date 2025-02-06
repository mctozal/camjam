import 'package:camjam/features/game/data/models/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPlayer(String gameCode, Player player) async {
    try {
      print('Adding player: ${player.toMap()} to game: $gameCode');

      await _firestore
          .collection('games')
          .doc(gameCode)
          .collection('players')
          .doc(player.id)
          .set(player.toMap());

      print('Player added successfully');
    } catch (e) {
      print('Error adding/updating player: $e');
      throw Exception('Error adding/updating player: $e');
    }
  }

  void removePlayerFromGame(String gameCode, String playerId) {
    _firestore
        .collection('games')
        .doc(gameCode)
        .collection('players')
        .doc(playerId)
        .delete()
        .then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
  }

  Stream<List<Player>> listenToPlayers(String gameCode) {
    return _firestore
        .collection('games')
        .doc(gameCode)
        .collection('players') // Listen to the players subcollection
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Player.fromMap(
              doc.data())) // Convert each document to a Player object
          .toList();
    });
  }

  Future<void> increasePlayerScore(String gameCode, String playerId) async {
    try {
      // Get the player's document in the players collection
      final playerRef = _firestore
          .collection(
              'games') // Assuming 'games' is the collection for the games
          .doc(gameCode) // Game document identified by gameCode
          .collection('players') // Players subcollection
          .doc(playerId); // Player document identified by playerId

      // Get the current player's score
      final playerSnapshot = await playerRef.get();
      if (playerSnapshot.exists) {
        final currentScore = playerSnapshot.data()?['score'] ?? 0;

        // Update the player's score
        await playerRef.update({
          'score': currentScore + 10, // Increment the score by 10
        });

        print('Player score updated successfully');
      } else {
        print('Player not found');
      }
    } catch (e) {
      print('Error updating player score: $e');
    }
  }
}
