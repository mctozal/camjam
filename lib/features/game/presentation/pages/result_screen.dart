import 'package:flutter/material.dart';
import 'package:camjam/features/game/data/models/player.dart';

class ResultScreen extends StatelessWidget {
  final List<Player> players;

  const ResultScreen({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    // Sort players by score in descending order
    final sortedPlayers = players.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Final Scores:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: sortedPlayers.length,
                itemBuilder: (context, index) {
                  final player = sortedPlayers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      '${player.score} pts',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Play Again'),
        ),
      ),
    );
  }
}
