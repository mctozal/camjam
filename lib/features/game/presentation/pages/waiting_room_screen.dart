import 'dart:async'; // For Timer
import 'package:camjam/core/services/user_service.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/presentation/pages/game_screen.dart';
import 'package:camjam/features/game/data/repositories/game_repository.dart';
import 'package:flutter/material.dart';

class WaitingRoomScreen extends StatefulWidget {
  final int timePerRound;
  final int numberOfRounds;
  final String gameCode;
  final String currentUserId;

  WaitingRoomScreen({
    required this.timePerRound,
    required this.numberOfRounds,
    required this.gameCode,
    required this.currentUserId,
  });

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final GameRepository gameRepository =
      GameRepository(); // Initialize the repository
  List<Player> players = []; // Track the list of players
  late Stream<List<Player>> playerStream;

  @override
  void initState() {
    super.initState();

    // Initialize the player stream
    playerStream = gameRepository.listenToPlayers(widget.gameCode);

    // Listen to the player stream and update the UI
    playerStream.listen((updatedPlayers) {
      setState(() {
        players = updatedPlayers;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting Room'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Waiting for players to join...',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Game Code: ${widget.gameCode}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            // Display the PlayersScreen within the WaitingRoomScreen
            Expanded(
              child: StreamBuilder<List<Player>>(
                stream: playerStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final players = snapshot.data ?? [];

                  if (players.isEmpty) {
                    return Center(
                      child: Text(
                        'No players have joined yet.',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                              player.name[0]), // Display first letter of name
                        ),
                        title: Text(player.name),
                        subtitle: Text('Score: ${player.score}'),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.6, 50),
              ),
              onPressed: players.isNotEmpty
                  ? () {
                      _startGame();
                    }
                  : null, // Disable button if no players have joined
              child: Text(
                'Start Game',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    // Navigate to the GameScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          currentPlayerId: widget.currentUserId,
          players: players,
          numberOfRounds: widget.numberOfRounds,
          timePerRound: widget.timePerRound,
        ),
      ),
    );

    // Notify the user that the game has started
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Game Started!')),
    );
  }
}
