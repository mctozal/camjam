import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camjam/features/game/data/models/round.dart';

class VotingScreen extends StatelessWidget {
  final Round currentRound; // Current round object
  final String currentPlayerId;
  final VoidCallback onRoundComplete;

  VotingScreen({
    required this.currentRound,
    required this.currentPlayerId,
    required this.onRoundComplete,
  });

  @override
  Widget build(BuildContext context) {
    final scores = currentRound.scores;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting Screen'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Vote for the most funny picture!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: scores.isNotEmpty
                  ? ListView(
                      children: scores.entries
                          .where((entry) =>
                              entry.key !=
                              currentPlayerId) // Exclude current player
                          .map((entry) {
                        final playerId = entry.key;
                        final playerScore = entry.value;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: playerScore.pictureUrl.isNotEmpty
                                ? Image.network(
                                    playerScore.pictureUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const CircularProgressIndicator();
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                          Icons.image_not_supported);
                                    },
                                  )
                                : const Icon(Icons.image_not_supported),
                            title: Text('Player: $playerId'),
                            subtitle: Text(
                              'Score: ${playerScore.score}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // Increment score and handle vote
                                _voteForPlayer(playerId, context);
                              },
                              child: const Text('Vote'),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : Center(
                      child: Text(
                        'No photos to vote on.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context);
                onRoundComplete();
              },
              child: const Text('Skip Voting'),
            ),
          ],
        ),
      ),
    );
  }

  void _voteForPlayer(String playerId, BuildContext context) {
    // Update the score in Firestore for the selected player
    final scoresRef = FirebaseFirestore.instance
        .collection('games')
        .doc('gameId') // Replace with the actual game ID
        .collection('rounds')
        .doc('round_${currentRound.roundNumber}');

    scoresRef.update({
      'scores.$playerId.score': FieldValue.increment(1),
    }).then((_) {
      Navigator.pop(context);
      onRoundComplete();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cast vote: $error')),
      );
    });
  }
}
