import 'dart:io';

import 'package:camjam/features/game/data/models/player.dart';
import 'package:flutter/material.dart';

class VotingScreen extends StatelessWidget {
  final List<Player> players;
  final String currentPlayerId;
  final String? capturedPhotoPath;
  final VoidCallback onRoundComplete;

  VotingScreen({
    required this.players,
    required this.currentPlayerId,
    required this.capturedPhotoPath,
    required this.onRoundComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: players
                  .where((player) =>
                      player.id !=
                      currentPlayerId) // Exclude current player's photo
                  .map((player) {
                return ListTile(
                  leading: Image.file(
                    File(player.photoPath),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(player.name),
                  trailing: ElevatedButton(
                    onPressed: () {
                      player.score++;
                      Navigator.pop(context);
                      onRoundComplete();
                    },
                    child: const Text('Vote'),
                  ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRoundComplete();
            },
            child: const Text('Skip Voting'),
          ),
        ],
      ),
    );
  }
}
